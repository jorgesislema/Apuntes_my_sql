# Retos Semanales MySQL - 2025

## Semana 1: Análisis de Rendimiento (Enero 2025)

### 🎯 Objetivo
Identificar y optimizar consultas lentas en una base de datos de e-commerce.

### 📊 Escenario
Tienes una base de datos con las siguientes tablas:
- `productos` (100,000 registros)
- `pedidos` (500,000 registros)
- `detalle_pedidos` (2,000,000 registros)
- `clientes` (50,000 registros)

### 🔥 Reto
1. **Consulta Problemática:**
```sql
SELECT p.nombre, COUNT(*) as total_vendido
FROM productos p
JOIN detalle_pedidos dp ON p.id = dp.producto_id
JOIN pedidos pe ON dp.pedido_id = pe.id
WHERE pe.fecha >= '2024-01-01'
GROUP BY p.nombre
ORDER BY total_vendido DESC;
```

**Tareas:**
- Analizar con EXPLAIN
- Identificar problemas de rendimiento
- Crear índices optimizados
- Reescribir la consulta si es necesario
- Medir mejora de performance

### 📈 Solución Esperada
```sql
-- Crear índices optimizados
CREATE INDEX idx_pedidos_fecha ON pedidos(fecha);
CREATE INDEX idx_detalle_producto_pedido ON detalle_pedidos(producto_id, pedido_id);

-- Consulta optimizada
SELECT p.nombre, COUNT(*) as total_vendido
FROM productos p
JOIN detalle_pedidos dp ON p.id = dp.producto_id
JOIN pedidos pe ON dp.pedido_id = pe.id
WHERE pe.fecha >= '2024-01-01'
  AND pe.fecha < '2025-01-01'  -- Añadir límite superior
GROUP BY p.id, p.nombre  -- Incluir p.id para mejor performance
ORDER BY total_vendido DESC
LIMIT 50;  -- Limitar resultados si es apropiado
```

### 🏆 Puntos Bonus
- Implementar particionamiento por fecha
- Crear vista materializada
- Configurar query cache

---

## Semana 2: Stored Procedures Avanzados (Febrero 2025)

### 🎯 Objetivo
Crear un sistema de facturación automatizado usando stored procedures.

### 📊 Escenario
Sistema de suscripciones mensuales que debe:
- Generar facturas automáticamente
- Aplicar descuentos basados en historial
- Manejar diferentes tipos de suscripción
- Registrar intentos de pago

### 🔥 Reto
Crear los siguientes stored procedures:

1. **`sp_generar_factura_mensual`**: Genera facturas para todos los usuarios activos
2. **`sp_calcular_descuento`**: Calcula descuentos basados en lealtad del cliente
3. **`sp_procesar_pago`**: Procesa el pago y actualiza estados
4. **`sp_reporte_facturacion`**: Genera reporte mensual de facturación

### 📈 Solución Ejemplo
```sql
DELIMITER //

CREATE PROCEDURE sp_generar_factura_mensual()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_usuario_id INT;
    DECLARE v_plan_precio DECIMAL(10,2);
    DECLARE v_descuento DECIMAL(5,2);
    
    DECLARE cur_usuarios CURSOR FOR 
        SELECT u.id, p.precio 
        FROM usuarios u 
        JOIN suscripciones s ON u.id = s.usuario_id 
        JOIN planes p ON s.plan_id = p.id 
        WHERE s.estado = 'activa';
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    START TRANSACTION;
    
    OPEN cur_usuarios;
    
    facturacion_loop: LOOP
        FETCH cur_usuarios INTO v_usuario_id, v_plan_precio;
        IF done THEN
            LEAVE facturacion_loop;
        END IF;
        
        -- Calcular descuento
        CALL sp_calcular_descuento(v_usuario_id, v_descuento);
        
        -- Insertar factura
        INSERT INTO facturas (usuario_id, monto_base, descuento, monto_final, fecha_generacion, estado)
        VALUES (v_usuario_id, v_plan_precio, v_descuento, 
                v_plan_precio * (1 - v_descuento/100), NOW(), 'pendiente');
    
    END LOOP;
    
    CLOSE cur_usuarios;
    COMMIT;
END //

DELIMITER ;
```

### 🏆 Puntos Bonus
- Implementar manejo de errores con ROLLBACK
- Crear logging de operaciones
- Añadir validaciones de negocio

---

## Semana 3: Replicación y Alta Disponibilidad (Marzo 2025)

### 🎯 Objetivo
Configurar un entorno de replicación MySQL con failover automático.

### 📊 Escenario
Empresa que necesita:
- 99.9% de uptime
- Distribución de carga de lectura
- Backup en tiempo real
- Recuperación rápida ante fallos

