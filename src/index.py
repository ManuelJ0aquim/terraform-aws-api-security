import json

def lambda_handler(event, context):
    client_ip = (
        event.get("requestContext", {})
        .get("identity", {})
        .get("sourceIp")
    )

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({
            "message": "Acesso autorizado pelo AWS WAF!",
            "client_ip": client_ip
        })
    }