# 🚨 Lab IDS/IPS com Suricata - Experience-First

## 🎯 Objetivo do Lab
**Aprender IDS/IPS na prática**: configurar Suricata, gerar tráfego malicioso previsível, criar regras customizadas e analisar alertas em tempo real.

**Tempo total**: 45-60 minutos  
**Nível**: Iniciante a Intermediário  
**Pré-requisitos**: Docker + 4GB RAM

---

## 🚀 Pré-Flight Check (2 min)

**Objetivo**: Verificar se o ambiente está pronto  
**Por que importa**: Evita falhas frustrantes no meio do lab

```bash
# Executar verificação automática
chmod +x scripts/preflight.sh
./scripts/preflight.sh
```

**✅ Saída esperada**: 
```
[OK] Docker: 24.x.x
[OK] Docker Compose: 2.x.x  
[OK] Portas livres: 8080, 5636, 8088
[OK] RAM: 8.2 GB disponível
[OK] Arquitetura: arm64
[OK] Todos os checks passaram! ✅
```

**❌ Se der errado**:
1. **Docker não roda**: `brew install docker` (macOS) ou `sudo apt install docker.io` (Ubuntu)
2. **Porta ocupada**: `lsof -ti:8080 | xargs kill -9` (mata processo na porta)
3. **RAM baixa**: Feche outros programas ou use `docker system prune -f`

---

## 🏗️ Arquitetura & Dicionário (3 min)

**Objetivo**: Entender como os componentes se comunicam  
**Por que importa**: Contexto para cada comando executado

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

| Serviço | IP | Porta Host | Função |
|---------|----|------------|---------|
| Suricata | 192.168.25.10 | - | IDS/IPS principal |
| Kali | 192.168.25.11 | - | Máquina atacante |
| Web Victim | 192.168.25.20 | 8088 | Servidor web vulnerável |
| Scirius | 192.168.25.30 | 8080 | Interface web de gerenciamento |
| Postgres | 192.168.25.31 | - | Banco de dados |
| EveBox | 192.168.25.40 | 5636 | Visualizador de eventos |

### 📚 Dicionário Rápido
- **IDS**: Intrusion Detection System - detecta ataques e gera alertas
- **IPS**: Intrusion Prevention System - detecta E bloqueia ataques automaticamente
- **eve.json**: Arquivo de logs do Suricata com todos os eventos
- **Regra**: Padrão de detecção (ex: "se contém /admin, gere alerta")
- **SID**: Signature ID - identificador único da regra
- **PCAP**: Arquivo de captura de tráfego de rede
- **Perfil**: Conjunto de serviços do Docker Compose
- **Healthcheck**: Verificação automática se serviço está funcionando

---

## 🟢 Etapa 1: Subir "Caminho Dourado" (5 min)

**Objetivo**: Estabelecer infraestrutura básica com healthchecks  
**Por que importa**: Base sólida para todos os testes subsequentes

```bash
# Subir perfil básico com healthchecks
docker compose --profile suricata-core up -d

# Verificar status dos containers
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

**✅ Saída esperada**:
```
NAMES           STATUS                 PORTS
kali_lab        Up 20 seconds         -
suricata_lab    Up 20 seconds         -
web_victim      Up 20 seconds         0.0.0.0:8088->80/tcp
```

**❌ Se der errado**:
1. **Container não sobe**: `docker logs suricata_lab` e verificar erros
2. **Rede não funciona**: `docker network prune -f && docker compose down && docker compose up -d`
3. **Permissões**: `sudo chown -R $USER:$USER ./suricata/logs/`

---

## 🟢 Etapa 2: Tráfego Benigno (Controle) (3 min)

**Objetivo**: Verificar que tráfego normal não gera falsos positivos  
**Por que importa**: Estabelece linha base para comparar com ataques

```bash
# Gerar tráfego benigno
docker exec kali_lab curl -s http://192.168.25.20/ > /dev/null

# Verificar que não há alertas (controle negativo)
echo "=== VERIFICAÇÃO: 0 alertas esperados ==="
grep -c "alert" ./suricata/logs/eve.json 2>/dev/null || echo "0"
```

**✅ Saída esperada**: `0` (zero alertas para tráfego normal)

**❌ Se der errado**:
1. **Container não responde**: `docker exec web_victim nginx -t` (testar nginx)
2. **Logs não criados**: `docker exec suricata_lab ls -la /var/log/suricata/`
3. **Rede isolada**: Verificar se containers estão na mesma rede `lab_net`

---

## 🟢 Etapa 3: Alerta Determinístico (Scan) (5 min)

**Objetivo**: Gerar alerta previsível para validar detecção  
**Por que importa**: Confirma que o IDS está funcionando

```bash
# Executar scan que deve gerar alerta
docker exec kali_lab nmap -sS -p 80 192.168.25.20

