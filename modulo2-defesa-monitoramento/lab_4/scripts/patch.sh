#!/usr/bin/env bash
set -euo pipefail

# Troca o Dockerfile do serviço 'app' no docker-compose para a versão "patched"
echo "[i] Aplicando patch: alterando Dockerfile para Dockerfile.patched"
sed -i.bak 's|Dockerfile.bullseye|Dockerfile.patched|g' docker-compose.yml
echo "[✓] Patch aplicado. Agora rode: make rebuild && make scan"
