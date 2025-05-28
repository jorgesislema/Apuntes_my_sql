-- ============================================
-- EJERCICIOS JOINS NIVEL 2 - 28 Mayo 2025
-- ============================================

-- ==========================================
-- EJERCICIO 1: ANÁLISIS DE VENTAS CRUZADAS
-- ==========================================

/*
Contexto: Sistema de e-commerce con análisis de productos que se compran juntos
Tablas: clientes, pedidos, detalle_pedidos, productos, categorias
*/

-- 1.1 Productos frecuentemente comprados juntos
-- Encuentra pares de productos que aparecen en el mismo pedido más de 10 veces
SELECT 
    p1.nombre AS producto_1,
    p2.nombre AS producto_2,
    COUNT(*) AS veces_juntos,
    AVG(dp1.precio_unitario + dp2.precio_unitario) AS precio_promedio_conjunto
FROM detalle_pedidos dp1
JOIN detalle_pedidos dp2 ON dp1.pedido_id = dp2.pedido_id AND dp1.producto_id < dp2.producto_id
JOIN productos p1 ON dp1.producto_id = p1.id
JOIN productos p2 ON dp2.producto_id = p2.id
GROUP BY dp1.producto_id, dp2.producto_id, p1.nombre, p2.nombre
HAVING veces_juntos > 10
ORDER BY veces_juntos DESC
LIMIT 20;

-- 1.2 Clientes que compran productos de múltiples categorías
-- Identifica clientes "cross-category" con análisis de diversidad
SELECT 
    c.nombre AS cliente,
    c.email,
    COUNT(DISTINCT cat.id) AS categorias_compradas,
    COUNT(DISTINCT p.id) AS productos_unicos,
    SUM(dp.cantidad * dp.precio_unitario) AS total_gastado,
    GROUP_CONCAT(DISTINCT cat.nombre ORDER BY cat.nombre) AS categorias_lista
FROM clientes c
JOIN pedidos pe ON c.id = pe.cliente_id
JOIN detalle_pedidos dp ON pe.id = dp.pedido_id
JOIN productos p ON dp.producto_id = p.id
JOIN categorias cat ON p.categoria_id = cat.id
WHERE pe.fecha >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY c.id, c.nombre, c.email
HAVING categorias_compradas >= 3
ORDER BY categorias_compradas DESC, total_gastado DESC;

-- ==========================================
-- EJERCICIO 2: ANÁLISIS JERÁRQUICO DE EMPLEADOS
-- ==========================================

/*
Contexto: Sistema de RRHH con estructura organizacional compleja
Tablas: empleados, departamentos, cargos, evaluaciones, proyectos
*/

-- 2.1 Cadena de mando completa con niveles
-- Muestra la jerarquía completa desde CEO hasta empleados base
WITH RECURSIVE jerarquia AS (
    -- Caso base: CEO (sin jefe)
    SELECT 
        id,
        nombre,
        jefe_id,
        cargo_id,
        departamento_id,
        0 AS nivel,
        CAST(nombre AS CHAR(1000)) AS ruta_jerarquica
    FROM empleados 
    WHERE jefe_id IS NULL
    
    UNION ALL
    
    -- Caso recursivo: empleados con jefe
    SELECT 
        e.id,
        e.nombre,
        e.jefe_id,
        e.cargo_id,
        e.departamento_id,
        j.nivel + 1,
        CONCAT(j.ruta_jerarquica, ' > ', e.nombre)
    FROM empleados e
    JOIN jerarquia j ON e.jefe_id = j.id
)
SELECT 
    j.nivel,
    REPEAT('  ', j.nivel) AS indentacion,
    j.nombre AS empleado,
    c.nombre AS cargo,
    d.nombre AS departamento,
    COUNT(subordinados.id) AS num_subordinados_directos,
    j.ruta_jerarquica
FROM jerarquia j
LEFT JOIN empleados subordinados ON j.id = subordinados.jefe_id
JOIN cargos c ON j.cargo_id = c.id
JOIN departamentos d ON j.departamento_id = d.id
GROUP BY j.id, j.nivel, j.nombre, c.nombre, d.nombre, j.ruta_jerarquica
ORDER BY j.nivel, j.nombre;

