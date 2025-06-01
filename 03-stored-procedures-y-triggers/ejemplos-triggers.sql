-- =============================================================================
-- TRIGGERS EN MYSQL - EJEMPLOS PRÁCTICOS
-- =============================================================================
-- Autor: [Tu Nombre]
-- Fecha: 28/05/2025
-- Descripción: Ejemplos completos de triggers en MySQL para auditoría, 
--              validación y automatización de procesos
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. CONFIGURACIÓN INICIAL - BASES DE DATOS DE EJEMPLO
-- -----------------------------------------------------------------------------

-- Base de datos para sistema de ventas
CREATE DATABASE IF NOT EXISTS tienda_triggers;
USE tienda_triggers;

-- Tabla de productos
CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    categoria_id INT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabla de ventas
CREATE TABLE ventas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_venta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10,2) NOT NULL,
    cliente_id INT
);

-- Tabla de detalle de ventas
CREATE TABLE detalle_ventas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    venta_id INT,
    producto_id INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (venta_id) REFERENCES ventas(id),
    FOREIGN KEY (producto_id) REFERENCES productos(id)
);

-- -----------------------------------------------------------------------------
-- 2. TABLAS DE AUDITORÍA
-- -----------------------------------------------------------------------------

-- Tabla de auditoría para productos
CREATE TABLE auditoria_productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    producto_id INT,
    accion ENUM('INSERT', 'UPDATE', 'DELETE'),
    campo_modificado VARCHAR(50),
    valor_anterior TEXT,
    valor_nuevo TEXT,
    usuario VARCHAR(50),
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de log de stock
CREATE TABLE log_stock (
    id INT PRIMARY KEY AUTO_INCREMENT,
    producto_id INT,
    stock_anterior INT,
    stock_nuevo INT,
    diferencia INT,
    motivo VARCHAR(100),
    fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de estadísticas diarias
CREATE TABLE estadisticas_ventas_diarias (
    fecha DATE PRIMARY KEY,
    total_ventas DECIMAL(12,2) DEFAULT 0,
    cantidad_ventas INT DEFAULT 0,
    ticket_promedio DECIMAL(10,2) DEFAULT 0
);

-- -----------------------------------------------------------------------------
-- 3. TRIGGERS BEFORE - VALIDACIÓN Y PREPARACIÓN
-- -----------------------------------------------------------------------------

-- Trigger: Validar datos antes de insertar producto
DELIMITER //
CREATE TRIGGER before_insert_producto
    BEFORE INSERT ON productos
    FOR EACH ROW
BEGIN
    -- Validar precio positivo
    IF NEW.precio <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El precio debe ser mayor que 0';
    END IF;
    
    -- Validar stock no negativo
    IF NEW.stock < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El stock no puede ser negativo';
    END IF;
    
    -- Normalizar nombre (primera letra mayúscula)
    SET NEW.nombre = CONCAT(UPPER(SUBSTRING(NEW.nombre, 1, 1)), 
                           LOWER(SUBSTRING(NEW.nombre, 2)));
    
    -- Redondear precio a 2 decimales
    SET NEW.precio = ROUND(NEW.precio, 2);
END//
DELIMITER ;

-- Trigger: Validar actualización de producto
DELIMITER //
CREATE TRIGGER before_update_producto
    BEFORE UPDATE ON productos
    FOR EACH ROW
BEGIN
    -- Validar precio positivo
    IF NEW.precio <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El precio debe ser mayor que 0';
    END IF;
    
    -- Validar stock no negativo
    IF NEW.stock < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El stock no puede ser negativo';
    END IF;
    
    -- Actualizar fecha de modificación
    SET NEW.fecha_actualizacion = CURRENT_TIMESTAMP;
END//
DELIMITER ;

-- Trigger: Validar detalle de venta
DELIMITER //
CREATE TRIGGER before_insert_detalle_venta
    BEFORE INSERT ON detalle_ventas
    FOR EACH ROW
BEGIN
    DECLARE stock_disponible INT;
    DECLARE precio_actual DECIMAL(10,2);
    
    -- Obtener stock y precio actual del producto
    SELECT stock, precio INTO stock_disponible, precio_actual
    FROM productos 
    WHERE id = NEW.producto_id;
    
    -- Validar stock suficiente
    IF stock_disponible < NEW.cantidad THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = CONCAT('Stock insuficiente. Disponible: ', stock_disponible);
    END IF;
    
    -- Calcular subtotal automáticamente
    SET NEW.subtotal = NEW.cantidad * NEW.precio_unitario;
    
    -- Validar que el precio no difiera más del 10% del precio actual
    IF ABS(NEW.precio_unitario - precio_actual) > (precio_actual * 0.1) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El precio unitario difiere mucho del precio actual del producto';
    END IF;
END//
DELIMITER ;

-- -----------------------------------------------------------------------------
-- 4. TRIGGERS AFTER - ACCIONES POST-OPERACIÓN
-- -----------------------------------------------------------------------------

-- Trigger: Auditoría completa de productos
DELIMITER //
CREATE TRIGGER after_insert_producto
    AFTER INSERT ON productos
    FOR EACH ROW
BEGIN
    INSERT INTO auditoria_productos (
        producto_id, accion, campo_modificado, valor_nuevo, usuario
    ) VALUES (
        NEW.id, 'INSERT', 'NUEVO_PRODUCTO', 
        CONCAT('Nombre:', NEW.nombre, ', Precio:', NEW.precio, ', Stock:', NEW.stock),
        USER()
    );
END//
DELIMITER ;

-- Trigger: Auditoría de actualizaciones
DELIMITER //
CREATE TRIGGER after_update_producto
    AFTER UPDATE ON productos
    FOR EACH ROW
BEGIN
    -- Auditar cambio de precio
    IF OLD.precio != NEW.precio THEN
        INSERT INTO auditoria_productos (
            producto_id, accion, campo_modificado, valor_anterior, valor_nuevo, usuario
        ) VALUES (
            NEW.id, 'UPDATE', 'precio', OLD.precio, NEW.precio, USER()
        );
    END IF;
    
    -- Auditar cambio de stock
    IF OLD.stock != NEW.stock THEN
        INSERT INTO auditoria_productos (
            producto_id, accion, campo_modificado, valor_anterior, valor_nuevo, usuario
        ) VALUES (
            NEW.id, 'UPDATE', 'stock', OLD.stock, NEW.stock, USER()
        );
        
        -- Log específico de stock
        INSERT INTO log_stock (
            producto_id, stock_anterior, stock_nuevo, diferencia, motivo
        ) VALUES (
            NEW.id, OLD.stock, NEW.stock, (NEW.stock - OLD.stock), 'Actualización manual'
        );
    END IF;
    
    -- Auditar cambio de nombre
    IF OLD.nombre != NEW.nombre THEN
        INSERT INTO auditoria_productos (
            producto_id, accion, campo_modificado, valor_anterior, valor_nuevo, usuario
        ) VALUES (
            NEW.id, 'UPDATE', 'nombre', OLD.nombre, NEW.nombre, USER()
        );
    END IF;
END//
DELIMITER ;

-- Trigger: Auditoría de eliminaciones
DELIMITER //
CREATE TRIGGER after_delete_producto
    AFTER DELETE ON productos
    FOR EACH ROW
BEGIN
    INSERT INTO auditoria_productos (
        producto_id, accion, campo_modificado, valor_anterior, usuario
    ) VALUES (
        OLD.id, 'DELETE', 'PRODUCTO_ELIMINADO',
        CONCAT('Nombre:', OLD.nombre, ', Precio:', OLD.precio, ', Stock:', OLD.stock),
        USER()
    );
END//
DELIMITER ;

-- Trigger: Actualizar stock después de venta
DELIMITER //
CREATE TRIGGER after_insert_detalle_venta
    AFTER INSERT ON detalle_ventas
    FOR EACH ROW
BEGIN
    -- Reducir stock del producto
    UPDATE productos 
    SET stock = stock - NEW.cantidad 
    WHERE id = NEW.producto_id;
    
    -- Log del cambio de stock por venta
    INSERT INTO log_stock (
        producto_id, stock_anterior, stock_nuevo, diferencia, motivo
    ) 
    SELECT 
        NEW.producto_id,
        stock + NEW.cantidad,
        stock,
        -NEW.cantidad,
        CONCAT('Venta ID: ', NEW.venta_id)
    FROM productos 
    WHERE id = NEW.producto_id;
    
    -- Actualizar total de la venta
    UPDATE ventas 
    SET total = (
        SELECT SUM(subtotal) 
        FROM detalle_ventas 
        WHERE venta_id = NEW.venta_id
    )
    WHERE id = NEW.venta_id;
END//
DELIMITER ;

-- Trigger: Actualizar estadísticas diarias
DELIMITER //
CREATE TRIGGER after_insert_venta
    AFTER INSERT ON ventas
    FOR EACH ROW
BEGIN
    -- Insertar o actualizar estadísticas del día
    INSERT INTO estadisticas_ventas_diarias (
        fecha, total_ventas, cantidad_ventas, ticket_promedio
    ) VALUES (
        DATE(NEW.fecha_venta), NEW.total, 1, NEW.total
    ) ON DUPLICATE KEY UPDATE
        total_ventas = total_ventas + NEW.total,
        cantidad_ventas = cantidad_ventas + 1,
        ticket_promedio = (total_ventas + NEW.total) / (cantidad_ventas + 1);
END//
DELIMITER ;

-- -----------------------------------------------------------------------------
-- 5. TRIGGERS COMPLEJOS - CASOS AVANZADOS
-- -----------------------------------------------------------------------------

-- Trigger: Control de stock mínimo con alertas
DELIMITER //
CREATE TRIGGER after_update_stock_minimo
    AFTER UPDATE ON productos
    FOR EACH ROW
BEGIN
    DECLARE stock_minimo INT DEFAULT 5;
    DECLARE producto_nombre VARCHAR(100);
    
    -- Si el stock bajó y está por debajo del mínimo
    IF NEW.stock < OLD.stock AND NEW.stock <= stock_minimo THEN
        SELECT nombre INTO producto_nombre FROM productos WHERE id = NEW.id;
        
        -- Crear tabla de alertas si no existe
        CREATE TABLE IF NOT EXISTS alertas_stock (
            id INT PRIMARY KEY AUTO_INCREMENT,
            producto_id INT,
            producto_nombre VARCHAR(100),
            stock_actual INT,
            stock_minimo INT,
            fecha_alerta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            procesada BOOLEAN DEFAULT FALSE
        );
        
        -- Insertar alerta
        INSERT INTO alertas_stock (
            producto_id, producto_nombre, stock_actual, stock_minimo
        ) VALUES (
            NEW.id, producto_nombre, NEW.stock, stock_minimo
        );
    END IF;
END//
DELIMITER ;

-- Trigger: Prevenir eliminación de productos con ventas
DELIMITER //
CREATE TRIGGER before_delete_producto_con_ventas
    BEFORE DELETE ON productos
    FOR EACH ROW
BEGIN
    DECLARE ventas_count INT;
    
    -- Contar ventas del producto
    SELECT COUNT(*) INTO ventas_count
    FROM detalle_ventas
    WHERE producto_id = OLD.id;
    
    -- Prevenir eliminación si tiene ventas
    IF ventas_count > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = CONCAT('No se puede eliminar el producto. Tiene ', 
                                ventas_count, ' ventas registradas');
    END IF;
END//
DELIMITER ;

-- Trigger: Control de precios históricos
DELIMITER //
CREATE TRIGGER after_update_precio_historico
    AFTER UPDATE ON productos
    FOR EACH ROW
BEGIN
    -- Crear tabla de precios históricos si no existe
    CREATE TABLE IF NOT EXISTS precios_historicos (
        id INT PRIMARY KEY AUTO_INCREMENT,
        producto_id INT,
        precio_anterior DECIMAL(10,2),
        precio_nuevo DECIMAL(10,2),
        porcentaje_cambio DECIMAL(5,2),
        fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    -- Si cambió el precio
    IF OLD.precio != NEW.precio THEN
        INSERT INTO precios_historicos (
            producto_id, precio_anterior, precio_nuevo, porcentaje_cambio
        ) VALUES (
            NEW.id, 
            OLD.precio, 
            NEW.precio,
            ROUND(((NEW.precio - OLD.precio) / OLD.precio) * 100, 2)
        );
    END IF;
END//
DELIMITER ;

-- -----------------------------------------------------------------------------
-- 6. DATOS DE PRUEBA Y EJEMPLOS
-- -----------------------------------------------------------------------------

-- Insertar productos de prueba
INSERT INTO productos (nombre, precio, stock, categoria_id) VALUES
('laptop gaming', 1299.99, 10, 1),
('mouse inalámbrico', 29.99, 50, 2),
('teclado mecánico', 89.99, 25, 2),
('monitor 4k', 399.99, 8, 1);

-- Crear una venta de prueba
INSERT INTO ventas (cliente_id) VALUES (1);
SET @venta_id = LAST_INSERT_ID();

-- Agregar detalles de venta
INSERT INTO detalle_ventas (venta_id, producto_id, cantidad, precio_unitario) VALUES
(@venta_id, 1, 1, 1299.99),
(@venta_id, 2, 2, 29.99);

-- Actualizar precio para probar auditoría
UPDATE productos SET precio = 1399.99 WHERE id = 1;

-- Actualizar stock para probar alertas
UPDATE productos SET stock = 3 WHERE id = 2;

-- -----------------------------------------------------------------------------
-- 7. CONSULTAS PARA VERIFICAR TRIGGERS
-- -----------------------------------------------------------------------------

-- Ver auditoría de productos
SELECT * FROM auditoria_productos ORDER BY fecha_modificacion DESC;

-- Ver log de stock
SELECT 
    ls.*,
    p.nombre as producto_nombre
FROM log_stock ls
JOIN productos p ON ls.producto_id = p.id
ORDER BY ls.fecha_cambio DESC;

-- Ver estadísticas diarias
SELECT * FROM estadisticas_ventas_diarias;

-- Ver alertas de stock (si existen)
SELECT * FROM alertas_stock WHERE procesada = FALSE;

-- Ver precios históricos (si existen)
SELECT 
    ph.*,
    p.nombre as producto_nombre
FROM precios_historicos ph
JOIN productos p ON ph.producto_id = p.id
ORDER BY ph.fecha_cambio DESC;

-- -----------------------------------------------------------------------------
-- 8. GESTIÓN DE TRIGGERS
-- -----------------------------------------------------------------------------

-- Listar todos los triggers de la base de datos
SELECT 
    TRIGGER_NAME,
    EVENT_MANIPULATION,
    EVENT_OBJECT_TABLE,
    ACTION_TIMING,
    CREATED
FROM INFORMATION_SCHEMA.TRIGGERS 
WHERE TRIGGER_SCHEMA = 'tienda_triggers'
ORDER BY EVENT_OBJECT_TABLE, ACTION_TIMING, EVENT_MANIPULATION;

-- Mostrar definición de un trigger específico
SHOW CREATE TRIGGER after_insert_detalle_venta;

-- Eliminar un trigger (ejemplo)
-- DROP TRIGGER IF EXISTS after_insert_producto;

-- Deshabilitar/Habilitar triggers (MySQL 8.0+)
-- ALTER TABLE productos DISABLE TRIGGER after_insert_producto;
-- ALTER TABLE productos ENABLE TRIGGER after_insert_producto;

-- -----------------------------------------------------------------------------
-- 9. EJERCICIOS PROPUESTOS
-- -----------------------------------------------------------------------------

/*
EJERCICIO 1: Crear un trigger que registre en una tabla 'log_accesos' 
cada vez que se consulte la tabla productos (usando SELECT).

EJERCICIO 2: Implementar un trigger que calcule automáticamente 
descuentos por volumen en la tabla detalle_ventas.

EJERCICIO 3: Crear un sistema de triggers que mantenga un inventario 
valorizado actualizado automáticamente.

EJERCICIO 4: Implementar triggers que prevengan la venta de productos 
descontinuados o fuera de temporada.

EJERCICIO 5: Crear un sistema de notificaciones automáticas cuando 
se produzcan cambios críticos en el inventario.
*/
