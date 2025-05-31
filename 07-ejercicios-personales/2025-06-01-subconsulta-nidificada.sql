-- ============================================
-- SUBCONSULTAS ANIDIFICADAS NIVEL AVANZADO - 1 Junio 2025
-- ============================================

-- ==========================================
-- EJERCICIO 1: SUBCONSULTAS MULTIDIMENSIONALES
-- ==========================================

/*
Contexto: Sistema de análisis de rendimiento empresarial
Objetivo: Dominar subconsultas complejas con múltiples niveles de anidación
*/

-- 1.1 Empleados top performers en departamentos de alto rendimiento
-- Encuentra empleados cuyo salario está en el top 20% de departamentos
-- que están en el top 30% de productividad empresarial
SELECT 
    e.nombre AS empleado,
    e.salario,
    d.nombre AS departamento,
    dept_stats.salario_promedio_dept,
    dept_stats.ranking_departamento,
    emp_percentil.percentil_empleado
FROM empleados e
JOIN departamentos d ON e.departamento_id = d.id
JOIN (
    -- Subconsulta nivel 2: Estadísticas y ranking de departamentos
    SELECT 
        dept_id,
        salario_promedio_dept,
        total_empleados_dept,
        productividad_score,
        ranking_departamento
    FROM (
        -- Subconsulta nivel 3: Cálculo de productividad por departamento
        SELECT 
            d.id AS dept_id,
            AVG(e.salario) AS salario_promedio_dept,
            COUNT(e.id) AS total_empleados_dept,
            -- Score de productividad basado en proyectos completados vs empleados
            (
                SELECT COUNT(p.id) * 1.0 / COUNT(DISTINCT ep.empleado_id)
                FROM proyectos p
                JOIN empleado_proyecto ep ON p.id = ep.proyecto_id
                JOIN empleados e2 ON ep.empleado_id = e2.id
                WHERE e2.departamento_id = d.id
                AND p.estado = 'completado'
                AND p.fecha_fin >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
            ) AS productividad_score,
            RANK() OVER (
                ORDER BY (
                    SELECT COUNT(p.id) * 1.0 / COUNT(DISTINCT ep.empleado_id)
                    FROM proyectos p
                    JOIN empleado_proyecto ep ON p.id = ep.proyecto_id
                    JOIN empleados e3 ON ep.empleado_id = e3.id
                    WHERE e3.departamento_id = d.id
                    AND p.estado = 'completado'
                    AND p.fecha_fin >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
                ) DESC
            ) AS ranking_departamento
        FROM departamentos d
        JOIN empleados e ON d.id = e.departamento_id
        GROUP BY d.id
        HAVING COUNT(e.id) >= 5  -- Solo departamentos con al menos 5 empleados
    ) ranked_depts
    WHERE ranking_departamento <= (
        SELECT COUNT(*) * 0.3  -- Top 30% de departamentos
        FROM (
            SELECT DISTINCT d2.id
            FROM departamentos d2
            JOIN empleados e2 ON d2.id = e2.departamento_id
            GROUP BY d2.id
            HAVING COUNT(e2.id) >= 5
        ) all_qualifying_depts
    )
) dept_stats ON e.departamento_id = dept_stats.dept_id
JOIN (
    -- Subconsulta para calcular percentil del empleado dentro de su departamento
    SELECT 
        emp_id,
        PERCENT_RANK() OVER (
            PARTITION BY departamento_id 
            ORDER BY salario
        ) AS percentil_empleado
    FROM (
        SELECT id AS emp_id, departamento_id, salario
        FROM empleados
    ) emp_data
) emp_percentil ON e.id = emp_percentil.emp_id
WHERE emp_percentil.percentil_empleado >= 0.8  -- Top 20% dentro del departamento
ORDER BY dept_stats.ranking_departamento, emp_percentil.percentil_empleado DESC;

-- ==========================================
-- EJERCICIO 2: ANÁLISIS TEMPORAL CON SUBCONSULTAS CORRELACIONADAS
-- ==========================================

