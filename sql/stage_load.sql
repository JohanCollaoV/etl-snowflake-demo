
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

-- 2. Crear External Stage (via STORAGE_INTEGRATION, recomendado para produccion)
-- PASO 1: Crear la integracion de almacenamiento (ejecutar en Snowflake):
--
--   CREATE OR REPLACE STORAGE_INTEGRATION s3_int
--       TYPE = EXTERNAL_STAGE
--       STORAGE_PROVIDER = 'S3'
--       ENABLED = TRUE
--       STORAGE_AWS_ROLE_ARN = '<ARN_DEL_ROL_IAM>'
--       STORAGE_ALLOWED_LOCATIONS = ('s3://etl-snowflake-demo-johan/');
--
-- PASO 2: Crear el stage usando la integracion:
--
--   CREATE OR REPLACE STAGE my_s3_stage
--       URL = 's3://etl-snowflake-demo-johan/raw/'
--       STORAGE_INTEGRATION = s3_int
--       FILE_FORMAT = (TYPE = CSV FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);
--
-- Alternativa para desarrollo (NO USAR EN PRODUCCION):
--   Sustituir <AWS_ACCESS_KEY> y <AWS_SECRET_KEY> por variables de entorno o un archivo .env

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