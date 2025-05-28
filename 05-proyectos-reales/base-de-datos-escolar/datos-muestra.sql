-- =====================================================
-- SISTEMA ESCOLAR AVANZADO - DATOS DE MUESTRA
-- =====================================================
-- Descripción: Datos de prueba para el sistema escolar
-- Autor: MySQL Advanced Course
-- Fecha: 2025
-- =====================================================

USE sistema_escolar_avanzado;

-- =====================================================
-- INSERTAR NIVELES EDUCATIVOS
-- =====================================================

INSERT INTO niveles_educativos (nombre, descripcion, orden_nivel, edad_minima, edad_maxima, duracion_anos) VALUES
('Preescolar', 'Educación inicial para niños pequeños', 1, 3, 5, 3),
('Primaria', 'Educación básica primaria', 2, 6, 11, 6),
('Secundaria', 'Educación básica secundaria', 3, 12, 16, 5),
('Media Técnica', 'Educación media con énfasis técnico', 4, 17, 18, 2),
('Preparatoria', 'Preparación para educación superior', 4, 16, 18, 3);

-- =====================================================
-- INSERTAR GRADOS
-- =====================================================

-- Preescolar
INSERT INTO grados (nivel_id, nombre, numero_grado, descripcion) VALUES
(1, 'Prejardín', 1, 'Primer año de preescolar'),
(1, 'Jardín', 2, 'Segundo año de preescolar'),
(1, 'Transición', 3, 'Preparación para primaria');

-- Primaria
INSERT INTO grados (nivel_id, nombre, numero_grado, descripcion) VALUES
(2, 'Primero', 1, 'Primer grado de primaria'),
(2, 'Segundo', 2, 'Segundo grado de primaria'),
(2, 'Tercero', 3, 'Tercer grado de primaria'),
(2, 'Cuarto', 4, 'Cuarto grado de primaria'),
(2, 'Quinto', 5, 'Quinto grado de primaria'),
(2, 'Sexto', 6, 'Sexto grado de primaria');

-- Secundaria
INSERT INTO grados (nivel_id, nombre, numero_grado, descripcion) VALUES
(3, 'Séptimo', 7, 'Primer año de secundaria'),
(3, 'Octavo', 8, 'Segundo año de secundaria'),
(3, 'Noveno', 9, 'Tercer año de secundaria'),
(3, 'Décimo', 10, 'Cuarto año de secundaria'),
(3, 'Once', 11, 'Último año de educación básica');

-- =====================================================
-- INSERTAR MATERIAS
-- =====================================================

-- Materias para Primaria
INSERT INTO materias (codigo, nombre, descripcion, nivel_id, creditos, horas_semanales, tipo_materia) VALUES
('PRIM-MAT', 'Matemáticas', 'Fundamentos matemáticos básicos', 2, 5, 6, 'obligatoria'),
('PRIM-ESP', 'Español', 'Lenguaje y comunicación', 2, 5, 6, 'obligatoria'),
('PRIM-CN', 'Ciencias Naturales', 'Conocimiento del medio natural', 2, 3, 3, 'obligatoria'),
('PRIM-CS', 'Ciencias Sociales', 'Historia y geografía básica', 2, 3, 3, 'obligatoria'),
('PRIM-ING', 'Inglés', 'Idioma extranjero', 2, 2, 2, 'obligatoria'),
('PRIM-EF', 'Educación Física', 'Desarrollo motor y deportivo', 2, 2, 2, 'obligatoria'),
('PRIM-ART', 'Educación Artística', 'Expresión artística y cultural', 2, 2, 2, 'obligatoria'),
('PRIM-TEC', 'Tecnología', 'Fundamentos tecnológicos', 2, 1, 1, 'obligatoria');

