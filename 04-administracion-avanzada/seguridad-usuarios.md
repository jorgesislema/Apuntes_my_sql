# Seguridad y Gestión de Usuarios en MySQL

## 📋 Índice
1. [Arquitectura de Seguridad](#arquitectura-de-seguridad)
2. [Gestión de Usuarios](#gestión-de-usuarios)
3. [Sistema de Privilegios](#sistema-de-privilegios)
4. [Autenticación](#autenticación)
5. [Cifrado y SSL](#cifrado-y-ssl)
6. [Auditoría](#auditoría)
7. [Mejores Prácticas](#mejores-prácticas)
8. [Troubleshooting](#troubleshooting)

---

## 🔐 Arquitectura de Seguridad

### Capas de Seguridad en MySQL

```
┌─────────────────────────────────────┐
│           Aplicación                │
├─────────────────────────────────────┤
│        Red/Firewall                 │
├─────────────────────────────────────┤
│    Conexión SSL/TLS                 │
├─────────────────────────────────────┤
│     Autenticación                   │
├─────────────────────────────────────┤
│      Autorización                   │
├─────────────────────────────────────┤
│   Cifrado de Datos                  │
├─────────────────────────────────────┤
│      Auditoría                      │
└─────────────────────────────────────┘
```

### Principios Fundamentales

1. **Principio de Menor Privilegio**: Otorgar solo permisos mínimos necesarios
2. **Defensa en Profundidad**: Múltiples capas de seguridad
3. **Separación de Funciones**: Roles específicos por función
4. **Auditoría Continua**: Registro y monitoreo de actividades

---

## 👥 Gestión de Usuarios

### Creación de Usuarios

```sql
-- Sintaxis básica
CREATE USER 'usuario'@'host' IDENTIFIED BY 'password';

-- Ejemplos específicos
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'Admin@2025!';
CREATE USER 'app_user'@'192.168.1.%' IDENTIFIED BY 'SecureApp123';
CREATE USER 'readonly'@'%' IDENTIFIED BY 'ReadOnly456';

-- Usuario con autenticación por plugin
CREATE USER 'ldap_user'@'%' IDENTIFIED WITH authentication_ldap_simple;

-- Usuario con expiración de password
CREATE USER 'temp_user'@'localhost' 
IDENTIFIED BY 'TempPass123' 
PASSWORD EXPIRE INTERVAL 30 DAY;
```

### Modificación de Usuarios

```sql
-- Cambiar password
ALTER USER 'usuario'@'host' IDENTIFIED BY 'nuevo_password';

-- Forzar cambio de password en próximo login
ALTER USER 'usuario'@'host' PASSWORD EXPIRE;

-- Deshabilitar usuario
ALTER USER 'usuario'@'host' ACCOUNT LOCK;

-- Habilitar usuario
ALTER USER 'usuario'@'host' ACCOUNT UNLOCK;

-- Establecer límites de recursos
ALTER USER 'usuario'@'host' 
WITH MAX_QUERIES_PER_HOUR 1000
     MAX_UPDATES_PER_HOUR 100
     MAX_CONNECTIONS_PER_HOUR 50
     MAX_USER_CONNECTIONS 5;
```

### Eliminación de Usuarios

```sql
-- Eliminar usuario
DROP USER 'usuario'@'host';

-- Eliminar múltiples usuarios
DROP USER 'user1'@'localhost', 'user2'@'%';

-- Verificar usuarios existentes antes de eliminar
SELECT User, Host FROM mysql.user WHERE User = 'usuario_a_eliminar';
```

---

## 🔑 Sistema de Privilegios

### Tipos de Privilegios

#### Privilegios Globales
```sql
-- Privilegios administrativos
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' WITH GRANT OPTION;
GRANT SUPER, PROCESS, RELOAD ON *.* TO 'dba'@'localhost';

-- Privilegios específicos
GRANT SELECT, INSERT, UPDATE, DELETE ON *.* TO 'app_global'@'%';
```

#### Privilegios de Base de Datos
```sql
-- Todos los privilegios en una base de datos
GRANT ALL PRIVILEGES ON empresa.* TO 'app_admin'@'localhost';

-- Privilegios específicos
GRANT SELECT, INSERT, UPDATE ON empresa.* TO 'app_user'@'192.168.1.%';
GRANT SELECT ON empresa.* TO 'readonly'@'%';
```

#### Privilegios de Tabla
```sql
-- Privilegios en tabla específica
GRANT SELECT, INSERT ON empresa.empleados TO 'hr_user'@'localhost';
GRANT UPDATE (salario) ON empresa.empleados TO 'payroll'@'localhost';

-- Solo ciertas columnas
GRANT SELECT (nombre, email) ON empresa.empleados TO 'public_user'@'%';
```

#### Privilegios de Columna
```sql
-- Acceso granular por columna
GRANT SELECT (id, nombre, email), 
      UPDATE (email, telefono) 
ON empresa.empleados TO 'profile_editor'@'localhost';
```

### Roles (MySQL 8.0+)

```sql
-- Crear roles
CREATE ROLE 'admin_role', 'readonly_role', 'developer_role';

-- Asignar privilegios a roles
GRANT ALL PRIVILEGES ON empresa.* TO 'admin_role';
GRANT SELECT ON empresa.* TO 'readonly_role';
GRANT SELECT, INSERT, UPDATE, DELETE ON desarrollo.* TO 'developer_role';

-- Asignar roles a usuarios
GRANT 'admin_role' TO 'juan'@'localhost';
GRANT 'readonly_role' TO 'maria'@'%';
GRANT 'developer_role', 'readonly_role' TO 'carlos'@'localhost';

-- Activar roles por defecto
ALTER USER 'juan'@'localhost' DEFAULT ROLE 'admin_role';
ALTER USER 'carlos'@'localhost' DEFAULT ROLE ALL;

-- Ver roles activos
SELECT CURRENT_ROLE();

-- Cambiar rol activo en sesión
SET ROLE 'developer_role';
SET ROLE ALL;
SET ROLE NONE;
```

### Gestión Avanzada de Privilegios

```sql
-- Crear usuario con privilegios específicos para aplicación web
CREATE USER 'webapp'@'app-server.empresa.com' IDENTIFIED BY 'WebApp2025!';

GRANT SELECT, INSERT, UPDATE, DELETE ON empresa.productos TO 'webapp'@'app-server.empresa.com';
GRANT SELECT, INSERT, UPDATE ON empresa.pedidos TO 'webapp'@'app-server.empresa.com';
GRANT SELECT ON empresa.clientes TO 'webapp'@'app-server.empresa.com';
GRANT EXECUTE ON PROCEDURE empresa.procesar_pedido TO 'webapp'@'app-server.empresa.com';

-- Usuario para backups
CREATE USER 'backup_user'@'backup-server.empresa.com' IDENTIFIED BY 'Backup2025!';
GRANT SELECT, LOCK TABLES, SHOW VIEW, EVENT, TRIGGER, RELOAD ON *.* TO 'backup_user'@'backup-server.empresa.com';

-- Usuario para monitoreo
CREATE USER 'monitor'@'monitoring.empresa.com' IDENTIFIED BY 'Monitor2025!';
GRANT PROCESS, REPLICATION CLIENT ON *.* TO 'monitor'@'monitoring.empresa.com';
GRANT SELECT ON performance_schema.* TO 'monitor'@'monitoring.empresa.com';
GRANT SELECT ON information_schema.* TO 'monitor'@'monitoring.empresa.com';
```

---

## 🔐 Autenticación

### Plugins de Autenticación

#### mysql_native_password (Por defecto hasta MySQL 5.7)
```sql
CREATE USER 'user_native'@'localhost' 
IDENTIFIED WITH mysql_native_password BY 'password123';
```

#### caching_sha2_password (Por defecto en MySQL 8.0+)
```sql
CREATE USER 'user_sha2'@'localhost' 
IDENTIFIED WITH caching_sha2_password BY 'password123';
```

#### authentication_ldap_simple
```sql
-- Configurar en my.cnf
[mysqld]
plugin-load-add=authentication_ldap_simple.so
authentication_ldap_simple_server_host=ldap.empresa.com
authentication_ldap_simple_server_port=389

-- Crear usuario LDAP
CREATE USER 'ldap_user'@'%' 
IDENTIFIED WITH authentication_ldap_simple;
```

#### Autenticación por Socket (Unix)
```sql
CREATE USER 'socket_user'@'localhost' 
IDENTIFIED WITH auth_socket;
```

### Políticas de Password

```sql
-- Configurar validación de passwords
INSTALL COMPONENT 'file://component_validate_password';

-- Ver configuración actual
SHOW VARIABLES LIKE 'validate_password%';

-- Configurar política de passwords
SET GLOBAL validate_password.policy = STRONG;
SET GLOBAL validate_password.length = 12;
SET GLOBAL validate_password.mixed_case_count = 1;
SET GLOBAL validate_password.number_count = 2;
SET GLOBAL validate_password.special_char_count = 1;

-- Verificar fortaleza de password
SELECT VALIDATE_PASSWORD_STRENGTH('MiPassword123!');
```

### Autenticación Multi-Factor (MySQL 8.0.27+)

```sql
-- Habilitar MFA para usuario
ALTER USER 'secure_user'@'localhost' 
ADD 2 FACTOR IDENTIFIED WITH authentication_fido;

-- Ver factores de autenticación
SELECT User, Host, plugin, authentication_string 
FROM mysql.user WHERE User = 'secure_user';
```

---

## 🔒 Cifrado y SSL

### Configuración SSL

#### Generar Certificados
```bash
# Generar certificados SSL para MySQL
mysql_ssl_rsa_setup --datadir=/var/lib/mysql

# Verificar archivos generados
ls -la /var/lib/mysql/*.pem
```

#### Configuración del Servidor
```ini
# my.cnf
[mysqld]
ssl-ca=/var/lib/mysql/ca.pem
ssl-cert=/var/lib/mysql/server-cert.pem
ssl-key=/var/lib/mysql/server-key.pem

# Forzar SSL para todas las conexiones
require_secure_transport=ON
```

#### Configuración de Usuarios SSL
```sql
-- Usuario que requiere SSL
CREATE USER 'ssl_user'@'%' 
IDENTIFIED BY 'password123' 
REQUIRE SSL;

-- Usuario con certificado específico
CREATE USER 'cert_user'@'%' 
IDENTIFIED BY 'password123' 
REQUIRE X509;

-- Usuario con certificado y issuer específicos
CREATE USER 'secure_user'@'%' 
IDENTIFIED BY 'password123' 
REQUIRE SUBJECT '/CN=client.empresa.com'
AND ISSUER '/CN=CA-empresa.com';
```

### Cifrado de Datos

#### Cifrado at Rest (InnoDB)
```sql
-- Crear tabla con cifrado
CREATE TABLE datos_sensibles (
    id INT PRIMARY KEY,
    numero_tarjeta VARCHAR(20),
    datos_personales TEXT
) ENCRYPTION='Y';

-- Configurar cifrado por defecto
SET GLOBAL default_table_encryption=ON;
```

#### Cifrado de Binary Logs
```ini
# my.cnf
[mysqld]
binlog-encryption=ON
binlog-rotate-encryption-master-key-at-startup=ON
```

#### Funciones de Cifrado
```sql
-- Cifrar datos con AES
INSERT INTO usuarios (nombre, email_cifrado) 
VALUES ('Juan', AES_ENCRYPT('juan@empresa.com', 'clave_secreta'));

-- Descifrar datos
SELECT nombre, AES_DECRYPT(email_cifrado, 'clave_secreta') as email 
FROM usuarios;

-- Hash de passwords
SELECT SHA2('password123', 256);
SELECT PASSWORD('password123');
```

---

## 📊 Auditoría

### MySQL Enterprise Audit

#### Instalación y Configuración
```sql
-- Instalar plugin de auditoría
INSTALL PLUGIN audit_log SONAME 'audit_log.so';

-- Configurar auditoría
SET GLOBAL audit_log_policy = ALL;
SET GLOBAL audit_log_format = JSON;
```

#### Configuración de Filtros
```sql
-- Crear filtro para usuarios específicos
SELECT audit_log_filter_set_filter('admin_filter', 
'{ "filter": { "users": [ "admin@localhost", "dba@%" ] } }');

-- Aplicar filtro
SELECT audit_log_filter_set_user('admin@localhost', 'admin_filter');

-- Filtro por eventos específicos
SELECT audit_log_filter_set_filter('login_filter', 
'{ "filter": { "class": { "name": "connection" } } }');
```

### Auditoría Manual con Triggers

```sql
-- Tabla de auditoría
CREATE TABLE audit_log (
    id INT PRIMARY KEY AUTO_INCREMENT,
    table_name VARCHAR(100),
    operation ENUM('INSERT', 'UPDATE', 'DELETE'),
    user_name VARCHAR(100),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old_values JSON,
    new_values JSON,
    ip_address VARCHAR(45)
);

-- Trigger de auditoría para tabla empleados
DELIMITER //
CREATE TRIGGER audit_empleados_update
    AFTER UPDATE ON empleados
    FOR EACH ROW
BEGIN
    INSERT INTO audit_log (
        table_name, operation, user_name, old_values, new_values, ip_address
    ) VALUES (
        'empleados', 
        'UPDATE', 
        USER(),
        JSON_OBJECT('id', OLD.id, 'nombre', OLD.nombre, 'salario', OLD.salario),
        JSON_OBJECT('id', NEW.id, 'nombre', NEW.nombre, 'salario', NEW.salario),
        CONNECTION_ID()
    );
END//
DELIMITER ;
```

### Análisis de Logs

```sql
-- Consultas sospechosas por hora
SELECT 
    HOUR(timestamp) as hora,
    COUNT(*) as intentos_login,
    COUNT(DISTINCT ip_address) as ips_distintas
FROM audit_log 
WHERE operation = 'LOGIN_FAILED'
    AND DATE(timestamp) = CURDATE()
GROUP BY HOUR(timestamp)
ORDER BY intentos_login DESC;

-- Usuarios con más modificaciones
SELECT 
    user_name,
    COUNT(*) as modificaciones,
    COUNT(DISTINCT table_name) as tablas_afectadas
FROM audit_log 
WHERE operation IN ('INSERT', 'UPDATE', 'DELETE')
    AND timestamp >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY user_name
ORDER BY modificaciones DESC;

-- Actividad fuera de horario laboral
SELECT 
    user_name,
    table_name,
    operation,
    timestamp
FROM audit_log 
WHERE (HOUR(timestamp) < 8 OR HOUR(timestamp) > 18)
    AND WEEKDAY(timestamp) BETWEEN 0 AND 4  -- Lunes a Viernes
    AND timestamp >= DATE_SUB(NOW(), INTERVAL 30 DAY)
ORDER BY timestamp DESC;
```

---

## 🛡️ Mejores Prácticas

### 1. Gestión de Usuarios

```sql
-- Crear esquema de naming para usuarios
-- Formato: [app]_[role]_[env]
CREATE USER 'webapp_read_prod'@'app-server-01.empresa.com';
CREATE USER 'webapp_write_prod'@'app-server-01.empresa.com';
CREATE USER 'analytics_read_prod'@'analytics.empresa.com';

-- Usar roles para simplificar gestión
CREATE ROLE 'app_readonly', 'app_readwrite', 'app_admin';

-- Documentar propósito de cada usuario
INSERT INTO user_documentation VALUES 
('webapp_read_prod', 'Usuario de lectura para aplicación web en producción', 'IT Team');
```

### 2. Seguridad de Passwords

```sql
-- Política de passwords robusta
SET GLOBAL validate_password.policy = STRONG;
SET GLOBAL validate_password.length = 14;
SET GLOBAL validate_password.check_user_name = ON;

-- Expiración regular de passwords
ALTER USER 'app_user'@'%' PASSWORD EXPIRE INTERVAL 90 DAY;

-- Historia de passwords
SET GLOBAL password_history = 5;
SET GLOBAL password_reuse_interval = 365;
```

### 3. Principio de Menor Privilegio

```sql
-- Ejemplo: Usuario para aplicación de reportes
CREATE USER 'reports_app'@'reporting-server.empresa.com' 
IDENTIFIED BY 'SecureReports2025!';

-- Solo permisos necesarios
GRANT SELECT ON empresa.ventas TO 'reports_app'@'reporting-server.empresa.com';
GRANT SELECT ON empresa.productos TO 'reports_app'@'reporting-server.empresa.com';
GRANT SELECT ON empresa.clientes TO 'reports_app'@'reporting-server.empresa.com';

-- Funciones específicas para reportes
GRANT EXECUTE ON FUNCTION empresa.calcular_comision TO 'reports_app'@'reporting-server.empresa.com';
GRANT EXECUTE ON PROCEDURE empresa.generar_reporte_mensual TO 'reports_app'@'reporting-server.empresa.com';
```

### 4. Monitoreo Continuo

```sql
-- Script de monitoreo de seguridad
DELIMITER //
CREATE PROCEDURE security_health_check()
BEGIN
    -- Usuarios sin password
    SELECT 'Usuarios sin password' as issue, User, Host 
    FROM mysql.user 
    WHERE authentication_string = '';
    
    -- Usuarios con privilegios excesivos
    SELECT 'Usuarios con ALL PRIVILEGES' as issue, User, Host 
    FROM mysql.user 
    WHERE Super_priv = 'Y' OR Grant_priv = 'Y';
    
    -- Conexiones desde IPs sospechosas
    SELECT 'Conexiones remotas como root' as issue, User, Host 
    FROM mysql.user 
    WHERE User = 'root' AND Host != 'localhost';
    
    -- Usuarios inactivos por mucho tiempo
    SELECT 'Usuarios no utilizados recientemente' as issue, 
           u.User, u.Host, 'No hay registros de conexión' as last_login
    FROM mysql.user u
    LEFT JOIN information_schema.processlist p ON u.User = p.User
    WHERE p.User IS NULL AND u.User != 'root';
END//
DELIMITER ;

-- Ejecutar verificación
CALL security_health_check();
```

### 5. Configuración del Servidor

```ini
# my.cnf - Configuración de seguridad
[mysqld]
# Deshabilitar carga de archivos locales
local_infile=OFF

# Deshabilitar symbolic links
symbolic-links=0

# Configurar bind-address para controlar conexiones
bind-address=127.0.0.1

# Logging detallado
general_log=ON
general_log_file=/var/log/mysql/general.log
log_error=/var/log/mysql/error.log

# Limitar conexiones
max_connections=100
max_user_connections=10

# SSL obligatorio
require_secure_transport=ON

# Validación de passwords
validate_password.policy=STRONG
```

---

## 🔧 Troubleshooting

### Problemas Comunes de Autenticación

#### Error: Access denied for user
```sql
-- Verificar usuario existe
SELECT User, Host, account_locked, password_expired 
FROM mysql.user 
WHERE User = 'usuario_problema';

-- Verificar privilegios
SHOW GRANTS FOR 'usuario_problema'@'host';

-- Verificar desde qué host se conecta
SELECT USER(), @@hostname;
```

#### Error: Plugin 'caching_sha2_password' cannot be loaded
```sql
-- Cambiar a plugin compatible
ALTER USER 'usuario'@'host' 
IDENTIFIED WITH mysql_native_password BY 'password';

-- O actualizar cliente MySQL
```

#### Error: SSL connection error
```bash
# Verificar configuración SSL
mysql -u root -p -e "SHOW VARIABLES LIKE '%ssl%';"

# Probar conexión SSL
mysql -u usuario -p --ssl-mode=REQUIRED

# Verificar certificados
openssl x509 -in /var/lib/mysql/server-cert.pem -text -noout
```

### Scripts de Diagnóstico

```sql
-- Diagnóstico completo de seguridad
DELIMITER //
CREATE PROCEDURE diagnóstico_seguridad()
BEGIN
    -- 1. Usuarios y privilegios
    SELECT 'USUARIOS Y PRIVILEGIOS' as categoria;
    SELECT User, Host, account_locked, password_expired, 
           password_last_changed, password_lifetime
    FROM mysql.user;
    
    -- 2. Conexiones actuales
    SELECT 'CONEXIONES ACTUALES' as categoria;
    SELECT User, Host, db, Command, Time, State 
    FROM information_schema.processlist;
    
    -- 3. Configuración SSL
    SELECT 'CONFIGURACIÓN SSL' as categoria;
    SHOW VARIABLES LIKE '%ssl%';
    
    -- 4. Variables de seguridad importantes
    SELECT 'VARIABLES DE SEGURIDAD' as categoria;
    SHOW VARIABLES WHERE Variable_name IN (
        'validate_password.policy',
        'require_secure_transport',
        'local_infile',
        'general_log',
        'log_error'
    );
    
    -- 5. Intentos de conexión fallidos recientes
    SELECT 'LOGS DE SEGURIDAD' as categoria;
    -- Esta parte requiere acceso a logs del sistema
    
END//
DELIMITER ;

-- Ejecutar diagnóstico
CALL diagnóstico_seguridad();
```

### Recuperación de Acceso

```bash
#!/bin/bash
# Script de recuperación de acceso de emergencia

# 1. Parar MySQL
sudo systemctl stop mysql

# 2. Iniciar en modo seguro
sudo mysqld_safe --skip-grant-tables --skip-networking &

# 3. Conectar sin password
mysql -u root

# 4. Restablecer password de root
# En MySQL:
# FLUSH PRIVILEGES;
# ALTER USER 'root'@'localhost' IDENTIFIED BY 'nuevo_password';
# FLUSH PRIVILEGES;

# 5. Salir y reiniciar MySQL normalmente
sudo systemctl restart mysql

echo "Acceso restablecido. Password de root cambiado."
```

---

## 📋 Checklist de Seguridad

### ✅ Configuración Inicial
- [ ] Cambiar password de root por defecto
- [ ] Eliminar usuarios anónimos
- [ ] Eliminar base de datos de prueba
- [ ] Deshabilitar acceso remoto como root
- [ ] Configurar firewall apropiado

### ✅ Gestión de Usuarios
- [ ] Crear usuarios específicos por aplicación
- [ ] Implementar principio de menor privilegio
- [ ] Configurar expiración de passwords
- [ ] Documentar propósito de cada usuario
- [ ] Revisar y limpiar usuarios inactivos

### ✅ Cifrado y SSL
- [ ] Configurar SSL/TLS para conexiones
- [ ] Implementar cifrado at-rest
- [ ] Configurar cifrado de binary logs
- [ ] Usar funciones de cifrado para datos sensibles

### ✅ Auditoría y Monitoreo
- [ ] Configurar logging apropiado
- [ ] Implementar auditoría de cambios críticos
- [ ] Monitorear intentos de acceso fallidos
- [ ] Revisar actividad sospechosa regularmente

### ✅ Mantenimiento
- [ ] Actualizar MySQL regularmente
- [ ] Revisar configuración de seguridad mensualmente
- [ ] Probar procedimientos de recuperación
- [ ] Capacitar al equipo en mejores prácticas

---

*Última actualización: 28/05/2025*
