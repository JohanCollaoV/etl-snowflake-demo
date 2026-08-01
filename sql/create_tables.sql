
USE DATABASE VENTAS_DB;
USE SCHEMA PUBLIC;

-- Tabla de Hechos
CREATE OR REPLACE TABLE FACT_SALES (
    sale_id VARCHAR(50) PRIMARY KEY,
    order_date DATE,
    customer_id VARCHAR(50),
    product_id VARCHAR(50),
    quantity INTEGER,
    unit_price DECIMAL(10,2),
    total_amount DECIMAL(10,2),
    payment_method VARCHAR(50),
    region VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- Dimensiones
CREATE OR REPLACE TABLE DIM_PRODUCTS (
    product_id VARCHAR(50) PRIMARY KEY,
    product_name VARCHAR(200),
    category VARCHAR(100),
    brand VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE DIM_CUSTOMERS (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_name VARCHAR(200),
    customer_email VARCHAR(200),
    customer_city VARCHAR(100),
    customer_segment VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- Tabla Staging (para carga)
CREATE OR REPLACE TABLE STG_SALES LIKE FACT_SALES;

SHOW TABLES;