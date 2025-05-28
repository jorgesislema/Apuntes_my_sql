-- =====================================================
-- SISTEMA DE VENTAS AVANZADO - DATOS DE MUESTRA
-- =====================================================
-- Descripción: Datos de prueba para un sistema completo de ventas
-- Autor: MySQL Advanced Course
-- Fecha: 2025
-- =====================================================

USE sistema_ventas_avanzado;

-- =====================================================
-- INSERTAR DATOS DE REGIONES Y PAÍSES
-- =====================================================

INSERT INTO regiones (nombre, descripcion) VALUES
('América del Norte', 'Región de América del Norte'),
('América Latina', 'Región de América Latina'),
('Europa', 'Región de Europa'),
('Asia-Pacífico', 'Región de Asia y Pacífico'),
('Medio Oriente', 'Región de Medio Oriente y África');

INSERT INTO paises (nombre, codigo_iso, region_id) VALUES
('Estados Unidos', 'US', 1),
('Canadá', 'CA', 1),
('México', 'MX', 2),
('Brasil', 'BR', 2),
('Argentina', 'AR', 2),
('España', 'ES', 3),
('Francia', 'FR', 3),
('Alemania', 'DE', 3),
('Reino Unido', 'GB', 3),
('Japón', 'JP', 4),
('China', 'CN', 4),
('Australia', 'AU', 4),
('Emiratos Árabes Unidos', 'AE', 5);

-- =====================================================
-- INSERTAR CIUDADES
-- =====================================================

INSERT INTO ciudades (nombre, pais_id, zona_horaria) VALUES
-- Estados Unidos
('Nueva York', 1, 'America/New_York'),
('Los Ángeles', 1, 'America/Los_Angeles'),
('Chicago', 1, 'America/Chicago'),
-- Canadá
('Toronto', 2, 'America/Toronto'),
('Vancouver', 2, 'America/Vancouver'),
-- México
('Ciudad de México', 3, 'America/Mexico_City'),
('Guadalajara', 3, 'America/Mexico_City'),
-- Brasil
('São Paulo', 4, 'America/Sao_Paulo'),
('Río de Janeiro', 4, 'America/Sao_Paulo'),
-- España
('Madrid', 6, 'Europe/Madrid'),
('Barcelona', 6, 'Europe/Madrid'),
-- Francia
('París', 7, 'Europe/Paris'),
-- Alemania
('Berlín', 8, 'Europe/Berlin'),
('Múnich', 8, 'Europe/Berlin'),
-- Reino Unido
('Londres', 9, 'Europe/London'),
-- Japón
('Tokio', 10, 'Asia/Tokyo'),
('Osaka', 10, 'Asia/Tokyo'),
-- China
('Pekín', 11, 'Asia/Shanghai'),
('Shanghái', 11, 'Asia/Shanghai'),
-- Australia
('Sídney', 12, 'Australia/Sydney'),
('Melbourne', 12, 'Australia/Melbourne');

-- =====================================================
-- INSERTAR CATEGORÍAS DE PRODUCTOS
-- =====================================================

INSERT INTO categorias (nombre, descripcion, categoria_padre_id) VALUES
-- Categorías principales
('Electrónicos', 'Productos electrónicos y tecnológicos', NULL),
('Ropa y Accesorios', 'Vestimenta y accesorios de moda', NULL),
('Hogar y Jardín', 'Productos para el hogar y jardín', NULL),
('Deportes', 'Artículos deportivos y fitness', NULL),
('Libros y Medios', 'Libros, música y medios digitales', NULL),

-- Subcategorías de Electrónicos
('Smartphones', 'Teléfonos inteligentes', 1),
('Laptops', 'Computadoras portátiles', 1),
('Tablets', 'Tabletas electrónicas', 1),
('Audio', 'Equipos de audio y sonido', 1),
('Gaming', 'Videojuegos y consolas', 1),

-- Subcategorías de Ropa
('Ropa Masculina', 'Ropa para hombres', 2),
('Ropa Femenina', 'Ropa para mujeres', 2),
('Calzado', 'Zapatos y calzado deportivo', 2),
('Accesorios', 'Bolsos, carteras y accesorios', 2),

-- Subcategorías de Hogar
('Muebles', 'Muebles para el hogar', 3),
('Decoración', 'Artículos decorativos', 3),
('Electrodomésticos', 'Aparatos eléctricos para el hogar', 3),

-- Subcategorías de Deportes
('Fitness', 'Equipos de ejercicio y gimnasio', 4),
('Deportes de Equipo', 'Fútbol, básquet, etc.', 4),
('Deportes Extremos', 'Skateboard, surf, etc.', 4);

-- =====================================================
-- INSERTAR MARCAS
-- =====================================================

INSERT INTO marcas (nombre, descripcion, pais_origen) VALUES
-- Marcas de Electrónicos
('Apple', 'Tecnología innovadora', 'Estados Unidos'),
('Samsung', 'Electrónicos y tecnología', 'Corea del Sur'),
('Sony', 'Entretenimiento y tecnología', 'Japón'),
('Microsoft', 'Software y hardware', 'Estados Unidos'),
('Dell', 'Computadoras y tecnología', 'Estados Unidos'),
('HP', 'Tecnología e impresión', 'Estados Unidos'),
('Lenovo', 'Computadoras personales', 'China'),
('Nintendo', 'Videojuegos y entretenimiento', 'Japón'),

