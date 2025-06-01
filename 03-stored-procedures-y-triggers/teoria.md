# Stored Procedures y Triggers en MySQL

## 📋 Contenido del Módulo

Este módulo cubre los aspectos avanzados de programación en MySQL, incluyendo stored procedures, functions y triggers.

### Archivos incluidos:
- `ejemplos-procedures.sql` - Ejemplos completos de stored procedures
- `ejemplos-triggers.sql` - Implementación de triggers para auditoría y validación
- `teoria.md` - Fundamentos teóricos y mejores prácticas

---

## 🎯 Objetivos de Aprendizaje

Al completar este módulo serás capaz de:

1. **Stored Procedures**
   - Crear y gestionar procedimientos almacenados
   - Implementar lógica de negocio compleja
   - Manejar parámetros de entrada y salida
   - Trabajar con cursores y loops
   - Gestionar excepciones y errores

2. **Triggers**
   - Implementar triggers para auditoría automática
   - Crear validaciones de datos complejas
   - Automatizar procesos de negocio
   - Mantener integridad referencial avanzada

3. **Functions**
   - Desarrollar funciones personalizadas
   - Implementar cálculos complejos reutilizables
   - Crear bibliotecas de funciones de utilidad

---

## 📚 Conceptos Fundamentales

### Stored Procedures vs Functions

| Característica | Stored Procedure | Function |
|----------------|------------------|----------|
| Valor de retorno | Opcional (OUT parameters) | Obligatorio |
| Llamada en SELECT | No | Sí |
| Transacciones | Puede controlar | No puede controlar |
| Modificación de datos | Sí | Limitada |
| Recursión | Sí | Sí |

### Tipos de Triggers

1. **Por Momento de Ejecución:**
   - `BEFORE` - Antes de la operación
   - `AFTER` - Después de la operación

2. **Por Evento:**
   - `INSERT` - Al insertar registros
   - `UPDATE` - Al actualizar registros
   - `DELETE` - Al eliminar registros

### Ventajas de los Stored Procedures

- **Performance**: Código precompilado
- **Seguridad**: Control de acceso granular
- **Reutilización**: Lógica centralizada
- **Mantenimiento**: Cambios sin modificar aplicaciones
- **Integridad**: Validaciones a nivel de base de datos

### Ventajas de los Triggers

- **Automatización**: Acciones automáticas
- **Auditoría**: Registro transparente de cambios
- **Integridad**: Validaciones complejas
- **Sincronización**: Mantenimiento de datos relacionados

---

## 🔧 Sintaxis Básica

### Crear Stored Procedure
```sql
DELIMITER //
CREATE PROCEDURE nombre_procedure(
    IN param_entrada INT,
    OUT param_salida VARCHAR(100),
    INOUT param_entrada_salida DECIMAL(10,2)
)
BEGIN
    -- Lógica del procedimiento
    DECLARE variable_local INT DEFAULT 0;
    
    -- Ejemplo de lógica
    SET param_salida = CONCAT('Resultado: ', param_entrada);
    SET param_entrada_salida = param_entrada_salida * 1.1;
    
END//
DELIMITER ;
```

### Crear Function
```sql
DELIMITER //
CREATE FUNCTION calcular_impuesto(monto DECIMAL(10,2))
RETURNS DECIMAL(10,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE impuesto DECIMAL(10,2);
    SET impuesto = monto * 0.21;
    RETURN impuesto;
END//
DELIMITER ;
```

### Crear Trigger
```sql
DELIMITER //
CREATE TRIGGER trigger_auditoria
    AFTER UPDATE ON tabla_principal
    FOR EACH ROW
BEGIN
    INSERT INTO tabla_auditoria (
        registro_id, campo_modificado, valor_anterior, valor_nuevo, fecha
    ) VALUES (
        NEW.id, 'campo', OLD.campo, NEW.campo, NOW()
    );
END//
DELIMITER ;
```

---

## 🎨 Patrones de Diseño Comunes

### 1. Patrón de Auditoría Completa
```sql
-- Trigger que registra todos los cambios en una tabla
DELIMITER //
CREATE TRIGGER audit_complete
    AFTER UPDATE ON tabla_principal
    FOR EACH ROW
BEGIN
    -- Auditar cada campo modificado
    IF OLD.campo1 != NEW.campo1 THEN
        INSERT INTO auditoria VALUES (NEW.id, 'campo1', OLD.campo1, NEW.campo1, NOW());
    END IF;
    -- Repetir para cada campo importante
END//
DELIMITER ;
```