-- Materias para Secundaria
INSERT INTO materias (codigo, nombre, descripcion, nivel_id, creditos, horas_semanales, tipo_materia) VALUES
('SEC-MAT', 'Matemáticas', 'Álgebra, geometría y estadística', 3, 5, 5, 'obligatoria'),
('SEC-ESP', 'Lengua Castellana', 'Literatura y comunicación avanzada', 3, 4, 4, 'obligatoria'),
('SEC-ING', 'Inglés', 'Idioma extranjero intermedio-avanzado', 3, 3, 3, 'obligatoria'),
('SEC-FIS', 'Física', 'Principios físicos fundamentales', 3, 3, 3, 'obligatoria'),
('SEC-QUI', 'Química', 'Fundamentos químicos', 3, 3, 3, 'obligatoria'),
('SEC-BIO', 'Biología', 'Ciencias de la vida', 3, 3, 3, 'obligatoria'),
('SEC-HIS', 'Historia', 'Historia universal y nacional', 3, 2, 2, 'obligatoria'),
('SEC-GEO', 'Geografía', 'Geografía física y humana', 3, 2, 2, 'obligatoria'),
('SEC-FIL', 'Filosofía', 'Pensamiento crítico y ética', 3, 2, 2, 'obligatoria'),
('SEC-EF', 'Educación Física', 'Deportes y salud física', 3, 2, 2, 'obligatoria'),
('SEC-ART', 'Educación Artística', 'Arte, música y expresión', 3, 2, 2, 'optativa'),
('SEC-TEC', 'Tecnología e Informática', 'Computación y tecnología', 3, 2, 2, 'obligatoria');

-- =====================================================
-- INSERTAR PERÍODOS ACADÉMICOS
-- =====================================================

INSERT INTO periodos_academicos (nombre, tipo_periodo, fecha_inicio, fecha_fin, fecha_inicio_inscripciones, fecha_fin_inscripciones, año_academico) VALUES
('Año Académico 2023', 'anual', '2023-02-01', '2023-11-30', '2022-12-01', '2023-01-31', 2023),
('Año Académico 2024', 'anual', '2024-02-01', '2024-11-30', '2023-12-01', '2024-01-31', 2024),
('Año Académico 2025', 'anual', '2025-02-01', '2025-11-30', '2024-12-01', '2025-01-31', 2025);

-- =====================================================
-- INSERTAR PERSONAS
-- =====================================================

-- Profesores
INSERT INTO personas (tipo_persona, numero_documento, nombres, apellidos, fecha_nacimiento, genero, telefono, email, nacionalidad) VALUES
('profesor', '12345678', 'María Elena', 'González Rodríguez', '1980-03-15', 'F', '555-0101', 'maria.gonzalez@colegio.edu', 'Colombiana'),
('profesor', '23456789', 'Carlos Alberto', 'Martínez López', '1975-07-22', 'M', '555-0102', 'carlos.martinez@colegio.edu', 'Colombiana'),
('profesor', '34567890', 'Ana Lucía', 'Pérez Vargas', '1982-11-08', 'F', '555-0103', 'ana.perez@colegio.edu', 'Colombiana'),
('profesor', '45678901', 'Roberto', 'Hernández Silva', '1978-05-30', 'M', '555-0104', 'roberto.hernandez@colegio.edu', 'Colombiana'),
('profesor', '56789012', 'Claudia Patricia', 'Ramírez Díaz', '1985-09-12', 'F', '555-0105', 'claudia.ramirez@colegio.edu', 'Colombiana'),
('profesor', '67890123', 'Jorge Luis', 'Morales Castillo', '1972-12-03', 'M', '555-0106', 'jorge.morales@colegio.edu', 'Colombiana'),
('profesor', '78901234', 'Sandra Milena', 'Torres Mejía', '1983-04-18', 'F', '555-0107', 'sandra.torres@colegio.edu', 'Colombiana'),
('profesor', '89012345', 'Andrés Felipe', 'Jiménez Ruiz', '1979-08-25', 'M', '555-0108', 'andres.jimenez@colegio.edu', 'Colombiana'),
('profesor', '90123456', 'Luz Marina', 'Acosta Fernández', '1981-01-14', 'F', '555-0109', 'luz.acosta@colegio.edu', 'Colombiana'),
('profesor', '01234567', 'Fernando', 'Gómez Sánchez', '1976-06-07', 'M', '555-0110', 'fernando.gomez@colegio.edu', 'Colombiana');

