USE GD1C2025;
GO

-- //////////////////////////////////////////////////////////////
-- ELIMINACION DE TABLAS Y PROCEDIMIENTOS ANTERIORES
-- //////////////////////////////////////////////////////////////
DROP PROCEDURE IF EXISTS BDGRUPOBI.Migrar_Datos;

IF OBJECT_ID('BDGRUPOBI.DimTiempo', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.DimTiempo;
IF OBJECT_ID('BDGRUPOBI.DimSucursal', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.DimSucursal;
IF OBJECT_ID('BDGRUPOBI.DimMaterial', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.DimMaterial;
IF OBJECT_ID('BDGRUPOBI.DimSillon', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.DimSillon;
IF OBJECT_ID('BDGRUPOBI.DimCliente', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.DimCliente;
IF OBJECT_ID('BDGRUPOBI.DimTurno', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.DimTurno;
IF OBJECT_ID('BDGRUPOBI.DimEstadoPedido', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.DimEstadoPedido;
IF OBJECT_ID('BDGRUPOBI.HechoVentas', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.HechoVentas;
IF OBJECT_ID('BDGRUPOBI.HechoCompras', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.HechoCompras;

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
    Mes INT
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
    Compra_Numero DECIMAL(18,0) PRIMARY KEY,
    Tiempo_ID INT,
    Sucursal_ID BIGINT,
    Material_ID BIGINT,
    Total DECIMAL(10,2),
    FOREIGN KEY (Tiempo_ID) REFERENCES BDGRUPOBI.DimTiempo(Tiempo_ID),
    FOREIGN KEY (Sucursal_ID) REFERENCES BDGRUPOBI.DimSucursal(Sucursal_ID),
    FOREIGN KEY (Material_ID) REFERENCES BDGRUPOBI.DimMaterial(Material_ID)
);
GO

/*
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
CREATE TABLE BDGRUPO.BI_HechoEnvios (
    Envio_Numero DECIMAL(18,0) PRIMARY KEY,
    Tiempo_ID INT,
    Cliente_Localidad NVARCHAR(100),
    ImporteEnvio DECIMAL(10,2),
    CumplidoEnFecha BIT
);
GO
*/

-- CARGA DE DATOS DIMENSIONES

-- Cliente
INSERT INTO BDGRUPOBI.DimCliente (Cliente_ID, RangoEtario)
SELECT Cliente_Dni,
    CASE 
        WHEN DATEDIFF(YEAR, Cliente_FechaNacimiento, GETDATE()) < 25 THEN '<25'
        WHEN DATEDIFF(YEAR, Cliente_FechaNacimiento, GETDATE()) BETWEEN 25 AND 35 THEN '25-35'
        WHEN DATEDIFF(YEAR, Cliente_FechaNacimiento, GETDATE()) BETWEEN 36 AND 50 THEN '35-50'
        ELSE '>50' END
FROM BDGRUPO.Cliente;

--Tiempo
INSERT INTO BDGRUPOBI.DimTiempo (anio, mes, cuatrimestre) 
SELECT anio, mes,
CASE 
WHEN mes IN (1,2,3) THEN 1
    WHEN mes IN (4,5,6) THEN 2
    WHEN mes IN (7,8,9) THEN 3
    ELSE 4
END,
    TO_CHAR(DATE (anio || '-' || mes || '-01'), 'Month')
FROM generate_series(2010, 2030) AS anio,
    generate_series(1, 12) AS mes;


INSERT INTO BDGRUPOBI.DimSucursal (Sucursal_ID, Provincia, Localidad)
SELECT s.Sucursal_ID, p.Sucursal_Provincia, s.Sucursal_Localidad
FROM BDGRUPO.Sucursal s
JOIN BDGRUPO.Provincia p ON s.Sucursal_Provincia = p.Provincia_Nombre;


INSERT INTO BDGRUPOBI.DimTurno(Turno_ID, Hora_Desde, Hora_Hasta, Turno) VALUES
(1, '8:00:00', '13:59:59', '8:00 - 14:00'),
(2, '14:00:00', '19:59:59', '14:00 - 20:00');

INSERT TO BDGRUPOBI.DimEstadoPedido(Estado_ID, Estado) VALUES
(1, 'pendiente'),
(2, 'entregado'),
(3, 'cancelado');


INSERT INTO BDGRUPOBI.DimSillon(Sillon_Codigo, Modelo)
SELECT Sillon_Codigo, Sillon_Modelo
FROM BDGRUPO.Sillon;

INSERT INTO BDGRUPOBI.DimMaterial(Material_ID, Tipo)
SELECT Material_ID, Material_TipoID
FROM BDGRUPO.Material;

-- CARGA DE DATOS HECHOS
-- Ventas
INSERT INTO BDGRUPO.BI_HechoVentas (Factura_Numero, Tiempo_ID, TiempoFabricacion Cliente_ID, Sucursal_ID, Total)
SELECT 
f.Factura_Numero, 
t.Tiempo_ID,
DATEDIFF(HOURS, p.Pedido_Fecha, f.Factura_Fecha),
p.Pedido_Cliente, 
f.Factura_Sucursal, 
f.Factura_Total
FROM BDGRUPO.Factura f
JOIN BDGRUPO.FacturaDetalle fd ON f.Factura_Numero = fd.Factura_Numero
JOIN BDGRUPO.DetallePedido dp ON fd.Detalle_Factura_Pedido_ID = dp.Detalle_Pedido_ID
JOIN BDGRUPO.Pedido p ON dp.Pedido_Numero = p.Pedido_Numero
JOIN BDGRUPO.BI_DimTiempo t ON t.Fecha = f.Factura_Fecha;

-- Compras
INSERT INTO BDGRUPOBI.HechoCompras (Compra_Numero, Tiempo_ID, Sucursal_ID, Material_ID, Total)
SELECT c.Compra_Numero, t.Tiempo_ID, c.Compra_Sucursal, c.Compra_Material, c.Compra_Total
FROM BDGRUPO.Compra c
JOIN BDGRUPO.BI_DimTiempo t ON t.Fecha = c.Compra_Fecha
JOIN BDGRUPO.BI_DimMaterial m ON m.Material_ID = c.Compra_Material
JOIN BDGRUPO.BI_DimSucursal s ON s.Sucursal_ID = c.Compra_Sucursal;


--VISTAS
--1 Ganancias
CREATE VIEW vista_ganancias AS
SELECT
ISNULL(SUM(v.Total), 0) - ISNULL(SUM(c.Total), 0) AS ganancia,
s.Sucursal,
t.Mes,
t.Anio
FROM
HechoVentas v 
INNER JOIN DimSucursal s ON v.Sucursal_ID = s.Sucursal_ID
INNER JOIN HechoCompras c ON c.Sucursal_ID = s.Sucursal_ID
INNER JOIN DimTiempo t ON v.Tiempo_ID = t.Tiempo_ID AND c.Tiempo_ID = t.Tiempo_ID
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
--10 Localidades que pagan mayor costo de envio