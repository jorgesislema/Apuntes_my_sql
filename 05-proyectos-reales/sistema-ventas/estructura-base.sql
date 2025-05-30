-- =============================================================================
-- SISTEMA DE VENTAS - PROYECTO REAL COMPLETO
-- =============================================================================
-- Autor: [Tu Nombre]
-- Fecha: 28/05/2025
-- Descripción: Base de datos completa para sistema de ventas con e-commerce,
--              inventario, CRM, reportes y análisis avanzado
-- Versión: 1.0
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. CONFIGURACIÓN INICIAL Y CREACIÓN DE BASE DE DATOS
-- -----------------------------------------------------------------------------

-- Crear base de datos
DROP DATABASE IF EXISTS sistema_ventas;
CREATE DATABASE sistema_ventas 
    CHARACTER SET utf8mb4 
    COLLATE utf8mb4_unicode_ci;

USE sistema_ventas;

-- Configuración de variables de sesión
SET @OLD_FOREIGN_KEY_CHECKS = @@FOREIGN_KEY_CHECKS;
SET FOREIGN_KEY_CHECKS = 0;
SET @OLD_SQL_MODE = @@SQL_MODE;
SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';
SET @OLD_AUTOCOMMIT = @@AUTOCOMMIT;
SET AUTOCOMMIT = 0;

-- -----------------------------------------------------------------------------
-- 2. TABLAS MAESTRAS Y CONFIGURACIÓN
-- -----------------------------------------------------------------------------

-- Tabla de países
CREATE TABLE paises (
    id INT PRIMARY KEY AUTO_INCREMENT,
    codigo_iso VARCHAR(3) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    codigo_telefono VARCHAR(10),
    activo BOOLEAN DEFAULT TRUE,
    INDEX idx_codigo (codigo_iso),
    INDEX idx_nombre (nombre)
);

-- Tabla de regiones/estados
CREATE TABLE regiones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    pais_id INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    codigo VARCHAR(10),
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (pais_id) REFERENCES paises(id),
    INDEX idx_pais (pais_id),
    INDEX idx_nombre (nombre)
);

-- Tabla de ciudades
CREATE TABLE ciudades (
    id INT PRIMARY KEY AUTO_INCREMENT,
    region_id INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    codigo_postal VARCHAR(20),
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (region_id) REFERENCES regiones(id),
    INDEX idx_region (region_id),
    INDEX idx_nombre (nombre)
);

-- Tabla de monedas
CREATE TABLE monedas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    codigo_iso VARCHAR(3) UNIQUE NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    simbolo VARCHAR(5),
    tasa_cambio DECIMAL(10,4) DEFAULT 1.0000,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    INDEX idx_codigo (codigo_iso)
);

-- Tabla de categorías de productos
CREATE TABLE categorias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    categoria_padre_id INT,
    imagen_url VARCHAR(500),
    activo BOOLEAN DEFAULT TRUE,
    orden_display INT DEFAULT 0,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (categoria_padre_id) REFERENCES categorias(id),
    INDEX idx_padre (categoria_padre_id),
    INDEX idx_activo (activo),
    INDEX idx_orden (orden_display)
);

-- Tabla de marcas
CREATE TABLE marcas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    descripcion TEXT,
    logo_url VARCHAR(500),
    sitio_web VARCHAR(255),
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_nombre (nombre),
    INDEX idx_activo (activo)
);

-- Tabla de proveedores
CREATE TABLE proveedores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    nombre_comercial VARCHAR(150) NOT NULL,
    razon_social VARCHAR(200),
    rfc_nit VARCHAR(30),
    telefono VARCHAR(20),
    email VARCHAR(100),
    sitio_web VARCHAR(255),
    contacto_principal VARCHAR(100),
    ciudad_id INT,
    direccion TEXT,
    calificacion DECIMAL(3,2) DEFAULT 0.00,
    terminos_pago ENUM('CONTADO', '15_DIAS', '30_DIAS', '60_DIAS', '90_DIAS') DEFAULT '30_DIAS',
    descuento_proveedor DECIMAL(5,2) DEFAULT 0.00,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (ciudad_id) REFERENCES ciudades(id),
    INDEX idx_codigo (codigo),
    INDEX idx_nombre (nombre_comercial),
    INDEX idx_activo (activo),
    INDEX idx_ciudad (ciudad_id)
);

-- -----------------------------------------------------------------------------
-- 3. GESTIÓN DE PRODUCTOS E INVENTARIO
-- -----------------------------------------------------------------------------