-- Padres de familia
INSERT INTO personas (tipo_persona, numero_documento, nombres, apellidos, fecha_nacimiento, genero, telefono, email) VALUES
('padre_familia', '11111111', 'Juan Carlos', 'Rodríguez Mora', '1975-03-10', 'M', '555-1001', 'juan.rodriguez@email.com'),
('padre_familia', '22222222', 'Patricia', 'Mora Jiménez', '1978-07-15', 'F', '555-1002', 'patricia.mora@email.com'),
('padre_familia', '33333333', 'Luis Alberto', 'García Vásquez', '1973-11-22', 'M', '555-1003', 'luis.garcia@email.com'),
('padre_familia', '44444444', 'Carmen Rosa', 'Vásquez Herrera', '1976-05-08', 'F', '555-1004', 'carmen.vasquez@email.com'),
('padre_familia', '55555555', 'Miguel Ángel', 'López Cruz', '1980-09-18', 'M', '555-1005', 'miguel.lopez@email.com'),
('padre_familia', '66666666', 'Gloria Elena', 'Cruz Medina', '1982-12-03', 'F', '555-1006', 'gloria.cruz@email.com'),
('padre_familia', '77777777', 'Ricardo Antonio', 'Mendoza Ríos', '1977-02-28', 'M', '555-1007', 'ricardo.mendoza@email.com'),
('padre_familia', '88888888', 'Adriana', 'Ríos Salazar', '1979-06-14', 'F', '555-1008', 'adriana.rios@email.com'),
('padre_familia', '99999999', 'Jairo Hernán', 'Salazar Pineda', '1974-10-05', 'M', '555-1009', 'jairo.salazar@email.com'),
('padre_familia', '10101010', 'Beatriz Elena', 'Pineda Contreras', '1981-04-12', 'F', '555-1010', 'beatriz.pineda@email.com');

-- Estudiantes
INSERT INTO personas (tipo_persona, numero_documento, nombres, apellidos, fecha_nacimiento, genero, telefono, email) VALUES
('estudiante', 'EST001', 'Sofía Alejandra', 'Rodríguez Mora', '2010-05-15', 'F', '555-2001', 'sofia.rodriguez@estudiante.edu'),
('estudiante', 'EST002', 'Sebastián', 'García Vásquez', '2009-08-22', 'M', '555-2002', 'sebastian.garcia@estudiante.edu'),
('estudiante', 'EST003', 'Valentina', 'López Cruz', '2011-03-10', 'F', '555-2003', 'valentina.lopez@estudiante.edu'),
('estudiante', 'EST004', 'Daniel Alejandro', 'Mendoza Ríos', '2008-12-05', 'M', '555-2004', 'daniel.mendoza@estudiante.edu'),
('estudiante', 'EST005', 'Isabella', 'Salazar Pineda', '2010-07-18', 'F', '555-2005', 'isabella.salazar@estudiante.edu'),
('estudiante', 'EST006', 'Santiago', 'Herrera Gómez', '2009-11-30', 'M', '555-2006', 'santiago.herrera@estudiante.edu'),
('estudiante', 'EST007', 'Camila Andrea', 'Moreno Silva', '2011-02-14', 'F', '555-2007', 'camila.moreno@estudiante.edu'),
('estudiante', 'EST008', 'Nicolás', 'Vargas Castillo', '2008-09-08', 'M', '555-2008', 'nicolas.vargas@estudiante.edu'),
('estudiante', 'EST009', 'Mariana', 'Jiménez Torres', '2010-04-25', 'F', '555-2009', 'mariana.jimenez@estudiante.edu'),
('estudiante', 'EST010', 'Mateo Andrés', 'Cruz Medina', '2009-06-12', 'M', '555-2010', 'mateo.cruz@estudiante.edu'),
('estudiante', 'EST011', 'Gabriela', 'Ramírez Díaz', '2011-01-08', 'F', '555-2011', 'gabriela.ramirez@estudiante.edu'),
('estudiante', 'EST012', 'Alejandro', 'Martínez López', '2008-10-20', 'M', '555-2012', 'alejandro.martinez@estudiante.edu'),
('estudiante', 'EST013', 'Lucía Fernanda', 'González Rodríguez', '2010-12-03', 'F', '555-2013', 'lucia.gonzalez@estudiante.edu'),
('estudiante', 'EST014', 'Diego Fernando', 'Pérez Vargas', '2009-03-28', 'M', '555-2014', 'diego.perez@estudiante.edu'),
('estudiante', 'EST015', 'Antonella', 'Hernández Silva', '2011-05-16', 'F', '555-2015', 'antonella.hernandez@estudiante.edu');

-- =====================================================
-- INSERTAR PROFESORES
-- =====================================================

