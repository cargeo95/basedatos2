-- ===========================================
-- CREACIÓN DE TABLAS EN LA BASE DE DATOS DE STAGING
-- Autor: Carlos Arturo Gómez Jiménez
-- Fecha: 30 marzo 2025
-- ===========================================

CREATE TABLE Staging.dim_cliente (
  ID_cliente INT PRIMARY KEY,
  nombre_cliente VARCHAR(50),
  nombre_contacto VARCHAR(30),
  apellido_contacto VARCHAR(30),
  telefono VARCHAR(15),
  ciudad VARCHAR(50),
  pais VARCHAR(50)
);

CREATE TABLE Staging.dim_oficina (
  ID_oficina INT PRIMARY KEY,
  ciudad VARCHAR(30),
  pais VARCHAR(50)
);

CREATE TABLE Staging.dim_empleado (
  ID_empleado INT PRIMARY KEY,
  nombre VARCHAR(50),
  apellido1 VARCHAR(50),
  apellido2 VARCHAR(50),
  puesto VARCHAR(50),
  ID_oficina INT,
  FOREIGN KEY (ID_oficina) REFERENCES Staging.dim_oficina(ID_oficina)
);

CREATE TABLE Staging.dim_producto (
  ID_producto INT PRIMARY KEY,
  CodigoProducto VARCHAR(15),
  nombre VARCHAR(70),
  Categoria INT,
  precio_venta DECIMAL(15, 2),
  proveedor VARCHAR(50)
);

CREATE TABLE Staging.dim_categoria (
  Id_Categoria INT PRIMARY KEY,
  Desc_Categoria VARCHAR(50)
);

CREATE TABLE Staging.dim_tiempo (
  fecha DATE PRIMARY KEY,
  dia INT,
  mes INT,
  ano INT,
  trimestre INT
);

CREATE TABLE Staging.fact_pedido (
  ID_pedido INT PRIMARY KEY,
  ID_cliente INT,
  ID_empleado INT,
  ID_producto INT,
  ID_oficina INT,
  fecha_pedido DATE,
  cantidad INT,
  precio_unidad DECIMAL(15, 2),
  total DECIMAL(15, 2),
  estado VARCHAR(15),
  fecha_esperada DATE,
  fecha_entrega DATE,
  FOREIGN KEY (ID_cliente) REFERENCES Staging.dim_cliente(ID_cliente),
  FOREIGN KEY (ID_empleado) REFERENCES Staging.dim_empleado(ID_empleado),
  FOREIGN KEY (ID_producto) REFERENCES Staging.dim_producto(ID_producto),
  FOREIGN KEY (ID_oficina) REFERENCES Staging.dim_oficina(ID_oficina)
);
