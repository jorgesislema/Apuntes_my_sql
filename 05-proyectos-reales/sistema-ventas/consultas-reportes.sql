-- =====================================================
-- SISTEMA DE VENTAS AVANZADO - CONSULTAS Y REPORTES
-- =====================================================
-- Descripción: Consultas avanzadas para análisis y reportes del sistema
-- Autor: MySQL Advanced Course
-- Fecha: 2025
-- =====================================================

USE sistema_ventas_avanzado;

-- =====================================================
-- 1. ANÁLISIS DE VENTAS Y RENDIMIENTO
-- =====================================================

-- 1.1 Reporte de ventas mensuales con comparación año anterior
SELECT 
    YEAR(p.fecha_pedido) as año,
    MONTH(p.fecha_pedido) as mes,
    MONTHNAME(p.fecha_pedido) as nombre_mes,
    COUNT(p.id) as total_pedidos,
    SUM(p.total) as ventas_totales,
    AVG(p.total) as ticket_promedio,
    LAG(SUM(p.total)) OVER (ORDER BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido)) as ventas_mes_anterior,
    ROUND(
        (SUM(p.total) - LAG(SUM(p.total)) OVER (ORDER BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido))) / 
        LAG(SUM(p.total)) OVER (ORDER BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido)) * 100, 2
    ) as crecimiento_porcentual
FROM pedidos p
WHERE p.estado IN ('entregado', 'en_transito')
GROUP BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido)
ORDER BY año DESC, mes DESC;

-- 1.2 Top 10 productos más vendidos con análisis de rentabilidad
WITH ventas_productos AS (
    SELECT 
        pr.id,
        pr.nombre,
        pr.sku,
        m.nombre as marca,
        c.nombre as categoria,
        SUM(dp.cantidad) as unidades_vendidas,
        SUM(dp.subtotal_linea) as ingresos_totales,
        AVG(dp.precio_unitario) as precio_promedio,
        pr.precio_compra,
        (AVG(dp.precio_unitario) - pr.precio_compra) as margen_unitario,
        ROUND(((AVG(dp.precio_unitario) - pr.precio_compra) / AVG(dp.precio_unitario)) * 100, 2) as margen_porcentual
    FROM productos pr
    JOIN detalles_pedido dp ON pr.id = dp.producto_id
    JOIN pedidos p ON dp.pedido_id = p.id
    JOIN marcas m ON pr.marca_id = m.id
    JOIN categorias c ON pr.categoria_id = c.id
    WHERE p.estado IN ('entregado', 'en_transito')
    GROUP BY pr.id, pr.nombre, pr.sku, m.nombre, c.nombre, pr.precio_compra
)
SELECT 
    *,
    RANK() OVER (ORDER BY unidades_vendidas DESC) as ranking_unidades,
    RANK() OVER (ORDER BY ingresos_totales DESC) as ranking_ingresos,
    RANK() OVER (ORDER BY margen_porcentual DESC) as ranking_margen
FROM ventas_productos
ORDER BY unidades_vendidas DESC
LIMIT 10;

-- 1.3 Análisis de performance por empleado de ventas
SELECT 
    e.nombre,
    e.apellido,
    e.departamento,
    COUNT(p.id) as pedidos_gestionados,
    SUM(p.total) as ventas_totales,
    AVG(p.total) as ticket_promedio,
    MIN(p.fecha_pedido) as primera_venta,
    MAX(p.fecha_pedido) as ultima_venta,
    ROUND(SUM(p.total) / COUNT(p.id), 2) as eficiencia_por_pedido,
    ROW_NUMBER() OVER (ORDER BY SUM(p.total) DESC) as ranking_ventas,
    CASE 
        WHEN SUM(p.total) > 100000 THEN 'Estrella'
        WHEN SUM(p.total) > 50000 THEN 'Alto'
        WHEN SUM(p.total) > 20000 THEN 'Medio'
        ELSE 'Bajo'
    END as nivel_performance
FROM empleados e
LEFT JOIN pedidos p ON e.id = p.empleado_id 
WHERE e.departamento = 'Ventas' AND e.estado = 'activo'
GROUP BY e.id, e.nombre, e.apellido, e.departamento
ORDER BY ventas_totales DESC;

