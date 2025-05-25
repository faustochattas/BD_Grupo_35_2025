
---------- Materal, tela, etc. 


CREATE TABLE Pedido (
    Pedido_Numero DECIMAL(18, 0) PRIMARY KEY,
    Pedido_Cliente BIGINT,
    Pedido_Sucursal BIGINT,
    Pedido_Estado VARCHAR(50),
    Pedido_CancelacionPedido BIGINT,
    Pedido_Fecha DATE,
    Pedido_Total DECIMAL(10, 2),

    FOREIGN KEY (Pedido_Cliente) REFERENCES Cliente(Dni_Cliente),
    FOREIGN KEY (Pedido_Sucursal) REFERENCES Sucursal(Sucursal_ID),
    FOREIGN KEY (Pedido_CancelacionPedido) REFERENCES CancelacionPedido(CancelacionID)
);


CREATE TABLE CancelacionPedido (
    Cancelacion_ID INT PRIMARY KEY,
    Pedido_Cancelacion_Fecha DATE,
    Pedido_Cancelacion_Motivo VARCHAR(255)
);

CREATE TABLE Factura (
    Factura_Numero INT PRIMARY KEY,
    Factura_Fecha DATE,
    Factura_Sucursal BIGINT,
    Factura_Total DECIMAL(10,2),

    FOREIGN KEY (Factura_Sucursal) REFERENCES Sucursal(Sucursal_ID)
);

CREATE TABLE DetallePedido (
    Detalle_Pedido_ID INT PRIMARY KEY,
    Pedido_Numero INT,
    Sillon_Codigo INT,
    Detalle_Pedido_Cantidad INT,
    Detalle_Pedido_Precio DECIMAL(10, 2),
    Detalle_Pedido_SubTotal DECIMAL(10, 2),

    FOREIGN KEY (Pedido_Numero) REFERENCES Pedido(Pedido_Numero),
    FOREIGN KEY (Sillon_Codigo) REFERENCES Sillon(Sillon_ID)
);


CREATE TABLE FacturaDetalle (
    Detalle_ID INT PRIMARY KEY,
    Factura_Numero INT,
    Detalle_Pedido_ID INT,
    Detalle_Factura_Cantidad INT,
    Detalle_Factura_Precio DECIMAL(10, 2),
    Detalle_Factura_SubTotal DECIMAL(10, 2),

    FOREIGN KEY (Factura_Numero) REFERENCES Factura(Factura_Numero),
    FOREIGN KEY (Detalle_Pedido_ID) REFERENCES DetallePedido(Detalle_Pedido_ID)
);

CREATE TABLE Envio (
    Envio_Numero INT PRIMARY KEY,
    Factura_Numero INT,
    Envio_Fecha_Programada DATE,
    Envio_Fecha DATE,
    Envio_ImporteTraslado DECIMAL(10,2),
    Envio_ImporteSubida DECIMAL(10,2),
    Envio_Total DECIMAL(10,2),

    FOREIGN KEY (Factura_Numero) REFERENCES Factura(Factura_Numero)
);


CREATE TABLE Compra (
    Compra_Numero INT PRIMARY KEY,
    Sucursal_NroSucursal INT,
    Proveedor_Cuit BIGINT,
    Detalle_Compra_ID INT,
    Compra_Fecha DATE,
    Compra_Total DECIMAL(10,2),

    FOREIGN KEY (Sucursal_NroSucursal) REFERENCES Sucursal(Sucursal_ID),
    FOREIGN KEY (Proveedor_Cuit) REFERENCES Proveedor(Cuit),
    FOREIGN KEY (Detalle_Compra_ID) REFERENCES DetalleCompra(Detalle_Compra_ID)
);

CREATE TABLE Sucursal (
    Sucursal_NroSucursal INT PRIMARY KEY,
    Sucursal_Localidad INT,
    Sucursal_Direccion VARCHAR(255),
    Sucursal_Telefono VARCHAR(20),
    Sucursal_Mail VARCHAR(100),

    FOREIGN KEY (Sucursal_Localidad) REFERENCES Localidad(Localidad_ID)
);

