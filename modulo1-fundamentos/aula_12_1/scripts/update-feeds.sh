#!/bin/bash
set -e
echo "[*] Atualizando feeds..."
greenbone-feed-sync --type NVT
greenbone-feed-sync --type SCAP
greenbone-feed-sync --type CERT
greenbone-feed-sync --type GVMD_DATA

echo "[*] Atualizando GVMD..."
gvmd --update
gvmd --rebuild

echo "[*] Iniciando GVM..."
exec supervisord -n
