from json import loads, dumps
from base64 import b64decode
from gzip import decompress

from os import environ, getenv

from http.client import HTTPSConnection

def send_message(fields):
    bot_name = getenv("BOT_NAME") or "midnight witch"

    bot_image = environ["BOT_IMAGE"]

    alert_hook = environ["ALERT_HOOK"]

    message = dumps({
        "username": bot_name,
        "avatar_url": bot_image,
        "content": None,
        "embeds": [
            {
                "title": "Alerta de falha em servico",
                "description": "-------------------------------------",
                "color": 15548997,
                "fields": fields
            }
        ],
        "attachments": []
    }).encode()

    conn = HTTPSConnection("discord.com")

    headers = {
        "Content-Type": "multipart/form-data; boundary=---011000010111000001101001"
    }

    payload = b"-----011000010111000001101001\r\nContent-Disposition: form-data; name=\"payload_json\"\r\n\r\n"+message+b"\r\n-----011000010111000001101001--\r\n"

    conn.request("POST", alert_hook, payload, headers)

    res = conn.getresponse()
    print(res.read().decode("utf-8"), flush=True)
    res.close()

    conn.close()

def main(event, context):
    try:
        event_data = event["awslogs"]["data"]

        dados_da_funcao = loads(decompress(b64decode(event_data.encode())))

        grupo_de_log = dados_da_funcao["logGroup"]

        log_stream = dados_da_funcao["logStream"]

        mensagem = dados_da_funcao["logEvents"][0]["message"]

        max_message_length = getenv("MAX_MESSAGE_LENGTH") or 1000

        if len(mensagem) > max_message_length:
            mensagem = "Mensagem de erro grande de mais para enviar no discord. Cofira o cloudwatch."

        fields = [
            {
                "name": "Path do log do servico",
                "value": grupo_de_log
            },
            {
                "name": "Stream de logs",
                "value": log_stream
            },
            {
                "name": "Mensagem",
                "value": mensagem
            },
            {
                "name": "Ambiente",
                "value": environ["ENVIRONMENT"]
            }
        ]

    except KeyError:
        print("nao achei os eventos do logs. presumindo sns")

        target_group_name = loads(event["Records"][0]["Sns"]["Message"])["Trigger"]["Metrics"][0]["Expression"].split("app/")[1].split("/")[0]

        mensagem = f"o load balancer do {target_group_name} reportou falha no health check. verifique o servico"

        fields = [
            {
                "name": "nome do servico",
                "value": target_group_name
            },
            {
                "name": "Mensagem",
                "value": mensagem
            },
            {
                "name": "Ambiente",
                "value": environ["ENVIRONMENT"]
            }
        ]

    print(f"enviando dados:\n{fields}", flush=True)

    send_message(fields)