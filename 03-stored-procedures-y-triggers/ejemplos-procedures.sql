-- ====================================================================
-- STORED PROCEDURES EN MYSQL - EJEMPLOS PRÁCTICOS
-- ====================================================================
-- Autor: Curso MySQL Avanzado
-- Fecha: 2025-05-28
-- Descripción: Ejemplos completos de stored procedures desde básico hasta avanzado
-- ====================================================================

-- ====================================================================
-- 1. CONCEPTOS BÁSICOS - STORED PROCEDURES SIMPLES
-- ====================================================================

-- 1.1 Procedure básico sin parámetros
DELIMITER //
CREATE PROCEDURE ObtenerFechaActual()
BEGIN
    SELECT NOW() AS fecha_actual;
END //
DELIMITER ;

-- Llamada del procedure
CALL ObtenerFechaActual();

-- 1.2 Procedure con parámetros de entrada (IN)
DELIMITER //
CREATE PROCEDURE BuscarClientePorID(
    IN cliente_id INT
)
BEGIN
    SELECT 
        id,
        nombre,
        email,
        fecha_registro
    FROM clientes 
    WHERE id = cliente_id;
END //
DELIMITER ;

-- Llamada con parámetro
CALL BuscarClientePorID(5);

-- 1.3 Procedure con parámetros de salida (OUT)
DELIMITER //
CREATE PROCEDURE ContarClientes(
    OUT total_clientes INT
)
BEGIN
    SELECT COUNT(*) INTO total_clientes 
    FROM clientes;
END //
DELIMITER ;

-- Llamada con variable de salida
CALL ContarClientes(@total);
SELECT @total AS total_clientes;

-- ====================================================================
-- 2. PROCEDURES CON PARÁMETROS INOUT
-- ====================================================================

DELIMITER //
CREATE PROCEDURE IncrementarValor(
    INOUT valor INT,
    IN incremento INT
)
BEGIN
    SET valor = valor + incremento;
END //
DELIMITER ;

-- Uso del procedure INOUT
SET @mi_valor = 10;
CALL IncrementarValor(@mi_valor, 5);
SELECT @mi_valor; -- Resultado: 15

-- ====================================================================
-- 3. PROCEDURES CON CONTROL DE FLUJO
-- ====================================================================

-- 3.1 Procedure con IF-ELSE
DELIMITER //
CREATE PROCEDURE CategoriarCliente(
    IN cliente_id INT,
    OUT categoria VARCHAR(20)
)
BEGIN
    DECLARE total_compras DECIMAL(10,2);
    
    SELECT COALESCE(SUM(total), 0) INTO total_compras
    FROM pedidos
    WHERE id_cliente = cliente_id;
    
    IF total_compras >= 10000 THEN
        SET categoria = 'VIP';
    ELSEIF total_compras >= 5000 THEN
        SET categoria = 'Premium';
    ELSEIF total_compras >= 1000 THEN
        SET categoria = 'Regular';
    ELSE
        SET categoria = 'Nuevo';
    END IF;
END //
DELIMITER ;

-- Uso del procedure
CALL CategoriarCliente(1, @cat);
SELECT @cat AS categoria_cliente;

-- 3.2 Procedure con CASE
DELIMITER //
CREATE PROCEDURE DescuentoPorCategoria(
    IN categoria VARCHAR(20),
    OUT descuento DECIMAL(5,2)
)
BEGIN
    CASE categoria
        WHEN 'VIP' THEN
            SET descuento = 15.00;
        WHEN 'Premium' THEN
            SET descuento = 10.00;
        WHEN 'Regular' THEN
            SET descuento = 5.00;
        ELSE
            SET descuento = 0.00;
    END CASE;
END //
DELIMITER ;

-- ====================================================================
-- 4. PROCEDURES CON LOOPS
-- ====================================================================

-- 4.1 Loop con WHILE
DELIMITER //
CREATE PROCEDURE GenerarNumeros(
    IN limite INT
)
BEGIN
    DECLARE contador INT DEFAULT 1;
    
    DROP TEMPORARY TABLE IF EXISTS temp_numeros;
    CREATE TEMPORARY TABLE temp_numeros (
        numero INT,
        cuadrado INT,
        cubo INT
    );
    
    WHILE contador <= limite DO
        INSERT INTO temp_numeros 
        VALUES (contador, contador * contador, contador * contador * contador);
        SET contador = contador + 1;
    END WHILE;
    
    SELECT * FROM temp_numeros;
END //
DELIMITER ;

-- Generar tabla con números del 1 al 10
CALL GenerarNumeros(10);

