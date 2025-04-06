-- ===========================================
-- EXTRACCIÓN DE DATOS DESDE LA BASE ORIGEN HACIA STAGING
-- Autor: Carlos Arturo Gómez Jiménez
-- Fecha: 30 marzo 2025
-- ===========================================

-- Inserción en Dimensión Cliente
INSERT INTO Staging.dim_cliente (ID_cliente, nombre_cliente, nombre_contacto, apellido_contacto, telefono, ciudad, pais)
SELECT ID_cliente, nombre_cliente, nombre_contacto, apellido_contacto, telefono, ciudad, pais
FROM Jardineria.cliente;

-- Inserción en Dimensión Oficina
INSERT INTO Staging.dim_oficina (ID_oficina, ciudad, pais)
SELECT ID_oficina, ciudad, pais
FROM Jardineria.oficina;

-- Inserción en Dimensión Empleado
INSERT INTO Staging.dim_empleado (ID_empleado, nombre, apellido1, apellido2, puesto, ID_oficina)
SELECT ID_empleado, nombre, apellido1, apellido2, puesto, ID_oficina
FROM Jardineria.empleado;

-- Inserción en Dimensión Producto
INSERT INTO Staging.dim_producto (ID_producto, CodigoProducto, nombre, Categoria, precio_venta, proveedor)
SELECT ID_producto, CodigoProducto, nombre, Categoria, precio_venta, proveedor
FROM Jardineria.producto;

-- Inserción en Dimensión Categoría
INSERT INTO Staging.dim_categoria (Id_Categoria, Desc_Categoria)
SELECT Id_Categoria, Desc_Categoria
FROM Jardineria.Categoria_producto;

-- Inserción en Dimensión Tiempo (extraída de pedidos)
INSERT INTO Staging.dim_tiempo (fecha, dia, mes, ano, trimestre)
SELECT DISTINCT 
    fecha_pedido AS fecha,
    DAY(fecha_pedido) AS dia,
    MONTH(fecha_pedido) AS mes,
    YEAR(fecha_pedido) AS ano,
    DATEPART(QUARTER, fecha_pedido) AS trimestre
FROM Jardineria.pedido
WHERE fecha_pedido IS NOT NULL;

-- Inserción en Tabla de Hechos: fact_pedido
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
