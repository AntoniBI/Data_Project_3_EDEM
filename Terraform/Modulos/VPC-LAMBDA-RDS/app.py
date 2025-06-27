from flask import Flask, render_template, request, redirect
import boto3
import json
import os
import logging
import pg8000

app = Flask(__name__)
lambda_client = boto3.client('lambda', region_name='eu-central-1', aws_access_key_id=os.environ.get("AWS_ACCESS_KEY_ID", ""),
                             aws_secret_access_key=os.environ.get("AWS_SECRET_ACCESS_KEY", ""))

def invoke_lambda(function_name, payload={}):
    try:
        response = lambda_client.invoke(
            FunctionName=function_name,
            InvocationType='RequestResponse',
            Payload=json.dumps({"body": json.dumps(payload)}).encode(),
        )
        raw_payload = response['Payload'].read()
        result = json.loads(raw_payload)
        if 'body' in result:
            return json.loads(result['body'])
        return result
    except Exception as e:
        app.logger.error(f"Error invoking lambda {function_name}: {e}")
        raise

@app.route('/')
def home():
    result = invoke_lambda('getProducts')
    products = result.get('products', []) if isinstance(result, dict) else []
    return render_template("index.html", products=products)

@app.route('/add', methods=["POST"])
def add_product():
    data = {
        "name": request.form['name'],
        "price": float(request.form['price']),
        "category": request.form['category'],
        "stock": int(request.form.get('stock', 10))
    }
    invoke_lambda('add', data)
    return redirect('/')

@app.route('/buy', methods=["POST"])
def buy_product():
    data = {
        "product_id": request.form['product_id'],
        "quantity": int(request.form['quantity'])
    }
    result = invoke_lambda('buy', data)
    if isinstance(result, dict) and result.get("error"):
        return f"Error comprando producto: {result['error']}", 400

    return redirect('/')


if __name__ == '__main__':
    import os
    port = int(os.environ.get("PORT", 8080))
    print(f"⚙️ Starting Flask on port {port}")
    app.run(host='0.0.0.0', port=port, debug=True)
