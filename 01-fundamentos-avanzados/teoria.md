# Fundamentos Avanzados de MySQL - Teoría

## 📋 Índice

1. [Subconsultas](#subconsultas)
2. [Joins Avanzados](#joins-avanzados)
3. [Funciones Avanzadas](#funciones-avanzadas)
4. [Optimización de Consultas](#optimización-de-consultas)
5. [Mejores Prácticas](#mejores-prácticas)

## 🔍 Subconsultas

### Conceptos Fundamentales

Las **subconsultas** son consultas anidadas dentro de otra consulta. Son una herramienta poderosa para resolver problemas complejos de manera modular.

#### Tipos de Subconsultas

1. **Subconsultas Escalares**: Devuelven un solo valor
2. **Subconsultas de Fila**: Devuelven una sola fila con múltiples columnas
3. **Subconsultas de Tabla**: Devuelven múltiples filas y columnas
4. **Subconsultas Correlacionadas**: Referencian columnas de la consulta externa

#### Ubicaciones de Subconsultas

- **En SELECT**: Para calcular columnas derivadas
- **En WHERE**: Para filtrar basado en condiciones complejas
- **En FROM**: Como tablas temporales (subconsultas derivadas)
- **En HAVING**: Para filtrar grupos

### Operadores con Subconsultas

- **EXISTS/NOT EXISTS**: Verificar existencia de registros
- **IN/NOT IN**: Comparar con una lista de valores
- **ANY/SOME**: Comparar con cualquier valor del conjunto
- **ALL**: Comparar con todos los valores del conjunto

### Consideraciones de Rendimiento

- Las subconsultas correlacionadas pueden ser costosas
- Consider usar JOINs cuando sea posible
- Usar EXISTS en lugar de IN para mejores performance en algunos casos

## 🔗 Joins Avanzados

### Tipos de Joins

#### INNER JOIN
- Solo devuelve filas que tienen coincidencias en ambas tablas
- Es el tipo de join más eficiente
- Útil para relaciones obligatorias

#### LEFT JOIN (LEFT OUTER JOIN)
- Devuelve todas las filas de la tabla izquierda
- Incluye filas sin coincidencias (con NULL en columnas de la tabla derecha)
- Útil para encontrar registros faltantes

#### RIGHT JOIN (RIGHT OUTER JOIN)
- Devuelve todas las filas de la tabla derecha
- Menos común que LEFT JOIN
- Generalmente se puede reescribir como LEFT JOIN

#### CROSS JOIN
- Producto cartesiano de ambas tablas
- Cada fila de la primera tabla se combina con cada fila de la segunda
- Útil para generar combinaciones

#### SELF JOIN
- Una tabla se une consigo misma
- Útil para relaciones jerárquicas
- Requiere alias para distinguir las instancias de la tabla

### Mejores Prácticas para Joins

1. **Usar alias descriptivos** para mejorar legibilidad
2. **Especificar condiciones de join explícitamente**
3. **Considerar el orden de las tablas** para optimización
4. **Usar índices apropiados** en columnas de join

## ⚡ Funciones Avanzadas

### Funciones de Ventana (Window Functions)

Las funciones de ventana permiten realizar cálculos sobre un conjunto de filas relacionadas sin colapsar el resultado en una sola fila.

#### Sintaxis General
```sql
función() OVER (
    [PARTITION BY columna]
    [ORDER BY columna]
    [ROWS/RANGE frame_specification]
)
```

#### Tipos de Funciones de Ventana

1. **Funciones de Ranking**
   - `ROW_NUMBER()`: Numeración única secuencial
   - `RANK()`: Ranking con gaps para empates
   - `DENSE_RANK()`: Ranking sin gaps para empates

2. **Funciones de Valor**
   - `LAG()`: Valor de fila anterior
   - `LEAD()`: Valor de fila siguiente
   - `FIRST_VALUE()`: Primer valor en la ventana
   - `LAST_VALUE()`: Último valor en la ventana

3. **Funciones de Agregación**
   - Todas las funciones de agregación pueden usarse como funciones de ventana
   - `SUM()`, `AVG()`, `COUNT()`, `MIN()`, `MAX()`

### Marcos de Ventana (Window Frames)

- **ROWS**: Define el marco en términos de filas físicas
- **RANGE**: Define el marco en términos de valores lógicos
- **UNBOUNDED PRECEDING**: Desde el inicio de la partición
- **CURRENT ROW**: Fila actual
- **UNBOUNDED FOLLOWING**: Hasta el final de la partición

### Funciones de Agregación Avanzadas

#### GROUP_CONCAT()
- Concatena valores de múltiples filas en una sola cadena
- Útil para crear listas separadas por comas
- Soporta ORDER BY y SEPARATOR personalizados

#### WITH ROLLUP
- Añade filas de resumen automáticamente
- Proporciona subtotales y totales generales
- Útil para reportes jerárquicos

### Funciones de Fecha y Tiempo

#### Funciones de Extracción
- `YEAR()`, `MONTH()`, `DAY()`: Extraer componentes de fecha
- `HOUR()`, `MINUTE()`, `SECOND()`: Extraer componentes de tiempo
- `QUARTER()`, `WEEK()`: Extraer períodos

#### Funciones de Cálculo
- `DATEDIFF()`: Diferencia en días entre fechas
- `TIMESTAMPDIFF()`: Diferencia en unidades específicas
- `DATE_ADD()`, `DATE_SUB()`: Aritmética de fechas

#### Funciones de Formato
- `DATE_FORMAT()`: Formateo personalizado de fechas
- `TIME_FORMAT()`: Formateo de tiempo

## 🎯 Optimización de Consultas

### Principios Básicos

1. **Selectividad**: Escribir condiciones más selectivas primero
2. **Índices**: Usar índices apropiados para WHERE, JOIN, ORDER BY
3. **Proyección**: Seleccionar solo las columnas necesarias
4. **Límites**: Usar LIMIT cuando sea apropiado

### Técnicas de Optimización

#### Reescritura de Subconsultas
- Convertir subconsultas correlacionadas a JOINs
- Usar EXISTS en lugar de IN para subconsultas
- Considerar CTEs (Common Table Expressions) para subconsultas complejas

#### Optimización de Joins
- Colocar la tabla más selectiva primero
- Usar índices compuestos para múltiples condiciones
- Evitar funciones en condiciones de JOIN

## 💡 Mejores Prácticas

### Legibilidad del Código

1. **Usar aliases descriptivos**
2. **Indentar consultas complejas**
3. **Comentar lógica compleja**
4. **Separar consultas muy largas en CTEs**

### Mantenibilidad

1. **Evitar magic numbers**
2. **Usar constantes nombradas**
3. **Documentar suposiciones de negocio**
4. **Versionar cambios de esquema**

### Rendimiento

1. **Analizar planes de ejecución**
2. **Monitorear consultas lentas**
3. **Usar índices apropiados**
4. **Considerar particionado para tablas grandes**

### Seguridad

1. **Usar parámetros preparados**
2. **Validar entrada de usuario**
3. **Aplicar principio de menor privilegio**
4. **Auditar acceso a datos sensibles**

## 📚 Recursos Adicionales

- [MySQL Documentation - Subqueries](https://dev.mysql.com/doc/refman/8.0/en/subqueries.html)
- [MySQL Documentation - JOIN Syntax](https://dev.mysql.com/doc/refman/8.0/en/join.html)
- [MySQL Documentation - Window Functions](https://dev.mysql.com/doc/refman/8.0/en/window-functions.html)

---

## 🎯 Objetivos de Aprendizaje

Al completar esta sección, deberías ser capaz de:

- [ ] Escribir subconsultas complejas y correlacionadas
- [ ] Usar todos los tipos de JOINs apropiadamente
- [ ] Aplicar funciones de ventana para análisis avanzados
- [ ] Optimizar consultas para mejor rendimiento
- [ ] Seguir mejores prácticas de desarrollo SQL

## 📝 Ejercicios Propuestos

1. **Subconsultas**: Crear una consulta que encuentre empleados cuyo salario esté en el top 10% de su departamento
2. **Joins**: Desarrollar un reporte que muestre ventas por región con comparación año anterior
3. **Funciones de Ventana**: Calcular el crecimiento porcentual mes a mes de ventas
4. **Optimización**: Analizar y optimizar una consulta lenta usando EXPLAIN
