# Índices en MySQL - Explicación Completa

## 📋 Índice

1. [¿Qué son los Índices?](#qué-son-los-índices)
2. [Tipos de Índices](#tipos-de-índices)
3. [Cuándo Usar Índices](#cuándo-usar-índices)
4. [Creación y Gestión](#creación-y-gestión)
5. [Mejores Prácticas](#mejores-prácticas)
6. [Casos de Uso Avanzados](#casos-de-uso-avanzados)

## 🔍 ¿Qué son los Índices?

Los **índices** son estructuras de datos que mejoran la velocidad de las operaciones de consulta en una tabla de base de datos. Funcionan como un "índice de libro" que permite encontrar información rápidamente sin tener que leer toda la tabla.

### Analogía del Índice de Libro
- **Sin índice**: Leer todo el libro página por página para encontrar un tema
- **Con índice**: Ir directamente a la página indicada en el índice

### Cómo Funcionan Internamente

Los índices en MySQL utilizan principalmente estructuras **B-Tree** (Balanced Tree):

```
        [50]
       /    \
   [25]      [75]
   /  \      /  \
[10][35] [60][90]
```

- **Búsqueda O(log n)** en lugar de O(n)
- **Equilibrio automático** del árbol
- **Múltiples niveles** para grandes conjuntos de datos

## 🗂️ Tipos de Índices

### 1. Índice Primario (PRIMARY KEY)

```sql
-- Automático al definir PRIMARY KEY
CREATE TABLE empleados (
    id INT PRIMARY KEY,
    nombre VARCHAR(100)
);

-- O explícitamente
ALTER TABLE empleados ADD PRIMARY KEY (id);
```

**Características:**
- Único por tabla
- No permite valores NULL
- Automáticamente crea un índice clusterizado
- Mejor rendimiento para consultas por ID

### 2. Índice Único (UNIQUE)

```sql
-- Al crear la tabla
CREATE TABLE usuarios (
    id INT PRIMARY KEY,
    email VARCHAR(100) UNIQUE,
    username VARCHAR(50) UNIQUE
);

-- Agregar después
ALTER TABLE usuarios ADD UNIQUE KEY idx_email (email);
CREATE UNIQUE INDEX idx_username ON usuarios (username);
```

**Características:**
- Garantiza unicidad de valores
- Permite un valor NULL (MySQL)
- Automáticamente usado para consultas de igualdad

### 3. Índice Regular (INDEX)

```sql
-- Índice simple
CREATE INDEX idx_apellido ON empleados (apellido);

-- Índice compuesto
CREATE INDEX idx_dept_salario ON empleados (departamento_id, salario);

-- Índice con longitud específica (para VARCHAR largos)
CREATE INDEX idx_descripcion ON productos (descripcion(100));
```

### 4. Índice de Texto Completo (FULLTEXT)

```sql
-- Para búsquedas de texto
ALTER TABLE articulos ADD FULLTEXT(titulo, contenido);

-- Uso
SELECT * FROM articulos 
WHERE MATCH(titulo, contenido) AGAINST('mysql database' IN NATURAL LANGUAGE MODE);
```

### 5. Índice Espacial (SPATIAL)

```sql
-- Para datos geoespaciales
CREATE TABLE ubicaciones (
    id INT PRIMARY KEY,
    punto POINT NOT NULL,
    SPATIAL INDEX(punto)
);
```

### 6. Índices Funcionales (MySQL 8.0+)

```sql
-- Índice en expresión
CREATE INDEX idx_year_fecha ON ventas ((YEAR(fecha_venta)));

-- Índice en función
CREATE INDEX idx_email_lower ON usuarios ((LOWER(email)));
```

## ⚡ Cuándo Usar Índices

### Escenarios IDEALES para Índices

#### 1. Columnas en WHERE frecuentes
```sql
-- Si esta consulta es común
SELECT * FROM empleados WHERE departamento_id = 5;

-- Crear este índice
CREATE INDEX idx_departamento ON empleados (departamento_id);
```

#### 2. Columnas en JOIN
```sql
-- Para este tipo de joins
SELECT e.nombre, d.nombre 
FROM empleados e 
JOIN departamentos d ON e.departamento_id = d.id;

-- Asegurar índices
CREATE INDEX idx_emp_dept ON empleados (departamento_id);
-- d.id ya tiene índice como PRIMARY KEY
```

#### 3. Columnas en ORDER BY
```sql
-- Para ordenamiento rápido
SELECT * FROM productos ORDER BY precio DESC;

-- Crear índice
CREATE INDEX idx_precio ON productos (precio);
```

#### 4. Rangos de Valores
```sql
-- Consultas de rango
SELECT * FROM ventas WHERE fecha BETWEEN '2025-01-01' AND '2025-12-31';

-- Índice beneficioso
CREATE INDEX idx_fecha ON ventas (fecha);
```

### Escenarios PROBLEMÁTICOS para Índices

#### 1. Tablas Muy Pequeñas
```sql
-- Para tabla con < 1000 filas, el índice puede ser innecesario
-- El escaneo completo puede ser más rápido
```

#### 2. Columnas que Cambian Frecuentemente
```sql
-- Si 'estado' cambia constantemente
UPDATE pedidos SET estado = 'completado' WHERE id = 123;
-- El índice en 'estado' requiere actualizaciones constantes
```

#### 3. Funciones en WHERE sin Índice Funcional
```sql
-- Este índice NO se usará
CREATE INDEX idx_email ON usuarios (email);

-- Con esta consulta
SELECT * FROM usuarios WHERE UPPER(email) = 'JUAN@EMAIL.COM';

-- Solución: índice funcional
CREATE INDEX idx_email_upper ON usuarios ((UPPER(email)));
```

## 🛠️ Creación y Gestión

### Sintaxis de Creación

```sql
-- Múltiples formas de crear índices

-- 1. En CREATE TABLE
CREATE TABLE productos (
    id INT PRIMARY KEY,
    nombre VARCHAR(100),
    categoria_id INT,
    precio DECIMAL(10,2),
    INDEX idx_categoria (categoria_id),
    INDEX idx_precio (precio),
    INDEX idx_cat_precio (categoria_id, precio)
);

-- 2. Con ALTER TABLE
ALTER TABLE productos 
ADD INDEX idx_nombre (nombre),
ADD INDEX idx_search (nombre, categoria_id, precio);

-- 3. Con CREATE INDEX
CREATE INDEX idx_descripcion ON productos (descripcion);
```

### Eliminación de Índices

```sql
-- Eliminar índice
DROP INDEX idx_nombre ON productos;

-- Con ALTER TABLE
ALTER TABLE productos DROP INDEX idx_categoria;

-- Verificar índices existentes
SHOW INDEXES FROM productos;
```

### Análisis de Índices

```sql
-- Ver información detallada de índices
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    COLUMN_NAME,
    SEQ_IN_INDEX,
    CARDINALITY,
    INDEX_TYPE
FROM INFORMATION_SCHEMA.STATISTICS 
WHERE TABLE_SCHEMA = 'mi_base_datos'
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;
```

## 🎯 Mejores Prácticas

### 1. Orden en Índices Compuestos

```sql
-- CORRECTO: Más selectivo primero
CREATE INDEX idx_search ON empleados (departamento_id, cargo, salario);

-- Para consultas como:
WHERE departamento_id = 5 AND cargo = 'Manager'
WHERE departamento_id = 5 AND cargo = 'Manager' AND salario > 50000
WHERE departamento_id = 5  -- También se puede usar

-- INCORRECTO: Menos selectivo primero
CREATE INDEX idx_bad ON empleados (activo, departamento_id, cargo);
-- Si 'activo' solo tiene valores TRUE/FALSE (baja selectividad)
```

### 2. Regla del Prefijo Izquierdo

```sql
-- Índice compuesto
CREATE INDEX idx_fecha_cliente_producto ON ventas (fecha, cliente_id, producto_id);

-- Estas consultas PUEDEN usar el índice:
WHERE fecha = '2025-05-28'
WHERE fecha = '2025-05-28' AND cliente_id = 100
WHERE fecha = '2025-05-28' AND cliente_id = 100 AND producto_id = 50

-- Estas consultas NO pueden usar el índice eficientemente:
WHERE cliente_id = 100
WHERE producto_id = 50
WHERE cliente_id = 100 AND producto_id = 50
```

### 3. Longitud de Índices para VARCHAR

```sql
-- Para columnas VARCHAR largas, usar prefijo
CREATE INDEX idx_descripcion ON productos (descripcion(50));

-- Analizar la longitud óptima
SELECT 
    COUNT(DISTINCT LEFT(descripcion, 10)) as dist_10,
    COUNT(DISTINCT LEFT(descripcion, 20)) as dist_20,
    COUNT(DISTINCT LEFT(descripcion, 50)) as dist_50,
    COUNT(DISTINCT descripcion) as dist_total
FROM productos;
```

### 4. Monitoreo de Uso de Índices

```sql
-- MySQL 5.6+: Verificar índices no utilizados
SELECT 
    object_schema,
    object_name,
    index_name
FROM performance_schema.table_io_waits_summary_by_index_usage 
WHERE index_name IS NOT NULL
AND count_star = 0
AND object_schema != 'mysql'
ORDER BY object_schema, object_name;
```

## 🚀 Casos de Uso Avanzados

### 1. Índices para Consultas de Cobertura

```sql
-- Consulta común
SELECT cliente_id, fecha, total 
FROM ventas 
WHERE fecha BETWEEN '2025-01-01' AND '2025-12-31'
ORDER BY fecha;

-- Índice de cobertura (incluye todas las columnas necesarias)
CREATE INDEX idx_covering ON ventas (fecha, cliente_id, total);
-- MySQL puede resolver la consulta solo con el índice, sin acceder a la tabla
```

### 2. Índices Parciales Simulados

```sql
-- MySQL no tiene índices parciales nativos, pero se pueden simular

-- Crear columna computed para índice condicional
ALTER TABLE pedidos ADD COLUMN activo_computed BOOLEAN 
GENERATED ALWAYS AS (CASE WHEN estado = 'activo' THEN TRUE ELSE NULL END) STORED;

CREATE INDEX idx_activos ON pedidos (activo_computed);

-- Solo indexa filas donde estado = 'activo'
```

### 3. Índices para Consultas de Agregación

```sql
-- Para consultas como:
SELECT departamento_id, COUNT(*), AVG(salario)
FROM empleados 
GROUP BY departamento_id;

-- Índice optimizado
CREATE INDEX idx_dept_salario ON empleados (departamento_id, salario);
```

### 4. Índices Hash (MEMORY Engine)

```sql
-- Para tablas temporales en memoria
CREATE TEMPORARY TABLE cache_datos (
    id INT PRIMARY KEY,
    clave VARCHAR(50),
    valor TEXT,
    INDEX USING HASH (clave)
) ENGINE=MEMORY;
```

## ⚠️ Consideraciones Importantes

### Costos de los Índices

1. **Espacio de Almacenamiento**
   - Índices ocupan espacio adicional
   - Índices compuestos ocupan más espacio

2. **Rendimiento de Escritura**
   - INSERT/UPDATE/DELETE son más lentos
   - Cada índice debe actualizarse

3. **Mantenimiento**
   - Fragmentación de índices
   - Estadísticas desactualizadas

### Análisis de Rendimiento

```sql
-- Analizar fragmentación de índices
SELECT 
    s.table_schema,
    s.table_name,
    s.index_name,
    s.data_length,
    s.index_length,
    ROUND(s.data_length / 1024 / 1024, 2) AS data_size_mb,
    ROUND(s.index_length / 1024 / 1024, 2) AS index_size_mb
FROM information_schema.tables s
WHERE s.table_schema = 'mi_base_datos'
ORDER BY s.index_length DESC;
```

## 🎓 Ejercicios Prácticos

### Ejercicio 1: Análisis de Consultas
```sql
-- Analizar estas consultas y proponer índices
SELECT * FROM pedidos WHERE cliente_id = 100 AND fecha > '2025-01-01';
SELECT COUNT(*) FROM productos WHERE categoria_id = 5 AND precio BETWEEN 100 AND 500;
SELECT * FROM empleados WHERE departamento_id = 3 ORDER BY salario DESC LIMIT 10;
```

### Ejercicio 2: Optimización de Índice Compuesto
```sql
-- ¿Cuál es el mejor orden para este índice?
-- Consulta frecuente: WHERE activo = 1 AND ciudad = 'Madrid' AND edad BETWEEN 25 AND 35
CREATE INDEX idx_search ON usuarios (?, ?, ?);
```

### Ejercicio 3: Índice de Cobertura
```sql
-- Diseñar un índice de cobertura para:
SELECT producto_id, SUM(cantidad), AVG(precio)
FROM detalle_ventas 
WHERE fecha BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY producto_id;
```

---

**Recuerda**: Los índices son herramientas poderosas, pero deben usarse con criterio. Más índices no siempre significa mejor rendimiento.
