-- =====================================================
-- SISTEMA DE VENTAS AVANZADO - VISTAS Y PROCEDIMIENTOS
-- =====================================================
-- Descripción: Vistas y stored procedures para el sistema de ventas
-- Autor: MySQL Advanced Course
-- Fecha: 2025
-- =====================================================

USE sistema_ventas_avanzado;

-- =====================================================
-- VISTAS PARA REPORTES Y ANÁLISIS
-- =====================================================

-- Vista: Resumen de ventas por empleado
DROP VIEW IF EXISTS vista_ventas_empleados;
CREATE VIEW vista_ventas_empleados AS
SELECT 
    e.id as empleado_id,
    CONCAT(e.nombre, ' ', e.apellido) as empleado_nombre,
    e.departamento,
    e.puesto,
    COUNT(p.id) as total_pedidos,
    COALESCE(SUM(p.total), 0) as ventas_totales,
    COALESCE(AVG(p.total), 0) as ticket_promedio,
    DATE(MIN(p.fecha_pedido)) as primera_venta,
    DATE(MAX(p.fecha_pedido)) as ultima_venta,
    CASE 
        WHEN SUM(p.total) > 100000 THEN 'Estrella'
        WHEN SUM(p.total) > 50000 THEN 'Alto'
        WHEN SUM(p.total) > 20000 THEN 'Medio'
        ELSE 'Bajo'
    END as nivel_performance
FROM empleados e
LEFT JOIN pedidos p ON e.id = p.empleado_id AND p.estado IN ('entregado', 'en_transito')
WHERE e.estado = 'activo'
GROUP BY e.id, e.nombre, e.apellido, e.departamento, e.puesto;

-- Vista: Productos con información completa
DROP VIEW IF EXISTS vista_productos_completa;
CREATE VIEW vista_productos_completa AS
SELECT 
    p.id,
    p.nombre,
    p.descripcion,
    p.sku,
    c.nombre as categoria,
    m.nombre as marca,
    prov.nombre as proveedor,
    p.precio_compra,
    p.precio_venta,
    p.stock_actual,
    p.stock_minimo,
    p.peso,
    p.dimensiones,
    p.estado,
    ROUND(((p.precio_venta - p.precio_compra) / p.precio_venta) * 100, 2) as margen_porcentual,
    CASE 
        WHEN p.stock_actual <= 0 THEN 'Sin Stock'
        WHEN p.stock_actual <= p.stock_minimo THEN 'Stock Bajo'
        WHEN p.stock_actual <= p.stock_minimo * 2 THEN 'Stock Normal'
        ELSE 'Stock Alto'
    END as estado_stock
FROM productos p
JOIN categorias c ON p.categoria_id = c.id
JOIN marcas m ON p.marca_id = m.id
JOIN proveedores prov ON p.proveedor_id = prov.id;

-- Vista: Clientes con resumen de compras
DROP VIEW IF EXISTS vista_clientes_resumen;
CREATE VIEW vista_clientes_resumen AS
SELECT 
    c.id,
    c.tipo_cliente,
    CASE 
        WHEN c.tipo_cliente = 'individual' THEN CONCAT(c.nombre, ' ', c.apellido)
        ELSE c.razon_social
    END as cliente_nombre,
    c.email,
    c.telefono,
    pa.nombre as pais,
    ci.nombre as ciudad,
    c.fecha_registro,
    COUNT(p.id) as total_pedidos,
    COALESCE(SUM(p.total), 0) as valor_total_compras,
    COALESCE(AVG(p.total), 0) as ticket_promedio,
    DATE(MAX(p.fecha_pedido)) as ultima_compra,
    DATEDIFF(CURDATE(), MAX(p.fecha_pedido)) as dias_sin_comprar,
    CASE 
        WHEN COUNT(p.id) = 0 THEN 'Sin Compras'
        WHEN DATEDIFF(CURDATE(), MAX(p.fecha_pedido)) <= 30 THEN 'Activo'
        WHEN DATEDIFF(CURDATE(), MAX(p.fecha_pedido)) <= 90 THEN 'Reciente'
        WHEN DATEDIFF(CURDATE(), MAX(p.fecha_pedido)) <= 180 THEN 'Inactivo'
        ELSE 'Perdido'
    END as estado_cliente
