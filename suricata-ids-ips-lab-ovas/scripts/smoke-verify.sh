#!/usr/bin/env bash
set -euo pipefail
EVE="/var/log/suricata/eve.json"
TAIL="${1:-8000}"
[ -f "$EVE" ] || { echo "Missing $EVE"; exit 1; }
TMP=$(mktemp)
tail -n "$TAIL" "$EVE" > "$TMP"
DVWA=$(grep -c '"LAB DVWA access"' "$TMP" || true)
SQLI_A=$(grep -c '"LAB SQLi attempt (simple)"' "$TMP" || true)
XSS_A=$(grep -c '"LAB XSS attempt (simple)"' "$TMP" || true)
BLOCKED=$(grep -Eic '"action":"blocked"|"drop":true' "$TMP" || true)
echo "DVWA alerts: $DVWA"
echo "SQLi alerts: $SQLI_A"
echo "XSS alerts:  $XSS_A"
echo "Blocked/drop: $BLOCKED"
rm -f "$TMP"