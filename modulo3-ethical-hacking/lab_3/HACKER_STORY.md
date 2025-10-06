# HACKER STORY — Aula 40: Metasploit básico

**Contexto:** Alex já fez OSINT e enumeração ativa nos passos anteriores (Aulas 38/39). Hoje ele usará Metasploit apenas como ferramenta de inventário e PoC controlada. Lembre: somente contra https://acme-corp-lab.com/ ou ambientes locais isolados.

**Cenário:** Alex tem uma lista de IPs autorizados (ex.: `targets.txt`) e quer transformar esses dados em um inventário estruturado, correlacionando versões com CVEs e documentando evidências.

---

## Passo a passo (execute conforme lê)

### 1) Preparar ambiente

```bash
# subir containers
docker-compose up -d --build

# entrar no Kali
docker exec -it kensei_kali /bin/bash
cd /home/kali/investigations
```

### 2) Iniciar Metasploit e DB

```bash
# dentro do container metasploit (ou via docker exec)
msfdb init
msfconsole
```

No `msfconsole`:

```text
msf6 > db_status           # verificar conexão com o DB
msf6 > workspace -a acme_investigation
msf6 > setg RHOSTS_FILE /home/kali/investigations/targets.txt
```

### 3) Scanner HTTP version (exemplo controlado)

```text
msf6 > use auxiliary/scanner/http/http_version
msf6 auxiliary(http_version) > set RHOSTS 10.10.10.5,10.10.10.6   # substitua por IPs autorizados
msf6 auxiliary(http_version) > set THREADS 8
msf6 auxiliary(http_version) > run
```

> Salve a saída com `spool /msf/results/msf_scan_http_version.txt` antes de rodar e `spool off` ao terminar.

### 4) Outros scanners úteis

- `auxiliary/scanner/http/robots_txt`
- `auxiliary/scanner/ssh/ssh_version`
- `auxiliary/scanner/smb/smb_version`

Exemplo SSH:

```text
msf6 > use auxiliary/scanner/ssh/ssh_version
msf6 auxiliary(ssh_version) > set RHOSTS 10.10.10.5
msf6 auxiliary(ssh_version) > run
```

### 5) Exportar DB / evidências

```text
msf6 > db_export /msf/results/db_export_msf.xml
# no shell do host
docker cp kensei_msf:/msf/results/db_export_msf.xml ./results/
```

### 6) Preencher `module_list_tested.txt`

Formato recomendado:

```
<módulo> | RHOSTS=... | RPORT=... | THREADS=... | justificativa curta
```

---

## Notas de ética e segurança

- **Autorização:** confirmar autorização escrita do instrutor para quaisquer testes além de scans passivos/auxiliares.
- **Exploração:** não execute módulos `exploit/*` contra `acme-corp-lab.com` sem autorização assinada e snapshots.
- **Isolamento:** use imagens Metasploitable locais para PoC de exploração.
