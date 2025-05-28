-- ============================================
-- JOINS AVANZADOS EN MYSQL
-- ============================================

-- ==========================================
-- 1. INNER JOIN - REVISIÓN Y CASOS AVANZADOS
-- ==========================================

-- Join básico con múltiples tablas
SELECT 
    e.nombre AS empleado,
    d.nombre AS departamento,
    p.nombre AS proyecto,
    ep.horas_trabajadas
FROM empleados e
INNER JOIN departamentos d ON e.departamento_id = d.id
INNER JOIN empleado_proyecto ep ON e.id = ep.empleado_id
INNER JOIN proyectos p ON ep.proyecto_id = p.id;

-- ==========================================
-- 2. LEFT JOIN - CASOS AVANZADOS
-- ==========================================

-- Todos los clientes con sus pedidos (incluso sin pedidos)
SELECT 
    c.nombre AS cliente,
    COUNT(p.id) AS total_pedidos,
    COALESCE(SUM(p.total), 0) AS total_gastado
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
GROUP BY c.id, c.nombre;

-- Empleados sin proyectos asignados
SELECT 
    e.nombre,
    e.departamento_id
FROM empleados e
LEFT JOIN empleado_proyecto ep ON e.id = ep.empleado_id
WHERE ep.empleado_id IS NULL;

-- ==========================================
-- 3. RIGHT JOIN - USOS ESPECÍFICOS
-- ==========================================

-- Todos los productos con sus ventas (incluso sin ventas)
SELECT 
    p.nombre AS producto,
    COUNT(dv.id) AS veces_vendido,
    COALESCE(SUM(dv.cantidad), 0) AS total_vendido
FROM detalle_ventas dv
RIGHT JOIN productos p ON dv.producto_id = p.id
GROUP BY p.id, p.nombre;

-- ==========================================
-- 4. FULL OUTER JOIN (SIMULADO CON UNION)
-- ==========================================

-- MySQL no tiene FULL OUTER JOIN nativo, se simula con UNION
SELECT 
    e.nombre AS empleado,
    d.nombre AS departamento
FROM empleados e
LEFT JOIN departamentos d ON e.departamento_id = d.id
UNION
SELECT 
    e.nombre AS empleado,
    d.nombre AS departamento
FROM empleados e
RIGHT JOIN departamentos d ON e.departamento_id = d.id;

-- ==========================================
-- 5. CROSS JOIN - PRODUCTOS CARTESIANOS
-- ==========================================

-- Todas las combinaciones posibles de productos y categorías
SELECT 
    p.nombre AS producto,
    c.nombre AS categoria_posible
FROM productos p
CROSS JOIN categorias c
WHERE p.categoria_id != c.id; -- Excluir la categoría actual

-- ==========================================
-- 6. SELF JOIN - JOINS CONSIGO MISMO
-- ==========================================

-- Empleados con sus jefes
SELECT 
    e1.nombre AS empleado,
    e2.nombre AS jefe
FROM empleados e1
LEFT JOIN empleados e2 ON e1.jefe_id = e2.id;

-- Empleados del mismo departamento
SELECT DISTINCT
    e1.nombre AS empleado1,
    e2.nombre AS empleado2,
    d.nombre AS departamento
FROM empleados e1
JOIN empleados e2 ON e1.departamento_id = e2.departamento_id
JOIN departamentos d ON e1.departamento_id = d.id
WHERE e1.id < e2.id; -- Evitar duplicados

-- ==========================================
-- 7. MÚLTIPLES JOINS CON CONDICIONES COMPLEJAS
-- ==========================================

-- Reporte completo de ventas con información detallada
SELECT 
    v.fecha,
    c.nombre AS cliente,
    c.email,
    p.nombre AS producto,
    dv.cantidad,
    dv.precio_unitario,
    (dv.cantidad * dv.precio_unitario) AS subtotal,
    cat.nombre AS categoria,
    ven.nombre AS vendedor
FROM ventas v
JOIN clientes c ON v.cliente_id = c.id
JOIN detalle_ventas dv ON v.id = dv.venta_id
JOIN productos p ON dv.producto_id = p.id
JOIN categorias cat ON p.categoria_id = cat.id
JOIN vendedores ven ON v.vendedor_id = ven.id
WHERE v.fecha BETWEEN '2025-01-01' AND '2025-12-31';

-- ==========================================
-- 8. JOINS CON AGREGACIONES
-- ==========================================

-- Departamentos con estadísticas de empleados
SELECT 
    d.nombre AS departamento,
    COUNT(e.id) AS total_empleados,
    AVG(e.salario) AS salario_promedio,
    MAX(e.salario) AS salario_maximo,
    MIN(e.salario) AS salario_minimo
FROM departamentos d
LEFT JOIN empleados e ON d.id = e.departamento_id
GROUP BY d.id, d.nombre
HAVING COUNT(e.id) > 0;

-- ==========================================
-- 9. JOINS CON SUBCONSULTAS
-- ==========================================

-- Empleados con salario mayor al promedio de su departamento
SELECT 
    e.nombre,
    e.salario,
    d.nombre AS departamento,
    prom.salario_promedio
FROM empleados e
JOIN departamentos d ON e.departamento_id = d.id
JOIN (
    SELECT 
        departamento_id,
        AVG(salario) AS salario_promedio
    FROM empleados
    GROUP BY departamento_id
) prom ON e.departamento_id = prom.departamento_id
WHERE e.salario > prom.salario_promedio;

-- ==========================================
-- 10. CASOS DE USO COMPLEJOS
-- ==========================================

-- Análisis de ventas por región y temporada
SELECT 
    r.nombre AS region,
    QUARTER(v.fecha) AS trimestre,
    COUNT(v.id) AS total_ventas,
    SUM(v.total) AS ingresos_totales,
    AVG(v.total) AS ticket_promedio
FROM ventas v
JOIN clientes c ON v.cliente_id = c.id
JOIN ciudades ci ON c.ciudad_id = ci.id
JOIN regiones r ON ci.region_id = r.id
WHERE YEAR(v.fecha) = 2025
GROUP BY r.id, QUARTER(v.fecha)
ORDER BY r.nombre, trimestre;

-- ==========================================
-- 11. EJERCICIOS PRÁCTICOS
-- ==========================================

-- Ejercicio 1: Productos más vendidos por categoría
-- Ejercicio 2: Empleados sin subordinados directos
-- Ejercicio 3: Clientes que han comprado en todas las categorías
-- Ejercicio 4: Análisis de productividad por empleado y proyecto