-- =====================================================
-- 2. ANÁLISIS DE CLIENTES Y SEGMENTACIÓN
-- =====================================================

-- 2.1 Segmentación RFM (Recency, Frequency, Monetary)
WITH rfm_analysis AS (
    SELECT 
        c.id as cliente_id,
        CASE 
            WHEN c.tipo_cliente = 'individual' THEN CONCAT(c.nombre, ' ', c.apellido)
            ELSE c.razon_social
        END as cliente_nombre,
        c.tipo_cliente,
        MAX(p.fecha_pedido) as ultima_compra,
        DATEDIFF(CURDATE(), MAX(p.fecha_pedido)) as dias_desde_ultima_compra,
        COUNT(p.id) as frecuencia_compras,
        SUM(p.total) as valor_monetario,
        AVG(p.total) as ticket_promedio
    FROM clientes c
    LEFT JOIN pedidos p ON c.id = p.cliente_id
    WHERE p.estado IN ('entregado', 'en_transito')
    GROUP BY c.id, cliente_nombre, c.tipo_cliente
),
rfm_scores AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY dias_desde_ultima_compra ASC) as recency_score,
        NTILE(5) OVER (ORDER BY frecuencia_compras DESC) as frequency_score,
        NTILE(5) OVER (ORDER BY valor_monetario DESC) as monetary_score
    FROM rfm_analysis
)
SELECT *,
    CONCAT(recency_score, frequency_score, monetary_score) as rfm_score,
    CASE 
        WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'Champions'
        WHEN recency_score >= 3 AND frequency_score >= 3 AND monetary_score >= 3 THEN 'Loyal Customers'
        WHEN recency_score >= 4 AND frequency_score <= 2 THEN 'New Customers'
        WHEN recency_score <= 2 AND frequency_score >= 3 THEN 'At Risk'
        WHEN recency_score <= 2 AND frequency_score <= 2 THEN 'Cant Lose Them'
        ELSE 'Others'
    END as segmento_cliente
FROM rfm_scores
ORDER BY valor_monetario DESC;

-- 2.2 Análisis de comportamiento de compra por geografía
SELECT 
    pa.nombre as pais,
    r.nombre as region,
    COUNT(DISTINCT c.id) as total_clientes,
    COUNT(p.id) as total_pedidos,
    SUM(p.total) as ventas_totales,
    AVG(p.total) as ticket_promedio,
    SUM(p.total) / COUNT(DISTINCT c.id) as valor_promedio_por_cliente,
    COUNT(p.id) / COUNT(DISTINCT c.id) as frecuencia_compra_promedio
FROM paises pa
JOIN regiones r ON pa.region_id = r.id
LEFT JOIN clientes c ON pa.id = c.pais_id
LEFT JOIN pedidos p ON c.id = p.cliente_id
WHERE p.estado IN ('entregado', 'en_transito')
GROUP BY pa.id, pa.nombre, r.nombre
HAVING COUNT(p.id) > 0
ORDER BY ventas_totales DESC;

-- =====================================================
-- 3. ANÁLISIS DE INVENTARIO Y LOGÍSTICA
-- =====================================================

-- 3.1 Productos con bajo stock y recomendaciones de reposición
WITH analisis_inventario AS (
    SELECT 
        p.id,
        p.nombre,
        p.sku,
        p.stock_actual,
        p.stock_minimo,
        p.stock_actual - p.stock_minimo as diferencia_stock,
        AVG(CASE WHEN m.tipo_movimiento = 'salida' THEN m.cantidad ELSE 0 END) as promedio_ventas_diarias,
        COUNT(CASE WHEN m.tipo_movimiento = 'salida' AND m.fecha_movimiento >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) THEN 1 END) as ventas_ultimo_mes,
        p.stock_actual / NULLIF(AVG(CASE WHEN m.tipo_movimiento = 'salida' THEN m.cantidad ELSE 0 END), 0) as dias_stock_restante
    FROM productos p
    LEFT JOIN movimientos_inventario m ON p.id = m.producto_id
    WHERE p.estado = 'activo'
    GROUP BY p.id, p.nombre, p.sku, p.stock_actual, p.stock_minimo
)
SELECT *,
    CASE 
        WHEN stock_actual <= stock_minimo THEN 'URGENTE'
        WHEN dias_stock_restante <= 7 THEN 'CRITICO'
        WHEN dias_stock_restante <= 15 THEN 'ALERTA'
        ELSE 'NORMAL'
    END as nivel_alerta,
    CASE 
        WHEN promedio_ventas_diarias > 0 THEN CEIL(promedio_ventas_diarias * 30)
        ELSE stock_minimo * 2
    END as cantidad_recomendada_pedido
