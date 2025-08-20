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
│  ├─ requirements.txt           # app Flask mínimo
│  └─ app.py                     # hello world
├─ docker-compose.yml            # sobe o app para teste
├─ scripts/
│  ├─ scan.sh                    # roda Trivy (image e fs)
│  ├─ patch.sh                   # aplica patch trocando Dockerfile
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

## 💡 Extensões do lab (opcional)

- Adicionar **Watchtower** para _auto-update_ dos containers.
- Incluir **Trivy SBOM** (`--format cyclonedx`) e publicar em um repositório.
- Rodar `trivy config` em Dockerfile e Compose (IaC scanning).
- Integrar ao GitHub Actions/GitLab CI e **falhar pipeline** em CVEs altos.

Bom treino! 🥷
