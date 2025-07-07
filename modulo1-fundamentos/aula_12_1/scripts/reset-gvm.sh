#!/bin/bash
echo "[*] Resetando GVM..."
supervisorctl stop all || true
rm -rf /var/lib/gvm/* /var/lib/openvas/* /var/lib/ospd/*
echo "[*] Reset concluído."
exec update-feeds.sh
