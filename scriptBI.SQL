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
IF OBJECT_ID('BDGRUPOBI.DimMaterial', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.DimMaterial;
IF OBJECT_ID('BDGRUPOBI.DimSillon', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.DimSillon;
IF OBJECT_ID('BDGRUPOBI.DimCliente', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.DimCliente;
IF OBJECT_ID('BDGRUPOBI.DimTurno', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.DimTurno;
IF OBJECT_ID('BDGRUPOBI.DimEstadoPedido', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.DimEstadoPedido;


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

-- DIM_SUCURSAL
CREATE TABLE BDGRUPOBI.DimSucursal (
    Sucursal_ID BIGINT PRIMARY KEY,
    Provincia NVARCHAR(100),
    Localidad NVARCHAR(100)
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
    Factura_Numero BIGINT PRIMARY KEY,
    Tiempo_ID INT,
    TiempoFabricacion INT,
    Cliente_ID BIGINT,
    Sucursal_ID BIGINT,
    Total DECIMAL(10,2),
    FOREIGN KEY (Tiempo_ID) REFERENCES BDGRUPOBI.DimTiempo(Tiempo_ID),
    FOREIGN KEY (Cliente_ID) REFERENCES BDGRUPOBI.DimCliente(Cliente_ID),
    FOREIGN KEY (Sucursal_ID) REFERENCES BDGRUPOBI.DimSucursal(Sucursal_ID)
);
GO

-- HECHO_COMPRAS
CREATE TABLE BDGRUPOBI.HechoCompras (
    Compra_Numero DECIMAL(18,0),
    Tiempo_ID INT,
    Sucursal_ID BIGINT,
    Material_ID BIGINT,
    Total DECIMAL(10,2),
	PRIMARY KEY (Compra_Numero, Sucursal_ID, Material_ID),
    FOREIGN KEY (Tiempo_ID) REFERENCES BDGRUPOBI.DimTiempo(Tiempo_ID),
    FOREIGN KEY (Sucursal_ID) REFERENCES BDGRUPOBI.DimSucursal(Sucursal_ID),
    FOREIGN KEY (Material_ID) REFERENCES BDGRUPOBI.DimMaterial(Material_ID)
);
GO

-- HECHO_PEDIDOS
CREATE TABLE BDGRUPOBI.HechoPedidos (
    Pedido_Numero DECIMAL(18,0) PRIMARY KEY,
    Fecha_ID INT,
    Cliente_ID BIGINT,
    Sucursal_ID BIGINT,
    Estado NVARCHAR(50),
    FOREIGN KEY (Fecha_ID) REFERENCES BDGRUPOBI.DimTiempo(Tiempo_ID),
    FOREIGN KEY (Cliente_ID) REFERENCES BDGRUPOBI.DimCliente(Cliente_ID),
    FOREIGN KEY (Sucursal_ID) REFERENCES BDGRUPOBI.DimSucursal(Sucursal_ID)
);
GO

-- HECHO_ENVIOS
CREATE TABLE BDGRUPOBI.HechoEnvios (
    Envio_Numero DECIMAL(18,0) PRIMARY KEY,
    Tiempo_ID INT,
    Cliente_Localidad NVARCHAR(100),
    ImporteEnvio DECIMAL(10,2),
    CumplidoEnFecha BIT
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

-- DimSucursal
INSERT INTO BDGRUPOBI.DimSucursal (Sucursal_ID, Provincia, Localidad)
SELECT s.Sucursal_NroSucursal, l.localidad_Provincia, s.Sucursal_Localidad
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
INSERT INTO BDGRUPOBI.HechoVentas (Factura_Numero, Tiempo_ID, TiempoFabricacion, Cliente_ID, Sucursal_ID, Total)
SELECT DISTINCT
	f.Factura_Numero, 
	t.Tiempo_ID,
	DATEDIFF(HOUR, p.Pedido_Fecha, f.Factura_Fecha),
	p.Pedido_Cliente, 
	f.Factura_Sucursal, 
	f.Factura_Total
FROM BDGRUPO.Factura f
JOIN BDGRUPO.FacturaDetalle fd ON f.Factura_Numero = fd.Factura_Numero
JOIN BDGRUPO.DetallePedido dp ON fd.Detalle_Factura_Pedido_ID = dp.Detalle_Pedido_ID
JOIN BDGRUPO.Pedido p ON dp.Pedido_Numero = p.Pedido_Numero
JOIN BDGRUPOBI.DimTiempo t ON f.Factura_Fecha = t.Fecha;

-- HechosCompras
INSERT INTO BDGRUPOBI.HechoCompras (Compra_Numero, Tiempo_ID, Sucursal_ID, Material_ID, Total)
SELECT DISTINCT 
	c.Compra_Numero, 
	t.Tiempo_ID, 
	c.Sucursal_NroSucursal, 
	dc.Material_ID, 
	c.Compra_Total
FROM BDGRUPO.Compra c
JOIN BDGRUPO.DetalleCompra dc ON c.Compra_Numero = dc.Compra_Numero
JOIN BDGRUPOBI.DimTiempo t ON c.Compra_Fecha = t.Fecha

-- HechosPedidos
INSERT INTO BDGRUPOBI.HechoPedidos (Pedido_Numero, Fecha_ID, Cliente_ID, Sucursal_ID, Estado)
SELECT
	p.Pedido_Numero,
	dm.Tiempo_ID,
	p.Pedido_Cliente,
	p.Pedido_Sucursal,
	de.Estado
FROM BDGRUPO.Pedido p
JOIN BDGRUPOBI.DimTiempo dm ON p.Pedido_Fecha = dm.Fecha
JOIN BDGRUPOBI.DimEstadoPedido de ON p.Pedido_Estado = de.Estado

-- HechoEnvios      //REVISAARRRRRRRRRR
INSERT INTO BDGRUPOBI.HechoEnvios (Envio_Numero, Tiempo_ID, Cliente_Localidad, ImporteEnvio, CumplidoEnFecha)
SELECT
    e.Envio_Numero,
    t.Tiempo_ID,
    l.Localidad_Nombre, -- o e.Envio_Localidad si ya lo trae directo
    e.Envio_Total,
    CASE 
        WHEN e.Envio_Fecha <= e.Envio_Fecha_Programada THEN 1
        ELSE 0
    END AS CumplidoEnFecha
FROM BDGRUPO.Envio e
JOIN BDGRUPO.Factura f ON e.Factura_Numero = f.Factura_Numero
JOIN BDGRUPO.FacturaDetalle fd ON f.Factura_Numero = fd.Factura_Numero
JOIN BDGRUPO.DetallePedido dp ON fd.Detalle_ID = dp.Detalle_Pedido_ID
JOIN BDGRUPO.Pedido p ON dp.Pedido_Numero = p.Pedido_Numero
JOIN BDGRUPO.Cliente c ON p.Pedido_Cliente = c.Cliente_Dni
JOIN BDGRUPO.Localidad l ON c.Cliente_Localidad = l.Localidad_ID
JOIN BDGRUPOBI.DimTiempo t ON CAST(e.Envio_Fecha AS DATE) = t.Fecha;



--VISTAS
--1 Ganancias
CREATE VIEW vista_ganancias AS
SELECT
ISNULL(SUM(v.Total), 0) - ISNULL(SUM(c.Total), 0) AS ganancia,
s.Sucursal_ID,
t.Mes,
t.Anio
FROM
BDGRUPOBI.HechoVentas v 
INNER JOIN BDGRUPOBI.DimSucursal s ON v.Sucursal_ID = s.Sucursal_ID
INNER JOIN BDGRUPOBI.HechoCompras c ON c.Sucursal_ID = s.Sucursal_ID
INNER JOIN BDGRUPOBI.DimTiempo t ON v.Tiempo_ID = t.Tiempo_ID AND c.Tiempo_ID = t.Tiempo_ID
GROUP BY
s.Sucursal_ID,
t.Mes,
t.Anio

--2 Factura Promedio Mensual
--3 Rendimiento de Modelos

--4 Volumen de Pedidos
CREATE VIEW vista_volumen_pedidos AS
SELECT
COUNT(DISTINCT p.Pedido_Numero) AS cantidad_pedidos,
t.Turno,
d.Mes,
d.Anio,
s.Sucursal_ID
FROM 
HechoPedidos p
INNER JOIN
DimTurno t ON p.Turno_ID = t.Turno_ID
INNER JOIN 
DimTiempo d ON p.Fecha_ID = d.Fecha_ID
INNER JOIN
DimSucursal s ON p.Sucursal_ID = s.Sucursal_ID
GROUP BY 
t.Turno, 
d.Mes, 
d.Anio, 
s.Sucursal_ID

--5 Conversion de pedidos
--6 Tiempo promedio de fabricacion
CREATE VIEW vista_tiempo_promedio_fabricacion AS
SELECT
AVG(v.TiempoFabricacion) AS tiempo_promedio_fabricacion_horas,
s.Sucursal_ID,
t.Cuatrimestre,
t.Anio
FROM
HechoVentas v 
INNER JOIN DimSucursal s ON v.Sucursal_ID = s.Sucursal_ID
INNER JOIN DimTiempo t ON v.Tiempo_ID = t.Tiempo_ID
GROUP BY
s.Sucursal_ID,
t.Cuatrimestre,
t.Anio


--7 Promedio de Compras
CREATE VIEW vista_promedio_compras AS
SELECT
AVG(c.Total) AS importe_promedio_compra,
t.Mes
t.Anio
FROM
HechoCompras c
INNER JOIN DimTiempo t ON c.Tiempo_ID = t.Tiempo_ID
GROUP BY t.Mes, t.Anio

--8 Compras por tipo de material
CREATE VIEW vista_compras_material AS
SELECT
m.Tipo,
SUM(c.Total) AS importe_total,
s.Sucursal_ID,
t.Cuatrimestre,
t.Anio
FROM
HechoCompras c
INNER JOIN DimMaterial m ON c.Material_ID = m.Material_ID
INNER JOIN DimSucursal s ON c.Sucursal_ID = s.Sucursal_ID
INNER JOIN DimTiempo t ON c.Tiempo_ID = t.Tiempo_ID
GROUP BY 
m.Tipo,
s.Sucursal_ID,
t.Cuatrimestre,
t.Anio

--9 Porcentaje de cumplimiento de envios
CREATE VIEW vista_cumplimiento_envios AS
SELECT 
((COUNT(CASE WHEN e.CumplidoEnFecha = 1 THEN 1 END) * 100.0) / COUNT(DISTINCT e.Envio_Numero)) AS porcentaje_cumplimiento,
t.Mes,
t.Anio
FROM
HechoEnvios e
INNER JOIN DimTiempo t ON e.Fecha_ID = t.Fecha_ID
GROUP BY 
t.Mes,
t.Anio

--10 Localidades que pagan mayor costo de envio