INSERT INTO profesores (persona_id, numero_empleado, fecha_contratacion, tipo_contrato, especialidad, grado_academico, experiencia_anos, salario_base) VALUES
(1, 'PROF001', '2020-02-01', 'tiempo_completo', 'Matemáticas', 'licenciatura', 8, 3500000.00),
(2, 'PROF002', '2019-02-01', 'tiempo_completo', 'Lengua Castellana', 'maestria', 12, 4000000.00),
(3, 'PROF003', '2021-02-01', 'tiempo_completo', 'Ciencias Naturales', 'licenciatura', 6, 3200000.00),
(4, 'PROF004', '2018-02-01', 'tiempo_completo', 'Ciencias Sociales', 'maestria', 15, 4200000.00),
(5, 'PROF005', '2022-02-01', 'tiempo_completo', 'Inglés', 'licenciatura', 4, 3000000.00),
(6, 'PROF006', '2017-02-01', 'tiempo_completo', 'Educación Física', 'licenciatura', 18, 3800000.00),
(7, 'PROF007', '2020-08-01', 'tiempo_completo', 'Educación Artística', 'licenciatura', 7, 3300000.00),
(8, 'PROF008', '2019-08-01', 'tiempo_completo', 'Tecnología e Informática', 'maestria', 10, 3900000.00),
(9, 'PROF009', '2021-08-01', 'tiempo_completo', 'Filosofía', 'maestria', 9, 3700000.00),
(10, 'PROF010', '2018-08-01', 'tiempo_completo', 'Física y Química', 'maestria', 14, 4100000.00);

-- =====================================================
-- INSERTAR ESTUDIANTES
-- =====================================================

INSERT INTO estudiantes (persona_id, numero_estudiante, fecha_ingreso, grado_actual_id, padre_id, madre_id) VALUES
(11, '2024001', '2024-02-01', 7, 1, 2),     -- Sofía - Séptimo
(12, '2024002', '2024-02-01', 8, 3, 4),     -- Sebastián - Octavo  
(13, '2024003', '2024-02-01', 6, 5, 6),     -- Valentina - Sexto
(14, '2024004', '2024-02-01', 9, 7, 8),     -- Daniel - Noveno
(15, '2024005', '2024-02-01', 7, 9, 10),    -- Isabella - Séptimo
(16, '2024006', '2024-02-01', 8, 1, 2),     -- Santiago - Octavo
(17, '2024007', '2024-02-01', 6, 3, 4),     -- Camila - Sexto
(18, '2024008', '2024-02-01', 10, 5, 6),    -- Nicolás - Décimo
(19, '2024009', '2024-02-01', 7, 7, 8),     -- Mariana - Séptimo
(20, '2024010', '2024-02-01', 8, 9, 10),    -- Mateo - Octavo
(21, '2024011', '2024-02-01', 6, 1, 2),     -- Gabriela - Sexto
(22, '2024012', '2024-02-01', 10, 3, 4),    -- Alejandro - Décimo
(23, '2024013', '2024-02-01', 7, 5, 6),     -- Lucía - Séptimo
(24, '2024014', '2024-02-01', 8, 7, 8),     -- Diego - Octavo
(25, '2024015', '2024-02-01', 6, 9, 10);    -- Antonella - Sexto

-- =====================================================
-- INSERTAR SECCIONES
-- =====================================================

INSERT INTO secciones (grado_id, periodo_id, nombre_seccion, profesor_guia_id, capacidad_maxima, aula) VALUES
-- Sexto grado
(9, 2, 'A', 1, 25, 'Aula 6A'),
(9, 2, 'B', 2, 25, 'Aula 6B'),
-- Séptimo grado  
(10, 2, 'A', 3, 30, 'Aula 7A'),
(10, 2, 'B', 4, 30, 'Aula 7B'),
-- Octavo grado
(11, 2, 'A', 5, 30, 'Aula 8A'),
(11, 2, 'B', 6, 30, 'Aula 8B'),
-- Noveno grado
(12, 2, 'A', 7, 28, 'Aula 9A'),
-- Décimo grado
(13, 2, 'A', 8, 25, 'Aula 10A');

-- =====================================================
-- INSERTAR CURSOS
-- =====================================================