-- Tabla principal de productos
CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    sku VARCHAR(50) UNIQUE NOT NULL,
    codigo_barras VARCHAR(50) UNIQUE,
    nombre VARCHAR(200) NOT NULL,
    descripcion_corta VARCHAR(500),
    descripcion_larga TEXT,
    categoria_id INT NOT NULL,
    marca_id INT,
    proveedor_principal_id INT,
    precio_compra DECIMAL(12,2),
    precio_venta DECIMAL(12,2) NOT NULL,
    precio_oferta DECIMAL(12,2),
    margen_utilidad DECIMAL(5,2),
    peso DECIMAL(8,3),
    dimensiones JSON, -- {alto, ancho, largo}
    color VARCHAR(50),
    talla VARCHAR(20),
    material VARCHAR(100),
    imagen_principal VARCHAR(500),
    galeria_imagenes JSON,
    especificaciones JSON,
    stock_actual INT DEFAULT 0,
    stock_minimo INT DEFAULT 5,
    stock_maximo INT DEFAULT 1000,
    punto_reorden INT DEFAULT 10,
    es_inventariable BOOLEAN DEFAULT TRUE,
    requiere_serie BOOLEAN DEFAULT FALSE,
    permite_venta_sin_stock BOOLEAN DEFAULT FALSE,
    activo BOOLEAN DEFAULT TRUE,
    visible_web BOOLEAN DEFAULT TRUE,
    destacado BOOLEAN DEFAULT FALSE,
    nuevo BOOLEAN DEFAULT FALSE,
    meta_title VARCHAR(200),
    meta_description VARCHAR(500),
    slug VARCHAR(200),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    usuario_creacion VARCHAR(100),
    usuario_actualizacion VARCHAR(100),
    FOREIGN KEY (categoria_id) REFERENCES categorias(id),
    FOREIGN KEY (marca_id) REFERENCES marcas(id),
    FOREIGN KEY (proveedor_principal_id) REFERENCES proveedores(id),
    INDEX idx_sku (sku),
    INDEX idx_codigo_barras (codigo_barras),
    INDEX idx_nombre (nombre),
    INDEX idx_categoria (categoria_id),
    INDEX idx_marca (marca_id),
    INDEX idx_proveedor (proveedor_principal_id),
    INDEX idx_precio (precio_venta),
    INDEX idx_activo_visible (activo, visible_web),
    INDEX idx_stock (stock_actual),
    INDEX idx_destacado (destacado),
    FULLTEXT idx_busqueda (nombre, descripcion_corta, descripcion_larga)
);

-- Tabla de variantes de productos (tallas, colores, etc.)
CREATE TABLE producto_variantes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    producto_id INT NOT NULL,
    sku_variante VARCHAR(50) UNIQUE NOT NULL,
    codigo_barras VARCHAR(50) UNIQUE,
    nombre_variante VARCHAR(200),
    atributos JSON, -- {color: "rojo", talla: "M"}
    precio_diferencial DECIMAL(10,2) DEFAULT 0.00,
    stock_actual INT DEFAULT 0,
    imagen_url VARCHAR(500),
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE,
    INDEX idx_producto (producto_id),
    INDEX idx_sku (sku_variante),
    INDEX idx_activo (activo)
);

-- Tabla de movimientos de inventario
CREATE TABLE movimientos_inventario (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    producto_id INT NOT NULL,
    variante_id INT,
    tipo_movimiento ENUM('ENTRADA', 'SALIDA', 'AJUSTE', 'TRANSFERENCIA') NOT NULL,
    motivo ENUM('COMPRA', 'VENTA', 'DEVOLUCION', 'AJUSTE_INVENTARIO', 'TRANSFERENCIA', 'MERMA', 'REGALO') NOT NULL,
    cantidad INT NOT NULL,
    costo_unitario DECIMAL(12,2),
    precio_unitario DECIMAL(12,2),
    stock_anterior INT NOT NULL,
    stock_posterior INT NOT NULL,
    referencia_documento VARCHAR(100), -- ID de venta, compra, etc.
    tipo_documento ENUM('VENTA', 'COMPRA', 'AJUSTE', 'TRANSFERENCIA'),
    almacen_origen_id INT,
    almacen_destino_id INT,
    observaciones TEXT,
    fecha_movimiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario VARCHAR(100),
    FOREIGN KEY (producto_id) REFERENCES productos(id),
    FOREIGN KEY (variante_id) REFERENCES producto_variantes(id),
    INDEX idx_producto (producto_id),
    INDEX idx_tipo (tipo_movimiento),
    INDEX idx_motivo (motivo),
    INDEX idx_fecha (fecha_movimiento),
    INDEX idx_documento (tipo_documento, referencia_documento)
);