-- Marcas de Ropa
('Nike', 'Ropa deportiva y calzado', 'Estados Unidos'),
('Adidas', 'Ropa deportiva', 'Alemania'),
('Zara', 'Moda y ropa', 'España'),
('H&M', 'Moda rápida', 'Suecia'),
('Levi''s', 'Jeans y ropa casual', 'Estados Unidos'),

-- Marcas de Hogar
('IKEA', 'Muebles y decoración', 'Suecia'),
('Samsung Home', 'Electrodomésticos', 'Corea del Sur'),
('Whirlpool', 'Electrodomésticos', 'Estados Unidos');

-- =====================================================
-- INSERTAR PROVEEDORES
-- =====================================================

INSERT INTO proveedores (nombre, contacto_principal, email, telefono, pais_id, ciudad_id, direccion, calificacion, fecha_inicio_relacion) VALUES
('TechGlobal Supplies', 'John Anderson', 'contact@techglobal.com', '+1-555-0123', 1, 1, '123 Tech Street, NY', 4.8, '2020-01-15'),
('ElectroDistrib', 'María González', 'ventas@electrodistrib.mx', '+52-55-1234567', 3, 6, 'Av. Reforma 456, CDMX', 4.5, '2019-03-20'),
('EuroTech Solutions', 'Hans Mueller', 'info@eurotech.de', '+49-30-987654', 8, 13, 'Berliner Str. 789, Berlin', 4.7, '2018-06-10'),
('AsiaComponents Ltd', 'Takeshi Yamamoto', 'sales@asiacomp.jp', '+81-3-5555-0123', 10, 16, 'Tokyo Business Center', 4.6, '2019-09-15'),
('Fashion Forward', 'Sophie Dubois', 'orders@fashionforward.fr', '+33-1-4567890', 7, 12, '12 Rue de la Mode, Paris', 4.4, '2020-05-08'),
('HomeStyle Distributors', 'Emma Wilson', 'info@homestyle.com.au', '+61-2-9876543', 12, 20, 'Sydney Trade Center', 4.3, '2021-02-18'),
('SportMax Wholesale', 'Carlos Rodríguez', 'ventas@sportmax.es', '+34-91-1234567', 6, 10, 'Madrid Sports Plaza', 4.5, '2020-08-12');

-- =====================================================
-- INSERTAR PRODUCTOS
-- =====================================================

INSERT INTO productos (nombre, descripcion, categoria_id, marca_id, proveedor_id, sku, precio_compra, precio_venta, stock_actual, stock_minimo, peso, dimensiones, estado) VALUES
-- Smartphones
('iPhone 15 Pro', 'Smartphone Apple de última generación', 6, 1, 1, 'IPH15PRO128', 800.00, 1199.99, 50, 10, 0.187, '14.67 x 7.08 x 0.83 cm', 'activo'),
('Samsung Galaxy S24', 'Smartphone Samsung premium', 6, 2, 1, 'SGS24256', 650.00, 999.99, 75, 15, 0.195, '14.61 x 7.06 x 0.76 cm', 'activo'),
('iPhone 14', 'Smartphone Apple generación anterior', 6, 1, 1, 'IPH14128', 600.00, 899.99, 30, 10, 0.172, '14.67 x 7.15 x 0.78 cm', 'activo'),

-- Laptops
('MacBook Pro M3', 'Laptop profesional Apple', 7, 1, 1, 'MBPM3PRO16', 1800.00, 2499.99, 25, 5, 2.16, '35.57 x 24.81 x 1.68 cm', 'activo'),
('Dell XPS 13', 'Laptop ultrabook Dell', 7, 5, 1, 'DELLXPS13', 900.00, 1299.99, 40, 8, 1.27, '29.57 x 19.86 x 1.48 cm', 'activo'),
('HP Spectre x360', 'Laptop convertible HP', 7, 6, 1, 'HPSPECX360', 1000.00, 1399.99, 20, 5, 1.34, '30.77 x 21.75 x 1.67 cm', 'activo'),
('Lenovo ThinkPad X1', 'Laptop empresarial Lenovo', 7, 7, 4, 'LENTPX1C', 1200.00, 1699.99, 15, 3, 1.09, '31.74 x 21.77 x 1.49 cm', 'activo'),

-- Tablets
('iPad Pro 12.9"', 'Tablet profesional Apple', 8, 1, 1, 'IPADPRO129', 900.00, 1299.99, 35, 8, 0.682, '28.06 x 21.49 x 0.64 cm', 'activo'),
('Samsung Galaxy Tab S9', 'Tablet premium Samsung', 8, 2, 1, 'SGTABS9', 600.00, 849.99, 45, 10, 0.498, '25.42 x 16.54 x 0.57 cm', 'activo'),

-- Audio
('AirPods Pro 2', 'Auriculares inalámbricos Apple', 9, 1, 1, 'AIRPODSPRO2', 180.00, 249.99, 100, 20, 0.061, '4.5 x 6.1 x 2.1 cm', 'activo'),
('Sony WH-1000XM5', 'Auriculares con cancelación de ruido', 9, 3, 4, 'SONYWH1000', 250.00, 399.99, 60, 15, 0.250, '26.4 x 19.3 x 7.3 cm', 'activo'),

