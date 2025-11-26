-- =============================================================
-- SCRIPT DE CREACIÓN DEL DATA WAREHOUSE (Esquema Estrella)
-- Ejecutar en una base de datos nueva: AdventureWorksDW
-- =============================================================

-- 1. DIMENSIÓN TIEMPO
CREATE TABLE DimTiempo (
    sk_tiempo INT PRIMARY KEY,
    fecha_completa DATE,
    dia INT,
    mes INT,
    mes_nombre VARCHAR(20),
    anio INT,
    trimestre INT,
    dia_semana VARCHAR(20)
);

-- 2. DIMENSIÓN PRODUCTO
CREATE TABLE DimProducto (
    sk_producto SERIAL PRIMARY KEY,
    id_producto_original INT,
    nombre_producto VARCHAR(255),
    subcategoria VARCHAR(100),
    categoria VARCHAR(100),
    color VARCHAR(50),
    tamanio VARCHAR(50),
    modelo VARCHAR(100),
    tipo_producto VARCHAR(150),
    version INT DEFAULT 1,
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_from TIMESTAMP,
    date_to TIMESTAMP
);
-- Fila Cero (Protección contra errores de Pentaho)
INSERT INTO DimProducto (sk_producto, id_producto_original, nombre_producto, subcategoria, categoria, color, tamanio, modelo, tipo_producto, version, date_from, date_to, fecha_carga) 
VALUES (0, 0, 'Desconocido', 'N/D', 'N/D', 'N/D', 'N/D', 'N/D', 'N/D', 0, '1900-01-01 00:00:00', '2199-12-31 00:00:00', NOW());
ALTER SEQUENCE dimproducto_sk_producto_seq RESTART WITH 1;

-- 3. DIMENSIÓN CLIENTE
CREATE TABLE DimCliente (
    sk_cliente SERIAL PRIMARY KEY,
    id_cliente_original INT,
    nombre_completo VARCHAR(255),
    genero VARCHAR(20),
    tipo_cliente VARCHAR(50),
    ciudad VARCHAR(100),
    estado_provincia VARCHAR(100),
    pais VARCHAR(100),
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    version INT DEFAULT 1,
    date_from TIMESTAMP,
    date_to TIMESTAMP
);
-- Fila Cero
INSERT INTO DimCliente (sk_cliente, id_cliente_original, nombre_completo, genero, tipo_cliente, ciudad, estado_provincia, pais, version, date_from, date_to, fecha_carga) 
VALUES (0, 0, 'Desconocido', 'N/D', 'N/D', 'N/D', 'N/D', 'N/D', 0, '1900-01-01 00:00:00', '2199-12-31 00:00:00', NOW());
ALTER SEQUENCE dimcliente_sk_cliente_seq RESTART WITH 1;

-- 4. DIMENSIÓN EMPLEADO
CREATE TABLE DimEmpleado (
    sk_empleado SERIAL PRIMARY KEY,
    id_empleado_original INT,
    nombre_completo VARCHAR(255),
    puesto VARCHAR(100),
    departamento VARCHAR(100),
    fecha_ingreso DATE,
    estado VARCHAR(50),
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    version INT DEFAULT 1,
    date_from TIMESTAMP,
    date_to TIMESTAMP
);
-- Fila Cero
INSERT INTO DimEmpleado (sk_empleado, id_empleado_original, nombre_completo, puesto, departamento, fecha_ingreso, estado, version, date_from, date_to, fecha_carga) 
VALUES (0, 0, 'Desconocido', 'N/D', 'N/D', '1900-01-01', 'N/D', 0, '1900-01-01 00:00:00', '2199-12-31 00:00:00', NOW());
ALTER SEQUENCE dimempleado_sk_empleado_seq RESTART WITH 1;

-- 5. DIMENSIÓN TIENDA
CREATE TABLE DimTienda (
    sk_tienda SERIAL PRIMARY KEY,
    id_territorio_original INT,
    nombre_tienda_territorio VARCHAR(100),
    region_grupo VARCHAR(100),
    pais VARCHAR(100),
    grupo VARCHAR(100),
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    version INT DEFAULT 1,
    date_from TIMESTAMP,
    date_to TIMESTAMP
);
-- Fila Cero
INSERT INTO DimTienda (sk_tienda, id_territorio_original, nombre_tienda_territorio, region_grupo, pais, grupo, version, date_from, date_to, fecha_carga) 
VALUES (0, 0, 'Desconocido', 'N/D', 'N/D', 'N/D', 0, '1900-01-01 00:00:00', '2199-12-31 00:00:00', NOW());
ALTER SEQUENCE dimtienda_sk_tienda_seq RESTART WITH 1;

-- 6. TABLA DE HECHOS
CREATE TABLE FactVentas (
    sk_ventas SERIAL PRIMARY KEY,
    sk_producto INT REFERENCES DimProducto(sk_producto),
    sk_cliente INT REFERENCES DimCliente(sk_cliente),
    sk_empleado INT REFERENCES DimEmpleado(sk_empleado),
    sk_tienda INT REFERENCES DimTienda(sk_tienda),
    sk_tiempo INT REFERENCES DimTiempo(sk_tiempo),
    cantidad_vendida INT,
    precio_unitario NUMERIC(18,4),
    descuento_unitario NUMERIC(18,4),
    subtotal_venta NUMERIC(18,4),
    total_con_impuesto NUMERIC(18,4),
    costo_unitario NUMERIC(18,4)
);