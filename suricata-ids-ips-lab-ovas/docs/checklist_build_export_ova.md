# Checklist do Instrutor: Construção e Exportação das OVAs

Objetivo: gerar 3 OVAs enxutas e consistentes para o LAB, com IPs fixos e hash SHA256.

Topologia e IPs fixos (sem DHCP):
- Kali Attacker: 192.168.50.11/24
- Suricata IDS/IPS: 192.168.50.10/24
- Web DVWA: 192.168.50.20/24
- VirtualBox Internal Network: `LABNET`

## Pré-requisitos
- VirtualBox instalado
- ISOs: Kali, Ubuntu/SELKS, WebApp (Ubuntu Server + DVWA)
- Usuário padrão: `student` / `student`

## Passos (geral)
1) Criar VMs com disco dinâmico (20–40 GB), 2 GB RAM (Suricata 4 GB), 2 CPUs (Suricata 3–4 CPUs).
2) Configurar NICs:
   - Modo: Rede Interna
   - Nome: `LABNET`
3) Configurar IPs estáticos nas VMs:
   - Linux (netplan ou ifcfg). Exemplo netplan:
     ```yaml
     network:
       version: 2
       renderer: networkd
       ethernets:
         eth0:
           dhcp4: false
           addresses: [192.168.50.10/24]
     ```
4) Habilitar SSH (opcional), definir hostname amigável: `kali`, `suricata`, `web`.
5) Instalação do Suricata (VM Suricata):
   - `sudo apt-get update && sudo apt-get install -y suricata jq curl iptables` (ou usar SELKS pronto)
   - Habilitar serviço: `sudo systemctl enable suricata`.
6) Instalação DVWA (VM Web): use pacote DVWA ou Docker offline pré-carregado. Garantir acesso em `http://192.168.50.20/dvwa`.
7) Kali: garantir `curl`, `nmap`.
8) Criar usuário `student` com sudo sem senha (ou preservar senha simples `student`).
9) Copiar este repositório para `/home/student/suricata-ids-ips-lab-ovas` nas VMs (Suricata e Kali pelo menos).

## Otimizações de Tamanho
- Remover caches: `sudo apt-get clean && sudo journalctl --vacuum-time=1d`
- Zerar espaço livre (opcional) antes de exportar.
- Criar Snapshot "clean".

## Teste Local Antes de Exportar
- Subir as 3 VMs e rodar smoke (ver `docs/smoke_test.md`).
- Critérios: alertas aparecem no modo IDS, bloqueios no modo IPS (NFQUEUE).

## Exportar OVAs
- VirtualBox: Arquivo > Exportar Appliance > selecione as 3 VMs.
- Nomear arquivos: `Kali-IDS-LAB.ova`, `Suricata-IDS-LAB.ova`, `Web-DVWA-LAB.ova`.
- Publicar nos Releases do GitHub. Não versionar no Git.

## Integridade (SHA256)
- No diretório com OVAs, rode:
  ```bash
  cd RELEASE
  ./checksums.sh
  ```
- Publique `CHECKSUMS.sha256` junto ao Release.

## Checklist [ ]
- [ ] IPs estáticos corretos
- [ ] DVWA acessível
- [ ] Suricata instalado e inicia
- [ ] Repositório presente nas VMs
- [ ] Smoke test OK (IDS)
- [ ] IPS NFQUEUE bloqueando
- [ ] Snapshots criados
- [ ] OVAs exportadas e hashes gerados