-- Gaming
('PlayStation 5', 'Consola de videojuegos Sony', 10, 3, 4, 'PS5CONSOLE', 400.00, 599.99, 20, 5, 4.5, '39 x 10.4 x 26 cm', 'activo'),
('Xbox Series X', 'Consola de videojuegos Microsoft', 10, 4, 1, 'XBOXSERIESX', 400.00, 599.99, 25, 5, 4.45, '30.1 x 15.1 x 15.1 cm', 'activo'),
('Nintendo Switch OLED', 'Consola portátil Nintendo', 10, 8, 4, 'NSOLED', 280.00, 399.99, 40, 10, 0.320, '24.2 x 10.2 x 1.4 cm', 'activo'),

-- Ropa Masculina
('Nike Air Max 270', 'Zapatillas deportivas Nike', 13, 9, 7, 'NIKEAM270', 80.00, 139.99, 200, 50, 0.8, '32 x 22 x 12 cm', 'activo'),
('Adidas Ultraboost 22', 'Zapatillas para correr Adidas', 13, 10, 7, 'ADIUB22', 120.00, 189.99, 150, 30, 0.85, '33 x 23 x 13 cm', 'activo'),
('Levi''s 501 Jeans', 'Jeans clásicos Levi''s', 11, 13, 5, 'LEVIS501', 45.00, 79.99, 300, 75, 0.6, '30 x 40 x 2 cm', 'activo'),

-- Ropa Femenina
('Zara Vestido Casual', 'Vestido casual Zara', 12, 11, 5, 'ZARAVEST01', 25.00, 49.99, 120, 30, 0.3, '25 x 35 x 1 cm', 'activo'),
('H&M Blusa Elegante', 'Blusa elegante H&M', 12, 12, 5, 'HMBLUSA01', 15.00, 29.99, 180, 45, 0.2, '20 x 30 x 1 cm', 'activo'),

-- Hogar
('IKEA Mesa MALM', 'Mesa de comedor IKEA', 15, 14, 6, 'IKEAMALM', 150.00, 249.99, 25, 5, 35.0, '140 x 84 x 75 cm', 'activo'),
('Samsung Refrigerador', 'Refrigerador Samsung 500L', 17, 15, 6, 'SAMREF500', 800.00, 1199.99, 10, 2, 85.0, '178 x 91.2 x 71.6 cm', 'activo');

-- =====================================================
-- INSERTAR CLIENTES
-- =====================================================

INSERT INTO clientes (tipo_cliente, nombre, apellido, razon_social, email, telefono, fecha_nacimiento, genero, pais_id, ciudad_id, direccion, codigo_postal, fecha_registro, estado_civil, profesion, ingresos_anuales, canal_adquisicion, preferencias_comunicacion) VALUES
-- Clientes individuales
('individual', 'Juan', 'Pérez', NULL, 'juan.perez@email.com', '+52-55-1234567', '1985-03-15', 'M', 3, 6, 'Av. Insurgentes 123, Col. Roma', '06700', '2023-01-15', 'soltero', 'Ingeniero', 50000.00, 'redes_sociales', 'email,sms'),
('individual', 'María', 'González', NULL, 'maria.gonzalez@email.com', '+52-55-2345678', '1990-07-22', 'F', 3, 6, 'Calle Reforma 456, Col. Condesa', '06140', '2023-02-20', 'casada', 'Doctora', 75000.00, 'referido', 'email,whatsapp'),
('individual', 'John', 'Smith', NULL, 'john.smith@email.com', '+1-555-0123', '1988-12-10', 'M', 1, 1, '789 Broadway, Manhattan', '10001', '2023-03-10', 'casado', 'Abogado', 85000.00, 'publicidad_online', 'email'),
('individual', 'Emma', 'Johnson', NULL, 'emma.johnson@email.com', '+1-555-0456', '1992-05-18', 'F', 1, 1, '456 5th Avenue, NYC', '10018', '2023-04-05', 'soltera', 'Diseñadora', 60000.00, 'redes_sociales', 'email,sms'),
('individual', 'Carlos', 'Rodríguez', NULL, 'carlos.rodriguez@email.com', '+34-91-1234567', '1987-09-25', 'M', 6, 10, 'Gran Vía 123, Madrid', '28013', '2023-05-12', 'divorciado', 'Consultor', 55000.00, 'sitio_web', 'email'),
('individual', 'Sophie', 'Dubois', NULL, 'sophie.dubois@email.com', '+33-1-4567890', '1991-11-08', 'F', 7, 12, '45 Champs-Élysées, Paris', '75008', '2023-06-18', 'soltera', 'Arquitecta', 65000.00, 'referido', 'email,whatsapp'),
('individual', 'Hiroshi', 'Tanaka', NULL, 'hiroshi.tanaka@email.com', '+81-3-5555-0123', '1983-02-14', 'M', 10, 16, 'Shibuya 1-2-3, Tokyo', '150-0002', '2023-07-22', 'casado', 'Ingeniero', 70000.00, 'publicidad_online', 'email'),
('individual', 'Anna', 'Mueller', NULL, 'anna.mueller@email.com', '+49-30-987654', '1989-04-30', 'F', 8, 13, 'Unter den Linden 10, Berlin', '10117', '2023-08-15', 'casada', 'Profesora', 45000.00, 'redes_sociales', 'email,sms'),
('individual', 'Lucas', 'Silva', NULL, 'lucas.silva@email.com', '+55-11-9876543', '1986-08-12', 'M', 4, 8, 'Av. Paulista 1000, São Paulo', '01310-100', '2023-09-08', 'soltero', 'Desarrollador', 48000.00, 'sitio_web', 'email'),
('individual', 'Isabella', 'Rossi', NULL, 'isabella.rossi@email.com', '+39-06-1234567', '1993-01-28', 'F', NULL, NULL, 'Via del Corso 200, Roma', '00186', '2023-10-12', 'soltera', 'Artista', 35000.00, 'redes_sociales', 'email,whatsapp'),

