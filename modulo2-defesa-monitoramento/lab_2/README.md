# README.md – Lab 2: Desafio de Hardening de Servidor Linux

## Objetivo do Desafio

Aplicar hardening básico em um servidor Ubuntu exposto, simulando práticas reais de defesa e testando o acesso via Kali Linux.

---

## ✅ Etapas para Executar o Desafio

### 1. Clone o projeto e acesse a pasta
```bash
git clone https://github.com/Kensei-CyberSec-Lab/formacao-cybersec.git
cd formacao-cybersec/modulo2-defesa/lab_2
```

### 2. Verifique se o `docker-compose.yml` inclui:
- Servidor Ubuntu (`ubuntu_lab_2`) com IP `172.20.0.10`
- Kali Linux (`kali_lab_2`) com IP `172.20.0.20`
- Rede `labnet` com subnet `172.20.0.0/24`

### 3. Suba os containers
```bash
docker compose up -d
```

### 4. Acesse o Kali e tente conectar por SSH ao Ubuntu
```bash
docker exec -it kali_lab_2 bash
ssh root@172.20.0.10
# senha: rootlab
```

---

## 🔧 Aplique o Hardening no Ubuntu

Acesse o Ubuntu:
```bash
docker exec -it ubuntu_lab_2 bash
```

### Passo 1 – Criar usuário defensor
```bash
adduser defensor
usermod -aG sudo defensor
```

### Passo 2 – Configurar autenticação por chave pública
No Kali:
```bash
ssh-keygen -t rsa -b 4096
ssh-copy-id defensor@172.20.0.10
```

### Passo 3 – Desabilitar login root e senha via SSH
No Ubuntu:
```bash
nano /etc/ssh/sshd_config
# Edite ou adicione:
PermitRootLogin no
PasswordAuthentication no

systemctl restart ssh
```

### Passo 4 – Ativar firewall (UFW)
```bash
apt update && apt install -y ufw
ufw allow OpenSSH
ufw --force enable
```

### Passo 5 – Remover pacotes desnecessários
```bash
apt remove telnet -y
```

### Passo 6 – Corrigir permissões de arquivos sensíveis
```bash
chmod 640 /etc/shadow
```

---

## 🔁 Valide o Resultado Final

No Kali, tente:
```bash
ssh root@172.20.0.10
# → Deve falhar

ssh defensor@172.20.0.10
# → Deve funcionar com chave
```

---

## 🎯 Conclusão

Você:
- Criou um usuário seguro
- Bloqueou root e senhas no SSH
- Aplicou autenticação por chave
- Ativou firewall
- Reduziu a superfície de ataque

**Servidor endurecido com sucesso. Missão cumprida.**