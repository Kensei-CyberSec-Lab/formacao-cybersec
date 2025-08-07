# 🔥 Laboratório de Firewall - Defesa e Monitoramento

## ⚡ Início Rápido (5 minutos)

```bash
# 1. Execute o script de setup
./scripts/setup-lab.sh

# 2. Acesse a interface gráfica
# Navegador: http://localhost:6080
# VNC: localhost:5901 (senha: kenseilab)

# 3. Teste a conectividade
docker exec -it kali_lab_19 /opt/lab-tools/test-lab.sh

# 4. Configure o firewall na interface gráfica
sudo iptables -L  # Ver regras atuais
```

## 📚 Objetivo do Laboratório

Este laboratório prático tem como objetivo ensinar os conceitos fundamentais de firewall e controle de acesso à rede através do **iptables** no Linux. Você aprenderá a:

- Configurar regras de firewall para proteger sistemas
- Bloquear ataques maliciosos
- Permitir tráfego legítimo e essencial
- Gerar logs para auditoria e diagnóstico
- Testar e validar configurações de segurança

---

## Desafio da Aula: Firewall na Prática

### O Cenário
Você é o **administrador de rede** de uma empresa e precisa proteger um servidor Ubuntu contra ataques vindos de uma máquina Kali Linux. Sua missão é:

1. **Bloquear ataques maliciosos** vindos do Kali
2. **Permitir o tráfego legítimo** (HTTP, conexões estabelecidas)

---

## 🏗️ Arquitetura do Laboratório

| Container     | Papel                        | IP                  | Função                    |
|---------------|------------------------------|---------------------|---------------------------|
| `kali_lab_19` | 🎯 **Máquina Atacante**      | 192.168.100.11      | Simula um atacante        |
| `ubuntu_lab_19` | 🛡️ **Servidor Alvo**        | 192.168.100.10      | Servidor a ser protegido  |
| `ubuntu_gui`  | 🖥️ **Interface Gráfica**     | 192.168.100.12      | Estação de trabalho       |

### Topologia de Rede:
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Kali Linux    │    │   Ubuntu CLI    │    │   Ubuntu GUI    │
│  (Atacante)     │    │   (Alvo)        │    │  (Estação)      │
│                 │    │                 │    │                 │
│ 192.168.100.11  │◄──►│ 192.168.100.10  │◄──►│ 192.168.100.12  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

---

## Passo a Passo: Configurando o Ambiente

### 1. Iniciando o Laboratório

```bash
# Clone ou navegue até o diretório do laboratório
cd lab_3

# Inicie todos os containers
docker-compose up -d

# Verifique se todos os containers estão rodando
docker ps
```

**Resultado esperado:**
```
CONTAINER ID   IMAGE                    COMMAND           CREATED         STATUS         PORTS                    NAMES
abc123...      kalilinux/kali-rolling   "sleep infinity"  2 minutes ago   Up 2 minutes                            kali_lab_19
def456...      ubuntu:22.04             "sleep infinity"  2 minutes ago   Up 2 minutes                            ubuntu_lab_19
ghi789...      consol/ubuntu-xfce-vnc   "/startup.sh"     2 minutes ago   Up 2 minutes   0.0.0.0:6080->6901/tcp   ubuntu_gui
```

### 2. Acessando a Interface Gráfica

Você tem duas opções para acessar o Ubuntu com interface gráfica:

#### Opção A: Via Navegador (Recomendado)
1. Abra seu navegador
2. Acesse: `http://localhost:6080`
3. Use as credenciais:
   - **Usuário:** `root`
   - **Senha:** `kenseilab`

#### Opção B: Via VNC Viewer
1. Instale um cliente VNC (como VNC Viewer)
2. Conecte em: `localhost:5901`
3. Use a senha: `kenseilab`

### 3. Preparando o Ambiente de Trabalho

Para verificar se tudo está funcionando:

