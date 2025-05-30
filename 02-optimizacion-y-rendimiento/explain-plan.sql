-- ============================================
-- EXPLAIN PLAN - ANÁLISIS DE CONSULTAS EN MYSQL
-- ============================================

-- ==========================================
-- 1. INTRODUCCIÓN A EXPLAIN
-- ==========================================

-- EXPLAIN básico
EXPLAIN SELECT * FROM empleados WHERE departamento_id = 5;

-- EXPLAIN EXTENDED (MySQL 5.6+)
EXPLAIN EXTENDED SELECT * FROM empleados WHERE salario > 50000;

-- EXPLAIN FORMAT=JSON (MySQL 5.6+)
EXPLAIN FORMAT=JSON 
SELECT e.nombre, d.nombre as departamento
FROM empleados e
JOIN departamentos d ON e.departamento_id = d.id
WHERE e.salario > 60000;

-- ==========================================
-- 2. INTERPRETACIÓN DE COLUMNAS EXPLAIN
-- ==========================================

-- Ejemplo completo con interpretación
EXPLAIN 
SELECT 
    e.nombre,
    e.salario,
    d.nombre as departamento,
    COUNT(p.id) as total_proyectos
FROM empleados e
LEFT JOIN departamentos d ON e.departamento_id = d.id
LEFT JOIN empleado_proyecto ep ON e.id = ep.empleado_id
LEFT JOIN proyectos p ON ep.proyecto_id = p.id
WHERE e.salario BETWEEN 40000 AND 80000
GROUP BY e.id, e.nombre, e.salario, d.nombre
ORDER BY e.salario DESC
LIMIT 10;

/*
Columnas importantes de EXPLAIN:
- id: Identificador de la consulta
- select_type: Tipo de SELECT (SIMPLE, PRIMARY, SUBQUERY, etc.)
- table: Tabla que se está accediendo
- type: Tipo de join/acceso (system, const, eq_ref, ref, range, index, ALL)
- possible_keys: Índices que podrían usarse
- key: Índice realmente usado
- key_len: Longitud del índice usado
- ref: Columnas/constantes usadas para buscar en el índice
- rows: Estimación de filas examinadas
- Extra: Información adicional importante
*/

-- ==========================================
-- 3. TIPOS DE ACCESO (COLUMN: type)
-- ==========================================

-- 1. system/const - Mejor rendimiento
EXPLAIN SELECT * FROM empleados WHERE id = 1;
-- type: const (búsqueda por PRIMARY KEY o UNIQUE con constante)

-- 2. eq_ref - Muy bueno
EXPLAIN 
SELECT e.nombre, d.nombre 
FROM empleados e 
JOIN departamentos d ON e.departamento_id = d.id;
-- type: eq_ref (un registro de la segunda tabla por cada combinación)

-- 3. ref - Bueno
EXPLAIN SELECT * FROM empleados WHERE departamento_id = 5;
-- type: ref (múltiples registros con el mismo valor de índice)

-- 4. range - Aceptable
EXPLAIN SELECT * FROM empleados WHERE salario BETWEEN 40000 AND 60000;
-- type: range (rango de valores en índice)

-- 5. index - Mejor que ALL pero no ideal
EXPLAIN SELECT id FROM empleados ORDER BY id;
-- type: index (escaneo completo del índice)

-- 6. ALL - Peor rendimiento
EXPLAIN SELECT * FROM empleados WHERE UPPER(nombre) = 'JUAN';
-- type: ALL (escaneo completo de la tabla)

-- ==========================================
-- 4. INFORMACIÓN EXTRA IMPORTANTE
-- ==========================================

-- Using index (EXCELENTE)
EXPLAIN SELECT departamento_id FROM empleados WHERE departamento_id > 5;
-- Extra: Using index (consulta resuelta solo con índice)

-- Using where (NORMAL)
EXPLAIN SELECT * FROM empleados WHERE salario > 50000;
-- Extra: Using where (filtrado después de leer filas)

