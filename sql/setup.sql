-- ============================================
-- CONFIGURACIÓN INICIAL
-- ============================================

-- 1. Crear Virtual Warehouse
CREATE WAREHOUSE IF NOT EXISTS COMPUTE_WH 
WITH WAREHOUSE_SIZE = 'X-SMALL' 
AUTO_SUSPEND = 300 
AUTO_RESUME = TRUE;

-- 2. Crear Base de Datos
CREATE DATABASE IF NOT EXISTS VENTAS_DB;

-- 3. Usar la base de datos y schema
USE DATABASE VENTAS_DB;
CREATE SCHEMA IF NOT EXISTS PUBLIC;
USE SCHEMA PUBLIC;

-- 4. Crear tabla de prueba (para verificar configuración)
CREATE OR REPLACE TABLE TEST_TABLE (
    id INTEGER,
    nombre VARCHAR(100),
    fecha DATE
);

INSERT INTO TEST_TABLE VALUES 
    (1, 'Prueba 1', CURRENT_DATE()),
    (2, 'Prueba 2', CURRENT_DATE());

-- 5. Verificar
SELECT * FROM TEST_TABLE;
SELECT CURRENT_VERSION();
SELECT CURRENT_WAREHOUSE();