# Arquitectura

## Flujo del Pipeline

```
generate_sales_data() → upload_to_s3()
                            ↓
                      S3 (raw/)
                            ↓
                      Snowflake
```

El script `scripts/ingest/ingest_to_s3.py` genera 500 registros de ventas ficticias y los sube a S3 como CSV en la capa `raw/`.

## Capas del Bucket S3

| Carpeta | Propósito |
|---|---|
| `raw/` | Datos crudos tal como se generan |
| `processed/` | Datos transformados (pendiente) |
| `curated/` | Datos listos para consumo (pendiente) |

## Ejecución

```bash
python scripts/ingest/ingest_to_s3.py
```

Esto produce `s3://<bucket>/raw/sales_data.csv`.