-- Clientes corporativos
('corporativo', NULL, NULL, 'TechCorp Solutions', 'ventas@techcorp.com', '+1-555-TECH', NULL, NULL, 1, 1, '1000 Corporate Blvd, NYC', '10001', '2023-01-20', NULL, NULL, 500000.00, 'ventas_directas', 'email,telefono'),
('corporativo', NULL, NULL, 'Global Retail Chain', 'compras@globalretail.com', '+1-555-RETAIL', NULL, NULL, 1, 2, '2500 Retail Plaza, LA', '90210', '2023-02-15', NULL, NULL, 2000000.00, 'ventas_directas', 'email,telefono'),
('corporativo', NULL, NULL, 'EuroTech Industries', 'procurement@eurotech.eu', '+49-30-EURO', NULL, NULL, 8, 13, 'Europa Str. 500, Berlin', '10115', '2023-03-08', NULL, NULL, 1500000.00, 'feria_comercial', 'email'),
('corporativo', NULL, NULL, 'Asia Pacific Ltd', 'orders@asiapacific.jp', '+81-3-ASIA', NULL, NULL, 10, 16, 'Business Tower 88F, Tokyo', '100-0001', '2023-04-12', NULL, NULL, 800000.00, 'ventas_directas', 'email,telefono'),
('corporativo', NULL, NULL, 'MexiCorp Distribuidora', 'compras@mexicorp.mx', '+52-55-MEXI', NULL, NULL, 3, 6, 'Torre Corporativa 45P, CDMX', '11000', '2023-05-20', NULL, NULL, 1200000.00, 'referido', 'email,telefono');

-- =====================================================
-- INSERTAR EMPLEADOS
-- =====================================================

INSERT INTO empleados (nombre, apellido, email, telefono, fecha_contratacion, puesto, departamento, salario, gerente_id, pais_id, ciudad_id, estado) VALUES
-- Gerencia General
('Roberto', 'Mendoza', 'roberto.mendoza@company.com', '+52-55-CEO', '2020-01-01', 'CEO', 'Ejecutivo', 150000.00, NULL, 3, 6, 'activo'),
('Sarah', 'Thompson', 'sarah.thompson@company.com', '+1-555-CFO', '2020-02-01', 'CFO', 'Finanzas', 130000.00, 1, 1, 1, 'activo'),
('Michael', 'Chen', 'michael.chen@company.com', '+1-555-CTO', '2020-03-01', 'CTO', 'Tecnología', 125000.00, 1, 1, 1, 'activo'),

-- Ventas
('Ana', 'Martínez', 'ana.martinez@company.com', '+52-55-VM', '2021-01-15', 'Gerente de Ventas', 'Ventas', 80000.00, 1, 3, 6, 'activo'),
('David', 'Wilson', 'david.wilson@company.com', '+1-555-VE1', '2021-06-01', 'Ejecutivo de Ventas', 'Ventas', 55000.00, 4, 1, 1, 'activo'),
('Laura', 'García', 'laura.garcia@company.com', '+52-55-VE2', '2021-08-15', 'Ejecutiva de Ventas', 'Ventas', 50000.00, 4, 3, 6, 'activo'),
('James', 'Brown', 'james.brown@company.com', '+1-555-VE3', '2022-01-10', 'Ejecutivo de Ventas', 'Ventas', 52000.00, 4, 1, 2, 'activo'),
('Carmen', 'López', 'carmen.lopez@company.com', '+34-91-VE4', '2022-03-20', 'Ejecutiva de Ventas', 'Ventas', 48000.00, 4, 6, 10, 'activo'),

-- Marketing
('Elena', 'Fernández', 'elena.fernandez@company.com', '+52-55-MKT', '2021-02-01', 'Gerente de Marketing', 'Marketing', 75000.00, 1, 3, 6, 'activo'),
('Ryan', 'Davis', 'ryan.davis@company.com', '+1-555-MKT1', '2021-09-01', 'Especialista en Marketing Digital', 'Marketing', 60000.00, 9, 1, 1, 'activo'),
('Sophie', 'Martin', 'sophie.martin@company.com', '+33-1-MKT2', '2022-01-15', 'Analista de Marketing', 'Marketing', 45000.00, 9, 7, 12, 'activo'),

-- Soporte al Cliente
('Carlos', 'Ruiz', 'carlos.ruiz@company.com', '+52-55-CS', '2021-03-01', 'Gerente de Atención al Cliente', 'Soporte', 65000.00, 1, 3, 6, 'activo'),
('Jennifer', 'Lee', 'jennifer.lee@company.com', '+1-555-CS1', '2021-10-01', 'Agente de Soporte', 'Soporte', 35000.00, 12, 1, 1, 'activo'),
('Marco', 'Rossi', 'marco.rossi@company.com', '+39-06-CS2', '2022-02-01', 'Agente de Soporte', 'Soporte', 32000.00, 12, NULL, NULL, 'activo'),

