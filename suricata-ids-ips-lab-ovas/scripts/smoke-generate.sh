#!/usr/bin/env bash
set -euo pipefail
TARGET_WEB="${1:-192.168.50.20}"
SURICATA_IP="${2:-192.168.50.10}"
echo "==[ Smoke: Generate Traffic ]=="
ping -c 2 "$TARGET_WEB"  >/dev/null && echo " OK ping web"  || echo " WARN ping web"
ping -c 2 "$SURICATA_IP" >/dev/null && echo " OK ping suri" || echo " WARN ping suri"
curl -s -o /dev/null -w " HTTP:%{http_code}\n" "http://$TARGET_WEB/dvwa" || true
curl -s -o /dev/null -w " HTTP:%{http_code}\n" -X POST -H "Content-Type: application/x-www-form-urlencoded" --data-urlencode "data=' or '1'='1" "http://$TARGET_WEB/dvwa" || true
curl -s -o /dev/null -w " HTTP:%{http_code}\n" -X POST -H "Content-Type: application/x-www-form-urlencoded" --data-urlencode "data=<script>alert('Hacked')</script>" "http://$TARGET_WEB/dvwa" || true
if command -v nmap >/dev/null 2>&1; then nmap -T4 -Pn "$TARGET_WEB" >/dev/null || true; fi
echo "Done. Check Suricata alerts."