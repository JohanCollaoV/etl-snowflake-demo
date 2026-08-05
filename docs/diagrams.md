# Diagramas de Arquitectura

> **Formato**: Mermaid (nativo en GitHub). Para exportar a draw.io o Lucidchart: copiar el bloque de codigo y usar `File > Import From > Mermaid` o usar https://mermaid.live.

---

## 1. Arquitectura General del Sistema

```mermaid
graph TB
    subgraph AWS["AWS Cloud (Free Tier)"]
        EB["EventBridge<br/>cron diario 8am"]
        L["Lambda<br/>ingest_to_s3.py"]
        CW["CloudWatch<br/>logs + metricas"]
        S3["S3 Data Lake<br/>raw/ | processed/ | curated/"]
        IAM["IAM Roles<br/>Lambda→S3<br/>Snowflake→S3"]
        SF["(opcional)<br/>Step Functions"]
    end

    subgraph Local["Entorno Local (Docker)"]
        AF["Apache Airflow<br/>orquestacion de DAGs"]
        DBT["dbt Core<br/>transformaciones SQL<br/>tests + docs"]
        DC["docker-compose.yml<br/>dbt + Airflow"]
    end

    subgraph Snowflake["Snowflake"]
        STG["STG_TEMP_SALES<br/>tabla staging"]
        FACT["FACT_SALES<br/>tabla de hechos"]
        DIMP["DIM_PRODUCTS"]
        DIMC["DIM_CUSTOMERS"]
        ES["External Stage<br/>STORAGE_INTEGRATION"]
    end

    subgraph DevOps["DevOps"]
        GH["GitHub Actions<br/>CI/CD"]
        TF["Terraform<br/>IaC"]
    end

    LS["Looker Studio<br/>dashboard"]

    EB -->|invoca| L
    L -->|boto3 putObject| S3
    L -->|logs| CW
    IAM -.->|permisos| L
    IAM -.->|permisos| S3
    S3 -->|COPY INTO| ES
    ES -->|INSERT SELECT| STG
    STG -->|INSERT| FACT
    STG -->|INSERT DISTINCT| DIMP
    STG -->|INSERT DISTINCT| DIMC
    AF -->|dispara| L
    AF -->|ejecuta| DBT
    DBT -->|lee/escribe| FACT
    DBT -->|lee/escribe| DIMP
    DBT -->|lee/escribe| DIMC
    GH -->|lint + test + plan| TF
    TF -->|apply| AWS
    FACT -->|conexion| LS
    DIMP -->|conexion| LS
    DIMC -->|conexion| LS

    style AWS fill:#232F3E,color:#FF9900,stroke:#FF9900
    style Snowflake fill:#29B5E8,color:#fff,stroke:#29B5E8
    style Local fill:#2496ED,color:#fff,stroke:#2496ED
    style DevOps fill:#2088FF,color:#fff,stroke:#2088FF
    style LS fill:#4285F4,color:#fff,stroke:#4285F4
```

---

## 2. Flujo de Datos End-to-End

```mermaid
sequenceDiagram
    participant Cron as EventBridge
    participant Lambda as AWS Lambda
    participant S3 as S3 (raw/)
    participant SF as Snowflake
    participant dbt as dbt Core
    participant LS as Looker Studio

    Cron->>Lambda: 8:00 AM (diario)
    Lambda->>Lambda: generate_sales_data(500)
    Lambda->>S3: putObject(raw/sales_data.csv)
    Lambda->>Lambda: log a CloudWatch

    Note over SF,S3: Orquestado por Airflow

    SF->>S3: LIST @my_s3_stage
    SF->>SF: COPY INTO STG_TEMP_SALES
    SF->>SF: INSERT INTO FACT_SALES
    SF->>SF: INSERT INTO DIM_PRODUCTS
    SF->>SF: INSERT INTO DIM_CUSTOMERS

    dbt->>SF: dbt run (modelos)
    dbt->>SF: dbt test (validaciones)
    dbt->>SF: dbt docs generate

    LS->>SF: Consulta datos curados
    SF-->>LS: Resultados
    LS->>LS: Dashboard actualizado
```

---

## 3. Infraestructura AWS (Terraform — IaC)

```mermaid
graph LR
    subgraph Terraform["terraform/"]
        MAIN["main.tf<br/>provider + S3"]
        IAMTF["iam.tf<br/>IAM roles + policies"]
        LT["lambda.tf<br/>Lambda + zip + permisos"]
        EBTF["eventbridge.tf<br/>regla cron + target"]
        CWT["cloudwatch.tf<br/>log groups"]
        OUTF["outputs.tf<br/>ARNs"]
    end

    subgraph AWS2["Recursos AWS provisionados"]
        S3R["aws_s3_bucket<br/>etl-snowflake-demo-johan"]
        S3V["aws_s3_bucket_versioning<br/>versioning habilitado"]
        S3F["aws_s3_object<br/>raw/ processed/ curated/"]
        LAMR["aws_lambda_function<br/>ingest_to_s3"]
        LAMP["aws_lambda_permission<br/>permite EventBridge"]
        EBR["aws_cloudwatch_event_rule<br/>cron(0 8 * * ? *)"]
        EBT["aws_cloudwatch_event_target<br/>→ Lambda"]
        CWG["aws_cloudwatch_log_group<br/>/aws/lambda/ingest"]
        IAMRL["aws_iam_role<br/>rol_lambda_s3"]
        IAMP["aws_iam_policy<br/>s3:PutObject"]
        IAMRS["aws_iam_role<br/>rol_snowflake_s3"]
        IAMRSD["aws_iam_policy_document<br/>trust Snowflake"]
    end

    MAIN --> S3R
    MAIN --> S3V
    MAIN --> S3F
    LT --> LAMR
    LT --> LAMP
    EBTF --> EBR
    EBTF --> EBT
    CWT --> CWG
    IAMTF --> IAMRL
    IAMTF --> IAMP
    IAMTF --> IAMRS
    IAMTF --> IAMRSD
    OUTF --> S3R
    OUTF --> LAMR
    OUTF --> IAMRS

    style Terraform fill:#7B42BC,color:#fff,stroke:#7B42BC
    style AWS2 fill:#232F3E,color:#FF9900,stroke:#FF9900
```

---

## Exportacion a otras herramientas

### draw.io
1. Abrir https://app.diagrams.net
2. `Arrange > Insert > Advanced > Mermaid`
3. Pegar el bloque de codigo Mermaid
4. `Insert` — convierte a diagrama nativo de draw.io

### Lucidchart
1. Abrir Lucidchart
2. `+ New > Import > Mermaid`
3. Pegar el codigo y hacer clic en `Import`

### Mermaid Live (online)
1. Abrir https://mermaid.live
2. Pegar el codigo
3. `Actions > Export as PNG/SVG`
