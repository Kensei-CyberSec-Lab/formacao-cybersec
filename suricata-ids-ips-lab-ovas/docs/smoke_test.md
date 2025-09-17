# Smoke Test

Objetivo: validar rapidamente conectividade, alertas IDS e bloqueio IPS.

## Execução
1) Na VM Suricata (IDS):
   ```bash
   sudo suricata -c ./suricata/suricata.yaml -S ./suricata/rules/local.rules -i eth0 -k none -D
   ```
2) Na VM Kali (tráfego):
   ```bash
   ./scripts/smoke-generate.sh 192.168.50.20 192.168.50.10
   ```
3) Na VM Suricata (verificação):
   ```bash
   ./scripts/smoke-verify.sh
   ```
4) Ativar IPS (NFQUEUE) e repetir:
   ```bash
   ./suricata/iptables-nfqueue.sh
   sudo pkill suricata || true
   sudo suricata -q 0 -k none -c ./suricata/suricata.yaml -S ./suricata/rules/local.rules -D
   ./scripts/smoke-generate.sh 192.168.50.20 192.168.50.10
   ./scripts/smoke-verify.sh
   ```

## Critérios de Sucesso
- IDS: `DVWA alerts`, `SQLi alerts`, `XSS alerts` > 0 e `Blocked/drop: 0`
- IPS: `Blocked/drop` > 0

## Reset
- `./scripts/reset-lab.sh`