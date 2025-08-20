#!/usr/bin/env bash
set -euo pipefail

# Aplica patch nas dependências Python para eliminar CVEs restantes

echo "[i] Aplicando patch Python: eliminando vulnerabilidades do gunicorn e setuptools"

# Backup do docker-compose atual
cp docker-compose.yml docker-compose.yml.bak

# Troca para usar o Dockerfile sem vulnerabilidades Python
sed -i.bak 's|dockerfile: Dockerfile.*|dockerfile: Dockerfile.zero-cves|g' docker-compose.yml

echo "[✓] Patch Python aplicado. Configuração alterada para Dockerfile.zero-cves"
echo ""
echo "📋 Mudanças aplicadas:"
echo "  - gunicorn: 21.2.0 → 23.0.0 (elimina CVE-2024-1135, CVE-2024-6827)"
echo "  - setuptools: 65.5.1 → 78.1.1 (elimina CVE-2024-6345, CVE-2025-47273)"
echo ""
echo "[✓] Agora rode: make rebuild && make scan"
echo "[💡] Resultado esperado: 0 vulnerabilidades CRITICAL/HIGH"