### 🔥 Reto
1. **Configurar Master-Slave**
   - 1 Master (escritura)
   - 2 Slaves (lectura)
   - Configurar binary logging

2. **Implementar Monitoring**
   - Scripts de monitoreo de lag
   - Alertas automáticas
   - Health checks

3. **Simular Failover**
   - Promover slave a master
   - Reconfigurar aplicación
   - Minimizar downtime

### 📈 Configuración Base
```sql
-- En el Master
[mysqld]
server-id = 1
log-bin = mysql-bin
binlog-format = ROW
gtid_mode = ON
enforce_gtid_consistency = ON

-- Crear usuario de replicación
CREATE USER 'replicator'@'%' IDENTIFIED BY 'strong_password';
GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%';

-- En cada Slave
[mysqld]
server-id = 2  # (3 para el segundo slave)
relay-log = mysql-relay-bin
log-slave-updates = 1
read_only = 1
gtid_mode = ON
enforce_gtid_consistency = ON

-- Configurar replicación
CHANGE MASTER TO
    MASTER_HOST='master_ip',
    MASTER_USER='replicator',
    MASTER_PASSWORD='strong_password',
    MASTER_AUTO_POSITION = 1;
```

### 🏆 Puntos Bonus
- Implementar MySQL Group Replication
- Configurar ProxySQL para load balancing
- Crear scripts de failover automático

---

## Semana 4: Data Warehousing y Analytics (Abril 2025)

### 🎯 Objetivo
Crear un sistema de data warehousing para análisis de negocio.

### 📊 Escenario
Transformar datos transaccionales en un modelo dimensional para:
- Análisis de ventas por período
- Segmentación de clientes
- Forecasting de demanda
- KPIs ejecutivos

### 🔥 Reto
1. **Diseñar Modelo Dimensional**
   - Tabla de hechos: `fact_ventas`
   - Dimensiones: `dim_tiempo`, `dim_producto`, `dim_cliente`, `dim_geografia`

2. **ETL Process**
   - Extraer datos de OLTP
   - Transformar y limpiar
   - Cargar en warehouse

3. **Consultas Analíticas**
   - Top productos por trimestre
   - Análisis de cohortes
   - Tendencias estacionales

### 📈 Estructura Dimensional
```sql
-- Tabla de hechos
CREATE TABLE fact_ventas (
    venta_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    fecha_key INT,
    producto_key INT,
    cliente_key INT,
    geografia_key INT,
    cantidad INT,
    precio_unitario DECIMAL(10,2),
    descuento DECIMAL(10,2),
    impuestos DECIMAL(10,2),
    total_venta DECIMAL(12,2),
    INDEX idx_fecha (fecha_key),
    INDEX idx_producto (producto_key),
    INDEX idx_cliente (cliente_key)
);

-- Dimensión tiempo
CREATE TABLE dim_tiempo (
    fecha_key INT PRIMARY KEY,
    fecha DATE,
    año INT,
    trimestre INT,
    mes INT,
    semana INT,
    dia_año INT,
    dia_mes INT,
    dia_semana INT,
    nombre_mes VARCHAR(20),
    nombre_dia VARCHAR(20),
    es_fin_semana BOOLEAN,
    es_feriado BOOLEAN
);
```

### 🏆 Puntos Bonus
- Implementar SCD (Slowly Changing Dimensions)
- Crear cubos OLAP
- Desarrollar dashboard en tiempo real

---

## Sistema de Puntuación

### 🎖️ Niveles de Logro
- **Bronce (50-69 pts)**: Completó el reto básico
- **Plata (70-89 pts)**: Completó + optimizaciones
- **Oro (90-100 pts)**: Completó + puntos bonus + innovación

### 📊 Distribución de Puntos
- **Funcionalidad Base**: 50 puntos
- **Optimización**: 20 puntos
- **Documentación**: 10 puntos
- **Puntos Bonus**: 20 puntos

### 🏅 Certificación de Completitud
Al completar los 4 retos con nivel Plata o superior:
- Certificado virtual de "MySQL Advanced Practitioner"
- Badge LinkedIn verificable
- Recomendación para certificación Oracle MySQL

## 📅 Cronograma 2025

| Mes | Semana | Tema | Dificultad |
|-----|--------|------|------------|
| Enero | 1-2 | Análisis de Rendimiento | ⭐⭐⭐ |
| Febrero | 3-4 | Stored Procedures | ⭐⭐⭐⭐ |
| Marzo | 5-6 | Replicación | ⭐⭐⭐⭐⭐ |
| Abril | 7-8 | Data Warehousing | ⭐⭐⭐⭐ |

### 📬 Entrega de Soluciones
- **Repositorio Git**: Crear branch para cada reto
- **Documentación**: README con proceso y resultados
- **Screenshots**: Evidencia de funcionamiento
- **Tiempo Límite**: 2 semanas por reto
