# 🐳 Lab Aula 31 – Container Security (Docker Bench & Trivy)

Este laboratório demonstra como avaliar a **segurança de containers** usando duas ferramentas essenciais:  
- **Docker Bench for Security** → verifica a configuração do host Docker.  
- **Trivy** → escaneia imagens de containers em busca de vulnerabilidades, misconfigs e secrets.  

---

## 📦 Serviços no Lab

| Container       | Papel                                | Observações                          |
|-----------------|--------------------------------------|--------------------------------------|
| `juice_shop`    | Aplicação web vulnerável OWASP       | Alvo para análise com Trivy           |
| `kali_lab_31`   | Máquina atacante/analista (Kali)     | Executa scans com Trivy               |

Rede isolada: `172.31.0.0/24`  

---

## 🚀 Como subir o ambiente

### Opção 1: Script automatizado (Recomendado)
```bash
cd formacao-cybersec/modulo2-defesa-monitoramento/lab_5
./run_lab.sh
```

### Opção 2: Manual
```bash
cd formacao-cybersec/modulo2-defesa-monitoramento/lab_5
docker compose up -d --build
```

Verifique se os containers estão ativos:
```bash
docker ps
```

🌐 **Juice Shop estará disponível em:** http://localhost:3000

---

## 🔍 Passo 1 – Rodando Trivy no Juice Shop

**Trivy já está pré-instalado no container Kali!** Execute diretamente:

### Para entrar no container Kali:
```bash
docker exec -it kali_lab_31 bash
```

### Scan completo:
```bash
trivy image bkimminich/juice-shop
```

### Apenas vulnerabilidades críticas e altas:
```bash
trivy image --severity HIGH,CRITICAL bkimminich/juice-shop
```


👉 Saída esperada:  
- Lista de **CVEs** encontrados.  
- Severidade (Baixo, Médio, Alto, Crítico).  
- Exemplos de vulnerabilidades em dependências Node.js.  

---

## 📊 Passo 1.5 – Gerando Relatórios Profissionais

**Novo!** O lab agora inclui scripts avançados para gerar relatórios profissionais:

### Comandos disponíveis:
```bash
# Relatório HTML completo
docker exec -it kali_lab_31 trivy_report.sh --format html bkimminich/juice-shop

# Relatório em múltiplos formatos
docker exec -it kali_lab_31 trivy_report.sh --format all bkimminich/juice-shop

# Scan rápido (apenas críticas e altas)
docker exec -it kali_lab_31 trivy_report.sh --quick bkimminich/juice-shop

# Relatório avançado com Python
docker exec -it kali_lab_31 generate_report.py bkimminich/juice-shop --format all
```

🎯 **Formatos disponíveis:**
- **HTML** - Relatório visual com gráficos e análise de risco
- **JSON** - Dados estruturados para análise automática  
- **CSV** - Tabela para análise em planilhas
- **TXT** - Relatório em texto simples

📁 **Os relatórios são salvos em:** `./reports/` (acessível do host)

### 🌐 Visualizando Relatórios:

#### Script automatizado:
```bash
./view_reports.sh
```

#### Manualmente:
```bash
# Abrir HTML no navegador
open reports/*.html

# Servidor web para visualizar HTML
python3 -m http.server 8080 --directory reports
# Acesse: http://localhost:8080

# Analisar CSV no Excel/LibreOffice
open reports/*.csv

# Resumo em terminal
grep -E 'HIGH|CRITICAL' reports/*.txt
```

---

## 🧹 Limpeza e Manutenção

### Script de limpeza:
```bash
./cleanup.sh --help     # Ver opções
./cleanup.sh --all      # Limpeza completa  
./cleanup.sh --reports  # Limpar relatórios
./cleanup.sh --status   # Status do lab
```

---

## 🛡️ Passo 2 – Rodando Docker Bench no Host

O **Docker Bench** precisa rodar diretamente no host Docker (não dentro do Kali). 

### Script automatizado (Recomendado):
```bash
./docker-bench.sh
```

### Opção manual (se o script falhar):
```bash
# Método 1: Docker oficial
docker run --rm -it --net host --pid host --userns host --cap-add audit_control \
  -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
  -v /var/lib:/var/lib:ro \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v /usr/lib/systemd:/usr/lib/systemd:ro \
  -v /etc:/etc:ro \
  --label docker_bench_security \
  docker/docker-bench-security

# Método 2: Script direto
git clone https://github.com/docker/docker-bench-security.git
cd docker-bench-security
sudo sh docker-bench-security.sh
```

👉 Saída esperada:  
- Checks "PASS" e "WARN".  
- Exemplos de alertas: containers rodando como root, ausência de user namespaces, falta de configuração de logging.

---

## 📑 Missão do Lab

### Parte 1: Análise de Vulnerabilidades
1. **Execute scan completo do Trivy** no Juice Shop
2. **Gere relatório HTML profissional** usando os scripts fornecidos
3. **Identifique 5 CVEs críticos** (CVSS ≥ 9.0) encontrados
4. **Analise os secrets** expostos no código

### Parte 2: Docker Bench Security  
5. **Execute Docker Bench** no host (se possível)
6. **Identifique 3 findings críticos** de configuração

### Parte 3: Plano de Remediação
7. **Elabore um plano 80/20** baseado nos achados:
   - 🚨 **Ações imediatas** (20% esforço, 80% impacto)
   - 📋 **Mitigações médio prazo** 
   - 🔄 **Ações contínuas** (automação, monitoramento)

### Entregáveis:
- ✅ Relatórios gerados (HTML + JSON/CSV)
- 📊 Screenshots dos principais achados
- 📝 Documento com plano de remediação
- 💡 Recomendações de segurança para containers

**Dica:** Use os relatórios HTML gerados para facilitar a análise e documentação!

---

## 📂 Estrutura de Arquivos

```
lab_5_container_security/
├── docker-compose.yml          # Configuração dos containers
├── Dockerfile.kali            # Imagem Kali customizada com Trivy
├── README.md                  # Este guia completo

├── run_lab.sh                # Script de setup automatizado
├── cleanup.sh                # Script de limpeza e manutenção
├── docker-bench.sh           # Script para Docker Bench Security
├── view_reports.sh           # Script para visualizar relatórios
├── scripts/                  # Scripts de geração de relatórios
│   ├── trivy_report.sh       # Gerador de relatórios (bash)
│   └── generate_report.py    # Gerador avançado (Python)
└── reports/                  # Relatórios gerados (mapeado do container)
    ├── *.html               # Relatórios visuais interativos
    ├── *.json               # Dados estruturados para APIs
    ├── *.csv                # Planilhas para análise
    └── *.txt                # Relatórios texto simples
```

---

✅ Agora é só praticar e proteger seus containers!