FROM clientes c
LEFT JOIN paises pa ON c.pais_id = pa.id
LEFT JOIN ciudades ci ON c.ciudad_id = ci.id
LEFT JOIN pedidos p ON c.id = p.cliente_id AND p.estado IN ('entregado', 'en_transito')
GROUP BY c.id, cliente_nombre, c.email, c.telefono, pa.nombre, ci.nombre, c.fecha_registro;

-- Vista: Dashboard ejecutivo
DROP VIEW IF EXISTS vista_dashboard_ejecutivo;
CREATE VIEW vista_dashboard_ejecutivo AS
SELECT 
    'ventas_mes_actual' as metrica,
    COALESCE(SUM(total), 0) as valor,
    'MXN' as unidad,
    DATE(NOW()) as fecha_actualizacion
FROM pedidos 
WHERE estado IN ('entregado', 'en_transito') 
    AND YEAR(fecha_pedido) = YEAR(CURDATE()) 
    AND MONTH(fecha_pedido) = MONTH(CURDATE())

UNION ALL

SELECT 
    'pedidos_mes_actual',
    COUNT(*),
    'pedidos',
    DATE(NOW())
FROM pedidos 
WHERE estado IN ('entregado', 'en_transito') 
    AND YEAR(fecha_pedido) = YEAR(CURDATE()) 
    AND MONTH(fecha_pedido) = MONTH(CURDATE())

UNION ALL

SELECT 
    'clientes_activos',
    COUNT(DISTINCT cliente_id),
    'clientes',
    DATE(NOW())
FROM pedidos 
WHERE estado IN ('entregado', 'en_transito') 
    AND fecha_pedido >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)

UNION ALL

SELECT 
    'productos_bajo_stock',
    COUNT(*),
    'productos',
    DATE(NOW())
FROM productos 
WHERE stock_actual <= stock_minimo AND estado = 'activo';

-- =====================================================
-- STORED PROCEDURES
-- =====================================================

