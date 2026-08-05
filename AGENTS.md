# AGENTS.md — Instrucciones para Agentes de IA

## Descripcion del Proyecto

Pipeline ETL end-to-end de datos de ventas de e-commerce. Genera datos ficticios, los ingesta a AWS S3, los carga en Snowflake y los transforma para analitica. Proyecto de portafolio que demuestra AWS (serverless, IaC), Data Engineering (dbt, Snowflake) y DevOps (Docker, CI/CD).

## Stack Tecnologico

- **Ingesta**: Python 3.10+, boto3, AWS Lambda
- **Data Lake**: AWS S3 (capas raw/, processed/, curated/)
- **Data Warehouse**: Snowflake
- **IaC**: Terraform (S3, Lambda, EventBridge, IAM, CloudWatch)
- **Orquestacion**: Apache Airflow + contenedores Docker
- **Transformacion**: dbt Core (modelos SQL, tests, docs)
- **CI/CD**: GitHub Actions (ruff, sqlfluff, dbt test, terraform plan)
- **Visualizacion**: Looker Studio (planificado)

## Estructura del Proyecto

```
etl-snowflake-demo/
├── scripts/                        # Scripts Python
│   ├── ingest/ingest_to_s3.py      # Genera datos y los sube a S3
│   └── load_dimensions.py          # Pobla dimensiones en Snowflake
├── sql/
│   ├── setup.sql                   # Warehouse, DB, schema inicial
│   ├── create_tables.sql           # FACT_SALES, DIM_PRODUCTS, DIM_CUSTOMERS
│   ├── stage_load.sql              # External Stage (STORAGE_INTEGRATION)
│   ├── stage_load_dev.sql          # External Stage (credenciales inline, dev)
│   ├── load_dimensions.sql         # Poblar dims desde staging
│   ├── analytics_querys.sql        # Consultas analiticas
│   └── limpieza.sql                # Limpieza de tablas temporales
├── terraform/
│   ├── main.tf                     # Provider + S3 bucket
│   ├── iam.tf                      # IAM roles (Lambda, Snowflake)
│   ├── lambda.tf                   # Lambda function + permisos
│   ├── eventbridge.tf              # Cron rule + target Lambda
│   ├── cloudwatch.tf               # Log groups
│   └── outputs.tf                  # ARNs utiles
├── dbt_sales/                      # (Fase 3) Proyecto dbt
│   └── models/
│       ├── staging/
│       ├── marts/
│       └── analytics/
├── airflow/                        # (Fase 4) Orquestacion
│   ├── dags/sales_pipeline_dag.py
│   └── docker-compose.yml
├── .github/workflows/              # (Fase 5) CI/CD
│   ├── lint.yml
│   ├── dbt_test.yml
│   └── terraform_plan.yml
├── docs/
│   ├── architecture.md             # Arquitectura y flujo del pipeline
│   ├── deployment.md               # Infraestructura y despliegue
│   ├── setup.md                    # Configuracion y dependencias
│   ├── diagrams.md                 # Diagramas Mermaid (Arquitectura, Flujo, IaC)
│   └── progress.md                 # Log de hitos (no commits)
├── .env.example                    # Template de variables de entorno
├── requirements.txt                # Dependencias Python
├── AGENTS.md                       # Este archivo
└── README.md                       # Documentacion para humanos
```

## Comandos Principales

```bash
# Activar entorno virtual
source venv/bin/activate

# Instalar dependencias
pip install -r requirements.txt

# Ejecutar ingesta de datos a S3
python scripts/ingest/ingest_to_s3.py

# Ejecutar load_dimensions contra Snowflake
python scripts/load_dimensions.py

# Infraestructura con Terraform
cd terraform && terraform init && terraform apply -auto-approve

# Destruir infraestructura
cd terraform && terraform destroy -auto-approve

# dbt (Fase 3)
cd dbt_sales && dbt run && dbt test && dbt docs generate

# Airflow (Fase 4)
cd airflow && docker-compose up -d
```

## Flujo del Pipeline

```
EventBridge (cron 8am) → Lambda (ingest) → S3 (raw/)
    → External Stage → STG_TEMP_SALES → FACT_SALES + DIM_PRODUCTS + DIM_CUSTOMERS
    → dbt (staging → marts → analytics) → Looker Studio
```

## Fases del Proyecto

| Fase | Estado | Entregables |
|------|--------|------------|
| 1 — Fundamentos | Completado | S3, Snowflake, ingesta local, documentacion |
| 2 — AWS Serverless | Planificado | Terraform: Lambda, EventBridge, IAM, CloudWatch |
| 3 — dbt Core | Planificado | Modelos SQL, tests, docs, Dockerfile |
| 4 — Airflow + Docker | Planificado | DAG orquestacion, docker-compose |
| 5 — CI/CD | Planificado | GitHub Actions: lint, test, terraform plan |
| 6 — Looker Studio | Planificado | Dashboard conectado a Snowflake |

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
- **Commits**: convencional (`feat:`, `fix:`, `docs:`, `refactor:`) en espanol
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

- `stage_load_dev.sql` usa CREDENTIALS inline → solo para Snowflake Standard Edition. `stage_load.sql` tiene la version segura con STORAGE_INTEGRATION (requiere Enterprise+).
- El bucket S3 tiene `force_destroy = true` — solo para desarrollo
- Snowflake warehouse configurado con `AUTO_SUSPEND = 300` para control de costos

## Modo Aprendizaje

Antes de ejecutar cualquier modificacion en el codigo (archivos .sql, .py, .tf, .yml, .md, .json):

1. Explica que archivos se van a modificar y por que
2. Haz una pregunta de verificacion al usuario para confirmar que entiende el cambio
3. Espera la respuesta antes de proceder

Ejemplo:
> "Voy a modificar `dbt_project.yml` para agregar el perfil de Snowflake.
> ¿Entiendes por que usamos `profiles.yml` en vez de variables de entorno?"

No aplicar esta regla para:
- Consultas de documentacion (aws_knowledge)
- Lectura de archivos
- Busquedas en el codigo
