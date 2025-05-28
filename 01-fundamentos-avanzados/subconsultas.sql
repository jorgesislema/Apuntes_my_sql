-- ============================================
-- SUBCONSULTAS EN MYSQL - GUÍA AVANZADA
-- ============================================

-- ==========================================
-- 1. SUBCONSULTAS SIMPLES
-- ==========================================

-- Ejemplo básico: Empleados con salario mayor al promedio
SELECT nombre, salario 
FROM empleados 
WHERE salario > (SELECT AVG(salario) FROM empleados);

-- ==========================================
-- 2. SUBCONSULTAS CORRELACIONADAS
-- ==========================================

-- Empleados con el salario más alto de su departamento
SELECT e1.nombre, e1.departamento, e1.salario
FROM empleados e1
WHERE e1.salario = (
    SELECT MAX(e2.salario) 
    FROM empleados e2 
    WHERE e2.departamento = e1.departamento
);

-- ==========================================
-- 3. SUBCONSULTAS CON EXISTS
-- ==========================================

-- Departamentos que tienen al menos un empleado
SELECT d.nombre
FROM departamentos d
WHERE EXISTS (
    SELECT 1 
    FROM empleados e 
    WHERE e.departamento_id = d.id
);

-- Clientes que han realizado al menos una compra
SELECT c.nombre
FROM clientes c
WHERE EXISTS (
    SELECT 1 
    FROM pedidos p 
    WHERE p.cliente_id = c.id
);

-- ==========================================
-- 4. SUBCONSULTAS CON NOT EXISTS
-- ==========================================

-- Productos que nunca se han vendido
SELECT p.nombre
FROM productos p
WHERE NOT EXISTS (
    SELECT 1 
    FROM detalle_pedidos dp 
    WHERE dp.producto_id = p.id
);

-- ==========================================
-- 5. SUBCONSULTAS CON IN
-- ==========================================

-- Empleados que trabajan en departamentos específicos
SELECT nombre, departamento
FROM empleados
WHERE departamento_id IN (
    SELECT id 
    FROM departamentos 
    WHERE nombre IN ('Ventas', 'Marketing', 'IT')
);

-- ==========================================
-- 6. SUBCONSULTAS CON ANY/ALL
-- ==========================================

-- Productos más caros que CUALQUIER producto de categoría 'Electrónicos'
SELECT nombre, precio
FROM productos
WHERE precio > ANY (
    SELECT precio 
    FROM productos 
    WHERE categoria = 'Electrónicos'
);

-- Productos más caros que TODOS los productos de categoría 'Libros'
SELECT nombre, precio
FROM productos
WHERE precio > ALL (
    SELECT precio 
    FROM productos 
    WHERE categoria = 'Libros'
);

-- ==========================================
-- 7. SUBCONSULTAS EN SELECT (COLUMNAS CALCULADAS)
-- ==========================================

-- Lista de departamentos con conteo de empleados
SELECT 
    d.nombre,
    (SELECT COUNT(*) 
     FROM empleados e 
     WHERE e.departamento_id = d.id) AS total_empleados
FROM departamentos d;

-- ==========================================
-- 8. SUBCONSULTAS MÚLTIPLES ANIDADAS
-- ==========================================

-- Empleados del departamento con mayor número de empleados
SELECT nombre, departamento
FROM empleados
WHERE departamento_id = (
    SELECT departamento_id
    FROM empleados
    GROUP BY departamento_id
    HAVING COUNT(*) = (
        SELECT MAX(contador)
        FROM (
            SELECT COUNT(*) as contador
            FROM empleados
            GROUP BY departamento_id
        ) AS conteos
    )
);

-- ==========================================
-- 9. EJERCICIOS PRÁCTICOS
-- ==========================================

-- Ejercicio 1: Productos con precio mayor al promedio de su categoría
-- Ejercicio 2: Clientes que han gastado más que el promedio
-- Ejercicio 3: Empleados contratados en el mismo año que su jefe
-- Ejercicio 4: Productos que se han vendido más veces que el promedio

-- ==========================================
-- 10. CASOS DE USO AVANZADOS
-- ==========================================

-- Ranking de ventas por vendedor usando subconsultas
SELECT 
    v.nombre,
    v.total_ventas,
    (SELECT COUNT(*) 
     FROM vendedores v2 
     WHERE v2.total_ventas > v.total_ventas) + 1 AS ranking
FROM vendedores v
ORDER BY total_ventas DESC;