-- Tabla de almacenes
CREATE TABLE almacenes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    tipo ENUM('PRINCIPAL', 'SUCURSAL', 'VIRTUAL', 'CONSIGNACION') DEFAULT 'PRINCIPAL',
    ciudad_id INT,
    direccion TEXT,
    responsable VARCHAR(100),
    telefono VARCHAR(20),
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ciudad_id) REFERENCES ciudades(id),
    INDEX idx_codigo (codigo),
    INDEX idx_tipo (tipo),
    INDEX idx_activo (activo)
);

-- Tabla de stock por almacén
CREATE TABLE stock_almacenes (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    almacen_id INT NOT NULL,
    producto_id INT NOT NULL,
    variante_id INT,
    stock_actual INT DEFAULT 0,
    stock_reservado INT DEFAULT 0,
    stock_disponible INT GENERATED ALWAYS AS (stock_actual - stock_reservado) STORED,
    costo_promedio DECIMAL(12,2),
    fecha_ultima_entrada TIMESTAMP,
    fecha_ultima_salida TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (almacen_id) REFERENCES almacenes(id),
    FOREIGN KEY (producto_id) REFERENCES productos(id),
    FOREIGN KEY (variante_id) REFERENCES producto_variantes(id),
    UNIQUE KEY unique_stock (almacen_id, producto_id, variante_id),
    INDEX idx_almacen (almacen_id),
    INDEX idx_producto (producto_id),
    INDEX idx_stock (stock_actual),
    INDEX idx_disponible (stock_disponible)
);

-- -----------------------------------------------------------------------------
-- 4. GESTIÓN DE CLIENTES Y CRM
-- -----------------------------------------------------------------------------

-- Tabla de tipos de cliente
CREATE TABLE tipos_cliente (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT,
    descuento_por_defecto DECIMAL(5,2) DEFAULT 0.00,
    limite_credito DECIMAL(12,2) DEFAULT 0.00,
    dias_credito INT DEFAULT 0,
    activo BOOLEAN DEFAULT TRUE,
    INDEX idx_nombre (nombre)
);

-- Tabla principal de clientes
CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    tipo_cliente_id INT NOT NULL,
    tipo_persona ENUM('FISICA', 'MORAL') DEFAULT 'FISICA',
    nombre VARCHAR(100),
    apellido_paterno VARCHAR(100),
    apellido_materno VARCHAR(100),
    razon_social VARCHAR(200),
    nombre_comercial VARCHAR(150),
    rfc_nit VARCHAR(30),
    curp VARCHAR(20),
    fecha_nacimiento DATE,
    genero ENUM('M', 'F', 'OTRO'),
    telefono_principal VARCHAR(20),
    telefono_secundario VARCHAR(20),
    email_principal VARCHAR(150),
    email_secundario VARCHAR(150),
    ciudad_id INT,
    direccion_principal TEXT,
    codigo_postal VARCHAR(20),
    referencia_direccion TEXT,
    ocupacion VARCHAR(100),
    empresa VARCHAR(150),
    estado_civil ENUM('SOLTERO', 'CASADO', 'DIVORCIADO', 'VIUDO', 'UNION_LIBRE'),
    limite_credito DECIMAL(12,2) DEFAULT 0.00,
    credito_usado DECIMAL(12,2) DEFAULT 0.00,
    credito_disponible DECIMAL(12,2) GENERATED ALWAYS AS (limite_credito - credito_usado) STORED,
    fecha_ultimo_pago TIMESTAMP,
    dias_vencido INT DEFAULT 0,
    calificacion_credito ENUM('EXCELENTE', 'BUENO', 'REGULAR', 'MALO') DEFAULT 'BUENO',
    descuento_especial DECIMAL(5,2) DEFAULT 0.00,
    vendedor_asignado_id INT,
    origen_cliente ENUM('TIENDA_FISICA', 'WEB', 'TELEFONO', 'REFERIDO', 'REDES_SOCIALES', 'PUBLICIDAD') DEFAULT 'TIENDA_FISICA',
    activo BOOLEAN DEFAULT TRUE,
    permite_marketing BOOLEAN DEFAULT TRUE,
    observaciones TEXT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    usuario_creacion VARCHAR(100),
    FOREIGN KEY (tipo_cliente_id) REFERENCES tipos_cliente(id),
    FOREIGN KEY (ciudad_id) REFERENCES ciudades(id),
    INDEX idx_codigo (codigo),
    INDEX idx_tipo (tipo_cliente_id),
    INDEX idx_nombres (nombre, apellido_paterno),
    INDEX idx_razon_social (razon_social),
    INDEX idx_email (email_principal),
    INDEX idx_telefono (telefono_principal),
    INDEX idx_activo (activo),
    INDEX idx_vendedor (vendedor_asignado_id),
    INDEX idx_credito (calificacion_credito),
    FULLTEXT idx_busqueda_cliente (nombre, apellido_paterno, apellido_materno, razon_social, email_principal)
);

