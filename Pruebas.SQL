-- VENTAS Y COMPRAS POR SUCURSAL EN BD TRANSACCIONAL
SELECT 
    Sucursal_NroSucursal,
    YEAR(Compra_Fecha) AS anio,
    MONTH(Compra_Fecha) AS Mes,
    COUNT(*) AS Cantidad_Compras,
    SUM(Compra_Total) AS Total_Compras
FROM BDGRUPO.Compra
GROUP BY Sucursal_NroSucursal, YEAR(Compra_Fecha), MONTH(Compra_Fecha)
ORDER BY Sucursal_NroSucursal, anio, Mes;

SELECT 
    Factura_Sucursal AS Sucursal_NroSucursal,
    YEAR(Factura_Fecha) AS anio,
    MONTH(Factura_Fecha) AS Mes,
    COUNT(*) AS Cantidad_Ventas,
    SUM(Factura_Total) AS Total_Ventas
FROM BDGRUPO.Factura
GROUP BY Factura_Sucursal, YEAR(Factura_Fecha), MONTH(Factura_Fecha)
ORDER BY Factura_Sucursal, anio, Mes;

-- VENTAS Y COMPRAS POR SUCURSAL EN BD BI

SELECT 
    b.Sucursal_ID,
    SUM(b.Total) AS Total_Compras,
    COUNT(DISTINCT b.Compra_Numero) AS Cantidad_Compras,
    b.Tiempo_ID,
    d.Mes,
    d.anio
FROM BDGRUPOBI.HechoCompras b
JOIN BDGRUPOBI.DimTiempo d on b.tiempo_Id = d.Tiempo_ID
GROUP BY b.Sucursal_ID, b.Tiempo_ID, d.Mes, d.anio
ORDER BY d.anio, d.Mes

SELECT 
    v.Sucursal_ID,
    SUM(v.Total) AS Total_Ventas,
    COUNT(DISTINCT v.Factura_Numero) AS Cantidad_Ventas,
    v.Tiempo_ID,
    d.Mes,
    d.Anio
FROM BDGRUPOBI.HechoVentas v
JOIN BDGRUPOBI.DimTiempo d ON v.Tiempo_ID = d.Tiempo_ID
GROUP BY v.Sucursal_ID, v.Tiempo_ID, d.Mes, d.Anio
ORDER BY d.Anio, d.Mes

