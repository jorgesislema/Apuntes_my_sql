-- ============================================
-- FUNCIONES AVANZADAS EN MYSQL
-- ============================================

-- ==========================================
-- 1. FUNCIONES DE VENTANA (WINDOW FUNCTIONS)
-- ==========================================

-- ROW_NUMBER() - Numeración secuencial
SELECT 
    nombre,
    salario,
    departamento_id,
    ROW_NUMBER() OVER (PARTITION BY departamento_id ORDER BY salario DESC) as ranking_dept
FROM empleados;

-- RANK() y DENSE_RANK() - Rankings con empates
SELECT 
    nombre,
    salario,
    RANK() OVER (ORDER BY salario DESC) as rank_salario,
    DENSE_RANK() OVER (ORDER BY salario DESC) as dense_rank_salario
FROM empleados;

-- LAG() y LEAD() - Valores de filas anteriores/siguientes
SELECT 
    fecha,
    ventas_diarias,
    LAG(ventas_diarias, 1) OVER (ORDER BY fecha) as ventas_dia_anterior,
    LEAD(ventas_diarias, 1) OVER (ORDER BY fecha) as ventas_dia_siguiente,
    ventas_diarias - LAG(ventas_diarias, 1) OVER (ORDER BY fecha) as diferencia
FROM ventas_diarias;

