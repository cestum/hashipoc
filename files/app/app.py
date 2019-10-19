import os
import sys
from flask import Flask
import hvac
import json
app = Flask(__name__)

@app.route('/')
def hello_world():
    port = os.getenv('NOMAD_PORT_http', 8000)
    arg = None
    if len(sys.argv) > 1:
        arg = sys.argv[1]
    token = os.getenv('VAULT_TOKEN', None)
    data = {}
    err = None
    if token:
        try:
            client = hvac.Client(url='http://active.vault.service.consul:8200', token=os.environ['VAULT_TOKEN'])
            data = client.read('secret/data/password')
            if data is not None and 'data' in data and 'data' in data['data'] and 'value' in data['data']['data']:
                data = data['data']['data']['value']
        except Exception as err:
            data = {}
    return '[%s] Hello, World: %s with a vault token of: %s and secret: %s (err=%s)\n' % (port, arg, token, data, err)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=os.getenv('NOMAD_PORT_http', 8000))

