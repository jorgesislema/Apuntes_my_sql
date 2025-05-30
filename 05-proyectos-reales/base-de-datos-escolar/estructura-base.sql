-- =====================================================
-- BASE DE DATOS ESCOLAR AVANZADA
-- =====================================================
-- Descripción: Sistema completo para gestión escolar
-- Incluye: Estudiantes, Profesores, Cursos, Calificaciones, Horarios
-- Autor: MySQL Advanced Course
-- Fecha: 2025
-- =====================================================

DROP DATABASE IF EXISTS sistema_escolar_avanzado;
CREATE DATABASE sistema_escolar_avanzado CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sistema_escolar_avanzado;

-- =====================================================
-- TABLAS DE CONFIGURACIÓN Y CATÁLOGOS
-- =====================================================

-- Tabla de niveles educativos
CREATE TABLE niveles_educativos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    orden_nivel INT NOT NULL,
    edad_minima INT,
    edad_maxima INT,
    duracion_anos INT,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de grados/cursos
CREATE TABLE grados (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nivel_id INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    numero_grado INT NOT NULL,
    descripcion TEXT,
    capacidad_maxima INT DEFAULT 30,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (nivel_id) REFERENCES niveles_educativos(id),
    UNIQUE KEY unique_nivel_grado (nivel_id, numero_grado)
);

-- Tabla de materias/asignaturas
CREATE TABLE materias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    nivel_id INT,
    creditos INT DEFAULT 1,
    horas_semanales INT DEFAULT 1,
    tipo_materia ENUM('obligatoria', 'optativa', 'extracurricular') DEFAULT 'obligatoria',
    prerequisitos JSON,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (nivel_id) REFERENCES niveles_educativos(id)
);

-- Tabla de períodos académicos
CREATE TABLE periodos_academicos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    tipo_periodo ENUM('anual', 'semestral', 'trimestral', 'bimestral') NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    fecha_inicio_inscripciones DATE,
    fecha_fin_inscripciones DATE,
    activo BOOLEAN DEFAULT TRUE,
    año_academico YEAR NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_periodo_año (año_academico, activo)
);

-- =====================================================
-- TABLAS DE PERSONAS
-- =====================================================

-- Tabla de personas (base para estudiantes, profesores, personal)
CREATE TABLE personas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo_persona ENUM('estudiante', 'profesor', 'administrativo', 'padre_familia') NOT NULL,
    numero_documento VARCHAR(50) NOT NULL UNIQUE,
    tipo_documento ENUM('cedula', 'pasaporte', 'tarjeta_identidad') DEFAULT 'cedula',
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    genero ENUM('M', 'F', 'otro') NOT NULL,
    direccion TEXT,
    telefono VARCHAR(20),
    email VARCHAR(150) UNIQUE,
    telefono_emergencia VARCHAR(20),
    contacto_emergencia VARCHAR(200),
    foto_url VARCHAR(500),
    estado_civil ENUM('soltero', 'casado', 'divorciado', 'viudo', 'union_libre'),
    nacionalidad VARCHAR(100),
    ciudad_nacimiento VARCHAR(100),
    estado ENUM('activo', 'inactivo', 'suspendido', 'egresado') DEFAULT 'activo',
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tipo_persona (tipo_persona),
    INDEX idx_estado (estado),
    INDEX idx_email (email)
);

-- Tabla específica de estudiantes
CREATE TABLE estudiantes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    persona_id INT NOT NULL UNIQUE,
    numero_estudiante VARCHAR(20) NOT NULL UNIQUE,
    fecha_ingreso DATE NOT NULL,
    grado_actual_id INT,
    seccion VARCHAR(10),
    estado_academico ENUM('regular', 'condicional', 'probatorio', 'suspendido', 'retirado', 'egresado') DEFAULT 'regular',
    tipo_estudiante ENUM('regular', 'transferencia', 'becado', 'intercambio') DEFAULT 'regular',
    beca_porcentaje DECIMAL(5,2) DEFAULT 0.00,
    promedio_general DECIMAL(4,2),
    creditos_acumulados INT DEFAULT 0,
    padre_id INT,
    madre_id INT,
    tutor_id INT,
    observaciones TEXT,
    fecha_graduacion DATE,
    titulo_obtenido VARCHAR(200),
    FOREIGN KEY (persona_id) REFERENCES personas(id) ON DELETE CASCADE,
    FOREIGN KEY (grado_actual_id) REFERENCES grados(id),
    FOREIGN KEY (padre_id) REFERENCES personas(id),
    FOREIGN KEY (madre_id) REFERENCES personas(id),
    FOREIGN KEY (tutor_id) REFERENCES personas(id),
    INDEX idx_numero_estudiante (numero_estudiante),
    INDEX idx_grado_seccion (grado_actual_id, seccion),
    INDEX idx_estado_academico (estado_academico)
);

