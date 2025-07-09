Desafio CTF: Invasão à Kensei Corp
Sua missão, caso decida aceitá-la, é usar suas habilidades de scanning e enumeração para encontrar 5 flags escondidas na infraestrutura da Kensei Corp.

🎯 Missão
Assumindo que você já descobriu os IPs ativos na DMZ e na Rede Interna (usando o guia principal), sua tarefa é analisar cada host, encontrar as portas e serviços, e usar as ferramentas certas para capturar as 5 flags.

🚀 Caça às Flags!
🚩 Flag 1: Web Server (DMZ)
O web_server está na porta 80. Use o curl para inspecionar o que ele está servindo. Às vezes, os segredos estão bem à vista.

```
# Substitua <IP_DO_WEB_SERVER> pelo IP correto
curl http://<IP_DO_WEB_SERVER>
```

Dica: Inspecione o código-fonte HTML.

🚩 Flag 2: Mail Server (DMZ)
O mail_server tem a porta 25 (SMTP) aberta. Serviços de texto como SMTP costumam se apresentar com um "banner". Use o netcat (nc) para ver como ele te cumprimenta.

```
# Substitua <IP_DO_MAIL_SERVER> pelo IP correto
nc <IP_DO_MAIL_SERVER> 25
```

🚩 Flag 3: Fileshare Server (Rede Interna)
O fileshare_server parece ter portas de compartilhamento de arquivos (SMB) abertas. Use o smbclient para listar os compartilhamentos disponíveis (a senha é em branco).

```
# Substitua <IP_DO_FILESHARE> pelo IP correto
smbclient -L //<IP_DO_FILESHARE> -N
```

Uma vez que você encontrar um compartilhamento chamado public, conecte-se a ele.

```
smbclient //<IP_DO_FILESHARE>/public -N
```

Agora que você está dentro do compartilhamento, use os seguintes comandos no prompt smb: \>:

Liste os arquivos (incluindo os ocultos):
smb: \> ```ls -a```
Você verá um diretório oculto chamado .secreto.

Entre no diretório secreto:
smb: \> ```cd .secreto```

Liste o conteúdo do diretório:
smb: \> ```ls```
Você verá o arquivo FLAG.txt.

Baixe o arquivo para sua máquina:
smb: \> ```get FLAG.txt```
O arquivo será baixado para o diretório /root/ no seu container.

Saia do smbclient:
smb: \> ```exit```

Leia a flag:
```cat FLAG.txt```

🚩 Flag 4: Database Server (Rede Interna)
O servidor de banco de dados é um alvo valioso. Conecte-se a ele usando o cliente mysql (usuário root, senha em branco).

```
# Substitua <IP_DO_DATABASE> pelo IP correto
mysql -h <IP_DO_DATABASE> -u root --ssl=0
```

Uma vez dentro, explore o banco de dados. Use os comandos SHOW DATABASES;, USE <database>;, SHOW TABLES; e SELECT * FROM <table>; para encontrar a flag.

🚩 Flag 5: Dev Machine (Rede Interna)
A dev_machine é nosso alvo mais suspeito. Um scan padrão pode não revelar tudo. Faça um scan completo em todas as portas para encontrar serviços ocultos.

```
# Substitua <IP_DA_DEV_MACHINE> pelo IP correto
rustscan -a <IP_DA_DEV_MACHINE> --range 1-65535 -- -A
```

Você encontrará uma porta 1337 (leet) aberta. Conecte-se a ela com nc para a sua última flag.

```
telnet <IP_DA_DEV_MACHINE> 1337 
nc <IP_DA_DEV_MACHINE> 1337
```

Parabéns por completar o desafio, Kensei! ⚔️