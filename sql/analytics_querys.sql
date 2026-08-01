
USE DATABASE VENTAS_DB;
USE SCHEMA PUBLIC;

-- 1. Ventas por región
SELECT region, COUNT(*) as total_ventas, SUM(total_amount) as monto
FROM FACT_SALES
GROUP BY region
ORDER BY monto DESC;

-- 2. Ventas por categoría de producto
SELECT 
    p.category,
    COUNT(*) AS total_ventas,
    SUM(f.total_amount) AS monto_total
FROM FACT_SALES f
JOIN DIM_PRODUCTS p ON f.product_id = p.product_id
GROUP BY p.category
ORDER BY monto_total DESC;

-- 3. Clientes con más compras
SELECT 
    c.customer_name,
    c.customer_segment,
    SUM(f.total_amount) AS total_gastado
FROM FACT_SALES f
JOIN DIM_CUSTOMERS c ON f.customer_id = c.customer_id
GROUP BY c.customer_name, c.customer_segment
ORDER BY total_gastado DESC
LIMIT 10;

-- 4. Ventas por segmento
SELECT 
    c.customer_segment,
    COUNT(*) AS total_ventas,
    SUM(f.total_amount) AS monto_total
FROM FACT_SALES f
JOIN DIM_CUSTOMERS c ON f.customer_id = c.customer_id
GROUP BY c.customer_segment
ORDER BY monto_total DESC;

-- 5. Top 5 productos
SELECT 
    p.product_name,
    p.brand,
    SUM(f.quantity) AS cantidad_total,
    SUM(f.total_amount) AS monto_total
FROM FACT_SALES f
JOIN DIM_PRODUCTS p ON f.product_id = p.product_id
GROUP BY p.product_name, p.brand
ORDER BY cantidad_total DESC
LIMIT 5;