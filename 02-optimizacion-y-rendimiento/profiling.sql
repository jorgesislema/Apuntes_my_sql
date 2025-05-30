-- ============================================
-- PROFILING EN MYSQL - MEDICIÓN DE RENDIMIENTO
-- ============================================

-- ==========================================
-- 1. CONFIGURACIÓN INICIAL DEL PROFILING
-- ==========================================

-- Verificar si profiling está disponible
SELECT @@have_profiling;

-- Activar profiling para la sesión actual
SET profiling = 1;

-- Verificar estado
SELECT @@profiling;

-- ==========================================
-- 2. PROFILING BÁSICO DE CONSULTAS
-- ==========================================

-- Ejecutar consultas para hacer profiling
SELECT COUNT(*) FROM empleados;

SELECT e.nombre, d.nombre as departamento
FROM empleados e
JOIN departamentos d ON e.departamento_id = d.id
WHERE e.salario > 50000;

SELECT departamento_id, AVG(salario) as promedio
FROM empleados
GROUP BY departamento_id
ORDER BY promedio DESC;

-- Ver las consultas ejecutadas
SHOW PROFILES;

-- Ver detalles de una consulta específica (usar Query_ID de SHOW PROFILES)
SHOW PROFILE FOR QUERY 1;

-- Ver detalles con más información
SHOW PROFILE CPU, MEMORY, BLOCK IO FOR QUERY 2;

-- ==========================================
-- 3. ANÁLISIS DETALLADO DE RENDIMIENTO
-- ==========================================

-- Consulta compleja para análisis detallado
SELECT 
    c.nombre as cliente,
    p.nombre as producto,
    SUM(dv.cantidad) as total_comprado,
    SUM(dv.cantidad * dv.precio_unitario) as total_gastado
FROM clientes c
JOIN ventas v ON c.id = v.cliente_id
JOIN detalle_ventas dv ON v.id = dv.venta_id
JOIN productos p ON dv.producto_id = p.id
WHERE v.fecha >= '2025-01-01'
GROUP BY c.id, p.id
HAVING total_gastado > 1000
ORDER BY total_gastado DESC
LIMIT 50;

-- Analizar el profile de la consulta anterior
SHOW PROFILE ALL FOR QUERY 4;

-- ==========================================
-- 4. IDENTIFICAR CUELLOS DE BOTELLA
-- ==========================================

-- Consulta problemática sin índices
SELECT * FROM ventas v
JOIN clientes c ON v.cliente_id = c.id
WHERE c.nombre LIKE '%García%'
AND YEAR(v.fecha) = 2025;

-- Ver breakdown detallado
SHOW PROFILE CPU, BLOCK IO, MEMORY FOR QUERY 5;

-- Crear índices para mejorar
CREATE INDEX idx_clientes_nombre ON clientes (nombre);
CREATE INDEX idx_ventas_fecha ON ventas (fecha);

-- Ejecutar consulta optimizada
SELECT * FROM ventas v
JOIN clientes c ON v.cliente_id = c.id
WHERE c.nombre LIKE '%García%'
AND v.fecha >= '2025-01-01' 
AND v.fecha < '2026-01-01';

-- Comparar profiles
SHOW PROFILE CPU, BLOCK IO FOR QUERY 6;

-- ==========================================
-- 5. PERFORMANCE SCHEMA (MySQL 5.6+)
-- ==========================================

-- Activar instrumentación específica
UPDATE performance_schema.setup_instruments 
SET ENABLED = 'YES', TIMED = 'YES' 
WHERE NAME LIKE '%statement/%';

UPDATE performance_schema.setup_consumers 
SET ENABLED = 'YES' 
WHERE NAME LIKE '%events_statements_%';

-- Consulta para analizar
SELECT 
    e.nombre,
    e.salario,
    d.nombre as departamento,
    (SELECT COUNT(*) FROM empleado_proyecto ep WHERE ep.empleado_id = e.id) as proyectos
FROM empleados e
LEFT JOIN departamentos d ON e.departamento_id = d.id
WHERE e.salario > (SELECT AVG(salario) FROM empleados)
ORDER BY e.salario DESC;

