# Despliegue

## Infraestructura (Terraform)

El directorio `terraform/` contiene la definición del bucket S3 con versioning y las carpetas del lakehouse.

```bash
cd terraform
terraform init
terraform apply
```

### Recursos

- `aws_s3_bucket.data_bucket` — Bucket principal
- `aws_s3_bucket_versioning.versioning` — Versioning habilitado
- `aws_s3_object.folders` — Carpetas `raw/`, `processed/`, `curated/`

### Outputs

- `bucket_name` — Nombre del bucket creado
- `bucket_arn` — ARN del bucket
