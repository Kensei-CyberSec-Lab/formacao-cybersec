# Roteiro do LAB: IDS → IPS

Objetivo: entender detecção e prevenção com Suricata usando DVWA como alvo.

Topologia
```
Kali (192.168.50.11) → Suricata (192.168.50.10) → Web/DVWA (192.168.50.20)
```

## Etapa 0: Sanidade de Rede
- No Kali: `ping 192.168.50.20` e `ping 192.168.50.10`
- Sucesso: recebe respostas.
- Se falhar: ver `troubleshooting.md`.

## Etapa 1: Acesso legítimo (visibilidade)
- No Kali: `curl -s -o /dev/null -w "HTTP:%{http_code}\n" http://192.168.50.20/dvwa`
- No Suricata: `./scripts/smoke-verify.sh`
- Sucesso: ver alertas "LAB DVWA access" (>0). Sem bloqueios.

## Etapa 2: Varredura (recon)
- No Kali: `nmap -T4 -Pn 192.168.50.20`
- No Suricata: verificar alertas de fluxo/scan (dependendo das regras e ruído). Não é foco bloquear aqui.

## Etapa 3: SQL Injection (detecção)
- No Kali:
  ```bash
  curl -s -o /dev/null -w "HTTP:%{http_code}\n" -X POST -H "Content-Type: application/x-www-form-urlencoded" \
    --data-urlencode "data=' or '1'='1" http://192.168.50.20/dvwa
  ```
- No Suricata: verificar alertas "LAB SQLi attempt (simple)".
- Sucesso: contagem > 0, sem bloqueio em modo IDS.

## Etapa 4: XSS (detecção)
- No Kali:
  ```bash
  curl -s -o /dev/null -w "HTTP:%{http_code}\n" -X POST -H "Content-Type: application/x-www-form-urlencoded" \
    --data-urlencode "data=<script>alert('Hacked')</script>" http://192.168.50.20/dvwa
  ```
- No Suricata: verificar alertas "LAB XSS attempt (simple)".

## Etapa 5: Ativar IPS (NFQUEUE)
- Na VM Suricata:
  ```bash
  ./suricata/iptables-nfqueue.sh
  sudo pkill suricata || true
  sudo suricata -q 0 -k none -c ./suricata/suricata.yaml -S ./suricata/rules/local.rules -D
  ```
- Critério de sucesso: ao repetir SQLi/XSS, ver `Blocked/drop` > 0 no `./scripts/smoke-verify.sh`.

## Etapa 6: IPS inline L2 (AF_PACKET bridge) [Opcional]
Requer 2 NICs (eth1/eth2) na VM Suricata em ponte interna.
- Preparar:
  ```bash
  ./suricata/ips-afpacket-bridge.sh eth1 eth2
  ```
- Ajustar `suricata.yaml` na seção `af-packet-inline` com nomes corretos das interfaces.
- Iniciar Suricata com o serviço do sistema apontando para o `suricata.yaml` (ou manualmente com `-i eth1 -i eth2` conforme setup do host).

## Análise de Logs
- Arquivo: `/var/log/suricata/eve.json`
- Tipos: alert, http, dns, tls, flow, stats
- Dicas: usar `jq` para filtrar, ex.: `jq 'select(.event_type=="alert")' eve.json`

## Reversão/Reset
- `./scripts/reset-lab.sh`

## Perguntas para reflexão
- Quais benefícios e custos de operar em IDS vs IPS?
- Como ajustar regras para reduzir falsos positivos?
- Onde posicionar o sensor para maximizar visibilidade/bloqueio?