-- Tabla de direcciones adicionales de clientes
CREATE TABLE cliente_direcciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    alias VARCHAR(50), -- "Casa", "Oficina", "Trabajo"
    tipo ENUM('FACTURACION', 'ENVIO', 'AMBAS') DEFAULT 'AMBAS',
    contacto VARCHAR(100),
    telefono VARCHAR(20),
    ciudad_id INT,
    direccion TEXT NOT NULL,
    codigo_postal VARCHAR(20),
    referencia TEXT,
    es_principal BOOLEAN DEFAULT FALSE,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE,
    FOREIGN KEY (ciudad_id) REFERENCES ciudades(id),
    INDEX idx_cliente (cliente_id),
    INDEX idx_tipo (tipo),
    INDEX idx_principal (es_principal)
);

-- Tabla de historial de interacciones con clientes
CREATE TABLE cliente_interacciones (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    tipo_interaccion ENUM('LLAMADA', 'EMAIL', 'VISITA', 'WHATSAPP', 'REDES_SOCIALES', 'OTRO') NOT NULL,
    canal ENUM('TELEFONO', 'EMAIL', 'PRESENCIAL', 'CHAT', 'WHATSAPP', 'FACEBOOK', 'INSTAGRAM') NOT NULL,
    asunto VARCHAR(200),
    descripcion TEXT,
    resultado ENUM('EXITOSO', 'PENDIENTE', 'SIN_RESPUESTA', 'RECHAZADO'),
    seguimiento_requerido BOOLEAN DEFAULT FALSE,
    fecha_seguimiento TIMESTAMP,
    usuario VARCHAR(100),
    fecha_interaccion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    INDEX idx_cliente (cliente_id),
    INDEX idx_tipo (tipo_interaccion),
    INDEX idx_fecha (fecha_interaccion),
    INDEX idx_seguimiento (seguimiento_requerido, fecha_seguimiento)
);

-- -----------------------------------------------------------------------------
-- 5. SISTEMA DE VENTAS Y PEDIDOS
-- -----------------------------------------------------------------------------

-- Tabla de vendedores/empleados
CREATE TABLE vendedores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido_paterno VARCHAR(100),
    apellido_materno VARCHAR(100),
    email VARCHAR(150),
    telefono VARCHAR(20),
    sucursal_id INT,
    porcentaje_comision DECIMAL(5,2) DEFAULT 0.00,
    meta_mensual DECIMAL(12,2) DEFAULT 0.00,
    activo BOOLEAN DEFAULT TRUE,
    fecha_ingreso DATE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_codigo (codigo),
    INDEX idx_nombre (nombre),
    INDEX idx_activo (activo)
);

-- Tabla de métodos de pago
CREATE TABLE metodos_pago (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    tipo ENUM('EFECTIVO', 'TARJETA_CREDITO', 'TARJETA_DEBITO', 'TRANSFERENCIA', 'CHEQUE', 'VALE', 'CREDITO') NOT NULL,
    requiere_autorizacion BOOLEAN DEFAULT FALSE,
    cargo_adicional DECIMAL(5,2) DEFAULT 0.00,
    descuento DECIMAL(5,2) DEFAULT 0.00,
    activo BOOLEAN DEFAULT TRUE,
    orden_display INT DEFAULT 0,
    INDEX idx_tipo (tipo),
    INDEX idx_activo (activo)
);