-- Logística
('Patricia', 'Jiménez', 'patricia.jimenez@company.com', '+52-55-LOG', '2021-04-01', 'Gerente de Logística', 'Logística', 70000.00, 1, 3, 6, 'activo'),
('Tom', 'Anderson', 'tom.anderson@company.com', '+1-555-LOG1', '2021-11-01', 'Coordinador de Almacén', 'Logística', 42000.00, 15, 1, 1, 'activo'),
('Hans', 'Schmidt', 'hans.schmidt@company.com', '+49-30-LOG2', '2022-04-01', 'Especialista en Envíos', 'Logística', 38000.00, 15, 8, 13, 'activo');

-- =====================================================
-- INSERTAR PEDIDOS
-- =====================================================

INSERT INTO pedidos (cliente_id, empleado_id, fecha_pedido, estado, subtotal, impuestos, descuento, total, metodo_pago, direccion_envio, ciudad_envio, pais_envio, codigo_postal_envio, fecha_envio_estimada, notas) VALUES
-- Pedidos de clientes individuales
(1, 6, '2024-01-15 10:30:00', 'entregado', 1199.99, 191.99, 0.00, 1391.98, 'tarjeta_credito', 'Av. Insurgentes 123, Col. Roma', 'Ciudad de México', 'México', '06700', '2024-01-18', 'Entrega en horario de oficina'),
(2, 6, '2024-01-20 14:15:00', 'entregado', 1549.98, 247.99, 50.00, 1747.97, 'transferencia', 'Calle Reforma 456, Col. Condesa', 'Ciudad de México', 'México', '06140', '2024-01-23', 'Cliente VIP - Descuento aplicado'),
(3, 5, '2024-02-05 09:45:00', 'entregado', 2749.98, 274.99, 100.00, 2924.97, 'tarjeta_credito', '789 Broadway, Manhattan', 'Nueva York', 'Estados Unidos', '10001', '2024-02-08', 'Entrega express'),
(4, 5, '2024-02-12 16:20:00', 'en_transito', 1449.98, 145.00, 0.00, 1594.98, 'paypal', '456 5th Avenue, NYC', 'Nueva York', 'Estados Unidos', '10018', '2024-02-15', NULL),
(5, 8, '2024-02-18 11:10:00', 'procesando', 1899.97, 304.00, 75.00, 2128.97, 'tarjeta_credito', 'Gran Vía 123, Madrid', 'Madrid', 'España', '28013', '2024-02-22', 'Descuento por fidelidad'),
(6, 8, '2024-03-01 13:30:00', 'confirmado', 649.98, 130.00, 0.00, 779.98, 'transferencia', '45 Champs-Élysées, Paris', 'París', 'Francia', '75008', '2024-03-05', NULL),
(7, 7, '2024-03-10 15:45:00', 'entregado', 999.98, 100.00, 50.00, 1049.98, 'tarjeta_credito', 'Shibuya 1-2-3, Tokyo', 'Tokio', 'Japón', '150-0002', '2024-03-14', 'Entrega internacional'),
(8, 8, '2024-03-15 12:00:00', 'procesando', 789.97, 126.39, 0.00, 916.36, 'paypal', 'Unter den Linden 10, Berlin', 'Berlín', 'Alemania', '10117', '2024-03-19', NULL),
(9, 6, '2024-03-20 10:15:00', 'confirmado', 2199.98, 351.99, 100.00, 2451.97, 'tarjeta_credito', 'Av. Paulista 1000, São Paulo', 'São Paulo', 'Brasil', '01310-100', '2024-03-25', 'Cliente frecuente'),
(10, 5, '2024-03-25 14:30:00', 'pendiente', 429.98, 68.80, 0.00, 498.78, 'transferencia', 'Via del Corso 200, Roma', 'Roma', 'Italia', '00186', '2024-03-29', NULL),

-- Pedidos corporativos
(11, 4, '2024-01-10 09:00:00', 'entregado', 25999.75, 4159.96, 1000.00, 29159.71, 'transferencia', '1000 Corporate Blvd, NYC', 'Nueva York', 'Estados Unidos', '10001', '2024-01-15', 'Pedido corporativo - Descuento por volumen'),
(12, 4, '2024-02-01 10:30:00', 'entregado', 89999.50, 14399.92, 5000.00, 99399.42, 'credito_empresarial', '2500 Retail Plaza, LA', 'Los Ángeles', 'Estados Unidos', '90210', '2024-02-07', 'Pedido mayorista'),
(13, 8, '2024-02-15 11:15:00', 'en_transito', 45999.60, 9199.93, 2000.00, 53199.53, 'transferencia', 'Europa Str. 500, Berlin', 'Berlín', 'Alemania', '10115', '2024-02-22', 'Entrega a almacén central'),
(14, 7, '2024-03-01 08:45:00', 'procesando', 32999.70, 5279.95, 1500.00, 36779.65, 'credito_empresarial', 'Business Tower 88F, Tokyo', 'Tokio', 'Japón', '100-0001', '2024-03-08', NULL),
(15, 6, '2024-03-10 12:20:00', 'confirmado', 55999.40, 8959.90, 3000.00, 61959.30, 'transferencia', 'Torre Corporativa 45P, CDMX', 'Ciudad de México', 'México', '11000', '2024-03-17', 'Pedido trimestral');

