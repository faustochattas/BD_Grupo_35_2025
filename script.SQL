CREATE SCHEMA BDGRUPO;
USE BDGRUPO;

-- PROVINCIA
CREATE TABLE BDGRUPO.Provincia (
    Provincia_Nombre NVARCHAR(100) PRIMARY KEY
);

-- LOCALIDAD
CREATE TABLE BDGRUPO.Loclida (
    Localidad_Nombre NVARCHAR(100) PRIMARY KEY,
    Localidad_Provincia NVARCHAR(100),
    FOREIGN KEY (Localidad_Provincia) REFERENCES Provincia(Provincia_Nombre)
);

-- CLIENTE
CREATE TABLE Cliente (
    Cliente_Dni DECIMAL(18, 0) PRIMARY KEY,
    Cliente_Apellido NVARCHAR(100),
    Cliente_Nombre NVARCHAR(100),
    Cliente_Localidad NVARCHAR(100),
    Cliente_Mail NVARCHAR(100),
    Cliente_FechaNacimiento DATE,
    Cliente_Telefono NVARCHAR(20),
    Cliente_Direccion NVARCHAR(255),
    FOREIGN KEY (Cliente_Localidad) REFERENCES Localidad(Localidad_Nombre)
);

-- SUCURSAL
CREATE TABLE BDGRUPO.Sucursal (
    Sucursal_NroSucursal INT PRIMARY KEY,
    Sucursal_Localidad NVARCHAR(100),
    Sucursal_Direccion NVARCHAR(255),
    Sucursal_Telefono NVARCHAR(20),
    Sucursal_Mail NVARCHAR(100),
    FOREIGN KEY (Sucursal_Localidad) REFERENCES Localidad(Localidad_Nombre)
);

-- PROVEEDOR
CREATE TABLE BDGRUPO.Proveedor (
    Proveedor_Cuit BIGINT PRIMARY KEY,
    Proveedor_Telefono NVARCHAR(20),
    Proveedor_Mail NVARCHAR(100),
    Proveedor_Direccion NVARCHAR(255),
    Proveedor_Localidad NVARCHAR(100),
    Proveedor_RazonSocial NVARCHAR(100),
    FOREIGN KEY (Proveedor_Localidad) REFERENCES Localidad(Localidad_Nombre)
);

-- MATERIAL
CREATE TABLE BDGRUPO.Material (
    Material_Nombre NVARCHAR(100) PRIMARY KEY,
    Material_Descripcion NVARCHAR(255),
    Material_Precio DECIMAL(10,2),
    Material_Tipo NVARCHAR(100),
);

-- TELA
CREATE TABLE BDGRUPO.Tela (
    Tela_Tipo NVARCHAR(100) PRIMARY KEY,
    Tela_Color NVARCHAR(100),
    Tela_Textura NVARCHAR(100)
);

-- MADERA
CREATE TABLE BDGRUPO.Madera (
    Madera_Tipo NVARCHAR(100) PRIMARY KEY,
    Madera_Color NVARCHAR(100),
    Madera_Dureza NVARCHAR(50)
);

-- RELLENO
CREATE TABLE BDGRUPO.Relleno (
    Relleno_Tipo NVARCHAR(100) PRIMARY KEY,
    Relleno_Densidad NVARCHAR(50)
);

-- MODELO
CREATE TABLE BDGRUPO.Modelo (
    Modelo_Codigo INT PRIMARY KEY,
    Modelo_Descripcion NVARCHAR(255),
    Modelo_Precio DECIMAL(10,2)
);

-- MEDIDA
CREATE TABLE BDGRUPO.Medida (
    Medida_Codigo INT PRIMARY KEY,
    Medida_Alto DECIMAL(5,2),
    Medida_Ancho DECIMAL(5,2),
    Medida_Profundidad DECIMAL(5,2),
    Medida_Precio DECIMAL(10,2)
);

-- SILLON
CREATE TABLE BDGRUPO.Sillon (
    Sillon_Codigo INT PRIMARY KEY,
    Sillon_Modelo_Codigo INT,
    Medida_Codigo INT,
    Material_Nombre NVARCHAR(100),
    FOREIGN KEY (Sillon_Modelo_Codigo) REFERENCES Modelo(Modelo_Codigo),
    FOREIGN KEY (Medida_Codigo) REFERENCES Medida(Medida_Codigo),
    FOREIGN KEY (Material_Nombre) REFERENCES Material(Material_Nombre)
);

-- MATERIAL POR SILLON
CREATE TABLE BDGRUPO.MaterialPorSillon (
    Sillon_Codigo INT,
    Material_Nombre NVARCHAR(100),
    FOREIGN KEY (Sillon_Codigo) REFERENCES Sillon(Sillon_Codigo),
    FOREIGN KEY (Material_Nombre) REFERENCES Material(Material_Nombre)
);

