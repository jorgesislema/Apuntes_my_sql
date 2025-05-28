# Ejercicios de Optimización - MySQL Avanzado

## 🎯 Objetivos

- Aplicar técnicas de optimización en casos reales
- Analizar y mejorar consultas lentas
- Diseñar índices eficientes
- Identificar y resolver cuellos de botella

## 📊 Ejercicio 1: Análisis de Rendimiento de E-commerce

### Contexto
Tienes una base de datos de e-commerce con las siguientes tablas:

```sql
-- Esquema de ejemplo
CREATE TABLE categorias (
    id INT PRIMARY KEY,
    nombre VARCHAR(100),
    padre_id INT
);

CREATE TABLE productos (
    id INT PRIMARY KEY,
    nombre VARCHAR(200),
    descripcion TEXT,
    precio DECIMAL(10,2),
    categoria_id INT,
    stock INT,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE clientes (
    id INT PRIMARY KEY,
    nombre VARCHAR(100),
    email VARCHAR(150),
    ciudad VARCHAR(100),
    fecha_registro DATE
);

CREATE TABLE pedidos (
    id INT PRIMARY KEY,
    cliente_id INT,
    fecha DATETIME,
    estado ENUM('pendiente', 'procesando', 'enviado', 'entregado', 'cancelado'),
    total DECIMAL(12,2)
);

CREATE TABLE detalle_pedidos (
    id INT PRIMARY KEY,
    pedido_id INT,
    producto_id INT,
    cantidad INT,
    precio_unitario DECIMAL(10,2)
);
```

### Problema 1.1: Consulta Lenta de Productos Populares

**Consulta problemática:**
```sql
SELECT 
    p.nombre,
    COUNT(dp.id) as veces_vendido,
    SUM(dp.cantidad) as total_vendido
FROM productos p
LEFT JOIN detalle_pedidos dp ON p.id = dp.producto_id
LEFT JOIN pedidos pe ON dp.pedido_id = pe.id
WHERE pe.fecha >= '2024-01-01'
OR pe.fecha IS NULL
GROUP BY p.id, p.nombre
ORDER BY veces_vendido DESC, total_vendido DESC
LIMIT 20;
```

**Tareas:**
1. Analizar la consulta con `EXPLAIN`
2. Identificar problemas de rendimiento
3. Proponer y crear índices optimizados
4. Reescribir la consulta si es necesario
5. Comparar el rendimiento antes y después

**Solución esperada:**
- Análisis de plan de ejecución
- Índices propuestos
- Consulta optimizada
- Métricas de mejora

### Problema 1.2: Reporte de Ventas Mensuales

**Consulta problemática:**
```sql
SELECT 
    YEAR(pe.fecha) as año,
    MONTH(pe.fecha) as mes,
    COUNT(DISTINCT pe.id) as total_pedidos,
    COUNT(DISTINCT pe.cliente_id) as clientes_unicos,
    SUM(pe.total) as ingresos_totales,
    AVG(pe.total) as ticket_promedio
FROM pedidos pe
WHERE pe.estado = 'entregado'
AND pe.fecha BETWEEN '2023-01-01' AND '2025-12-31'
GROUP BY YEAR(pe.fecha), MONTH(pe.fecha)
ORDER BY año DESC, mes DESC;
```

**Tareas:**
1. Usar `EXPLAIN` para analizar la consulta
2. Identificar el uso de funciones que impiden índices
3. Optimizar sin usar funciones en WHERE
4. Crear índices apropiados
5. Medir la mejora de rendimiento

## 🔧 Ejercicio 2: Optimización de Consultas Complejas

### Problema 2.1: Clientes VIP

Necesitas identificar clientes VIP basado en múltiples criterios:

```sql
SELECT 
    c.id,
    c.nombre,
    c.email,
    COUNT(DISTINCT pe.id) as total_pedidos,
    SUM(pe.total) as total_gastado,
    AVG(pe.total) as promedio_por_pedido,
    MAX(pe.fecha) as ultima_compra,
    DATEDIFF(CURDATE(), MAX(pe.fecha)) as dias_sin_comprar
FROM clientes c
LEFT JOIN pedidos pe ON c.id = pe.cliente_id
WHERE pe.estado IN ('entregado', 'enviado')
AND pe.fecha >= DATE_SUB(CURDATE(), INTERVAL 2 YEAR)
GROUP BY c.id, c.nombre, c.email
HAVING total_pedidos >= 5 
AND total_gastado >= 1000
AND dias_sin_comprar <= 90
ORDER BY total_gastado DESC, total_pedidos DESC;
```

**Retos:**
1. Optimizar la consulta para manejo de millones de registros
2. Crear índices que soporten todas las condiciones
3. Considerar desnormalización si es necesario
4. Proponer estrategias de cache

### Problema 2.2: Análisis de Productos por Categoría

```sql
SELECT 
    cat.nombre as categoria,
    COUNT(DISTINCT p.id) as total_productos,
    COUNT(DISTINCT CASE WHEN p.stock > 0 THEN p.id END) as productos_disponibles,
    AVG(p.precio) as precio_promedio,
    SUM(COALESCE(ventas.total_vendido, 0)) as unidades_vendidas,
    SUM(COALESCE(ventas.ingresos, 0)) as ingresos_categoria
FROM categorias cat
LEFT JOIN productos p ON cat.id = p.categoria_id
LEFT JOIN (
    SELECT 
        dp.producto_id,
        SUM(dp.cantidad) as total_vendido,
        SUM(dp.cantidad * dp.precio_unitario) as ingresos
    FROM detalle_pedidos dp
    JOIN pedidos pe ON dp.pedido_id = pe.id
    WHERE pe.estado = 'entregado'
    AND pe.fecha >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
    GROUP BY dp.producto_id
) ventas ON p.id = ventas.producto_id
WHERE cat.padre_id IS NULL
GROUP BY cat.id, cat.nombre
ORDER BY ingresos_categoria DESC;
```