-- 2.2 Análisis de span of control y eficiencia organizacional
-- Identifica jefes con demasiados o muy pocos subordinados
SELECT 
    jefe.nombre AS jefe,
    jefe_cargo.nombre AS cargo_jefe,
    jefe_dept.nombre AS departamento,
    COUNT(subordinado.id) AS subordinados_directos,
    AVG(eval.calificacion_general) AS promedio_evaluaciones_equipo,
    CASE 
        WHEN COUNT(subordinado.id) > 10 THEN 'Span muy alto'
        WHEN COUNT(subordinado.id) BETWEEN 5 AND 10 THEN 'Span óptimo'
        WHEN COUNT(subordinado.id) BETWEEN 1 AND 4 THEN 'Span bajo'
        ELSE 'Sin subordinados'
    END AS analisis_span
FROM empleados jefe
LEFT JOIN empleados subordinado ON jefe.id = subordinado.jefe_id
LEFT JOIN evaluaciones eval ON subordinado.id = eval.empleado_id 
    AND eval.año = YEAR(CURDATE())
JOIN cargos jefe_cargo ON jefe.cargo_id = jefe_cargo.id
JOIN departamentos jefe_dept ON jefe.departamento_id = jefe_dept.id
WHERE jefe_cargo.nivel_jerarquico >= 3  -- Solo jefes de nivel medio hacia arriba
GROUP BY jefe.id, jefe.nombre, jefe_cargo.nombre, jefe_dept.nombre
ORDER BY COUNT(subordinado.id) DESC;

-- ==========================================
-- EJERCICIO 3: ANÁLISIS TEMPORAL AVANZADO
-- ==========================================

/*
Contexto: Análisis de tendencias y patrones temporales en ventas
Tablas: ventas, productos, clientes, regiones
*/

-- 3.1 Análisis de cohorts de clientes por mes de registro
-- Seguimiento de retención y valor de clientes por cohorte
SELECT 
    cohorte.mes_registro,
    COUNT(DISTINCT cohorte.cliente_id) AS clientes_en_cohorte,
    COUNT(DISTINCT CASE WHEN compras.mes_compra = cohorte.mes_registro THEN cohorte.cliente_id END) AS activos_mes_0,
    COUNT(DISTINCT CASE WHEN compras.mes_compra = DATE_ADD(cohorte.mes_registro, INTERVAL 1 MONTH) THEN cohorte.cliente_id END) AS activos_mes_1,
    COUNT(DISTINCT CASE WHEN compras.mes_compra = DATE_ADD(cohorte.mes_registro, INTERVAL 3 MONTH) THEN cohorte.cliente_id END) AS activos_mes_3,
    COUNT(DISTINCT CASE WHEN compras.mes_compra = DATE_ADD(cohorte.mes_registro, INTERVAL 6 MONTH) THEN cohorte.cliente_id END) AS activos_mes_6,
    COUNT(DISTINCT CASE WHEN compras.mes_compra = DATE_ADD(cohorte.mes_registro, INTERVAL 12 MONTH) THEN cohorte.cliente_id END) AS activos_mes_12
FROM (
    SELECT 
        id AS cliente_id,
        DATE_FORMAT(fecha_registro, '%Y-%m-01') AS mes_registro
    FROM clientes 
    WHERE fecha_registro >= '2024-01-01'
) cohorte
LEFT JOIN (
    SELECT 
        cliente_id,
        DATE_FORMAT(fecha, '%Y-%m-01') AS mes_compra
    FROM pedidos
    WHERE estado = 'entregado'
) compras ON cohorte.cliente_id = compras.cliente_id
GROUP BY cohorte.mes_registro
ORDER BY cohorte.mes_registro;

-- 3.2 Análisis de estacionalidad por categoría de producto
-- Identifica patrones estacionales y picos de demanda
SELECT 
    cat.nombre AS categoria,
    MONTH(p.fecha) AS mes,
    MONTHNAME(DATE(CONCAT('2025-', MONTH(p.fecha), '-01'))) AS nombre_mes,
    COUNT(DISTINCT p.id) AS total_pedidos,
    SUM(dp.cantidad) AS unidades_vendidas,
    SUM(dp.cantidad * dp.precio_unitario) AS ingresos,
    AVG(dp.precio_unitario) AS precio_promedio,
    -- Comparación con promedio anual
    SUM(dp.cantidad * dp.precio_unitario) / 
        (SELECT SUM(dp2.cantidad * dp2.precio_unitario) / 12 
         FROM detalle_pedidos dp2 
         JOIN pedidos p2 ON dp2.pedido_id = p2.id 
         JOIN productos prod2 ON dp2.producto_id = prod2.id 
         WHERE prod2.categoria_id = cat.id 
         AND p2.estado = 'entregado'
         AND YEAR(p2.fecha) = YEAR(p.fecha)) * 100 AS indice_estacionalidad
