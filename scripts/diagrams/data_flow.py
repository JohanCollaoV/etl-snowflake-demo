#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Genera diagrama de flujo de datos end-to-end con iconos oficiales.
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import Lambda
from diagrams.aws.integration import Eventbridge
from diagrams.aws.storage import S3
from diagrams.onprem.analytics import Dbt
from diagrams.saas.analytics import Snowflake
from diagrams.onprem.client import User

graph_attr = {
    "fontsize": "16",
    "bgcolor": "white",
    "pad": "0.5",
    "splines": "ortho",
}

with Diagram(
    "Flujo de Datos — ETL Snowflake Demo",
    filename="docs/diagrams/data_flow",
    show=False,
    direction="LR",
    graph_attr=graph_attr,
    outformat="png",
):
    eb = Eventbridge("EventBridge\n(cron 8am)")

    with Cluster("Ingesta"):
        lmb = Lambda("Lambda\n(genera 500\nregistros)")

    with Cluster("Data Lake"):
        s3_raw = S3("S3 raw/\nCSV crudo")
        s3_proc = S3("S3 processed/\ndbt export")
        s3_cur = S3("S3 curated/\ndataset final")

    with Cluster("Snowflake"):
        stg = Snowflake("STG_TEMP_SALES\n(staging 16 cols)")
        fact = Snowflake("FACT_SALES\n(hechos 9 cols)")
        dims = Snowflake("DIM_PRODUCTS\nDIM_CUSTOMERS")

    with Cluster("Transformacion"):
        dbt = Dbt("dbt Core\nmodelos + tests")

    user = User("Looker Studio\n(dashboard)")

    eb >> lmb
    lmb >> Edge(label="boto3") >> s3_raw
    s3_raw >> Edge(label="STORAGE_INTEGRATION") >> stg
    stg >> Edge(label="INSERT SELECT") >> fact
    stg >> Edge(label="INSERT DISTINCT") >> dims
    fact >> Edge(label="dbt modela") >> dbt
    dims >> dbt
    dbt >> s3_proc
    s3_proc >> s3_cur
    fact >> user
    dims >> user