CREATE TABLE Cliente (
    Cliente_Dni BIGINT PRIMARY KEY,
    Cliente_Apellido VARCHAR(100),
    Cliente_Nombre VARCHAR(100),
    Cliente_Localidad INT,
    Cliente_Mail VARCHAR(100),
    Cliente_FechaNacimiento DATE,
    Cliente_Telefono VARCHAR(20),
    Cliente_Direccion VARCHAR(255),

    FOREIGN KEY (Cliente_Localidad) REFERENCES Localidad(Localidad_ID)
);

CREATE TABLE Proveedor (
    Proveedor_Cuit BIGINT PRIMARY KEY,
    Proveedor_Telefono VARCHAR(20),
    Proveedor_Mail VARCHAR(100),
    Proveedor_Direccion VARCHAR(255),
    Proveedor_Localidad INT,
    Proveedor_RazonSocial VARCHAR(100),

    FOREIGN KEY (Proveedor_Localidad) REFERENCES Localidad(Localidad_ID)
);

CREATE TABLE DetalleCompra (
    Detalle_Compra_ID INT PRIMARY KEY,
    Material_Nombre VARCHAR(100),
    Detalle_Compra_Precio DECIMAL(10,2),
    Detalle_Compra_Cantidad INT,
    Detalle_Compra_Subtotal DECIMAL(10,2),

    FOREIGN KEY (Material_Nombre) REFERENCES Material(Nombre)
);

CREATE TABLE MaterialPorSillon (
    Sillon_Codigo INT,
    Material_Nombre VARCHAR(100),

    PRIMARY KEY (Sillon_Codigo, Material_Nombre),

    FOREIGN KEY (Sillon_Codigo) REFERENCES Sillon(Sillon_ID),
    FOREIGN KEY (Material_Nombre) REFERENCES Material(Nombre)
);

CREATE TABLE Sillon (
    Sillon_Codigo INT PRIMARY KEY,
    Sillon_Modelo_Codigo INT,
    Medida_Codigo INT,
    Material_Nombre VARCHAR(100),

    FOREIGN KEY (Sillon_Modelo_Codigo) REFERENCES Modelo(Modelo_ID),
    FOREIGN KEY (Medida_Codigo) REFERENCES Medida(Medida_ID),
    FOREIGN KEY (Material_Nombre) REFERENCES Material(Nombre)
);

CREATE TABLE Localidad (
    Localidad_Nombre VARCHAR(100) PRIMARY KEY,
    Localidad_Provincia VARCHAR(100),

    FOREIGN KEY (Localidad_Provincia) REFERENCES Provincia(Provincia_Nombre)
);

CREATE TABLE Material (
    Material_Nombre VARCHAR(100) PRIMARY KEY,
    Material_Descripcion VARCHAR(255),
    Material_Precio DECIMAL(10,2),
    Material_Tipo VARCHAR(100),

    FOREIGN KEY (Material_Tipo) REFERENCES Tipo(Tipo_Nombre)
);

CREATE TABLE Modelo (
    Modelo_Codigo INT PRIMARY KEY,
    Modelo_Descripcion VARCHAR(255),
    Modelo_Precio DECIMAL(10,2)
);

CREATE TABLE Medida (
    Medida_Codigo INT PRIMARY KEY,
    Medida_Alto DECIMAL(5,2),
    Medida_Ancho DECIMAL(5,2),
    Medida_Profundidad DECIMAL(5,2),
    Medida_Precio DECIMAL(10,2)
);

CREATE TABLE Provincia (
    Provincia_Nombre VARCHAR(100) PRIMARY KEY
);

CREATE TABLE Tela (
    Tela_Tipo VARCHAR(100) PRIMARY KEY,
    Tela_Color VARCHAR(100),
    Tela_Textura VARCHAR(100)
);

CREATE TABLE Madera (
    Madera_Tipo VARCHAR(100) PRIMARY KEY,
    Madera_Color VARCHAR(100),
    Madera_Dureza VARCHAR(50)
);

CREATE TABLE Relleno (
    Relleno_Tipo VARCHAR(100) PRIMARY KEY,
    Relleno_Densidad VARCHAR(50)
);



