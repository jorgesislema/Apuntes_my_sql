# Preguntas Estilo Certificación MySQL

## Oracle MySQL Database Administrator (OCA/OCP)

### Arquitectura y Configuración

#### Pregunta 1 - Nivel Intermedio
**¿Cuál de las siguientes afirmaciones sobre el motor de almacenamiento InnoDB es INCORRECTA?**

A) InnoDB soporta transacciones ACID
B) InnoDB utiliza bloqueos a nivel de fila
C) InnoDB no soporta claves foráneas
D) InnoDB es el motor de almacenamiento por defecto en MySQL 5.5+

**Respuesta:** C) InnoDB no soporta claves foráneas
**Explicación:** InnoDB SÍ soporta claves foráneas y constraints referencial integrity, lo que es una de sus principales ventajas sobre MyISAM.

#### Pregunta 2 - Nivel Avanzado
**¿Cuál es el propósito principal del parámetro `innodb_buffer_pool_size`?**

A) Controlar el tamaño máximo de archivos de log
B) Definir la memoria cache para datos e índices de InnoDB
C) Establecer el número máximo de conexiones concurrentes
D) Configurar el timeout de conexiones inactivas

**Respuesta:** B) Definir la memoria cache para datos e índices de InnoDB
**Explicación:** Este parámetro controla el tamaño del buffer pool, que es la cache principal de InnoDB para datos e índices en memoria.

### Optimización y Performance

#### Pregunta 3 - Nivel Intermedio
**¿Cuál comando proporciona información detallada sobre la ejecución de una consulta?**

A) SHOW STATUS
B) EXPLAIN
C) DESCRIBE
D) ANALYZE

**Respuesta:** B) EXPLAIN
**Explicación:** EXPLAIN muestra el plan de ejecución de una consulta, incluyendo qué índices se usan y el orden de las operaciones.

#### Pregunta 4 - Nivel Avanzado
**En el resultado de EXPLAIN, ¿qué indica un valor alto en la columna 'rows'?**

A) Mejor performance de la consulta
B) Número exacto de filas que retornará la consulta
C) Estimación de filas que MySQL debe examinar
D) Número de índices utilizados

**Respuesta:** C) Estimación de filas que MySQL debe examinar
**Explicación:** La columna 'rows' muestra una estimación del número de filas que MySQL debe examinar para ejecutar la consulta, no las filas del resultado final.

### Replicación y Alta Disponibilidad

#### Pregunta 5 - Nivel Avanzado
**En una configuración Master-Slave, ¿cuál archivo contiene la posición actual del binary log en el slave?**

A) mysql-bin.index
B) master.info
C) relay-log.info
D) slave-relay-bin.index

**Respuesta:** C) relay-log.info
**Explicación:** El archivo relay-log.info mantiene información sobre la posición actual del relay log en el servidor slave.

#### Pregunta 6 - Nivel Experto
**¿Cuál es la diferencia principal entre replicación asíncrona y semi-síncrona?**

A) La semi-síncrona es más rápida
B) En semi-síncrona, el master espera confirmación de al menos un slave antes de confirmar la transacción
C) La asíncrona no permite lag de replicación
D) No hay diferencias significativas

**Respuesta:** B) En semi-síncrona, el master espera confirmación de al menos un slave antes de confirmar la transacción
**Explicación:** La replicación semi-síncrona proporciona mayor durabilidad al esperar confirmación del slave, mientras que la asíncrona confirma inmediatamente.

### Seguridad y Usuarios

#### Pregunta 7 - Nivel Intermedio
**¿Cuál comando se usa para cambiar la contraseña de un usuario en MySQL 8.0?**

A) SET PASSWORD FOR 'user'@'host' = 'newpassword'
B) ALTER USER 'user'@'host' IDENTIFIED BY 'newpassword'
C) UPDATE mysql.user SET password = PASSWORD('newpassword')
D) CHANGE PASSWORD FOR 'user'@'host' TO 'newpassword'

**Respuesta:** B) ALTER USER 'user'@'host' IDENTIFIED BY 'newpassword'
**Explicación:** ALTER USER es la forma recomendada en MySQL 8.0 para cambiar contraseñas de usuarios.

#### Pregunta 8 - Nivel Avanzado
**¿Cuál plugin de autenticación es el predeterminado en MySQL 8.0?**

A) mysql_native_password
B) sha256_password
C) caching_sha2_password
D) authentication_windows

