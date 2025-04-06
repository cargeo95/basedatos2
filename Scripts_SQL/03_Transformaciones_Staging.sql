-- ===========================================
-- TRANSFORMACIONES DE DATOS EN EL ENTORNO DE STAGING
-- Autor: Carlos Arturo Gómez Jiménez
-- Fecha: 30 marzo 2025
-- ===========================================

-- Limpieza y estandarización en Dimensión Cliente
UPDATE Staging.dim_cliente
SET nombre_cliente = UPPER(LTRIM(RTRIM(nombre_cliente))),
    nombre_contacto = UPPER(LTRIM(RTRIM(nombre_contacto))),
    apellido_contacto = UPPER(LTRIM(RTRIM(apellido_contacto))),
    ciudad = UPPER(LTRIM(RTRIM(ciudad))),
    pais = UPPER(LTRIM(RTRIM(pais)));

-- Limpieza y estandarización en Dimensión Empleado
UPDATE Staging.dim_empleado
SET nombre = UPPER(LTRIM(RTRIM(nombre))),
    apellido1 = UPPER(LTRIM(RTRIM(apellido1))),
    apellido2 = UPPER(LTRIM(RTRIM(apellido2))),
    puesto = UPPER(LTRIM(RTRIM(puesto)));

-- Limpieza y estandarización en Dimensión Producto
UPDATE Staging.dim_producto
SET nombre = UPPER(LTRIM(RTRIM(nombre))),
    proveedor = UPPER(LTRIM(RTRIM(proveedor)));

-- Limpieza y estandarización en Dimensión Oficina
UPDATE Staging.dim_oficina
SET ciudad = UPPER(LTRIM(RTRIM(ciudad))),
    pais = UPPER(LTRIM(RTRIM(pais)));

-- Limpieza y estandarización en Dimensión Categoría
UPDATE Staging.dim_categoria
SET Desc_Categoria = UPPER(LTRIM(RTRIM(Desc_Categoria)));

-- Redondeo de precios en Dimensión Producto
UPDATE Staging.dim_producto
SET precio_venta = ROUND(precio_venta, 2);