-- Cursos para Sexto Grado
INSERT INTO cursos (materia_id, profesor_id, seccion_id, periodo_id, codigo_curso, cupo_maximo, aula, dias_semana, hora_inicio, hora_fin, estado) VALUES
(1, 1, 1, 2, 'PRIM-MAT-6A-2024', 25, 'Aula 6A', 'lunes,martes,miercoles,jueves,viernes', '07:00:00', '07:50:00', 'activo'),
(2, 2, 1, 2, 'PRIM-ESP-6A-2024', 25, 'Aula 6A', 'lunes,martes,miercoles,jueves,viernes', '08:00:00', '08:50:00', 'activo'),
(3, 3, 1, 2, 'PRIM-CN-6A-2024', 25, 'Lab Ciencias', 'martes,jueves', '09:00:00', '09:50:00', 'activo'),
(4, 4, 1, 2, 'PRIM-CS-6A-2024', 25, 'Aula 6A', 'lunes,miercoles,viernes', '10:00:00', '10:50:00', 'activo'),
(5, 5, 1, 2, 'PRIM-ING-6A-2024', 25, 'Aula Idiomas', 'martes,jueves', '11:00:00', '11:50:00', 'activo');

-- Cursos para Séptimo Grado
INSERT INTO cursos (materia_id, profesor_id, seccion_id, periodo_id, codigo_curso, cupo_maximo, aula, dias_semana, hora_inicio, hora_fin, estado) VALUES
(9, 1, 3, 2, 'SEC-MAT-7A-2024', 30, 'Aula 7A', 'lunes,martes,miercoles,jueves,viernes', '07:00:00', '07:50:00', 'activo'),
(10, 2, 3, 2, 'SEC-ESP-7A-2024', 30, 'Aula 7A', 'lunes,martes,miercoles,jueves', '08:00:00', '08:50:00', 'activo'),
(11, 5, 3, 2, 'SEC-ING-7A-2024', 30, 'Aula Idiomas', 'martes,jueves,viernes', '09:00:00', '09:50:00', 'activo'),
(15, 3, 3, 2, 'SEC-BIO-7A-2024', 30, 'Lab Ciencias', 'lunes,miercoles,viernes', '10:00:00', '10:50:00', 'activo'),
(16, 4, 3, 2, 'SEC-HIS-7A-2024', 30, 'Aula 7A', 'martes,jueves', '11:00:00', '11:50:00', 'activo');

-- Cursos para Octavo Grado
INSERT INTO cursos (materia_id, profesor_id, seccion_id, periodo_id, codigo_curso, cupo_maximo, aula, dias_semana, hora_inicio, hora_fin, estado) VALUES
(9, 1, 5, 2, 'SEC-MAT-8A-2024', 30, 'Aula 8A', 'lunes,martes,miercoles,jueves,viernes', '07:00:00', '07:50:00', 'activo'),
(10, 2, 5, 2, 'SEC-ESP-8A-2024', 30, 'Aula 8A', 'lunes,martes,miercoles,jueves', '08:00:00', '08:50:00', 'activo'),
(11, 5, 5, 2, 'SEC-ING-8A-2024', 30, 'Aula Idiomas', 'martes,jueves,viernes', '09:00:00', '09:50:00', 'activo'),
(12, 10, 5, 2, 'SEC-FIS-8A-2024', 30, 'Lab Física', 'lunes,miercoles,viernes', '10:00:00', '10:50:00', 'activo'),
(14, 3, 5, 2, 'SEC-QUI-8A-2024', 30, 'Lab Química', 'martes,jueves', '11:00:00', '11:50:00', 'activo');

-- =====================================================
-- INSERTAR INSCRIPCIONES
-- =====================================================

INSERT INTO inscripciones (estudiante_id, periodo_id, grado_id, seccion_id, fecha_inscripcion, monto_pension) VALUES
-- Estudiantes de Sexto A
(3, 2, 9, 1, '2024-01-15 10:00:00', 450000.00),
(7, 2, 9, 1, '2024-01-15 11:00:00', 450000.00),
(11, 2, 9, 1, '2024-01-15 12:00:00', 450000.00),
(15, 2, 9, 1, '2024-01-15 13:00:00', 450000.00),

-- Estudiantes de Séptimo A
(1, 2, 10, 3, '2024-01-15 14:00:00', 500000.00),
(5, 2, 10, 3, '2024-01-15 15:00:00', 500000.00),
(9, 2, 10, 3, '2024-01-15 16:00:00', 500000.00),
(13, 2, 10, 3, '2024-01-15 17:00:00', 500000.00),

