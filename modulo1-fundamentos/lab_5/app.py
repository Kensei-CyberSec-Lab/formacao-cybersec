from flask import Flask, request, jsonify

app = Flask(__name__)

# Endpoint da página inicial (GET)
@app.route('/')
def home():
    user_agent = request.headers.get('User-Agent')
    remote_addr = request.remote_addr
    return (
        f"<h1>Bem-vind@ ao Kensei Web Server!</h1>"
        f"<p>Este é um servidor simples para testar a captura de tráfego.</p>"
        f"<p>Seu User-Agent: {user_agent}</p>"
        f"<p>Seu IP de origem: {remote_addr}</p>"
        f"<p>Parabéns, você conseguiu alcançar o alvo! 🎯</p>"
        f"<ul>"
        f"<li><a href='/secret'>Página Secreta (GET)</a></li>"
        f"<li><a href='/login_form'>Simular Login (POST)</a></li>"
        f"</ul>"
    )

# Endpoint de página secreta (GET)
@app.route('/secret')
def secret():
    return "<h3>Shhh... esta é uma página secreta! Apenas para admin.</h3><p>Voltar para <a href='/'>Home</a></p>"

# Endpoint para exibir formulário de login (GET)
@app.route('/login_form')
def login_form():
    return '''
        <h1>Simular Login</h1>
        <form method="POST" action="/do_login">
            <label for="username">Usuário:</label><br>
            <input type="text" id="username" name="username" value="testuser"><br>
            <label for="password">Senha:</label><br>
            <input type="password" id="password" name="password" value="testpass"><br><br>
            <input type="submit" value="Login">
        </form>
        <p>Voltar para <a href='/'>Home</a></p>
    '''

# Endpoint para processar o login (POST)
@app.route('/do_login', methods=['POST'])
def do_login():
    username = request.form.get('username')
    password = request.form.get('password')

    if username == "admin" and password == "kensei123":
        return jsonify({"status": "success", "message": f"Bem-vindo, {username}!"})
    else:
        return jsonify({"status": "fail", "message": "Credenciais inválidas."})

if __name__ == '__main__':
    # Rodar o Flask em todas as interfaces na porta 8080
    app.run(host='0.0.0.0', port=8080)