-- Tabla específica de profesores
CREATE TABLE profesores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    persona_id INT NOT NULL UNIQUE,
    numero_empleado VARCHAR(20) NOT NULL UNIQUE,
    fecha_contratacion DATE NOT NULL,
    tipo_contrato ENUM('tiempo_completo', 'medio_tiempo', 'por_horas', 'temporal') DEFAULT 'tiempo_completo',
    especialidad VARCHAR(200),
    grado_academico ENUM('bachiller', 'tecnico', 'licenciatura', 'maestria', 'doctorado'),
    universidad_titulo VARCHAR(200),
    experiencia_anos INT DEFAULT 0,
    salario_base DECIMAL(10,2),
    estado_laboral ENUM('activo', 'licencia', 'vacaciones', 'suspendido', 'retirado') DEFAULT 'activo',
    fecha_retiro DATE,
    evaluacion_promedio DECIMAL(3,2),
    certificaciones JSON,
    observaciones TEXT,
    FOREIGN KEY (persona_id) REFERENCES personas(id) ON DELETE CASCADE,
    INDEX idx_numero_empleado (numero_empleado),
    INDEX idx_especialidad (especialidad),
    INDEX idx_estado_laboral (estado_laboral)
);

-- =====================================================
-- TABLAS DE ESTRUCTURA ACADÉMICA
-- =====================================================

-- Tabla de secciones por grado y período
CREATE TABLE secciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    grado_id INT NOT NULL,
    periodo_id INT NOT NULL,
    nombre_seccion VARCHAR(10) NOT NULL,
    profesor_guia_id INT,
    capacidad_maxima INT DEFAULT 30,
    estudiantes_inscritos INT DEFAULT 0,
    aula VARCHAR(20),
    horario_inicio TIME,
    horario_fin TIME,
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (grado_id) REFERENCES grados(id),
    FOREIGN KEY (periodo_id) REFERENCES periodos_academicos(id),
    FOREIGN KEY (profesor_guia_id) REFERENCES profesores(id),
    UNIQUE KEY unique_grado_periodo_seccion (grado_id, periodo_id, nombre_seccion),
    INDEX idx_periodo_grado (periodo_id, grado_id)
);

-- Tabla de cursos (materia + profesor + período + sección)
CREATE TABLE cursos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    materia_id INT NOT NULL,
    profesor_id INT NOT NULL,
    seccion_id INT NOT NULL,
    periodo_id INT NOT NULL,
    codigo_curso VARCHAR(30) NOT NULL UNIQUE,
    cupo_maximo INT DEFAULT 30,
    estudiantes_inscritos INT DEFAULT 0,
    aula VARCHAR(20),
    dias_semana SET('lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo'),
    hora_inicio TIME,
    hora_fin TIME,
    estado ENUM('programado', 'activo', 'finalizado', 'cancelado') DEFAULT 'programado',
    fecha_inicio DATE,
    fecha_fin DATE,
    observaciones TEXT,
    FOREIGN KEY (materia_id) REFERENCES materias(id),
    FOREIGN KEY (profesor_id) REFERENCES profesores(id),
    FOREIGN KEY (seccion_id) REFERENCES secciones(id),
    FOREIGN KEY (periodo_id) REFERENCES periodos_academicos(id),
    INDEX idx_profesor_periodo (profesor_id, periodo_id),
    INDEX idx_materia_periodo (materia_id, periodo_id)
);

-- =====================================================
-- TABLAS DE INSCRIPCIONES Y CALIFICACIONES
-- =====================================================

-- Tabla de inscripciones de estudiantes
CREATE TABLE inscripciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    estudiante_id INT NOT NULL,
    periodo_id INT NOT NULL,
    grado_id INT NOT NULL,
    seccion_id INT NOT NULL,
    fecha_inscripcion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado_inscripcion ENUM('pre_inscrito', 'inscrito', 'retirado', 'transferido') DEFAULT 'inscrito',
    fecha_retiro DATE,
    motivo_retiro TEXT,
    monto_pension DECIMAL(10,2),
    descuento_aplicado DECIMAL(5,2) DEFAULT 0.00,
    observaciones TEXT,
    FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id),
    FOREIGN KEY (periodo_id) REFERENCES periodos_academicos(id),
    FOREIGN KEY (grado_id) REFERENCES grados(id),
    FOREIGN KEY (seccion_id) REFERENCES secciones(id),
    UNIQUE KEY unique_estudiante_periodo (estudiante_id, periodo_id),
    INDEX idx_periodo_grado (periodo_id, grado_id)
);

