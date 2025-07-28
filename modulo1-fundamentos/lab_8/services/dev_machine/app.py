# services/dev_machine/app.py
# Aplicação Flask simples para a máquina do dev.
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Ambiente de desenvolvimento. Cuidado!'