-- 2.1 Productos con crecimiento sostenido en ventas
-- Identifica productos cuyas ventas han crecido en cada uno de los últimos 6 meses
-- comparado con el mes anterior
SELECT 
    p.nombre AS producto,
    p.categoria_id,
    current_month.ventas_mes_actual,
    growth_metrics.meses_consecutivos_crecimiento,
    growth_metrics.crecimiento_promedio_mensual,
    growth_metrics.aceleracion_ventas
FROM productos p
JOIN (
    -- Ventas del mes actual
    SELECT 
        producto_id,
        SUM(dp.cantidad * dp.precio_unitario) AS ventas_mes_actual
    FROM detalle_pedidos dp
    JOIN pedidos pe ON dp.pedido_id = pe.id
    WHERE pe.estado = 'entregado'
    AND YEAR(pe.fecha) = YEAR(CURDATE())
    AND MONTH(pe.fecha) = MONTH(CURDATE())
    GROUP BY producto_id
) current_month ON p.id = current_month.producto_id
JOIN (
    -- Análisis de crecimiento sostenido
    SELECT 
        producto_id,
        COUNT(*) AS meses_consecutivos_crecimiento,
        AVG(crecimiento_porcentual) AS crecimiento_promedio_mensual,
        (MAX(ventas_mes) - MIN(ventas_mes)) / MIN(ventas_mes) * 100 AS aceleracion_ventas
    FROM (
        SELECT 
            dp.producto_id,
            YEAR(pe.fecha) AS año,
            MONTH(pe.fecha) AS mes,
            SUM(dp.cantidad * dp.precio_unitario) AS ventas_mes,
            LAG(SUM(dp.cantidad * dp.precio_unitario)) OVER (
                PARTITION BY dp.producto_id 
                ORDER BY YEAR(pe.fecha), MONTH(pe.fecha)
            ) AS ventas_mes_anterior,
            CASE 
                WHEN LAG(SUM(dp.cantidad * dp.precio_unitario)) OVER (
                    PARTITION BY dp.producto_id 
                    ORDER BY YEAR(pe.fecha), MONTH(pe.fecha)
                ) > 0 THEN
                    (SUM(dp.cantidad * dp.precio_unitario) - LAG(SUM(dp.cantidad * dp.precio_unitario)) OVER (
                        PARTITION BY dp.producto_id 
                        ORDER BY YEAR(pe.fecha), MONTH(pe.fecha)
                    )) * 100.0 / LAG(SUM(dp.cantidad * dp.precio_unitario)) OVER (
                        PARTITION BY dp.producto_id 
                        ORDER BY YEAR(pe.fecha), MONTH(pe.fecha)
                    )
                ELSE NULL
            END AS crecimiento_porcentual
        FROM detalle_pedidos dp
        JOIN pedidos pe ON dp.pedido_id = pe.id
        WHERE pe.estado = 'entregado'
        AND pe.fecha >= DATE_SUB(DATE_FORMAT(CURDATE(), '%Y-%m-01'), INTERVAL 6 MONTH)
        GROUP BY dp.producto_id, YEAR(pe.fecha), MONTH(pe.fecha)
    ) monthly_sales
    WHERE crecimiento_porcentual > 0  -- Solo meses con crecimiento
    AND mes >= MONTH(DATE_SUB(CURDATE(), INTERVAL 5 MONTH))  -- Últimos 6 meses
    GROUP BY producto_id
    HAVING meses_consecutivos_crecimiento >= 4  -- Al menos 4 meses de crecimiento consecutivo
) growth_metrics ON p.id = growth_metrics.producto_id
WHERE EXISTS (
    -- Verificar que el producto tiene historial suficiente
    SELECT 1
    FROM detalle_pedidos dp2
    JOIN pedidos pe2 ON dp2.pedido_id = pe2.id
    WHERE dp2.producto_id = p.id
    AND pe2.estado = 'entregado'
    AND pe2.fecha >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
    GROUP BY YEAR(pe2.fecha), MONTH(pe2.fecha)
    HAVING COUNT(DISTINCT YEAR(pe2.fecha) * 100 + MONTH(pe2.fecha)) >= 8
)
ORDER BY growth_metrics.crecimiento_promedio_mensual DESC;