-- Estudiantes de Octavo A
(2, 2, 11, 5, '2024-01-16 09:00:00', 550000.00),
(6, 2, 11, 5, '2024-01-16 10:00:00', 550000.00),
(10, 2, 11, 5, '2024-01-16 11:00:00', 550000.00),
(14, 2, 11, 5, '2024-01-16 12:00:00', 550000.00),

-- Estudiantes de Noveno A
(4, 2, 12, 7, '2024-01-16 13:00:00', 600000.00),

-- Estudiantes de Décimo A
(8, 2, 13, 8, '2024-01-16 14:00:00', 650000.00),
(12, 2, 13, 8, '2024-01-16 15:00:00', 650000.00);

-- =====================================================
-- INSERTAR MATRÍCULAS EN CURSOS
-- =====================================================

-- Matrículas para estudiantes de Sexto A (inscripciones 1-4)
INSERT INTO matriculas_cursos (inscripcion_id, curso_id) VALUES
-- Estudiante 1 (Valentina - Sexto A)
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5),
-- Estudiante 2 (Camila - Sexto A)  
(2, 1), (2, 2), (2, 3), (2, 4), (2, 5),
-- Estudiante 3 (Gabriela - Sexto A)
(3, 1), (3, 2), (3, 3), (3, 4), (3, 5),
-- Estudiante 4 (Antonella - Sexto A)
(4, 1), (4, 2), (4, 3), (4, 4), (4, 5);

-- Matrículas para estudiantes de Séptimo A (inscripciones 5-8)
INSERT INTO matriculas_cursos (inscripcion_id, curso_id) VALUES
-- Estudiante 5 (Sofía - Séptimo A)
(5, 6), (5, 7), (5, 8), (5, 9), (5, 10),
-- Estudiante 6 (Isabella - Séptimo A)
(6, 6), (6, 7), (6, 8), (6, 9), (6, 10),
-- Estudiante 7 (Mariana - Séptimo A)
(7, 6), (7, 7), (7, 8), (7, 9), (7, 10),
-- Estudiante 8 (Lucía - Séptimo A)
(8, 6), (8, 7), (8, 8), (8, 9), (8, 10);

-- =====================================================
-- INSERTAR TIPOS DE EVALUACIÓN
-- =====================================================

INSERT INTO tipos_evaluacion (nombre, descripcion, peso_porcentual, es_recuperable) VALUES
('Primer Período', 'Evaluación del primer período académico', 25.00, TRUE),
('Segundo Período', 'Evaluación del segundo período académico', 25.00, TRUE),
('Tercer Período', 'Evaluación del tercer período académico', 25.00, TRUE),
('Examen Final', 'Evaluación final del año académico', 25.00, FALSE),
('Recuperación', 'Examen de recuperación', 0.00, FALSE),
('Trabajo en Clase', 'Evaluación continua en clase', 10.00, FALSE),
('Tareas y Proyectos', 'Trabajos asignados para casa', 15.00, TRUE);

-- =====================================================
-- INSERTAR CALIFICACIONES
-- =====================================================

-- Calificaciones para Matemáticas - Sexto A
INSERT INTO calificaciones (matricula_id, tipo_evaluacion_id, fecha_evaluacion, calificacion, registrado_por) VALUES
-- Valentina en Matemáticas
(1, 1, '2024-04-15', 4.2, 1),
(1, 2, '2024-06-15', 4.5, 1),
(1, 6, '2024-03-10', 4.0, 1),
(1, 7, '2024-05-20', 4.3, 1),

-- Camila en Matemáticas
(2, 1, '2024-04-15', 3.8, 1),
(2, 2, '2024-06-15', 4.1, 1),
(2, 6, '2024-03-10', 3.9, 1),
(2, 7, '2024-05-20', 4.0, 1),

-- Gabriela en Matemáticas
(3, 1, '2024-04-15', 4.7, 1),
(3, 2, '2024-06-15', 4.8, 1),
(3, 6, '2024-03-10', 4.5, 1),
(3, 7, '2024-05-20', 4.6, 1);