-- Tabla principal de ventas
CREATE TABLE ventas (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    numero_venta VARCHAR(30) UNIQUE NOT NULL,
    tipo_venta ENUM('MOSTRADOR', 'CREDITO', 'APARTADO', 'PEDIDO', 'COTIZACION') DEFAULT 'MOSTRADOR',
    estado ENUM('PENDIENTE', 'CONFIRMADA', 'PAGADA', 'ENVIADA', 'ENTREGADA', 'CANCELADA', 'DEVUELTA') DEFAULT 'PENDIENTE',
    cliente_id INT NOT NULL,
    vendedor_id INT,
    sucursal_id INT,
    moneda_id INT DEFAULT 1,
    tasa_cambio DECIMAL(10,4) DEFAULT 1.0000,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    descuento_porcentaje DECIMAL(5,2) DEFAULT 0.00,
    descuento_monto DECIMAL(12,2) DEFAULT 0.00,
    impuestos DECIMAL(12,2) DEFAULT 0.00,
    envio DECIMAL(10,2) DEFAULT 0.00,
    total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total_costo DECIMAL(12,2) DEFAULT 0.00,
    utilidad DECIMAL(12,2) GENERATED ALWAYS AS (total - total_costo) STORED,
    margen_porcentaje DECIMAL(5,2) GENERATED ALWAYS AS (
        CASE WHEN total > 0 THEN ((total - total_costo) / total * 100) ELSE 0 END
    ) STORED,
    metodo_pago_id INT,
    referencia_pago VARCHAR(100),
    fecha_venta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_vencimiento TIMESTAMP,
    fecha_entrega_estimada TIMESTAMP,
    fecha_entrega_real TIMESTAMP,
    direccion_entrega JSON,
    observaciones TEXT,
    observaciones_internas TEXT,
    origen ENUM('TIENDA_FISICA', 'WEB', 'TELEFONO', 'WHATSAPP', 'APP_MOVIL') DEFAULT 'TIENDA_FISICA',
    canal_venta ENUM('MOSTRADOR', 'ONLINE', 'TELEFONO', 'WHATSAPP', 'MARKETPLACE') DEFAULT 'MOSTRADOR',
    usuario_creacion VARCHAR(100),
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    FOREIGN KEY (vendedor_id) REFERENCES vendedores(id),
    FOREIGN KEY (moneda_id) REFERENCES monedas(id),
    FOREIGN KEY (metodo_pago_id) REFERENCES metodos_pago(id),
    INDEX idx_numero (numero_venta),
    INDEX idx_cliente (cliente_id),
    INDEX idx_vendedor (vendedor_id),
    INDEX idx_fecha (fecha_venta),
    INDEX idx_estado (estado),
    INDEX idx_tipo (tipo_venta),
    INDEX idx_total (total),
    INDEX idx_origen (origen),
    INDEX idx_periodo (DATE(fecha_venta))
);

-- Tabla de detalle de ventas
CREATE TABLE venta_detalles (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    venta_id BIGINT NOT NULL,
    producto_id INT NOT NULL,
    variante_id INT,
    sku VARCHAR(50),
    nombre_producto VARCHAR(200),
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(12,2) NOT NULL,
    precio_original DECIMAL(12,2),
    descuento_linea DECIMAL(12,2) DEFAULT 0.00,
    subtotal DECIMAL(12,2) NOT NULL,
    costo_unitario DECIMAL(12,2),
    costo_total DECIMAL(12,2),
    utilidad_linea DECIMAL(12,2) GENERATED ALWAYS AS (subtotal - costo_total) STORED,
    impuesto_porcentaje DECIMAL(5,2) DEFAULT 0.00,
    impuesto_monto DECIMAL(12,2) DEFAULT 0.00,
    numero_serie VARCHAR(100),
    observaciones TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (venta_id) REFERENCES ventas(id) ON DELETE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES productos(id),
    FOREIGN KEY (variante_id) REFERENCES producto_variantes(id),
    INDEX idx_venta (venta_id),
    INDEX idx_producto (producto_id),
    INDEX idx_sku (sku)
);

-- Tabla de pagos recibidos
CREATE TABLE venta_pagos (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    venta_id BIGINT NOT NULL,
    numero_pago VARCHAR(30) UNIQUE NOT NULL,
    metodo_pago_id INT NOT NULL,
    monto DECIMAL(12,2) NOT NULL,
    moneda_id INT DEFAULT 1,
    tasa_cambio DECIMAL(10,4) DEFAULT 1.0000,
    referencia VARCHAR(100),
    numero_autorizacion VARCHAR(50),
    banco VARCHAR(100),
    fecha_pago TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    observaciones TEXT,
    usuario_registro VARCHAR(100),
    FOREIGN KEY (venta_id) REFERENCES ventas(id),
    FOREIGN KEY (metodo_pago_id) REFERENCES metodos_pago(id),
    FOREIGN KEY (moneda_id) REFERENCES monedas(id),
    INDEX idx_venta (venta_id),
    INDEX idx_metodo (metodo_pago_id),
    INDEX idx_fecha (fecha_pago),
    INDEX idx_monto (monto)
);