```bash
# Na interface gráfica (Ubuntu GUI):
sudo iptables -L          # Ver regras
# iptables-gui -L           # Script wrapper
# /opt/lab-scripts/test-firewall.sh  # Teste completo

# Via container Ubuntu:
docker exec -it ubuntu_lab_19 bash
iptables -L               # Já como root

# Via container Kali:
docker exec -it kali_lab_19 bash
/opt/lab-tools/test-lab.sh  # Teste de conectividade
```

---

## Passo a Passo: Configurando o Firewall

### Fase 1: Análise Inicial (Antes das Regras)

Primeiro, vamos testar a conectividade **antes** de aplicar as regras de firewall:

#### 1.1 Testando SSH do Kali para o Ubuntu

```bash
# Acesse o terminal do Kali (já configurado)
docker exec -it kali_lab_19 bash

# ✅ TUDO JÁ ESTÁ INSTALADO E CONFIGURADO!
# - SSH client: ✅ Instalado
# - nmap: ✅ Instalado
# - Ferramentas de rede: ✅ Instaladas

# Teste conectividade com o Ubuntu
ping -c 3 192.168.100.10

# Teste SSH (deve funcionar inicialmente)
ssh root@192.168.100.10
# Digite 'yes' para aceitar a chave
# Digite 'exit' para sair

# OU use o script de teste automático:
/opt/lab-tools/test-lab.sh
```

#### 1.2 Verificando Portas Abertas

```bash
# No Kali, escaneie as portas do Ubuntu
nmap -sS -p- 192.168.100.10

# Teste HTTP (se houver serviço web)
curl http://192.168.100.10
```

### Fase 2: Configurando as Regras de Firewall

Agora vamos configurar o firewall no Ubuntu para protegê-lo:

#### 2.1 Acessando o Ubuntu Alvo

```bash
# Acesse o terminal do Ubuntu (já configurado)
docker exec -it ubuntu_lab_19 bash

# ✅ TUDO JÁ ESTÁ INSTALADO E CONFIGURADO!
# - iptables: ✅ Instalado
# - SSH: ✅ Instalado e rodando
# - Ferramentas: ✅ nmap, curl, wget, sudo, etc.

# Verificar se SSH está rodando
service ssh status

# Se não estiver rodando, inicie:
service ssh start
```

#### 2.2 Aplicando as Regras de Firewall

Execute as seguintes regras **uma por vez** e entenda o que cada uma faz:

```bash
# 1. Limpar todas as regras existentes
iptables -F
iptables -X

# 2. Definir política padrão: NEGAR TUDO (princípio de segurança)
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# 3. Permitir conexões já estabelecidas (importante!)
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# 4. Permitir tráfego local (loopback)
iptables -A INPUT -i lo -j ACCEPT

# 5. Permitir HTTP (porta 80) - tráfego legítimo
iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# 6. BLOQUEAR SSH do Kali (192.168.100.11) - ataque malicioso
iptables -A INPUT -s 192.168.100.11 -p tcp --dport 22 -j DROP

# 7. Permitir SSH de outros IPs (opcional - para administração)
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# 8. Adicionar logging para auditoria
iptables -A INPUT -s 192.168.100.11 -j LOG --log-prefix "BLOCKED_KALI: "
```

#### 2.3 Verificando as Regras Aplicadas

```bash
# Ver todas as regras configuradas
iptables -L -v -n

# Ver regras com números de linha
iptables -L --line-numbers

# Ver estatísticas
iptables -L -v
```

### Fase 3: Testando as Regras (Depois)

Agora vamos testar se as regras estão funcionando:

#### 3.1 Testando Bloqueio do SSH

```bash
# No Kali, tente conectar via SSH novamente
ssh root@192.168.100.10
# Deve ser BLOQUEADO!
```

#### 3.2 Testando Conectividade

```bash
# No Kali, teste ping (deve funcionar)
ping -c 3 192.168.100.10

# Teste HTTP (deve funcionar se houver serviço)
curl http://192.168.100.10

# Escaneie portas novamente
nmap -sS -p- 192.168.100.10
```

# Parar todos os containers
docker-compose down