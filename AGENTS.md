# AGENTS.md — Instrucciones para Agentes de IA

## Descripcion del Proyecto

Pipeline ETL end-to-end de datos de ventas de e-commerce. Genera datos ficticios, los ingesta a AWS S3, los carga en Snowflake y los transforma para analitica.

## Stack Tecnologico

- **Ingesta**: Python 3.10+, Pandas, boto3
- **Data Lake**: AWS S3 (capas raw/, processed/, curated/)
- **Data Warehouse**: Snowflake
- **IaC**: Terraform (bucket S3)
- **Orquestacion**: Apache Airflow (planificado)
- **Transformacion**: dbt (planificado)
- **Visualizacion**: Looker Studio (planificado)

## Estructura del Proyecto

```
etl-snowflake-demo/
├── scripts/ingest/ingest_to_s3.py   # Genera datos y los sube a S3
├── sql/
│   ├── setup.sql                    # Warehouse, DB, schema inicial
│   ├── create_tables.sql            # FACT_SALES, DIM_PRODUCTS, DIM_CUSTOMERS
│   ├── stage_load.sql               # External Stage (STORAGE_INTEGRATION, produccion)
│   ├── stage_load_dev.sql           # External Stage (credenciales inline, desarrollo)
│   ├── load_dimensions.sql          # Poblar dims desde staging
│   ├── analytics_querys.sql         # Consultas analiticas
│   └── limpieza.sql                 # Limpieza de tablas temporales
├── terraform/main.tf                # Bucket S3 + versioning + carpetas
├── docs/
│   ├── architecture.md              # Arquitectura y flujo del pipeline
│   ├── deployment.md                # Infraestructura y despliegue
│   ├── setup.md                     # Configuracion y dependencias
│   └── progress.md                  # Log de hitos (no commits)
├── .env.example                     # Template de variables de entorno
├── requirements.txt                 # pandas, boto3, snowflake-connector-python, python-dotenv
├── AGENTS.md                        # Este archivo
└── README.md                        # Documentacion para humanos
```

## Comandos Principales

```bash
# Activar entorno virtual
source venv/bin/activate

# Instalar dependencias
pip install -r requirements.txt

# Ejecutar ingesta de datos a S3
python scripts/ingest/ingest_to_s3.py

# Infraestructura con Terraform
cd terraform && terraform init && terraform apply -auto-approve

# Destruir infraestructura
cd terraform && terraform destroy -auto-approve
```

## Flujo del Pipeline

```
generate_sales_data() → S3 (raw/sales_data.csv) → External Stage → COPY INTO STG_TEMP_SALES → INSERT INTO FACT_SALES → Poblar DIM_PRODUCTS, DIM_CUSTOMERS
```

## Modelo de Datos (Snowflake)

| Tabla | Tipo | Descripcion |
|-------|------|-------------|
| FACT_SALES | Hechos | Ventas con FK a dimensiones |
| DIM_PRODUCTS | Dimension | Catalogo de productos |
| DIM_CUSTOMERS | Dimension | Datos de clientes |
| STG_TEMP_SALES | Staging | Tabla temporal de carga (16 columnas raw) |
| STG_SALES | Staging | Tabla staging espejo de FACT_SALES |

## Convenciones de Codigo

- **Python**: snake_case, docstrings en espanol, type hints donde aplique
- **SQL**: UPPERCASE para keywords, indentacion de 4 espacios, comentarios descriptivos
- **Terraform**: snake_case para recursos, tags descriptivos
- **Commits**: convencional (`feat:`, `fix:`, `docs:`, `refactor:`)
- **Idioma**: documentacion y comentarios en espanol

## Variables de Entorno (.env)

Copiar `.env.example` a `.env` y completar:

```
AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION, S3_BUCKET_NAME
SNOWFLAKE_ACCOUNT, SNOWFLAKE_USER, SNOWFLAKE_PASSWORD, SNOWFLAKE_WAREHOUSE
SNOWFLAKE_DATABASE, SNOWFLAKE_SCHEMA
```

NUNCA commitear `.env`. Las credenciales de AWS en SQL deben usar STORAGE_INTEGRATION, no inline credentials.

## Tests

Actualmente no hay test suite. Cualquier nuevo script debe incluir validacion de datos (count checks, schema validation).

## Notas de Seguridad

- `stage_load_dev.sql` usa CREDENTIALS inline → solo para Snowflake Standard Edition. `stage_load.sql` tiene la version segura con STORAGE_INTEGRATION (requiere Enterprise+). Sustituir `<AWS_ACCESS_KEY>` / `<AWS_SECRET_KEY>` por valores reales al ejecutar.
- El bucket S3 tiene `force_destroy = true` — solo para desarrollo
- Snowflake warehouse configurado con `AUTO_SUSPEND = 300` para control de costos