-- FIRST_VALUE() y LAST_VALUE() - Primer y último valor en ventana
SELECT 
    nombre,
    salario,
    departamento_id,
    FIRST_VALUE(salario) OVER (PARTITION BY departamento_id ORDER BY salario DESC) as salario_mas_alto_dept,
    LAST_VALUE(salario) OVER (PARTITION BY departamento_id ORDER BY salario DESC 
                              ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as salario_mas_bajo_dept
FROM empleados;

-- ==========================================
-- 2. FUNCIONES DE AGREGACIÓN AVANZADAS
-- ==========================================

-- GROUP_CONCAT() - Concatenar valores agrupados
SELECT 
    departamento_id,
    GROUP_CONCAT(nombre ORDER BY nombre SEPARATOR ', ') as empleados,
    GROUP_CONCAT(DISTINCT cargo ORDER BY cargo SEPARATOR ' | ') as cargos_disponibles
FROM empleados
GROUP BY departamento_id;

-- WITH ROLLUP - Totales y subtotales automáticos
SELECT 
    departamento_id,
    cargo,
    COUNT(*) as cantidad,
    AVG(salario) as salario_promedio
FROM empleados
GROUP BY departamento_id, cargo WITH ROLLUP;

-- ==========================================
-- 3. FUNCIONES DE FECHA Y TIEMPO AVANZADAS
-- ==========================================

-- Manipulación avanzada de fechas
SELECT 
    fecha_contratacion,
    YEAR(fecha_contratacion) as año,
    QUARTER(fecha_contratacion) as trimestre,
    WEEKOFYEAR(fecha_contratacion) as semana_del_año,
    DAYNAME(fecha_contratacion) as dia_semana,
    DATEDIFF(CURDATE(), fecha_contratacion) as dias_trabajados,
    TIMESTAMPDIFF(YEAR, fecha_contratacion, CURDATE()) as años_antiguedad
FROM empleados;

-- Rangos de fechas y períodos
SELECT 
    DATE_FORMAT(fecha, '%Y-%m') as mes,
    COUNT(*) as total_ventas,
    SUM(total) as ingresos_mes
FROM ventas
WHERE fecha BETWEEN DATE_SUB(CURDATE(), INTERVAL 12 MONTH) AND CURDATE()
GROUP BY DATE_FORMAT(fecha, '%Y-%m')
ORDER BY mes;

-- ==========================================
-- 4. FUNCIONES DE CADENA AVANZADAS
-- ==========================================

-- Manipulación de texto compleja
SELECT 
    CONCAT(
        UPPER(LEFT(nombre, 1)),
        LOWER(SUBSTRING(nombre, 2)),
        ' - ',
        LPAD(id, 5, '0')
    ) as nombre_formateado,
    REPLACE(REPLACE(email, '@gmail.com', ''), '@hotmail.com', '') as usuario_email,
    CHAR_LENGTH(descripcion) as longitud_descripcion,
    SUBSTRING_INDEX(email, '@', -1) as dominio_email
FROM empleados;

-- Búsqueda y extracción de patrones
SELECT 
    nombre,
    email,
    CASE 
        WHEN email REGEXP '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' 
        THEN 'Email válido'
        ELSE 'Email inválido'
    END as validacion_email
FROM empleados;

-- ==========================================
-- 5. FUNCIONES MATEMÁTICAS AVANZADAS
-- ==========================================

-- Cálculos estadísticos
SELECT 
    departamento_id,
    COUNT(*) as empleados,
    AVG(salario) as media,
    STDDEV(salario) as desviacion_estandar,
    VARIANCE(salario) as varianza,
    MIN(salario) as minimo,
    MAX(salario) as maximo,
    (MAX(salario) - MIN(salario)) as rango
FROM empleados
GROUP BY departamento_id;

-- Funciones trigonométricas y logarítmicas
SELECT 
    producto_id,
    precio,
    LOG(precio) as log_precio,
    SQRT(precio) as raiz_precio,
    POWER(precio, 2) as precio_cuadrado,
    ROUND(precio * 1.16, 2) as precio_con_iva
FROM productos;

-- ==========================================
-- 6. FUNCIONES CONDICIONALES AVANZADAS
-- ==========================================

-- CASE complejos con múltiples condiciones
SELECT 
    nombre,
    salario,
    CASE 
        WHEN salario < 30000 THEN 'Bajo'
        WHEN salario BETWEEN 30000 AND 50000 THEN 'Medio'
        WHEN salario BETWEEN 50001 AND 80000 THEN 'Alto'
        ELSE 'Muy Alto'
    END as categoria_salario,
    CASE 
        WHEN TIMESTAMPDIFF(YEAR, fecha_contratacion, CURDATE()) < 1 THEN 'Nuevo'
        WHEN TIMESTAMPDIFF(YEAR, fecha_contratacion, CURDATE()) BETWEEN 1 AND 5 THEN 'Intermedio'
        ELSE 'Veterano'
    END as categoria_antiguedad
FROM empleados;

-- IF anidados y NULLIF
SELECT 
    nombre,
    salario,
    comision,
    IF(comision IS NULL, salario, salario + comision) as salario_total,
    NULLIF(comision, 0) as comision_valida,
    IFNULL(comision, 0) as comision_o_cero
FROM empleados;

-- ==========================================
-- 7. FUNCIONES JSON (MySQL 5.7+)
-- ==========================================

-- Manipulación de datos JSON
SELECT 
    id,
    nombre,
    JSON_EXTRACT(datos_adicionales, '$.telefono') as telefono,
    JSON_EXTRACT(datos_adicionales, '$.direccion.ciudad') as ciudad,
    JSON_CONTAINS(datos_adicionales, '"MySQL"', '$.habilidades') as sabe_mysql
FROM empleados
WHERE JSON_EXTRACT(datos_adicionales, '$.activo') = true;

-- ==========================================
-- 8. FUNCIONES DE CONVERSIÓN Y FORMATO
-- ==========================================

-- Conversiones de tipo avanzadas
SELECT 
    id,
    CAST(salario AS CHAR) as salario_texto,
    CONVERT(fecha_contratacion, CHAR) as fecha_texto,
    FORMAT(salario, 2) as salario_formateado,
    DATE_FORMAT(fecha_contratacion, '%d/%m/%Y') as fecha_formateada
FROM empleados;

-- ==========================================
-- 9. FUNCIONES DEFINIDAS POR EL USUARIO
-- ==========================================

-- Ejemplo de función personalizada
DELIMITER //
CREATE FUNCTION calcular_bono(salario DECIMAL(10,2), antiguedad INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE bono DECIMAL(10,2);
    
    IF antiguedad < 1 THEN
        SET bono = salario * 0.05;
    ELSEIF antiguedad BETWEEN 1 AND 5 THEN
        SET bono = salario * 0.10;
    ELSE
        SET bono = salario * 0.15;
    END IF;
    
    RETURN bono;
END//
DELIMITER ;

-- Uso de la función personalizada
SELECT 
    nombre,
    salario,
    TIMESTAMPDIFF(YEAR, fecha_contratacion, CURDATE()) as antiguedad,
    calcular_bono(salario, TIMESTAMPDIFF(YEAR, fecha_contratacion, CURDATE())) as bono_calculado
FROM empleados;

-- ==========================================
-- 10. EJERCICIOS PRÁCTICOS
-- ==========================================

-- Ejercicio 1: Crear ranking de ventas por vendedor usando funciones de ventana
-- Ejercicio 2: Análisis de tendencias mensuales con LAG/LEAD
-- Ejercicio 3: Formato personalizado de reportes con funciones de cadena
-- Ejercicio 4: Cálculo de comisiones progresivas con CASE y funciones matemáticas
