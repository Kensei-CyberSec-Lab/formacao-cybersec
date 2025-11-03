# Ambiente Atacante - Containers Kali Linux

Esta pasta contém dois ambientes completos do Kali Linux para testes de penetração e desafios CTF:

## 📁 Estrutura do Projeto

```
attacker/
├── 📄 README.md              # Documentação principal
├── 📄 Makefile              # Comandos de build e gerenciamento
├── 📁 conf/                 # Arquivos de configuração
│   ├── docker-compose.yml   # Orquestração de containers
│   ├── .env                 # Variáveis de ambiente
│   ├── supervisord.conf     # Configuração do supervisor de processos
│   ├── Dockerfile.kali-cli  # Definição do container CLI
│   ├── Dockerfile.kali-gui  # Definição do container GUI
│   └── .dockerignore        # Regras de ignore do Docker
├── 📁 scripts/              # Scripts auxiliares
│   ├── setup.sh            # Configuração interativa
│   ├── connect-cli.sh       # Conectar ao container CLI
│   └── connect-gui.sh       # Auxiliar de conexão GUI
├── 📁 docs/                 # Documentação
│   ├── README.md            # Documentação detalhada
│   ├── REFERENCIA-RAPIDA.md # Referência rápida
│   └── SOLUCAO-PROBLEMAS.md # Solução de problemas
└── 📁 shared/              # Pasta compartilhada entre host e containers
```

## 🖥️ Containers Disponíveis

### 1. Kali CLI (`kali-cli`)
- **Propósito**: Interface de linha de comando para usuários avançados
- **Características**: Conjunto completo de ferramentas Kali Linux, leve, inicialização rápida
- **Acesso**: Acesso direto ao terminal via Docker exec
- **Melhor para**: Scripts automatizados, ferramentas de linha de comando, eficiência de recursos

### 2. Kali GUI (`kali-gui`)
- **Propósito**: Interface gráfica com acesso VNC
- **Características**: Ambiente desktop completo, acesso via navegador, ferramentas visuais
- **Acesso**: VNC na porta 5901, Web VNC na porta 6080
- **Melhor para**: Ferramentas baseadas em GUI, iniciantes, análise visual

## 🚀 Início Rápido

### Opção 1: Configuração Interativa (Recomendada)
```bash
./scripts/setup.sh           # Instalação e configuração interativa
```

### Opção 2: Início Rápido com Make
```bash
make setup                   # Tornar scripts executáveis
make build                   # Construir containers
make up                      # Iniciar todos os containers
```

### Opção 3: Docker Compose Direto
```bash
# Do diretório raiz do projeto
cd conf/
docker-compose up -d         # Iniciar todos os containers
docker-compose up -d kali-cli # Apenas CLI
docker-compose up -d kali-gui # Apenas GUI
```

## 🔧 Métodos de Acesso

### Acesso ao Kali CLI
```bash
# Conectar ao container CLI
docker exec -it kali-cli /bin/bash

# Ou usar o script fornecido
./scripts/connect-cli.sh

# Ou usar comando make
make connect-cli
```

### Acesso ao Kali GUI
1. **Cliente VNC**: Conectar em `localhost:5901` (senha: `kalilinux`)
2. **Navegador Web**: Abrir `http://localhost:6080` (senha: `kalilinux`)
3. **Script auxiliar**: `./scripts/connect-gui.sh` ou `make connect-gui`
4. **Acesso via linha de comando**: `docker exec -it kali-gui /bin/bash`

## 📦 Ferramentas Incluídas

Ambos os containers incluem o conjunto completo de ferramentas do Kali Linux:

### Análise de Rede
- Nmap, Masscan, Zmap
- Wireshark, tcpdump, tshark
- Netcat, Socat, Netdiscover

### Testes de Aplicações Web
- Burp Suite Community
- OWASP ZAP
- Nikto, Dirb, Gobuster
- SQLmap, Wfuzz
- Whatweb, Sublist3r

### Avaliação de Vulnerabilidades
- OpenVAS (via gvm)
- Nessus (instalação manual)
- Nuclei, Naabu
- Searchsploit

### Exploração
- Metasploit Framework
- Social Engineering Toolkit
- Beef-xss
- Empire, Cobalt Strike (community)

### Pós-Exploração
- Mimikatz (via wine)
- BloodHound
- PowerShell Empire
- Scripts de escalação de privilégios

### Análise Forense
- Volatility Framework
- Autopsy, Sleuth Kit
- Binwalk, Foremost
- John the Ripper, Hashcat

### Segurança Wireless
- Suíte Aircrack-ng
- Reaver, Bully
- Kismet, Hostapd

## 🛠️ Especificações dos Containers

### Recursos do Sistema
- **RAM**: 2GB mínimo, 4GB recomendado
- **Armazenamento**: ~8GB por container
- **CPU**: Multi-core recomendado

### Persistência
- Diretórios home montados como volumes
- Configurações de ferramentas preservadas
- Scripts personalizados e payloads salvos

## 📋 Exemplos de Uso

### Desafios CTF
```bash
# Varredura de rede
docker exec -it kali-cli nmap -sC -sV target_ip

# Teste de aplicação web
docker exec -it kali-cli gobuster dir -u http://target -w /usr/share/wordlists/dirb/common.txt

# Quebra de senhas
docker exec -it kali-cli john --wordlist=/usr/share/wordlists/rockyou.txt hash.txt
```

### Exercícios de Laboratório
1. Iniciar o ambiente: `docker-compose up -d`
2. Escolher CLI ou GUI baseado nos requisitos do laboratório
3. Seguir as instruções do laboratório usando as ferramentas fornecidas
4. Resultados são preservados em volumes montados

## 🔒 Notas de Segurança

- A senha VNC padrão deve ser alterada em produção
- Containers executam em redes isoladas
- Nenhum dado sensível deve ser armazenado permanentemente
- Atualizações regulares recomendadas: `docker-compose pull && docker-compose up -d`

## 🆘 Solução de Problemas

### Problemas Comuns
1. **Conflitos de porta**: Verificar se as portas 5901/6080 estão disponíveis
2. **Performance**: Aumentar alocação de memória do Docker
3. **Conexão VNC**: Garantir que o firewall permite conexões
4. **Atualizações de ferramentas**: Executar `apt update && apt upgrade` dentro dos containers

### Resetar Ambiente
```bash
# Do diretório conf/
docker-compose down -v
docker-compose up -d

# Ou usando make (do diretório raiz)
make clean
make up
```

## 📚 Documentação Adicional

### Documentação Completa
- [docs/README.md](docs/README.md) - Documentação detalhada
- [docs/REFERENCIA-RAPIDA.md](docs/REFERENCIA-RAPIDA.md) - Referência rápida de comandos
- [docs/SOLUCAO-PROBLEMAS.md](docs/SOLUCAO-PROBLEMAS.md) - Problemas comuns e soluções

### Links Externos
- [Documentação do Kali Linux](https://www.kali.org/docs/)
- [Guia do Docker Compose](https://docs.docker.com/compose/)
- [Guia de Configuração VNC](https://www.kali.org/docs/general-use/novnc-kali-in-browser/)

---
**Nota**: Estes containers são projetados para fins educacionais e testes de penetração autorizados apenas. Sempre garanta que você tem autorização adequada antes de testar qualquer sistema.