-- Using temporary (COSTOSO)
EXPLAIN 
SELECT departamento_id, COUNT(*) 
FROM empleados 
GROUP BY departamento_id 
ORDER BY COUNT(*) DESC;
-- Extra: Using temporary (tabla temporal para GROUP BY/ORDER BY)

-- Using filesort (COSTOSO)
EXPLAIN SELECT * FROM empleados ORDER BY nombre;
-- Extra: Using filesort (ordenamiento no puede usar índice)

-- Using index condition (BUENO - MySQL 5.6+)
EXPLAIN SELECT * FROM empleados WHERE departamento_id > 5 AND salario > 40000;
-- Extra: Using index condition (filtrado a nivel de índice)

-- ==========================================
-- 5. ANÁLISIS DE SUBCONSULTAS
-- ==========================================

-- Subconsulta simple
EXPLAIN 
SELECT * FROM empleados 
WHERE salario > (SELECT AVG(salario) FROM empleados);

-- Subconsulta correlacionada (COSTOSA)
EXPLAIN 
SELECT e1.nombre, e1.salario
FROM empleados e1
WHERE e1.salario > (
    SELECT AVG(e2.salario) 
    FROM empleados e2 
    WHERE e2.departamento_id = e1.departamento_id
);

-- Subconsulta con EXISTS
EXPLAIN 
SELECT d.nombre
FROM departamentos d
WHERE EXISTS (
    SELECT 1 FROM empleados e 
    WHERE e.departamento_id = d.id
);

-- ==========================================
-- 6. OPTIMIZACIÓN BASADA EN EXPLAIN
-- ==========================================

-- PROBLEMA: Consulta lenta sin índice
EXPLAIN 
SELECT * FROM ventas 
WHERE YEAR(fecha) = 2025 AND cliente_id = 100;
-- Problema: función YEAR() impide uso de índice

-- SOLUCIÓN 1: Reescribir sin función
EXPLAIN 
SELECT * FROM ventas 
WHERE fecha >= '2025-01-01' 
AND fecha < '2026-01-01' 
AND cliente_id = 100;

-- SOLUCIÓN 2: Crear índice compuesto
CREATE INDEX idx_fecha_cliente ON ventas (fecha, cliente_id);

-- PROBLEMA: ORDER BY lento
EXPLAIN 
SELECT * FROM productos 
WHERE categoria_id = 5 
ORDER BY precio DESC;

-- SOLUCIÓN: Índice compuesto para WHERE y ORDER BY
CREATE INDEX idx_categoria_precio ON productos (categoria_id, precio);

-- ==========================================
-- 7. ANÁLISIS DE JOINS COMPLEJOS
-- ==========================================

-- Join múltiple - analizar orden de tablas
EXPLAIN 
SELECT 
    c.nombre as cliente,
    p.nombre as producto,
    v.fecha,
    dv.cantidad
FROM clientes c
JOIN ventas v ON c.id = v.cliente_id
JOIN detalle_ventas dv ON v.id = dv.venta_id
JOIN productos p ON dv.producto_id = p.id
WHERE c.ciudad = 'Madrid'
AND v.fecha >= '2025-01-01';

-- Verificar que los índices están siendo usados
SHOW INDEXES FROM clientes;
SHOW INDEXES FROM ventas;
SHOW INDEXES FROM detalle_ventas;
SHOW INDEXES FROM productos;

-- ==========================================
-- 8. EXPLAIN ANALYZE (MySQL 8.0+)
-- ==========================================

-- EXPLAIN ANALYZE proporciona tiempos reales de ejecución
EXPLAIN ANALYZE
SELECT 
    departamento_id,
    AVG(salario) as salario_promedio
FROM empleados 
WHERE fecha_contratacion >= '2020-01-01'
GROUP BY departamento_id
ORDER BY salario_promedio DESC;

-- ==========================================
-- 9. CASOS PRÁCTICOS DE OPTIMIZACIÓN
-- ==========================================

