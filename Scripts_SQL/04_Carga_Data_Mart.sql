-- ===========================================
-- CARGA FINAL AL DATA MART (dm_jardineria)
-- Autor: Carlos Arturo Gómez Jiménez
-- Fecha: 30 marzo 2025
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

-- Carga de Tabla de Hechos: fact_pedido
INSERT INTO dm_jardineria.fact_pedido (
  ID_pedido, ID_cliente, ID_empleado, ID_producto, ID_oficina,
  fecha_pedido, cantidad, precio_unidad, total, estado, fecha_esperada, fecha_entrega
)
SELECT 
  ID_pedido, ID_cliente, ID_empleado, ID_producto, ID_oficina,
  fecha_pedido, cantidad, precio_unidad, total, estado, fecha_esperada, fecha_entrega
FROM Staging.fact_pedido;
