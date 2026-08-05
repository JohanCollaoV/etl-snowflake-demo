#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Genera diagrama de arquitectura AWS con iconos oficiales.
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import Lambda
from diagrams.aws.integration import Eventbridge
from diagrams.aws.storage import S3
from diagrams.aws.management import Cloudwatch
from diagrams.aws.security import IAMRole
from diagrams.aws.general import General
from diagrams.onprem.ci import GithubActions
from diagrams.onprem.workflow import Airflow
from diagrams.onprem.analytics import Dbt
from diagrams.onprem.client import User
from diagrams.saas.analytics import Snowflake
from diagrams.generic.blank import Blank

graph_attr = {
    "fontsize": "18",
    "bgcolor": "white",
    "pad": "0.5",
    "splines": "ortho",
}

with Diagram(
    "Arquitectura AWS — ETL Snowflake Demo",
    filename="docs/diagrams/aws_architecture",
    show=False,
    direction="TB",
    graph_attr=graph_attr,
    outformat="png",
):
    with Cluster("AWS Cloud (Free Tier)"):
        eb = Eventbridge("EventBridge\ncron diario 8am")

        with Cluster("Compute"):
            lmb = Lambda("Lambda\ningest_to_s3.py")

        with Cluster("Storage"):
            s3 = S3("S3 Data Lake\nraw/processed/curated/")

        with Cluster("Security"):
            iam = IAMRole("IAM Roles\nLambda→S3\nSnowflake→S3")

        with Cluster("Monitoring"):
            cw = Cloudwatch("CloudWatch\nlogs + metricas")

    with Cluster("Local (Docker)"):
        af = Airflow("Apache Airflow\norquestacion DAGs")
        dbt = Dbt("dbt Core\ntransformaciones\nSQL + tests")

    with Cluster("Data Warehouse"):
        sf = Snowflake("Snowflake\nFACT_SALES\nDIM_PRODUCTS\nDIM_CUSTOMERS")

    with Cluster("DevOps"):
        gh = GithubActions("GitHub Actions\nCI/CD")
        tf = General("Terraform\nIaC")

    user = User("Looker Studio\nDashboard")

    eb >> Edge(label="invoca") >> lmb
    lmb >> Edge(label="putObject") >> s3
    lmb >> Edge(label="logs") >> cw
    iam >> Edge(style="dashed") >> lmb
    iam >> Edge(style="dashed") >> s3

    s3 >> Edge(label="STORAGE_INTEGRATION") >> sf

    af >> Edge(label="orquesta") >> lmb
    af >> Edge(label="ejecuta") >> dbt
    dbt >> Edge(label="modela") >> sf

    gh >> Edge(label="CI/CD") >> tf
    sf >> Edge(label="lee") >> user
