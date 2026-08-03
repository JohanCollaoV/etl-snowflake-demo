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
- [ ] Ejecutar `load_dimensions.sql` para poblar DIM_PRODUCTS y DIM_CUSTOMERS
- [ ] Implementar dbt para transformaciones y testing
- [x] Migrar credenciales de stage a STORAGE_INTEGRATION

### Fase 3 — Orquestacion y Visualizacion
- [ ] DAG de Airflow para orquestar el pipeline completo
- [ ] Dashboard en Looker Studio conectado a Snowflake

### Fase 4 — DevOps
- [ ] CI/CD con GitHub Actions
- [ ] Exportacion Snowflake → S3 (datos transformados)

---

*Ultima actualizacion: 3 de agosto, 2026*