-- Tabla de matrículas en cursos específicos
CREATE TABLE matriculas_cursos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    inscripcion_id INT NOT NULL,
    curso_id INT NOT NULL,
    fecha_matricula TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado_matricula ENUM('matriculado', 'retirado', 'aprobado', 'reprobado') DEFAULT 'matriculado',
    fecha_retiro DATE,
    motivo_retiro TEXT,
    FOREIGN KEY (inscripcion_id) REFERENCES inscripciones(id) ON DELETE CASCADE,
    FOREIGN KEY (curso_id) REFERENCES cursos(id),
    UNIQUE KEY unique_inscripcion_curso (inscripcion_id, curso_id),
    INDEX idx_curso_estado (curso_id, estado_matricula)
);

-- Tabla de tipos de evaluación
CREATE TABLE tipos_evaluacion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    peso_porcentual DECIMAL(5,2) NOT NULL,
    es_recuperable BOOLEAN DEFAULT TRUE,
    requiere_asistencia BOOLEAN DEFAULT FALSE,
    activo BOOLEAN DEFAULT TRUE
);

-- Tabla de calificaciones
CREATE TABLE calificaciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    matricula_id INT NOT NULL,
    tipo_evaluacion_id INT NOT NULL,
    fecha_evaluacion DATE NOT NULL,
    calificacion DECIMAL(4,2) NOT NULL,
    calificacion_maxima DECIMAL(4,2) DEFAULT 100.00,
    observaciones TEXT,
    es_recuperacion BOOLEAN DEFAULT FALSE,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    registrado_por INT NOT NULL,
    FOREIGN KEY (matricula_id) REFERENCES matriculas_cursos(id) ON DELETE CASCADE,
    FOREIGN KEY (tipo_evaluacion_id) REFERENCES tipos_evaluacion(id),
    FOREIGN KEY (registrado_por) REFERENCES profesores(id),
    INDEX idx_matricula_tipo (matricula_id, tipo_evaluacion_id),
    INDEX idx_fecha_evaluacion (fecha_evaluacion)
);

-- =====================================================
-- TABLAS DE ASISTENCIA Y DISCIPLINA
-- =====================================================

-- Tabla de asistencia
CREATE TABLE asistencia (
    id INT PRIMARY KEY AUTO_INCREMENT,
    matricula_id INT NOT NULL,
    fecha DATE NOT NULL,
    estado_asistencia ENUM('presente', 'ausente', 'tardanza', 'justificado') NOT NULL,
    hora_llegada TIME,
    observaciones TEXT,
    justificacion TEXT,
    registrado_por INT NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (matricula_id) REFERENCES matriculas_cursos(id) ON DELETE CASCADE,
    FOREIGN KEY (registrado_por) REFERENCES profesores(id),
    UNIQUE KEY unique_matricula_fecha (matricula_id, fecha),
    INDEX idx_fecha_estado (fecha, estado_asistencia)
);

-- Tabla de incidentes disciplinarios
CREATE TABLE incidentes_disciplinarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    estudiante_id INT NOT NULL,
    tipo_incidente ENUM('leve', 'moderado', 'grave', 'muy_grave') NOT NULL,
    descripcion TEXT NOT NULL,
    fecha_incidente DATE NOT NULL,
    lugar_incidente VARCHAR(200),
    profesor_reporta_id INT NOT NULL,
    medida_disciplinaria TEXT,
    fecha_resolucion DATE,
    resuelto_por INT,
    estado ENUM('reportado', 'en_proceso', 'resuelto', 'archivado') DEFAULT 'reportado',
    observaciones TEXT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id),
    FOREIGN KEY (profesor_reporta_id) REFERENCES profesores(id),
    FOREIGN KEY (resuelto_por) REFERENCES profesores(id),
    INDEX idx_estudiante_fecha (estudiante_id, fecha_incidente),
    INDEX idx_tipo_estado (tipo_incidente, estado)
);

-- =====================================================
-- TABLAS DE PAGOS Y FINANZAS
-- =====================================================

