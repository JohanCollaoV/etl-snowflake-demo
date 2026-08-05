# Log de Hitos (Milestones)

Registro de avances significativos del proyecto. No incluye commits individuales — para eso usar `git log`.

---

## Fase 1 — Fundamentos :white_check_mark: (Completado)

### Infraestructura
- Cuenta AWS configurada (usuario IAM johandev con permisos S3)
- Cuenta Snowflake creada (Free Trial, 30 dias)
- Bucket S3 con Terraform: `etl-snowflake-demo-johan`
- Carpetas del lakehouse: raw/, processed/, curated/
- Versioning habilitado en el bucket

### Ingesta de Datos
- Script `ingest_to_s3.py` funcional
- Generacion de 500 registros de ventas ficticias
- Subida a S3 en formato CSV

### Snowflake
- Warehouse COMPUTE_WH (X-SMALL, AUTO_SUSPEND=300)
- Base de datos VENTAS_DB y schema PUBLIC
- Tablas creadas: FACT_SALES, DIM_PRODUCTS, DIM_CUSTOMERS, STG_SALES
- External Stage `my_s3_stage` conectado a S3
- Stage migrado a STORAGE_INTEGRATION (sin credenciales inline)
- Stage alternativo `stage_load_dev.sql` (Standard Edition)
- Datos cargados con COPY INTO (500 FACT_SALES, 3 DIM_CUSTOMERS, 5 DIM_PRODUCTS)
- VS Code conectado via extension oficial de Snowflake

### Repositorio
- Estructura de archivos organizada (sql/, scripts/, terraform/, docs/)
- Variables de entorno con .env.example
- AGENTS.md con instrucciones para agentes de IA
- README.md limpio y estructurado
- Diagramas de arquitectura en docs/diagrams.md (Mermaid)

---

## Fase 2 — AWS Serverless (Planificado)

- [ ] Terraform: IAM roles (Lambda→S3, Snowflake→S3 con STORAGE_INTEGRATION)
- [ ] Terraform: Lambda function empaquetada con script de ingesta
- [ ] Terraform: EventBridge cron rule (8am diario)
- [ ] Terraform: CloudWatch log group para Lambda
- [ ] Adaptar `ingest_to_s3.py` para runtime Lambda (sin pandas, usar csv stdlib)

---

## Fase 3 — dbt Core (Planificado)

- [ ] Crear proyecto `dbt_sales/` con dbt init
- [ ] Modelos staging: limpiar STG_TEMP_SALES
- [ ] Modelos marts: DIM_PRODUCTS, DIM_CUSTOMERS, FACT_SALES
- [ ] Modelos analytics: KPIs de negocio
- [ ] Tests dbt: unique, not_null, accepted_values
- [ ] Documentacion dbt: `dbt docs generate`
- [ ] Dockerfile para contenedor dbt portatil

---

## Fase 4 — Airflow + Docker (Planificado)

- [ ] DAG `sales_pipeline`: Task 1 (disparar Lambda), Task 2 (COPY INTO Snowflake), Task 3 (dbt run)
- [ ] Conexiones Airflow: AWS, Snowflake
- [ ] Variables de entorno en docker-compose
- [ ] docker-compose.yml: Airflow + PostgreSQL (metadata) + dbt
- [ ] Sensores: verificar que el CSV llego a S3 antes de COPY INTO

---

## Fase 5 — CI/CD con GitHub Actions (Planificado)

- [ ] Workflow: ruff (Python lint) en PRs
- [ ] Workflow: sqlfluff (SQL lint) en PRs
- [ ] Workflow: dbt test en cambios a modelos
- [ ] Workflow: terraform plan en cambios a infraestructura
- [ ] Workflow: docker build check

---

## Fase 6 — Looker Studio (Planificado)

- [ ] Conexion Looker Studio → Snowflake
- [ ] Dashboard: ventas por region
- [ ] Dashboard: top productos y clientes
- [ ] Dashboard: tendencias temporales

---

## Notas

- **Secrets Manager**: referenciado en diagramas como mejor practica. No implementado ($0.40/mes).
- **Glue**: reemplazado por dbt. No implementado (costo).
- **Step Functions**: reemplazado por Airflow (mayor valor de portafolio en Data Engineering).

*Ultima actualizacion: 4 de agosto, 2026*