-- Tabla de envíos
CREATE TABLE envios (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    venta_id BIGINT NOT NULL,
    numero_envio VARCHAR(30) UNIQUE NOT NULL,
    paqueteria VARCHAR(100),
    numero_guia VARCHAR(100),
    estado ENUM('PREPARANDO', 'ENVIADO', 'EN_TRANSITO', 'ENTREGADO', 'DEVUELTO', 'PERDIDO') DEFAULT 'PREPARANDO',
    costo_envio DECIMAL(10,2),
    peso_total DECIMAL(8,3),
    direccion_completa JSON,
    fecha_envio TIMESTAMP,
    fecha_entrega_estimada TIMESTAMP,
    fecha_entrega_real TIMESTAMP,
    observaciones TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_creacion VARCHAR(100),
    FOREIGN KEY (venta_id) REFERENCES ventas(id),
    INDEX idx_venta (venta_id),
    INDEX idx_numero (numero_envio),
    INDEX idx_estado (estado),
    INDEX idx_fecha_envio (fecha_envio)
);

-- -----------------------------------------------------------------------------
-- 6. TRIGGERS PARA AUTOMATIZACIÓN
-- -----------------------------------------------------------------------------

-- Trigger para actualizar stock después de venta
DELIMITER //
CREATE TRIGGER after_insert_venta_detalle
    AFTER INSERT ON venta_detalles
    FOR EACH ROW
BEGIN
    -- Actualizar stock del producto principal
    UPDATE productos 
    SET stock_actual = stock_actual - NEW.cantidad
    WHERE id = NEW.producto_id;
    
    -- Actualizar stock de variante si aplica
    IF NEW.variante_id IS NOT NULL THEN
        UPDATE producto_variantes 
        SET stock_actual = stock_actual - NEW.cantidad
        WHERE id = NEW.variante_id;
    END IF;
    
    -- Registrar movimiento de inventario
    INSERT INTO movimientos_inventario (
        producto_id, variante_id, tipo_movimiento, motivo, cantidad,
        precio_unitario, stock_anterior, stock_posterior,
        referencia_documento, tipo_documento, usuario
    ) 
    SELECT 
        NEW.producto_id,
        NEW.variante_id,
        'SALIDA',
        'VENTA',
        NEW.cantidad,
        NEW.precio_unitario,
        stock_actual + NEW.cantidad,
        stock_actual,
        NEW.venta_id,
        'VENTA',
        (SELECT usuario_creacion FROM ventas WHERE id = NEW.venta_id)
    FROM productos 
    WHERE id = NEW.producto_id;
END//
DELIMITER ;

-- Trigger para calcular totales de venta
DELIMITER //
CREATE TRIGGER after_insert_update_venta_detalle_totales
    AFTER INSERT ON venta_detalles
    FOR EACH ROW
BEGIN
    UPDATE ventas 
    SET 
        subtotal = (
            SELECT SUM(subtotal) 
            FROM venta_detalles 
            WHERE venta_id = NEW.venta_id
        ),
        total_costo = (
            SELECT SUM(IFNULL(costo_total, 0))
            FROM venta_detalles 
            WHERE venta_id = NEW.venta_id
        )
    WHERE id = NEW.venta_id;
    
    -- Recalcular total con descuentos e impuestos
    UPDATE ventas 
    SET total = subtotal - descuento_monto + impuestos + envio
    WHERE id = NEW.venta_id;
END//
DELIMITER ;

-- Trigger para generar número de venta automático
DELIMITER //
CREATE TRIGGER before_insert_venta
    BEFORE INSERT ON ventas
    FOR EACH ROW
BEGIN
    IF NEW.numero_venta IS NULL OR NEW.numero_venta = '' THEN
        SET NEW.numero_venta = CONCAT(
            'V',
            DATE_FORMAT(NOW(), '%Y%m%d'),
            '-',
            LPAD((
                SELECT IFNULL(MAX(SUBSTRING(numero_venta, -6)), 0) + 1
                FROM ventas 
                WHERE DATE(fecha_venta) = CURDATE()
            ), 6, '0')
        );
    END IF;
END//
DELIMITER ;

-- Trigger para alertas de stock bajo
DELIMITER //
CREATE TRIGGER after_update_stock_alerta
    AFTER UPDATE ON productos
    FOR EACH ROW
BEGIN
    IF NEW.stock_actual <= NEW.punto_reorden AND OLD.stock_actual > NEW.punto_reorden THEN
        -- Crear tabla de alertas si no existe
        CREATE TABLE IF NOT EXISTS alertas_stock (
            id INT PRIMARY KEY AUTO_INCREMENT,
            producto_id INT,
            tipo_alerta ENUM('STOCK_BAJO', 'STOCK_AGOTADO'),
            stock_actual INT,
            punto_reorden INT,
            fecha_alerta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            atendida BOOLEAN DEFAULT FALSE,
            INDEX idx_producto (producto_id),
            INDEX idx_fecha (fecha_alerta),
            INDEX idx_atendida (atendida)
        );
        
        INSERT INTO alertas_stock (producto_id, tipo_alerta, stock_actual, punto_reorden)
        VALUES (NEW.id, 'STOCK_BAJO', NEW.stock_actual, NEW.punto_reorden);
    END IF;
