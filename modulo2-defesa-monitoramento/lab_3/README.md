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

## 🎯 Desafio da Aula: Firewall na Prática

### O Cenário
Você é o **administrador de rede** de uma empresa e precisa proteger um servidor Ubuntu contra ataques vindos de uma máquina Kali Linux. Sua missão é:

1. **Bloquear ataques maliciosos** vindos do Kali
2. **Permitir o tráfego legítimo** (HTTP, conexões estabelecidas)
3. **Gerar logs detalhados** para auditoria e diagnóstico

### O que você deve entregar:
- ✅ Regras de firewall configuradas
- ✅ Capturas de tela (prints) do antes e depois
- ✅ Descrição da estratégia e princípios utilizados

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

## ✅ Pré-requisitos

Antes de começar, certifique-se de ter:

- [ ] **Docker** instalado e funcionando
- [ ] **Docker Compose** instalado
- [ ] Portas `6080` e `5901` livres no seu sistema
- [ ] Conhecimento básico de Linux e redes

### Verificando os pré-requisitos:

```bash
# Verificar se o Docker está instalado
docker --version

# Verificar se o Docker Compose está instalado
docker-compose --version

# Verificar se as portas estão livres
netstat -tuln | grep -E ":(6080|5901)"
```

---

## 🚀 Passo a Passo: Configurando o Ambiente

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

**✅ AMBIENTE PRÉ-CONFIGURADO!** 

Os containers já vêm com todas as ferramentas necessárias instaladas e configuradas. O script de setup automatiza todo o processo.

#### 🔒 Configurações Automáticas Incluídas:

**Container Ubuntu GUI:**
- ✅ iptables e iptables-persistent instalados
- ✅ sudo configurado para usuário `defaultuser`
- ✅ Script wrapper `iptables-gui` criado
- ✅ Script de teste `/opt/lab-scripts/test-firewall.sh`
- ✅ Ferramentas de rede (nmap, curl, wget, etc.)

**Container Kali:**
- ✅ sshpass instalado para automação SSH
- ✅ Script de teste de conectividade
- ✅ Ferramentas de pentesting (metasploit, nmap, etc.)

**Container Ubuntu:**
- ✅ SSH server configurado e rodando
- ✅ iptables instalado
- ✅ Scripts de exemplo copiados

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

## 📖 Conceitos Teóricos Importantes

### O que é um Firewall?
Um **firewall** é um sistema de segurança que monitora e controla o tráfego de rede baseado em regras predefinidas. Funciona como uma "barreira" entre redes confiáveis e não confiáveis.

### Como funciona o iptables?
O **iptables** é o firewall padrão do Linux que usa **tabelas** e **cadeias** para filtrar pacotes:

#### Tabelas Principais:
- **filter**: Filtragem de pacotes (padrão)
- **nat**: Network Address Translation
- **mangle**: Modificação de pacotes

#### Cadeias da Tabela Filter:
- **INPUT**: Pacotes destinados ao próprio sistema
- **OUTPUT**: Pacotes originados do próprio sistema
- **FORWARD**: Pacotes que passam pelo sistema (roteador)

#### Políticas Padrão:
- **ACCEPT**: Permitir o tráfego
- **DROP**: Descartar o pacote silenciosamente
- **REJECT**: Rejeitar o pacote com mensagem de erro

---

## 🔧 Passo a Passo: Configurando o Firewall

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

**📸 TIRE UM PRINT** dos resultados para comparar depois!

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

#### 3.2 Verificando Logs

```bash
# No Ubuntu, verifique os logs
tail -f /var/log/syslog | grep BLOCKED_KALI
```

#### 3.3 Testando Conectividade

```bash
# No Kali, teste ping (deve funcionar)
ping -c 3 192.168.100.10

# Teste HTTP (deve funcionar se houver serviço)
curl http://192.168.100.10

# Escaneie portas novamente
nmap -sS -p- 192.168.100.10
```

**📸 TIRE UM PRINT** dos resultados para comparar com o antes!

---

## 🎯 Desafio Prático

### Objetivo
Configure regras de firewall que implementem a **política de segurança** da empresa:

