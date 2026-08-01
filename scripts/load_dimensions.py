#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Ejecuta load_dimensions.sql contra Snowflake para poblar
DIM_CUSTOMERS y DIM_PRODUCTS desde STG_TEMP_SALES.
"""

import os
import snowflake.connector
from dotenv import load_dotenv

load_dotenv()


def get_connection():
    return snowflake.connector.connect(
        account=os.getenv("SNOWFLAKE_ACCOUNT"),
        user=os.getenv("SNOWFLAKE_USER"),
        password=os.getenv("SNOWFLAKE_PASSWORD"),
        warehouse=os.getenv("SNOWFLAKE_WAREHOUSE"),
        database=os.getenv("SNOWFLAKE_DATABASE"),
        schema=os.getenv("SNOWFLAKE_SCHEMA"),
    )


def ejecutar_dimensiones():
    conn = get_connection()
    cur = conn.cursor()

    queries = {
        "DIM_CUSTOMERS": """
            INSERT INTO DIM_CUSTOMERS (customer_id, customer_name, customer_email, customer_city, customer_segment)
            SELECT DISTINCT
                customer_id,
                customer_name,
                customer_email,
                customer_city,
                customer_segment
            FROM STG_TEMP_SALES
        """,
        "DIM_PRODUCTS": """
            INSERT INTO DIM_PRODUCTS (product_id, product_name, category, brand)
            SELECT DISTINCT
                product_id,
                product_name,
                category,
                brand
            FROM STG_TEMP_SALES
        """,
    }

    for nombre, query in queries.items():
        try:
            cur.execute(query)
            cur.execute(f"SELECT COUNT(*) FROM {nombre}")
            count = cur.fetchone()[0]
            print(f"{nombre}: {count} registros insertados")
        except Exception as e:
            print(f"Error en {nombre}: {e}")

    cur.close()
    conn.close()
    print("Dimensiones pobladas exitosamente.")


if __name__ == "__main__":
    ejecutar_dimensiones()
