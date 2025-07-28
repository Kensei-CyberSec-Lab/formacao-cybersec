# 🛠️ Docker Recon Lab (Reconhecimento)

Ambiente de laboratório com target e Kali pré-configurados para coletar informações iniciais.

---

## 📦 Estrutura de arquivos

```
docker-recon-lab/
├── docker-compose.yml
├── target/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app.py
└── kali-full/
    └── Dockerfile
```

---

## 🚀 Instruções de uso

```bash
docker compose build
docker compose up -d
docker compose run --rm kali bash
```

---

## 🔍 Fluxo de Reconhecimento – Explicado

### 1. `ping -c1 lab_target`

- **O que faz?**  
  Envia 1 pacote ICMP para verificar se o host `lab_target` está acessível.
- **Para que serve?**  
  Confirma se o alvo está ativo na rede.
- **Resultado esperado:**  
  "1 packets received"

---

### 2. `nmap -sS -sV -O lab_target`

- **O que faz?**
  - `-sS`: Varredura stealth para descobrir portas abertas.
  - `-sV`: Detecta versões dos serviços.
  - `-O`: Identifica o sistema operacional.
- **Para que serve?**  
  Descobrir portas, serviços (como HTTP), e sistema operacional do alvo.
- **Resultado esperado:**  
  Exemplo: `80/tcp open http Werkzeug/2.3.0`, `OS: Linux`

---

### 3. `curl -I http://lab_target/`

- **O que faz?**  
  Envia um pedido HEAD para visualizar apenas os cabeçalhos HTTP.
- **Para que serve?**  
  Revela o servidor e tecnologias em uso.
- **Resultado esperado:**  
  ```
  HTTP/1.0 200 OK
  Server: Werkzeug/2.3.0 Python/3.11
  ```

---

### 4. `gobuster dir -u http://lab_target/ -w /usr/share/dirb/wordlists/common.txt`

- **O que faz?**  
  Faz brute-force em diretórios e arquivos do site.
- **Para que serve?**  
  Descobrir rotas ocultas como `/admin`, `/secret`, `/login`.
- **Resultado esperado:**  
  ```
  /secret              (Status: 200)
  ```

---

## ✅ Resumo dos Comandos

| Comando                           | Descobre...                       |
|----------------------------------|-----------------------------------|
| `ping`                           | Se o host está online             |
| `nmap -sS -sV -O`                | Portas abertas, serviços e SO     |
| `curl -I`                        | Qual servidor HTTP está rodando   |
| `gobuster`                       | Diretórios e arquivos ocultos     |

---

## 📝 Entregáveis (para desafio de aula)

- **Prints** dos comandos acima
- **Narrativa** explicando:
  - Alvo, vetor inicial, serviços descobertos, diretórios, próximos passos

---

Boa exploração! 🧠
