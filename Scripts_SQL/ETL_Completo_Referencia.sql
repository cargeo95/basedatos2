-- ===========================================
-- PROCESO ETL - MODELO ESTRELLA PARA JARDINERÍA
-- Autor: Carlos Arturo Gómez Jiménez
-- Fecha: [30 marzo 2025
-- Descripción: Este script crea y llena el entorno de staging,
--              transforma los datos y los carga en el Data Mart.
-- ===========================================


-- ===========================================
-- ===========================================
-- CREACIÓN DE TABLAS EN LA BASE DE DATOS DE STAGING
-- ===========================================
-- ===========================================

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


CREATE TABLE Staging.dim_cliente (
  ID_cliente INT PRIMARY KEY,
  nombre_cliente VARCHAR(50),
  nombre_contacto VARCHAR(30),
  apellido_contacto VARCHAR(30),
  telefono VARCHAR(15),
  ciudad VARCHAR(50),
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


CREATE TABLE Staging.dim_oficina (
  ID_oficina INT PRIMARY KEY,
  ciudad VARCHAR(30),
  pais VARCHAR(50)
);

CREATE TABLE Staging.dim_tiempo (
  fecha DATE PRIMARY KEY,
  dia INT,
  mes INT,
  ano INT,
  trimestre INT
);

CREATE TABLE Staging.dim_categoria (
  Id_Categoria INT PRIMARY KEY,
  Desc_Categoria VARCHAR(50)
);


-- ===========================================
-- ===========================================
-- EXTRACCIÓN DE DATOS DESDE LA BASE ORIGEN
-- ===========================================
-- ===========================================



-- Dimensión Cliente
INSERT INTO Staging.dim_cliente (ID_cliente, nombre_cliente, nombre_contacto, apellido_contacto, telefono, ciudad, pais)
SELECT ID_cliente, nombre_cliente, nombre_contacto, apellido_contacto, telefono, ciudad, pais
FROM Jardineria.cliente;

-- Dimensión Empleado
INSERT INTO Staging.dim_empleado (ID_empleado, nombre, apellido1, apellido2, puesto, ID_oficina)
SELECT ID_empleado, nombre, apellido1, apellido2, puesto, ID_oficina
FROM Jardineria.empleado;

-- Dimensión Producto
INSERT INTO Staging.dim_producto (ID_producto, CodigoProducto, nombre, Categoria, precio_venta, proveedor)
SELECT ID_producto, CodigoProducto, nombre, Categoria, precio_venta, proveedor
FROM Jardineria.producto;

-- Dimensión Oficina
INSERT INTO Staging.dim_oficina (ID_oficina, ciudad, pais)
SELECT ID_oficina, ciudad, pais
FROM Jardineria.oficina;

-- Dimensión Categoría
INSERT INTO Staging.dim_categoria (Id_Categoria, Desc_Categoria)
SELECT Id_Categoria, Desc_Categoria
FROM Jardineria.Categoria_producto;

-- Dimensión Tiempo (a partir de las fechas en los pedidos)
-- Nota: DISTINCT para evitar fechas duplicadas
INSERT INTO Staging.dim_tiempo (fecha, dia, mes, ano, trimestre)
SELECT DISTINCT 
    fecha_pedido AS fecha,
    DAY(fecha_pedido) AS dia,
    MONTH(fecha_pedido) AS mes,
    YEAR(fecha_pedido) AS ano,
    DATEPART(QUARTER, fecha_pedido) AS trimestre
FROM Jardineria.pedido
WHERE fecha_pedido IS NOT NULL;

-- Tabla de hechos: fact_pedido
-- Esta tabla integra claves foráneas de las dimensiones y métricas clave
INSERT INTO Staging.fact_pedido (
    ID_pedido, ID_cliente, ID_empleado, ID_producto, ID_oficina,
    fecha_pedido, cantidad, precio_unidad, total, estado, fecha_esperada, fecha_entrega
)
SELECT 
    p.ID_pedido,
    p.ID_cliente,
    c.ID_empleado_rep_ventas,
    dp.ID_producto,
    e.ID_oficina,
    p.fecha_pedido,
    dp.cantidad,
    dp.precio_unidad,
    dp.precio_unidad * dp.cantidad AS total,
    p.estado,
    p.fecha_esperada,
    p.fecha_entrega
FROM Jardineria.pedido p
JOIN Jardineria.detalle_pedido dp ON p.ID_pedido = dp.ID_pedido
JOIN Jardineria.cliente c ON p.ID_cliente = c.ID_cliente
JOIN Jardineria.empleado e ON c.ID_empleado_rep_ventas = e.ID_empleado;


-- VALIDACIÓN DE LOS DATOS EXTRAÍDOS

SELECT COUNT(*) FROM Staging.fact_pedido;
SELECT COUNT(*) FROM Staging.dim_cliente;
SELECT 'Clientes' AS tabla, COUNT(*) AS registros FROM Staging.dim_cliente
UNION ALL
SELECT 'Empleados', COUNT(*) FROM Staging.dim_empleado
UNION ALL
SELECT 'Productos', COUNT(*) FROM Staging.dim_producto
UNION ALL
SELECT 'Oficinas', COUNT(*) FROM Staging.dim_oficina
UNION ALL
SELECT 'Categorías', COUNT(*) FROM Staging.dim_categoria
UNION ALL
SELECT 'Tiempo', COUNT(*) FROM Staging.dim_tiempo;
SELECT 'Pedidos (Hechos)' AS tabla, COUNT(*) AS registros FROM Staging.fact_pedido;



-- ===========================================
-- ===========================================
-- TRANSFORMACIÓN DE DATOS
-- ===========================================
-- ===========================================


-- Limpieza de espacios en blanco en los nombres de clientes
-- Cliente: limpieza de espacios y conversión a mayúsculas
UPDATE Staging.dim_cliente
SET nombre_cliente = UPPER(LTRIM(RTRIM(nombre_cliente))),
    nombre_contacto = UPPER(LTRIM(RTRIM(nombre_contacto))),
    apellido_contacto = UPPER(LTRIM(RTRIM(apellido_contacto))),
    ciudad = UPPER(LTRIM(RTRIM(ciudad))),
    pais = UPPER(LTRIM(RTRIM(pais)));

-- Empleado: limpieza de espacios y estandarización de nombre/apellidos
UPDATE Staging.dim_empleado
SET nombre = UPPER(LTRIM(RTRIM(nombre))),
    apellido1 = UPPER(LTRIM(RTRIM(apellido1))),
    apellido2 = UPPER(LTRIM(RTRIM(apellido2))),
    puesto = UPPER(LTRIM(RTRIM(puesto)));

-- Producto: limpieza de campos textuales
UPDATE Staging.dim_producto
SET nombre = UPPER(LTRIM(RTRIM(nombre))),
    proveedor = UPPER(LTRIM(RTRIM(proveedor)));

-- Oficina: limpieza de campos de localización
UPDATE Staging.dim_oficina
SET ciudad = UPPER(LTRIM(RTRIM(ciudad))),
    pais = UPPER(LTRIM(RTRIM(pais)));

-- Categoría: estandarización de nombres
UPDATE Staging.dim_categoria
SET Desc_Categoria = UPPER(LTRIM(RTRIM(Desc_Categoria)));

-- (Opcional) Redondeo de precios en productos
UPDATE Staging.dim_producto
SET precio_venta = ROUND(precio_venta, 2);



-- ===========================================
-- ===========================================
-- CARGA FINAL AL DATA MART
-- ===========================================
-- ===========================================



-- Carga de Dimensión Cliente
INSERT INTO dm_jardineria.dim_cliente (
  ID_cliente, nombre_cliente, nombre_contacto, apellido_contacto, telefono, ciudad, pais
)
SELECT ID_cliente, nombre_cliente, nombre_contacto, apellido_contacto, telefono, ciudad, pais
FROM Staging.dim_cliente;

-- Carga de Dimensión Empleado
INSERT INTO dm_jardineria.dim_empleado (
  ID_empleado, nombre, apellido1, apellido2, puesto, ID_oficina
)
SELECT ID_empleado, nombre, apellido1, apellido2, puesto, ID_oficina
FROM Staging.dim_empleado;

-- Carga de Dimensión Producto
INSERT INTO dm_jardineria.dim_producto (
  ID_producto, CodigoProducto, nombre, Categoria, precio_venta, proveedor
)
SELECT ID_producto, CodigoProducto, nombre, Categoria, precio_venta, proveedor
FROM Staging.dim_producto;

-- Carga de Dimensión Oficina
INSERT INTO dm_jardineria.dim_oficina (
  ID_oficina, ciudad, pais
)
SELECT ID_oficina, ciudad, pais
FROM Staging.dim_oficina;

-- Carga de Dimensión Categoría
INSERT INTO dm_jardineria.dim_categoria (
  Id_Categoria, Desc_Categoria
)
SELECT Id_Categoria, Desc_Categoria
FROM Staging.dim_categoria;

-- Carga de Dimensión Tiempo
INSERT INTO dm_jardineria.dim_tiempo (
  fecha, dia, mes, ano, trimestre
)
SELECT fecha, dia, mes, ano, trimestre
FROM Staging.dim_tiempo;

-- Carga de Hechos de Pedido
INSERT INTO dm_jardineria.fact_pedido (
  ID_pedido, ID_cliente, ID_empleado, ID_producto, ID_oficina,
  fecha_pedido, cantidad, precio_unidad, total, estado, fecha_esperada, fecha_entrega
)
SELECT 
  ID_pedido, ID_cliente, ID_empleado, ID_producto, ID_oficina,
  fecha_pedido, cantidad, precio_unidad, total, estado, fecha_esperada, fecha_entrega
FROM Staging.fact_pedido;


-- ===========================================
-- ===========================================
-- VALIDACIÓN POST-CARGA EN EL DATA MART
-- ===========================================
-- ===========================================


-- Validación rápida de cantidad de registros por tabla
SELECT 'dim_cliente' AS tabla, COUNT(*) FROM dm_jardineria.dim_cliente
UNION ALL
SELECT 'dim_empleado', COUNT(*) FROM dm_jardineria.dim_empleado
UNION ALL
SELECT 'dim_producto', COUNT(*) FROM dm_jardineria.dim_producto
UNION ALL
SELECT 'dim_oficina', COUNT(*) FROM dm_jardineria.dim_oficina
UNION ALL
SELECT 'dim_categoria', COUNT(*) FROM dm_jardineria.dim_categoria
UNION ALL
SELECT 'dim_tiempo', COUNT(*) FROM dm_jardineria.dim_tiempo
UNION ALL
SELECT 'fact_pedido', COUNT(*) FROM dm_jardineria.fact_pedido;