-- DETALLE COMPRA
CREATE TABLE BDGRUPO.DetalleCompra (
    Detalle_Compra_ID INT PRIMARY KEY,
    Material_Nombre NVARCHAR(100),
    Detalle_Compra_Precio DECIMAL(10,2),
    Detalle_Compra_Cantidad INT,
    Detalle_Compra_Subtotal DECIMAL(10,2),
    FOREIGN KEY (Material_Nombre) REFERENCES Material(Material_Nombre)
);

-- COMPRA
CREATE TABLE BDGRUPO.Compra (
    Compra_Numero INT PRIMARY KEY,
    Sucursal_NroSucursal INT,
    Proveedor_Cuit BIGINT,
    Detalle_Compra_ID INT,
    Compra_Fecha DATE,
    Compra_Total DECIMAL(10,2),
    FOREIGN KEY (Sucursal_NroSucursal) REFERENCES Sucursal(Sucursal_NroSucursal),
    FOREIGN KEY (Proveedor_Cuit) REFERENCES Proveedor(Proveedor_Cuit),
    FOREIGN KEY (Detalle_Compra_ID) REFERENCES DetalleCompra(Detalle_Compra_ID)
);

-- CANCELACION PEDIDO
CREATE TABLE BDGRUPO.CancelacionPedido (
    Cancelacion_ID INT PRIMARY KEY,
    Pedido_Cancelacion_Fecha DATE,
    Pedido_Cancelacion_Motivo NVARCHAR(255)
);

-- PEDIDO
CREATE TABLE BDGRUPO.Pedido (
    Pedido_Numero DECIMAL(18, 0) PRIMARY KEY,
    Pedido_Cliente BIGINT,
    Pedido_Sucursal INT,
    Pedido_Estado NVARCHAR(50),
    Pedido_CancelacionPedido INT,
    Pedido_Fecha DATE,
    Pedido_Total DECIMAL(10, 2),
    FOREIGN KEY (Pedido_Cliente) REFERENCES Cliente(Cliente_Dni),
    FOREIGN KEY (Pedido_Sucursal) REFERENCES Sucursal(Sucursal_NroSucursal),
    FOREIGN KEY (Pedido_CancelacionPedido) REFERENCES CancelacionPedido(Cancelacion_ID)
);

-- DETALLE PEDIDO
CREATE TABLE BDGRUPO.DetallePedido (
    Detalle_Pedido_ID INT PRIMARY KEY,
    Pedido_Numero DECIMAL(18, 0),
    Sillon_Codigo INT,
    Detalle_Pedido_Cantidad INT,
    Detalle_Pedido_Precio DECIMAL(10, 2),
    Detalle_Pedido_SubTotal DECIMAL(10, 2),
    FOREIGN KEY (Pedido_Numero) REFERENCES Pedido(Pedido_Numero),
    FOREIGN KEY (Sillon_Codigo) REFERENCES Sillon(Sillon_Codigo)
);

-- FACTURA
CREATE TABLE BDGRUPO.Factura (
    Factura_Numero INT PRIMARY KEY,
    Factura_Fecha DATE,
    Factura_Sucursal INT,
    Factura_Total DECIMAL(10,2),
    FOREIGN KEY (Factura_Sucursal) REFERENCES Sucursal(Sucursal_NroSucursal)
);

-- FACTURA DETALLE
CREATE TABLE BDGRUPO.FacturaDetalle (
    Detalle_ID INT PRIMARY KEY,
    Factura_Numero INT,
    Detalle_Pedido_ID INT,
    Detalle_Factura_Cantidad INT,
    Detalle_Factura_Precio DECIMAL(10, 2),
    Detalle_Factura_SubTotal DECIMAL(10, 2),
    FOREIGN KEY (Factura_Numero) REFERENCES Factura(Factura_Numero),
    FOREIGN KEY (Detalle_Pedido_ID) REFERENCES DetallePedido(Detalle_Pedido_ID)
);

-- ENVIO
CREATE TABLE BDGRUPO.Envio (
    Envio_Numero INT PRIMARY KEY,
    Factura_Numero INT,
    Envio_Fecha_Programada DATE,
    Envio_Fecha DATE,
    Envio_ImporteTraslado DECIMAL(10,2),
    Envio_ImporteSubida DECIMAL(10,2),
    Envio_Total DECIMAL(10,2),
    FOREIGN KEY (Factura_Numero) REFERENCES Factura(Factura_Numero)
);

--ASIGNACION DE LOS VALORES DE TABLA MAESTRA A LAS TABLAS CREADAS
INSERT INTO BDGRUPO.Provincia (Provincia_Nombre)
SELECT DISTINCT Localidad_Provincia
FROM gd_esquema.Maestra
WHERE Localidad_Provincia IS NOT NULL;

