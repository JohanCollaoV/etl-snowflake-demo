
USE DATABASE VENTAS_DB;
USE SCHEMA PUBLIC;

-- 1. Poblar DIM_CUSTOMERS
INSERT INTO DIM_CUSTOMERS (customer_id, customer_name, customer_email, customer_city, customer_segment)
SELECT DISTINCT 
    customer_id,
    customer_name,
    customer_email,
    customer_city,
    customer_segment
FROM STG_TEMP_SALES;

-- 2. Poblar DIM_PRODUCTS
INSERT INTO DIM_PRODUCTS (product_id, product_name, category, brand)
SELECT DISTINCT 
    product_id,
    product_name,
    category,
    brand
FROM STG_TEMP_SALES;

-- 3. Verificar
SELECT COUNT(*) FROM DIM_CUSTOMERS;
SELECT COUNT(*) FROM DIM_PRODUCTS;