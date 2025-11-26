# 📦 Data Warehouse AdventureWorks ETL

Proyecto de Almacenes de datos, que implementa un Data Warehouse completo, transformando la base de datos transaccional **AdventureWorks** en un modelo dimensional optimizado para la toma de decisiones estratégicas.

## 🛠️ Tecnologías

* **ETL:** Pentaho Data Integration (PDI) 9.4
* **Base de Datos:** PostgreSQL 15+
* **Modelado:** Esquema Estrella (Star Schema)

## 🏗️ Arquitectura del Data Warehouse

El modelo consta de una tabla de hechos central (`FactVentas`) rodeada por 5 dimensiones estratégicas:

1. **DimTiempo:** Generación dinámica de fechas.
2. **DimProducto:** Manejo de historial de cambios (SCD Tipo 2) y control de versiones.
3. **DimCliente:** Normalización geográfica y auditoría de ubicaciones.
4. **DimEmpleado:** Seguimiento de fuerza de ventas.
5. **DimTienda:** Análisis por territorio y región.

### Características del Proceso ETL

* **Orquestación:** Job maestro (`.kjb`) que ejecuta la carga en secuencia lógica (Dimensiones -> Hechos).
* **Carga Incremental:** Detección automática de cambios (Insert/Update) y manejo de versiones históricas para productos.
* **Integridad:** Validación de llaves foráneas y limpieza de datos nulos.

## 🚀 Guía de Despliegue y Pruebas (Paso a Paso)

Para replicar este proyecto en un entorno local, siga este orden estricto de ejecución.

### 1. Preparación de Bases de Datos

El proyecto requiere dos bases de datos en PostgreSQL:

* **Origen (OLTP):**
  * Cree una base de datos llamada `adventure`.
  * Restaure el respaldo que se encuentra en: `data/adventure.sql`.

* **Destino (Data Warehouse):**
  * Cree una base de datos vacía llamada `AdventureWorksDW`.
  * Ejecute el script de estructura DDL ubicado en: `sql/01_Estructura_DW.sql`.
  * *Nota:* Este script crea las tablas y las filas "Cero" (Unknown Members) necesarias para la integridad.

### 2. Ejecución del Proceso ETL

La carga de datos está automatizada mediante un Job maestro de Pentaho.

1. Abra **Spoon (PDI)**.
2. Abra el archivo principal: `etl/AdventureWorksDW.kjb`.
3. **Importante:** Verifique y edite las conexiones "Origen_AdventureWorks" y "Destino_DW" si sus credenciales de PostgreSQL son diferentes a las predeterminadas.
4. Ejecute el Job (Botón Play).
   * *Resultado esperado:* Todas las transformaciones deben finalizar en verde.

### 3. Verificación de Resultados (Reportes)

Una vez cargado el DW, puede validar los indicadores de negocio.

* Abra pgAdmin en la base `AdventureWorksDW`.
* Ejecute el script: `sql/02_Consultas_Reporte.sql`.
* Obtendrá los 5 reportes clave (Ventas mensuales, Top Clientes, Márgenes, etc.).

### 4. Prueba de Carga Incremental (SCD Tipo 2)

Este proyecto soporta la detección de cambios históricos. Para probarlo:

1. Abra el script: `sql/03_Script_Prueba_Incremental.sql`.
2. Ejecute la **SECCIÓN 1 y 2** en la base de datos `adventure` (Origen).
   * *Esto modificará un producto y creará una venta futura.*
3. Vuelva a ejecutar el Job ETL en Pentaho.
4. Ejecute la **SECCIÓN 3** del script en `AdventureWorksDW` (Destino).
   * *Validación:* Verá que el sistema creó una nueva versión del producto y vinculó la nueva venta correctamente, manteniendo la historia de las ventas pasadas.

## 📂 Estructura del Repositorio

* `/etl`: Flujos de trabajo de Pentaho (Transformaciones .ktr y Job .kjb).
* `/sql`: Scripts DDL para crear las tablas (`01_Estructura_DW.sql`) y reportes (`02_Consultas_Reporte.sql`).
* `/docs`: Informe final en PDF y diagramas del modelo.
* `/data`: Respaldo de la base de datos origen (`adventure.sql`).

## 📊 Resultados de Negocio (Consultas OLAP)

El sistema incluye scripts SQL optimizados para responder las siguientes preguntas de negocio requeridas:

1. **Ventas mensuales por categoría de producto:** Análisis estacional de ingresos.
2. **Ventas anuales por territorio:** Rendimiento geográfico comparativo.
3. **Top 10 Clientes con mayor facturación:** Identificación de clientes VIP (Pareto).
4. **Comparación de ventas por empleado:** Ranking de productividad del equipo comercial.
5. **Margen estimado por producto:** Cálculo de rentabilidad real (Precio Venta - Costo Estándar).

---

*Proyecto académico de Almacenes de datos *
GRUPO E
- Roberto Alvarez 
- Jesus Mendoza