-- CASO 1: Optimizar consulta de reporte
-- ANTES: Consulta lenta
EXPLAIN 
SELECT 
    YEAR(v.fecha) as año,
    MONTH(v.fecha) as mes,
    COUNT(*) as total_ventas,
    SUM(v.total) as ingresos
FROM ventas v
WHERE v.fecha BETWEEN '2024-01-01' AND '2025-12-31'
GROUP BY YEAR(v.fecha), MONTH(v.fecha)
ORDER BY año, mes;

-- DESPUÉS: Optimizada
-- 1. Crear índice
CREATE INDEX idx_fecha ON ventas (fecha);

-- 2. Verificar mejora
EXPLAIN 
SELECT 
    YEAR(v.fecha) as año,
    MONTH(v.fecha) as mes,
    COUNT(*) as total_ventas,
    SUM(v.total) as ingresos
FROM ventas v
WHERE v.fecha >= '2024-01-01' AND v.fecha <= '2025-12-31'
GROUP BY YEAR(v.fecha), MONTH(v.fecha)
ORDER BY año, mes;

-- CASO 2: Optimizar búsqueda de texto
-- ANTES: Búsqueda lenta
EXPLAIN 
SELECT * FROM productos 
WHERE nombre LIKE '%laptop%' 
OR descripcion LIKE '%laptop%';

-- DESPUÉS: Con índice FULLTEXT
ALTER TABLE productos ADD FULLTEXT(nombre, descripcion);

EXPLAIN 
SELECT * FROM productos 
WHERE MATCH(nombre, descripcion) AGAINST('laptop' IN NATURAL LANGUAGE MODE);

-- ==========================================
-- 10. MONITOREO Y ALERTAS
-- ==========================================

-- Consultas que escanean muchas filas
EXPLAIN 
SELECT SQL_NO_CACHE * FROM empleados 
WHERE CONCAT(nombre, ' ', apellido) LIKE '%Juan García%';

-- Buscar consultas problemáticas en Performance Schema (MySQL 5.6+)
SELECT 
    digest_text,
    count_star,
    avg_timer_wait/1000000000 as avg_time_seconds,
    sum_rows_examined,
    sum_rows_sent
FROM performance_schema.events_statements_summary_by_digest 
WHERE digest_text NOT LIKE '%performance_schema%'
AND digest_text NOT LIKE '%information_schema%'
ORDER BY avg_timer_wait DESC
LIMIT 10;

-- ==========================================
-- 11. HERRAMIENTAS COMPLEMENTARIAS
-- ==========================================

-- Activar slow query log
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 1; -- queries > 1 segundo

-- Verificar estado de queries
SHOW PROCESSLIST;

-- Estadísticas de tablas
ANALYZE TABLE empleados;

-- Optimizar tabla (reorganizar índices)
OPTIMIZE TABLE empleados;

-- ==========================================
-- 12. EJERCICIOS PRÁCTICOS
-- ==========================================

-- Ejercicio 1: Analizar y optimizar esta consulta
EXPLAIN 
SELECT 
    c.nombre,
    COUNT(p.id) as total_pedidos,
    SUM(p.total) as total_gastado
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
WHERE c.fecha_registro >= '2024-01-01'
AND (p.estado = 'completado' OR p.estado IS NULL)
GROUP BY c.id, c.nombre
HAVING total_gastado > 1000
ORDER BY total_gastado DESC;

-- Ejercicio 2: ¿Qué índices crearías para optimizar estas consultas?
-- Consulta A:
SELECT * FROM ventas WHERE cliente_id = ? AND fecha >= ? AND fecha <= ?;

-- Consulta B:
SELECT cliente_id, SUM(total) FROM ventas 
WHERE fecha >= ? GROUP BY cliente_id ORDER BY SUM(total) DESC;

-- Consulta C:
SELECT v.*, c.nombre, p.nombre 
FROM ventas v
JOIN clientes c ON v.cliente_id = c.id
JOIN productos p ON v.producto_id = p.id
WHERE c.ciudad = ? AND p.categoria = ?;
