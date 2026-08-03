
-- ============================================
-- STAGE LOAD — VERSION DESARROLLO (Standard Edition)
-- ============================================
-- Este archivo usa CREDENTIALS inline porque Snowflake Standard
-- no soporta STORAGE_INTEGRATION (requiere Enterprise+).
-- Para produccion usar: sql/stage_load.sql

USE DATABASE VENTAS_DB;
USE SCHEMA PUBLIC;

-- 1. Crear tabla temporal con todas las columnas del archivo
CREATE OR REPLACE TABLE STG_TEMP_SALES (
    sale_id VARCHAR(50),
    order_date DATE,
    customer_id VARCHAR(50),
    customer_name VARCHAR(200),
    customer_email VARCHAR(200),
    customer_city VARCHAR(100),
    customer_segment VARCHAR(50),
    product_id VARCHAR(50),
    product_name VARCHAR(200),
    category VARCHAR(100),
    brand VARCHAR(100),
    quantity INTEGER,
    unit_price DECIMAL(10,2),
    total_amount DECIMAL(10,2),
    payment_method VARCHAR(50),
    region VARCHAR(100)
);

-- 2. Crear External Stage (desarrollo — credenciales inline)
CREATE OR REPLACE STAGE my_s3_stage
URL = 's3://etl-snowflake-demo-johan/raw/'
CREDENTIALS = (AWS_KEY_ID = '<AWS_ACCESS_KEY>' AWS_SECRET_KEY = '<AWS_SECRET_KEY>')
FILE_FORMAT = (TYPE = CSV FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

-- 3. Verificar Stage (debe mostrar sales_data.csv)
LIST @my_s3_stage;

-- 4. Cargar datos a STG_TEMP_SALES
COPY INTO STG_TEMP_SALES
FROM @my_s3_stage/sales_data.csv
FILE_FORMAT = (TYPE = CSV FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

-- 5. Verificar carga (debe mostrar 500)
SELECT COUNT(*) FROM STG_TEMP_SALES;

-- 6. Insertar a FACT_SALES
INSERT INTO FACT_SALES (
    sale_id, order_date, customer_id, product_id, quantity, unit_price, total_amount, payment_method, region
)
SELECT
    sale_id, order_date, customer_id, product_id, quantity, unit_price, total_amount, payment_method, region
FROM STG_TEMP_SALES;

-- 7. Verificar
SELECT COUNT(*) FROM FACT_SALES;
SELECT * FROM FACT_SALES LIMIT 10;
SELECT SUM(total_amount) AS total_ventas FROM FACT_SALES;