-- Calificaciones para Español - Sexto A
INSERT INTO calificaciones (matricula_id, tipo_evaluacion_id, fecha_evaluacion, calificacion, registrado_por) VALUES
-- Valentina en Español
(6, 1, '2024-04-20', 4.4, 2),
(6, 2, '2024-06-20', 4.6, 2),
(6, 6, '2024-03-15', 4.2, 2),

-- Camila en Español
(7, 1, '2024-04-20', 4.0, 2),
(7, 2, '2024-06-20', 4.2, 2),
(7, 6, '2024-03-15', 3.8, 2);

-- =====================================================
-- INSERTAR ASISTENCIA
-- =====================================================

INSERT INTO asistencia (matricula_id, fecha, estado_asistencia, registrado_por) VALUES
-- Asistencia de marzo para algunos estudiantes
(1, '2024-03-01', 'presente', 1),
(1, '2024-03-04', 'presente', 1),
(1, '2024-03-05', 'tardanza', 1),
(1, '2024-03-06', 'presente', 1),
(1, '2024-03-07', 'presente', 1),
(1, '2024-03-08', 'ausente', 1),
(1, '2024-03-11', 'presente', 1),
(1, '2024-03-12', 'presente', 1),

(2, '2024-03-01', 'presente', 1),
(2, '2024-03-04', 'tardanza', 1),
(2, '2024-03-05', 'presente', 1),
(2, '2024-03-06', 'presente', 1),
(2, '2024-03-07', 'ausente', 1),
(2, '2024-03-08', 'justificado', 1),
(2, '2024-03-11', 'presente', 1),
(2, '2024-03-12', 'presente', 1);

-- =====================================================
-- INSERTAR CONCEPTOS DE PAGO
-- =====================================================

INSERT INTO conceptos_pago (codigo, nombre, descripcion, tipo_concepto, monto_base, es_obligatorio) VALUES
('PENSION', 'Pensión Mensual', 'Pago mensual de pensión escolar', 'pension', 500000.00, TRUE),
('MATRICULA', 'Matrícula Anual', 'Pago único de matrícula por año', 'matricula', 800000.00, TRUE),
('ALIMENTACION', 'Servicio de Alimentación', 'Almuerzo escolar mensual', 'alimentacion', 150000.00, FALSE),
('TRANSPORTE', 'Servicio de Transporte', 'Transporte escolar mensual', 'transporte', 200000.00, FALSE),
('SEGURO', 'Seguro Estudiantil', 'Seguro de accidentes anual', 'otro', 50000.00, TRUE),
('ACTIVIDADES', 'Actividades Extracurriculares', 'Deportes y actividades culturales', 'otro', 100000.00, FALSE);

-- =====================================================
-- INSERTAR PAGOS
-- =====================================================

INSERT INTO pagos (estudiante_id, periodo_id, concepto_id, fecha_vencimiento, monto_original, monto_final, fecha_pago, metodo_pago, estado_pago, recibido_por) VALUES
-- Pagos de matrícula 2024
(1, 2, 2, '2024-01-31', 800000.00, 800000.00, '2024-01-20 10:00:00', 'transferencia', 'pagado', 1),
(2, 2, 2, '2024-01-31', 800000.00, 800000.00, '2024-01-22 14:30:00', 'efectivo', 'pagado', 1),
(3, 2, 2, '2024-01-31', 800000.00, 800000.00, '2024-01-25 09:15:00', 'transferencia', 'pagado', 1),

-- Pagos de pensión febrero 2024
(1, 2, 1, '2024-02-05', 500000.00, 500000.00, '2024-02-03 11:00:00', 'transferencia', 'pagado', 2),
(2, 2, 1, '2024-02-05', 550000.00, 550000.00, '2024-02-04 15:20:00', 'efectivo', 'pagado', 2),
(3, 2, 1, '2024-02-05', 450000.00, 450000.00, '2024-02-05 08:45:00', 'transferencia', 'pagado', 2),

-- Pagos de pensión marzo 2024
(1, 2, 1, '2024-03-05', 500000.00, 500000.00, '2024-03-02 10:30:00', 'transferencia', 'pagado', 2),
(2, 2, 1, '2024-03-05', 550000.00, 550000.00, NULL, 'efectivo', 'vencido', NULL),
(3, 2, 1, '2024-03-05', 450000.00, 450000.00, '2024-03-10 16:00:00', 'transferencia', 'pagado', 2);

