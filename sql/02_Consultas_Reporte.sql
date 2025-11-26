-- =============================================================
-- INFORME FINAL DE ALMACENES DE DATOS
-- Base de Datos: AdventureWorksDW
-- =============================================================

-- CONSULTA 1: Ventas mensuales por categoría
-- Análisis: Tendencia temporal de ventas por familias de productos.
SELECT 
    t.anio AS "Año",
    t.mes_nombre AS "Mes",
    p.categoria AS "Categoría",
    SUM(f.subtotal_venta) AS "Ventas Totales ($)"
FROM FactVentas f
JOIN DimTiempo t ON f.sk_tiempo = t.sk_tiempo
JOIN DimProducto p ON f.sk_producto = p.sk_producto
GROUP BY t.anio, t.mes, t.mes_nombre, p.categoria
ORDER BY t.anio DESC, t.mes DESC, "Ventas Totales ($)" DESC;


-- CONSULTA 2: Ventas anuales por territorio
-- Análisis: Rendimiento geográfico.
SELECT 
    t.anio AS "Año",
    ti.pais AS "País",
    ti.nombre_tienda_territorio AS "Territorio",
    SUM(f.subtotal_venta) AS "Ventas Anuales ($)"
FROM FactVentas f
JOIN DimTiempo t ON f.sk_tiempo = t.sk_tiempo
JOIN DimTienda ti ON f.sk_tienda = ti.sk_tienda
GROUP BY t.anio, ti.pais, ti.nombre_tienda_territorio
ORDER BY t.anio DESC, "Ventas Anuales ($)" DESC;


-- CONSULTA 3: Top 10 Clientes VIP
-- Análisis: Identificación de clientes clave (Pareto).
SELECT 
    c.nombre_completo AS "Cliente",
    c.tipo_cliente AS "Tipo",
    MAX(CASE 
        WHEN c.pais IS NULL OR c.pais IN ('N/D', 'N/A') THEN ti.pais 
        ELSE c.pais 
    END) AS "País",
    
    COUNT(f.sk_ventas) as "Nro. Transacciones",
    SUM(f.subtotal_venta) AS "Facturación Total ($)"
FROM FactVentas f
JOIN DimCliente c ON f.sk_cliente = c.sk_cliente
JOIN DimTienda ti ON f.sk_tienda = ti.sk_tienda
GROUP BY c.nombre_completo, c.tipo_cliente
ORDER BY "Facturación Total ($)" DESC
LIMIT 10;

-- CONSULTA 4: Comparacion de ventas por empleado (Ranking empleados)
-- Análisis: Productividad del equipo comercial.
SELECT 
    e.nombre_completo AS "Vendedor",
    e.puesto AS "Cargo",
    e.departamento AS "Departamento",
    SUM(f.subtotal_venta) AS "Ventas Generadas ($)"
FROM FactVentas f
JOIN DimEmpleado e ON f.sk_empleado = e.sk_empleado
WHERE e.nombre_completo <> 'Cliente Desconocido' -- Filtramos ventas online
GROUP BY e.nombre_completo, e.puesto, e.departamento
ORDER BY "Ventas Generadas ($)" DESC;


-- CONSULTA 5: Margen de Ganancia estimado por Producto
-- Análisis: Rentabilidad real por SKU y Modelo.
SELECT 
    p.modelo AS "Modelo (Genérico)",           -- Agregado para claridad
    p.nombre_producto AS "Producto (SKU)",     -- El nombre específico
    p.subcategoria AS "Subcategoría",
    SUM(f.cantidad_vendida) as "Unidades",
    -- Cálculo del Margen: (Precio Venta Real - Costo Estándar) * Cantidad
    SUM((f.precio_unitario - f.costo_unitario) * f.cantidad_vendida) AS "Margen Total ($)"
FROM FactVentas f
JOIN DimProducto p ON f.sk_producto = p.sk_producto
GROUP BY p.modelo, p.nombre_producto, p.subcategoria
ORDER BY "Margen Total ($)" DESC
LIMIT 15;