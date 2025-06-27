import json
import pg8000
import os

def lambda_handler(event, context):
    db_host = os.environ.get('DB_HOST',"terraform-20250627075830662500000001.chs8ig0oc6qv.eu-central-1.rds.amazonaws.com")
    db_user = os.environ.get('DB_USER', 'postgres_user')
    db_password = os.environ.get('DB_PASSWORD', 'password123')
    db_name = os.environ.get('DB_NAME', 'shopdb')

    try:
        body = json.loads(event.get('body', '{}'))
        product_id = body.get('product_id')
        quantity = body.get('quantity')

        if not product_id or not quantity:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Faltan product_id o quantity"})
            }

        connection = pg8000.connect(
            host=db_host,
            port=5432,
            user=db_user,
            password=db_password,
            database=db_name
        )

        with connection.cursor() as cursor:
            cursor.execute("SELECT stock FROM products WHERE id = %s", (product_id,))
            row = cursor.fetchone()

            if not row:
                return {
                    "statusCode": 404,
                    "body": json.dumps({"error": "Producto no encontrado"})
                }

            current_stock = row[0]
            if current_stock < quantity:
                return {
                    "statusCode": 400,
                    "body": json.dumps({"error": "Stock insuficiente"})
                }

            cursor.execute(
                "UPDATE products SET stock = stock - %s WHERE id = %s",
                (quantity, product_id)
            )
            connection.commit()

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Compra realizada"})
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }

    finally:
        if 'connection' in locals():
            connection.close()