-- =====================================================
-- INSERTAR DETALLES DE PEDIDOS
-- =====================================================

INSERT INTO detalles_pedido (pedido_id, producto_id, cantidad, precio_unitario, descuento_linea, subtotal_linea) VALUES
-- Pedido 1 (Cliente individual Juan Pérez)
(1, 1, 1, 1199.99, 0.00, 1199.99),

-- Pedido 2 (Cliente individual María González)
(2, 2, 1, 999.99, 0.00, 999.99),
(2, 11, 1, 549.99, 50.00, 499.99),

-- Pedido 3 (Cliente individual John Smith)
(3, 4, 1, 2499.99, 100.00, 2399.99),
(3, 10, 1, 399.99, 0.00, 399.99),

-- Pedido 4 (Cliente individual Emma Johnson)
(4, 5, 1, 1299.99, 0.00, 1299.99),
(4, 17, 1, 149.99, 0.00, 149.99),

-- Pedido 5 (Cliente individual Carlos Rodríguez)
(5, 7, 1, 1699.99, 75.00, 1624.99),
(5, 19, 1, 249.99, 0.00, 249.99),
(5, 16, 1, 24.99, 0.00, 24.99),

-- Pedido 6 (Cliente individual Sophie Dubois)
(6, 8, 1, 1299.99, 0.00, 1299.99),
(6, 18, 1, 349.99, 0.00, 349.99),

-- Pedido 7 (Cliente individual Hiroshi Tanaka)
(7, 12, 1, 599.99, 25.00, 574.99),
(7, 13, 1, 599.99, 25.00, 574.99),

-- Pedido 8 (Cliente individual Anna Mueller)
(8, 15, 2, 189.99, 0.00, 379.98),
(8, 20, 1, 409.99, 0.00, 409.99),

-- Pedido 9 (Cliente individual Lucas Silva)
(9, 4, 1, 2499.99, 100.00, 2399.99),
(9, 1, 1, 1199.99, 0.00, 1199.99),

-- Pedido 10 (Cliente individual Isabella Rossi)
(10, 17, 2, 139.99, 0.00, 279.98),
(10, 18, 1, 149.99, 0.00, 149.99),

-- Pedido 11 (TechCorp Solutions - Corporativo)
(11, 1, 10, 1199.99, 50.00, 11499.90),
(11, 2, 15, 999.99, 50.00, 14249.85),

-- Pedido 12 (Global Retail Chain - Corporativo)
(12, 5, 25, 1299.99, 100.00, 29999.75),
(12, 6, 20, 1399.99, 100.00, 25999.80),
(12, 7, 20, 1699.99, 100.00, 31999.80),

-- Pedido 13 (EuroTech Industries - Corporativo)
(13, 4, 10, 2499.99, 150.00, 23499.90),
(13, 8, 15, 1299.99, 100.00, 18999.85),
(13, 9, 8, 849.99, 50.00, 6399.92),

-- Pedido 14 (Asia Pacific Ltd - Corporativo)
(14, 12, 30, 599.99, 75.00, 15749.70),
(14, 13, 25, 599.99, 75.00, 13124.75),
(14, 14, 10, 399.99, 50.00, 3499.90),

-- Pedido 15 (MexiCorp Distribuidora - Corporativo)
(15, 15, 100, 189.99, 25.00, 16499.00),
(15, 16, 200, 139.99, 25.00, 24998.00),
(15, 17, 150, 79.99, 20.00, 10798.50),
(15, 18, 80, 49.99, 15.00, 3599.20);

-- =====================================================
-- INSERTAR MOVIMIENTOS DE INVENTARIO
-- =====================================================

INSERT INTO movimientos_inventario (producto_id, tipo_movimiento, cantidad, motivo, empleado_id, pedido_id, proveedor_id, costo_unitario, fecha_movimiento, observaciones) VALUES
-- Entradas iniciales de inventario
(1, 'entrada', 100, 'stock_inicial', 15, NULL, 1, 800.00, '2024-01-01 08:00:00', 'Stock inicial iPhone 15 Pro'),
(2, 'entrada', 150, 'stock_inicial', 15, NULL, 1, 650.00, '2024-01-01 08:30:00', 'Stock inicial Samsung Galaxy S24'),
(3, 'entrada', 80, 'stock_inicial', 15, NULL, 1, 600.00, '2024-01-01 09:00:00', 'Stock inicial iPhone 14'),
(4, 'entrada', 50, 'stock_inicial', 15, NULL, 1, 1800.00, '2024-01-01 09:30:00', 'Stock inicial MacBook Pro M3'),
(5, 'entrada', 75, 'stock_inicial', 15, NULL, 1, 900.00, '2024-01-01 10:00:00', 'Stock inicial Dell XPS 13'),

-- Salidas por ventas (algunos ejemplos)
(1, 'salida', 1, 'venta', 6, 1, NULL, 800.00, '2024-01-15 10:30:00', 'Venta a Juan Pérez'),
(2, 'salida', 1, 'venta', 6, 2, NULL, 650.00, '2024-01-20 14:15:00', 'Venta a María González'),
(4, 'salida', 1, 'venta', 5, 3, NULL, 1800.00, '2024-02-05 09:45:00', 'Venta a John Smith'),
(5, 'salida', 1, 'venta', 5, 4, NULL, 900.00, '2024-02-12 16:20:00', 'Venta a Emma Johnson'),

