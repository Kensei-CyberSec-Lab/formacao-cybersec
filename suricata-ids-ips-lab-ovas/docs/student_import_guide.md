# Guia do Aluno: Importar e Rodar o LAB

Tempo total: ≤ 10 minutos até o primeiro alerta.

Topologia
```
[Kali 192.168.50.11] -- LABNET -- [Suricata 192.168.50.10] -- LABNET -- [Web/DVWA 192.168.50.20]
```

## 1) Importar as OVAs
1. Abra o VirtualBox → Arquivo → Importar Appliance.
2. Selecione as três OVAs fornecidas: Kali, Suricata, Web-DVWA.
3. Para cada VM: Ajuste a placa de rede para `Rede Interna` (Internal Network) e nome `LABNET`.

## 2) Verificar IPs (sem DHCP)
- Kali: 192.168.50.11/24
- Suricata: 192.168.50.10/24
- Web: 192.168.50.20/24

Dicas de verificação dentro da VM:
- Linux: `ip a`, `ip r`

## 3) Ordem de Inicialização
1. Inicie Web
2. Inicie Suricata
3. Inicie Kali

## 4) Quick Start IDS
Na VM Suricata:
```bash
cd ~/suricata-ids-ips-lab-ovas
sudo suricata -c ./suricata/suricata.yaml -S ./suricata/rules/local.rules -i eth0 -k none -D
```

Na VM Kali (gera tráfego):
```bash
cd ~/suricata-ids-ips-lab-ovas
./scripts/smoke-generate.sh 192.168.50.20 192.168.50.10
```

Na VM Suricata (verifica):
```bash
./scripts/smoke-verify.sh
```
Sucesso: números de alertas > 0 e `Blocked/drop: 0`.

## 5) Modo IPS (NFQUEUE)
Na VM Suricata:
```bash
./suricata/iptables-nfqueue.sh
sudo pkill suricata || true
sudo suricata -q 0 -k none -c ./suricata/suricata.yaml -S ./suricata/rules/local.rules -D
```
Gere tráfego novamente no Kali e verifique. Sucesso: `Blocked/drop` > 0.

## 6) Reset
A qualquer momento:
```bash
./scripts/reset-lab.sh
```

## Checklist Rápida [ ]
- [ ] OVAs importadas
- [ ] NICs em `LABNET`
- [ ] IPs corretos
- [ ] IDS: alertas > 0
- [ ] IPS: bloqueios > 0

Problemas? Veja `docs/troubleshooting.md`.