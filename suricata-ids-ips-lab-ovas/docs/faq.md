# FAQ

## Preciso de internet durante o lab?
Não. Apenas para baixar as OVAs inicialmente. O lab roda offline.

## Posso usar VMWare/UTM?
O guia é focado em VirtualBox. Outros hipervisores podem funcionar, mas não são suportados.

## Qual o usuário/senha?
Sugerido: `student` / `student`.

## Onde vejo os logs do Suricata?
`/var/log/suricata/eve.json`.

## Como ativo o IPS?
Use `./suricata/iptables-nfqueue.sh` e inicie o Suricata com `-q 0 -k none`.

## AF_PACKET inline funciona?
Sim, com 2 NICs. Veja `suricata/ips-afpacket-bridge.sh` e `suricata/suricata.yaml`.

## Como reverter erros?
Execute `./scripts/reset-lab.sh` e siga o Quick Start de novo.