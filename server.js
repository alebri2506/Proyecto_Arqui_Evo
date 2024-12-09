const { ApolloServer, gql } = require("apollo-server");
const { sequelize, User, Task } = require("./db");
const bcrypt = require("bcryptjs");
require("dotenv").config();

// GraphQL schema definition
const typeDefs = gql`
  type User {
    id_user: Int
    first_name: String
    last_name: String
    email: String
    role: String
  }

  type Task {
    id_task: Int
    user_id: Int
    title: String
    description: String
    status: String
    priority: String
    deadline: String
  }

  type Query {
    users: [User]
    tasks: [Task]
    user(id_user: Int): User
    task(id_task: Int): Task
  }

  type Mutation {
    createUser(
      first_name: String
      last_name: String
      email: String
      password: String
      role: String
    ): User
    createTask(
      user_id: Int
      title: String
      description: String
      status: String
      priority: String
      deadline: String
    ): Task
    loginUser(email: String, password: String): String
  }
`;

// Resolvers to handle GraphQL queries and mutations
const resolvers = {
  Query: {
    users: async () => await User.findAll(),
    tasks: async () => await Task.findAll(),
    user: async (_, { id_user }) => await User.findByPk(id_user),
    task: async (_, { id_task }) => await Task.findByPk(id_task),
  },

  Mutation: {
    createUser: async (_, { first_name, last_name, email, password, role }) => {
      const hashedPassword = await bcrypt.hash(password, 10);
      return await User.create({
        first_name,
        last_name,
        email,
        password: hashedPassword,
        role,
      });
    },

    createTask: async (
      _,
      { user_id, title, description, status, priority, deadline }
    ) => {
      return await Task.create({
        user_id,
        title,
        description,
        status,
        priority,
        deadline,
      });
    },

    loginUser: async (_, { email, password }) => {
      const user = await User.findOne({ where: { email } });
      if (!user) throw new Error("User not found");

      const isPasswordValid = await bcrypt.compare(password, user.password);
      if (!isPasswordValid) throw new Error("Invalid password");

      // Here you can generate and return a JWT token
      return "JWT-TOKEN-HERE"; // Example placeholder for a JWT token
    },
  },
};

// Apollo Server setup
const server = new ApolloServer({
  typeDefs,
  resolvers,
  context: async ({ req }) => {
    // Implement authentication context if needed (e.g., validate JWT)
  },
});

// Start the server
const startServer = async () => {
  try {
    // Sync the Sequelize models with the database
    await sequelize.sync(); // Set `force: true` to drop and recreate tables (be careful with this in production)
    console.log("Database synced successfully");

    // Start the Apollo Server
    await server.listen({ port: process.env.PORT || 4000 });
    console.log(
      `Server running at http://localhost:${process.env.PORT || 4000}`
    );
  } catch (error) {
    console.error("Error starting the server:", error);
  }
};

startServer();
