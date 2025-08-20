#!/usr/bin/env bash
set -euo pipefail

mkdir -p reports

# Permite usar Trivy local se existir; caso contrário, usa o container oficial
TRIVY_BIN="$(command -v trivy || true)"
if [[ -z "${TRIVY_BIN}" ]]; then
  echo "[i] Trivy local não encontrado. Usando container aquasec/trivy:latest"
  TRIVY="docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd):/work -w /work aquasec/trivy:latest"
else
  TRIVY="trivy"
fi

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

echo "[+] Scan de imagem (lab27_app:local) - CRITICAL/HIGH, falha se achar"
$TRIVY image --ignore-unfixed --scanners vuln   --severity CRITICAL,HIGH   --exit-code 1   --format table   --output "reports/image-${TIMESTAMP}.txt"   lab27_app:local || (echo "[!] Vulnerabilidades CRÍTICAS/ALTAS encontradas na imagem" && exit 1)

echo "[+] Scan do filesystem do projeto (dependências & Dockerfile)"
$TRIVY fs --scanners vuln,secret,misconfig   --severity CRITICAL,HIGH,MEDIUM   --exit-code 0   --format table   --output "reports/fs-${TIMESTAMP}.txt"   .

echo "[✓] Relatórios criados em ./reports"
