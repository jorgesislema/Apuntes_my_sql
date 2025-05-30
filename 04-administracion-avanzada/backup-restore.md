# Backup y Restore en MySQL

## 📋 Índice
1. [Tipos de Backup](#tipos-de-backup)
2. [Herramientas de Backup](#herramientas-de-backup)
3. [Estrategias de Backup](#estrategias-de-backup)
4. [Backup Físico vs Lógico](#backup-físico-vs-lógico)
5. [Implementación Práctica](#implementación-práctica)
6. [Restauración](#restauración)
7. [Automatización](#automatización)
8. [Mejores Prácticas](#mejores-prácticas)

---

## 🎯 Tipos de Backup

### 1. Backup Completo (Full Backup)
- **Descripción**: Copia completa de toda la base de datos
- **Frecuencia**: Semanal o diario
- **Ventajas**: Restauración simple y rápida
- **Desventajas**: Requiere más espacio y tiempo

```bash
# Ejemplo de backup completo con mysqldump
mysqldump -u root -p --all-databases --routines --triggers > backup_completo_$(date +%Y%m%d_%H%M%S).sql
```

### 2. Backup Incremental
- **Descripción**: Solo cambios desde el último backup
- **Frecuencia**: Cada hora o diario
- **Ventajas**: Rápido y eficiente en espacio
- **Desventajas**: Restauración más compleja

```bash
# Configurar binary logs para backups incrementales
# En my.cnf:
[mysqld]
log-bin=mysql-bin
expire_logs_days=7
```

### 3. Backup Diferencial
- **Descripción**: Cambios desde el último backup completo
- **Frecuencia**: Diario
- **Ventajas**: Balance entre tiempo y espacio
- **Desventajas**: Crecimiento progresivo del tamaño

---

## 🛠️ Herramientas de Backup

### 1. mysqldump (Backup Lógico)

#### Sintaxis Básica
```bash
# Backup de una base de datos específica
mysqldump -u usuario -p base_de_datos > backup.sql

# Backup con parámetros avanzados
mysqldump -u root -p \
  --single-transaction \
  --routines \
  --triggers \
  --events \
  --hex-blob \
  --master-data=2 \
  --flush-logs \
  mi_base_datos > backup_completo.sql
```

#### Parámetros Importantes
- `--single-transaction`: Consistencia para InnoDB
- `--routines`: Incluye stored procedures y functions
- `--triggers`: Incluye triggers
- `--events`: Incluye eventos programados
- `--master-data`: Información de replicación
- `--flush-logs`: Crea nuevo binary log

#### Backup Selectivo
```bash
# Backup de tablas específicas
mysqldump -u root -p base_datos tabla1 tabla2 > backup_tablas.sql

# Backup solo estructura (sin datos)
mysqldump -u root -p --no-data base_datos > estructura.sql

# Backup solo datos (sin estructura)
mysqldump -u root -p --no-create-info base_datos > datos.sql
```

### 2. MySQL Enterprise Backup (Backup Físico)

```bash
# Backup completo con MySQL Enterprise Backup
mysqlbackup --user=root --password \
  --backup-dir=/backup/full \
  backup-and-apply-log

# Backup incremental
mysqlbackup --user=root --password \
  --backup-dir=/backup/inc1 \
  --incremental \
  --incremental-base=dir:/backup/full \
  backup
```

### 3. Percona XtraBackup (Alternativa Open Source)

```bash
# Instalación en Ubuntu/Debian
sudo apt-get install percona-xtrabackup-80

# Backup completo con XtraBackup
xtrabackup --backup --target-dir=/backup/full --user=root --password=password

# Preparar backup para restauración
xtrabackup --prepare --target-dir=/backup/full
```

### 4. Binary Logs para Backup Incremental

```sql
-- Verificar configuración de binary logs
SHOW VARIABLES LIKE 'log_bin%';
SHOW VARIABLES LIKE 'binlog%';

-- Ver binary logs disponibles
SHOW BINARY LOGS;

-- Ver eventos en un binary log específico
SHOW BINLOG EVENTS IN 'mysql-bin.000001';
```

---

## 📊 Estrategias de Backup

### Estrategia 3-2-1
- **3 copias** de datos importantes
- **2 tipos diferentes** de medios de almacenamiento
- **1 copia offsite** (fuera del sitio)

### Cronograma Recomendado

| Tipo | Frecuencia | Retención | Herramienta |
|------|------------|-----------|-------------|
| Completo | Semanal | 3 meses | mysqldump |
| Incremental | Diario | 30 días | Binary logs |
| Snapshot | Por hora | 7 días | LVM/Cloud |

### Ejemplo de Estrategia Empresarial

```bash
#!/bin/bash
# Estrategia de backup empresarial

# Variables
BACKUP_DIR="/backups/mysql"
DATE=$(date +%Y%m%d_%H%M%S)
USER="backup_user"
DATABASES="produccion desarrollo"

# Backup completo (domingos)
if [ $(date +%u) -eq 7 ]; then
    for db in $DATABASES; do
        mysqldump -u $USER -p$MYSQL_PASSWORD \
            --single-transaction \
            --routines --triggers --events \
            $db > $BACKUP_DIR/full/${db}_full_$DATE.sql
    done
fi

# Backup incremental (diario)
mysqladmin -u $USER -p$MYSQL_PASSWORD flush-logs
cp /var/lib/mysql/mysql-bin.* $BACKUP_DIR/incremental/
```

---

## 🔄 Backup Físico vs Lógico

### Backup Lógico (mysqldump)

**Ventajas:**
- Portable entre versiones y plataformas
- Fácil de inspeccionar y modificar
- Backup selectivo granular
- Compresión efectiva

**Desventajas:**
- Más lento para bases de datos grandes
- Requiere más CPU durante el backup
- Mayor tiempo de restauración

**Casos de uso:**
- Migración entre servidores
- Backup de desarrollo
- Bases de datos < 100GB

### Backup Físico (XtraBackup/Enterprise)

**Ventajas:**
- Backup muy rápido
- Backup en caliente sin bloqueos
- Ideal para bases de datos grandes
- Menos overhead de CPU

**Desventajas:**
- Menos portable
- Requiere misma versión para restore
- Más complejo de automatizar

**Casos de uso:**
- Producción con alta disponibilidad
- Bases de datos > 100GB
- Replicación y clustering

---

## 🔧 Implementación Práctica

### Script de Backup Completo

```bash
#!/bin/bash
# backup_mysql.sh - Script completo de backup

# Configuración
MYSQL_USER="backup_user"
MYSQL_PASSWORD="secure_password"
BACKUP_ROOT="/backups/mysql"
RETENTION_DAYS=30
DATABASES="app1 app2 logs"

# Crear directorios
mkdir -p $BACKUP_ROOT/{full,incremental,logs}

# Función de logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> $BACKUP_ROOT/logs/backup.log
}

# Función de backup
backup_database() {
    local db=$1
    local backup_file="$BACKUP_ROOT/full/${db}_$(date +%Y%m%d_%H%M%S).sql"
    
    log "Iniciando backup de $db"
    
    mysqldump -u $MYSQL_USER -p$MYSQL_PASSWORD \
        --single-transaction \
        --routines \
        --triggers \
        --events \
        --hex-blob \
        --master-data=2 \
        $db > $backup_file
    
    if [ $? -eq 0 ]; then
        # Comprimir backup
        gzip $backup_file
        log "Backup de $db completado: ${backup_file}.gz"
        
        # Verificar integridad
        gunzip -t ${backup_file}.gz
        if [ $? -eq 0 ]; then
            log "Verificación de integridad OK para $db"
        else
            log "ERROR: Verificación de integridad falló para $db"
        fi
    else
        log "ERROR: Backup de $db falló"
    fi
}

# Ejecutar backups
for db in $DATABASES; do
    backup_database $db
done

# Limpiar backups antiguos
find $BACKUP_ROOT/full -name "*.gz" -mtime +$RETENTION_DAYS -delete
log "Limpieza de backups antiguos completada"

# Backup de configuración
cp /etc/mysql/my.cnf $BACKUP_ROOT/config/my.cnf.$(date +%Y%m%d)

log "Proceso de backup completado"
```

### Monitoreo de Backup

```sql
-- Crear tabla para monitoreo de backups
CREATE TABLE backup_monitor (
    id INT PRIMARY KEY AUTO_INCREMENT,
    database_name VARCHAR(100),
    backup_type ENUM('FULL', 'INCREMENTAL'),
    backup_size BIGINT,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    status ENUM('SUCCESS', 'FAILED'),
    backup_file VARCHAR(500),
    error_message TEXT
);

-- Stored procedure para registrar backup
DELIMITER //
CREATE PROCEDURE log_backup(
    IN db_name VARCHAR(100),
    IN backup_type VARCHAR(20),
    IN backup_size BIGINT,
    IN start_time TIMESTAMP,
    IN end_time TIMESTAMP,
    IN status VARCHAR(10),
    IN backup_file VARCHAR(500),
    IN error_message TEXT
)
BEGIN
    INSERT INTO backup_monitor VALUES (
        NULL, db_name, backup_type, backup_size,
        start_time, end_time, status, backup_file, error_message
    );
END//
DELIMITER ;
```

---

## 🔄 Restauración

### Restauración Completa con mysqldump

```bash
# Restauración básica
mysql -u root -p base_datos < backup.sql

# Restauración con parámetros específicos
mysql -u root -p \
    --default-character-set=utf8 \
    --max_allowed_packet=1G \
    base_datos < backup.sql
```

### Restauración Point-in-Time

```bash
# 1. Restaurar backup completo hasta punto específico
mysql -u root -p < backup_completo.sql

# 2. Aplicar binary logs hasta punto específico
mysqlbinlog --start-datetime="2025-05-28 10:00:00" \
            --stop-datetime="2025-05-28 14:30:00" \
            mysql-bin.000001 mysql-bin.000002 | mysql -u root -p

# 3. O hasta posición específica
mysqlbinlog --start-position=4 \
            --stop-position=12345 \
            mysql-bin.000001 | mysql -u root -p
```

### Restauración con XtraBackup

```bash
# 1. Parar MySQL
sudo systemctl stop mysql

# 2. Limpiar directorio de datos
sudo rm -rf /var/lib/mysql/*

# 3. Restaurar backup
sudo xtrabackup --copy-back --target-dir=/backup/full

# 4. Cambiar permisos
sudo chown -R mysql:mysql /var/lib/mysql

# 5. Iniciar MySQL
sudo systemctl start mysql
```

### Procedimiento de Recuperación de Desastre

```bash
#!/bin/bash
# disaster_recovery.sh

# 1. Verificar disponibilidad del servidor
if ! mysqladmin ping -h localhost -u root -p$MYSQL_PASSWORD; then
    echo "MySQL no responde - iniciando recuperación de desastre"
    
    # 2. Obtener último backup válido
    LATEST_BACKUP=$(find /backups/mysql/full -name "*.gz" -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -d' ' -f2-)
    
    # 3. Restaurar backup
    echo "Restaurando desde: $LATEST_BACKUP"
    gunzip -c $LATEST_BACKUP | mysql -u root -p$MYSQL_PASSWORD
    
    # 4. Aplicar binary logs
    echo "Aplicando binary logs..."
    # Código para aplicar logs incrementales
    
    # 5. Verificar integridad
    mysqlcheck --all-databases --check --auto-repair -u root -p$MYSQL_PASSWORD
    
    echo "Recuperación completada"
fi
```

---

## ⚙️ Automatización

### Cron Jobs para Backup Automático

```bash
# Editar crontab
crontab -e

# Backup completo los domingos a las 2 AM
0 2 * * 0 /scripts/backup_mysql.sh full

# Backup incremental diario a las 2 AM (lunes a sábado)
0 2 * * 1-6 /scripts/backup_mysql.sh incremental

# Flush logs cada 6 horas
0 */6 * * * mysqladmin -u backup_user -ppassword flush-logs

# Verificación de integridad semanal
0 4 * * 1 /scripts/verify_backups.sh
```

### Script de Verificación

```bash
#!/bin/bash
# verify_backups.sh

BACKUP_DIR="/backups/mysql/full"
LOG_FILE="/var/log/backup_verification.log"

# Función para verificar backup
verify_backup() {
    local backup_file=$1
    echo "[$(date)] Verificando $backup_file" >> $LOG_FILE
    
    # Verificar compresión
    if gunzip -t "$backup_file" 2>/dev/null; then
        echo "[$(date)] ✓ Compresión OK" >> $LOG_FILE
        
        # Verificar contenido SQL
        if gunzip -c "$backup_file" | head -n 100 | grep -q "MySQL dump"; then
            echo "[$(date)] ✓ Contenido válido" >> $LOG_FILE
            return 0
        else
            echo "[$(date)] ✗ Contenido inválido" >> $LOG_FILE
            return 1
        fi
    else
        echo "[$(date)] ✗ Error de compresión" >> $LOG_FILE
        return 1
    fi
}

# Verificar últimos 7 backups
find $BACKUP_DIR -name "*.gz" -mtime -7 | while read backup; do
    verify_backup "$backup"
done
```

### Notificaciones por Email

```bash
#!/bin/bash
# Función para enviar notificaciones

send_notification() {
    local status=$1
    local message=$2
    
    if [ "$status" = "ERROR" ]; then
        echo "$message" | mail -s "ERROR: Backup MySQL falló" admin@empresa.com
    elif [ "$status" = "SUCCESS" ]; then
        echo "$message" | mail -s "SUCCESS: Backup MySQL completado" admin@empresa.com
    fi
}

# Uso en script de backup
if [ $backup_result -eq 0 ]; then
    send_notification "SUCCESS" "Backup completado exitosamente en $(date)"
else
    send_notification "ERROR" "Backup falló en $(date). Revisar logs."
fi
```

---

## 🏆 Mejores Prácticas

### 1. Seguridad
```bash
# Crear usuario específico para backups
CREATE USER 'backup_user'@'localhost' IDENTIFIED BY 'secure_password';
GRANT SELECT, LOCK TABLES, SHOW VIEW, EVENT, TRIGGER, RELOAD ON *.* TO 'backup_user'@'localhost';

# Proteger archivos de backup
chmod 600 /backups/mysql/*
chown mysql:mysql /backups/mysql/*
```

### 2. Performance
- Usar `--single-transaction` para InnoDB
- Programar backups en horas de menor carga
- Comprimir backups para ahorrar espacio
- Usar almacenamiento rápido para backups

### 3. Testing
```bash
# Script de testing de restore
#!/bin/bash
# test_restore.sh

# Crear instancia temporal
docker run --name mysql-test -e MYSQL_ROOT_PASSWORD=test -d mysql:8.0

# Restaurar backup
docker exec -i mysql-test mysql -uroot -ptest < /backup/test.sql

# Verificar datos
docker exec mysql-test mysql -uroot -ptest -e "SELECT COUNT(*) FROM test.users;"

# Limpiar
docker rm -f mysql-test
```

### 4. Documentación

Mantener registro de:
- Cronograma de backups
- Ubicación de archivos
- Procedimientos de restauración
- Contactos de emergencia
- Últimas pruebas de restore

### 5. Monitoreo

```sql
-- Query para verificar estado de binary logs
SELECT 
    File_size,
    ROUND(File_size/1024/1024, 2) as Size_MB
FROM INFORMATION_SCHEMA.FILES 
WHERE ENGINE = 'BINLOG';

-- Verificar espacio disponible
SELECT 
    table_schema as 'Database',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) as 'Size (MB)'
FROM information_schema.tables 
GROUP BY table_schema;
```

---

## 🚨 Troubleshooting Común

### Problemas y Soluciones

1. **Backup demasiado lento**
   - Usar `--single-transaction` en lugar de `--lock-tables`
   - Incrementar `--max_allowed_packet`
   - Backup por tablas en paralelo

2. **Archivos de backup corruptos**
   - Verificar espacio en disco
   - Usar `--hex-blob` para datos binarios
   - Implementar checksums

3. **Restauración falla**
   - Verificar charset y collation
   - Usar `--force` para continuar con errores
   - Revisar permisos de usuario

4. **Binary logs llenan disco**
   - Configurar `expire_logs_days`
   - Implementar rotación automática
   - Monitorear crecimiento

---

*Última actualización: 28/05/2025*
