from flask import Flask, jsonify, request

app = Flask(__name__)

@app.route("/")
def index():
    return "<h1>Recon Lab</h1><p>Host: lab_target | Porta 80 aberta.</p>"

@app.route("/secret")
def secret():
    token = request.args.get("token", "")
    return jsonify({
        "message": "Você chegou até aqui!",
        "token": token
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80, debug=False)