-- Ver estadísticas de la consulta
SELECT 
    DIGEST_TEXT,
    COUNT_STAR,
    AVG_TIMER_WAIT/1000000000 AS avg_time_seconds,
    MAX_TIMER_WAIT/1000000000 AS max_time_seconds,
    SUM_ROWS_EXAMINED,
    SUM_ROWS_SENT
FROM performance_schema.events_statements_summary_by_digest 
WHERE DIGEST_TEXT LIKE '%empleados%'
ORDER BY AVG_TIMER_WAIT DESC;

-- ==========================================
-- 6. PROFILING DE OPERACIONES DML
-- ==========================================

-- INSERT masivo
START TRANSACTION;

INSERT INTO log_actividades (usuario_id, accion, fecha, detalles)
SELECT 
    id,
    'login',
    NOW() - INTERVAL FLOOR(RAND() * 30) DAY,
    CONCAT('Login desde IP: ', 
           FLOOR(RAND() * 255), '.', 
           FLOOR(RAND() * 255), '.', 
           FLOOR(RAND() * 255), '.', 
           FLOOR(RAND() * 255))
FROM empleados
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) t;

COMMIT;

-- Ver profile del INSERT
SHOW PROFILE FOR QUERY 8;

-- UPDATE masivo
UPDATE empleados 
SET salario = salario * 1.05 
WHERE departamento_id IN (
    SELECT id FROM departamentos 
    WHERE nombre IN ('Ventas', 'Marketing')
);

-- DELETE con subconsulta
DELETE FROM log_actividades 
WHERE fecha < DATE_SUB(NOW(), INTERVAL 90 DAY);

-- Ver profiles de operaciones DML
SHOW PROFILES;

-- ==========================================
-- 7. ANÁLISIS DE MEMORY USAGE
-- ==========================================

-- Consulta que usa mucha memoria
SELECT 
    c1.nombre as cliente1,
    c2.nombre as cliente2,
    COUNT(*) as productos_comunes
FROM ventas v1
JOIN clientes c1 ON v1.cliente_id = c1.id
JOIN detalle_ventas dv1 ON v1.id = dv1.venta_id
JOIN ventas v2 ON dv1.producto_id IN (
    SELECT dv2.producto_id 
    FROM detalle_ventas dv2 
    WHERE dv2.venta_id = v2.id
)
JOIN clientes c2 ON v2.cliente_id = c2.id
WHERE c1.id != c2.id
GROUP BY c1.id, c2.id
HAVING productos_comunes > 5;

-- Análisis de memoria
SHOW PROFILE MEMORY FOR QUERY 10;

-- ==========================================
-- 8. PROFILING DE ÍNDICES
-- ==========================================

-- Desactivar uso de índices para comparación
SELECT SQL_NO_CACHE * FROM empleados IGNORE INDEX (PRIMARY) 
WHERE id = 100;

-- Con índice
SELECT SQL_NO_CACHE * FROM empleados 
WHERE id = 100;

-- Comparar profiles
SHOW PROFILES;
SHOW PROFILE FOR QUERY 11;
SHOW PROFILE FOR QUERY 12;

-- ==========================================
-- 9. PROFILING DE FUNCIONES Y PROCEDIMIENTOS
-- ==========================================

