# 🛡️ Tutorial Completo - Lab de Segurança WAF + DVWA

Este tutorial te guia passo a passo para executar o laboratório completo de defesa e monitoramento, demonstrando ataques controlados e resposta com WAF ModSecurity.

## 📋 Índice
1. [Pré-requisitos](#pré-requisitos)
2. [Configuração Inicial](#configuração-inicial)
3. [Subindo o Ambiente](#subindo-o-ambiente)
4. [Verificação dos Containers](#verificação-dos-containers)
5. [Configuração do DVWA](#configuração-do-dvwa)
6. [Reconhecimento (Nmap)](#reconhecimento-nmap)
7. [Teste no Modo Detecção](#teste-no-modo-detecção)
8. [Teste no Modo Blocking](#teste-no-modo-blocking)
9. [Monitoramento com Dozzle](#monitoramento-com-dozzle)
10. [Coleta de Evidências](#coleta-de-evidências)
11. [Solução de Problemas](#solução-de-problemas)

---

## 📦 Pré-requisitos

Antes de começar, certifique-se de ter:

- **Docker** e **Docker Compose** instalados
- **Navegador web** (Chrome, Firefox, Safari)
- **Terminal** (macOS Terminal, Windows PowerShell, Linux Terminal)
- Conexão com a internet para baixar as imagens Docker

### Verificar Docker
```bash
docker --version
docker-compose --version
```

---

## ⚙️ Configuração Inicial

### 1. Navegar para o Diretório do Lab
```bash
cd ./labs
```

### 2. Verificar Arquivos Necessários
Certifique-se de que existem estes arquivos:
```
labs/
├── docker-compose.yml
├── Dockerfile.kali
├── scripts/
│   ├── attack_script.sh
│   └── monitor_defense.sh
└── README.md
```

---

## 🚀 Subindo o Ambiente

### 1. Iniciar Todos os Containers
```bash
docker compose up -d --build
```

**O que acontece:**
- 🐧 **Kali Linux**: Container atacante com ferramentas de pentest
- 🛡️ **WAF ModSecurity**: Firewall de aplicação web com OWASP CRS
- 🎯 **DVWA**: Aplicação web vulnerável (alvo)
- 📊 **Dozzle**: Interface para monitorar logs em tempo real

### 2. Aguardar Inicialização
Espere alguns segundos para todos os containers estarem prontos.

---

## ✅ Verificação dos Containers

### 1. Verificar Status dos Containers
```bash
docker ps
```

**Resultado esperado:**
```
CONTAINER ID   IMAGE                              PORTS                    NAMES
xxxxxxxxxx     owasp/modsecurity-crs:nginx-alpine 0.0.0.0:8080->8080/tcp  waf_modsec
xxxxxxxxxx     labs-kali_lab35                                             kali_lab35
xxxxxxxxxx     vulnerables/web-dvwa               80/tcp                   dvwa
xxxxxxxxxx     amir20/dozzle:latest               0.0.0.0:9999->8080/tcp  dozzle
```

### 2. Testar Conectividade
```bash
curl -s http://localhost:8080 | head -5
```

**Se funcionar:** Você verá HTML do DVWA
**Se não funcionar:** Veja a seção [Solução de Problemas](#solução-de-problemas)

---

## 🎯 Configuração do DVWA

### 1. Acessar DVWA no Navegador
Abra seu navegador e vá para: **http://localhost:8080**

### 2. Fazer Login
- **Usuário:** `admin`
- **Senha:** `password`

### 3. Configurar Banco de Dados
1. Após login, clique em **"Setup"** (menu lateral)
2. Clique em **"Create / Reset Database"**
3. Aguarde a mensagem de sucesso

### 4. Configurar Nível de Segurança
1. Clique em **"DVWA Security"** (menu lateral)
2. Selecione **"Low"**
3. Clique em **"Submit"**

**🔥 Importante:** Mantenha o navegador aberto para manter a sessão ativa!

---

## 🔍 Reconhecimento (Nmap)

### 1. Entrar no Container Kali
```bash
docker exec -it kali_lab35 /bin/bash
```

### 2. Executar Scan Nmap
```bash
nmap -sS -sV waf_modsec
```

**Resultado esperado:**
```
PORT     STATE SERVICE  VERSION
8080/tcp open  http     nginx
8443/tcp open  ssl/http nginx
```

### 3. Sair do Container
```bash
exit
```

**📝 Explicação:** O nmap identifica que o WAF está rodando nginx nas portas 8080 (HTTP) e 8443 (HTTPS).

---

## 🕵️ Teste no Modo Detecção

### 1. Configurar WAF para Modo Detecção
Edite o arquivo `docker-compose.yml` e certifique-se de que a linha esteja assim:
```yaml
- MODSEC_RULE_ENGINE=DetectionOnly  # modo detecção apenas
```

### 2. Recriar o Container WAF
```bash
docker compose up -d --force-recreate waf_modsec
```

### 3. Testar Ataque SQLi (Deve Passar)
```bash
docker exec kali_lab35 curl -s "http://waf_modsec:8080/vulnerabilities/sqli/?id=1'+OR+'1'='1'--+-&Submit=Submit" \
  -H "Host: dvwa" \
  -H "Cookie: PHPSESSID=test; security=low" \
  -w "Status: %{http_code}\n"
```

**Resultado esperado:** Status 302 (redirecionamento) - **ATAQUE DETECTADO MAS NÃO BLOQUEADO**

### 4. Testar Ataque XSS (Deve Passar)
```bash
docker exec kali_lab35 curl -s "http://waf_modsec:8080/vulnerabilities/xss_r/?name=%3Cscript%3Ealert%28%22XSS%22%29%3C/script%3E" \
  -H "Host: dvwa" \
  -H "Cookie: security=low" \
  -w "Status: %{http_code}\n"
```

**Resultado esperado:** Status 302 (redirecionamento) - **ATAQUE DETECTADO MAS NÃO BLOQUEADO**

---

## 🚫 Teste no Modo Blocking

### 1. Configurar WAF para Modo Blocking
Edite o arquivo `docker-compose.yml` e altere para:
```yaml
- MODSEC_RULE_ENGINE=On  # modo blocking (bloqueia ataques)
```

### 2. Recriar o Container WAF
```bash
docker compose up -d --force-recreate waf_modsec
```

### 3. Testar Ataque SQLi (Deve ser Bloqueado)
```bash
docker exec kali_lab35 curl -s "http://waf_modsec:8080/vulnerabilities/sqli/?id=1'+OR+'1'='1'--+-&Submit=Submit" \
  -H "Host: dvwa" \
  -H "Cookie: PHPSESSID=test; security=low" \
  -w "Status: %{http_code}\n"
```

**Resultado esperado:** Status 403 + página "403 Forbidden" - **ATAQUE BLOQUEADO!**

### 4. Testar Ataque XSS (Deve ser Bloqueado)
```bash
docker exec kali_lab35 curl -s "http://waf_modsec:8080/vulnerabilities/xss_r/?name=%3Cscript%3Ealert%28%22XSS%22%29%3C/script%3E" \
  -H "Host: dvwa" \
  -H "Cookie: security=low" \
  -w "Status: %{http_code}\n"
```

**Resultado esperado:** Status 403 + página "403 Forbidden" - **ATAQUE BLOQUEADO!**

---

## 📊 Monitoramento com Dozzle

### 1. Acessar Interface Dozzle
Abra seu navegador e vá para: **http://localhost:9999**

### 2. Fazer Login no Dozzle
- **Usuário:** `admin`
- **Senha:** `admin`

### 3. Visualizar Logs do WAF
1. Clique no container **"waf_modsec"**
2. Observe os logs em tempo real
3. Execute novos ataques e veja as detecções aparecerem

### 4. Analisar Logs Estruturados
Procure por estas informações importantes:
- **`"secrules_engine":"DetectionOnly"`** ou **`"secrules_engine":"Enabled"`**
- **Rule IDs:** 942100 (SQLi), 941100 (XSS)
- **HTTP Status Codes:** 302 (detecção) vs 403 (bloqueio)

---

## 📋 Coleta de Evidências

### 1. Capturar Logs Detalhados
```bash
docker logs waf_modsec --tail 50 > logs_waf_evidencias.txt
```

### 2. Fazer Screenshots
Capture telas do:
- ✅ Dozzle mostrando logs de detecção
- ✅ Dozzle mostrando logs de bloqueio
- ✅ Resultado do nmap
- ✅ Páginas 403 Forbidden

### 3. Documentar Timeline NIST IR
1. **Detecção:** Timestamp dos logs de detecção
2. **Análise:** Identificação dos tipos de ataque
3. **Contenção:** Ativação do modo blocking
4. **Erradicação:** Bloqueio efetivo dos ataques

---

## 🛠️ Solução de Problemas

### Container não sobe
```bash
# Verificar logs de erro
docker logs waf_modsec
docker logs dvwa

# Recriar tudo do zero
docker compose down
docker compose up -d --build
```

### DVWA não carrega
```bash
# Verificar se header Host está correto
curl -v "http://localhost:8080/login.php" -H "Host: dvwa"
```

### WAF não bloqueia
```bash
# Verificar configuração
docker exec waf_modsec env | grep MODSEC_RULE_ENGINE

# Deve mostrar: MODSEC_RULE_ENGINE=On (para blocking)
```

### Dozzle não acessa
```bash
# Verificar se porta está disponível
docker ps | grep dozzle

# Deve mostrar: 0.0.0.0:9999->8080/tcp
```

---

## 🎯 Objetivos do Lab

Ao completar este tutorial, você terá demonstrado:

✅ **Reconhecimento:** Identificação de serviços com nmap  
✅ **Ataques Controlados:** SQLi e XSS contra aplicação vulnerável  
✅ **Detecção:** WAF identificando ataques sem bloquear  
✅ **Proteção:** WAF bloqueando ataques maliciosos  
✅ **Monitoramento:** Logs estruturados em tempo real  
✅ **Resposta:** Transição de detecção para bloqueio  

---

## 📚 Referências Técnicas

- **ModSecurity:** https://modsecurity.org/
- **OWASP CRS:** https://owasp.org/www-project-modsecurity-core-rule-set/
- **DVWA:** https://dvwa.co.uk/
- **NIST IR Framework:** https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-61r2.pdf

---

## 🎓 Próximos Passos

1. **Criar Relatório:** Use o template `RELATORIO-template.md`

**🏆 Parabéns! Você completou um laboratório completo de segurança ofensiva e defensiva!**