### Requisitos:
1. **Bloquear completamente** o acesso SSH do Kali (192.168.100.11) ao Ubuntu
2. **Permitir** tráfego HTTP (porta 80)
3. **Permitir** conexões já estabelecidas
4. **Gerar logs** de todas as tentativas de acesso bloqueadas
5. **Permitir** SSH de outros IPs para administração

### Regras Sugeridas:
```bash
# Suas regras aqui...
iptables -F
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Adicione suas regras personalizadas aqui
```

### Testes Obrigatórios:
- [ ] SSH do Kali → Ubuntu (deve ser BLOQUEADO)
- [ ] Ping do Kali → Ubuntu (deve FUNCIONAR)
- [ ] HTTP do Kali → Ubuntu (deve FUNCIONAR)
- [ ] SSH de outro IP → Ubuntu (deve FUNCIONAR)
- [ ] Logs de tentativas bloqueadas (deve APARECER)

---

## 📊 Análise e Documentação

### O que documentar:

#### 1. Regras Aplicadas
```bash
# Cole aqui suas regras finais
iptables -L -v -n
```

#### 2. Testes Realizados
| Teste | Antes | Depois | Status |
|-------|-------|--------|--------|
| SSH Kali→Ubuntu | ✅ | ❌ | Bloqueado |
| Ping Kali→Ubuntu | ✅ | ✅ | Funciona |
| HTTP Kali→Ubuntu | ❓ | ❓ | ? |
| SSH Outro IP→Ubuntu | ❓ | ❓ | ? |

#### 3. Logs Capturados
```bash
# Cole aqui os logs de tentativas bloqueadas
grep BLOCKED_KALI /var/log/syslog
```

#### 4. Screenshots
- [ ] Print da tela antes das regras
- [ ] Print da tela depois das regras
- [ ] Print dos logs de bloqueio
- [ ] Print dos testes de conectividade

---

## 🧠 Princípios de Segurança Aplicados

### 1. **Princípio do Menor Privilégio**
- Negar tudo por padrão
- Permitir apenas o necessário

### 2. **Defesa em Profundidade**
- Múltiplas camadas de proteção
- Logs para auditoria

### 3. **Fail-Safe**
- Se algo der errado, o sistema fica seguro
- Política padrão DROP

### 4. **Monitoramento Contínuo**
- Logs de todas as tentativas
- Auditoria de acessos

---

## 🔍 Troubleshooting

### ⚠️ Problemas Comuns e Soluções

#### 1. **Permissões de Root / Sudo não encontrado**
```bash
# PROBLEMA: "sudo: command not found" ou "Permission denied"
# SOLUÇÃO: Use o usuário root diretamente

# No container Ubuntu:
su -                    # Virar root
# OU
docker exec -it ubuntu_lab_19 bash  # Já entra como root

# Execute comandos sem sudo:
apt update && apt upgrade -y
iptables -L
```

#### 2. **"Connection refused" no SSH**
```bash
# Verifique se o SSH está rodando
service ssh status

# Inicie se necessário
service ssh start

# Verifique se a porta 22 está aberta
netstat -tuln | grep :22
```

#### 3. **Regras de firewall não funcionam**
```bash
# Verifique a ordem das regras
iptables -L --line-numbers

# As regras são processadas em ordem!
# Regras mais específicas devem vir ANTES das gerais

# Verifique se as regras foram aplicadas
iptables -L -v -n
```

#### 4. **Logs não aparecem**
```bash
# Verifique se o logging está ativo
dmesg | grep BLOCKED

# Ou
tail -f /var/log/syslog

# Verifique se a regra de logging foi adicionada
iptables -L | grep LOG
```

#### 5. **Container não responde**
```bash
# Reinicie o container
docker restart ubuntu_lab_19

# Verifique se está rodando
docker ps

# Verifique logs do container
docker logs ubuntu_lab_19
```

#### 6. **Problemas de conectividade**
```bash
# Teste ping entre containers
docker exec kali_lab_19 ping -c 3 192.168.100.10
docker exec ubuntu_lab_19 ping -c 3 192.168.100.11

# Verifique se a rede está funcionando
docker network ls
docker network inspect lab_3_cybersec_lab_19
```

