-- Habilitar extensión para cifrado de contraseñas
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Crear tabla USUARIOS
CREATE TABLE Usuarios (
    id_Usuario SERIAL PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL,
    correo VARCHAR(50) NOT NULL,
    contraseña TEXT NOT NULL,
    rol VARCHAR(20) NOT NULL
);
INSERT INTO Usuarios (nombre, apellido, correo, contraseña, rol)
VALUES
('Juan', 'Pérez', 'juan.perez@email.com', crypt('password123', gen_salt('bf')), 'admin'),
('Maria', 'Lopez', 'maria.lopez@email.com', crypt('password456', gen_salt('bf')), 'user'),
('Carlos', 'Gomez', 'carlos.gomez@email.com', crypt('password789', gen_salt('bf')), 'user'),
('Ana', 'Martinez', 'ana.martinez@email.com', crypt('password321', gen_salt('bf')), 'user'),
('Luis', 'Diaz', 'luis.diaz@email.com', crypt('password654', gen_salt('bf')), 'user'),
('Pedro', 'Sanchez', 'pedro.sanchez@email.com', crypt('password987', gen_salt('bf')), 'admin'),
('Lucia', 'Fernandez', 'lucia.fernandez@email.com', crypt('password654', gen_salt('bf')), 'user'),
('Rafael', 'Perez', 'rafael.perez@email.com', crypt('password852', gen_salt('bf')), 'user'),
('Sofia', 'Moreno', 'sofia.moreno@email.com', crypt('password159', gen_salt('bf')), 'user'),
('Elena', 'Garcia', 'elena.garcia@email.com', crypt('password963', gen_salt('bf')), 'user'),
('Felipe', 'Ruiz', 'felipe.ruiz@email.com', crypt('password258', gen_salt('bf')), 'user'),
('Paola', 'Alvarez', 'paola.alvarez@email.com', crypt('password741', gen_salt('bf')), 'user'),
('Javier', 'Jimenez', 'javier.jimenez@email.com', crypt('password852', gen_salt('bf')), 'admin'),
('Marta', 'Gonzalez', 'marta.gonzalez@email.com', crypt('password963', gen_salt('bf')), 'user'),
('Diego', 'Ramirez', 'diego.ramirez@email.com', crypt('password369', gen_salt('bf')), 'user');



-- Crear tabla TAREAS
CREATE TABLE Tareas (
    id_tarea SERIAL PRIMARY KEY,
    id_usuario_T INTEGER REFERENCES Usuarios(id_Usuario) NOT NULL,
    titulo VARCHAR(50) NOT NULL,
    descripcion TEXT,
    estado VARCHAR(15) CHECK (estado IN ('pendiente', 'completada', 'vencida')) NOT NULL,
    prioridad VARCHAR(15) CHECK (prioridad IN ('alta', 'media', 'baja')) NOT NULL,
    fecha_limite DATE NOT NULL
);

INSERT INTO tareas (id_usuario_T, id_Pro, titulo, descripcion, estado, prioridad, fecha_limite)
VALUES
(1, 1, 'Crear bocetos', 'Realizar bocetos iniciales para la interfaz de la app', 'pendiente', 'media', '2024-12-10'),
(2, 1, 'Diseño base de datos', 'Diseñar las tablas principales de la aplicación', 'pendiente', 'alta', '2024-12-12'),
(3, 2, 'Revisar algoritmos', 'Investigar sobre los algoritmos de redes neuronales', 'pendiente', 'media', '2024-12-15'),
(4, 3, 'Definir paleta de colores', 'Seleccionar colores para el portafolio', 'pendiente', 'baja', '2024-12-11'),
(5, 4, 'Configurar routers', 'Realizar la configuración inicial de los routers', 'completada', 'alta', '2024-12-14'),
(6, 5, 'Crear diagrama ER', 'Diseñar el diagrama entidad-relación del sistema', 'pendiente', 'media', '2024-12-08'),
(7, 6, 'Montar estructura', 'Ensayar el ensamblaje del brazo robótico', 'pendiente', 'alta', '2024-12-18'),
(8, 7, 'Probar vulnerabilidades', 'Hacer pruebas básicas en aplicaciones seleccionadas', 'vencida', 'alta', '2024-12-20'),
(9, 8, 'Diseñar sprites', 'Crear los personajes principales del videojuego', 'pendiente', 'media', '2024-12-19'),
(10, 9, 'Calcular eficiencia', 'Estimar la eficiencia del panel solar en pruebas', 'vencida', 'baja', '2024-12-22'),
(11, 10, 'Diseñar mockups', 'Crear diseños preliminares de la app móvil', 'completada', 'alta', '2024-12-15'),
(12, 11, 'Realizar simulación', 'Probar colisiones entre objetos con software', 'pendiente', 'media', '2024-12-17'),
(13, 12, 'Configurar carrito', 'Implementar funcionalidad de carrito de compras', 'pendiente', 'media', '2024-12-23'),
(14, 13, 'Visualizar datos', 'Crear gráficos con resultados de las encuestas', 'pendiente', 'alta', '2024-12-26'),
(15, 14, 'Revisar logs', 'Auditar los registros del servidor del campus', 'vencida', 'alta', '2024-12-27');
select * from tareas;


-- Índices para mejorar rendimiento
CREATE INDEX estado_prioridad_idx ON Tareas(estado, prioridad);
CREATE INDEX fecha_limite_idx ON Tareas(fecha_limite);




-- Función para actualizar automáticamente el estado de tareas vencidas
CREATE OR REPLACE FUNCTION actualizar_estado_vencido()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.fecha_limite < CURRENT_DATE AND NEW.estado != 'completada' THEN
        NEW.estado = 'vencida';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;




-- Trigger para aplicar la función en inserciones y actualizaciones
CREATE TRIGGER trigger_actualizar_estado
BEFORE INSERT OR UPDATE ON Tareas
FOR EACH ROW EXECUTE FUNCTION actualizar_estado_vencido();




-- Consultas frecuentes
-- Tareas por estado
SELECT * FROM Tareas WHERE estado = 'completada';
SELECT * FROM Tareas WHERE estado = 'pendiente';
SELECT * FROM Tareas WHERE estado = 'vencida';




-- Tareas que vencen en menos de 7 días
SELECT * FROM Tareas 
WHERE estado = 'pendiente' AND fecha_limite <= CURRENT_DATE + INTERVAL '7 days';




-- Usuarios con más tareas asignadas
SELECT u.nombre, u.apellido, COUNT(t.id_tarea) AS total_tareas
FROM Usuarios u
JOIN Tareas t ON u.id_Usuario = t.id_usuario_T
GROUP BY u.id_Usuario
ORDER BY total_tareas DESC;




-- Proyectos con más tareas completadas
SELECT p.titulo, COUNT(t.id_tarea) AS tareas_completadas
FROM Proyecto p
JOIN Tareas t ON p.id_proyecto = t.id_Pro
WHERE t.estado = 'completada'
GROUP BY p.id_proyecto
ORDER BY tareas_completadas DESC;