-- 4.2 Loop con REPEAT
DELIMITER //
CREATE PROCEDURE SumaHastaN(
    IN n INT,
    OUT suma_total INT
)
BEGIN
    DECLARE contador INT DEFAULT 1;
    DECLARE suma INT DEFAULT 0;
    
    REPEAT
        SET suma = suma + contador;
        SET contador = contador + 1;
    UNTIL contador > n
    END REPEAT;
    
    SET suma_total = suma;
END //
DELIMITER ;

-- Calcular suma de 1 a 100
CALL SumaHastaN(100, @suma);
SELECT @suma; -- Resultado: 5050

-- ====================================================================
-- 5. MANEJO DE CURSORES
-- ====================================================================

DELIMITER //
CREATE PROCEDURE ActualizarSalariosEmpleados(
    IN porcentaje_aumento DECIMAL(5,2)
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE emp_id INT;
    DECLARE salario_actual DECIMAL(10,2);
    DECLARE nuevo_salario DECIMAL(10,2);
    
    -- Cursor para recorrer empleados
    DECLARE cur_empleados CURSOR FOR
        SELECT id, salario FROM empleados WHERE activo = 1;
    
    -- Handler para el final del cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Crear tabla temporal para log
    DROP TEMPORARY TABLE IF EXISTS temp_actualizaciones;
    CREATE TEMPORARY TABLE temp_actualizaciones (
        empleado_id INT,
        salario_anterior DECIMAL(10,2),
        salario_nuevo DECIMAL(10,2),
        aumento DECIMAL(10,2)
    );
    
    OPEN cur_empleados;
    
    read_loop: LOOP
        FETCH cur_empleados INTO emp_id, salario_actual;
        
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        SET nuevo_salario = salario_actual * (1 + porcentaje_aumento / 100);
        
        UPDATE empleados 
        SET salario = nuevo_salario 
        WHERE id = emp_id;
        
        INSERT INTO temp_actualizaciones VALUES 
        (emp_id, salario_actual, nuevo_salario, nuevo_salario - salario_actual);
        
    END LOOP;
    
    CLOSE cur_empleados;
    
    SELECT * FROM temp_actualizaciones;
END //
DELIMITER ;

-- Aplicar aumento del 5% a todos los empleados
CALL ActualizarSalariosEmpleados(5.00);

-- ====================================================================
-- 6. MANEJO DE EXCEPCIONES
-- ====================================================================

DELIMITER //
CREATE PROCEDURE TransferirDinero(
    IN cuenta_origen INT,
    IN cuenta_destino INT,
    IN monto DECIMAL(10,2),
    OUT resultado VARCHAR(100)
)
BEGIN
    DECLARE saldo_origen DECIMAL(10,2);
    DECLARE cuenta_origen_existe INT DEFAULT 0;
    DECLARE cuenta_destino_existe INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET resultado = 'Error: La transferencia falló debido a un error de base de datos';
    END;
    
    START TRANSACTION;
    
    -- Verificar si las cuentas existen
    SELECT COUNT(*) INTO cuenta_origen_existe 
    FROM cuentas WHERE id = cuenta_origen;
    
    SELECT COUNT(*) INTO cuenta_destino_existe 
    FROM cuentas WHERE id = cuenta_destino;
    
    IF cuenta_origen_existe = 0 THEN
        SET resultado = 'Error: La cuenta de origen no existe';
        ROLLBACK;
    ELSEIF cuenta_destino_existe = 0 THEN
        SET resultado = 'Error: La cuenta de destino no existe';
        ROLLBACK;
    ELSE
        -- Verificar saldo suficiente
        SELECT saldo INTO saldo_origen 
        FROM cuentas WHERE id = cuenta_origen;
        
        IF saldo_origen < monto THEN
            SET resultado = 'Error: Saldo insuficiente';
            ROLLBACK;
        ELSE
            -- Realizar la transferencia
            UPDATE cuentas 
            SET saldo = saldo - monto 
            WHERE id = cuenta_origen;
            
            UPDATE cuentas 
            SET saldo = saldo + monto 
            WHERE id = cuenta_destino;
            
            COMMIT;
            SET resultado = CONCAT('Transferencia exitosa de $', monto, ' realizada');
        END IF;
    END IF;
END //
DELIMITER ;

-- Ejemplo de uso
CALL TransferirDinero(1, 2, 500.00, @resultado);
SELECT @resultado;

-- ====================================================================
-- 7. PROCEDURES PARA REPORTES COMPLEJOS
-- ====================================================================

DELIMITER //
CREATE PROCEDURE ReporteVentasMensuales(
    IN anio INT,
    IN mes INT
)
BEGIN
    SELECT 
        CONCAT(c.nombre, ' ', c.apellido) AS cliente,
        COUNT(p.id) AS total_pedidos,
        SUM(p.total) AS total_vendido,
        AVG(p.total) AS promedio_pedido,
        MAX(p.total) AS pedido_mayor,
        MIN(p.total) AS pedido_menor,
        CASE 
            WHEN SUM(p.total) >= 5000 THEN 'VIP'
            WHEN SUM(p.total) >= 2000 THEN 'Premium'
            ELSE 'Regular'
        END AS categoria_cliente
    FROM clientes c
    LEFT JOIN pedidos p ON c.id = p.id_cliente
    WHERE YEAR(p.fecha_pedido) = anio 
      AND MONTH(p.fecha_pedido) = mes
    GROUP BY c.id, c.nombre, c.apellido
    HAVING total_vendido > 0
    ORDER BY total_vendido DESC;
END //
DELIMITER ;

-- Reporte de mayo 2025
CALL ReporteVentasMensuales(2025, 5);

-- ====================================================================
-- 8. PROCEDURE PARA MANTENIMIENTO DE DATOS
-- ====================================================================

DELIMITER //
CREATE PROCEDURE LimpiezaDatos(
    IN dias_antiguedad INT,
    OUT registros_eliminados INT
)
BEGIN
    DECLARE logs_eliminados INT DEFAULT 0;
    DECLARE temp_eliminados INT DEFAULT 0;
    DECLARE sesiones_eliminadas INT DEFAULT 0;
    
    -- Limpiar logs antiguos
    DELETE FROM logs_sistema 
    WHERE fecha_log < DATE_SUB(NOW(), INTERVAL dias_antiguedad DAY);
    SET logs_eliminados = ROW_COUNT();
    
    -- Limpiar archivos temporales
    DELETE FROM archivos_temporales 
    WHERE fecha_creacion < DATE_SUB(NOW(), INTERVAL dias_antiguedad DAY);
    SET temp_eliminados = ROW_COUNT();
    
    -- Limpiar sesiones expiradas
    DELETE FROM sesiones_usuario 
    WHERE ultima_actividad < DATE_SUB(NOW(), INTERVAL dias_antiguedad DAY);
    SET sesiones_eliminadas = ROW_COUNT();
    
    SET registros_eliminados = logs_eliminados + temp_eliminados + sesiones_eliminadas;
    
    -- Log de la operación
    INSERT INTO log_mantenimiento (
        fecha_operacion,
        tipo_operacion,
        registros_afectados,
        descripcion
    ) VALUES (
        NOW(),
        'LIMPIEZA_DATOS',
        registros_eliminados,
        CONCAT('Limpieza de datos de ', dias_antiguedad, ' días de antigüedad')
    );
END //
DELIMITER ;

-- Limpiar datos de más de 30 días
CALL LimpiezaDatos(30, @eliminados);
SELECT @eliminados AS registros_eliminados;

-- ====================================================================
-- 9. PROCEDURE CON PARÁMETROS DINÁMICOS
-- ====================================================================

DELIMITER //
CREATE PROCEDURE BusquedaDinamica(
    IN tabla VARCHAR(50),
    IN campo VARCHAR(50),
    IN valor VARCHAR(100),
    IN operador VARCHAR(10)
)
BEGIN
    SET @sql = CONCAT(
        'SELECT * FROM ', tabla, 
        ' WHERE ', campo, ' ', operador, ' \'', valor, '\''
    );
    
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //
DELIMITER ;

-- Ejemplos de uso dinámico
CALL BusquedaDinamica('clientes', 'nombre', 'Juan', 'LIKE');
CALL BusquedaDinamica('productos', 'precio', '100', '>');

-- ====================================================================
-- 10. GESTIÓN Y MONITOREO DE PROCEDURES
-- ====================================================================

-- Ver información de procedures
SELECT 
    ROUTINE_NAME as nombre_procedure,
    ROUTINE_TYPE as tipo,
    CREATED as fecha_creacion,
    LAST_ALTERED as ultima_modificacion,
    SECURITY_TYPE as tipo_seguridad
FROM INFORMATION_SCHEMA.ROUTINES 
WHERE ROUTINE_SCHEMA = DATABASE()
  AND ROUTINE_TYPE = 'PROCEDURE';

-- Eliminar procedure
-- DROP PROCEDURE IF EXISTS NombreProcedure;

-- Mostrar definición de un procedure
-- SHOW CREATE PROCEDURE NombreProcedure;

-- ====================================================================
-- EJERCICIOS PRÁCTICOS
-- ====================================================================

/*
EJERCICIO 1: Crear un procedure que calcule el factorial de un número
EJERCICIO 2: Procedure para generar números de Fibonacci hasta N términos
EJERCICIO 3: Procedure que valide y formate números de teléfono
EJERCICIO 4: Procedure para calcular estadísticas de ventas por período
EJERCICIO 5: Procedure que implemente un sistema de auditoría automática

Soluciones disponibles en el archivo 'soluciones-procedures.sql'
*/
