# Lab 2 – Hardening Progressivo de Servidor Linux (Ubuntu)

## 🎯 Objetivo

Aplicar técnicas progressivas de **hardening** em um servidor Ubuntu, simulando práticas reais de defesa, validando acessos em cada etapa a partir de uma máquina Kali Linux.

---

## ✅ Etapas do Lab

### 1. Clone o projeto e acesse a pasta
```bash
git clone https://github.com/Kensei-CyberSec-Lab/formacao-cybersec.git
cd formacao-cybersec/modulo2-defesa/lab_2
```

### 2. Verifique a configuração do `docker-compose.yml`

- `ubuntu_lab_2` (IP: `172.20.0.10`)
- `kali_lab_2` (IP: `172.20.0.20`)
- Rede `labnet` com subnet `172.20.0.0/24`

### 3. Suba os containers
```bash
docker compose up -d
```

---

## 🔓 Etapa 1 – Acesso Inseguro via Root e Senha

Do Kali, conecte-se ao Ubuntu usando root e senha:
```bash
docker exec -it kali_lab_2 bash
ssh root@172.20.0.10
# Senha: rootlab
```

> Isso demonstra um acesso inseguro que será bloqueado ao final.

---

## 👤 Etapa 2 – Criar Usuário Não-root com Sudo

No Ubuntu:
```bash
docker exec -it ubuntu_lab_2 bash
adduser defensor
usermod -aG sudo defensor
```

Teste o novo usuário a partir do Kali:
```bash
ssh defensor@172.20.0.10
# Digite a senha criada
```

---

## 🔐 Etapa 3 – Habilitar Acesso por Chave Privada

### No Ubuntu (criar chave como defensor):
```bash
sudo -u defensor ssh-keygen -t rsa -b 4096 -f /home/defensor/.ssh/id_rsa -N ""
sudo -u defensor bash -c "cat /home/defensor/.ssh/id_rsa.pub >> /home/defensor/.ssh/authorized_keys"
chmod 700 /home/defensor/.ssh
chmod 600 /home/defensor/.ssh/authorized_keys
chown -R defensor:defensor /home/defensor/.ssh
```

### No host: transferir a chave privada para o Kali
```bash
docker cp ubuntu_lab_2:/home/defensor/.ssh/id_rsa ./id_rsa_defensor
chmod 600 id_rsa_defensor
docker cp ./id_rsa_defensor kali_lab_2:/root/.ssh/id_rsa_defensor
```

### No Kali: testar o acesso com chave
```bash
docker exec -it kali_lab_2 bash
chmod 600 ~/.ssh/id_rsa_defensor
ssh -i ~/.ssh/id_rsa_defensor defensor@172.20.0.10
```

---

## 🔒 Etapa 4 – Desabilitar Root e Autenticação por Senha

No Ubuntu:
```bash
nano /etc/ssh/sshd_config
# Edite ou adicione:
PermitRootLogin no
PasswordAuthentication no

# Reinicie o SSH:
service ssh restart
```

---

## 🧱 Etapa 5 – Firewall, Limpeza e Permissões

```bash
apt update && apt install -y ufw
ufw allow OpenSSH
ufw --force enable

apt remove telnet -y
chmod 640 /etc/shadow
```

---

## 🔁 Testes Finais

### Acesso por senha deve falhar:
```bash
ssh root@172.20.0.10         # ← bloqueado
ssh defensor@172.20.0.10     # ← bloqueado
```

### Acesso por chave deve funcionar:
```bash
ssh -i ~/.ssh/id_rsa_defensor defensor@172.20.0.10
```

---

## ✅ Checklist

- [x] Acesso root por senha desativado
- [x] Usuário sudo criado
- [x] Login por chave ativado
- [x] Firewall (UFW) ativado
- [x] Serviços e permissões revisadas

---

## 🏁 Missão Cumprida

Você viu como um servidor sai de um estado inseguro e gradualmente se torna mais protegido. Cada etapa pode ser validada com testes reais de conexão.
