# Replicación en MySQL

## 📋 Índice
1. [Introducción a la Replicación](#introducción-a-la-replicación)
2. [Tipos de Replicación](#tipos-de-replicación)
3. [Configuración Maestro-Esclavo](#configuración-maestro-esclavo)
4. [Replicación Multi-Maestro](#replicación-multi-maestro)
5. [Group Replication](#group-replication)
6. [Monitoreo y Troubleshooting](#monitoreo-y-troubleshooting)
7. [Mejores Prácticas](#mejores-prácticas)
8. [Casos de Uso](#casos-de-uso)

---

## 🔄 Introducción a la Replicación

### ¿Qué es la Replicación?

La replicación en MySQL es el proceso de copiar automáticamente datos de un servidor (maestro) a uno o más servidores (esclavos), permitiendo:

- **Alta Disponibilidad**: Failover automático
- **Escalabilidad de Lectura**: Distribuir consultas SELECT
- **Backup en Tiempo Real**: Copias actualizadas
- **Análisis sin Impacto**: Reportes en servidores separados

### Arquitectura de Replicación

```
┌─────────────────┐    Binary Logs    ┌─────────────────┐
│  Servidor       │ ───────────────►  │  Servidor       │
│  Maestro        │                   │  Esclavo 1      │
│  (Write/Read)   │                   │  (Read Only)    │
└─────────────────┘                   └─────────────────┘
         │                                     │
         │          Binary Logs                │
         └─────────────────────────────────────┼─────────┐
                                               │         │
                                    ┌─────────────────┐ │
                                    │  Servidor       │ │
                                    │  Esclavo 2      │ │
                                    │  (Read Only)    │ │
                                    └─────────────────┘ │
                                                        │
                                             ┌─────────────────┐
                                             │  Servidor       │
                                             │  Esclavo N      │
                                             │  (Read Only)    │
                                             └─────────────────┘
```

### Componentes Clave

1. **Binary Log**: Registro de cambios en el maestro
2. **Relay Log**: Copia local del binary log en el esclavo
3. **I/O Thread**: Descarga binary logs del maestro
4. **SQL Thread**: Aplica cambios del relay log

---

## 📡 Tipos de Replicación

### 1. Replicación Asíncrona (Por Defecto)

```sql
-- Características:
-- - El maestro no espera confirmación del esclavo
-- - Mejor performance
-- - Posible pérdida de datos en caso de fallo
-- - Lag entre maestro y esclavo
```

### 2. Replicación Semi-Síncrona

```sql
-- Instalar plugin en maestro
INSTALL PLUGIN rpl_semi_sync_master SONAME 'semisync_master.so';

-- Instalar plugin en esclavo
INSTALL PLUGIN rpl_semi_sync_slave SONAME 'semisync_slave.so';

-- Activar en maestro
SET GLOBAL rpl_semi_sync_master_enabled = 1;
SET GLOBAL rpl_semi_sync_master_timeout = 1000; -- 1 segundo

-- Activar en esclavo
SET GLOBAL rpl_semi_sync_slave_enabled = 1;
```

### 3. Replicación por Statement vs Row vs Mixed

```sql
-- Configurar formato de replicación en maestro
SET GLOBAL binlog_format = 'ROW';      -- Replica filas modificadas
SET GLOBAL binlog_format = 'STATEMENT'; -- Replica comandos SQL
SET GLOBAL binlog_format = 'MIXED';     -- Automático según contexto
```

---

## ⚙️ Configuración Maestro-Esclavo

### Configuración del Servidor Maestro

#### 1. Configurar my.cnf del Maestro
```ini
[mysqld]
# ID único del servidor (debe ser diferente en cada servidor)
server-id = 1

# Habilitar binary logging
log-bin = mysql-bin
binlog_format = ROW

# Configuración de replicación
binlog-do-db = empresa
binlog-ignore-db = mysql,information_schema,performance_schema

# Configuración de red
bind-address = 0.0.0.0

# Configuración de performance
innodb_flush_log_at_trx_commit = 1
sync_binlog = 1

# Configuración de relay logs (si actúa como esclavo también)
relay-log = relay-bin
relay-log-index = relay-bin.index
```

#### 2. Crear Usuario de Replicación
```sql
-- Crear usuario específico para replicación
CREATE USER 'replicator'@'%' IDENTIFIED BY 'ReplicationPass2025!';

-- Otorgar privilegios de replicación
GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%';

-- Aplicar cambios
FLUSH PRIVILEGES;
```

#### 3. Obtener Posición del Maestro
```sql
-- Bloquear escrituras temporalmente
FLUSH TABLES WITH READ LOCK;

-- Obtener posición actual del binary log
SHOW MASTER STATUS;
-- Resultado ejemplo:
-- +------------------+----------+--------------+------------------+
-- | File             | Position | Binlog_Do_DB | Binlog_Ignore_DB |
-- +------------------+----------+--------------+------------------+
-- | mysql-bin.000001 | 154      | empresa      |                  |
-- +------------------+----------+--------------+------------------+

-- Hacer backup de datos (en otra terminal)
-- mysqldump -u root -p --all-databases --master-data > backup.sql

-- Desbloquear tablas
UNLOCK TABLES;
```

### Configuración del Servidor Esclavo

#### 1. Configurar my.cnf del Esclavo
```ini
[mysqld]
# ID único del servidor
server-id = 2

# Configuración de relay logs
relay-log = relay-bin
relay-log-index = relay-bin.index

# Log de errores específico
log-error = /var/log/mysql/slave-error.log

# Configuración de red
bind-address = 0.0.0.0

# Hacer servidor read-only (opcional)
read-only = 1
super-read-only = 1

# Configuración de replicación
replicate-do-db = empresa
replicate-ignore-db = mysql,information_schema,performance_schema

# Skip de errores específicos (usar con cuidado)
# slave-skip-errors = 1062,1053
```

#### 2. Restaurar Datos y Configurar Replicación
```bash
# Restaurar datos desde backup del maestro
mysql -u root -p < backup.sql

# O copiar datos directamente (si es instalación nueva)
```

```sql
-- Configurar conexión al maestro
CHANGE MASTER TO
    MASTER_HOST = '192.168.1.100',
    MASTER_USER = 'replicator',
    MASTER_PASSWORD = 'ReplicationPass2025!',
    MASTER_LOG_FILE = 'mysql-bin.000001',
    MASTER_LOG_POS = 154;

-- Iniciar replicación
START SLAVE;

-- Verificar estado
SHOW SLAVE STATUS\G
```

### Verificación de la Replicación

```sql
-- En el maestro: Verificar esclavos conectados
SHOW PROCESSLIST;

-- En el esclavo: Verificar estado detallado
SHOW SLAVE STATUS\G

-- Campos importantes a verificar:
-- Slave_IO_Running: Yes
-- Slave_SQL_Running: Yes
-- Seconds_Behind_Master: 0 (o valor bajo)
-- Last_Error: (debe estar vacío)

-- Probar replicación
-- En maestro:
CREATE DATABASE test_replication;
USE test_replication;
CREATE TABLE test (id INT PRIMARY KEY, data VARCHAR(100));
INSERT INTO test VALUES (1, 'Test data');

-- En esclavo:
USE test_replication;
SELECT * FROM test; -- Debe mostrar los datos
```

---

## 🔄 Replicación Multi-Maestro

### Configuración Master-Master

#### Servidor A (Maestro 1)
```ini
[mysqld]
server-id = 1
log-bin = mysql-bin

# Configuración para evitar conflictos de ID
auto_increment_increment = 2
auto_increment_offset = 1

# Configuración de relay logs
relay-log = relay-bin
```

#### Servidor B (Maestro 2)
```ini
[mysqld]
server-id = 2
log-bin = mysql-bin

# Configuración para evitar conflictos de ID
auto_increment_increment = 2
auto_increment_offset = 2

# Configuración de relay logs
relay-log = relay-bin
```

#### Configuración de Replicación Bidireccional

```sql
-- En Servidor A: Configurar como esclavo de B
CHANGE MASTER TO
    MASTER_HOST = '192.168.1.101',
    MASTER_USER = 'replicator',
    MASTER_PASSWORD = 'ReplicationPass2025!',
    MASTER_LOG_FILE = 'mysql-bin.000001',
    MASTER_LOG_POS = 154;

START SLAVE;

-- En Servidor B: Configurar como esclavo de A
CHANGE MASTER TO
    MASTER_HOST = '192.168.1.100',
    MASTER_USER = 'replicator',
    MASTER_PASSWORD = 'ReplicationPass2025!',
    MASTER_LOG_FILE = 'mysql-bin.000001',
    MASTER_LOG_POS = 154;

START SLAVE;
```

---

## 🌐 Group Replication (MySQL 5.7+)

### Configuración Básica

#### my.cnf para Group Replication
```ini
[mysqld]
server-id = 1
gtid_mode = ON
enforce_gtid_consistency = ON

# Group Replication configuración
plugin_load_add = 'group_replication.so'
group_replication_group_name = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
group_replication_start_on_boot = off
group_replication_local_address = "192.168.1.100:33061"
group_replication_group_seeds = "192.168.1.100:33061,192.168.1.101:33061,192.168.1.102:33061"

# Configuración de single-primary (un solo maestro)
group_replication_single_primary_mode = ON
group_replication_enforce_update_everywhere_checks = OFF

# Configuración de bootstrap
group_replication_bootstrap_group = OFF
```

#### Inicializar Group Replication

```sql
-- En el primer nodo (bootstrap)
SET GLOBAL group_replication_bootstrap_group=ON;
START GROUP_REPLICATION;
SET GLOBAL group_replication_bootstrap_group=OFF;

-- En nodos adicionales
START GROUP_REPLICATION;

-- Verificar miembros del grupo
SELECT * FROM performance_schema.replication_group_members;
```

### Multi-Primary Mode

```sql
-- Cambiar a modo multi-primary
SELECT group_replication_switch_to_multi_primary_mode();

-- Verificar modo actual
SELECT @@group_replication_single_primary_mode;

-- Cambiar de vuelta a single-primary
SELECT group_replication_switch_to_single_primary_mode('member_uuid');
```

---

## 📊 Monitoreo y Troubleshooting

### Monitoreo de Replicación

#### Scripts de Monitoreo

```sql
-- Script de verificación de replicación
DELIMITER //
CREATE PROCEDURE check_replication_health()
BEGIN
    DECLARE lag_seconds INT;
    DECLARE io_running VARCHAR(10);
    DECLARE sql_running VARCHAR(10);
    DECLARE last_error TEXT;
    
    -- Obtener estado de replicación
    SELECT 
        Slave_IO_Running,
        Slave_SQL_Running,
        Seconds_Behind_Master,
        Last_Error
    INTO io_running, sql_running, lag_seconds, last_error
    FROM SHOW SLAVE STATUS;
    
    -- Reportar estado
    SELECT 
        'REPLICATION STATUS' as category,
        CASE 
            WHEN io_running = 'Yes' AND sql_running = 'Yes' THEN 'HEALTHY'
            ELSE 'CRITICAL'
        END as status,
        io_running as io_thread,
        sql_running as sql_thread,
        lag_seconds as lag_seconds,
        last_error as error_message;
    
    -- Alertas
    IF lag_seconds > 300 THEN
        SELECT 'WARNING: Replication lag > 5 minutes' as alert;
    END IF;
    
    IF io_running != 'Yes' OR sql_running != 'Yes' THEN
        SELECT 'CRITICAL: Replication threads stopped' as alert;
    END IF;
    
END//
DELIMITER ;

-- Ejecutar verificación
CALL check_replication_health();
```

#### Consultas de Monitoreo

```sql
-- Estado general de replicación
SHOW SLAVE STATUS\G

-- Procesos de replicación activos
SELECT * FROM information_schema.processlist 
WHERE Command IN ('Binlog Dump', 'Connect');

-- Lag de replicación
SELECT 
    CASE
        WHEN Slave_SQL_Running_State = 'Slave has read all relay log; waiting for more updates'
        THEN 'Slave está actualizado'
        ELSE CONCAT('Lag: ', Seconds_Behind_Master, ' segundos')
    END as replication_status
FROM SHOW SLAVE STATUS;

-- Tamaño de binary logs
SELECT 
    Log_name,
    File_size,
    ROUND(File_size/1024/1024, 2) as Size_MB
FROM SHOW BINARY LOGS;
```

### Problemas Comunes y Soluciones

#### 1. Replicación Detenida por Error

```sql
-- Ver detalles del error
SHOW SLAVE STATUS\G

-- Saltar error específico (usar con precaución)
STOP SLAVE;
SET GLOBAL sql_slave_skip_counter = 1;
START SLAVE;

-- O configurar skip automático para errores específicos
-- En my.cnf: slave-skip-errors = 1062,1053
```

#### 2. Lag Excesivo de Replicación

```sql
-- Optimizar aplicación de relay logs
STOP SLAVE SQL_THREAD;
SET GLOBAL slave_parallel_workers = 4;
SET GLOBAL slave_parallel_type = 'LOGICAL_CLOCK';
START SLAVE SQL_THREAD;

-- Verificar configuración
SHOW VARIABLES LIKE 'slave_parallel%';
```

#### 3. Conexión Perdida con Maestro

```sql
-- Verificar configuración de red
SHOW VARIABLES LIKE 'slave_net_timeout';

-- Configurar reconexión automática
CHANGE MASTER TO MASTER_CONNECT_RETRY = 60;
CHANGE MASTER TO MASTER_RETRY_COUNT = 3;
```

#### 4. Binary Logs Corruptos

```bash
# Verificar binary log
mysqlbinlog mysql-bin.000001 > /dev/null

# Si está corrupto, empezar desde siguiente log
CHANGE MASTER TO 
    MASTER_LOG_FILE = 'mysql-bin.000002',
    MASTER_LOG_POS = 4;
```

### Scripts de Recuperación

```bash
#!/bin/bash
# recovery_replication.sh

# Función para recuperar replicación
recover_replication() {
    echo "Iniciando recuperación de replicación..."
    
    # 1. Obtener nueva posición del maestro
    MASTER_STATUS=$(mysql -h $MASTER_HOST -u $REPL_USER -p$REPL_PASS -e "SHOW MASTER STATUS\G")
    LOG_FILE=$(echo "$MASTER_STATUS" | grep "File:" | awk '{print $2}')
    LOG_POS=$(echo "$MASTER_STATUS" | grep "Position:" | awk '{print $2}')
    
    echo "Nueva posición: $LOG_FILE:$LOG_POS"
    
    # 2. Reconfigurar esclavo
    mysql -u root -p$ROOT_PASS << EOF
STOP SLAVE;
CHANGE MASTER TO 
    MASTER_LOG_FILE = '$LOG_FILE',
    MASTER_LOG_POS = $LOG_POS;
START SLAVE;
EOF
    
    # 3. Verificar estado
    mysql -u root -p$ROOT_PASS -e "SHOW SLAVE STATUS\G" | grep -E "(Slave_IO_Running|Slave_SQL_Running|Seconds_Behind_Master)"
}

# Configuración
MASTER_HOST="192.168.1.100"
REPL_USER="replicator"
REPL_PASS="ReplicationPass2025!"
ROOT_PASS="rootpassword"

# Ejecutar recuperación
recover_replication
```

---

## 🏆 Mejores Prácticas

### 1. Configuración de Performance

```ini
# my.cnf - Optimización para replicación
[mysqld]
# Binary log configuración
binlog_cache_size = 1M
sync_binlog = 1
binlog_group_commit_sync_delay = 0
binlog_group_commit_sync_no_delay_count = 0

# Relay log configuración
relay_log_purge = ON
relay_log_recovery = ON

# Configuración de threads
slave_parallel_workers = 4
slave_parallel_type = LOGICAL_CLOCK
slave_preserve_commit_order = ON

# Configuración de red
slave_net_timeout = 60
master_connect_retry = 60
master_retry_count = 86400
```

### 2. Seguridad en Replicación

```sql
-- Usuario de replicación con acceso restringido
CREATE USER 'replicator'@'192.168.1.%' 
IDENTIFIED BY 'SecureReplicationPass2025!';

GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'192.168.1.%';

-- Configurar SSL para replicación
CHANGE MASTER TO
    MASTER_HOST = '192.168.1.100',
    MASTER_USER = 'replicator',
    MASTER_PASSWORD = 'SecureReplicationPass2025!',
    MASTER_SSL = 1,
    MASTER_SSL_CA = '/etc/mysql/ca.pem',
    MASTER_SSL_CERT = '/etc/mysql/client-cert.pem',
    MASTER_SSL_KEY = '/etc/mysql/client-key.pem';
```

### 3. Monitoreo Automatizado

```bash
#!/bin/bash
# monitor_replication.sh

# Configuración
MYSQL_USER="monitor"
MYSQL_PASS="MonitorPass123"
LAG_THRESHOLD=300
EMAIL="admin@empresa.com"

# Función de verificación
check_replication() {
    local result=$(mysql -u$MYSQL_USER -p$MYSQL_PASS -e "SHOW SLAVE STATUS\G" 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        send_alert "ERROR: No se puede conectar a MySQL"
        return 1
    fi
    
    local io_running=$(echo "$result" | grep "Slave_IO_Running:" | awk '{print $2}')
    local sql_running=$(echo "$result" | grep "Slave_SQL_Running:" | awk '{print $2}')
    local lag=$(echo "$result" | grep "Seconds_Behind_Master:" | awk '{print $2}')
    
    # Verificar threads
    if [ "$io_running" != "Yes" ] || [ "$sql_running" != "Yes" ]; then
        send_alert "CRITICAL: Replication threads stopped - IO:$io_running SQL:$sql_running"
        return 1
    fi
    
    # Verificar lag
    if [ "$lag" != "NULL" ] && [ "$lag" -gt $LAG_THRESHOLD ]; then
        send_alert "WARNING: Replication lag is $lag seconds"
        return 1
    fi
    
    echo "Replication OK - Lag: $lag seconds"
    return 0
}

# Función de alerta
send_alert() {
    local message="$1"
    echo "[$(date)] $message" >> /var/log/replication_monitor.log
    echo "$message" | mail -s "MySQL Replication Alert" $EMAIL
}

# Ejecutar verificación
check_replication

# Configurar en crontab para ejecutar cada 5 minutos:
# */5 * * * * /scripts/monitor_replication.sh
```

### 4. Backup con Replicación

```bash
#!/bin/bash
# backup_from_slave.sh

# Configuración
SLAVE_HOST="192.168.1.101"
BACKUP_DIR="/backups/mysql"
DATE=$(date +%Y%m%d_%H%M%S)

# Función de backup desde esclavo
backup_from_slave() {
    echo "Iniciando backup desde esclavo..."
    
    # Pausar replicación temporalmente
    mysql -h $SLAVE_HOST -u root -p$ROOT_PASS -e "STOP SLAVE SQL_THREAD;"
    
    # Esperar que termine de aplicar relay logs
    while true; do
        local status=$(mysql -h $SLAVE_HOST -u root -p$ROOT_PASS -e "SHOW SLAVE STATUS\G" | grep "Slave_SQL_Running_State")
        if [[ $status == *"Slave has read all relay log"* ]]; then
            break
        fi
        sleep 1
    done
    
    # Realizar backup
    mysqldump -h $SLAVE_HOST -u backup_user -p$BACKUP_PASS \
        --single-transaction \
        --routines --triggers --events \
        --all-databases > $BACKUP_DIR/backup_slave_$DATE.sql
    
    # Reanudar replicación
    mysql -h $SLAVE_HOST -u root -p$ROOT_PASS -e "START SLAVE SQL_THREAD;"
    
    echo "Backup completado: backup_slave_$DATE.sql"
}

backup_from_slave
```

---

## 💼 Casos de Uso

### 1. Escalabilidad de Lectura

```sql
-- Configuración para aplicación web
-- Maestro: Solo escrituras
-- Esclavos: Solo lecturas

-- En aplicación, usar conexiones separadas:
-- $write_connection = new PDO("mysql:host=master.db.empresa.com");
-- $read_connection = new PDO("mysql:host=slave.db.empresa.com");

-- Configurar Load Balancer para múltiples esclavos de lectura
-- HAProxy configuración para balanceo de lecturas
```

### 2. Análisis y Reportes

```sql
-- Servidor dedicado para análisis (esclavo)
-- Configurar para usar motor de almacenamiento optimizado para análisis

-- En esclavo de análisis:
CREATE TABLE sales_analysis (
    date DATE,
    total_sales DECIMAL(15,2),
    order_count INT,
    avg_order_value DECIMAL(10,2),
    INDEX idx_date (date)
) ENGINE=ColumnStore; -- Si usa MariaDB ColumnStore

-- Jobs programados para ETL
DELIMITER //
CREATE EVENT daily_sales_summary
ON SCHEDULE EVERY 1 DAY
STARTS '2025-05-29 02:00:00'
DO
BEGIN
    INSERT INTO sales_analysis 
    SELECT 
        DATE(order_date),
        SUM(total_amount),
        COUNT(*),
        AVG(total_amount)
    FROM orders 
    WHERE DATE(order_date) = CURDATE() - INTERVAL 1 DAY
    GROUP BY DATE(order_date);
END//
DELIMITER ;
```

### 3. Disaster Recovery

```sql
-- Configuración para DR site
-- Maestro en sitio principal
-- Esclavo en sitio de respaldo (diferente datacenter)

-- Procedimiento de failover automático
DELIMITER //
CREATE PROCEDURE emergency_failover()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Promover esclavo a maestro
    STOP SLAVE;
    RESET SLAVE ALL;
    
    -- Habilitar escrituras
    SET GLOBAL read_only = OFF;
    SET GLOBAL super_read_only = OFF;
    
    -- Registrar evento de failover
    INSERT INTO failover_log VALUES (NOW(), 'EMERGENCY_FAILOVER', USER());
    
    COMMIT;
    
    SELECT 'Failover completed successfully' as result;
END//
DELIMITER ;
```

### 4. Testing y Desarrollo

```bash
#!/bin/bash
# sync_dev_from_prod.sh

# Sincronizar ambiente de desarrollo desde producción
# usando replicación temporal

echo "Sincronizando desarrollo desde producción..."

# 1. Parar aplicación de desarrollo
sudo systemctl stop apache2

# 2. Configurar replicación temporal
mysql -u root -p$DEV_ROOT_PASS << EOF
STOP SLAVE;
CHANGE MASTER TO
    MASTER_HOST = '$PROD_MASTER_HOST',
    MASTER_USER = 'dev_replicator',
    MASTER_PASSWORD = '$DEV_REPL_PASS',
    MASTER_AUTO_POSITION = 1;
START SLAVE;
EOF

# 3. Esperar sincronización
echo "Esperando sincronización..."
while true; do
    LAG=$(mysql -u root -p$DEV_ROOT_PASS -e "SHOW SLAVE STATUS\G" | grep "Seconds_Behind_Master:" | awk '{print $2}')
    if [ "$LAG" = "0" ] || [ "$LAG" = "NULL" ]; then
        break
    fi
    sleep 5
done

# 4. Detener replicación y limpiar datos sensibles
mysql -u root -p$DEV_ROOT_PASS << EOF
STOP SLAVE;
RESET SLAVE ALL;

-- Anonimizar datos sensibles
UPDATE customers SET 
    email = CONCAT('user', id, '@ejemplo.com'),
    phone = '555-0000',
    address = 'Dirección de Prueba';

UPDATE users SET password = SHA2('desarrollo123', 256);
EOF

# 5. Reiniciar aplicación
sudo systemctl start apache2

echo "Sincronización completada"
```

---

## 📈 Optimización de Performance

### Configuración Avanzada

```ini
# my.cnf - Configuración optimizada para replicación
[mysqld]
# Configuración de binary logs
binlog_cache_size = 2M
max_binlog_cache_size = 512M
max_binlog_size = 512M
binlog_stmt_cache_size = 32K

# Configuración de relay logs
max_relay_log_size = 512M
relay_log_space_limit = 2G

# Configuración de threads paralelos
slave_parallel_workers = 8
slave_parallel_type = LOGICAL_CLOCK
binlog_transaction_dependency_tracking = WRITESET

# Configuración de red optimizada
slave_net_timeout = 120
master_connect_retry = 30

# Configuración de checksums
binlog_checksum = CRC32
master_verify_checksum = ON
slave_sql_verify_checksum = ON
```

### Monitoreo de Performance

```sql
-- Consultas para monitorear performance de replicación
-- 1. Throughput de replicación
SELECT 
    COUNT(*) as events_per_second,
    SUM(CASE WHEN event_type = 'Write_rows' THEN 1 ELSE 0 END) as writes_per_second
FROM performance_schema.events_statements_history_long
WHERE timer_start >= UNIX_TIMESTAMP(NOW() - INTERVAL 1 MINUTE) * 1000000000;

-- 2. Latencia de replicación por base de datos
SELECT 
    db,
    COUNT(*) as operations,
    AVG(timer_wait/1000000) as avg_latency_ms
FROM performance_schema.events_statements_history_long
WHERE event_name LIKE 'statement/sql/%'
    AND timer_start >= UNIX_TIMESTAMP(NOW() - INTERVAL 5 MINUTE) * 1000000000
GROUP BY db;

-- 3. Análisis de relay logs
SELECT 
    channel_name,
    service_state,
    count_received_heartbeats,
    last_heartbeat_timestamp,
    received_transaction_set
FROM performance_schema.replication_connection_status;
```

---

*Última actualización: 28/05/2025*