-- Crear función para testing
DELIMITER //
CREATE FUNCTION calcular_bono_complejo(emp_id INT) 
RETURNS DECIMAL(10,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE bono DECIMAL(10,2) DEFAULT 0;
    DECLARE salario DECIMAL(10,2);
    DECLARE antiguedad INT;
    DECLARE performance_score DECIMAL(3,2);
    
    SELECT 
        e.salario,
        TIMESTAMPDIFF(YEAR, e.fecha_contratacion, CURDATE()),
        COALESCE(AVG(ev.calificacion), 3.0)
    INTO salario, antiguedad, performance_score
    FROM empleados e
    LEFT JOIN evaluaciones ev ON e.id = ev.empleado_id
    WHERE e.id = emp_id
    GROUP BY e.id;
    
    SET bono = salario * (antiguedad * 0.01) * performance_score;
    
    RETURN bono;
END//
DELIMITER ;

-- Usar función en consulta
SELECT 
    nombre,
    salario,
    calcular_bono_complejo(id) as bono
FROM empleados 
LIMIT 10;

-- Ver profile
SHOW PROFILE FOR QUERY 13;

-- ==========================================
-- 10. HERRAMIENTAS DE MONITOREO AVANZADO
-- ==========================================

-- Configurar variables para mejor profiling
SET SESSION query_cache_type = OFF;
SET SESSION query_cache_size = 0;

-- Estadísticas de estado del servidor
SHOW STATUS LIKE 'Handler_%';
SHOW STATUS LIKE 'Created_tmp_%';
SHOW STATUS LIKE 'Sort_%';

-- Antes de ejecutar consulta compleja
FLUSH STATUS;

-- Consulta compleja
SELECT 
    d.nombre as departamento,
    COUNT(DISTINCT e.id) as empleados,
    AVG(e.salario) as salario_promedio,
    COUNT(DISTINCT p.id) as proyectos_activos,
    SUM(CASE WHEN ep.estado = 'completado' THEN 1 ELSE 0 END) as proyectos_completados
FROM departamentos d
LEFT JOIN empleados e ON d.id = e.departamento_id
LEFT JOIN empleado_proyecto ep ON e.id = ep.empleado_id
LEFT JOIN proyectos p ON ep.proyecto_id = p.id
WHERE d.activo = 1
AND (p.fecha_fin IS NULL OR p.fecha_fin > CURDATE())
GROUP BY d.id, d.nombre
ORDER BY empleados DESC;

-- Ver estadísticas después
SHOW STATUS LIKE 'Handler_%';
SHOW STATUS LIKE 'Created_tmp_%';
SHOW STATUS LIKE 'Sort_%';

-- ==========================================
-- 11. OPTIMIZACIÓN BASADA EN PROFILING
-- ==========================================

-- Identificar consulta lenta
SELECT 
    v.id,
    v.fecha,
    c.nombre,
    SUM(dv.cantidad * dv.precio_unitario) as total
FROM ventas v
JOIN clientes c ON v.cliente_id = c.id
JOIN detalle_ventas dv ON v.id = dv.venta_id
WHERE v.fecha BETWEEN '2025-01-01' AND '2025-12-31'
AND c.ciudad IN ('Madrid', 'Barcelona', 'Valencia')
GROUP BY v.id, v.fecha, c.nombre
ORDER BY total DESC;

-- Profile inicial
SHOW PROFILE CPU, BLOCK IO FOR QUERY 15;

-- Crear índices optimizados
CREATE INDEX idx_ventas_fecha_cliente ON ventas (fecha, cliente_id);
CREATE INDEX idx_clientes_ciudad ON clientes (ciudad);
CREATE INDEX idx_detalle_venta_total ON detalle_ventas (venta_id, cantidad, precio_unitario);

-- Ejecutar consulta optimizada
SELECT 
    v.id,
    v.fecha,
    c.nombre,
    SUM(dv.cantidad * dv.precio_unitario) as total
FROM ventas v
JOIN clientes c ON v.cliente_id = c.id
JOIN detalle_ventas dv ON v.id = dv.venta_id
WHERE v.fecha >= '2025-01-01' AND v.fecha <= '2025-12-31'
AND c.ciudad IN ('Madrid', 'Barcelona', 'Valencia')
GROUP BY v.id, v.fecha, c.nombre
ORDER BY total DESC;

-- Comparar profiles
SHOW PROFILE CPU, BLOCK IO FOR QUERY 16;

-- ==========================================
-- 12. LIMPIEZA Y MEJORES PRÁCTICAS
-- ==========================================

-- Limpiar profiles antiguos
SET profiling = 0;
SET profiling = 1;

-- Eliminar función de prueba
DROP FUNCTION IF EXISTS calcular_bono_complejo;

-- Ver configuración actual
SHOW VARIABLES LIKE '%profiling%';

-- Desactivar profiling al finalizar
SET profiling = 0;

/*
MEJORES PRÁCTICAS DE PROFILING:

1. Usar en entorno de desarrollo/testing, no en producción
2. Activar solo cuando sea necesario
3. Limpiar profiles regularmente
4. Combinar con EXPLAIN para análisis completo
5. Usar Performance Schema para monitoreo continuo
6. Considerar herramientas externas como pt-query-digest
7. Documentar hallazgos y optimizaciones aplicadas
*/
