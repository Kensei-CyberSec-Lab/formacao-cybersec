# HACKER STORY — Aula 40: Metasploit básico

Alex empurra a cadeira, toma um gole de café e encara a lista de IPs permitidos sobre a mesa. “Hoje não é sobre explorar”, pensa. “É sobre enxergar com nitidez.” O objetivo é transformar a enumeração das aulas anteriores em um inventário confiável: versões, serviços, evidências — munição organizada.

Ele liga o laboratório. Nada de glamour, só disciplina:

```bash
docker-compose up -d --build
docker exec -it kensei_kali /bin/bash
cd /home/kali/investigations
```

O terminal devolve aquele silêncio confortável de quem está pronto. Alex respira fundo e convoca o arsenal.

```bash
msfconsole
```

O prompt do Metasploit surge. Primeiro, ele testa o pulso do banco: conexão é vida.

```text
msf6 > db_status
msf6 > workspace -a acme_investigation
msf6 > setg RHOSTS_FILE /home/kali/investigations/targets.txt
```

“Sem pressa, mas sem pausa.” Alex decide começar pelo que mais expõe versões de cara: HTTP. Ele prepara o módulo como quem ajusta a mira.

```text
msf6 > use auxiliary/scanner/http/http_version
msf6 auxiliary(http_version) > set RHOSTS 10.10.10.5,10.10.10.6   # substitua por IPs autorizados
msf6 auxiliary(http_version) > set THREADS 8
msf6 auxiliary(http_version) > spool /home/kali/investigations/msf_scan_http_version.txt
msf6 auxiliary(http_version) > run
msf6 auxiliary(http_version) > spool off
```

Cada banner é uma história, cada número de versão, uma trilha. Alex deixa o arquivo de saída onde precisa estar: na pasta sincronizada com o host. Sem atritos.

Ele amplia o reconhecimento. “Cada serviço revela um pedaço diferente do quebra-cabeça.”

```text
# Outras sondas úteis
msf6 > use auxiliary/scanner/http/robots_txt
msf6 > use auxiliary/scanner/ssh/ssh_version
msf6 > use auxiliary/scanner/smb/smb_version
```

Quando quer foco, Alex escolhe um alvo por vez. Para SSH, ele trata cada conexão como uma entrevista objetiva:

```text
msf6 > use auxiliary/scanner/ssh/ssh_version
msf6 auxiliary(ssh_version) > set RHOSTS 10.10.10.5
msf6 auxiliary(ssh_version) > run
```

Com o terreno mapeado, é hora de preservar. Evidência que não é exportada é memória volátil.

```text
msf6 > db_export /home/kali/investigations/db_export_msf.xml
```

Sem cópias extras: a pasta `investigations` já está montada no host como `workspace/`. Alex gosta quando as coisas simplesmente… aparecem onde deveriam.

Antes de encerrar, ele registra o diário da missão. Frio, objetivo, reprodutível — como deve ser.

```
# Exemplo de linha no module_list_tested.txt
auxiliary/scanner/http/http_version | RHOSTS=10.10.10.5,10.10.10.6 | RPORT=80,443 | THREADS=8 | Inventário de versões HTTP
auxiliary/scanner/ssh/ssh_version  | RHOSTS=10.10.10.5            | RPORT=22     | THREADS=4 | Versão de SSH para correlação
```

Ele recosta. Missão limpa. Sem barulho desnecessário, só o suficiente para transformar dados em inteligência.

---

## Notas de ética e segurança

- **Autorização:** confirme autorização escrita do instrutor para quaisquer testes além de scans passivos/auxiliares.
- **Exploração:** não execute módulos `exploit/*` contra `acme-corp-lab.com` sem autorização assinada e snapshots.
- **Isolamento:** use imagens Metasploitable locais para PoC de exploração.
