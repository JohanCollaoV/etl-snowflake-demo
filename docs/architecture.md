# Arquitectura

## Diagrama General

Ver [docs/diagrams.md](diagrams.md) para los diagramas completos en formato Mermaid (renderizables en GitHub, importables a draw.io y Lucidchart).

## Flujo del Pipeline

```
EventBridge (cron 8am)
    │
    ▼
AWS Lambda (ingest_to_s3.py)
    │ genera 500 registros
    ▼
S3 (raw/sales_data.csv)
    │
    ├──► raw/      — Datos crudos tal como se generan
    ├──► processed/— Datos transformados por dbt
    └──► curated/  — Datos listos para Looker Studio
            │
            ▼ (STORAGE_INTEGRATION)
        Snowflake
            │
            ▼ (COPY INTO)
    STG_TEMP_SALES → FACT_SALES + DIM_PRODUCTS + DIM_CUSTOMERS
            │
            ▼ (dbt run)
    Modelos dbt: staging → marts → analytics
            │
            ▼
        Looker Studio
```

## Componentes

### AWS (Free Tier)
| Componente | Servicio | Proposito |
|------------|----------|-----------|
| Ingesta | Lambda | Genera datos y los sube a S3 |
| Orquestacion | EventBridge | Cron diario que dispara Lambda |
| Almacenamiento | S3 | Data Lake con 3 capas |
| Seguridad | IAM | Roles Least Privilege (Lambda↔S3, Snowflake↔S3) |
| Monitoreo | CloudWatch | Logs y metricas de Lambda |
| IaC | Terraform | Toda la infraestructura como codigo |

### Orquestacion Local (Docker)
| Componente | Tecnologia | Proposito |
|------------|-----------|-----------|
| Orquestador | Apache Airflow | DAG: Lambda → COPY INTO → dbt run |
| Transformacion | dbt Core | Modelos SQL con tests y documentacion |

### Data Warehouse
| Componente | Tecnologia | Proposito |
|------------|-----------|-----------|
| Almacenamiento | Snowflake | Tablas de hechos y dimensiones |
| Conexion S3 | STORAGE_INTEGRATION | Acceso seguro sin credenciales inline |
| Carga | COPY INTO | Ingestion desde External Stage |

### DevOps
| Componente | Tecnologia | Proposito |
|------------|-----------|-----------|
| CI/CD | GitHub Actions | Lint, test, terraform plan en PRs |
| IaC | Terraform | Infraestructura reproducible |

### Visualizacion
| Componente | Tecnologia | Proposito |
|------------|-----------|-----------|
| Dashboard | Looker Studio | Visualizacion de datos desde Snowflake |

## Capas del Data Lake (S3)

| Carpeta | Proposito | Formato |
|---------|-----------|---------|
| `raw/` | Datos crudos generados por Lambda | CSV |
| `processed/` | Datos transformados por dbt | CSV / Parquet |
| `curated/` | Datasets finales para Looker Studio | CSV / Parquet |

## Servicios en Diagrama pero no Implementados

| Servicio | Razon |
|----------|-------|
| Secrets Manager | En diagrama como mejor practica. Implementacion real: .env + STORAGE_INTEGRATION |
| Glue | Reemplazado por dbt dentro de Snowflake |
| Step Functions | Reemplazado por Airflow (Docker local) |