FROM categorias cat
JOIN productos prod ON cat.id = prod.categoria_id
JOIN detalle_pedidos dp ON prod.id = dp.producto_id
JOIN pedidos p ON dp.pedido_id = p.id
WHERE p.estado = 'entregado'
AND p.fecha >= DATE_SUB(CURDATE(), INTERVAL 2 YEAR)
GROUP BY cat.id, cat.nombre, MONTH(p.fecha)
ORDER BY cat.nombre, mes;

-- ==========================================
-- EJERCICIO 4: ANÁLISIS DE RENDIMIENTO POR REGIÓN
-- ==========================================

/*
Contexto: Análisis geográfico de ventas con métricas de rendimiento
Tablas: clientes, pedidos, ciudades, regiones, vendedores
*/

-- 4.1 Ranking de regiones con métricas completas
-- Análisis integral de rendimiento por región geográfica
SELECT 
    r.nombre AS region,
    COUNT(DISTINCT c.id) AS total_clientes,
    COUNT(DISTINCT CASE WHEN ultima_compra.fecha >= DATE_SUB(CURDATE(), INTERVAL 90 DAY) THEN c.id END) AS clientes_activos_90d,
    COUNT(DISTINCT p.id) AS total_pedidos,
    SUM(p.total) AS ingresos_totales,
    AVG(p.total) AS ticket_promedio,
    COUNT(DISTINCT v.id) AS vendedores_region,
    SUM(p.total) / COUNT(DISTINCT v.id) AS ingresos_por_vendedor,
    -- Métricas de retención
    COUNT(DISTINCT CASE WHEN cliente_stats.total_pedidos > 1 THEN c.id END) AS clientes_recurrentes,
    COUNT(DISTINCT CASE WHEN cliente_stats.total_pedidos > 1 THEN c.id END) * 100.0 / COUNT(DISTINCT c.id) AS tasa_retencion,
    -- Ranking
    RANK() OVER (ORDER BY SUM(p.total) DESC) AS ranking_ingresos,
    RANK() OVER (ORDER BY AVG(p.total) DESC) AS ranking_ticket_promedio
FROM regiones r
JOIN ciudades ci ON r.id = ci.region_id
JOIN clientes c ON ci.id = c.ciudad_id
LEFT JOIN pedidos p ON c.id = p.cliente_id AND p.estado = 'entregado'
LEFT JOIN vendedores v ON r.id = v.region_id
LEFT JOIN (
    SELECT 
        cliente_id,
        MAX(fecha) AS fecha
    FROM pedidos 
    WHERE estado = 'entregado'
    GROUP BY cliente_id
) ultima_compra ON c.id = ultima_compra.cliente_id
LEFT JOIN (
    SELECT 
        cliente_id,
        COUNT(*) AS total_pedidos
    FROM pedidos 
    WHERE estado = 'entregado'
    GROUP BY cliente_id
) cliente_stats ON c.id = cliente_stats.cliente_id
WHERE p.fecha >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY r.id, r.nombre
ORDER BY ingresos_totales DESC;

-- ==========================================
-- EJERCICIO 5: ANÁLISIS DE PRODUCTOS AVANZADO
-- ==========================================

