-- ===========================================
-- PRUEBA 1: Detección de registros duplicados en la tabla de hechos
-- ===========================================

SELECT ID_cliente, ID_producto, ID_empleado, ID_oficina, fecha_pedido, COUNT(*) AS conteo_duplicados
FROM fact_pedido
GROUP BY ID_cliente, ID_producto, ID_empleado, ID_oficina, fecha_pedido
HAVING COUNT(*) > 1;

-- ===========================================
-- PRUEBA 2: Validación de valores nulos críticos
-- ===========================================

SELECT COUNT(*) AS cantidad_nulos
FROM fact_pedido
WHERE ID_cliente IS NULL
   OR ID_producto IS NULL
   OR ID_empleado IS NULL
   OR ID_oficina IS NULL
   OR fecha_pedido IS NULL
   OR cantidad_vendida IS NULL
   OR total_venta IS NULL;

-- ===========================================
-- PRUEBA 3: Verificación de claves primarias únicas
-- ===========================================

SELECT ID_pedido, COUNT(*) AS repeticiones
FROM fact_pedido
GROUP BY ID_pedido
HAVING COUNT(*) > 1;

-- ===========================================
-- PRUEBA 4: Integridad referencial con dimensiones
-- ===========================================

-- Clientes
SELECT COUNT(*) AS sin_cliente
FROM fact_pedido fp
LEFT JOIN dim_cliente dc ON fp.ID_cliente = dc.ID_cliente
WHERE dc.ID_cliente IS NULL;

-- Productos
SELECT COUNT(*) AS sin_producto
FROM fact_pedido fp
LEFT JOIN dim_producto dp ON fp.ID_producto = dp.ID_producto
WHERE dp.ID_producto IS NULL;

-- Empleados
SELECT COUNT(*) AS sin_empleado
FROM fact_pedido fp
LEFT JOIN dim_empleado de ON fp.ID_empleado = de.ID_empleado
WHERE de.ID_empleado IS NULL;

-- Oficinas
SELECT COUNT(*) AS sin_oficina
FROM fact_pedido fp
LEFT JOIN dim_oficina dof ON fp.ID_oficina = dof.ID_oficina
WHERE dof.ID_oficina IS NULL;

-- Tiempo
SELECT COUNT(*) AS sin_fecha
FROM fact_pedido fp
LEFT JOIN dim_tiempo dt ON fp.fecha_pedido = dt.fecha
WHERE dt.fecha IS NULL;

-- ===========================================
-- PRUEBA 5: Verificación de valores atípicos
-- ===========================================

SELECT COUNT(*) AS registros_atipicos
FROM fact_pedido
WHERE cantidad_vendida <= 0
   OR total_venta <= 0
   OR cantidad_vendida > 1000
   OR total_venta > 50000;

-- ===========================================
-- PRUEBA 6: Rango lógico de fechas
-- ===========================================

SELECT COUNT(*) AS fechas_fuera_rango
FROM fact_pedido
WHERE fecha_pedido < '2020-01-01' OR fecha_pedido > CURRENT_DATE;


-- ===========================================
-- PRUEBA 7: Valores fuera de catálogo
-- (Verifica que la categoría del producto exista en la dimensión categoría)
-- ===========================================

SELECT COUNT(*) AS productos_sin_categoria
FROM dim_producto p
LEFT JOIN dim_categoria c ON p.Categoria = c.Id_Categoria
WHERE c.Id_Categoria IS NULL;


-- ===========================================
-- PRUEBA 8: Verificación de formatos (nombres en mayúsculas sin espacios residuales)
-- ===========================================

SELECT COUNT(*) AS nombres_malos
FROM dim_cliente
WHERE nombre_cliente <> UPPER(LTRIM(RTRIM(nombre_cliente)));


-- ===========================================
-- PRUEBA 9: Fechas de entrega futuras (consistencia de negocio)
-- ===========================================

SELECT COUNT(*) AS entregas_futuras
FROM fact_pedido
WHERE fecha_entrega > CURRENT_DATE;