FROM analisis_inventario
ORDER BY nivel_alerta DESC, dias_stock_restante ASC;

-- 3.2 Análisis de rotación de inventario
SELECT 
    p.nombre,
    cat.nombre as categoria,
    m.nombre as marca,
    SUM(CASE WHEN mi.tipo_movimiento = 'entrada' THEN mi.cantidad ELSE 0 END) as total_entradas,
    SUM(CASE WHEN mi.tipo_movimiento = 'salida' THEN mi.cantidad ELSE 0 END) as total_salidas,
    p.stock_actual,
    ROUND(
        SUM(CASE WHEN mi.tipo_movimiento = 'salida' THEN mi.cantidad ELSE 0 END) / 
        NULLIF(AVG(p.stock_actual), 0), 2
    ) as rotacion_inventario,
    ROUND(
        365 / NULLIF(
            SUM(CASE WHEN mi.tipo_movimiento = 'salida' THEN mi.cantidad ELSE 0 END) / 
            NULLIF(AVG(p.stock_actual), 0), 0
        ), 2
    ) as dias_promedio_inventario
FROM productos p
JOIN categorias cat ON p.categoria_id = cat.id
JOIN marcas m ON p.marca_id = m.id
LEFT JOIN movimientos_inventario mi ON p.id = mi.producto_id
WHERE p.estado = 'activo'
GROUP BY p.id, p.nombre, cat.nombre, m.nombre, p.stock_actual
HAVING total_salidas > 0
ORDER BY rotacion_inventario DESC;

-- =====================================================
-- 4. ANÁLISIS FINANCIERO Y RENTABILIDAD
-- =====================================================

-- 4.1 Análisis de rentabilidad por categoría
SELECT 
    cat.nombre as categoria,
    COUNT(DISTINCT p.id) as productos_activos,
    SUM(dp.cantidad) as unidades_vendidas,
    SUM(dp.subtotal_linea) as ingresos_brutos,
    SUM(dp.cantidad * p.precio_compra) as costo_total,
    SUM(dp.subtotal_linea) - SUM(dp.cantidad * p.precio_compra) as beneficio_bruto,
    ROUND(
        ((SUM(dp.subtotal_linea) - SUM(dp.cantidad * p.precio_compra)) / SUM(dp.subtotal_linea)) * 100, 2
    ) as margen_beneficio_porcentual,
    AVG(dp.precio_unitario) as precio_promedio_venta
FROM categorias cat
JOIN productos p ON cat.id = p.categoria_id
JOIN detalles_pedido dp ON p.id = dp.producto_id
JOIN pedidos ped ON dp.pedido_id = ped.id
WHERE ped.estado IN ('entregado', 'en_transito') AND p.estado = 'activo'
GROUP BY cat.id, cat.nombre
ORDER BY beneficio_bruto DESC;

-- 4.2 Análisis de métodos de pago y tendencias
SELECT 
    metodo_pago,
    COUNT(*) as numero_transacciones,
    SUM(total) as volumen_total,
    AVG(total) as ticket_promedio,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM pedidos WHERE estado IN ('entregado', 'en_transito')), 2) as porcentaje_uso,
    MIN(fecha_pedido) as primera_transaccion,
    MAX(fecha_pedido) as ultima_transaccion
FROM pedidos
WHERE estado IN ('entregado', 'en_transito')
GROUP BY metodo_pago
ORDER BY volumen_total DESC;

-- =====================================================
-- 5. ANÁLISIS DE MARKETING Y CAMPAÑAS
-- =====================================================

-- 5.1 Efectividad de campañas de marketing
SELECT 
    cm.nombre as campana,
    cm.tipo_campana,
    cm.canal,
    cm.presupuesto,
    cm.objetivo,
    COUNT(DISTINCT c.id) as clientes_alcanzados,
    COUNT(p.id) as pedidos_generados,
    SUM(p.total) as ingresos_generados,
    ROUND(SUM(p.total) / cm.presupuesto, 2) as roi_campana,
    ROUND(SUM(p.total) / COUNT(p.id), 2) as valor_promedio_pedido,
    e.nombre as responsable
