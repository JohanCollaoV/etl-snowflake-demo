# ETL Snowflake Demo

Pipeline ETL end-to-end de datos de ventas de e-commerce. Genera datos ficticios, los ingesta a AWS S3, los carga en Snowflake y los transforma para analitica.

## Stack Tecnologico

| Capa | Tecnologia | Estado |
|------|------------|--------|
| Infraestructura | Terraform | Completado |
| Data Lake | AWS S3 | Completado |
| Procesamiento | Python + Pandas | Completado |
| Data Warehouse | Snowflake | Completado |
| Orquestacion | Apache Airflow | Planificado |
| Transformacion | dbt | Planificado |
| Visualizacion | Looker Studio | Planificado |
| CI/CD | GitHub Actions | Planificado |

## Requisitos

- Python 3.10+
- AWS CLI configurado
- Cuenta de Snowflake
- Terraform (opcional, para infraestructura)

## Instalacion

```bash
git clone git@github.com:JohanCollaoV/etl-snowflake-demo.git
cd etl-snowflake-demo
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# Editar .env con tus credenciales de AWS y Snowflake
```

## Uso

```bash
# Crear bucket S3
cd terraform && terraform init && terraform apply -auto-approve

# Generar datos y subir a S3
python scripts/ingest/ingest_to_s3.py

# Verificar en S3
aws s3 ls s3://etl-snowflake-demo-johan/raw/

# Destruir infraestructura al finalizar
cd terraform && terraform destroy -auto-approve
```

## Flujo del Pipeline

```
generate_sales_data() → S3 (raw/sales_data.csv) → External Stage → STG_TEMP_SALES → FACT_SALES → DIM_PRODUCTS, DIM_CUSTOMERS
```

## Modelo de Datos

### FACT_SALES (Hechos)

| Columna | Tipo | Descripcion |
|---------|------|-------------|
| sale_id | VARCHAR(50) | ID unico de venta (PK) |
| order_date | DATE | Fecha de la venta |
| customer_id | VARCHAR(50) | FK a DIM_CUSTOMERS |
| product_id | VARCHAR(50) | FK a DIM_PRODUCTS |
| quantity | INTEGER | Cantidad vendida |
| unit_price | DECIMAL(10,2) | Precio unitario |
| total_amount | DECIMAL(10,2) | Monto total |
| payment_method | VARCHAR(50) | Metodo de pago |
| region | VARCHAR(100) | Region geografica |
| created_at | TIMESTAMP | Fecha de ingesta |

### DIM_PRODUCTS

| Columna | Tipo | Descripcion |
|---------|------|-------------|
| product_id | VARCHAR(50) | ID del producto (PK) |
| product_name | VARCHAR(200) | Nombre del producto |
| category | VARCHAR(100) | Categoria |
| brand | VARCHAR(100) | Marca |
| created_at | TIMESTAMP | Fecha de ingesta |

### DIM_CUSTOMERS

| Columna | Tipo | Descripcion |
|---------|------|-------------|
| customer_id | VARCHAR(50) | ID del cliente (PK) |
| customer_name | VARCHAR(200) | Nombre del cliente |
| customer_email | VARCHAR(200) | Email del cliente |
| customer_city | VARCHAR(100) | Ciudad |
| customer_segment | VARCHAR(50) | Segmento (Gold/Silver/Bronze) |
| created_at | TIMESTAMP | Fecha de ingesta |

## Consultas Rapidas (Snowflake)

```sql
-- Ventas por region
SELECT region, COUNT(*) AS total_ventas, SUM(total_amount) AS monto
FROM FACT_SALES GROUP BY region ORDER BY monto DESC;

-- Top 5 productos
SELECT p.product_name, p.brand, SUM(f.quantity) AS cantidad_total
FROM FACT_SALES f
JOIN DIM_PRODUCTS p ON f.product_id = p.product_id
GROUP BY p.product_name, p.brand ORDER BY cantidad_total DESC LIMIT 5;

-- Clientes con mas compras
SELECT c.customer_name, c.customer_segment, SUM(f.total_amount) AS total_gastado
FROM FACT_SALES f
JOIN DIM_CUSTOMERS c ON f.customer_id = c.customer_id
GROUP BY c.customer_name, c.customer_segment ORDER BY total_gastado DESC LIMIT 10;
```

## Gestion de Costos

```sql
-- Suspender warehouse (se auto-suspende a los 5 min)
ALTER WAREHOUSE COMPUTE_WH SUSPEND;
```

```bash
# Destruir bucket S3 al finalizar
cd terraform && terraform destroy -auto-approve
```

## Documentacion

| Documento | Contenido |
|-----------|-----------|
| [docs/architecture.md](docs/architecture.md) | Arquitectura y flujo del pipeline |
| [docs/deployment.md](docs/deployment.md) | Infraestructura y despliegue |
| [docs/setup.md](docs/setup.md) | Configuracion y dependencias |
| [docs/progress.md](docs/progress.md) | Log de hitos del proyecto |
| [AGENTS.md](AGENTS.md) | Instrucciones para agentes de IA |

## Licencia

MIT