### 2. Patrón de Validación en Cascada
```sql
-- Procedure que valida múltiples condiciones
DELIMITER //
CREATE PROCEDURE validar_operacion(IN datos JSON, OUT resultado BOOLEAN)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET resultado = FALSE;
        ROLLBACK;
    END;
    
    START TRANSACTION;
    -- Múltiples validaciones
    -- Si todas pasan, commit
    COMMIT;
    SET resultado = TRUE;
END//
DELIMITER ;
```

### 3. Patrón de Procesamiento por Lotes
```sql
-- Procedure para procesar grandes volúmenes de datos
DELIMITER //
CREATE PROCEDURE procesar_lotes(IN tamaño_lote INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE batch_cursor CURSOR FOR 
        SELECT id FROM tabla_procesar WHERE procesado = FALSE LIMIT tamaño_lote;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    proceso_loop: LOOP
        OPEN batch_cursor;
        -- Procesar lote
        CLOSE batch_cursor;
        
        IF done THEN
            LEAVE proceso_loop;
        END IF;
    END LOOP;
END//
DELIMITER ;
```

---

## 🚀 Optimización y Mejores Prácticas

### Performance

1. **Evitar cursores cuando sea posible**
   - Usar operaciones basadas en conjuntos
   - Los cursores son más lentos que las operaciones SQL directas

2. **Gestión de memoria**
   - Liberar cursores después del uso
   - Evitar variables innecesarias

3. **Índices apropiados**
   - Asegurar índices en columnas usadas en WHERE
   - Considerar índices compuestos

### Seguridad

1. **Principio de menor privilegio**
   - Otorgar solo permisos necesarios
   - Usar DEFINER vs INVOKER apropiadamente

2. **Validación de entrada**
   - Validar todos los parámetros
   - Prevenir inyección SQL

3. **Manejo de errores**
   - Implementar handlers apropiados
   - Log de errores para debugging

### Mantenibilidad

1. **Documentación**
   - Comentarios claros y descriptivos
   - Documentar parámetros y comportamiento

2. **Naming conventions**
   - Nombres descriptivos y consistentes
   - Prefijos por tipo (sp_, fn_, tr_)

3. **Versionado**
   - Controlar cambios en procedures
   - Mantener compatibilidad hacia atrás

---

## 🔍 Debugging y Troubleshooting

### Técnicas de Debug

1. **Variables temporales para trace**
```sql
DECLARE debug_msg VARCHAR(255);
SET debug_msg = CONCAT('Punto 1: variable = ', @variable);
-- Insertar en tabla de debug o usar SELECT para mostrar
```

2. **Manejo de errores detallado**
```sql
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1
        @error_code = MYSQL_ERRNO,
        @error_msg = MESSAGE_TEXT;
    -- Log del error
    INSERT INTO error_log VALUES (NOW(), @error_code, @error_msg);
END;
```

3. **Profiling de procedures**
```sql
-- Activar profiling
SET profiling = 1;
CALL mi_procedure();
SHOW PROFILES;
SHOW PROFILE FOR QUERY 1;
```

### Problemas Comunes

1. **Deadlocks en triggers**
   - Evitar operaciones circulares
   - Ordenar acceso a tablas consistentemente

2. **Performance degradation**
   - Monitorear tiempo de ejecución
   - Identificar procedures lentos

3. **Recursive triggers**
   - Controlar profundidad de recursión
   - Usar banderas para prevenir loops infinitos

---

## 📝 Ejercicios Prácticos

### Ejercicio 1: Sistema de Auditoría
Implementar un sistema completo de auditoría que:
- Registre todos los cambios en tablas críticas
- Mantenga historial de versiones
- Permita rollback de cambios

### Ejercicio 2: Workflow de Aprobaciones
Crear un sistema de procedures que:
- Gestione flujos de aprobación multinivel
- Envíe notificaciones automáticas
- Mantenga estados de documentos

### Ejercicio 3: Procesamiento de Datos Masivos
Desarrollar procedures para:
- Procesar millones de registros en lotes
- Generar reportes complejos
- Mantener performance óptima

---

## 🔗 Recursos Adicionales

- [MySQL Stored Procedure Documentation](https://dev.mysql.com/doc/refman/8.0/en/stored-routines.html)
- [MySQL Trigger Documentation](https://dev.mysql.com/doc/refman/8.0/en/triggers.html)
- [Best Practices for MySQL Stored Procedures](https://dev.mysql.com/doc/refman/8.0/en/stored-routines-syntax.html)

---

*Última actualización: 28/05/2025*
