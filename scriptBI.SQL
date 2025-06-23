USE GD1C2025;
GO

-- //////////////////////////////////////////////////////////////
-- ELIMINACION DE TABLAS Y PROCEDIMIENTOS ANTERIORES
-- //////////////////////////////////////////////////////////////

DROP PROCEDURE IF EXISTS BDGRUPOBI.Migrar_Datos;

-- Primero eliminar tablas de hechos (por FK)
IF OBJECT_ID('BDGRUPOBI.HechoVentas', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.HechoVentas;
IF OBJECT_ID('BDGRUPOBI.HechoCompras', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.HechoCompras;
IF OBJECT_ID('BDGRUPOBI.HechoEnvios', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.HechoEnvios;
IF OBJECT_ID('BDGRUPOBI.HechoPedidos', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.HechoPedidos;


-- Luego eliminar dimensiones
IF OBJECT_ID('BDGRUPOBI.DimTiempo', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.DimTiempo;
IF OBJECT_ID('BDGRUPOBI.DimSucursal', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.DimSucursal;
IF OBJECT_ID('BDGRUPOBI.DimUbicacion', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.DimUbicacion;
IF OBJECT_ID('BDGRUPOBI.DimMaterial', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.DimMaterial;
IF OBJECT_ID('BDGRUPOBI.DimSillon', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.DimSillon;
IF OBJECT_ID('BDGRUPOBI.DimCliente', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.DimCliente;
IF OBJECT_ID('BDGRUPOBI.DimTurno', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.DimTurno;
IF OBJECT_ID('BDGRUPOBI.DimEstadoPedido', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.DimEstadoPedido;

IF OBJECT_ID('BDGRUPOBI.vista_ganancias', 'V') IS NOT NULL DROP VIEW BDGRUPOBI.vista_ganancias;
IF OBJECT_ID('BDGRUPOBI.vista_conversion_pedidos', 'V') IS NOT NULL DROP VIEW BDGRUPOBI.vista_conversion_pedidos;
IF OBJECT_ID('BDGRUPOBI.vista_volumen_pedidos', 'V') IS NOT NULL DROP VIEW BDGRUPOBI.vista_volumen_pedidos;
IF OBJECT_ID('BDGRUPOBI.vista_tiempo_promedio_fabricacion', 'V') IS NOT NULL DROP VIEW BDGRUPOBI.vista_tiempo_promedio_fabricacion;
IF OBJECT_ID('BDGRUPOBI.vista_promedio_compras', 'V') IS NOT NULL DROP VIEW BDGRUPOBI.vista_promedio_compras;
IF OBJECT_ID('BDGRUPOBI.vista_compras_material', 'V') IS NOT NULL DROP VIEW BDGRUPOBI.vista_compras_material;
IF OBJECT_ID('BDGRUPOBI.vista_cumplimiento_envios', 'V') IS NOT NULL DROP VIEW BDGRUPOBI.vista_cumplimiento_envios;
IF OBJECT_ID('BDGRUPOBI.vista_localidades_mayor_costo', 'V') IS NOT NULL DROP VIEW BDGRUPOBI.vista_localidades_mayor_costo;
IF OBJECT_ID('BDGRUPOBI.vista_rendimiento_modelos', 'V') IS NOT NULL DROP VIEW BDGRUPOBI.vista_rendimiento_modelos;
IF OBJECT_ID('BDGRUPOBI.vista_factura_promedio_mensual', 'V') IS NOT NULL DROP VIEW BDGRUPOBI.vista_factura_promedio_mensual;
IF OBJECT_ID('BDGRUPOBI.vista_localidades_mayor_costo', 'V') IS NOT NULL DROP VIEW BDGRUPOBI.vista_localidades_mayor_Costo;
IF OBJECT_ID('BDGRUPOBI.vista_conversion_pedidos', 'V') IS NOT NULL DROP VIEW BDGRUPOBI.vista_conversion_pedidos;


GO

-- Primero eliminamos el esquema (si está vacío)
IF EXISTS (SELECT * FROM sys.schemas WHERE name = 'BDGRUPOBI')
    DROP SCHEMA BDGRUPOBI;
GO

-- //////////////////////////////////////////////////////////////
-- CREACION DE TABLAS
-- //////////////////////////////////////////////////////////////
CREATE SCHEMA BDGRUPOBI;
GO

-- DIM_TIEMPO
CREATE TABLE BDGRUPOBI.DimTiempo (
    Tiempo_ID INT PRIMARY KEY IDENTITY(1,1),
    Anio INT,
    Cuatrimestre INT,
    Mes INT,
	Fecha DATE
);
GO

-- DIM_UBICACION
CREATE TABLE BDGRUPOBI.DimUbicacion (
    Localidad_ID BIGINT PRIMARY KEY,
    Provincia NVARCHAR(100),
    Localidad NVARCHAR(100)
);
GO

-- DIM_SUCURSAL
CREATE TABLE BDGRUPOBI.DimSucursal (
    Sucursal_ID BIGINT PRIMARY KEY,
    Localidad_ID BIGINT
);
GO

-- DIM_MATERIAL
CREATE TABLE BDGRUPOBI.DimMaterial (
    Material_ID BIGINT PRIMARY KEY,
    Tipo NVARCHAR(100)
);
GO

-- DIM_SILLON
CREATE TABLE BDGRUPOBI.DimSillon (
    Sillon_Codigo BIGINT PRIMARY KEY,
    Modelo NVARCHAR(255)
);
GO

-- DIM_CLIENTE
CREATE TABLE BDGRUPOBI.DimCliente (
    Cliente_ID BIGINT PRIMARY KEY,
    RangoEtario NVARCHAR(20)
);
GO

-- DIM_TURNO
CREATE TABLE BDGRUPOBI.DimTurno (
    Turno_ID INT PRIMARY KEY,
    Hora_Desde TIME,
    Hora_Hasta TIME,
    Turno NVARCHAR(50)
);
GO

-- DIM_ESTADO_PEDIDO
CREATE TABLE BDGRUPOBI.DimEstadoPedido (
    Estado_ID INT PRIMARY KEY,
    Estado NVARCHAR(50)
);
GO

-- HECHO_VENTAS
CREATE TABLE BDGRUPOBI.HechoVentas (
    Tiempo_ID INT,
    TiempoFabricacion INT,
    Cliente_ID BIGINT,
    Sucursal_ID BIGINT,
    Sillon_Codigo BIGINT,
    Total DECIMAL(12,2),
    FOREIGN KEY (Tiempo_ID) REFERENCES BDGRUPOBI.DimTiempo(Tiempo_ID),
    FOREIGN KEY (Cliente_ID) REFERENCES BDGRUPOBI.DimCliente(Cliente_ID),
    FOREIGN KEY (Sucursal_ID) REFERENCES BDGRUPOBI.DimSucursal(Sucursal_ID),
    FOREIGN KEY (Sillon_Codigo) REFERENCES BDGRUPOBI.DimSillon(Sillon_Codigo),
    CONSTRAINT PK_HechoVentas PRIMARY KEY (Tiempo_ID, Cliente_ID, Sucursal_ID, Sillon_Codigo)
);
GO

-- HECHO_COMPRAS
CREATE TABLE BDGRUPOBI.HechoCompras (
	Compra_ID BIGINT NOT NULL,
    Compra_Numero DECIMAL(18,0) NOT NULL,
    Tiempo_ID INT,
    Sucursal_ID BIGINT NOT NULL,
    Material_ID BIGINT NOT NULL,
    Total DECIMAL(12,2),
    FOREIGN KEY (Tiempo_ID) REFERENCES BDGRUPOBI.DimTiempo(Tiempo_ID),
    FOREIGN KEY (Sucursal_ID) REFERENCES BDGRUPOBI.DimSucursal(Sucursal_ID),
    FOREIGN KEY (Material_ID) REFERENCES BDGRUPOBI.DimMaterial(Material_ID),
    CONSTRAINT PK_HechoCompras PRIMARY KEY (Compra_ID, Compra_Numero, Material_ID, Sucursal_ID)
);
GO


-- HECHO_PEDIDOS
CREATE TABLE BDGRUPOBI.HechoPedidos (
    Pedido_Numero DECIMAL(18,0) PRIMARY KEY,
    Fecha_ID INT,
    Turno_ID INT,
    Cliente_ID BIGINT,
    Sucursal_ID BIGINT,
    Estado NVARCHAR(50),
    FOREIGN KEY (Fecha_ID) REFERENCES BDGRUPOBI.DimTiempo(Tiempo_ID),
    FOREIGN KEY (Turno_ID) REFERENCES BDGRUPOBI.DimTurno(Turno_ID),
    FOREIGN KEY (Cliente_ID) REFERENCES BDGRUPOBI.DimCliente(Cliente_ID),
    FOREIGN KEY (Sucursal_ID) REFERENCES BDGRUPOBI.DimSucursal(Sucursal_ID)
);
GO

-- HECHO_ENVIOS
CREATE TABLE BDGRUPOBI.HechoEnvios (
    Envio_Numero DECIMAL(18,0) PRIMARY KEY,
    Tiempo_ID INT,
    Localidad_Cliente BIGINT,
    ImporteEnvio DECIMAL(10,2),
    CumplidoEnFecha BIT,
    
    FOREIGN KEY (Localidad_Cliente) REFERENCES BDGRUPOBI.DimUbicacion(Localidad_ID)
);
GO

-- //////////////////////////////////////////////////////////////
-- CARGA DE DATOS DIMENSIONES
-- //////////////////////////////////////////////////////////////

-- DimCliente
INSERT INTO BDGRUPOBI.DimCliente (Cliente_ID, RangoEtario)
SELECT Cliente_Dni,
    CASE 
        WHEN DATEDIFF(YEAR, Cliente_FechaNacimiento, GETDATE()) < 25 THEN '<25'
        WHEN DATEDIFF(YEAR, Cliente_FechaNacimiento, GETDATE()) BETWEEN 25 AND 35 THEN '25-35'
        WHEN DATEDIFF(YEAR, Cliente_FechaNacimiento, GETDATE()) BETWEEN 36 AND 50 THEN '35-50'
        ELSE '>50' END
FROM BDGRUPO.Cliente;

-- DimTiempo
INSERT INTO BDGRUPOBI.DimTiempo (Anio, Mes, Cuatrimestre, Fecha)
SELECT 
    anios.Anio,
    meses.Mes,
    CASE 
        WHEN meses.Mes BETWEEN 1 AND 3 THEN 1
        WHEN meses.Mes BETWEEN 4 AND 6 THEN 2
        WHEN meses.Mes BETWEEN 7 AND 9 THEN 3
        ELSE 4
    END AS Cuatrimestre,
    DATEFROMPARTS(anios.Anio, meses.Mes, 1) AS Fecha
FROM 
    (VALUES (2010), (2011), (2012), (2013), (2014), (2015), (2016), (2017), (2018), (2019),
            (2020), (2021), (2022), (2023), (2024), (2025), (2026), (2027), (2028), (2029), (2030)) AS anios(Anio)
CROSS JOIN 
    (VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12)) AS meses(Mes)
ORDER BY anios.Anio, meses.Mes;


-- DimUbicacion
INSERT INTO BDGRUPOBI.DimUbicacion (Localidad_ID, Provincia, Localidad)
SELECT l.Localidad_ID, l.localidad_Provincia, l.Localidad_Nombre
FROM BDGRUPO.Localidad l;

-- DimSucursal
INSERT INTO BDGRUPOBI.DimSucursal (Sucursal_ID, Localidad_ID)
SELECT 
    s.Sucursal_NroSucursal, 
    l.Localidad_ID
FROM BDGRUPO.Sucursal s
JOIN BDGRUPO.Localidad l ON s.Sucursal_Localidad = l.Localidad_ID

-- DimTurno
INSERT INTO BDGRUPOBI.DimTurno(Turno_ID, Hora_Desde, Hora_Hasta, Turno) VALUES
(1, '8:00:00', '13:59:59', '8:00 - 14:00'),
(2, '14:00:00', '19:59:59', '14:00 - 20:00');

--DimEstadoPedido
INSERT INTO BDGRUPOBI.DimEstadoPedido(Estado_ID, Estado) VALUES
(1, 'pendiente'),
(2, 'entregado'),
(3, 'cancelado');

--DimSillon
INSERT INTO BDGRUPOBI.DimSillon(Sillon_Codigo, Modelo)
SELECT Sillon_Codigo, Sillon_Modelo_Codigo
FROM BDGRUPO.Sillon;

--DimMateriales
INSERT INTO BDGRUPOBI.DimMaterial(Material_ID, Tipo)
SELECT Material_ID, Material_Tipo
FROM BDGRUPO.Material;

-- //////////////////////////////////////////////////////////////
-- CARGA DE DATOS HECHOS
-- //////////////////////////////////////////////////////////////

-- HechosVentas
-- HechosVentas
INSERT INTO BDGRUPOBI.HechoVentas (Tiempo_ID, TiempoFabricacion, Cliente_ID, Sucursal_ID, Sillon_Codigo, Total)
SELECT
    t.Tiempo_ID,
    DATEDIFF(HOUR, p.Pedido_Fecha, f.Factura_Fecha) AS TiempoFabricacion,
    p.Pedido_Cliente,
    f.Factura_Sucursal,
    dp.Sillon_Codigo,
    f.Factura_Total
FROM BDGRUPO.Factura f
JOIN BDGRUPO.FacturaDetalle fd ON f.Factura_Numero = fd.Factura_Numero
JOIN BDGRUPO.DetallePedido dp ON fd.Detalle_Factura_Pedido_ID = dp.Detalle_Pedido_ID
JOIN BDGRUPO.Pedido p ON dp.Pedido_Numero = p.Pedido_Numero
JOIN BDGRUPOBI.DimTiempo t ON YEAR(f.Factura_Fecha) = t.Anio AND MONTH(f.Factura_Fecha) = t.Mes
GO

-- HechosCompras
INSERT INTO BDGRUPOBI.HechoCompras (Compra_ID, Compra_Numero,Tiempo_ID, Sucursal_ID, Material_ID, Total)
SELECT 
	dc.Detalle_Compra_ID,
    c.Compra_Numero,
	t.Tiempo_ID, 
	c.Sucursal_NroSucursal, 
	dc.Material_ID, 
	dc.Detalle_Compra_Subtotal
FROM BDGRUPO.Compra c
JOIN BDGRUPOBI.DimTiempo t ON YEAR(c.Compra_Fecha) = t.Anio AND MONTH(c.Compra_Fecha) = t.Mes
JOIN BDGRUPO.DetalleCompra dc ON c.Compra_Numero = dc.Compra_Numero
GO

-- HechosPedidos
INSERT INTO BDGRUPOBI.HechoPedidos (Pedido_Numero, Fecha_ID, Turno_ID, Cliente_ID, Sucursal_ID, Estado)
SELECT
	p.Pedido_Numero,
	dm.Tiempo_ID,
    dt.Turno_ID,
	p.Pedido_Cliente,
	p.Pedido_Sucursal,
	de.Estado
FROM BDGRUPO.Pedido p
JOIN BDGRUPOBI.DimTiempo dm ON MONTH(p.Pedido_Fecha) = dm.Mes AND YEAR(p.Pedido_Fecha) = dm.Anio
JOIN BDGRUPOBI.DimTurno dt ON CONVERT(TIME, p.Pedido_Fecha) BETWEEN dt.Hora_Desde AND dt.Hora_Hasta
JOIN BDGRUPOBI.DimEstadoPedido de ON p.Pedido_Estado = de.Estado
GO

-- HechoEnvios
INSERT INTO BDGRUPOBI.HechoEnvios (Envio_Numero, Tiempo_ID, Localidad_Cliente, ImporteEnvio, CumplidoEnFecha)
SELECT DISTINCT e.Envio_Numero,
    t.Tiempo_ID,
	c.Cliente_Localidad, 
    e.Envio_Total,
    CASE 
        WHEN e.Envio_Fecha <= e.Envio_Fecha_Programada THEN 1
        ELSE 0
    END AS CumplidoEnFecha
FROM BDGRUPO.Envio e
JOIN BDGRUPO.Factura f ON e.Factura_Numero = f.Factura_Numero
JOIN BDGRUPO.FacturaDetalle fd ON f.Factura_Numero = fd.Factura_Numero
JOIN BDGRUPO.DetallePedido dp ON fd.Detalle_Factura_Pedido_ID = dp.Detalle_Pedido_ID
JOIN BDGRUPO.Pedido p ON dp.Pedido_Numero = p.Pedido_Numero
JOIN BDGRUPO.Cliente c ON p.Pedido_Cliente = c.Cliente_Dni
JOIN BDGRUPOBI.DimTiempo t ON YEAR(e.Envio_Fecha) = t.Anio AND MONTH(e.Envio_Fecha) = t.Mes
GO

-- //////////////////////////////////////////////////////////////
-- VISTAS
-- //////////////////////////////////////////////////////////////


--1 Ganancias
CREATE VIEW BDGRUPOBI.vista_ganancias AS
SELECT
    v.Sucursal_ID,
    t.Mes,
    t.Anio,
    SUM(v.total) - SUM(c.total) AS Ganancia
FROM
    BDGRUPOBI.HechoVentas v
INNER JOIN BDGRUPOBI.DimSucursal s ON v.Sucursal_ID = s.Sucursal_ID
INNER JOIN BDGRUPOBI.DimTiempo t ON v.Tiempo_ID = t.Tiempo_ID
INNER JOIN BDGRUPOBI.HechoCompras c ON v.Sucursal_ID = c.Sucursal_ID AND v.Tiempo_ID = c.Tiempo_ID
GROUP BY
    v.sucursal_id, t.Mes, t.Anio
GO

--2 Factura Promedio Mensual
CREATE VIEW BDGRUPOBI.vista_factura_promedio_mensual AS
SELECT
    u.Provincia,
    t.Cuatrimestre,
    t.Anio,
    AVG(f.Total) AS Promedio_Factura
FROM
    BDGRUPOBI.HechoVentas f
JOIN BDGRUPOBI.DimSucursal s ON f.Sucursal_ID = s.Sucursal_ID
JOIN BDGRUPOBI.DimUbicacion u ON s.Localidad_ID = u.Localidad_ID
JOIN BDGRUPOBI.DimTiempo t ON f.Tiempo_ID = t.Tiempo_ID
GROUP BY
    u.Provincia, t.Cuatrimestre, t.Anio
GO

--3 Rendimiento de Modelos
CREATE VIEW BDGRUPOBI.vista_rendimiento_modelos AS
SELECT
    u.Localidad,
    c.RangoEtario,
    t.Cuatrimestre,
    t.Anio,
    d.Modelo,
    SUM(v.Total) AS total_ventas
FROM
    BDGRUPOBI.HechoVentas v
    JOIN BDGRUPOBI.Dimsucursal s ON v.Sucursal_ID = s.Sucursal_ID
    JOIN BDGRUPOBI.DimUbicacion u ON s.Localidad_ID = u.Localidad_ID
    JOIN BDGRUPOBI.DimTiempo t ON v.Tiempo_ID = t.Tiempo_ID
    JOIN BDGRUPOBI.DimCliente c ON v.Cliente_ID = c.Cliente_ID
    JOIN BDGRUPOBI.DimSillon d ON v.Sillon_Codigo = d.Sillon_Codigo
GROUP BY
    u.Localidad, c.RangoEtario, t.Cuatrimestre, t.Anio, d.Modelo
GO


--4 Volumen de Pedidos
CREATE VIEW BDGRUPOBI.vista_volumen_pedidos AS
SELECT
    COUNT(DISTINCT p.Pedido_Numero) AS cantidad_pedidos,
    t.Turno,
    d.Mes,
    d.Anio,
    s.Sucursal_ID
FROM 
BDGRUPOBI.HechoPedidos p
INNER JOIN BDGRUPOBI.DimTurno t ON p.Turno_ID = t.Turno_ID
INNER JOIN BDGRUPOBI.DimTiempo d ON p.Fecha_ID = d.Tiempo_ID
INNER JOIN BDGRUPOBI.DimSucursal s ON p.Sucursal_ID = s.Sucursal_ID
GROUP BY 
    t.Turno, 
    d.Mes, 
    d.Anio, 
    s.Sucursal_ID
GO

--5 Conversion de pedidos 
CREATE VIEW BDGRUPOBI.vista_conversion_pedidos AS
SELECT
    COUNT(*) * 100.0 / NULLIF(SUM(COUNT(*)) OVER (PARTITION BY t.Anio, t.Cuatrimestre, s.Sucursal_ID), 0) AS Porcentaje_Conversion,
    e.Estado,
    t.Anio,
    t.Cuatrimestre,
    s.Sucursal_ID
FROM BDGRUPOBI.HechoPedidos hp
INNER JOIN BDGRUPOBI.DimEstadoPedido e ON hp.Estado = e.Estado
INNER JOIN BDGRUPOBI.DimTiempo t ON hp.Fecha_ID = t.Tiempo_ID
INNER JOIN BDGRUPOBI.DimSucursal s ON hp.Sucursal_ID = s.Sucursal_ID
GROUP BY e.Estado, t.Anio, t.Cuatrimestre, s.Sucursal_ID;
GO

--6 Tiempo promedio de fabricacion
CREATE VIEW BDGRUPOBI.vista_tiempo_promedio_fabricacion AS
SELECT
    AVG(v.TiempoFabricacion) AS tiempo_promedio_fabricacion_horas,
    s.Sucursal_ID,
    t.Cuatrimestre,
    t.Anio
FROM
BDGRUPOBI.HechoVentas v 
INNER JOIN BDGRUPOBI.DimSucursal s ON v.Sucursal_ID = s.Sucursal_ID
INNER JOIN BDGRUPOBI.DimTiempo t ON v.Tiempo_ID = t.Tiempo_ID
GROUP BY s.Sucursal_ID, t.Cuatrimestre, t.Anio
GO

--7 Promedio de Compras
CREATE VIEW BDGRUPOBI.vista_promedio_compras AS
SELECT
    AVG(c.Total) AS importe_promedio_compra,
    t.Mes,
    t.Anio
FROM
BDGRUPOBI.HechoCompras c
INNER JOIN BDGRUPOBI.DimTiempo t ON c.Tiempo_ID = t.Tiempo_ID
GROUP BY t.Mes, t.Anio
GO

--8 Compras por tipo de material
CREATE VIEW BDGRUPOBI.vista_compras_material AS
SELECT
    m.Tipo,
    SUM(c.Total) AS importe_total,
    s.Sucursal_ID,
    t.Cuatrimestre,
    t.Anio
FROM
BDGRUPOBI.HechoCompras c
INNER JOIN BDGRUPOBI.DimMaterial m ON c.Material_ID = m.Material_ID
INNER JOIN BDGRUPOBI.DimSucursal s ON c.Sucursal_ID = s.Sucursal_ID
INNER JOIN BDGRUPOBI.DimTiempo t ON c.Tiempo_ID = t.Tiempo_ID
GROUP BY m.Tipo, s.Sucursal_ID, t.Cuatrimestre, t.Anio
GO

--9 Porcentaje de cumplimiento de envios
CREATE VIEW BDGRUPOBI.vista_cumplimiento_envios AS
SELECT 
    ((COUNT(CASE WHEN e.CumplidoEnFecha = 1 THEN 1 END) * 100.0) / COUNT(DISTINCT e.Envio_Numero)) AS porcentaje_cumplimiento,
    t.Mes,
    t.Anio
FROM
BDGRUPOBI.HechoEnvios e
INNER JOIN BDGRUPOBI.DimTiempo t ON e.Tiempo_ID = t.Tiempo_ID
GROUP BY t.Mes, t.Anio
GO


--10 Localidades que pagan mayor costo de envio
CREATE VIEW BDGRUPOBI.vista_localidades_mayor_costo AS
SELECT TOP 3
u.Localidad,
u.Provincia,
ROW_NUMBER() OVER (ORDER BY he.ImporteEnvio DESC) AS puesto
FROM BDGRUPOBI.HechoEnvios he 
INNER JOIN BDGRUPOBI.DimUbicacion u ON u.Localidad_ID = he.Localidad_Cliente
GO