-- =====================================================
-- INSERTAR COMUNICACIONES
-- =====================================================

INSERT INTO comunicaciones (titulo, contenido, tipo_comunicacion, dirigido_a, fecha_publicacion, publicado_por) VALUES
('Inicio de Clases 2024', 'Estimados padres de familia, les informamos que las clases del año académico 2024 iniciarán el próximo 1 de febrero. Los horarios están disponibles en la plataforma virtual.', 'circular', 'padres', '2024-01-20 08:00:00', 1),
('Reunión de Padres de Familia', 'Se convoca a reunión general de padres de familia para el día 15 de marzo a las 7:00 PM en el auditorio principal. Tema: Rendimiento académico primer período.', 'notificacion', 'padres', '2024-03-01 10:00:00', 2),
('Jornada Pedagógica', 'El día 22 de marzo no habrá clases para estudiantes debido a jornada pedagógica del cuerpo docente. Las clases se reanudan normalmente el 23 de marzo.', 'circular', 'todos', '2024-03-15 12:00:00', 3),
('Festival de Ciencias', 'Los invitamos al Festival de Ciencias que se realizará el 5 de abril en las instalaciones del colegio. Exposición de proyectos de estudiantes de secundaria.', 'evento', 'todos', '2024-03-25 14:00:00', 4);

-- =====================================================
-- INSERTAR EVENTOS ESCOLARES
-- =====================================================

INSERT INTO eventos_escolares (nombre, descripcion, tipo_evento, fecha_inicio, fecha_fin, lugar, organizador_id, participantes, estado) VALUES
('Festival de Ciencias 2024', 'Exposición anual de proyectos científicos de los estudiantes', 'academico', '2024-04-05 08:00:00', '2024-04-05 17:00:00', 'Auditorio Principal', 3, 'todos', 'programado'),
('Intercolegiados de Fútbol', 'Torneo deportivo entre colegios de la ciudad', 'deportivo', '2024-04-20 14:00:00', '2024-04-20 18:00:00', 'Cancha de Fútbol', 6, 'estudiantes', 'programado'),
('Día de la Madre', 'Celebración especial para las madres de familia', 'social', '2024-05-10 09:00:00', '2024-05-10 12:00:00', 'Auditorio Principal', 7, 'todos', 'programado'),
('Muestra Cultural', 'Presentación de talentos artísticos estudiantiles', 'cultural', '2024-06-15 18:00:00', '2024-06-15 21:00:00', 'Teatro del Colegio', 7, 'todos', 'programado');

-- =====================================================
-- ACTUALIZAR CONTADORES Y PROMEDIOS
-- =====================================================

-- Actualizar estudiantes inscritos en secciones
UPDATE secciones s 
SET estudiantes_inscritos = (
    SELECT COUNT(*) 
    FROM inscripciones i 
    WHERE i.seccion_id = s.id AND i.estado_inscripcion = 'inscrito'
);

-- Actualizar estudiantes inscritos en cursos
UPDATE cursos c 
SET estudiantes_inscritos = (
    SELECT COUNT(*) 
    FROM matriculas_cursos mc 
    JOIN inscripciones i ON mc.inscripcion_id = i.id
    WHERE mc.curso_id = c.id AND mc.estado_matricula = 'matriculado'
);

-- =====================================================
-- COMENTARIOS FINALES
-- =====================================================

-- Los datos insertados incluyen:
-- ✅ Estructura educativa completa (niveles, grados, materias)
-- ✅ Períodos académicos configurados
-- ✅ Personal docente con especialidades
-- ✅ Estudiantes con padres de familia
-- ✅ Inscripciones y matrículas por período
-- ✅ Cursos con horarios y profesores asignados
-- ✅ Sistema de calificaciones con diferentes tipos
-- ✅ Control de asistencia diaria
-- ✅ Gestión de pagos y conceptos financieros
-- ✅ Comunicaciones y eventos escolares

-- Este conjunto de datos permite:
-- 📊 Reportes académicos completos
-- 📈 Análisis de rendimiento estudiantil
-- 💰 Control financiero detallado
-- 📅 Gestión de horarios y asistencia
-- 👨‍👩‍👧‍👦 Comunicación con padres de familia
-- 🏆 Seguimiento del progreso académico
-- 📋 Administración escolar integral

COMMIT;
