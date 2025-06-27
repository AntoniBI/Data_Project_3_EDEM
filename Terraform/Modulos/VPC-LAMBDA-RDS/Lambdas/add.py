import json
import pg8000
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

DB_HOST = os.getenv('DB_HOST', 'terraform-20250627075830662500000001.chs8ig0oc6qv.eu-central-1.rds.amazonaws.com')
DB_USER = os.getenv('DB_USER', 'postgres_user')
DB_PASSWORD = os.getenv('DB_PASSWORD', 'password123')
DB_NAME = os.getenv('DB_NAME', 'shopdb')

def lambda_handler(event, context):
    logger.info(f"Received event: {event}")
    logger.debug(f"Context object: {context}")

    try:
       
        body = json.loads(event.get("body", "{}"))

        name = body.get('name')
        price = body.get('price')
        category = body.get('category')
        stock = body.get('stock', 10)

        logger.debug(f"Parsed values - name: {name}, price: {price}, category: {category}, stock: {stock}")

        # Validaciones
        if len(name or '') < 3:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "El nombre debe tener al menos 3 caracteres"})
            }
        if len(category or '') < 3:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "La categoría debe tener al menos 3 caracteres"})
            }
        try:
            price = float(price)
        except (ValueError, TypeError):
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "El precio debe ser un número"})
            }
        try:
            stock = int(stock)
            if stock < 0:
                stock = 10
        except (ValueError, TypeError):
            stock = 10

        logger.info("Validaciones completadas")

        # Conexión a la base de datos
        connection = pg8000.connect(
            host=DB_HOST,
            port=5432,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME
        )
        logger.info("Conexión a la base de datos establecida")

        with connection.cursor() as cursor:
            # Asegurar existencia de la tabla
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS products (
                    id SERIAL PRIMARY KEY,
                    name TEXT NOT NULL,
                    price NUMERIC(10,2) NOT NULL,
                    category TEXT NOT NULL,
                    stock INTEGER NOT NULL DEFAULT 10
                );
            """)
            connection.commit()

            # Insertar producto
            cursor.execute(
                "INSERT INTO products (name, price, category, stock) VALUES (%s, %s, %s, %s)",
                (name, price, category, stock)
            )
            connection.commit()

        logger.info("Producto insertado correctamente")

        return {
            "statusCode": 201,
            "body": json.dumps({"message": "Producto añadido correctamente"})
        }

    except Exception as e:
        logger.error(f"Error en lambda_handler: {str(e)}", exc_info=True)
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }

    finally:
        if 'connection' in locals():
            connection.close()
            logger.info("Conexión cerrada")