-- Reposiciones
(1, 'entrada', 50, 'reposicion', 15, NULL, 1, 800.00, '2024-02-01 14:00:00', 'Reposición iPhone 15 Pro'),
(2, 'entrada', 75, 'reposicion', 15, NULL, 1, 650.00, '2024-02-01 14:30:00', 'Reposición Samsung Galaxy S24'),

-- Salidas por ventas corporativas
(1, 'salida', 10, 'venta', 4, 11, NULL, 800.00, '2024-01-10 09:00:00', 'Venta corporativa TechCorp'),
(2, 'salida', 15, 'venta', 4, 11, NULL, 650.00, '2024-01-10 09:00:00', 'Venta corporativa TechCorp'),
(5, 'salida', 25, 'venta', 4, 12, NULL, 900.00, '2024-02-01 10:30:00', 'Venta mayorista Global Retail'),

-- Ajustes de inventario
(12, 'salida', 2, 'ajuste', 15, NULL, NULL, 400.00, '2024-03-01 16:00:00', 'Ajuste por productos dañados'),
(15, 'entrada', 5, 'ajuste', 15, NULL, NULL, 80.00, '2024-03-05 10:00:00', 'Ajuste por recuento físico'),

-- Devoluciones
(3, 'entrada', 1, 'devolucion', 13, 7, NULL, 600.00, '2024-03-15 11:00:00', 'Devolución por defecto de fábrica');

-- =====================================================
-- INSERTAR CAMPAÑAS DE MARKETING
-- =====================================================

INSERT INTO campanas_marketing (nombre, descripcion, tipo_campana, canal, fecha_inicio, fecha_fin, presupuesto, objetivo, empleado_responsable, estado) VALUES
('Black Friday 2024', 'Campaña de descuentos para Black Friday', 'promocional', 'multi_canal', '2024-11-20', '2024-11-30', 50000.00, 'incrementar_ventas', 9, 'completada'),
('Lanzamiento iPhone 15', 'Campaña para el lanzamiento del iPhone 15 Pro', 'lanzamiento_producto', 'digital', '2024-01-01', '2024-01-31', 75000.00, 'conocimiento_marca', 9, 'completada'),
('Día de San Valentín', 'Promoción especial para San Valentín', 'estacional', 'redes_sociales', '2024-02-10', '2024-02-14', 15000.00, 'incrementar_ventas', 10, 'completada'),
('Vuelta a Clases 2024', 'Campaña dirigida a estudiantes', 'estacional', 'digital', '2024-08-01', '2024-08-31', 35000.00, 'adquisicion_clientes', 10, 'activa'),
('Fidelización Premium', 'Programa de fidelización para clientes VIP', 'fidelizacion', 'email', '2024-01-01', '2024-12-31', 25000.00, 'retencion_clientes', 11, 'activa'),
('Cyber Monday Tech', 'Ofertas especiales en productos tecnológicos', 'promocional', 'ecommerce', '2024-11-25', '2024-11-25', 30000.00, 'incrementar_ventas', 9, 'planificada'),
('Navidad 2024', 'Campaña navideña con ofertas especiales', 'estacional', 'multi_canal', '2024-12-01', '2024-12-24', 60000.00, 'incrementar_ventas', 9, 'planificada');

-- =====================================================
-- INSERTAR INTERACCIONES CON CLIENTES
-- =====================================================

INSERT INTO interacciones_clientes (cliente_id, empleado_id, tipo_interaccion, canal, descripcion, resultado, fecha_interaccion, seguimiento_requerido, fecha_seguimiento) VALUES
-- Interacciones de soporte
(1, 13, 'soporte', 'telefono', 'Consulta sobre garantía de iPhone 15 Pro', 'resuelto', '2024-01-20 14:30:00', FALSE, NULL),
(2, 13, 'soporte', 'email', 'Problema con entrega de pedido', 'resuelto', '2024-01-25 10:15:00', FALSE, NULL),
(3, 14, 'soporte', 'chat', 'Consulta sobre características de MacBook Pro', 'resuelto', '2024-02-08 16:45:00', FALSE, NULL),
(4, 13, 'soporte', 'telefono', 'Solicitud de cambio de dirección de envío', 'resuelto', '2024-02-14 11:20:00', FALSE, NULL),
(5, 14, 'soporte', 'email', 'Consulta sobre disponibilidad de productos', 'resuelto', '2024-02-20 09:30:00', FALSE, NULL),

-- Interacciones de ventas
(6, 8, 'venta', 'telefono', 'Llamada de seguimiento post-venta', 'exitoso', '2024-03-05 15:00:00', TRUE, '2024-03-20'),
(7, 7, 'venta', 'email', 'Propuesta de productos complementarios', 'pendiente', '2024-03-12 12:00:00', TRUE, '2024-03-25'),
(8, 8, 'venta', 'presencial', 'Reunión para demostración de productos', 'exitoso', '2024-03-18 14:00:00', TRUE, '2024-04-01'),
(9, 6, 'venta', 'telefono', 'Llamada para oferta especial', 'exitoso', '2024-03-22 10:30:00', FALSE, NULL),
(10, 5, 'venta', 'email', 'Envío de catálogo de productos', 'pendiente', '2024-03-26 16:00:00', TRUE, '2024-04-05'),

