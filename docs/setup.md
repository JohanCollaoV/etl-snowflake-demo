# Setup

## Requisitos

- Python 3.10+
- Cuenta de AWS con credenciales configuradas
- Cuenta de Snowflake
- Terraform
- Graphviz (`brew install graphviz` en macOS) — para generar diagramas
- Docker (para Airflow, Fase 4)

## Instalación

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## Configuración

Copia y edita el archivo de variables de entorno:

```bash
cp .env.example .env
```

### Variables de Entorno

| Variable | Descripción |
|---|---|
| `AWS_ACCESS_KEY_ID` | Clave de acceso de AWS |
| `AWS_SECRET_ACCESS_KEY` | Clave secreta de AWS |
| `AWS_DEFAULT_REGION` | Región de AWS |
| `S3_BUCKET_NAME` | Nombre del bucket S3 |
| `SNOWFLAKE_ACCOUNT` | Identificador de cuenta Snowflake |
| `SNOWFLAKE_USER` | Usuario de Snowflake |
| `SNOWFLAKE_PASSWORD` | Contraseña de Snowflake |
| `SNOWFLAKE_WAREHOUSE` | Warehouse de Snowflake |
| `SNOWFLAKE_DATABASE` | Base de datos en Snowflake |
| `SNOWFLAKE_SCHEMA` | Schema en Snowflake |
