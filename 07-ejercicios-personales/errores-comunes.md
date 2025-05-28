# Errores Comunes en MySQL - Guía de Prevención y Solución

## 📋 Índice

1. [Errores de Sintaxis](#errores-de-sintaxis)
2. [Errores de Lógica](#errores-de-lógica)
3. [Errores de Rendimiento](#errores-de-rendimiento)
4. [Errores de Diseño](#errores-de-diseño)
5. [Errores de Datos](#errores-de-datos)
6. [Mejores Prácticas](#mejores-prácticas)

## 💥 Errores de Sintaxis

### Error 1: Comas Faltantes o Sobran

**❌ Incorrecto:**
```sql
SELECT nombre apellido, email
FROM usuarios;

SELECT nombre, apellido email
FROM usuarios;
```

**✅ Correcto:**
```sql
SELECT nombre, apellido, email
FROM usuarios;
```

**Prevención:**
- Revisar cada coma en SELECT
- Usar formateo consistente con saltos de línea
- Validar sintaxis antes de ejecutar

### Error 2: Comillas Inconsistentes

**❌ Incorrecto:**
```sql
SELECT * FROM usuarios WHERE nombre = "Juan';
SELECT * FROM usuarios WHERE nombre = 'Juan";
SELECT * FROM usuarios WHERE fecha = 2025-05-28;
```

**✅ Correcto:**
```sql
SELECT * FROM usuarios WHERE nombre = 'Juan';
SELECT * FROM usuarios WHERE nombre = "Juan";
SELECT * FROM usuarios WHERE fecha = '2025-05-28';
```

**Prevención:**
- Usar comillas simples para strings
- Siempre encerrar fechas en comillas
- Mantener consistencia en el estilo

### Error 3: Palabras Reservadas como Nombres

**❌ Incorrecto:**
```sql
CREATE TABLE order (
    id INT,
    date DATE,
    user VARCHAR(50)
);

SELECT order, date FROM order;
```

**✅ Correcto:**
```sql
CREATE TABLE `order` (
    id INT,
    `date` DATE,
    `user` VARCHAR(50)
);

-- O mejor aún, usar nombres descriptivos
CREATE TABLE pedidos (
    id INT,
    fecha_pedido DATE,
    usuario VARCHAR(50)
);
```

### Error 4: Paréntesis Desbalanceados

**❌ Incorrecto:**
```sql
SELECT * FROM usuarios 
WHERE (edad > 18 AND ciudad = 'Madrid'
OR (estado = 'activo');

SELECT COUNT(*) FROM pedidos 
WHERE fecha BETWEEN ('2025-01-01' AND '2025-12-31');
```

**✅ Correcto:**
```sql
SELECT * FROM usuarios 
WHERE (edad > 18 AND ciudad = 'Madrid') 
OR (estado = 'activo');

SELECT COUNT(*) FROM pedidos 
WHERE fecha BETWEEN '2025-01-01' AND '2025-12-31';
```

## 🧠 Errores de Lógica

### Error 5: NULL en Comparaciones

**❌ Problemático:**
```sql
-- Esto NO encuentra registros con salario NULL
SELECT * FROM empleados WHERE salario != 5000;

-- Esto tampoco funciona como esperado
SELECT * FROM empleados WHERE salario = NULL;
```

**✅ Correcto:**
```sql
-- Para excluir NULLs explícitamente
SELECT * FROM empleados 
WHERE salario != 5000 AND salario IS NOT NULL;

-- Para encontrar NULLs
SELECT * FROM empleados WHERE salario IS NULL;

-- Para incluir NULLs en comparaciones
SELECT * FROM empleados 
WHERE salario != 5000 OR salario IS NULL;
```

**Conceptos clave:**
- NULL no es igual a nada, ni siquiera a sí mismo
- Usar `IS NULL` e `IS NOT NULL` para comparaciones con NULL
- Considerar NULLs en todas las condiciones WHERE

### Error 6: Agregaciones sin GROUP BY

**❌ Incorrecto:**
```sql
-- Error SQL_MODE=ONLY_FULL_GROUP_BY
SELECT departamento, COUNT(*), nombre
FROM empleados;
```

**✅ Correcto:**
```sql
-- Opción 1: GROUP BY apropiado
SELECT departamento, COUNT(*) as total_empleados
FROM empleados
GROUP BY departamento;

-- Opción 2: Si necesitas nombres específicos
SELECT 
    departamento, 
    COUNT(*) as total_empleados,
    GROUP_CONCAT(nombre) as lista_empleados
FROM empleados
GROUP BY departamento;

-- Opción 3: Usar window functions
SELECT DISTINCT
    departamento,
    COUNT(*) OVER (PARTITION BY departamento) as total_empleados
FROM empleados;
```

### Error 7: HAVING vs WHERE Confusion

**❌ Incorrecto:**
```sql
-- Usar HAVING para filtros no relacionados con agregaciones
SELECT departamento, COUNT(*) 
FROM empleados
HAVING departamento = 'Ventas'
GROUP BY departamento;

-- Usar WHERE con funciones de agregación
SELECT departamento, COUNT(*) as total
FROM empleados
WHERE COUNT(*) > 5
GROUP BY departamento;
```

**✅ Correcto:**
```sql
-- WHERE para filtrar filas antes de agrupar
SELECT departamento, COUNT(*) 
FROM empleados
WHERE departamento = 'Ventas'
GROUP BY departamento;

-- HAVING para filtrar grupos después de agregar
SELECT departamento, COUNT(*) as total
FROM empleados
GROUP BY departamento
HAVING COUNT(*) > 5;

-- Combinación correcta
SELECT departamento, AVG(salario) as salario_promedio
FROM empleados
WHERE fecha_contratacion >= '2020-01-01'  -- Filtrar empleados
GROUP BY departamento
HAVING AVG(salario) > 50000;  -- Filtrar departamentos
```

### Error 8: Subconsultas Ineficientes

**❌ Ineficiente:**
```sql
-- Subconsulta correlacionada costosa
SELECT e1.nombre, e1.salario
FROM empleados e1
WHERE e1.salario > (
    SELECT AVG(e2.salario)
    FROM empleados e2
    WHERE e2.departamento_id = e1.departamento_id
);
```

**✅ Optimizado:**
```sql
-- Usar window function
SELECT nombre, salario
FROM (
    SELECT 
        nombre, 
        salario,
        AVG(salario) OVER (PARTITION BY departamento_id) as avg_dept_salary
    FROM empleados
) ranked
WHERE salario > avg_dept_salary;

-- O usar JOIN con subquery
SELECT e.nombre, e.salario
FROM empleados e
JOIN (
    SELECT departamento_id, AVG(salario) as avg_salary
    FROM empleados
    GROUP BY departamento_id
) dept_avg ON e.departamento_id = dept_avg.departamento_id
WHERE e.salario > dept_avg.avg_salary;
```

## ⚡ Errores de Rendimiento

### Error 9: Funciones en WHERE que Impiden Índices

**❌ No usa índices:**
```sql
SELECT * FROM ventas WHERE YEAR(fecha) = 2025;
SELECT * FROM usuarios WHERE UPPER(nombre) = 'JUAN';
SELECT * FROM productos WHERE precio * 1.16 > 100;
```

**✅ Optimizado:**
```sql
-- Reescribir sin funciones
SELECT * FROM ventas 
WHERE fecha >= '2025-01-01' AND fecha < '2026-01-01';

-- Usar índice funcional (MySQL 8.0+) o normalizar datos
CREATE INDEX idx_nombre_upper ON usuarios ((UPPER(nombre)));
SELECT * FROM usuarios WHERE UPPER(nombre) = 'JUAN';

-- Invertir la operación
SELECT * FROM productos WHERE precio > 100 / 1.16;
```

### Error 10: SELECT * en Producción

**❌ Problemático:**
```sql
-- Trae columnas innecesarias
SELECT * FROM usuarios WHERE ciudad = 'Madrid';

-- Con JOINs es peor
SELECT *
FROM pedidos p
JOIN clientes c ON p.cliente_id = c.id
JOIN productos pr ON p.producto_id = pr.id;
```

**✅ Optimizado:**
```sql
-- Solo columnas necesarias
SELECT id, nombre, email FROM usuarios WHERE ciudad = 'Madrid';

-- JOINs específicos
SELECT 
    p.id,
    p.fecha,
    c.nombre as cliente,
    pr.nombre as producto
FROM pedidos p
JOIN clientes c ON p.cliente_id = c.id
JOIN productos pr ON p.producto_id = pr.id;
```

### Error 11: LIMIT sin ORDER BY

**❌ Resultados inconsistentes:**
```sql
-- El orden puede cambiar entre ejecuciones
SELECT * FROM productos LIMIT 10;
```

**✅ Consistente:**
```sql
-- Siempre especificar orden
SELECT * FROM productos ORDER BY id LIMIT 10;
SELECT * FROM productos ORDER BY nombre, id LIMIT 10;
```

### Error 12: N+1 Query Problem

**❌ Ineficiente:**
```sql
-- Primero obtener usuarios
SELECT id FROM usuarios WHERE activo = 1;

-- Luego por cada usuario (N queries)
SELECT COUNT(*) FROM pedidos WHERE usuario_id = ?;
```

**✅ Eficiente:**
```sql
-- Una sola query con JOIN
SELECT 
    u.id,
    u.nombre,
    COUNT(p.id) as total_pedidos
FROM usuarios u
LEFT JOIN pedidos p ON u.id = p.usuario_id
WHERE u.activo = 1
GROUP BY u.id, u.nombre;
```

## 🏗️ Errores de Diseño

### Error 13: Falta de Índices Estratégicos

**❌ Sin índices apropiados:**
```sql
-- Tabla sin índices en columnas de búsqueda frecuente
CREATE TABLE pedidos (
    id INT PRIMARY KEY,
    cliente_id INT,  -- Sin índice
    fecha DATE,      -- Sin índice
    estado VARCHAR(20) -- Sin índice
);

-- Consultas lentas resultantes
SELECT * FROM pedidos WHERE cliente_id = 100;
SELECT * FROM pedidos WHERE fecha >= '2025-01-01';
```

**✅ Con índices estratégicos:**
```sql
CREATE TABLE pedidos (
    id INT PRIMARY KEY,
    cliente_id INT,
    fecha DATE,
    estado VARCHAR(20),
    INDEX idx_cliente (cliente_id),
    INDEX idx_fecha (fecha),
    INDEX idx_estado (estado),
    INDEX idx_cliente_fecha (cliente_id, fecha)  -- Índice compuesto
);
```

### Error 14: Tipos de Datos Inadecuados

**❌ Tipos incorrectos:**
```sql
CREATE TABLE eventos (
    id VARCHAR(20),  -- Debería ser INT AUTO_INCREMENT
    activo VARCHAR(1),  -- Debería ser BOOLEAN
    fecha VARCHAR(50),  -- Debería ser DATE/DATETIME
    precio VARCHAR(20)  -- Debería ser DECIMAL
);
```

**✅ Tipos apropiados:**
```sql
CREATE TABLE eventos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    activo BOOLEAN DEFAULT TRUE,
    fecha DATETIME NOT NULL,
    precio DECIMAL(10,2)
);
```

### Error 15: Falta de Constraints

**❌ Sin validaciones:**
```sql
CREATE TABLE usuarios (
    id INT PRIMARY KEY,
    email VARCHAR(100),
    edad INT,
    estado VARCHAR(20)
);
```

**✅ Con constraints apropiados:**
```sql
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    edad INT CHECK (edad >= 0 AND edad <= 150),
    estado ENUM('activo', 'inactivo', 'suspendido') DEFAULT 'activo',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 📊 Errores de Datos

### Error 16: Duplicados por Falta de DISTINCT

**❌ Duplicados inesperados:**
```sql
-- JOIN puede crear duplicados
SELECT c.nombre, p.categoria
FROM clientes c
JOIN pedidos pe ON c.id = pe.cliente_id
JOIN productos p ON pe.producto_id = p.id;
```

**✅ Con manejo adecuado:**
```sql
-- Usar DISTINCT cuando sea necesario
SELECT DISTINCT c.nombre, p.categoria
FROM clientes c
JOIN pedidos pe ON c.id = pe.cliente_id
JOIN productos p ON pe.producto_id = p.id;

-- O mejor, ser específico sobre lo que quieres
SELECT 
    c.nombre,
    GROUP_CONCAT(DISTINCT p.categoria) as categorias_compradas
FROM clientes c
JOIN pedidos pe ON c.id = pe.cliente_id
JOIN productos p ON pe.producto_id = p.id
GROUP BY c.id, c.nombre;
```

### Error 17: Problemas de Encoding

**❌ Caracteres especiales mal manejados:**
```sql
-- Base de datos en latin1, aplicación en UTF-8
INSERT INTO productos (nombre) VALUES ('Niño');
-- Resultado: Ni├▒o
```

**✅ Encoding consistente:**
```sql
-- Configurar base de datos y tablas
CREATE DATABASE tienda CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE productos (
    nombre VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
);

-- Verificar configuración
SHOW VARIABLES LIKE 'character_set%';
```

### Error 18: División por Cero

**❌ Error en runtime:**
```sql
SELECT 
    producto,
    ventas_totales / ventas_año_anterior as crecimiento
FROM reporte_ventas;
-- Error si ventas_año_anterior = 0
```

**✅ Con manejo seguro:**
```sql
SELECT 
    producto,
    CASE 
        WHEN ventas_año_anterior = 0 OR ventas_año_anterior IS NULL THEN NULL
        ELSE ventas_totales / ventas_año_anterior
    END as crecimiento
FROM reporte_ventas;

-- O usar NULLIF
SELECT 
    producto,
    ventas_totales / NULLIF(ventas_año_anterior, 0) as crecimiento
FROM reporte_ventas;
```

## 💡 Mejores Prácticas

### Prevención General

1. **Usar SQL_MODE estricto:**
```sql
SET SQL_MODE = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
```

2. **Validar consultas antes de producción:**
```sql
-- Usar EXPLAIN para verificar planes
EXPLAIN SELECT * FROM tabla WHERE condicion;

-- Limitar resultados en testing
SELECT * FROM tabla WHERE condicion LIMIT 100;
```

3. **Documentar consultas complejas:**
```sql
-- Comentar la lógica de negocio
SELECT 
    c.nombre,
    -- Calcular valor de vida del cliente (últimos 12 meses)
    SUM(CASE 
        WHEN p.fecha >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH) 
        THEN p.total 
        ELSE 0 
    END) as clv_12m
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
GROUP BY c.id, c.nombre;
```

4. **Usar transacciones para operaciones críticas:**
```sql
START TRANSACTION;

UPDATE productos SET stock = stock - 1 WHERE id = 123;
INSERT INTO pedidos (cliente_id, producto_id, cantidad) VALUES (456, 123, 1);

-- Verificar que todo esté correcto antes de commit
SELECT stock FROM productos WHERE id = 123;

COMMIT;
-- O ROLLBACK si algo está mal
```

5. **Manejo de errores en aplicaciones:**
```sql
-- En código de aplicación, siempre manejar excepciones SQL
try {
    // Ejecutar consulta
} catch (SQLException e) {
    // Log del error específico
    // Rollback si es necesario
    // Mensaje amigable al usuario
}
```

### Checklist de Revisión

✅ **Antes de ejecutar cualquier consulta:**
- [ ] ¿Hay índices apropiados para las condiciones WHERE?
- [ ] ¿Estoy seleccionando solo las columnas necesarias?
- [ ] ¿He manejado correctamente los valores NULL?
- [ ] ¿La consulta tiene ORDER BY si uso LIMIT?
- [ ] ¿He validado la sintaxis y lógica?

✅ **Para consultas de modificación (UPDATE/DELETE):**
- [ ] ¿Tengo backup reciente?
- [ ] ¿He probado la condición WHERE con SELECT primero?
- [ ] ¿Estoy usando transacciones si es crítico?
- [ ] ¿He verificado el número de filas afectadas?

✅ **Para consultas en producción:**
- [ ] ¿He probado con datos reales en ambiente de staging?
- [ ] ¿El rendimiento es aceptable con volúmenes reales?
- [ ] ¿He documentado la consulta si es compleja?
- [ ] ¿Tengo plan de rollback si algo sale mal?

## 🔧 Herramientas de Debugging

### Usar EXPLAIN efectivamente:
```sql
-- Para consultas SELECT
EXPLAIN EXTENDED SELECT * FROM tabla WHERE condicion;

-- Para consultas UPDATE/DELETE
EXPLAIN UPDATE tabla SET campo = valor WHERE condicion;

-- Formato JSON para más detalles
EXPLAIN FORMAT=JSON SELECT * FROM tabla;
```

### Activar query log para debugging:
```sql
SET GLOBAL general_log = 'ON';
SET GLOBAL log_output = 'TABLE';

-- Ver queries ejecutadas
SELECT * FROM mysql.general_log ORDER BY event_time DESC LIMIT 10;
```

### Monitorear queries lentas:
```sql
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 1;  -- Queries > 1 segundo

-- Analizar slow query log
-- mysqldumpslow /path/to/slow-query.log
```

---

**Recuerda:** La mejor forma de evitar errores es escribir código SQL defensivo, probar exhaustivamente y mantener buenas prácticas de desarrollo desde el inicio.
