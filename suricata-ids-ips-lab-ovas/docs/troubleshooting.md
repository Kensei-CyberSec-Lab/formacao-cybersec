# Troubleshooting

## Sem alertas no modo IDS
- [ ] Suricata está rodando? `systemctl status suricata` ou `pgrep -a suricata`
- [ ] Interface correta? Usando `-i eth0` e tráfego realmente passa por essa interface?
- [ ] `suricata.yaml` e `local.rules` corretos? Rodar `suricata -T -c ... -S ...`
- [ ] `eve.json` existe? `/var/log/suricata/eve.json`
- [ ] Clocks OK? Logs recentes? Use `tail -f`.

## Sem bloqueio no modo IPS (NFQUEUE)
- [ ] Rodou `./suricata/iptables-nfqueue.sh`? Regras em `iptables -L -v` mostram NFQUEUE?
- [ ] Suricata iniciado com `-q 0 -k none`?
- [ ] Regras `drop` ativas no `local.rules`? Não comente as linhas.
- [ ] Kernel/Permissões: usar `sudo`.

## Rede não funciona entre VMs
- [ ] NICs em `LABNET` e `Rede Interna`?
- [ ] IPs estáticos corretos? `ip a`
- [ ] Sem gateway necessário (mesma L2). Rotas incorretas podem atrapalhar.

## DVWA não abre
- [ ] Serviço web ativo (`systemctl status apache2`/`nginx`)?
- [ ] Porta 80 ouvindo? `ss -ltnp | grep :80`
- [ ] Conteúdo disponível em `/dvwa`?

## Logs vazios ou truncados
- [ ] Permissões do diretório `/var/log/suricata`.
- [ ] Espaço em disco livre.
- [ ] Rotação de logs: verificar `logrotate`.

## Suricata não inicia
- [ ] Validação `-T` falha: veja erros de sintaxe no YAML ou regras.
- [ ] Interface inexistente: ajuste `eth0`/`eth1` conforme VM.

## Ferramentas úteis
- `jq`, `tail -f`, `tcpdump -i eth0 -nn` (para confirmar tráfego)

Se persistir, execute `./scripts/reset-lab.sh` e repita os passos do Quick Start.