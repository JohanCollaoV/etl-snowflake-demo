# Progress Log — ETL Snowflake Demo

> Documento de sesión para retomar el proyecto sin perder contexto.

---

## 1. Estado Actual del Proyecto

### Infraestructura (AWS + Terraform)

| Recurso | Estado |
|---|---|
| Bucket S3 `etl-snowflake-demo-johan` | Creado con Terraform |
| Carpetas `raw/`, `processed/`, `curated/` | Creadas |
| `raw/sales_data.csv` | Subido (500 registros) |

### Snowflake (`VENTAS_DB.PUBLIC`)

| Tabla | Estado | Datos |
|---|---|---|
| `FACT_SALES` | Creada | ✅ 500 registros |
| `DIM_PRODUCTS` | Creada | ❌ Vacía |
| `DIM_CUSTOMERS` | Creada | ❌ Vacía |
| `STG_TEMP_SALES` | Creada y eliminada | — |
| `STG_SALES` | Creada y eliminada | — |

### Stage externo

- **Nombre:** `my_s3_stage`
- **URL:** `s3://etl-snowflake-demo-johan/raw/`
- **Creado con credenciales AWS inline** (ver nota ⚠️)

### Esquema actual de FACT_SALES

```
sale_id         VARCHAR(50) PK
order_date      DATE
customer_id     VARCHAR(50)
product_id      VARCHAR(50)
quantity        INTEGER
unit_price      DECIMAL(10,2)
total_amount    DECIMAL(10,2)
payment_method  VARCHAR(50)
region          VARCHAR(100)
created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
```

### Pipeline actual

```
ingest_to_s3.py (genera datos → S3 raw)
       ↓
COPY INTO (STG_TEMP_SALES → FACT_SALES)
       ↓
(Pendiente: poblar dimensiones y dashboard)
```

---

## 2. Próximos Pasos (Priorizados)

### [ ] Paso 1 — Poblar dimensiones

```sql
USE DATABASE VENTAS_DB;
USE SCHEMA PUBLIC;

INSERT INTO DIM_PRODUCTS (product_id, product_name, category, brand)
SELECT DISTINCT product_id, product_name, category, brand
FROM FACT_SALES;

INSERT INTO DIM_CUSTOMERS (customer_id, customer_name, customer_email, customer_city, customer_segment)
SELECT DISTINCT customer_id, customer_name, customer_email, customer_city, customer_segment
FROM FACT_SALES;
```

> `FACT_SALES` tiene los datos descriptivos (customer_name, product_name, etc.) porque se cargó desde el CSV completo. Si en el futuro FACT_SALES solo tiene los FK, poblar desde STG_TEMP_SALES o directamente desde el stage.

### [ ] Paso 2 — Dashboard (Looker Studio)

1. Conectar Looker Studio a Snowflake
2. Tabla: `FACT_SALES` con JOIN a `DIM_PRODUCTS` y `DIM_CUSTOMERS`
3. Métricas sugeridas: ventas totales por producto, categoría, región, mes; top clientes por segmento; método de pago

### [ ] Paso 3 — dbt

Migrar los SQL actuales a un proyecto dbt:
- `models/staging/stg_sales.sql`
- `models/dim/dim_products.sql`, `dim_customers.sql`
- `models/fact/fact_sales.sql`
- `schema.yml` con tests y documentación

### [ ] Paso 4 — Airflow

DAG que automatice:
1. `ingest_to_s3.py` (generar datos → S3)
2. `COPY INTO` (S3 → staging)
3. `dbt run` (transformaciones)
4. `dbt test` (opcional)

---

## 3. Comandos Útiles (Retomar Sesión)

### Setup local

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env   # editar credenciales
```

### Infraestructura

```bash
cd terraform && terraform init && terraform apply -auto-approve
```

### Generar datos y subir a S3

```bash
python scripts/ingest/ingest_to_s3.py
```

---

## 4. ⚠️ Notas Técnicas

### Credenciales AWS en el stage

El stage `my_s3_stage` fue creado con `CREDENTIALS = (AWS_KEY_ID = '...' AWS_SECRET_KEY = '...')`. Esto expone las claves en el historial de consultas de Snowflake. Para producción usar **STORAGE_INTEGRATION**:

```sql
CREATE OR REPLACE STORAGE_INTEGRATION s3_int
TYPE = EXTERNAL_STAGE
STORAGE_PROVIDER = 'S3'
ENABLED = TRUE
STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::<account>:role/<role-name>'
STORAGE_ALLOWED_LOCATIONS = ('s3://etl-snowflake-demo-johan/');

CREATE OR REPLACE STAGE my_s3_stage
URL = 's3://etl-snowflake-demo-johan/raw/'
STORAGE_INTEGRATION = s3_int
FILE_FORMAT = (TYPE = CSV FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);
```

### Limpieza de costos

El bucket S3 se elimina con `terraform destroy` al finalizar cada sesión. El warehouse `COMPUTE_WH` tiene `AUTO_SUSPEND = 300` (5 min).

---

## 5. Diagrama del Pipeline (Completo)

```
ingest_to_s3.py
      ↓
S3 (raw/sales_data.csv)
      ↓  (COPY INTO)
STG_TEMP_SALES
      ↓  (INSERT)
FACT_SALES ──→ DIM_PRODUCTS
      │          DIM_CUSTOMERS
      ↓
Looker Studio (Dashboard)
```

---

*Última actualización: 2026-07-28*
