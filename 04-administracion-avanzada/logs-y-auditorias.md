# Logs y Auditorías en MySQL

## 📋 Índice
1. [Tipos de Logs en MySQL](#tipos-de-logs-en-mysql)
2. [Binary Log](#binary-log)
3. [Error Log](#error-log)
4. [General Query Log](#general-query-log)
5. [Slow Query Log](#slow-query-log)
6. [Relay Log](#relay-log)
7. [Auditoría Empresarial](#auditoría-empresarial)
8. [Análisis y Monitoreo](#análisis-y-monitoreo)
9. [Mejores Prácticas](#mejores-prácticas)

---

## 📝 Tipos de Logs en MySQL

### Visión General de Logs

```
MySQL Server
├── Error Log           → Errores y eventos del servidor
├── General Query Log   → Todas las consultas SQL
├── Binary Log         → Cambios para replicación/recovery
├── Slow Query Log     → Consultas lentas para optimización
├── Relay Log          → Binary logs recibidos (esclavo)
├── DDL Log            → Metadatos de DDL (interno)
└── Audit Log          → Auditoría empresarial (plugin)
```

### Configuración Global de Logs

```sql
-- Ver configuración actual de logs
SHOW VARIABLES LIKE '%log%';

-- Variables importantes
SHOW VARIABLES LIKE 'log_error';
SHOW VARIABLES LIKE 'general_log%';
SHOW VARIABLES LIKE 'slow_query_log%';
SHOW VARIABLES LIKE 'log_bin%';
```

---

## 🔄 Binary Log

### Configuración del Binary Log

#### my.cnf Configuración
```ini
[mysqld]
# Habilitar binary logging
log-bin = mysql-bin
server-id = 1

# Formato de binary log
binlog_format = ROW          # ROW, STATEMENT, o MIXED

# Configuración de archivos
max_binlog_size = 1G         # Tamaño máximo por archivo
expire_logs_days = 7         # Retención automática
binlog_cache_size = 1M       # Cache para transacciones

# Configuración de sync
sync_binlog = 1              # Sync por transacción (durabilidad)

# Filtros de bases de datos
binlog-do-db = produccion
binlog-ignore-db = test,development

# Configuración de seguridad
binlog_checksum = CRC32
```

### Gestión del Binary Log

```sql
-- Ver binary logs disponibles
SHOW BINARY LOGS;

-- Ver tamaño total de binary logs
SELECT 
    COUNT(*) as log_count,
    ROUND(SUM(file_size)/1024/1024, 2) as total_size_mb
FROM SHOW BINARY LOGS;

-- Ver eventos en binary log específico
SHOW BINLOG EVENTS IN 'mysql-bin.000001' LIMIT 10;

-- Purgar binary logs antiguos
PURGE BINARY LOGS TO 'mysql-bin.000010';
PURGE BINARY LOGS BEFORE '2025-05-01 00:00:00';

-- Flush logs (crear nuevo binary log)
FLUSH BINARY LOGS;

-- Resetear binary logs (¡CUIDADO! - elimina todos)
RESET MASTER;
```

### Análisis del Binary Log

```bash
# Leer binary log con mysqlbinlog
mysqlbinlog mysql-bin.000001

# Filtrar por rango de tiempo
mysqlbinlog --start-datetime="2025-05-28 10:00:00" \
           --stop-datetime="2025-05-28 12:00:00" \
           mysql-bin.000001

# Filtrar por posición
mysqlbinlog --start-position=4 --stop-position=1000 mysql-bin.000001

# Filtrar por base de datos
mysqlbinlog --database=empresa mysql-bin.000001

# Salida más legible
mysqlbinlog --base64-output=DECODE-ROWS -v mysql-bin.000001

# Estadísticas del binary log
mysqlbinlog --hexdump mysql-bin.000001 | head -50
```

### Monitoreo del Binary Log

```sql
-- Stored procedure para monitorear binary logs
DELIMITER //
CREATE PROCEDURE monitor_binlog()
BEGIN
    -- Información general
    SELECT 'BINARY LOG STATUS' as category;
    SHOW BINARY LOGS;
    
    -- Uso de espacio
    SELECT 
        'BINARY LOG SPACE' as category,
        COUNT(*) as log_files,
        ROUND(SUM(file_size)/1024/1024, 2) as total_mb,
        ROUND(AVG(file_size)/1024/1024, 2) as avg_mb_per_file
    FROM SHOW BINARY LOGS;
    
    -- Tasa de crecimiento (última hora)
    SELECT 
        'BINARY LOG GROWTH' as category,
        ROUND((SELECT file_size FROM SHOW BINARY LOGS ORDER BY log_name DESC LIMIT 1)/1024/1024, 2) as current_log_mb;
    
    -- Alertas
    SET @total_size = (SELECT SUM(file_size) FROM SHOW BINARY LOGS);
    IF @total_size > 10 * 1024 * 1024 * 1024 THEN  -- 10GB
        SELECT 'WARNING: Binary logs > 10GB' as alert;
    END IF;
    
END//
DELIMITER ;

-- Ejecutar monitoreo
CALL monitor_binlog();
```

---

## ❌ Error Log

### Configuración del Error Log

```ini
[mysqld]
# Ubicación del error log
log-error = /var/log/mysql/error.log

# Nivel de logging
log_error_verbosity = 3      # 1=Error, 2=Error+Warning, 3=Error+Warning+Note

# Configuración de syslog (alternativa)
log_syslog = ON
log_syslog_tag = mysql
log_syslog_facility = daemon
```

### Análisis del Error Log

```bash
# Ver errores recientes
tail -f /var/log/mysql/error.log

# Buscar errores específicos
grep -i "error" /var/log/mysql/error.log | tail -20
grep -i "warning" /var/log/mysql/error.log | tail -20

# Estadísticas de errores por hora
awk '/^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}/ {
    date_hour = substr($1, 1, 13)
    if ($0 ~ /ERROR/) error_count[date_hour]++
    if ($0 ~ /WARNING/) warning_count[date_hour]++
} END {
    print "HORA\t\tERRORES\tWARNINGS"
    for (h in error_count) {
        printf "%s\t%d\t%d\n", h, error_count[h], warning_count[h]
    }
}' /var/log/mysql/error.log | sort
```

### Script de Análisis de Error Log

```bash
#!/bin/bash
# analyze_error_log.sh

ERROR_LOG="/var/log/mysql/error.log"
REPORT_FILE="/tmp/mysql_error_report_$(date +%Y%m%d).txt"

analyze_error_log() {
    echo "=== ANÁLISIS DE ERROR LOG MYSQL ===" > $REPORT_FILE
    echo "Fecha: $(date)" >> $REPORT_FILE
    echo "Archivo: $ERROR_LOG" >> $REPORT_FILE
    echo "" >> $REPORT_FILE
    
    # Errores más comunes
    echo "=== ERRORES MÁS COMUNES ===" >> $REPORT_FILE
    grep -i "ERROR" $ERROR_LOG | awk '{
        for(i=4; i<=NF; i++) printf "%s ", $i
        print ""
    }' | sort | uniq -c | sort -nr | head -10 >> $REPORT_FILE
    echo "" >> $REPORT_FILE
    
    # Warnings más comunes
    echo "=== WARNINGS MÁS COMUNES ===" >> $REPORT_FILE
    grep -i "WARNING" $ERROR_LOG | awk '{
        for(i=4; i<=NF; i++) printf "%s ", $i
        print ""
    }' | sort | uniq -c | sort -nr | head -10 >> $REPORT_FILE
    echo "" >> $REPORT_FILE
    
    # Actividad por hora
    echo "=== ACTIVIDAD POR HORA (ÚLTIMAS 24H) ===" >> $REPORT_FILE
    grep "$(date +%Y-%m-%d)" $ERROR_LOG | awk '{
        hour = substr($2, 1, 2)
        if ($0 ~ /ERROR/) errors[hour]++
        if ($0 ~ /WARNING/) warnings[hour]++
        total[hour]++
    } END {
        printf "%-4s %-8s %-8s %-8s\n", "HORA", "TOTAL", "ERRORES", "WARNINGS"
        for (h=0; h<24; h++) {
            h_str = sprintf("%02d", h)
            printf "%-4s %-8d %-8d %-8d\n", h_str, total[h_str]+0, errors[h_str]+0, warnings[h_str]+0
        }
    }' >> $REPORT_FILE
    
    # Conectividad
    echo "" >> $REPORT_FILE
    echo "=== PROBLEMAS DE CONECTIVIDAD ===" >> $REPORT_FILE
    grep -i "connection" $ERROR_LOG | tail -20 >> $REPORT_FILE
    
    echo "Reporte generado en: $REPORT_FILE"
}

analyze_error_log
```

---

## 📊 General Query Log

### Configuración del General Query Log

```sql
-- Habilitar general query log
SET GLOBAL general_log = 'ON';
SET GLOBAL general_log_file = '/var/log/mysql/general.log';

-- Log a tabla (alternativa a archivo)
SET GLOBAL log_output = 'TABLE';
-- Los logs van a mysql.general_log

-- Combinación archivo y tabla
SET GLOBAL log_output = 'FILE,TABLE';
```

```ini
# my.cnf
[mysqld]
general_log = ON
general_log_file = /var/log/mysql/general.log
log_output = FILE
```

### Análisis del General Query Log

```sql
-- Si log_output = 'TABLE', consultar desde tabla
SELECT 
    event_time,
    user_host,
    thread_id,
    server_id,
    command_type,
    LEFT(argument, 100) as query_preview
FROM mysql.general_log 
ORDER BY event_time DESC 
LIMIT 20;

-- Estadísticas por usuario
SELECT 
    SUBSTRING_INDEX(user_host, '[', 1) as user,
    command_type,
    COUNT(*) as query_count
FROM mysql.general_log 
WHERE event_time >= DATE_SUB(NOW(), INTERVAL 1 HOUR)
GROUP BY SUBSTRING_INDEX(user_host, '[', 1), command_type
ORDER BY query_count DESC;

-- Consultas más frecuentes
SELECT 
    LEFT(argument, 200) as query_pattern,
    COUNT(*) as frequency
FROM mysql.general_log 
WHERE command_type = 'Query'
    AND event_time >= DATE_SUB(NOW(), INTERVAL 1 DAY)
GROUP BY LEFT(argument, 200)
ORDER BY frequency DESC
LIMIT 20;
```

---

## 🐌 Slow Query Log

### Configuración del Slow Query Log

```sql
-- Habilitar slow query log
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL slow_query_log_file = '/var/log/mysql/slow.log';
SET GLOBAL long_query_time = 2.0;  -- Consultas > 2 segundos

-- Logging adicional
SET GLOBAL log_queries_not_using_indexes = 'ON';
SET GLOBAL log_slow_admin_statements = 'ON';
SET GLOBAL min_examined_row_limit = 1000;
```

```ini
# my.cnf
[mysqld]
slow_query_log = ON
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 1.0
log_queries_not_using_indexes = ON
log_slow_admin_statements = ON
min_examined_row_limit = 100
```

### Análisis con mysqldumpslow

```bash
# Análisis básico con mysqldumpslow
mysqldumpslow /var/log/mysql/slow.log

# Top 10 consultas más lentas
mysqldumpslow -s t -t 10 /var/log/mysql/slow.log

# Top 10 consultas más frecuentes
mysqldumpslow -s c -t 10 /var/log/mysql/slow.log

# Consultas con más rows examinadas
mysqldumpslow -s e -t 10 /var/log/mysql/slow.log

# Filtrar por tiempo mínimo
mysqldumpslow -t 5 -s t /var/log/mysql/slow.log | grep "Query_time: [5-9]"
```

### Script Avanzado de Análisis

```bash
#!/bin/bash
# analyze_slow_queries.sh

SLOW_LOG="/var/log/mysql/slow.log"
REPORT_DIR="/var/log/mysql/reports"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $REPORT_DIR

analyze_slow_queries() {
    echo "Analizando slow queries..."
    
    # Reporte general
    echo "=== SLOW QUERY ANALYSIS REPORT ===" > $REPORT_DIR/slow_analysis_$DATE.txt
    echo "Generated: $(date)" >> $REPORT_DIR/slow_analysis_$DATE.txt
    echo "" >> $REPORT_DIR/slow_analysis_$DATE.txt
    
    # Top 20 consultas más lentas
    echo "=== TOP 20 SLOWEST QUERIES ===" >> $REPORT_DIR/slow_analysis_$DATE.txt
    mysqldumpslow -s t -t 20 $SLOW_LOG >> $REPORT_DIR/slow_analysis_$DATE.txt
    echo "" >> $REPORT_DIR/slow_analysis_$DATE.txt
    
    # Top 20 consultas más frecuentes
    echo "=== TOP 20 MOST FREQUENT SLOW QUERIES ===" >> $REPORT_DIR/slow_analysis_$DATE.txt
    mysqldumpslow -s c -t 20 $SLOW_LOG >> $REPORT_DIR/slow_analysis_$DATE.txt
    echo "" >> $REPORT_DIR/slow_analysis_$DATE.txt
    
    # Estadísticas por hora
    echo "=== SLOW QUERIES BY HOUR ===" >> $REPORT_DIR/slow_analysis_$DATE.txt
    awk '/^# Time:/ {
        time = $3
        hour = substr(time, 1, 2)
        count[hour]++
    } END {
        print "Hour\tCount"
        for (h in count) {
            print h "\t" count[h]
        }
    }' $SLOW_LOG | sort >> $REPORT_DIR/slow_analysis_$DATE.txt
    
    # Consultas problemáticas (> 10 segundos)
    echo "" >> $REPORT_DIR/slow_analysis_$DATE.txt
    echo "=== CRITICAL SLOW QUERIES (>10s) ===" >> $REPORT_DIR/slow_analysis_$DATE.txt
    mysqldumpslow $SLOW_LOG | grep "Query_time: [1-9][0-9]" >> $REPORT_DIR/slow_analysis_$DATE.txt
    
    echo "Reporte generado: $REPORT_DIR/slow_analysis_$DATE.txt"
}

# Función para limpiar logs antiguos
cleanup_old_logs() {
    echo "Limpiando logs antiguos..."
    find $REPORT_DIR -name "slow_analysis_*.txt" -mtime +30 -delete
    echo "Limpieza completada"
}

analyze_slow_queries
cleanup_old_logs
```

---

## 🔄 Relay Log

### Configuración del Relay Log (Servidores Esclavos)

```ini
# my.cnf para servidor esclavo
[mysqld]
relay-log = relay-bin
relay-log-index = relay-bin.index
max_relay_log_size = 512M
relay_log_purge = ON
relay_log_recovery = ON
```

### Monitoreo del Relay Log

```sql
-- Estado de relay logs
SHOW SLAVE STATUS\G

-- Información específica de relay logs
SELECT 
    channel_name,
    file_name,
    file_position,
    relay_log_file,
    relay_log_pos
FROM performance_schema.replication_applier_status_by_worker;

-- Espacio usado por relay logs
SELECT 
    'RELAY_LOG_SPACE' as metric,
    ROUND(SUM(size)/1024/1024, 2) as size_mb
FROM (
    SELECT size FROM INFORMATION_SCHEMA.FILES 
    WHERE FILE_NAME LIKE '%relay%'
) t;
```

---

## 🔍 Auditoría Empresarial

### MySQL Enterprise Audit Plugin

```sql
-- Instalar plugin de auditoría
INSTALL PLUGIN audit_log SONAME 'audit_log.so';

-- Configurar auditoría
SET GLOBAL audit_log_policy = ALL;
SET GLOBAL audit_log_format = JSON;
SET GLOBAL audit_log_file = '/var/log/mysql/audit.log';

-- Ver configuración
SHOW VARIABLES LIKE 'audit_log%';
```

### Configuración de Filtros de Auditoría

```sql
-- Crear filtro para usuarios administrativos
SELECT audit_log_filter_set_filter('admin_users', '{
  "filter": {
    "users": [
      "admin@localhost",
      "dba@%",
      "root@localhost"
    ]
  }
}');

-- Aplicar filtro a usuario específico
SELECT audit_log_filter_set_user('admin@localhost', 'admin_users');

-- Filtro para eventos específicos
SELECT audit_log_filter_set_filter('security_events', '{
  "filter": {
    "class": [
      {
        "name": "connection",
        "event": {
          "name": [
            "connect",
            "disconnect",
            "change_user"
          ]
        }
      },
      {
        "name": "general",
        "event": {
          "name": [
            "status"
          ]
        }
      }
    ]
  }
}');

-- Filtro para comandos DDL críticos
SELECT audit_log_filter_set_filter('ddl_operations', '{
  "filter": {
    "class": {
      "name": "table_access",
      "event": {
        "name": [
          "insert",
          "update", 
          "delete"
        ]
      }
    }
  }
}');
```

### Auditoría Personalizada con Triggers

```sql
-- Sistema de auditoría personalizado
CREATE DATABASE audit_system;
USE audit_system;

-- Tabla principal de auditoría
CREATE TABLE audit_trail (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    database_name VARCHAR(100),
    table_name VARCHAR(100),
    operation ENUM('INSERT', 'UPDATE', 'DELETE', 'SELECT'),
    user_name VARCHAR(100),
    host_name VARCHAR(100),
    old_values JSON,
    new_values JSON,
    affected_rows INT,
    sql_statement TEXT,
    session_id BIGINT,
    INDEX idx_timestamp (timestamp),
    INDEX idx_user (user_name),
    INDEX idx_table (database_name, table_name),
    INDEX idx_operation (operation)
);

-- Tabla de sesiones de auditoría
CREATE TABLE audit_sessions (
    session_id BIGINT PRIMARY KEY,
    user_name VARCHAR(100),
    host_name VARCHAR(100),
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP NULL,
    total_queries INT DEFAULT 0,
    INDEX idx_user (user_name),
    INDEX idx_start_time (start_time)
);

-- Stored procedure para logging
DELIMITER //
CREATE PROCEDURE log_audit_event(
    IN p_database_name VARCHAR(100),
    IN p_table_name VARCHAR(100),
    IN p_operation VARCHAR(10),
    IN p_old_values JSON,
    IN p_new_values JSON,
    IN p_affected_rows INT,
    IN p_sql_statement TEXT
)
BEGIN
    INSERT INTO audit_trail (
        database_name,
        table_name,
        operation,
        user_name,
        host_name,
        old_values,
        new_values,
        affected_rows,
        sql_statement,
        session_id
    ) VALUES (
        p_database_name,
        p_table_name,
        p_operation,
        USER(),
        @@hostname,
        p_old_values,
        p_new_values,
        p_affected_rows,
        p_sql_statement,
        CONNECTION_ID()
    );
    
    -- Actualizar contador de sesión
    INSERT INTO audit_sessions (session_id, user_name, host_name, total_queries)
    VALUES (CONNECTION_ID(), USER(), @@hostname, 1)
    ON DUPLICATE KEY UPDATE 
        total_queries = total_queries + 1,
        end_time = CURRENT_TIMESTAMP;
END//
DELIMITER ;
```

---

## 📈 Análisis y Monitoreo

### Dashboard de Logs SQL

```sql
-- Vista consolidada de actividad de logs
CREATE VIEW log_dashboard AS
SELECT 
    'General Log' as log_type,
    COUNT(*) as entries,
    MAX(event_time) as last_entry,
    COUNT(DISTINCT SUBSTRING_INDEX(user_host, '[', 1)) as unique_users
FROM mysql.general_log
WHERE event_time >= DATE_SUB(NOW(), INTERVAL 24 HOUR)

UNION ALL

SELECT 
    'Slow Query' as log_type,
    COUNT(*) as entries,
    MAX(start_time) as last_entry,
    COUNT(DISTINCT user) as unique_users
FROM mysql.slow_log
WHERE start_time >= DATE_SUB(NOW(), INTERVAL 24 HOUR);

-- Consultar dashboard
SELECT * FROM log_dashboard;
```

### Alertas Automáticas

```sql
-- Stored procedure para verificar alertas
DELIMITER //
CREATE PROCEDURE check_log_alerts()
BEGIN
    DECLARE slow_count INT;
    DECLARE error_count INT;
    DECLARE connection_failures INT;
    
    -- Contar consultas lentas recientes
    SELECT COUNT(*) INTO slow_count
    FROM mysql.slow_log 
    WHERE start_time >= DATE_SUB(NOW(), INTERVAL 1 HOUR);
    
    -- Contar errores recientes (simulado)
    -- En realidad necesitaríamos parsear el error log
    SET error_count = 0;
    
    -- Generar alertas
    IF slow_count > 100 THEN
        INSERT INTO alert_log VALUES (
            NOW(), 'HIGH_SLOW_QUERIES', 
            CONCAT('Se detectaron ', slow_count, ' consultas lentas en la última hora'),
            'WARNING'
        );
    END IF;
    
    -- Reportar estado
    SELECT 
        'LOG_HEALTH_CHECK' as check_name,
        slow_count as slow_queries_last_hour,
        CASE 
            WHEN slow_count > 100 THEN 'WARNING'
            WHEN slow_count > 50 THEN 'CAUTION'
            ELSE 'OK'
        END as status;
        
END//
DELIMITER ;

-- Crear tabla de alertas si no existe
CREATE TABLE IF NOT EXISTS alert_log (
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    alert_type VARCHAR(50),
    message TEXT,
    severity ENUM('INFO', 'WARNING', 'CRITICAL')
);

-- Ejecutar verificación
CALL check_log_alerts();
```

### Script de Rotación de Logs

```bash
#!/bin/bash
# rotate_mysql_logs.sh

MYSQL_USER="root"
MYSQL_PASS="password"
LOG_DIR="/var/log/mysql"
BACKUP_DIR="/backup/mysql/logs"
RETENTION_DAYS=30

rotate_logs() {
    echo "Iniciando rotación de logs MySQL..."
    
    # Crear directorio de backup
    mkdir -p $BACKUP_DIR/$(date +%Y%m%d)
    
    # Flush logs para crear nuevos archivos
    mysql -u$MYSQL_USER -p$MYSQL_PASS -e "FLUSH LOGS;"
    
    # Mover logs antiguos
    if [ -f "$LOG_DIR/general.log.1" ]; then
        mv $LOG_DIR/general.log.1 $BACKUP_DIR/$(date +%Y%m%d)/general_$(date +%H%M%S).log
    fi
    
    if [ -f "$LOG_DIR/slow.log.1" ]; then
        mv $LOG_DIR/slow.log.1 $BACKUP_DIR/$(date +%Y%m%d)/slow_$(date +%H%M%S).log
    fi
    
    # Comprimir logs backup
    gzip $BACKUP_DIR/$(date +%Y%m%d)/*.log 2>/dev/null
    
    # Limpiar backups antiguos
    find $BACKUP_DIR -type f -mtime +$RETENTION_DAYS -delete
    find $BACKUP_DIR -type d -empty -delete
    
    # Purgar binary logs antiguos
    mysql -u$MYSQL_USER -p$MYSQL_PASS -e "PURGE BINARY LOGS BEFORE DATE(NOW() - INTERVAL 7 DAY);"
    
    echo "Rotación de logs completada"
}

# Limpiar tabla general_log si es muy grande
cleanup_general_log_table() {
    local table_size=$(mysql -u$MYSQL_USER -p$MYSQL_PASS -e "
        SELECT ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'DB Size in MB' 
        FROM information_schema.tables 
        WHERE table_schema='mysql' AND table_name='general_log';" -s -N)
    
    if (( $(echo "$table_size > 1000" | bc -l) )); then
        echo "Limpiando tabla general_log (${table_size}MB)..."
        mysql -u$MYSQL_USER -p$MYSQL_PASS -e "
            DELETE FROM mysql.general_log 
            WHERE event_time < DATE_SUB(NOW(), INTERVAL 7 DAY);"
    fi
}

rotate_logs
cleanup_general_log_table

# Configurar en crontab:
# 0 2 * * 0 /scripts/rotate_mysql_logs.sh
```

---

## 🏆 Mejores Prácticas

### 1. Configuración de Producción

```ini
# my.cnf - Configuración optimizada para producción
[mysqld]
# Error log - siempre habilitado
log-error = /var/log/mysql/error.log
log_error_verbosity = 2

# Binary log - para replicación y recovery
log-bin = mysql-bin
server-id = 1
binlog_format = ROW
sync_binlog = 1
expire_logs_days = 7

# Slow query log - para optimización
slow_query_log = ON
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 1.0
log_queries_not_using_indexes = ON

# General log - solo para debugging (deshabilitar en producción)
general_log = OFF

# Configuración de archivos
max_binlog_size = 512M
```

### 2. Monitoreo Automatizado

```bash
#!/bin/bash
# mysql_log_monitor.sh

# Configuración
MYSQL_USER="monitor"
MYSQL_PASS="MonitorPass123"
ERROR_LOG="/var/log/mysql/error.log"
SLOW_LOG="/var/log/mysql/slow.log"
EMAIL="admin@empresa.com"

# Función de verificación de salud de logs
check_log_health() {
    local status="OK"
    local alerts=""
    
    # Verificar crecimiento de binary logs
    local binlog_size=$(mysql -u$MYSQL_USER -p$MYSQL_PASS -e "
        SELECT ROUND(SUM(file_size)/1024/1024/1024, 2) 
        FROM SHOW BINARY LOGS;" -s -N)
    
    if (( $(echo "$binlog_size > 10" | bc -l) )); then
        alerts="$alerts\nWARNING: Binary logs size: ${binlog_size}GB"
        status="WARNING"
    fi
    
    # Verificar errores recientes
    local recent_errors=$(grep "$(date +%Y-%m-%d)" $ERROR_LOG | grep -i "error" | wc -l)
    if [ $recent_errors -gt 10 ]; then
        alerts="$alerts\nWARNING: $recent_errors errors today"
        status="WARNING"
    fi
    
    # Verificar consultas lentas
    local slow_queries=$(mysql -u$MYSQL_USER -p$MYSQL_PASS -e "
        SELECT COUNT(*) FROM mysql.slow_log 
        WHERE start_time >= DATE_SUB(NOW(), INTERVAL 1 HOUR);" -s -N)
    
    if [ $slow_queries -gt 50 ]; then
        alerts="$alerts\nWARNING: $slow_queries slow queries in last hour"
        status="WARNING"
    fi
    
    # Enviar alerta si hay problemas
    if [ "$status" != "OK" ]; then
        echo -e "MySQL Log Health Status: $status\n$alerts" | \
        mail -s "MySQL Log Alert - $status" $EMAIL
    fi
    
    echo "Log health check: $status"
}

# Función de limpieza
cleanup_logs() {
    # Rotar logs si son muy grandes
    if [ -f "$ERROR_LOG" ] && [ $(stat -f%z "$ERROR_LOG" 2>/dev/null || stat -c%s "$ERROR_LOG") -gt 1073741824 ]; then
        echo "Rotando error log (>1GB)"
        mysql -u$MYSQL_USER -p$MYSQL_PASS -e "FLUSH LOGS;"
    fi
    
    # Limpiar tabla general_log si está habilitada
    mysql -u$MYSQL_USER -p$MYSQL_PASS -e "
        DELETE FROM mysql.general_log 
        WHERE event_time < DATE_SUB(NOW(), INTERVAL 3 DAY);" 2>/dev/null
}

check_log_health
cleanup_logs

# Configurar en crontab:
# */30 * * * * /scripts/mysql_log_monitor.sh
```

### 3. Análisis de Seguridad

```sql
-- Análisis de actividad sospechosa
DELIMITER //
CREATE PROCEDURE security_log_analysis()
BEGIN
    -- Intentos de conexión fallidos
    SELECT 'FAILED_CONNECTIONS' as alert_type, COUNT(*) as count
    FROM mysql.general_log 
    WHERE event_time >= DATE_SUB(NOW(), INTERVAL 1 HOUR)
        AND command_type = 'Connect'
        AND argument LIKE '%Access denied%';
    
    -- Actividad fuera de horario
    SELECT 'OFF_HOURS_ACTIVITY' as alert_type, 
           user_host, 
           COUNT(*) as queries
    FROM mysql.general_log 
    WHERE event_time >= DATE_SUB(NOW(), INTERVAL 1 DAY)
        AND (HOUR(event_time) < 7 OR HOUR(event_time) > 19)
        AND command_type = 'Query'
    GROUP BY user_host
    HAVING COUNT(*) > 100;
    
    -- Consultas DDL sospechosas
    SELECT 'SUSPICIOUS_DDL' as alert_type,
           event_time,
           user_host,
           LEFT(argument, 200) as query
    FROM mysql.general_log 
    WHERE event_time >= DATE_SUB(NOW(), INTERVAL 1 DAY)
        AND command_type = 'Query'
        AND (argument LIKE '%DROP %' 
             OR argument LIKE '%ALTER %' 
             OR argument LIKE '%TRUNCATE %')
    ORDER BY event_time DESC;
END//
DELIMITER ;

-- Ejecutar análisis de seguridad
CALL security_log_analysis();
```

### 4. Backup de Logs

```bash
#!/bin/bash
# backup_mysql_logs.sh

BACKUP_DIR="/backup/mysql/logs"
DATE=$(date +%Y%m%d)
RETENTION_DAYS=90

# Crear estructura de directorios
mkdir -p $BACKUP_DIR/$DATE

# Backup de binary logs
cp /var/lib/mysql/mysql-bin.* $BACKUP_DIR/$DATE/ 2>/dev/null

# Backup de error log
cp /var/log/mysql/error.log $BACKUP_DIR/$DATE/error_$DATE.log

# Backup de slow query log
cp /var/log/mysql/slow.log $BACKUP_DIR/$DATE/slow_$DATE.log

# Comprimir backups
tar -czf $BACKUP_DIR/mysql_logs_$DATE.tar.gz -C $BACKUP_DIR $DATE/
rm -rf $BACKUP_DIR/$DATE

# Limpiar backups antiguos
find $BACKUP_DIR -name "mysql_logs_*.tar.gz" -mtime +$RETENTION_DAYS -delete

echo "Backup de logs completado: mysql_logs_$DATE.tar.gz"
```

---

## 📋 Checklist de Auditoría

### ✅ Configuración Básica
- [ ] Error log habilitado y monitoreado
- [ ] Binary log configurado para replicación/recovery
- [ ] Slow query log habilitado para optimización
- [ ] General log deshabilitado en producción
- [ ] Configuración de rotación automática

### ✅ Seguridad
- [ ] Auditoría de accesos privilegiados
- [ ] Monitoreo de intentos de acceso fallidos
- [ ] Logging de cambios DDL críticos
- [ ] Análisis de actividad fuera de horario
- [ ] Backup seguro de logs de auditoría

### ✅ Performance
- [ ] Monitoreo de crecimiento de logs
- [ ] Análisis regular de slow queries
- [ ] Optimización de configuración de logs
- [ ] Limpieza automática de logs antiguos
- [ ] Alertas de uso excesivo de espacio

### ✅ Compliance
- [ ] Retención de logs según políticas
- [ ] Integridad y no repudio de logs
- [ ] Acceso controlado a logs de auditoría
- [ ] Documentación de procedimientos
- [ ] Revisión periódica de configuración

---

*Última actualización: 28/05/2025*