END//
DELIMITER ;

-- -----------------------------------------------------------------------------
-- 7. VISTAS PARA REPORTES Y CONSULTAS
-- -----------------------------------------------------------------------------

-- Vista de productos con información completa
CREATE VIEW vista_productos_completa AS
SELECT 
    p.id,
    p.sku,
    p.codigo_barras,
    p.nombre,
    p.descripcion_corta,
    c.nombre as categoria,
    m.nombre as marca,
    prov.nombre_comercial as proveedor,
    p.precio_compra,
    p.precio_venta,
    p.precio_oferta,
    p.stock_actual,
    p.stock_minimo,
    p.punto_reorden,
    p.activo,
    p.visible_web,
    p.destacado,
    CASE 
        WHEN p.stock_actual <= 0 THEN 'AGOTADO'
        WHEN p.stock_actual <= p.punto_reorden THEN 'STOCK_BAJO'
        ELSE 'DISPONIBLE'
    END as estado_stock,
    p.fecha_creacion,
    p.fecha_actualizacion
FROM productos p
LEFT JOIN categorias c ON p.categoria_id = c.id
LEFT JOIN marcas m ON p.marca_id = m.id
LEFT JOIN proveedores prov ON p.proveedor_principal_id = prov.id;

-- Vista de ventas con información del cliente
CREATE VIEW vista_ventas_completa AS
SELECT 
    v.id,
    v.numero_venta,
    v.tipo_venta,
    v.estado,
    v.fecha_venta,
    CONCAT_WS(' ', c.nombre, c.apellido_paterno, c.apellido_materno) as cliente_nombre,
    c.razon_social as cliente_empresa,
    c.email_principal as cliente_email,
    c.telefono_principal as cliente_telefono,
    CONCAT_WS(' ', vend.nombre, vend.apellido_paterno) as vendedor_nombre,
    v.subtotal,
    v.descuento_monto,
    v.impuestos,
    v.total,
    v.total_costo,
    v.utilidad,
    v.margen_porcentaje,
    mp.nombre as metodo_pago,
    v.origen,
    v.canal_venta
FROM ventas v
INNER JOIN clientes c ON v.cliente_id = c.id
LEFT JOIN vendedores vend ON v.vendedor_id = vend.id
LEFT JOIN metodos_pago mp ON v.metodo_pago_id = mp.id;

-- Vista de análisis de ventas por período
CREATE VIEW vista_ventas_analisis AS
SELECT 
    DATE(v.fecha_venta) as fecha,
    COUNT(*) as total_ventas,
    SUM(v.total) as monto_total,
    AVG(v.total) as ticket_promedio,
    SUM(v.utilidad) as utilidad_total,
    AVG(v.margen_porcentaje) as margen_promedio,
    COUNT(DISTINCT v.cliente_id) as clientes_unicos,
    COUNT(DISTINCT v.vendedor_id) as vendedores_activos
FROM ventas v
WHERE v.estado NOT IN ('CANCELADA', 'DEVUELTA')
GROUP BY DATE(v.fecha_venta);

-- Vista de productos más vendidos
CREATE VIEW vista_productos_mas_vendidos AS
SELECT 
    p.id,
    p.sku,
    p.nombre,
    c.nombre as categoria,
    SUM(vd.cantidad) as total_vendido,
    SUM(vd.subtotal) as monto_vendido,
    COUNT(DISTINCT vd.venta_id) as numero_ventas,
    AVG(vd.precio_unitario) as precio_promedio
FROM productos p
INNER JOIN venta_detalles vd ON p.id = vd.producto_id
INNER JOIN ventas v ON vd.venta_id = v.id
INNER JOIN categorias c ON p.categoria_id = c.id
WHERE v.estado NOT IN ('CANCELADA', 'DEVUELTA')
GROUP BY p.id, p.sku, p.nombre, c.nombre;

-- Vista de clientes top
CREATE VIEW vista_clientes_top AS
SELECT 
    c.id,
    c.codigo,
    CASE 
        WHEN c.tipo_persona = 'FISICA' THEN 
            CONCAT_WS(' ', c.nombre, c.apellido_paterno, c.apellido_materno)
        ELSE c.razon_social
    END as nombre_completo,
    c.email_principal,
    c.telefono_principal,
    COUNT(v.id) as total_compras,
    SUM(v.total) as monto_total_compras,
    AVG(v.total) as ticket_promedio,
    MAX(v.fecha_venta) as ultima_compra,
    DATEDIFF(CURDATE(), MAX(v.fecha_venta)) as dias_sin_comprar