-- ==========================================
-- EJERCICIO 3: SUBCONSULTAS CON ANÁLISIS DE SEGMENTACIÓN
-- ==========================================

-- 3.1 Clientes de alto valor con comportamiento atípico
-- Encuentra clientes VIP cuyo comportamiento de compra ha cambiado significativamente
SELECT 
    c.nombre AS cliente,
    c.email,
    vip_status.categoria_cliente,
    vip_status.valor_historico_total,
    recent_behavior.compras_recientes_90d,
    recent_behavior.gasto_reciente_90d,
    historical_avg.compras_promedio_90d_historico,
    historical_avg.gasto_promedio_90d_historico,
    -- Indicadores de cambio de comportamiento
    CASE 
        WHEN recent_behavior.compras_recientes_90d < historical_avg.compras_promedio_90d_historico * 0.5 
        THEN 'Disminución crítica en frecuencia'
        WHEN recent_behavior.gasto_reciente_90d < historical_avg.gasto_promedio_90d_historico * 0.6
        THEN 'Disminución significativa en gasto'
        WHEN recent_behavior.compras_recientes_90d > historical_avg.compras_promedio_90d_historico * 1.5
        THEN 'Aumento notable en frecuencia'
        ELSE 'Comportamiento estable'
    END AS analisis_comportamiento,
    -- Score de riesgo de churn
    CASE 
        WHEN DATEDIFF(CURDATE(), recent_behavior.ultima_compra) > 60 
        AND recent_behavior.gasto_reciente_90d < historical_avg.gasto_promedio_90d_historico * 0.7
        THEN 'Alto riesgo'
        WHEN recent_behavior.compras_recientes_90d < historical_avg.compras_promedio_90d_historico * 0.8
        THEN 'Riesgo medio'
        ELSE 'Bajo riesgo'
    END AS riesgo_churn
FROM clientes c
JOIN (
    -- Clasificación VIP basada en valor histórico total
    SELECT 
        cliente_id,
        total_gastado,
        total_pedidos,
        CASE 
            WHEN total_gastado >= (
                SELECT PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY cliente_totals.total_gastado)
                FROM (
                    SELECT cliente_id, SUM(total) AS total_gastado
                    FROM pedidos 
                    WHERE estado = 'entregado'
                    GROUP BY cliente_id
                ) cliente_totals
            ) THEN 'VIP Platino'
            WHEN total_gastado >= (
                SELECT PERCENTILE_CONT(0.85) WITHIN GROUP (ORDER BY cliente_totals.total_gastado)
                FROM (
                    SELECT cliente_id, SUM(total) AS total_gastado
                    FROM pedidos 
                    WHERE estado = 'entregado'
                    GROUP BY cliente_id
                ) cliente_totals
            ) THEN 'VIP Oro'
            WHEN total_gastado >= (
                SELECT PERCENTILE_CONT(0.70) WITHIN GROUP (ORDER BY cliente_totals.total_gastado)
                FROM (
                    SELECT cliente_id, SUM(total) AS total_gastado
                    FROM pedidos 
                    WHERE estado = 'entregado'
                    GROUP BY cliente_id
                ) cliente_totals
            ) THEN 'VIP Plata'
            ELSE 'Regular'
        END AS categoria_cliente,
        total_gastado AS valor_historico_total
    FROM (
        SELECT 
            cliente_id,
            SUM(total) AS total_gastado,
            COUNT(*) AS total_pedidos
        FROM pedidos
        WHERE estado = 'entregado'
        GROUP BY cliente_id
    ) client_totals
) vip_status ON c.id = vip_status.cliente_id
JOIN (
    -- Comportamiento reciente (últimos 90 días)
    SELECT 
        cliente_id,
        COUNT(*) AS compras_recientes_90d,
        COALESCE(SUM(total), 0) AS gasto_reciente_90d,
        MAX(fecha) AS ultima_compra
    FROM pedidos
    WHERE estado = 'entregado'
    AND fecha >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
    GROUP BY cliente_id
) recent_behavior ON c.id = recent_behavior.cliente_id
JOIN (
    -- Promedio histórico de comportamiento por períodos de 90 días
    SELECT 
        cliente_id,
        AVG(compras_periodo) AS compras_promedio_90d_historico,
        AVG(gasto_periodo) AS gasto_promedio_90d_historico
    FROM (
        SELECT 
            cliente_id,
            periodo,
            COUNT(*) AS compras_periodo,
            SUM(total) AS gasto_periodo
        FROM (
            SELECT 
                cliente_id,
                total,
                -- Agrupar en períodos de 90 días
                FLOOR(DATEDIFF(fecha, (
                    SELECT MIN(fecha) 
                    FROM pedidos p2 
                    WHERE p2.cliente_id = pedidos.cliente_id
                )) / 90) AS periodo
            FROM pedidos
            WHERE estado = 'entregado'
            AND fecha < DATE_SUB(CURDATE(), INTERVAL 90 DAY)  -- Excluir período actual
        ) periodos_cliente
        GROUP BY cliente_id, periodo
        HAVING COUNT(*) > 0  -- Solo períodos con actividad
    ) historical_periods
    GROUP BY cliente_id
    HAVING COUNT(*) >= 3  -- Al menos 3 períodos históricos para comparar
) historical_avg ON c.id = historical_avg.cliente_id
WHERE vip_status.categoria_cliente LIKE 'VIP%'  -- Solo clientes VIP
AND (
    recent_behavior.compras_recientes_90d < historical_avg.compras_promedio_90d_historico * 0.7
    OR recent_behavior.gasto_reciente_90d < historical_avg.gasto_promedio_90d_historico * 0.7
    OR DATEDIFF(CURDATE(), recent_behavior.ultima_compra) > 45
)
ORDER BY 
    CASE vip_status.categoria_cliente
        WHEN 'VIP Platino' THEN 1
        WHEN 'VIP Oro' THEN 2
        WHEN 'VIP Plata' THEN 3
    END,
    recent_behavior.gasto_reciente_90d / historical_avg.gasto_promedio_90d_historico ASC;