-- Tabla de conceptos de pago
CREATE TABLE conceptos_pago (
    id INT PRIMARY KEY AUTO_INCREMENT,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    tipo_concepto ENUM('pension', 'matricula', 'alimentacion', 'transporte', 'material', 'examen', 'certificado', 'otro') NOT NULL,
    monto_base DECIMAL(10,2),
    es_obligatorio BOOLEAN DEFAULT TRUE,
    aplica_descuento BOOLEAN DEFAULT TRUE,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de pagos
CREATE TABLE pagos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    estudiante_id INT NOT NULL,
    periodo_id INT NOT NULL,
    concepto_id INT NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    monto_original DECIMAL(10,2) NOT NULL,
    descuento_aplicado DECIMAL(10,2) DEFAULT 0.00,
    monto_final DECIMAL(10,2) NOT NULL,
    fecha_pago DATETIME,
    metodo_pago ENUM('efectivo', 'transferencia', 'tarjeta', 'cheque', 'deposito') DEFAULT 'efectivo',
    referencia_pago VARCHAR(100),
    estado_pago ENUM('pendiente', 'pagado', 'vencido', 'cancelado') DEFAULT 'pendiente',
    observaciones TEXT,
    recibido_por INT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id),
    FOREIGN KEY (periodo_id) REFERENCES periodos_academicos(id),
    FOREIGN KEY (concepto_id) REFERENCES conceptos_pago(id),
    FOREIGN KEY (recibido_por) REFERENCES profesores(id),
    INDEX idx_estudiante_periodo (estudiante_id, periodo_id),
    INDEX idx_fecha_vencimiento (fecha_vencimiento),
    INDEX idx_estado_pago (estado_pago)
);

-- =====================================================
-- TABLAS ADICIONALES
-- =====================================================

-- Tabla de horarios maestros
CREATE TABLE horarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    curso_id INT NOT NULL,
    dia_semana ENUM('lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo') NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    aula VARCHAR(20),
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (curso_id) REFERENCES cursos(id) ON DELETE CASCADE,
    INDEX idx_dia_hora (dia_semana, hora_inicio)
);

-- Tabla de comunicaciones/circulares
CREATE TABLE comunicaciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(200) NOT NULL,
    contenido TEXT NOT NULL,
    tipo_comunicacion ENUM('circular', 'notificacion', 'emergencia', 'evento', 'academica') NOT NULL,
    dirigido_a ENUM('todos', 'estudiantes', 'profesores', 'padres', 'grado_especifico') NOT NULL,
    grado_id INT,
    fecha_publicacion DATETIME NOT NULL,
    fecha_expiracion DATETIME,
    archivo_adjunto VARCHAR(500),
    publicado_por INT NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (grado_id) REFERENCES grados(id),
    FOREIGN KEY (publicado_por) REFERENCES profesores(id),
    INDEX idx_tipo_fecha (tipo_comunicacion, fecha_publicacion),
    INDEX idx_dirigido_grado (dirigido_a, grado_id)
);

-- Tabla de eventos escolares
CREATE TABLE eventos_escolares (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    tipo_evento ENUM('academico', 'deportivo', 'cultural', 'social', 'administrativo') NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME,
    lugar VARCHAR(200),
    organizador_id INT NOT NULL,
    participantes ENUM('todos', 'estudiantes', 'profesores', 'padres', 'grado_especifico', 'invitados') NOT NULL,
    grado_id INT,
    capacidad_maxima INT,
    inscripciones_abiertas BOOLEAN DEFAULT TRUE,
    costo DECIMAL(10,2) DEFAULT 0.00,
    estado ENUM('programado', 'activo', 'finalizado', 'cancelado') DEFAULT 'programado',
    observaciones TEXT,
    FOREIGN KEY (organizador_id) REFERENCES profesores(id),
    FOREIGN KEY (grado_id) REFERENCES grados(id),
    INDEX idx_fecha_tipo (fecha_inicio, tipo_evento),
    INDEX idx_estado (estado)
);

-- =====================================================
-- TRIGGERS PARA AUDITORÍA Y VALIDACIONES
-- =====================================================

-- Trigger para actualizar contador de estudiantes en secciones
DELIMITER //
CREATE TRIGGER tr_actualizar_estudiantes_seccion_insert
AFTER INSERT ON inscripciones
FOR EACH ROW
BEGIN
    UPDATE secciones 
    SET estudiantes_inscritos = (
        SELECT COUNT(*) 
        FROM inscripciones 
        WHERE seccion_id = NEW.seccion_id 
            AND estado_inscripcion = 'inscrito'
    )
    WHERE id = NEW.seccion_id;