FROM clientes c
INNER JOIN ventas v ON c.id = v.cliente_id
WHERE v.estado NOT IN ('CANCELADA', 'DEVUELTA')
GROUP BY c.id, c.codigo, nombre_completo, c.email_principal, c.telefono_principal;

-- -----------------------------------------------------------------------------
-- 8. DATOS DE EJEMPLO
-- -----------------------------------------------------------------------------

-- Insertar datos básicos
INSERT INTO paises (codigo_iso, nombre, codigo_telefono) VALUES 
('MEX', 'México', '+52'),
('USA', 'Estados Unidos', '+1'),
('ESP', 'España', '+34');

INSERT INTO regiones (pais_id, nombre, codigo) VALUES 
(1, 'Ciudad de México', 'CDMX'),
(1, 'Jalisco', 'JAL'),
(1, 'Nuevo León', 'NL');

INSERT INTO ciudades (region_id, nombre, codigo_postal) VALUES 
(1, 'Ciudad de México', '01000'),
(2, 'Guadalajara', '44100'),
(3, 'Monterrey', '64000');

INSERT INTO monedas (codigo_iso, nombre, simbolo, tasa_cambio) VALUES 
('MXN', 'Peso Mexicano', '$', 1.0000),
('USD', 'Dólar Americano', 'USD$', 17.50),
('EUR', 'Euro', '€', 19.25);

INSERT INTO categorias (nombre, descripcion, categoria_padre_id) VALUES 
('Electrónicos', 'Productos electrónicos y tecnología', NULL),
('Smartphones', 'Teléfonos inteligentes', 1),
('Laptops', 'Computadoras portátiles', 1),
('Ropa', 'Prendas de vestir', NULL),
('Hombre', 'Ropa para hombre', 4),
('Mujer', 'Ropa para mujer', 4);

INSERT INTO marcas (nombre, descripcion, sitio_web) VALUES 
('Apple', 'Productos Apple Inc.', 'https://apple.com'),
('Samsung', 'Productos Samsung Electronics', 'https://samsung.com'),
('Nike', 'Ropa deportiva Nike', 'https://nike.com'),
('Adidas', 'Ropa deportiva Adidas', 'https://adidas.com');

INSERT INTO tipos_cliente (nombre, descripcion, descuento_por_defecto, limite_credito, dias_credito) VALUES 
('Público General', 'Clientes regulares', 0.00, 0.00, 0),
('Mayorista', 'Clientes mayoristas', 10.00, 50000.00, 30),
('VIP', 'Clientes preferenciales', 5.00, 25000.00, 15),
('Empleado', 'Empleados de la empresa', 15.00, 10000.00, 30);

INSERT INTO metodos_pago (nombre, tipo, cargo_adicional, descuento) VALUES 
('Efectivo', 'EFECTIVO', 0.00, 2.00),
('Tarjeta de Crédito', 'TARJETA_CREDITO', 3.50, 0.00),
('Tarjeta de Débito', 'TARJETA_DEBITO', 1.50, 0.00),
('Transferencia', 'TRANSFERENCIA', 0.00, 1.00),
('Crédito 30 días', 'CREDITO', 0.00, 0.00);

-- Restaurar configuración
SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;
SET SQL_MODE = @OLD_SQL_MODE;
SET AUTOCOMMIT = @OLD_AUTOCOMMIT;
COMMIT;

-- -----------------------------------------------------------------------------
-- 9. ÍNDICES ADICIONALES PARA PERFORMANCE
-- -----------------------------------------------------------------------------

-- Índices compuestos para consultas frecuentes
CREATE INDEX idx_ventas_fecha_estado ON ventas(fecha_venta, estado);
CREATE INDEX idx_ventas_cliente_fecha ON ventas(cliente_id, fecha_venta);
CREATE INDEX idx_productos_categoria_activo ON productos(categoria_id, activo, visible_web);
CREATE INDEX idx_movimientos_producto_fecha ON movimientos_inventario(producto_id, fecha_movimiento);
CREATE INDEX idx_clientes_activo_tipo ON clientes(activo, tipo_cliente_id);

-- Índices para reportes de análisis
CREATE INDEX idx_venta_detalles_producto_fecha ON venta_detalles(producto_id, (SELECT fecha_venta FROM ventas WHERE id = venta_id));

SELECT 'Base de datos SISTEMA DE VENTAS creada exitosamente' as resultado;
