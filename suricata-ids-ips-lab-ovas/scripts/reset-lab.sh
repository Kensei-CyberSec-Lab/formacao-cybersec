#!/usr/bin/env bash
set -euo pipefail
echo "[Reset] Limpando iptables e reiniciando Suricata..."
sudo iptables -F || true
sudo iptables -t nat -F || true
sudo iptables -t mangle -F || true
sudo systemctl restart suricata || true
sleep 2
systemctl is-active --quiet suricata && echo "Suricata ativo." || echo "Suricata não ativo!"
echo "[Reset] OK."