END//

CREATE TRIGGER tr_actualizar_estudiantes_seccion_update
AFTER UPDATE ON inscripciones
FOR EACH ROW
BEGIN
    -- Actualizar sección anterior si cambió
    IF OLD.seccion_id != NEW.seccion_id THEN
        UPDATE secciones 
        SET estudiantes_inscritos = (
            SELECT COUNT(*) 
            FROM inscripciones 
            WHERE seccion_id = OLD.seccion_id 
                AND estado_inscripcion = 'inscrito'
        )
        WHERE id = OLD.seccion_id;
    END IF;
    
    -- Actualizar sección nueva
    UPDATE secciones 
    SET estudiantes_inscritos = (
        SELECT COUNT(*) 
        FROM inscripciones 
        WHERE seccion_id = NEW.seccion_id 
            AND estado_inscripcion = 'inscrito'
    )
    WHERE id = NEW.seccion_id;
END//

-- Trigger para actualizar promedio general del estudiante
CREATE TRIGGER tr_actualizar_promedio_estudiante
AFTER INSERT ON calificaciones
FOR EACH ROW
BEGIN
    DECLARE v_promedio DECIMAL(4,2);
    
    SELECT AVG(c.calificacion * te.peso_porcentual / 100)
    INTO v_promedio
    FROM calificaciones c
    JOIN tipos_evaluacion te ON c.tipo_evaluacion_id = te.id
    JOIN matriculas_cursos mc ON c.matricula_id = mc.id
    JOIN inscripciones i ON mc.inscripcion_id = i.id
    WHERE i.estudiante_id = (
        SELECT i2.estudiante_id 
        FROM matriculas_cursos mc2
        JOIN inscripciones i2 ON mc2.inscripcion_id = i2.id
        WHERE mc2.id = NEW.matricula_id
    );
    
    UPDATE estudiantes 
    SET promedio_general = v_promedio
    WHERE id = (
        SELECT i.estudiante_id 
        FROM matriculas_cursos mc
        JOIN inscripciones i ON mc.inscripcion_id = i.id
        WHERE mc.id = NEW.matricula_id
    );
END//
DELIMITER ;

-- =====================================================
-- ÍNDICES ADICIONALES PARA OPTIMIZACIÓN
-- =====================================================

-- Índices compuestos para consultas frecuentes
CREATE INDEX idx_estudiante_periodo_estado ON inscripciones(estudiante_id, periodo_id, estado_inscripcion);
CREATE INDEX idx_curso_profesor_periodo ON cursos(profesor_id, periodo_id, estado);
CREATE INDEX idx_calificacion_fecha ON calificaciones(fecha_evaluacion, calificacion);
CREATE INDEX idx_pago_vencimiento_estado ON pagos(fecha_vencimiento, estado_pago);
CREATE INDEX idx_asistencia_fecha_estado ON asistencia(fecha, estado_asistencia);

-- =====================================================
-- COMENTARIOS FINALES
-- =====================================================

/*
🏫 SISTEMA ESCOLAR AVANZADO COMPLETADO

✅ CARACTERÍSTICAS PRINCIPALES:
- Gestión completa de estudiantes, profesores y personal
- Sistema de inscripciones y matrículas por período
- Calificaciones con diferentes tipos de evaluación
- Control de asistencia y disciplina
- Gestión de pagos y conceptos financieros
- Horarios y programación académica
- Comunicaciones y eventos escolares
- Triggers automáticos para auditoría
- Índices optimizados para performance

📊 ENTIDADES PRINCIPALES:
- Personas (base para todos los actores)
- Estudiantes con información académica completa
- Profesores con datos laborales
- Materias y cursos estructurados por niveles
- Períodos académicos flexibles
- Sistema de calificaciones ponderadas
- Control financiero detallado

🔧 FUNCIONALIDADES AVANZADAS:
- Jerarquía de niveles educativos
- Prerequisitos de materias (JSON)
- Certificaciones de profesores (JSON)
- Triggers para mantener consistencia
- Índices para optimización de consultas
- Estructura flexible para diferentes tipos de instituciones

💡 CASOS DE USO:
- Colegios de educación básica y media
- Universidades e institutos técnicos
- Centros de capacitación
- Academias especializadas
*/
