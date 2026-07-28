#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Script de ingesta de datos de ventas a AWS S3.
Genera datos de ejemplo y los sube al bucket S3 configurado en el archivo .env.
"""

import os
import boto3
import pandas as pd
from datetime import datetime, timedelta
import random
from dotenv import load_dotenv

# Cargar variables de entorno desde el archivo .env
load_dotenv()

# Obtener el nombre del bucket desde las variables de entorno
BUCKET_NAME = os.getenv("S3_BUCKET_NAME")

def generate_sales_data(num_records=500):
    """
    Genera un conjunto de datos de ventas ficticios.

    Parametros:
        num_records (int): Cantidad de registros a generar. Por defecto 500.

    Retorna:
        pandas.DataFrame: DataFrame con los datos de ventas generados.
    """
    # Catalogo de productos disponibles
    productos = [
        ("P001", "Laptop", "Electronics", "Dell"),
        ("P002", "Smartphone", "Electronics", "Samsung"),
        ("P003", "Headphones", "Audio", "Sony"),
        ("P004", "Keyboard", "Accessories", "Logitech"),
        ("P005", "Monitor", "Electronics", "LG"),
    ]

    # Catalogo de clientes
    clientes = [
        ("C001", "Juan Perez", "juan@email.com", "Santiago", "Gold"),
        ("C002", "Maria Garcia", "maria@email.com", "Valparaiso", "Silver"),
        ("C003", "Carlos Lopez", "carlos@email.com", "Concepcion", "Bronze"),
    ]

    # Lista de regiones y metodos de pago
    regiones = ["Santiago", "Valparaiso", "Concepcion", "Antofagasta"]
    metodos_pago = ["Credit Card", "Debit Card", "PayPal", "Transfer"]

    # Lista para almacenar los registros generados
    data = []

    # Fecha de inicio para las ventas (1 de enero de 2025)
    start_date = datetime(2025, 1, 1)

    # Generar registros aleatorios
    for i in range(num_records):
        # Seleccionar un producto y un cliente al azar
        producto = random.choice(productos)
        cliente = random.choice(clientes)

        # Generar fecha aleatoria dentro del año 2025
        fecha = start_date + timedelta(days=random.randint(0, 365))

        # Cantidad y precio aleatorios
        cantidad = random.randint(1, 5)
        precio = round(random.uniform(10, 500), 2)

        # Crear el registro como diccionario
        registro = {
            'sale_id': f'S{str(i+1).zfill(6)}',  # ID unico de venta
            'order_date': fecha.strftime('%Y-%m-%d'),
            'customer_id': cliente[0],
            'customer_name': cliente[1],
            'customer_email': cliente[2],
            'customer_city': cliente[3],
            'customer_segment': cliente[4],
            'product_id': producto[0],
            'product_name': producto[1],
            'category': producto[2],
            'brand': producto[3],
            'quantity': cantidad,
            'unit_price': precio,
            'total_amount': round(cantidad * precio, 2),
            'payment_method': random.choice(metodos_pago),
            'region': random.choice(regiones),
        }
        data.append(registro)

    # Convertir la lista de diccionarios a DataFrame de pandas
    return pd.DataFrame(data)


def upload_to_s3(df):
    """
    Sube un DataFrame a S3 en formato CSV.

    Parametros:
        df (pandas.DataFrame): Datos a subir.
    """
    # Crear cliente de S3 usando las credenciales del entorno
    s3 = boto3.client('s3')

    # Convertir DataFrame a CSV en memoria (sin indice)
    csv_buffer = df.to_csv(index=False)

    # Subir el archivo al bucket en la carpeta 'raw/'
    s3.put_object(
        Bucket=BUCKET_NAME,
        Key='raw/sales_data.csv',
        Body=csv_buffer,
        ContentType='text/csv'
    )

    print(f"Archivo subido a s3://{BUCKET_NAME}/raw/sales_data.csv")
    print(f"Registros generados: {len(df)}")


def main():
    """Punto de entrada principal del script."""
    print("Generando datos de prueba...")
    df = generate_sales_data(500)
    upload_to_s3(df)
    print("Ingesta completada exitosamente.")


if __name__ == "__main__":
    main()