-- 5.1 Análisis ABC de productos con múltiples dimensiones
-- Clasificación de productos por volumen, valor y frecuencia
WITH producto_stats AS (
    SELECT 
        p.id,
        p.nombre,
        p.categoria_id,
        SUM(dp.cantidad) AS total_unidades,
        COUNT(DISTINCT dp.pedido_id) AS pedidos_unicos,
        SUM(dp.cantidad * dp.precio_unitario) AS ingresos_totales,
        AVG(dp.precio_unitario) AS precio_promedio,
        COUNT(DISTINCT pe.cliente_id) AS clientes_unicos
    FROM productos p
    JOIN detalle_pedidos dp ON p.id = dp.producto_id
    JOIN pedidos pe ON dp.pedido_id = pe.id
    WHERE pe.estado = 'entregado'
    AND pe.fecha >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
    GROUP BY p.id, p.nombre, p.categoria_id
),
percentiles AS (
    SELECT 
        PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY ingresos_totales) AS p80_ingresos,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ingresos_totales) AS p50_ingresos,
        PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY total_unidades) AS p80_volumen,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_unidades) AS p50_volumen,
        PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY pedidos_unicos) AS p80_frecuencia,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY pedidos_unicos) AS p50_frecuencia
    FROM producto_stats
)
SELECT 
    ps.nombre AS producto,
    cat.nombre AS categoria,
    ps.total_unidades,
    ps.ingresos_totales,
    ps.pedidos_unicos,
    ps.clientes_unicos,
    ps.precio_promedio,
    -- Clasificación ABC por ingresos
    CASE 
        WHEN ps.ingresos_totales >= p.p80_ingresos THEN 'A'
        WHEN ps.ingresos_totales >= p.p50_ingresos THEN 'B'
        ELSE 'C'
    END AS clase_ingresos,
    -- Clasificación ABC por volumen
    CASE 
        WHEN ps.total_unidades >= p.p80_volumen THEN 'A'
        WHEN ps.total_unidades >= p.p50_volumen THEN 'B'
        ELSE 'C'
    END AS clase_volumen,
    -- Clasificación ABC por frecuencia
    CASE 
        WHEN ps.pedidos_unicos >= p.p80_frecuencia THEN 'A'
        WHEN ps.pedidos_unicos >= p.p50_frecuencia THEN 'B'
        ELSE 'C'
    END AS clase_frecuencia,
    -- Clasificación combinada
    CONCAT(
        CASE WHEN ps.ingresos_totales >= p.p80_ingresos THEN 'A' WHEN ps.ingresos_totales >= p.p50_ingresos THEN 'B' ELSE 'C' END,
        CASE WHEN ps.total_unidades >= p.p80_volumen THEN 'A' WHEN ps.total_unidades >= p.p50_volumen THEN 'B' ELSE 'C' END,
        CASE WHEN ps.pedidos_unicos >= p.p80_frecuencia THEN 'A' WHEN ps.pedidos_unicos >= p.p50_frecuencia THEN 'B' ELSE 'C' END
    ) AS clasificacion_combinada
FROM producto_stats ps
CROSS JOIN percentiles p
JOIN categorias cat ON ps.categoria_id = cat.id
ORDER BY ps.ingresos_totales DESC;

-- ==========================================
-- RETOS ADICIONALES PARA PRÁCTICA
-- ==========================================

/*
RETO 1: Análisis de Churning de Clientes
- Identifica clientes en riesgo de abandonar
- Calcula probabilidad de churn basada en patrones históricos
- Segmenta clientes por nivel de riesgo

RETO 2: Análisis de Rentabilidad por Vendedor
- Compara rendimiento de vendedores considerando:
  * Territorio asignado
  * Experiencia (tiempo en empresa)
  * Tipo de clientes asignados
  * Productos que venden

RETO 3: Optimización de Inventario
- Identifica productos con rotación lenta
- Calcula días de inventario por producto
- Sugiere estrategias de liquidación

RETO 4: Análisis de Satisfacción del Cliente
- Correlaciona reseñas/ratings con patrones de compra
- Identifica productos problemáticos
- Analiza impacto de satisfacción en lealtad

RETO 5: Análisis de Canales de Venta
- Compara rendimiento entre canales (online, tienda física, móvil)
- Analiza journey del cliente cross-channel
- Identifica oportunidades de optimización
*/

-- ==========================================
-- NOTAS PARA EL ESTUDIANTE
-- ==========================================

/*
OBJETIVOS DE APRENDIZAJE:
1. Dominar JOINs complejos con múltiples tablas
2. Usar CTEs recursivos para estructuras jerárquicas
3. Aplicar funciones de ventana para rankings y análisis
4. Combinar agregaciones con análisis temporal
5. Diseñar consultas para KPIs de negocio reales

TÉCNICAS AVANZADAS UTILIZADAS:
- CTEs recursivos para jerarquías
- Window functions para rankings y percentiles
- Self joins para comparaciones
- Múltiples LEFT JOINs con agregaciones
- Análisis de cohortes con fechas
- Clasificación ABC con percentiles

SIGUIENTES PASOS:
1. Ejecutar cada consulta paso a paso
2. Modificar condiciones para explorar diferentes escenarios
3. Crear visualizaciones de los resultados
4. Optimizar consultas usando EXPLAIN
5. Aplicar a tus propios casos de uso
*/
