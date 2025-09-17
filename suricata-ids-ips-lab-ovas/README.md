# Suricata IDS/IPS LAB com OVAs + VirtualBox

Este repositório entrega um LAB pronto para sala de aula usando 3 VMs (OVAs) e VirtualBox. Foco: fácil, offline, didático, com automação e verificações.

Topologia (rede interna VirtualBox `LABNET`, /24, sem DHCP):

```
[Kali Attacker] 192.168.50.11 ---- LABNET ---- 192.168.50.10 [Suricata IDS/IPS] ---- LABNET ---- 192.168.50.20 [Web DVWA]
```

- Credenciais sugeridas: `student` / `student`
- Nomes das VMs: `Kali`, `Suricata`, `Web-DVWA`

## Quick Start (Aluno) ≤ 10 min

Pré-requisitos:
- VirtualBox instalado (Mac/Windows/Linux)
- 3 OVAs fornecidas pelo instrutor (não versionadas aqui)
- Este repositório (zip) entregue junto pelo instrutor

Passos:
1) Importar as 3 OVAs no VirtualBox (Arquivo > Importar Appliance). Veja `docs/student_import_guide.md`.
2) Em cada VM, defina a placa de rede como `Rede Interna` com nome exato `LABNET`.
3) Confirmar IPs estáticos nas VMs (sem DHCP):
   - Kali: 192.168.50.11/24
   - Suricata: 192.168.50.10/24
   - Web DVWA: 192.168.50.20/24
4) Iniciar as VMs na ordem: Web → Suricata → Kali.
5) Na VM Suricata, abrir este repo (por exemplo, em `/home/student/suricata-ids-ips-lab-ovas`).
6) IDS (observação) primeiro:
   - Garantir Suricata rodando com AF_PACKET (serviço) ou executar manualmente:
     ```bash
     sudo suricata -c ./suricata/suricata.yaml -S ./suricata/rules/local.rules -i eth0 -k none -D
     ```
7) Na VM Kali, gerar tráfego:
   ```bash
   cd /path/to/suricata-ids-ips-lab-ovas
   ./scripts/smoke-generate.sh 192.168.50.20 192.168.50.10
   ```
8) Na VM Suricata, verificar:
   ```bash
   ./scripts/smoke-verify.sh
   ```
   Critério de sucesso (IDS): contagens de alertas > 0 e `Blocked/drop: 0`.
9) Ativar IPS (NFQUEUE) e repetir:
   ```bash
   ./suricata/iptables-nfqueue.sh
   sudo pkill suricata || true
   sudo suricata -q 0 -k none -c ./suricata/suricata.yaml -S ./suricata/rules/local.rules -D
   ```
   Gere tráfego novamente no Kali e verifique. Critério de sucesso (IPS): `Blocked/drop` > 0.
10) Reset do ambiente a qualquer momento:
    ```bash
    ./scripts/reset-lab.sh
    ```

- Guia completo do lab: `docs/lab_guide.md`
- Troubleshooting: `docs/troubleshooting.md`
- Smoke test: `docs/smoke_test.md`

## Conteúdo
- Configs do Suricata para IDS e IPS (NFQUEUE e AF_PACKET inline L2)
- Regras didáticas (DVWA/SQLi/XSS) com `alert` e `drop`
- Scripts de smoke e reset
- CI com lint e validação `suricata -T` via Docker
- Templates de release e checksums (SHA256) das OVAs

## Política e Boas Práticas
- Licença MIT (ver `LICENSE`)
- `SECURITY.md` com disclosure responsável
- OVAs não são versionadas. Publique-as em Releases com hashes SHA256

## Inglês (resumo)
Veja `README.en.md` para um resumo em inglês.