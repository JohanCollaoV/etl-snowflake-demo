# Log de Hitos (Milestones)

Registro de avances significativos del proyecto. No incluye commits individuales — para eso usar `git log`.

---

## Fase 1 — Fundamentos (Completado)

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
- Datos cargados con COPY INTO (500 registros verificados en FACT_SALES)
- VS Code conectado via extension oficial de Snowflake

### Repositorio
- Estructura de archivos organizada (sql/, scripts/, terraform/, docs/)
- Variables de entorno con .env.example
- Codigo subido a GitHub

---

## Proximas Fases

### Fase 2 — Dimensiones y Transformaciones
- [x] Crear `stage_load_dev.sql` (Standard Edition, credenciales inline)
- [x] `stage_load.sql` migrado a STORAGE_INTEGRATION (codigo listo, requiere Snowflake Enterprise+)
- [x] Ejecutar `load_dimensions.sql` para poblar DIM_PRODUCTS (5) y DIM_CUSTOMERS (3)
- [ ] Configurar dbt Core (local) — proyecto dbt_sales/ con modelos staging, dims, fact, analytics
- [ ] Crear Dockerfile para dbt (contenedor portatil)
- [ ] Agregar tests y documentacion dbt

### Fase 3 — Orquestacion
- [ ] DAG de Airflow: ingest_to_s3.py → COPY INTO → dbt run
- [ ] Airflow local con Docker

### Fase 4 — CI/CD
- [ ] GitHub Actions: lint Python (ruff), lint SQL (sqlfluff), dbt test, terraform plan por PR

### Fase 5 — Visualizacion
- [ ] Dashboard en Looker Studio conectado a Snowflake

---

*Ultima actualizacion: 3 de agosto, 2026*