**Respuesta:** C) caching_sha2_password
**Explicación:** MySQL 8.0 introdujo caching_sha2_password como el plugin de autenticación predeterminado para mejorar la seguridad.

### Backup y Recovery

#### Pregunta 9 - Nivel Avanzado
**¿Cuál es la principal ventaja de usar mysqldump con la opción --single-transaction?**

A) Reduce el tamaño del archivo de backup
B) Proporciona un backup consistente sin bloquear tablas
C) Acelera significativamente el proceso de backup
D) Permite backup incremental

**Respuesta:** B) Proporciona un backup consistente sin bloquear tablas
**Explicación:** --single-transaction inicia una transacción de lectura consistente, proporcionando un snapshot consistente sin bloquear las tablas.

#### Pregunta 10 - Nivel Experto
**En un escenario de Point-in-Time Recovery, ¿qué archivos son esenciales?**

A) Solo el último backup completo
B) El backup completo + binary logs desde el backup
C) Solo los binary logs
D) El backup completo + error logs

**Respuesta:** B) El backup completo + binary logs desde el backup
**Explicación:** Para PITR necesitas el último backup completo y todos los binary logs generados desde ese backup hasta el punto de tiempo deseado.

### JSON y Nuevas Características

#### Pregunta 11 - Nivel Intermedio
**¿Cuál función se usa para extraer un valor específico de un campo JSON?**

A) JSON_EXTRACT()
B) JSON_GET()
C) JSON_VALUE()
D) JSON_FIND()

**Respuesta:** A) JSON_EXTRACT()
**Explicación:** JSON_EXTRACT() o el operador -> se usan para extraer valores de documentos JSON en MySQL.

#### Pregunta 12 - Nivel Avanzado
**¿Cuál índice es más eficiente para buscar en campos JSON?**

A) Índice B-tree tradicional
B) Índice funcional (functional index)
C) Índice FULLTEXT
D) Índice SPATIAL

**Respuesta:** B) Índice funcional (functional index)
**Explicación:** Los índices funcionales permiten indexar expresiones como JSON_EXTRACT(), mejorando las consultas en campos JSON.

## Preguntas de Repaso - Nivel Practicante

### Consultas Complejas

#### Pregunta 13
**¿Cuál es la diferencia entre UNION y UNION ALL?**

A) No hay diferencia
B) UNION elimina duplicados, UNION ALL no
C) UNION ALL es más lento
D) UNION ALL solo funciona con dos tablas

**Respuesta:** B) UNION elimina duplicados, UNION ALL no

#### Pregunta 14
**¿En qué orden se procesan las cláusulas en una consulta SELECT?**

A) SELECT, FROM, WHERE, GROUP BY, HAVING, ORDER BY
B) FROM, WHERE, GROUP BY, HAVING, SELECT, ORDER BY
C) WHERE, FROM, SELECT, GROUP BY, HAVING, ORDER BY
D) FROM, WHERE, SELECT, GROUP BY, HAVING, ORDER BY

**Respuesta:** B) FROM, WHERE, GROUP BY, HAVING, SELECT, ORDER BY

### Window Functions

#### Pregunta 15
**¿Cuál es la diferencia principal entre ROW_NUMBER() y RANK()?**

A) No hay diferencia
B) ROW_NUMBER() asigna números únicos consecutivos, RANK() puede tener valores duplicados
C) RANK() es más rápido
D) ROW_NUMBER() solo funciona con ORDER BY

**Respuesta:** B) ROW_NUMBER() asigna números únicos consecutivos, RANK() puede tener valores duplicados

## Scoring y Niveles

### Evaluación:
- **15-12 correctas**: Nivel Experto - Listo para certificación avanzada
- **11-9 correctas**: Nivel Avanzado - Necesita revisar algunos conceptos
- **8-6 correctas**: Nivel Intermedio - Requiere más estudio
- **5 o menos**: Nivel Básico - Necesita reforzar fundamentos

### Áreas de Mejora por Pregunta:
1-2: Arquitectura InnoDB
3-4: Optimización y EXPLAIN
5-6: Replicación
7-8: Seguridad
9-10: Backup/Recovery
11-12: JSON y nuevas características
13-15: Consultas avanzadas

### Recursos Recomendados:
- **Oracle MySQL Documentation**: https://dev.mysql.com/doc/
- **MySQL Certification Study Guide**: Official Oracle certification materials
- **Práctica**: Configurar replicación, optimizar consultas, administrar usuarios
- **Labs**: Realizar backup/restore en entornos de práctica
