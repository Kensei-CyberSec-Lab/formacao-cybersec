# 🚨 Lab IDS/IPS com Suricata + Scirius UI

## 📋 Visão Geral

Este laboratório prático demonstra **Intrusion Detection System (IDS)** e **Intrusion Prevention System (IPS)** usando Suricata. Você aprenderá:

- **IDS**: Detecção de ataques e atividades suspeitas
- **IPS**: Bloqueio automático de tráfego malicioso
- **Regras customizadas**: Criação e teste de regras de detecção
- **Análise de logs**: Interpretação de alertas e eventos
- **Interface web**: Gerenciamento via Scirius UI

## 🏗️ Arquitetura

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Kali Linux    │    │    Suricata     │    │   Web Victim    │
│   (Atacante)    │────│    (IDS/IPS)    │────│   (Nginx)       │
│ 192.168.25.11   │    │ 192.168.25.10   │    │ 192.168.25.20   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
                    ┌─────────────────┐    ┌─────────────────┐
                    │     Scirius     │    │    Postgres     │
                    │      (UI)       │────│     (DB)        │
                    │ 192.168.25.30   │    │ 192.168.25.31   │
                    └─────────────────┘    └─────────────────┘
                                │
                                ▼
                    ┌─────────────────┐
                    │     EveBox      │
                    │   (Visualizer)  │
                    │ 192.168.25.40   │
                    └─────────────────┘
```

### 📊 Tabela de Serviços

| Serviço | IP | Porta | Descrição |
|---------|----|-------|-----------|
| Suricata | 192.168.25.10 | - | IDS/IPS principal |
| Kali | 192.168.25.11 | - | Máquina atacante |
| Web Victim | 192.168.25.20 | 8088 | Servidor web vulnerável |
| Scirius | 192.168.25.30 | 8080 | Interface web de gerenciamento |
| Postgres | 192.168.25.31 | - | Banco de dados |
| EveBox | 192.168.25.40 | 5636 | Visualizador de eventos |

## ⚙️ Pré-requisitos

- Docker e Docker Compose instalados
- 4GB RAM livre
- Portas 8080, 5636, 8088 disponíveis
- macOS/Linux (Apple Silicon compatível)

## 🚀 Como Subir (Rápido)

```bash
# Clone o repositório
git clone <seu-repo>
cd lab_4

# Perfil básico (Suricata + Kali + Web)
docker compose --profile suricata-core up -d

# Perfil completo (inclui Scirius UI)
docker compose --profile suricata-scirius up -d
```

### ✅ Validação

```bash
# Verificar containers rodando
docker ps

# Verificar logs do Suricata
docker logs suricata_lab

# Verificar rede
docker network ls | grep lab_net
```

## 🎯 Cenários Didáticos

### Cenário 1: Tráfego Benigno

**Objetivo**: Verificar que tráfego normal não gera alertas.

```bash
# Acessar página principal (deve ser silencioso)
curl http://192.168.25.20/

# Verificar logs (deve estar vazio ou com poucos eventos)
tail -f ./suricata/logs/eve.json
```

**Resultado esperado**: Mínimo de alertas, apenas logs de conexão HTTP.

### Cenário 2: Probe/Scan

**Objetivo**: Detectar tentativas de reconhecimento.

```bash
# Entrar no container Kali
docker exec -it kali_lab bash

# Scan básico de portas
nmap -sS 192.168.25.20

# Ping para gerar tráfego ICMP
ping -c 3 192.168.25.20
```

**Resultado esperado**: Alertas de scan SYN e ICMP Echo.

### Cenário 3: Regras Customizadas

**Objetivo**: Testar regras específicas de detecção.

```bash
# Acesso à área administrativa (deve disparar regra 1000001)
curl http://192.168.25.20/admin

# Tentativa de XSS (deve disparar regra 1000002)
curl "http://192.168.25.20/search?q=<script>alert('xss')</script>"

# SQL Injection (deve disparar regra 1000003)
curl "http://192.168.25.20/search?q=' OR '1'='1"

# POST com password (deve disparar regra 1000004)
curl -X POST http://192.168.25.20/login -d "user=admin&password=123456"
```

**Verificação**:
```bash
# Ver alertas em tempo real
docker logs -f suricata_lab

# Ver eventos detalhados
tail -f ./suricata/logs/eve.json | grep "alert"
```

### Cenário 4: Interface Scirius (Opcional)

**Objetivo**: Gerenciar regras via interface web.

```bash
# Subir perfil completo
docker compose --profile suricata-scirius up -d

