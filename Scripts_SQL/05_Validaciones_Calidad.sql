-- ===========================================
-- VALIDACIONES DE CALIDAD Y CONSISTENCIA DE DATOS EN EL DATA MART
-- Autor: Carlos Arturo Gómez Jiménez
-- Fecha: 30 marzo 2025
-- ===========================================


-- ===========================================
-- 1. Validación de cantidad de registros por tabla
-- ===========================================

SELECT 'dim_cliente' AS tabla, COUNT(*) AS total_registros FROM dm_jardineria.dim_cliente
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


-- ===========================================
-- 2. Verificación de valores nulos críticos en fact_pedido
-- ===========================================

SELECT COUNT(*) AS registros_con_nulos
FROM dm_jardineria.fact_pedido
WHERE ID_cliente IS NULL
   OR ID_producto IS NULL
   OR ID_empleado IS NULL
   OR ID_oficina IS NULL
   OR fecha_pedido IS NULL
   OR cantidad IS NULL
   OR precio_unidad IS NULL
   OR total IS NULL;


-- ===========================================
-- 3. Verificación de integridad referencial entre hechos y dimensiones
-- ===========================================

-- Clientes
SELECT COUNT(*) AS sin_referencia_cliente
FROM dm_jardineria.fact_pedido fp
LEFT JOIN dm_jardineria.dim_cliente dc ON fp.ID_cliente = dc.ID_cliente
WHERE dc.ID_cliente IS NULL;

-- Productos
SELECT COUNT(*) AS sin_referencia_producto
FROM dm_jardineria.fact_pedido fp
LEFT JOIN dm_jardineria.dim_producto dp ON fp.ID_producto = dp.ID_producto
WHERE dp.ID_producto IS NULL;

-- Empleados
SELECT COUNT(*) AS sin_referencia_empleado
FROM dm_jardineria.fact_pedido fp
LEFT JOIN dm_jardineria.dim_empleado de ON fp.ID_empleado = de.ID_empleado
WHERE de.ID_empleado IS NULL;

-- Oficinas
SELECT COUNT(*) AS sin_referencia_oficina
FROM dm_jardineria.fact_pedido fp
LEFT JOIN dm_jardineria.dim_oficina dof ON fp.ID_oficina = dof.ID_oficina
WHERE dof.ID_oficina IS NULL;

-- Tiempo
SELECT COUNT(*) AS sin_referencia_fecha
FROM dm_jardineria.fact_pedido fp
LEFT JOIN dm_jardineria.dim_tiempo dt ON fp.fecha_pedido = dt.fecha
WHERE dt.fecha IS NULL;


-- ===========================================
-- 4. Detección de valores atípicos
-- ===========================================

SELECT COUNT(*) AS registros_atipicos
FROM dm_jardineria.fact_pedido
WHERE cantidad <= 0
   OR total <= 0
   OR cantidad > 1000
   OR total > 50000;


-- ===========================================
-- 5. Validación de rango lógico de fechas
-- ===========================================

SELECT COUNT(*) AS fechas_fuera_rango
FROM dm_jardineria.fact_pedido
WHERE fecha_pedido < '2020-01-01'
   OR fecha_pedido > CURRENT_DATE;


-- ===========================================
-- FIN DE LAS VALIDACIONES DE CALIDAD
-- ===========================================

-- Si todos los conteos retornan 0, la carga se considera exitosa y los datos son válidos.