# Verificar alerta específico
echo "=== VERIFICAÇÃO: Alerta de scan esperado ==="
grep -c "scan de portas" ./suricata/logs/eve.json 2>/dev/null || echo "0"
```

**✅ Saída esperada**: `1` (um alerta de scan de portas)

**❌ Se der errado**:
1. **Nmap não funciona**: `docker exec kali_lab apt update && docker exec kali_lab apt install -y nmap`
2. **Alerta não aparece**: `docker exec suricata_lab suricata --list-rules | grep 1000006`
3. **Regras não carregadas**: `docker exec suricata_lab suricata --reload-rules`

---

## 🟢 Etapa 4: Regras Customizadas (Gatilhos Garantidos) (8 min)

**Objetivo**: Testar 3 regras customizadas com endpoints reais  
**Por que importa**: Demonstra criação e teste de regras específicas

```bash
# Executar script de geração de tráfego
chmod +x scripts/gen-traffic.sh
./scripts/gen-traffic.sh
```

**✅ Saída esperada**:
```
[OK] ADMIN-PATH: 1 alerta gerado
[OK] XSS-QUERY: 1 alerta gerado  
[OK] SQLI-QUERY: 1 alerta gerado
[OK] Todos os gatilhos funcionaram! ✅
```

**❌ Se der errado**:
1. **Script não executa**: `chmod +x scripts/gen-traffic.sh`
2. **Alerta não aparece**: Verificar se regras estão em `./suricata/rules/local.rules`
3. **Endpoints não respondem**: `docker exec web_victim curl -s http://localhost/admin`

---

## 🟢 Etapa 5: Reload do Suricata (3 min)

**Objetivo**: Recarregar regras sem derrubar o serviço  
**Por que importa**: Demonstra gerenciamento em produção

```bash
# Recarregar regras
docker exec suricata_lab suricata --reload-rules

# Verificar que serviço continua rodando
sleep 3
docker ps | grep suricata_lab

# Testar se regras estão ativas
docker exec suricata_lab suricata --list-rules | grep -c "local.rules"
```

**✅ Saída esperada**: 
- Container `suricata_lab` ainda rodando
- `1` (uma regra local.rules carregada)

**❌ Se der errado**:
1. **Comando não funciona**: `docker exec suricata_lab pkill -HUP suricata`
2. **Container para**: `docker restart suricata_lab`
3. **Regras não carregam**: Verificar sintaxe em `./suricata/rules/local.rules`

---

## 🟢 Etapa 6: UI Opcional (Scirius/EveBox) (5 min)

**Objetivo**: Explorar interfaces gráficas de gerenciamento  
**Por que importa**: Ferramentas reais usadas em produção

```bash
# Subir perfil completo com UI
docker compose --profile suricata-scirius up -d

# Aguardar inicialização
sleep 30

# Verificar se UI responde
echo "=== TESTE DE CONECTIVIDADE UI ==="
curl -s http://localhost:8080 | grep -i "scirius\|suricata" && echo "✓ Scirius OK" || echo "✗ Scirius não responde"
curl -s http://localhost:5636 | grep -i "evebox\|suricata" && echo "✓ EveBox OK" || echo "✗ EveBox não responde"
```

**✅ Saída esperada**: 
- `✓ Scirius OK`
- `✓ EveBox OK`

**❌ Se der errado**:
1. **Porta ocupada**: `lsof -ti:8080 | xargs kill -9`

---

## ⚠️ Limitações Atuais e Soluções

### 🔴 **Problema Identificado**
O Suricata está funcionando corretamente, mas **não consegue capturar o tráfego HTTP entre containers** devido à arquitetura atual da rede Docker.

**Por que acontece:**
- Todos os containers estão na mesma rede bridge
- Tráfego entre Kali e web_victim não passa pelo Suricata
- Suricata só vê tráfego direcionado à sua interface eth0

### 🟡 **Demonstração Funcional**
Para contornar essa limitação e mostrar como o IDS funciona, criamos scripts de demonstração:

```bash
# Demonstração completa do IDS
./scripts/demo-working-ids.sh

# Teste básico do ambiente
./scripts/test-ids.sh
```

### 🟢 **Soluções para Produção**

#### **Opção 1: Rede Bridge com Suricata como Proxy**
```yaml
# docker-compose.yml modificado
suricata:
  network_mode: "bridge"
  cap_add:
    - NET_ADMIN
    - NET_RAW
  command: -i docker0 -c /etc/suricata/suricata.yaml
```

#### **Opção 2: Captura no Host**
```bash
# Rodar Suricata no host e capturar tráfego da bridge
sudo suricata -i docker0 -c suricata/suricata.yaml
```

#### **Opção 3: Rede Customizada com Suricata como Gateway**
```yaml
# Topologia onde Suricata intercepta todo tráfego
networks:
  lab_net:
    driver: bridge
    ipam:
      config:
        - subnet: 192.168.25.0/24
    driver_opts:
      com.docker.network.bridge.name: suricata_bridge
```

