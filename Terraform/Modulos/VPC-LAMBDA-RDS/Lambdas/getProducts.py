import json
import pg8000
import os

def lambda_handler(event, context):
    db_host = os.environ.get('DB_HOST', "terraform-20250627075830662500000001.chs8ig0oc6qv.eu-central-1.rds.amazonaws.com")
    db_user = os.environ.get('DB_USER', 'postgres_user')
    db_password = os.environ.get('DB_PASSWORD', 'password123')
    db_name = os.environ.get('DB_NAME', 'shopdb')


    try:
        connection = pg8000.connect(
            host=db_host,
            port=5432,
            user=db_user,
            password=db_password,
            database=db_name
        )
        with connection.cursor() as cursor:
            cursor.execute("SELECT id, name, price, category, stock FROM products")
            rows = cursor.fetchall()
            products = [
                {
                    "id": row[0],
                    "name": row[1],
                    "price": float(row[2]),
                    "category": row[3],
                    "stock": row[4]
                }
                for row in rows
            ]

        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"products": products})
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }

    finally:
        if 'connection' in locals():
            connection.close()