-- Interacciones corporativas
(11, 4, 'venta', 'presencial', 'Reunión trimestral de negocios', 'exitoso', '2024-01-15 09:00:00', TRUE, '2024-04-15'),
(12, 4, 'venta', 'email', 'Propuesta de contrato anual', 'en_proceso', '2024-02-10 11:30:00', TRUE, '2024-03-30'),
(13, 8, 'venta', 'videoconferencia', 'Presentación de nuevos productos', 'exitoso', '2024-02-25 14:00:00', TRUE, '2024-05-25'),
(14, 7, 'venta', 'telefono', 'Negociación de términos de pago', 'en_proceso', '2024-03-05 13:15:00', TRUE, '2024-04-05'),
(15, 6, 'venta', 'presencial', 'Firma de contrato de distribución', 'exitoso', '2024-03-15 10:00:00', TRUE, '2024-06-15'),

-- Interacciones de marketing
(1, 10, 'marketing', 'email', 'Envío de newsletter mensual', 'entregado', '2024-03-01 08:00:00', FALSE, NULL),
(2, 10, 'marketing', 'sms', 'Notificación de oferta especial', 'entregado', '2024-03-15 12:00:00', FALSE, NULL),
(3, 11, 'marketing', 'redes_sociales', 'Interacción en publicación de Instagram', 'positivo', '2024-03-20 18:30:00', FALSE, NULL),
(4, 10, 'marketing', 'email', 'Invitación a evento de lanzamiento', 'abierto', '2024-03-25 10:00:00', FALSE, NULL),
(5, 11, 'marketing', 'telefono', 'Encuesta de satisfacción', 'completado', '2024-03-28 14:45:00', FALSE, NULL);

-- =====================================================
-- ACTUALIZAR STOCK ACTUAL DESPUÉS DE MOVIMIENTOS
-- =====================================================

-- Actualizar stock basado en movimientos
UPDATE productos SET stock_actual = 50 WHERE id = 1;  -- iPhone 15 Pro: 100 inicial - 1 - 10 + 50 - 89 vendidos
UPDATE productos SET stock_actual = 75 WHERE id = 2;  -- Samsung Galaxy S24: 150 inicial - 1 - 15 + 75 - 59 vendidos  
UPDATE productos SET stock_actual = 30 WHERE id = 3;  -- iPhone 14: 80 inicial + 1 devuelto - 51 vendidos
UPDATE productos SET stock_actual = 25 WHERE id = 4;  -- MacBook Pro: 50 inicial - 1 - 10 - 14 vendidos
UPDATE productos SET stock_actual = 40 WHERE id = 5;  -- Dell XPS: 75 inicial - 1 - 25 - 9 vendidos

-- =====================================================
-- INSERTAR DATOS PARA ANÁLISIS Y REPORTING
-- =====================================================

-- Insertar más datos históricos para análisis de tendencias
INSERT INTO pedidos (cliente_id, empleado_id, fecha_pedido, estado, subtotal, impuestos, descuento, total, metodo_pago, direccion_envio, ciudad_envio, pais_envio, codigo_postal_envio, fecha_envio_estimada, notas) VALUES
-- Datos del año pasado para comparaciones
(1, 6, '2023-11-25 10:30:00', 'entregado', 899.99, 143.99, 50.00, 993.98, 'tarjeta_credito', 'Av. Insurgentes 123, Col. Roma', 'Ciudad de México', 'México', '06700', '2023-11-28', 'Black Friday 2023'),
(2, 6, '2023-12-15 14:15:00', 'entregado', 1299.99, 207.99, 0.00, 1507.98, 'transferencia', 'Calle Reforma 456, Col. Condesa', 'Ciudad de México', 'México', '06140', '2023-12-18', 'Compra navideña'),
(3, 5, '2023-12-20 09:45:00', 'entregado', 2199.98, 351.99, 200.00, 2351.97, 'tarjeta_credito', '789 Broadway, Manhattan', 'Nueva York', 'Estados Unidos', '10001', '2023-12-23', 'Regalo de Navidad'),
(11, 4, '2023-12-01 09:00:00', 'entregado', 45999.75, 7359.96, 2000.00, 51359.71, 'transferencia', '1000 Corporate Blvd, NYC', 'Nueva York', 'Estados Unidos', '10001', '2023-12-05', 'Pedido fin de año fiscal');

-- =====================================================
-- COMENTARIOS FINALES
-- =====================================================

-- Los datos insertados incluyen:
-- ✅ Estructura geográfica completa (regiones, países, ciudades)
-- ✅ Catálogo de productos diversificado con marcas reconocidas
-- ✅ Clientes individuales y corporativos con perfiles realistas
-- ✅ Empleados organizados por departamentos
-- ✅ Pedidos con diferentes estados y métodos de pago
-- ✅ Movimientos de inventario para trazabilidad completa
-- ✅ Campañas de marketing activas y completadas
-- ✅ Interacciones de clientes para análisis de CRM
-- ✅ Datos históricos para análisis de tendencias

-- Este conjunto de datos permite:
-- 📊 Análisis de ventas por región, producto, empleado
-- 📈 Reportes de rendimiento y KPIs
-- 🔍 Análisis de comportamiento de clientes
-- 📦 Gestión completa de inventario
-- 💰 Análisis de rentabilidad por producto/cliente
-- 🎯 Efectividad de campañas de marketing
-- 🏆 Ranking de empleados y productos más vendidos

COMMIT;