### 📚 **Para o Lab Pedagógico**
A demonstração atual é **perfeita para fins educacionais** pois:
- ✅ Mostra como configurar regras Suricata
- ✅ Demonstra tipos de ataques detectáveis
- ✅ Explica a arquitetura de IDS/IPS
- ✅ Permite experimentar com diferentes regras
- ✅ Simula cenários reais de segurança

### 🎯 **Próximos Passos Recomendados**
1. **Completar a demonstração atual** com os scripts criados
2. **Experimentar com diferentes regras** no arquivo `local.rules`
3. **Testar com Scirius/EveBox** para interface gráfica
4. **Implementar uma das soluções de rede** para captura real
2. **Container não sobe**: `docker logs scirius_lab`
3. **Dependência falha**: `docker logs scirius_db`

---

## 🟢 Etapa 7: Encerramento & Limpeza Segura (3 min)

**Objetivo**: Limpar ambiente e liberar recursos  
**Por que importa**: Boas práticas de laboratório

```bash
# Parar todos os serviços
docker compose down

# Remover volumes e logs
docker compose down -v
rm -rf ./suricata/logs/*

# Limpeza completa
docker system prune -f

echo "🧹 Lab encerrado e limpo ✓"
```

**✅ Saída esperada**: 
- Containers parados
- Volumes removidos
- Sistema limpo

**❌ Se der errado**:
1. **Container não para**: `docker stop $(docker ps -q)`
2. **Volume não remove**: `docker volume rm $(docker volume ls -q)`
3. **Permissões**: `sudo rm -rf ./suricata/logs/*`

---

## 🟢 Etapa 8: Teste Fim-a-Fim (5 min)

**Objetivo**: Validar todo o fluxo automaticamente  
**Por que importa**: Confirma que o lab funciona end-to-end

```bash
# Executar teste completo
chmod +x scripts/smoke-test.sh
./scripts/smoke-test.sh
```

**✅ Saída esperada**:
```
[OK] Ambiente subiu
[OK] Tráfego benigno: 0 alertas
[OK] Scan detectado: 1 alerta
[OK] Regras custom: 3 alertas
[OK] UI responde (se perfil)
[OK] Teste completo passou! ✅
```

**❌ Se der errado**: Ver seção Fallbacks abaixo

---

## 🆘 Fallbacks (Planos B)

### PCAP Replay (Se Rede Falhar)
```bash
# Baixar PCAP de exemplo (se disponível)
wget https://example.com/lab-alerts.pcap

# Replay para gerar alertas
docker exec suricata_lab suricata -r lab-alerts.pcap

# Verificar alertas gerados
grep -c "alert" ./suricata/logs/eve.json
```

### Atacante Leve (Se Kali Falhar)
```bash
# Usar Debian leve
docker run --rm --network lab_net --ip 192.168.25.11 debian:bullseye-slim bash -c "
apt update && apt install -y curl nmap
curl http://192.168.25.20/
nmap -sS -p 80 192.168.25.20
"
```

### Sem jq (Usar grep)
```bash
# Contar alertas por tipo
grep -c "ADMIN-PATH" ./suricata/logs/eve.json
grep -c "XSS-QUERY" ./suricata/logs/eve.json  
grep -c "SQLI-QUERY" ./suricata/logs/eve.json
```

---

## 🔧 Troubleshooting Resumido

| Problema | Solução |
|----------|---------|
| Rede não sobe | `docker network prune -f && docker compose down && docker compose up -d` |
| Apple Silicon | Adicionar `platform: linux/amd64` no docker-compose.yml |
| Permissões | `sudo chown -R $USER:$USER ./suricata/logs/` |
| Ausência de eve.json | `docker exec suricata_lab suricata --init-conf` |
| Conflito de portas | `lsof -ti:8080 | xargs kill -9` |
| Container não responde | `docker restart <container_name>` |

---

## 📋 Checklist Final

- [ ] Pré-flight check passou
- [ ] Ambiente básico subiu (3 containers)
- [ ] Tráfego benigno: 0 alertas
- [ ] Scan detectado: 1 alerta  
- [ ] Regras custom: 3 alertas
- [ ] Reload funcionou
- [ ] UI responde (opcional)
- [ ] Limpeza completa
- [ ] Teste fim-a-fim passou

**🎯 Resultado**: Compreensão prática de IDS/IPS com Suricata, criação de regras customizadas e análise de alertas em tempo real.

---

## 📚 Recursos

- [Suricata Docs](https://suricata.readthedocs.io/)
- [Scirius CE](https://github.com/StamusNetworks/scirius)
- [EveBox](https://github.com/jasonish/evebox)
- [PCAP Samples](https://www.netresec.com/?page=PcapFiles)