-- ==========================================
-- EJERCICIO 4: OPTIMIZACIÓN DE INVENTARIO CON SUBCONSULTAS
-- ==========================================

-- 4.1 Análisis inteligente de stock con predicción de demanda
-- Identifica productos que necesitan reabastecimiento considerando:
-- - Velocidad de rotación histórica
-- - Tendencia de demanda
-- - Estacionalidad
-- - Lead time de proveedores
SELECT 
    p.nombre AS producto,
    p.stock_actual,
    demand_analysis.demanda_promedio_diaria,
    demand_analysis.demanda_maxima_diaria,
    demand_analysis.variabilidad_demanda,
    trend_analysis.tendencia_demanda,
    seasonality.factor_estacional_actual,
    stock_projection.dias_inventario_restante,
    stock_projection.stock_recomendado,
    CASE 
        WHEN stock_projection.dias_inventario_restante <= supplier_data.lead_time_dias 
        THEN 'CRÍTICO - Ordenar inmediatamente'
        WHEN stock_projection.dias_inventario_restante <= supplier_data.lead_time_dias * 1.5
        THEN 'URGENTE - Ordenar esta semana'
        WHEN stock_projection.dias_inventario_restante <= supplier_data.lead_time_dias * 2
        THEN 'PLANIFICAR - Ordenar próxima semana'
        ELSE 'NORMAL - Monitorear'
    END AS recomendacion_compra