### 🔧 Script de Troubleshooting Automatizado

Para diagnóstico automático de problemas:

```bash
# Execute o script de troubleshooting
./scripts/troubleshooting.sh
```

Este script irá:
- ✅ Verificar se todos os containers estão rodando
- ✅ Testar conectividade de rede
- ✅ Verificar serviços essenciais
- ✅ Diagnosticar problemas de permissões
- ✅ Sugerir correções automáticas
- ✅ Mostrar comandos úteis

---

## 📚 Comandos Úteis para o Laboratório

### Gerenciamento de Containers:
```bash
# Ver containers rodando
docker ps

# Acessar terminal do Kali
docker exec -it kali_lab_19 bash

# Acessar terminal do Ubuntu
docker exec -it ubuntu_lab_19 bash

# Parar todos os containers
docker-compose down

# Reiniciar containers
docker-compose restart
```

### Comandos iptables:
```bash
# Ver regras
iptables -L -v -n

# Ver regras com números
iptables -L --line-numbers

# Ver estatísticas
iptables -L -v

# Salvar regras (Ubuntu)
iptables-save > /etc/iptables/rules.v4

# Carregar regras
iptables-restore < /etc/iptables/rules.v4
```

### Testes de Conectividade:
```bash
# Ping
ping -c 3 192.168.100.10

# SSH
ssh root@192.168.100.10

# Nmap
nmap -sS -p- 192.168.100.10

# Curl
curl http://192.168.100.10
```

---

## 🎓 Conclusão

Ao final deste laboratório, você terá:

✅ **Compreendido** os conceitos fundamentais de firewall  
✅ **Configurado** regras de segurança com iptables  
✅ **Testado** e validado configurações de proteção  
✅ **Implementado** logging para auditoria  
✅ **Aplicado** princípios de segurança em rede  

### Próximos Passos:
- Explore regras mais avançadas (rate limiting, NAT)
- Configure firewalls em outros sistemas
- Implemente IDS/IPS
- Estude ferramentas como UFW e firewalld

---

## 🛠️ Scripts e Ferramentas

### Setup Automatizado (Recomendado)
```bash
# Executar setup completo do laboratório
./scripts/setup-lab.sh
```
**✅ Inclui:**
- Build dos containers personalizados
- Instalação automática de todas as ferramentas
- Configuração do SSH
- Scripts de configuração rápida

### Configuração Rápida (Dentro dos Containers)
```bash
# No Ubuntu: Configurar firewall rapidamente
docker exec -it ubuntu_lab_19 /opt/lab-scripts/quick-setup.sh

# No Kali: Testar conectividade
docker exec -it kali_lab_19 /opt/lab-tools/test-lab.sh
```

### Teste de Configurações
```bash
# Testar se as regras de firewall estão funcionando
./scripts/test-firewall.sh
```

### Troubleshooting
```bash
# Diagnosticar e corrigir problemas
./scripts/troubleshooting.sh
```

### Exemplo de Configuração
```bash
# Ver exemplo de regras de firewall
cat scripts/iptables-example.sh
```

## 📚 Documentação Adicional

- **[Checklist do Laboratório](docs/checklist-laboratorio.md)** - Acompanhe seu progresso
- **[Exemplos Práticos](docs/exemplos-praticos.md)** - Casos de uso avançados
- **[Solução de Problemas](docs/solucao-problemas.md)** - Guia rápido para problemas comuns
- **[Script de Setup](scripts/setup-lab.sh)** - Configuração automatizada
- **[Script de Teste](scripts/test-firewall.sh)** - Validação das configurações
- **[Script de Troubleshooting](scripts/troubleshooting.sh)** - Diagnóstico e correção de problemas

## 📞 Suporte

Se encontrar problemas:
1. Execute o script de setup: `./scripts/setup-lab.sh`
2. Execute o script de teste: `./scripts/test-firewall.sh`
3. Verifique os logs do Docker: `docker-compose logs`
4. Reinicie os containers: `docker-compose restart`
5. Consulte a documentação do iptables
6. Peça ajuda no grupo do WhatsApp

**Bom estudo e boa sorte no desafio! 🚀**