FROM campanas_marketing cm
LEFT JOIN clientes c ON c.canal_adquisicion = 
    CASE 
        WHEN cm.canal = 'redes_sociales' THEN 'redes_sociales'
        WHEN cm.canal = 'digital' THEN 'publicidad_online'
        WHEN cm.canal = 'email' THEN 'email_marketing'
        ELSE c.canal_adquisicion
    END
LEFT JOIN pedidos p ON c.id = p.cliente_id 
    AND p.fecha_pedido BETWEEN cm.fecha_inicio AND cm.fecha_fin
LEFT JOIN empleados e ON cm.empleado_responsable = e.id
WHERE cm.estado = 'completada'
GROUP BY cm.id, cm.nombre, cm.tipo_campana, cm.canal, cm.presupuesto, cm.objetivo, e.nombre
ORDER BY roi_campana DESC;

-- 5.2 Análisis de interacciones con clientes
SELECT 
    tipo_interaccion,
    canal,
    COUNT(*) as total_interacciones,
    COUNT(CASE WHEN resultado = 'exitoso' THEN 1 END) as interacciones_exitosas,
    COUNT(CASE WHEN resultado = 'resuelto' THEN 1 END) as problemas_resueltos,
    ROUND(
        COUNT(CASE WHEN resultado IN ('exitoso', 'resuelto') THEN 1 END) * 100.0 / COUNT(*), 2
    ) as tasa_exito,
    AVG(CASE WHEN seguimiento_requerido THEN 1 ELSE 0 END) as tasa_seguimiento_requerido
FROM interacciones_clientes
GROUP BY tipo_interaccion, canal
ORDER BY total_interacciones DESC;

-- =====================================================
-- 6. DASHBOARDS Y KPIS EJECUTIVOS
-- =====================================================

-- 6.1 Dashboard ejecutivo - KPIs principales
SELECT 
    'Ventas Totales (Último Mes)' as kpi,
    CONCAT('$', FORMAT(SUM(total), 2)) as valor
FROM pedidos 
WHERE estado IN ('entregado', 'en_transito') 
    AND fecha_pedido >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)

UNION ALL

SELECT 
    'Número de Pedidos (Último Mes)',
    COUNT(*)
FROM pedidos 
WHERE estado IN ('entregado', 'en_transito') 
    AND fecha_pedido >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)

UNION ALL

SELECT 
    'Ticket Promedio (Último Mes)',
    CONCAT('$', FORMAT(AVG(total), 2))
FROM pedidos 
WHERE estado IN ('entregado', 'en_transito') 
    AND fecha_pedido >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)

UNION ALL

SELECT 
    'Clientes Activos (Último Mes)',
    COUNT(DISTINCT cliente_id)
FROM pedidos 
WHERE estado IN ('entregado', 'en_transito') 
    AND fecha_pedido >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)

UNION ALL

SELECT 
    'Productos Bajo Stock Mínimo',
    COUNT(*)
FROM productos 
WHERE stock_actual <= stock_minimo AND estado = 'activo'

UNION ALL

SELECT 
    'Tasa de Conversión (%)',
    ROUND(
        (SELECT COUNT(*) FROM pedidos WHERE estado IN ('entregado', 'en_transito')) * 100.0 / 
        (SELECT COUNT(*) FROM clientes), 2
    );

-- 6.2 Tendencias de crecimiento semanal
SELECT 
    YEAR(fecha_pedido) as año,
    WEEK(fecha_pedido) as semana,
    DATE(DATE_SUB(fecha_pedido, INTERVAL WEEKDAY(fecha_pedido) DAY)) as inicio_semana,
    COUNT(*) as pedidos,
    SUM(total) as ventas,
    COUNT(DISTINCT cliente_id) as clientes_unicos,
    AVG(total) as ticket_promedio,
    LAG(SUM(total)) OVER (ORDER BY YEAR(fecha_pedido), WEEK(fecha_pedido)) as ventas_semana_anterior,
    ROUND(
        (SUM(total) - LAG(SUM(total)) OVER (ORDER BY YEAR(fecha_pedido), WEEK(fecha_pedido))) * 100.0 / 
        NULLIF(LAG(SUM(total)) OVER (ORDER BY YEAR(fecha_pedido), WEEK(fecha_pedido)), 0), 2
    ) as crecimiento_semanal_porcentual
