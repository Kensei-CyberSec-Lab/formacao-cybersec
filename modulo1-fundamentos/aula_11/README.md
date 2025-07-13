# Lab: O Ciclo Completo do Reconhecimento

E aí, pessoal! Professor Kaze na área.  
Bem-vindos ao nosso laboratório mais completo de reconhecimento até agora. Hoje, vamos simular um fluxo de trabalho de pentest do mundo real, desde não saber nada sobre a rede até extrair informações detalhadas e, finalmente, capturar uma flag!

## Nossa missão em quatro fases:

1. **Descoberta**: Encontrar alvos vivos e suas portas TCP/UDP abertas usando `nmap`, `rustscan`.
2. **Detecção**: Analisar os serviços, versões e o SO do alvo encontrado.
3. **Enumeração**: Usar `enum4linux-ng` e `snmpwalk` para cavar fundo nos serviços SMB e SNMP.
4. **Captura**: Usar as informações coletadas para encontrar e capturar a flag secreta.

---

## Arquitetura do Lab

Nosso ambiente é composto por dois containers principais em uma rede isolada:

- `attacker-enum`: Máquina Kali Linux de onde lançaremos os ataques.
- `alvo-enum`: Servidor Linux simulado com serviços SMB, SNMP e uma flag secreta escondida.

---

## Pré-requisitos

Instale na máquina host:

- Docker  
- Docker Compose  

---

## Passo a Passo da Missão

Cada passo depende do anterior. Siga com atenção e entenda o que cada comando faz.

---

### Passo 0: Preparação do Ambiente

Entre na pasta `aula-enum` contendo o `docker-compose.yml` e os Dockerfiles.

```bash
docker compose up -d --build
```

- `--build`: Garante que o Docker reconstrua a imagem com a flag secreta.

---

### Passo 1: Infiltrando o Ambiente

Acesse o container de ataque:

```bash
docker exec -it attacker-enum /bin/bash
```

---

### Passo 2: Descoberta e Detecção

#### Host Discovery com Nmap

```bash
nmap -sn -T4 172.20.0.0/24 -oG - | grep "Up"
```

- Resultado: IP do host ativo (ex: `172.20.0.2`).

#### TCP Scan com Rustscan

```bash
rustscan -a 172.20.0.3
```

- Resultado: Portas TCP abertas, como `139`, `445`.

#### UDP Scan com Nmap

```bash
nmap -sU -p 161 172.20.0.3
```

- Resultado: Porta `161/udp` como `open|filtered`.

---

### Passo 3: Enumeração Profunda

#### Enumeração do SMB

```bash
enum4linux-ng -A 172.20.0.3
```

- Resultado: Informações sobre usuários, grupos e compartilhamentos (shares).

#### Enumeração do SNMP

```bash
snmpwalk -v2c -c public 172.20.0.3
```

- Resultado: Dump do sistema — hostname, rede, uptime, entre outros.

---

### Desafio Final: Capture a Flag (CTF)

**Objetivo**: Encontrar a flag secreta no formato `Kensei{...}`.

Como proceder:

1. Reanalise as saídas do `enum4linux-ng` e do `snmpwalk`.
2. Identifique serviços com possíveis brechas ou arquivos acessíveis.
3. Use ferramentas para interagir com os serviços e procurar arquivos suspeitos.

**Dica**: A flag pode estar em um compartilhamento acessível via `smbclient`.

Exemplo:

```bash
smbclient //172.20.0.3/anonymous
```

Use `ls`, `cd` e `get` para explorar o conteúdo.

---

## Limpeza do Ambiente

Saia do container:

```bash
exit
```

Finalize o laboratório:

```bash
docker compose down
```

---

## Conclusão

Parabéns, Kensei! Você completou um ciclo completo de reconhecimento, análise e exploração. Capturar a flag mostra que suas habilidades de enumeração e investigação estão afiadas.
