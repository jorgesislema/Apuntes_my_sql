# Ejercicios Personales MySQL

## 📚 Descripción
Esta sección contiene ejercicios personales organizados por fecha, diseñados para practicar conceptos específicos de MySQL y reforzar el aprendizaje continuo.

## 📁 Estructura de Archivos

### Ejercicios por Fecha
- **2025-05-28-joins-nivel-2.sql** - Ejercicios avanzados de JOINs múltiples
- **2025-06-01-subconsulta-nidificada.sql** - Práctica de subconsultas complejas y anidadas

### Documentación de Errores
- **errores-comunes.md** - Guía de errores frecuentes y sus soluciones

## 🎯 Metodología de Ejercicios

### Formato de Nomenclatura
```
YYYY-MM-DD-tema-descripcion.sql
```

### Estructura de Cada Ejercicio
1. **Comentario de cabecera** con objetivo y nivel de dificultad
2. **Setup de datos de prueba** (si es necesario)
3. **Ejercicios progresivos** de menor a mayor complejidad
4. **Soluciones comentadas** con explicaciones
5. **Ejercicios de reto** para práctica adicional

## 📊 Niveles de Dificultad

| Nivel | Descripción | Indicador |
|-------|-------------|-----------|
| **Básico** | Conceptos fundamentales | ⭐ |
| **Intermedio** | Combinación de conceptos | ⭐⭐ |
| **Avanzado** | Optimización y casos complejos | ⭐⭐⭐ |
| **Experto** | Casos reales empresariales | ⭐⭐⭐⭐ |

## 🗓️ Plan de Ejercicios 2025

### Enero - Fundamentos Avanzados
- [x] **Semana 4**: JOINs complejos con múltiples tablas
- [ ] **Pendiente**: Window functions con particiones

### Febrero - Subconsultas y CTEs  
- [x] **Semana 1**: Subconsultas anidadas y correlacionadas
- [ ] **Pendiente**: CTEs recursivos para jerarquías
- [ ] **Pendiente**: Optimización de subconsultas

### Marzo - Funciones y Procedimientos
- [ ] **Planificado**: Stored procedures con cursores
- [ ] **Planificado**: Triggers para auditoría
- [ ] **Planificado**: Funciones definidas por usuario

### Abril - Optimización
- [ ] **Planificado**: Análisis de planes de ejecución
- [ ] **Planificado**: Diseño de índices compuestos
- [ ] **Planificado**: Particionamiento de tablas

### Mayo - Administración
- [ ] **Planificado**: Backup y recovery scenarios
- [ ] **Planificado**: Configuración de replicación
- [ ] **Planificado**: Monitoreo y alertas

### Junio - Casos Reales
- [ ] **Planificado**: Sistema de inventario completo
- [ ] **Planificado**: Analytics en tiempo real
- [ ] **Planificado**: Migración de datos

## 📈 Seguimiento de Progreso

### Ejercicios Completados: 2/30
- ✅ JOINs nivel 2 (2025-05-28)
- ✅ Subconsultas anidadas (2025-06-01)

### Próximos Objetivos
1. **CTEs recursivos** - Semana del 15 de enero
2. **Window functions avanzadas** - Semana del 22 de enero
3. **Optimización de índices** - Semana del 29 de enero

## 🔧 Herramientas de Práctica

### Entorno de Desarrollo
- **MySQL Version**: 8.0+
- **Herramientas**: MySQL Workbench, CLI, phpMyAdmin
- **Sample Databases**: sakila, world, employees

### Configuración Recomendada
```sql
-- Habilitar profiling para análisis de performance
SET profiling = 1;

-- Configurar timeouts para práctica
SET SESSION max_execution_time = 30000;

-- Habilitar logging de consultas lentas
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 1;
```

## 📚 Recursos de Apoyo

### Documentación
- [MySQL Reference Manual](https://dev.mysql.com/doc/refman/8.0/en/)
- [MySQL Performance Blog](https://www.percona.com/blog/)
- [High Performance MySQL Book](https://www.oreilly.com/library/view/high-performance-mysql/9781449332471/)

### Datasets de Práctica
- **Sakila Database** - DVD rental store (sample database)
- **World Database** - Country and city information
- **Employees Database** - Large dataset for performance testing

## 💡 Tips para el Estudio

### Metodología Efectiva
1. **Leer el objetivo** antes de empezar
2. **Intentar resolver** sin ver la solución
3. **Comparar resultados** con la solución propuesta
4. **Analizar performance** usando EXPLAIN
5. **Experimentar variaciones** del ejercicio

### Registro de Aprendizaje
- Mantener un log de conceptos nuevos aprendidos
- Documentar dudas y resoluciones
- Crear resúmenes de patrones útiles
- Practicar regularmente (al menos 3 veces por semana)

## 🎖️ Sistema de Logros

### Badges Desbloqueables
- 🥉 **Principiante**: 5 ejercicios completados
- 🥈 **Intermedio**: 15 ejercicios completados  
- 🥇 **Avanzado**: 25 ejercicios completados
- 💎 **Experto**: 50 ejercicios + proyecto completo

### Especialidades
- 🔍 **Query Master**: 10 ejercicios de optimización
- 🏗️ **Architect**: 5 diseños de base de datos
- 🛡️ **Security Expert**: 5 ejercicios de seguridad
- 📊 **Analytics Pro**: 10 ejercicios de reportes

## 📞 Soporte y Comunidad

### Canales de Ayuda
- **Stack Overflow**: Tag [mysql]
- **Reddit**: r/MySQL
- **Discord**: MySQL Community Server
- **Local MySQL Meetups**

### Contribuciones
Si encuentras errores o tienes sugerencias de mejora:
1. Documenta el issue en `errores-comunes.md`
2. Propone ejercicios adicionales
3. Comparte optimizaciones alternativas
4. Actualiza documentación según sea necesario

---

**¡Happy coding! 🚀**

> "La práctica hace al maestro, pero la práctica perfecta hace al experto" - Vince Lombardi