# Acessar interface
open http://localhost:8080
# ou
curl http://localhost:8080
```

**Funcionalidades**:
- Visualizar regras ativas
- Gerenciar conjuntos de regras
- Analisar eventos e alertas
- Configurar Suricata

### Cenário 5: EveBox (Opcional)

**Objetivo**: Visualizar eventos de forma gráfica.

```bash
# Acessar EveBox
open http://localhost:5636
# ou
curl http://localhost:5636
```

**Configuração**:
- Apontar para `./suricata/logs/eve.json`
- Filtrar por tipo de evento
- Analisar padrões de tráfego

## 🔧 Modo IPS (Opcional)

Para habilitar modo **Prevention** (bloqueio automático):

### 1. Backup da configuração atual
```bash
cp suricata/suricata.yaml suricata/suricata-ids.yaml
```

### 2. Ativar configuração IPS
```bash
cp suricata/suricata-ips.yaml suricata/suricata.yaml
```

### 3. Reiniciar Suricata
```bash
docker restart suricata_lab
```

### 4. Teste de bloqueio
```bash
# Criar regra de bloqueio
echo 'drop http any any -> 192.168.25.20 any (msg:"[BLOCK] Admin access blocked"; content:"/admin"; http_uri; sid:1000008; rev:1;)' >> ./suricata/rules/local.rules

# Recarregar regras
docker exec suricata_lab suricata --reload-rules

# Testar (deve retornar erro de conexão)
curl http://192.168.25.20/admin
```

### 5. Voltar para modo IDS
```bash
cp suricata/suricata-ids.yaml suricata/suricata.yaml
docker restart suricata_lab
```

**⚠️ Importante**: Modo IPS requer configuração de iptables/nftables. Teste em ambiente isolado primeiro!

## 🚨 Troubleshooting

### Rede não sobe
```bash
# Resetar rede Docker
docker network prune -f
docker compose down
docker compose up -d
```

### Permissões de capabilities
```bash
# Verificar se Suricata tem NET_ADMIN
docker exec suricata_lab cat /proc/self/status | grep CapEff
```

### Apple Silicon (M1/M2)
```bash
# Se houver problemas, usar imagem x86_64
# Em docker-compose.yml, adicionar:
# platform: linux/amd64
```

### Conflito de portas
```bash
# Verificar portas em uso
lsof -i :8080
lsof -i :5636
lsof -i :8088
```

## 🧹 Encerramento & Limpeza

```bash
# Parar todos os serviços
docker compose down

# Remover volumes e logs
docker compose down -v
rm -rf ./suricata/logs/*

# Limpeza completa
docker system prune -f
```

## 🏆 Desafios Extra (Nota Bônus)

### Desafio 1: Regra de User-Agent
```bash
# Criar regra para bloquear User-Agent específico
echo 'alert http any any -> 192.168.25.20 any (msg:"[BONUS] User-Agent malicioso"; content:"sqlmap"; http_user_agent; sid:1000009; rev:1;)' >> ./suricata/rules/local.rules

# Testar
curl -H "User-Agent: sqlmap/1.0" http://192.168.25.20/
```

### Desafio 2: Detecção de Password
```bash
# Regra já existe (1000004), mas teste com variações:
curl -X POST http://192.168.25.20/login -d "username=admin&pwd=secret"
curl -X POST http://192.168.25.20/auth -d "login=user&pass=123456"
```

### Desafio 3: Análise Offline
```bash
# Gerar PCAP de teste
docker exec web_victim tcpdump -w /tmp/test.pcap -i eth0 port 80 &

# Fazer algumas requisições
curl http://192.168.25.20/admin
curl http://192.168.25.20/search?q=<script>

# Parar capture
docker exec web_victim pkill tcpdump

# Analisar com Suricata offline
docker exec suricata_lab suricata -r /tmp/test.pcap -c /etc/suricata/suricata.yaml
```

## 📚 Recursos Adicionais

- [Documentação Suricata](https://suricata.readthedocs.io/)
- [Regras Snort/Suricata](https://rules.emergingthreats.net/)
- [Scirius Community Edition](https://github.com/StamusNetworks/scirius)
- [EveBox](https://github.com/jasonish/evebox)

---

**🎯 Objetivo do Lab**: Compreender na prática como IDS/IPS detecta e previne ataques, criando e testando regras customizadas em ambiente controlado.