FROM productos p
JOIN (
    -- Análisis de demanda histórica
    SELECT 
        producto_id,
        AVG(cantidad_diaria) AS demanda_promedio_diaria,
        MAX(cantidad_diaria) AS demanda_maxima_diaria,
        STDDEV(cantidad_diaria) AS variabilidad_demanda
    FROM (
        SELECT 
            dp.producto_id,
            DATE(pe.fecha) AS fecha,
            SUM(dp.cantidad) AS cantidad_diaria
        FROM detalle_pedidos dp
        JOIN pedidos pe ON dp.pedido_id = pe.id
        WHERE pe.estado = 'entregado'
        AND pe.fecha >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
        GROUP BY dp.producto_id, DATE(pe.fecha)
    ) daily_demand
    GROUP BY producto_id
    HAVING COUNT(*) >= 30  -- Al menos 30 días de datos
) demand_analysis ON p.id = demand_analysis.producto_id
JOIN (
    -- Análisis de tendencia (crecimiento/decrecimiento)
    SELECT 
        producto_id,
        CASE 
            WHEN slope > 0.1 THEN 'Creciente'
            WHEN slope < -0.1 THEN 'Decreciente'
            ELSE 'Estable'
        END AS tendencia_demanda,
        slope AS pendiente_tendencia
    FROM (
        SELECT 
            producto_id,
            -- Cálculo de regresión lineal simple para tendencia
            (COUNT(*) * SUM(day_number * cantidad_diaria) - SUM(day_number) * SUM(cantidad_diaria)) /
            (COUNT(*) * SUM(day_number * day_number) - SUM(day_number) * SUM(day_number)) AS slope
        FROM (
            SELECT 
                dp.producto_id,
                DATEDIFF(pe.fecha, DATE_SUB(CURDATE(), INTERVAL 90 DAY)) + 1 AS day_number,
                SUM(dp.cantidad) AS cantidad_diaria
            FROM detalle_pedidos dp
            JOIN pedidos pe ON dp.pedido_id = pe.id
            WHERE pe.estado = 'entregado'
            AND pe.fecha >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
            GROUP BY dp.producto_id, DATE(pe.fecha)
        ) trend_data
        GROUP BY producto_id
    ) trend_calc
) trend_analysis ON p.id = trend_analysis.producto_id
JOIN (
    -- Factor estacional (comparación mes actual vs promedio anual)
    SELECT 
        producto_id,
        demanda_mes_actual / NULLIF(demanda_promedio_mensual, 0) AS factor_estacional_actual
    FROM (
        SELECT 
            producto_id,
            -- Demanda del mes actual
            (
                SELECT SUM(dp2.cantidad)
                FROM detalle_pedidos dp2
                JOIN pedidos pe2 ON dp2.pedido_id = pe2.id
                WHERE dp2.producto_id = monthly_data.producto_id
                AND pe2.estado = 'entregado'
                AND YEAR(pe2.fecha) = YEAR(CURDATE())
                AND MONTH(pe2.fecha) = MONTH(CURDATE())
            ) AS demanda_mes_actual,
            -- Promedio mensual histórico
            AVG(cantidad_mensual) AS demanda_promedio_mensual
        FROM (
            SELECT 
                dp.producto_id,
                YEAR(pe.fecha) AS año,
                MONTH(pe.fecha) AS mes,
                SUM(dp.cantidad) AS cantidad_mensual
            FROM detalle_pedidos dp
            JOIN pedidos pe ON dp.pedido_id = pe.id
            WHERE pe.estado = 'entregado'
            AND pe.fecha >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
            AND pe.fecha < DATE_FORMAT(CURDATE(), '%Y-%m-01')  -- Excluir mes actual
            GROUP BY dp.producto_id, YEAR(pe.fecha), MONTH(pe.fecha)
        ) monthly_data
        GROUP BY producto_id
        HAVING COUNT(*) >= 6  -- Al menos 6 meses de historia
    ) seasonality_calc
) seasonality ON p.id = seasonality.producto_id
JOIN (
    -- Proyección de stock y recomendaciones
    SELECT 
        producto_id,
        stock_actual,
        FLOOR(stock_actual / GREATEST(demanda_ajustada, 0.1)) AS dias_inventario_restante,
        CEILING(demanda_ajustada * (lead_time_promedio + safety_stock_days)) AS stock_recomendado
    FROM (
        SELECT 
            p2.id AS producto_id,
            p2.stock AS stock_actual,
            da.demanda_promedio_diaria * GREATEST(s.factor_estacional_actual, 0.5) * 
            CASE ta.tendencia_demanda
                WHEN 'Creciente' THEN 1.2
                WHEN 'Decreciente' THEN 0.8
                ELSE 1.0
            END AS demanda_ajustada,
            COALESCE(sd.lead_time_dias, 14) AS lead_time_promedio,
            GREATEST(da.variabilidad_demanda / da.demanda_promedio_diaria * 7, 3) AS safety_stock_days
        FROM productos p2
        JOIN demand_analysis da ON p2.id = da.producto_id
        JOIN trend_analysis ta ON p2.id = ta.producto_id
        JOIN seasonality s ON p2.id = s.producto_id
        LEFT JOIN proveedores_productos pp ON p2.id = pp.producto_id
        LEFT JOIN (
            SELECT proveedor_id, AVG(lead_time_dias) AS lead_time_dias
            FROM proveedores
            GROUP BY proveedor_id
        ) sd ON pp.proveedor_id = sd.proveedor_id
    ) stock_calc
) stock_projection ON p.id = stock_projection.producto_id
LEFT JOIN proveedores_productos pp ON p.id = pp.producto_id
LEFT JOIN (
    SELECT proveedor_id, lead_time_dias
    FROM proveedores
) supplier_data ON pp.proveedor_id = supplier_data.proveedor_id
WHERE p.activo = 1
AND demand_analysis.demanda_promedio_diaria > 0
ORDER BY 
    CASE 
        WHEN stock_projection.dias_inventario_restante <= COALESCE(supplier_data.lead_time_dias, 14) THEN 1
        WHEN stock_projection.dias_inventario_restante <= COALESCE(supplier_data.lead_time_dias, 14) * 1.5 THEN 2
        WHEN stock_projection.dias_inventario_restante <= COALESCE(supplier_data.lead_time_dias, 14) * 2 THEN 3
        ELSE 4
    END,
    stock_projection.dias_inventario_restante ASC;