FROM pedidos
WHERE estado IN ('entregado', 'en_transito')
    AND fecha_pedido >= DATE_SUB(CURDATE(), INTERVAL 12 WEEK)
GROUP BY YEAR(fecha_pedido), WEEK(fecha_pedido), inicio_semana
ORDER BY año DESC, semana DESC;

-- =====================================================
-- 7. CONSULTAS PARA ALERTAS Y MONITOREO
-- =====================================================

-- 7.1 Alertas de inventario crítico
SELECT 
    'ALERTA INVENTARIO' as tipo_alerta,
    p.nombre as producto,
    p.sku,
    p.stock_actual,
    p.stock_minimo,
    CONCAT('Stock actual: ', p.stock_actual, ' | Stock mínimo: ', p.stock_minimo) as detalle
FROM productos p
WHERE p.stock_actual <= p.stock_minimo AND p.estado = 'activo'

UNION ALL

-- 7.2 Alertas de pedidos pendientes
SELECT 
    'ALERTA PEDIDOS PENDIENTES' as tipo_alerta,
    CONCAT('Pedido #', p.id) as producto,
    c.email as sku,
    DATEDIFF(CURDATE(), p.fecha_pedido) as stock_actual,
    3 as stock_minimo,
    CONCAT('Pedido pendiente desde hace ', DATEDIFF(CURDATE(), p.fecha_pedido), ' días') as detalle
FROM pedidos p
JOIN clientes c ON p.cliente_id = c.id
WHERE p.estado = 'pendiente' AND DATEDIFF(CURDATE(), p.fecha_pedido) > 3

UNION ALL

-- 7.3 Alertas de seguimientos vencidos
SELECT 
    'ALERTA SEGUIMIENTOS VENCIDOS' as tipo_alerta,
    CONCAT('Cliente: ', COALESCE(CONCAT(c.nombre, ' ', c.apellido), c.razon_social)) as producto,
    ic.descripcion as sku,
    DATEDIFF(CURDATE(), ic.fecha_seguimiento) as stock_actual,
    0 as stock_minimo,
    CONCAT('Seguimiento vencido desde hace ', DATEDIFF(CURDATE(), ic.fecha_seguimiento), ' días') as detalle
FROM interacciones_clientes ic
JOIN clientes c ON ic.cliente_id = c.id
WHERE ic.seguimiento_requerido = TRUE 
    AND ic.fecha_seguimiento < CURDATE()
ORDER BY tipo_alerta, stock_actual DESC;

-- =====================================================
-- COMENTARIOS SOBRE LAS CONSULTAS
-- =====================================================

/*
📊 CONSULTAS INCLUIDAS:

1. ANÁLISIS DE VENTAS:
   - Reporte mensual con comparación YoY
   - Top productos más vendidos con rentabilidad
   - Performance de empleados de ventas

2. ANÁLISIS DE CLIENTES:
   - Segmentación RFM avanzada
   - Comportamiento por geografía
   - Identificación de segmentos de valor

3. ANÁLISIS DE INVENTARIO:
   - Productos con bajo stock
   - Rotación de inventario
   - Recomendaciones de reposición

4. ANÁLISIS FINANCIERO:
   - Rentabilidad por categoría
   - Análisis de métodos de pago
   - Márgenes y beneficios

5. ANÁLISIS DE MARKETING:
   - ROI de campañas
   - Efectividad por canal
   - Análisis de interacciones

6. DASHBOARDS EJECUTIVOS:
   - KPIs principales
   - Tendencias de crecimiento
   - Métricas de performance

7. ALERTAS Y MONITOREO:
   - Inventario crítico
   - Pedidos pendientes
   - Seguimientos vencidos

🔧 CARACTERÍSTICAS TÉCNICAS:
- Window functions para análisis temporales
- CTEs para consultas complejas
- Funciones analíticas avanzadas
- Consultas optimizadas para performance
- Formato de reportes ejecutivos
*/