-- Procedure: Crear nuevo pedido
DELIMITER //
DROP PROCEDURE IF EXISTS sp_crear_pedido//
CREATE PROCEDURE sp_crear_pedido(
    IN p_cliente_id INT,
    IN p_empleado_id INT,
    IN p_direccion_envio TEXT,
    IN p_ciudad_envio VARCHAR(100),
    IN p_pais_envio VARCHAR(100),
    IN p_codigo_postal VARCHAR(20),
    IN p_metodo_pago ENUM('efectivo', 'tarjeta_credito', 'tarjeta_debito', 'transferencia', 'paypal', 'credito_empresarial'),
    IN p_notas TEXT,
    OUT p_pedido_id INT,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE v_error_msg VARCHAR(255);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1 v_error_msg = MESSAGE_TEXT;
        SET p_mensaje = CONCAT('Error: ', v_error_msg);
        SET p_pedido_id = 0;
    END;
    
    START TRANSACTION;
    
    -- Validar cliente
    IF NOT EXISTS (SELECT 1 FROM clientes WHERE id = p_cliente_id) THEN
        SET p_mensaje = 'Error: Cliente no existe';
        SET p_pedido_id = 0;
        ROLLBACK;
    ELSE
        -- Insertar pedido
        INSERT INTO pedidos (
            cliente_id, empleado_id, fecha_pedido, estado, 
            subtotal, impuestos, descuento, total,
            metodo_pago, direccion_envio, ciudad_envio, 
            pais_envio, codigo_postal_envio, notas
        ) VALUES (
            p_cliente_id, p_empleado_id, NOW(), 'pendiente',
            0, 0, 0, 0,
            p_metodo_pago, p_direccion_envio, p_ciudad_envio,
            p_pais_envio, p_codigo_postal, p_notas
        );
        
        SET p_pedido_id = LAST_INSERT_ID();
        SET p_mensaje = 'Pedido creado exitosamente';
        
        COMMIT;
    END IF;
END//
DELIMITER ;

-- Procedure: Agregar producto al pedido
DELIMITER //
DROP PROCEDURE IF EXISTS sp_agregar_producto_pedido//
CREATE PROCEDURE sp_agregar_producto_pedido(
    IN p_pedido_id INT,
    IN p_producto_id INT,
    IN p_cantidad INT,
    IN p_descuento_linea DECIMAL(10,2),
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE v_precio_unitario DECIMAL(10,2);
    DECLARE v_stock_actual INT;
    DECLARE v_subtotal_linea DECIMAL(10,2);
    DECLARE v_error_msg VARCHAR(255);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1 v_error_msg = MESSAGE_TEXT;
        SET p_mensaje = CONCAT('Error: ', v_error_msg);
    END;
    
    START TRANSACTION;
    
    -- Validar que el pedido existe y está en estado pendiente
    IF NOT EXISTS (SELECT 1 FROM pedidos WHERE id = p_pedido_id AND estado = 'pendiente') THEN
        SET p_mensaje = 'Error: Pedido no existe o no está en estado pendiente';
        ROLLBACK;
    ELSE
        -- Obtener precio y stock del producto
        SELECT precio_venta, stock_actual 
        INTO v_precio_unitario, v_stock_actual
        FROM productos 
        WHERE id = p_producto_id AND estado = 'activo';
        
        -- Validar stock
        IF v_stock_actual < p_cantidad THEN
            SET p_mensaje = CONCAT('Error: Stock insuficiente. Disponible: ', v_stock_actual);
            ROLLBACK;
        ELSE
            -- Calcular subtotal de línea
            SET v_subtotal_linea = (v_precio_unitario * p_cantidad) - p_descuento_linea;
            
            -- Insertar detalle del pedido
            INSERT INTO detalles_pedido (
                pedido_id, producto_id, cantidad, 
                precio_unitario, descuento_linea, subtotal_linea
            ) VALUES (
                p_pedido_id, p_producto_id, p_cantidad,
                v_precio_unitario, p_descuento_linea, v_subtotal_linea
            );
            
            SET p_mensaje = 'Producto agregado exitosamente al pedido';
            COMMIT;
        END IF;
    END IF;
END//
DELIMITER ;

-- Procedure: Calcular totales del pedido
DELIMITER //
DROP PROCEDURE IF EXISTS sp_calcular_totales_pedido//
CREATE PROCEDURE sp_calcular_totales_pedido(
    IN p_pedido_id INT,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE v_subtotal DECIMAL(10,2) DEFAULT 0;
    DECLARE v_descuento_total DECIMAL(10,2) DEFAULT 0;
    DECLARE v_impuestos DECIMAL(10,2) DEFAULT 0;
    DECLARE v_total DECIMAL(10,2) DEFAULT 0;
    DECLARE v_error_msg VARCHAR(255);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1 v_error_msg = MESSAGE_TEXT;
        SET p_mensaje = CONCAT('Error: ', v_error_msg);
    END;
    
    START TRANSACTION;
    
    -- Calcular subtotal y descuento total
    SELECT 
        COALESCE(SUM(subtotal_linea), 0),
        COALESCE(SUM(descuento_linea), 0)
    INTO v_subtotal, v_descuento_total
    FROM detalles_pedido 
    WHERE pedido_id = p_pedido_id;
    
    -- Calcular impuestos (16% en México)
    SET v_impuestos = v_subtotal * 0.16;
    
    -- Calcular total
    SET v_total = v_subtotal + v_impuestos;
    
    -- Actualizar pedido
    UPDATE pedidos 
    SET 
        subtotal = v_subtotal,
        descuento = v_descuento_total,
        impuestos = v_impuestos,
        total = v_total,
        fecha_actualizacion = NOW()
    WHERE id = p_pedido_id;
    
    SET p_mensaje = CONCAT('Totales calculados: Subtotal=', v_subtotal, ', Impuestos=', v_impuestos, ', Total=', v_total);
    
    COMMIT;
END//
DELIMITER ;

-- Procedure: Confirmar pedido y actualizar inventario
DELIMITER //
DROP PROCEDURE IF EXISTS sp_confirmar_pedido//
CREATE PROCEDURE sp_confirmar_pedido(
    IN p_pedido_id INT,
    IN p_empleado_id INT,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_producto_id INT;
    DECLARE v_cantidad INT;
    DECLARE v_precio_unitario DECIMAL(10,2);
    DECLARE v_stock_actual INT;
    DECLARE v_error_msg VARCHAR(255);
    
    -- Cursor para recorrer los productos del pedido
    DECLARE cur_productos CURSOR FOR
        SELECT producto_id, cantidad, precio_unitario
        FROM detalles_pedido
        WHERE pedido_id = p_pedido_id;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1 v_error_msg = MESSAGE_TEXT;
        SET p_mensaje = CONCAT('Error: ', v_error_msg);
    END;
    
    START TRANSACTION;
    
    -- Validar que el pedido existe y está pendiente
    IF NOT EXISTS (SELECT 1 FROM pedidos WHERE id = p_pedido_id AND estado = 'pendiente') THEN
        SET p_mensaje = 'Error: Pedido no existe o no está en estado pendiente';
        ROLLBACK;
    ELSE
        -- Verificar stock para todos los productos antes de confirmar
        OPEN cur_productos;
        
        productos_loop: LOOP
            FETCH cur_productos INTO v_producto_id, v_cantidad, v_precio_unitario;
            IF v_done THEN
                LEAVE productos_loop;
            END IF;
            
            SELECT stock_actual INTO v_stock_actual
            FROM productos 
            WHERE id = v_producto_id;
            
            IF v_stock_actual < v_cantidad THEN
                SET p_mensaje = CONCAT('Error: Stock insuficiente para producto ID ', v_producto_id);
                CLOSE cur_productos;
                ROLLBACK;
                LEAVE productos_loop;
            END IF;
        END LOOP;
        
        CLOSE cur_productos;
        
        -- Si llegamos aquí, hay stock suficiente para todos los productos
        SET v_done = FALSE;
        OPEN cur_productos;
        
        confirmar_loop: LOOP
            FETCH cur_productos INTO v_producto_id, v_cantidad, v_precio_unitario;
            IF v_done THEN
                LEAVE confirmar_loop;
            END IF;
            
            -- Actualizar stock
            UPDATE productos 
            SET stock_actual = stock_actual - v_cantidad
            WHERE id = v_producto_id;
            
            -- Registrar movimiento de inventario
            INSERT INTO movimientos_inventario (
                producto_id, tipo_movimiento, cantidad, motivo,
                empleado_id, pedido_id, costo_unitario, 
                fecha_movimiento, observaciones
            ) VALUES (
                v_producto_id, 'salida', v_cantidad, 'venta',
                p_empleado_id, p_pedido_id, v_precio_unitario,
                NOW(), CONCAT('Venta confirmada - Pedido #', p_pedido_id)
            );
        END LOOP;
        
        CLOSE cur_productos;
        
        -- Actualizar estado del pedido
        UPDATE pedidos 
        SET 
            estado = 'confirmado',
            fecha_actualizacion = NOW(),
            fecha_envio_estimada = DATE_ADD(CURDATE(), INTERVAL 3 DAY)
        WHERE id = p_pedido_id;
        
        SET p_mensaje = 'Pedido confirmado exitosamente';
        COMMIT;
    END IF;
END//
DELIMITER ;

-- Procedure: Reporte de ventas por período
DELIMITER //
DROP PROCEDURE IF EXISTS sp_reporte_ventas_periodo//
CREATE PROCEDURE sp_reporte_ventas_periodo(
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE,
    IN p_empleado_id INT
)
BEGIN
    SELECT 
        p.id as pedido_id,
        p.fecha_pedido,
        CASE 
            WHEN c.tipo_cliente = 'individual' THEN CONCAT(c.nombre, ' ', c.apellido)
            ELSE c.razon_social
        END as cliente,
        c.tipo_cliente,
        p.subtotal,
        p.impuestos,
        p.descuento,
        p.total,
        p.metodo_pago,
        p.estado,
        COUNT(dp.id) as items_pedido,
        SUM(dp.cantidad) as productos_totales
    FROM pedidos p
    JOIN clientes c ON p.cliente_id = c.id
    LEFT JOIN detalles_pedido dp ON p.id = dp.pedido_id
    WHERE p.fecha_pedido BETWEEN p_fecha_inicio AND p_fecha_fin
        AND (p_empleado_id IS NULL OR p.empleado_id = p_empleado_id)
        AND p.estado IN ('entregado', 'en_transito', 'confirmado')
    GROUP BY p.id, p.fecha_pedido, cliente, c.tipo_cliente, 
             p.subtotal, p.impuestos, p.descuento, p.total, 
             p.metodo_pago, p.estado
    ORDER BY p.fecha_pedido DESC;
END//
DELIMITER ;

-- Procedure: Alertas de inventario
DELIMITER //
DROP PROCEDURE IF EXISTS sp_alertas_inventario//
CREATE PROCEDURE sp_alertas_inventario()
BEGIN
    SELECT 
        p.id,
        p.nombre,
        p.sku,
        c.nombre as categoria,
        m.nombre as marca,
        p.stock_actual,
        p.stock_minimo,
        p.stock_actual - p.stock_minimo as diferencia,
        CASE 
            WHEN p.stock_actual <= 0 THEN 'SIN STOCK'
            WHEN p.stock_actual <= p.stock_minimo THEN 'CRÍTICO'
            WHEN p.stock_actual <= p.stock_minimo * 1.5 THEN 'BAJO'
            ELSE 'NORMAL'
        END as nivel_alerta,
        prov.nombre as proveedor,
        prov.email as email_proveedor,
        prov.telefono as telefono_proveedor
    FROM productos p
    JOIN categorias c ON p.categoria_id = c.id
    JOIN marcas m ON p.marca_id = m.id
    JOIN proveedores prov ON p.proveedor_id = prov.id
    WHERE p.estado = 'activo' 
        AND p.stock_actual <= p.stock_minimo * 1.5
    ORDER BY nivel_alerta DESC, p.stock_actual ASC;
END//
DELIMITER ;

-- =====================================================
-- FUNCIONES AUXILIARES
-- =====================================================

-- Función: Calcular edad de cliente
DELIMITER //
DROP FUNCTION IF EXISTS fn_calcular_edad//
CREATE FUNCTION fn_calcular_edad(fecha_nacimiento DATE)
RETURNS INT
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE edad INT;
    
    IF fecha_nacimiento IS NULL THEN
        RETURN NULL;
    END IF;
    
    SET edad = TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE());
    
    RETURN edad;
END//
DELIMITER ;

-- Función: Obtener nombre completo de cliente
DELIMITER //
DROP FUNCTION IF EXISTS fn_nombre_cliente//
CREATE FUNCTION fn_nombre_cliente(
    tipo_cliente ENUM('individual', 'corporativo'),
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    razon_social VARCHAR(200)
)
RETURNS VARCHAR(300)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE nombre_completo VARCHAR(300);
    
    IF tipo_cliente = 'individual' THEN
        SET nombre_completo = CONCAT(COALESCE(nombre, ''), ' ', COALESCE(apellido, ''));
    ELSE
        SET nombre_completo = COALESCE(razon_social, 'Corporativo sin nombre');
    END IF;
    
    RETURN TRIM(nombre_completo);
END//
DELIMITER ;

-- Función: Calcular días desde última compra
DELIMITER //
DROP FUNCTION IF EXISTS fn_dias_ultima_compra//
CREATE FUNCTION fn_dias_ultima_compra(cliente_id INT)
RETURNS INT
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE ultima_fecha DATE;
    DECLARE dias INT;
    
    SELECT MAX(DATE(fecha_pedido)) INTO ultima_fecha
    FROM pedidos 
    WHERE cliente_id = cliente_id 
        AND estado IN ('entregado', 'en_transito');
    
    IF ultima_fecha IS NULL THEN
        RETURN NULL;
    END IF;
    
    SET dias = DATEDIFF(CURDATE(), ultima_fecha);
    
    RETURN dias;
END//
DELIMITER ;

-- =====================================================
-- EJEMPLOS DE USO DE PROCEDURES
-- =====================================================

/*
-- Crear un nuevo pedido
CALL sp_crear_pedido(1, 6, 'Av. Insurgentes 123', 'Ciudad de México', 'México', '06700', 'tarjeta_credito', 'Entrega urgente', @pedido_id, @mensaje);
SELECT @pedido_id, @mensaje;

-- Agregar productos al pedido
CALL sp_agregar_producto_pedido(@pedido_id, 1, 2, 0.00, @mensaje);
SELECT @mensaje;

CALL sp_agregar_producto_pedido(@pedido_id, 5, 1, 50.00, @mensaje);
SELECT @mensaje;

-- Calcular totales
CALL sp_calcular_totales_pedido(@pedido_id, @mensaje);
SELECT @mensaje;

-- Confirmar pedido
CALL sp_confirmar_pedido(@pedido_id, 6, @mensaje);
SELECT @mensaje;

-- Generar reporte de ventas
CALL sp_reporte_ventas_periodo('2024-01-01', '2024-03-31', NULL);

-- Ver alertas de inventario
CALL sp_alertas_inventario();

-- Usar funciones
SELECT 
    id,
    fn_nombre_cliente(tipo_cliente, nombre, apellido, razon_social) as nombre_completo,
    fn_calcular_edad(fecha_nacimiento) as edad,
    fn_dias_ultima_compra(id) as dias_sin_comprar
FROM clientes 
LIMIT 10;
*/