-- ==========================================
-- EJERCICIOS DE DESAFÍO ADICIONALES
-- ==========================================

/*
DESAFÍO 1: ANÁLISIS DE FRAUDE
Crea subconsultas para detectar patrones sospechosos:
- Clientes con múltiples direcciones en poco tiempo
- Pedidos con patrones atípicos de productos
- Transacciones fuera del comportamiento normal del cliente

DESAFÍO 2: OPTIMIZACIÓN DE PRECIOS DINÁMICOS
Desarrolla subconsultas para:
- Analizar elasticidad de precios por producto
- Identificar oportunidades de up-pricing
- Calcular precios óptimos basados en competencia y demanda

DESAFÍO 3: ANÁLISIS DE LIFETIME VALUE (CLV)
Construye subconsultas que calculen:
- Valor presente neto de cada cliente
- Predicción de valor futuro basada en comportamiento
- Segmentación por CLV para estrategias diferenciadas

DESAFÍO 4: ANÁLISIS DE CANIBALIZACIÓNES
Usa subconsultas para identificar:
- Productos que se canibalizan entre sí
- Impacto de nuevos lanzamientos en productos existentes
- Optimización de portfolio de productos
*/

-- ==========================================
-- METACONOCIMIENTO: CUÁNDO USAR SUBCONSULTAS
-- ==========================================

/*
✅ USAR SUBCONSULTAS CUANDO:
1. Necesitas filtrar basado en agregaciones complejas
2. Requieres cálculos que dependen de otros cálculos
3. Quieres mantener la consulta legible y modular
4. Los datos intermedios no se reutilizan en otras partes

❌ EVITAR SUBCONSULTAS CUANDO:
1. Un JOIN simple puede resolver el problema
2. La subconsulta correlacionada se ejecuta muchas veces
3. Los datos se pueden obtener con window functions
4. El rendimiento es crítico y hay alternativas más eficientes

🔧 OPTIMIZACIÓN DE SUBCONSULTAS:
1. Usa EXISTS en lugar de IN cuando sea posible
2. Convierte subconsultas correlacionadas a JOINs si es factible
3. Considera CTEs para subconsultas complejas reutilizables
4. Usa EXPLAIN para verificar planes de ejecución
5. Crea índices apropiados para columnas en subconsultas
*/
