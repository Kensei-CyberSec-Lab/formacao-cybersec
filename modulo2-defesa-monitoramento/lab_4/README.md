# 🛠️ Lab – Patch Management Automatizado (Docker + Trivy)

Este lab demonstra **como automatizar identificação e correção de vulnerabilidades** em containers, usando **Trivy** para _scan_ e uma estratégia simples de **patch via atualização de imagem base**.

> Objetivo: partir de uma imagem **vulnerável** (`bullseye`) e **reduzir CVEs** trocando para uma base **mais nova e enxuta** (`bookworm-slim`). Você verá como integrar o scan ao ciclo de build e **quebrar o pipeline** quando houver CVEs **CRÍTICOS/ALTOS**.

---

## 📦 Estrutura

```
lab-aula-27-patch-mgmt/
├─ app/
│  ├─ Dockerfile.bullseye        # versão inicial (mais CVEs)
│  ├─ Dockerfile.patched         # versão "com patch" (menos CVEs)
│  ├─ Dockerfile.zero-cves       # versão com ZERO vulnerabilidades
│  ├─ requirements.txt           # app Flask mínimo
│  ├─ requirements-fixed.txt     # dependências sem CVEs
│  └─ app.py                     # hello world
├─ docker-compose.yml            # sobe o app para teste
├─ scripts/
│  ├─ scan.sh                    # roda Trivy (image e fs)
│  ├─ patch.sh                   # aplica patch trocando Dockerfile
│  ├─ python-fix.sh              # aplica patch nas dependências Python
│  └─ policy.trivy.yaml          # política de severidade/aceitação
├─ .trivyignore                  # ignora findings conhecidos (exemplo)
└─ Makefile                      # automações locais
```

---

## 🚀 Pré-requisitos

- Docker / Docker Compose
- Trivy (local) **ou** use o container `aquasec/trivy:latest`
- (Opcional) `make` para usar os atalhos

Instalação (Linux/macOS):
```bash
# Trivy local (opcional; se não quiser, o script usa o container)
# https://aquasecurity.github.io/trivy/latest/getting-started/installation/
```

---

## ▶️ Passo a passo rápido

```bash
# 1) Build da versão vulnerável (bullseye)
make build
make up

# 2) Scan da imagem e do filesystem (gera relatórios em ./reports)
make scan

# 3) Aplicar "patch" (troca para base bookworm-slim) e rebuild
make patch
make rebuild
make scan

# 4) Validar na prática: CVEs devem reduzir
```

Se quiser **quebrar o processo** automaticamente quando houver CVEs CRÍTICOS/ALTOS, o `scan.sh` retorna **exit code 1** nesses casos (usando `--exit-code 1`). Isso permite integrar em CI/CD.

---

## 🔍 Como o patch funciona aqui?

- **Antes (vulnerável):** `FROM python:3.11-bullseye`
- **Depois (patch):** `FROM python:3.11-bookworm-slim`

Ambas constroem o mesmo app Flask. A diferença é a **imagem base** (distro e atualização), que costuma reduzir CVEs.

> Em projetos reais, além de atualizar a base, você deve **fixar versões**, rodar `apt-get update && apt-get upgrade -y` com parcimônia, e revalidar o app.

---

## 🧪 Validando o resultado

- Compare os relatórios em `./reports/` antes e depois do `make patch`.
- Busque a tendência: **menos CRÍTICOS/ALTOS** após o patch.

> Dica: Use `--format table` ou `--format sarif/json` para integrar com dashboards.

---

## 🎯 Next Steps (Opcional) - Eliminar Vulnerabilidades Python

Após aplicar o patch da imagem base, ainda restam **4 vulnerabilidades HIGH** nos pacotes Python (`gunicorn` e `setuptools`). Para eliminar **100% das vulnerabilidades**:

### 🐍 **Opção 1: Script Automático**

```bash
# Aplica patch das dependências Python automaticamente
make python-fix
make rebuild
make scan
```

### 🔧 **Opção 2: Manual**

1. **Atualizar requirements.txt:**
```bash
# Versões sem vulnerabilidades conhecidas
flask==3.0.2
gunicorn==23.0.0  # era 21.2.0 (CVE-2024-1135, CVE-2024-6827)
```

2. **Criar Dockerfile.zero-cves:**
```dockerfile
FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive PIP_NO_CACHE_DIR=1 \
    PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1

# Atualizar setuptools para eliminar CVE-2024-6345, CVE-2025-47273
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates && \
    pip install --upgrade pip setuptools==78.1.1 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY app.py .
EXPOSE 5000
CMD ["python", "app.py"]
```

3. **Atualizar docker-compose.yml:**
```yaml
services:
  app:
    build:
      context: ./app
      dockerfile: Dockerfile.zero-cves  # nova versão sem CVEs
```

### 📊 **Resultado Esperado:**
- **Vulnerabilidades CRITICAL:** 0 ✅
- **Vulnerabilidades HIGH:** 0 ✅  
- **Total de CVEs:** 0 ✅

---

## 💡 Extensões do lab (opcional)

- Adicionar **Watchtower** para _auto-update_ dos containers.
- Incluir **Trivy SBOM** (`--format cyclonedx`) e publicar em um repositório.
- Rodar `trivy config` em Dockerfile e Compose (IaC scanning).
- Integrar ao GitHub Actions/GitLab CI e **falhar pipeline** em CVEs altos.

Bom treino! 🥷