**Tareas:**
1. Analizar la subconsulta y su impacto
2. Considerar convertir subconsulta a CTE o tabla temporal
3. Optimizar con índices apropiados
4. Evaluar si es mejor un enfoque con múltiples consultas simples

## 📈 Ejercicio 3: Diseño de Índices Estratégicos

### Escenario
Analiza estos patrones de consulta frecuentes y diseña una estrategia de índices:

**Consulta A (80% del tráfico):**
```sql
SELECT * FROM productos 
WHERE categoria_id = ? AND activo = 1 AND precio BETWEEN ? AND ?
ORDER BY nombre;
```

**Consulta B (15% del tráfico):**
```sql
SELECT p.*, c.nombre as categoria
FROM productos p
JOIN categorias c ON p.categoria_id = c.id
WHERE p.nombre LIKE ? AND p.activo = 1;
```

**Consulta C (5% del tráfico):**
```sql
SELECT cliente_id, COUNT(*), SUM(total)
FROM pedidos
WHERE fecha >= ? AND estado = 'entregado'
GROUP BY cliente_id
ORDER BY SUM(total) DESC;
```

**Tareas:**
1. Diseñar índices óptimos para cada consulta
2. Considerar índices compuestos vs. múltiples índices simples
3. Evaluar el impacto en operaciones DML (INSERT/UPDATE/DELETE)
4. Proponer un plan de implementación gradual

## 🎭 Ejercicio 4: Casos Extremos y Edge Cases

### Problema 4.1: Consulta de Búsqueda Full-Text

Optimiza esta búsqueda de productos:

```sql
SELECT * FROM productos 
WHERE (nombre LIKE '%smartphone%' 
   OR descripcion LIKE '%smartphone%')
AND categoria_id IN (1, 2, 3, 5, 8)
AND precio BETWEEN 200 AND 800
AND activo = 1
ORDER BY 
    CASE 
        WHEN nombre LIKE 'smartphone%' THEN 1
        WHEN nombre LIKE '%smartphone%' THEN 2
        ELSE 3
    END,
    precio ASC;
```

**Retos:**
1. Implementar FULLTEXT search
2. Optimizar el ranking personalizado
3. Manejar búsquedas con múltiples términos
4. Considerar alternativas como Elasticsearch

### Problema 4.2: Consulta de Inventario en Tiempo Real

```sql
SELECT 
    p.id,
    p.nombre,
    p.stock as stock_actual,
    COALESCE(SUM(CASE 
        WHEN pe.estado IN ('pendiente', 'procesando') 
        THEN dp.cantidad 
        ELSE 0 
    END), 0) as stock_reservado,
    p.stock - COALESCE(SUM(CASE 
        WHEN pe.estado IN ('pendiente', 'procesando') 
        THEN dp.cantidad 
        ELSE 0 
    END), 0) as stock_disponible
FROM productos p
LEFT JOIN detalle_pedidos dp ON p.id = dp.producto_id
LEFT JOIN pedidos pe ON dp.pedido_id = pe.id
WHERE p.activo = 1
GROUP BY p.id, p.nombre, p.stock
HAVING stock_disponible < 10
ORDER BY stock_disponible ASC;
```

**Desafíos:**
1. Optimizar para ejecución frecuente (cada minuto)
2. Considerar desnormalización vs. consulta en tiempo real
3. Evaluar uso de vistas materializadas
4. Proponer arquitectura de cache

## 🏆 Ejercicio 5: Proyecto Integral de Optimización

### Escenario Final
Tienes una aplicación con 1M+ productos, 100K+ clientes activos, y 10K+ pedidos diarios.

**Métricas actuales problemáticas:**
- Consulta de productos: 2.5 segundos promedio
- Reporte de ventas: 45 segundos
- Búsqueda de clientes: 1.8 segundos
- Dashboard admin: 30+ segundos

**Tarea Final:**
1. **Auditoría completa** de todas las consultas principales
2. **Plan de optimización** priorizado por impacto de negocio
3. **Estrategia de índices** integral
4. **Propuesta de refactoring** de consultas críticas
5. **Plan de monitoreo** continuo de rendimiento

**Entregables:**
- Documento de análisis (2-3 páginas)
- Scripts de optimización comentados
- Métricas de mejora esperadas
- Plan de implementación por fases

## 📋 Criterios de Evaluación

### Nivel Básico ⭐
- Usa EXPLAIN correctamente
- Identifica problemas obvios de rendimiento
- Crea índices simples apropiados

### Nivel Intermedio ⭐⭐
- Optimiza consultas complejas
- Diseña índices compuestos eficientes
- Reescribe subconsultas problemáticas

### Nivel Avanzado ⭐⭐⭐
- Propone soluciones arquitectónicas
- Considera trade-offs de rendimiento vs. mantenibilidad
- Diseña estrategias de monitoreo y alertas

### Nivel Experto ⭐⭐⭐⭐
- Optimiza para casos extremos y alta concurrencia
- Propone alternativas tecnológicas cuando SQL no es suficiente
- Documenta decisiones con análisis de costo-beneficio

## 🔗 Recursos de Apoyo

- [Documentación de MySQL - Optimization](https://dev.mysql.com/doc/refman/8.0/en/optimization.html)
- [Percona Toolkit](https://www.percona.com/software/database-tools/percona-toolkit)
- [pt-query-digest](https://docs.percona.com/percona-toolkit/pt-query-digest.html)

---

**Nota:** Estos ejercicios están diseñados para ser progresivos. Comienza con el nivel que coincida con tu experiencia actual y avanza gradualmente.
