-- =============================================================
-- Scripts Prueba Incremental 
-- Bases de Datos: adventure y AdventureWorksDW
-- =============================================================


-- Ejecutamos esto paso a paso

###Revisamos el producto antes de cambiarlo

-- Ejecutar en la base de datos ORIGEN (adventure)

SELECT 
    ProductID, 
    Name, 
    Color, 
    ListPrice, 
    ModifiedDate
FROM Production.Product
WHERE ProductID = 707;


###ASEGURARSE DE HABER CREADO AdventureWorksDW y EJECUTADO EL JOB ANTES DE HACER LOS SIGUIENTES PASOS 

###Simulamos un Cambio (En la base de datos origen)

Ahora, simula que el color y el precio de ese producto cambiaron en el sistema transaccional.


-- Ejecutar en la base de datos ORIGEN (adventure)

UPDATE Production.Product
SET 
    Color = 'Metallic Red', -- ¡Cambiamos el color!
    ListPrice = 1500.00,    -- Y el precio
    ModifiedDate = NOW()    -- Actualiza la fecha de modificación
WHERE ProductID = 707;

-- Confirmamos el cambio
SELECT Color, ListPrice FROM Production.Product WHERE ProductID = 707;



-- Insertamos una venta de ese producto para q se actualice en la FactVentas

-- Ejecutar en la base de datos ORIGEN (adventure)

INSERT INTO Sales.SalesOrderHeader (
    SalesOrderID,
    RevisionNumber,
    OrderDate,
    DueDate,
    ShipDate,
    Status,
    OnlineOrderFlag,        
    PurchaseOrderNumber,    
    AccountNumber,
    CustomerID,
    SalesPersonID,
    TerritoryID,
    BillToAddressID,        
    ShipToAddressID,        
    ShipMethodID,
    CreditCardID,
    CurrencyRateID,
    SubTotal,
    TaxAmt,
    Freight,
    TotalDue
) VALUES (
    99999,
    1,
    NOW() + INTERVAL '1 hour',
    NOW() + INTERVAL '10 days',
    NOW() + INTERVAL '5 days',
    5,     
    FALSE, 
    'PO123456',
    'AW29825',
    29825, -- ID de Cliente
    275,   -- ID de Vendedor
    1,     -- Territorio de Ventas
    249,   -- 
    249,   -- 
    1,     
    NULL,
    NULL,
    100.00,
    8.00,
    5.00,
    113.00
);


-- Ejecutar en la base de datos ORIGEN (adventure)

INSERT INTO Sales.SalesOrderDetail (
    SalesOrderID,
    SalesOrderDetailID,
    OrderQty,
    ProductID,
    UnitPrice,
    UnitPriceDiscount,
    SpecialOfferID          -- <--- CAMPO OBLIGATORIO AGREGADO
) VALUES (
    99999,                  -- Mismo ID de pedido
    1,     
    2,                      -- Cantidad
    707,                    -- Producto 707 modificado
    1500.00,                -- Precio nuevo
    0.00,
    1                       -- <--- USAMOS ID 1: "NO DISCOUNT"
);



###EJECUTAR EL JOB NUEVAMENTE DESPUES DE INSERTAR LA VENTA

###CAMBIAR CONEXION A AdventureWorks_DW

-- Ejecutar en la base de datos destino (AdventureWorks_DW)
-- Verificamos la creación de una nueva versión (Versión 2) en DimProducto con los nuevos atributos.

SELECT 
    sk_producto, 
    id_producto_original,
	nombre_producto,
    color, 
    version, 
    date_from, 
    date_to 
FROM DimProducto
WHERE id_producto_original = 707
ORDER BY version DESC;


-- Mas detallado ordenado por version
SELECT 
    f.sk_ventas,
    p.nombre_producto,
    p.color,           
    p.version,         
    f.precio_unitario, 
	p.date_from,
	p.date_to,
    f.cantidad_vendida
FROM FactVentas f
JOIN DimProducto p ON f.sk_producto = p.sk_producto
WHERE p.id_producto_original = 707
ORDER BY p.version DESC; -- Para ver la más nueva arriba

-- Mas detallado ordenado por fecha de venta

SELECT 
    -- DATOS DE LA VENTA (FACTURA)
    f.sk_ventas,
    t.fecha_completa AS "Fecha de Venta",
    
    -- DATOS DEL PRODUCTO (DIMENSIÓN)
    p.nombre_producto,
    p.color AS "Color del Producto",
    f.precio_unitario AS "Precio Cobrado", -- Precio congelado en la factura
    
    -- DATOS DE AUDITORÍA (SCD TIPO 2)
    p.version AS "Versión Usada",
    p.date_from AS "Vigencia Desde",
    p.date_to AS "Vigencia Hasta"

FROM FactVentas f
JOIN DimProducto p ON f.sk_producto = p.sk_producto
JOIN DimTiempo t ON f.sk_tiempo = t.sk_tiempo
WHERE p.id_producto_original = 707
ORDER BY t.fecha_completa DESC, p.version DESC;




/*
=============================================================================
 ZONA DE PELIGRO - SCRIPTS DE REINICIO Y LIMPIEZA
=============================================================================
*/

/*

-- OPCIÓN A: Limpiar datos pero mantener tablas (Reinicio de Carga)
TRUNCATE TABLE FactVentas RESTART IDENTITY CASCADE;
TRUNCATE TABLE DimProducto RESTART IDENTITY CASCADE;
TRUNCATE TABLE DimCliente RESTART IDENTITY CASCADE;
TRUNCATE TABLE DimEmpleado RESTART IDENTITY CASCADE;
TRUNCATE TABLE DimTienda RESTART IDENTITY CASCADE;
TRUNCATE TABLE DimTiempo RESTART IDENTITY CASCADE;


-- OPCIÓN B: Destruir todo el Data Warehouse (Borrón y Cuenta Nueva)
DROP TABLE IF EXISTS FactVentas;
DROP TABLE IF EXISTS DimProducto CASCADE;
DROP TABLE IF EXISTS DimCliente CASCADE;
DROP TABLE IF EXISTS DimEmpleado CASCADE;
DROP TABLE IF EXISTS DimTienda CASCADE;
DROP TABLE IF EXISTS DimTiempo CASCADE;

*/
