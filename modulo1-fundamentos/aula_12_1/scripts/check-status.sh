#!/bin/bash
echo "[*] Verificando status do GVM..."
gvmd --get-users
echo "[*] Acesse http://localhost:9392 com admin/admin"
tail -f /var/log/gvm/gvmd.log
