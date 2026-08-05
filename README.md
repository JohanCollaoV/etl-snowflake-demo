# ETL Snowflake Demo

Pipeline ETL end-to-end de datos de ventas de e-commerce. Proyecto de portafolio que demuestra **AWS Serverless**, **Data Engineering** (Snowflake + dbt) y **DevOps** (Terraform, Docker, CI/CD).

## Arquitectura

```
EventBridge → Lambda → S3 → Snowflake → dbt → Looker Studio
                     (raw/)    │
                               ├── Airflow (Docker)
                               └── GitHub Actions (CI/CD)
```

[Ver diagramas completos en docs/diagrams.md](docs/diagrams.md)

## Stack Tecnologico

| Capa | Tecnologia | Estado |
|------|------------|--------|
| Ingesta | AWS Lambda + EventBridge | Planificado |
| Data Lake | AWS S3 | Completado |
| IaC | Terraform | Completado (S3) |
| Data Warehouse | Snowflake | Completado |
| Transformacion | dbt Core | Planificado |
| Orquestacion | Apache Airflow (Docker) | Planificado |
| CI/CD | GitHub Actions | Planificado |
| Visualizacion | Looker Studio | Planificado |

## Requisitos

- Python 3.10+
- AWS CLI configurado
- Cuenta de Snowflake
- Terraform
- Docker (para Airflow y dbt)

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
# Crear infraestructura AWS
cd terraform && terraform init && terraform apply -auto-approve

# Generar datos y subir a S3 (local)
python scripts/ingest/ingest_to_s3.py

# Poblar dimensiones en Snowflake
python scripts/load_dimensions.py

# Destruir infraestructura al finalizar
cd terraform && terraform destroy -auto-approve
```

## Flujo del Pipeline

```
Lambda (ingest) → S3 (raw/) → External Stage → STG_TEMP_SALES → FACT_SALES + DIM_PRODUCTS + DIM_CUSTOMERS → dbt → Looker Studio
```

## Fases del Proyecto

| Fase | Estado |
|------|--------|
| 1 — Fundamentos (S3, Snowflake, tablas) | Completado |
| 2 — AWS Serverless (Lambda, EventBridge, IAM) | Planificado |
| 3 — dbt Core (modelos, tests, docs) | Planificado |
| 4 — Airflow + Docker (orquestacion) | Planificado |
| 5 — CI/CD (GitHub Actions) | Planificado |
| 6 — Looker Studio (dashboard) | Planificado |

## Documentacion

| Documento | Contenido |
|-----------|-----------|
| [docs/architecture.md](docs/architecture.md) | Arquitectura detallada del pipeline |
| [docs/diagrams.md](docs/diagrams.md) | Diagramas Mermaid (Arquitectura, Flujo, IaC) |
| [docs/deployment.md](docs/deployment.md) | Infraestructura y despliegue |
| [docs/setup.md](docs/setup.md) | Configuracion y dependencias |
| [docs/progress.md](docs/progress.md) | Log de hitos del proyecto |
| [AGENTS.md](AGENTS.md) | Instrucciones para agentes de IA |

## Licencia

MIT
