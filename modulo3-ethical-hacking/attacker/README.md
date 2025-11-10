# Ambiente Atacante - Containers Kali Linux

Esta pasta contém dois ambientes completos do Kali Linux para testes de penetração e desafios CTF:

## 🚀 Atualização 2024 – Ambientes Estáveis
- O container **CLI** continua baseado em `kalilinux/kali-last-release` (configurável em `conf/.env`) com o metapacote **`kali-linux-everything`** para manter todo o catálogo de ferramentas.
- O container **GUI** foi refeito reutilizando a receita provada do laboratório `modulo1/lab_7` (`kalilinux/kali-rolling` + tightvncserver). Essa versão força o mirror oficial `http.kali.org`, instala `kali-desktop-xfce` + `kali-linux-default` e prioriza estabilidade do VNC/noVNC.
- Resultado: builds bem mais rápidos (≈5 GB) e conexões VNC que funcionam mesmo em clientes rígidos como RealVNC. Ferramentas extras podem ser instaladas sob demanda via `apt` dentro do container GUI.
- Antes do primeiro uso ou para trocar de release, rode `docker compose build --pull --no-cache` dentro de `attacker/conf` e depois `docker compose up -d`.

## 📁 Estrutura do Projeto

```
attacker/
├── 📄 README.md              # Documentação principal
├── 📁 conf/                 # Arquivos de configuração
│   ├── docker-compose.yml   # Orquestração de containers
│   ├── .env                 # Variáveis de ambiente
│   ├── supervisord.conf     # Configuração do supervisor de processos
│   ├── Dockerfile.kali-cli  # Definição do container CLI
│   ├── Dockerfile.kali-gui  # Definição do container GUI
│   └── .dockerignore        # Regras de ignore do Docker
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
- **Características**: Ambiente XFCE enxuto (kali-linux-default) inspirado no lab_7, VNC tradicional + noVNC prontinho
- **Acesso**: VNC na porta 5901, Web VNC na porta 6080
- **Melhor para**: Ferramentas baseadas em GUI, treinamentos visuais, fluxos que exigem navegador integrado
- **Extras**: Instale toolsets adicionais com `apt install <pacote>` diretamente no container, caso precise de algo fora do perfil padrão

```bash
# Do diretório raiz do projeto
cd conf/
docker-compose up -d         # Iniciar todos os containers
docker-compose up -d kali-cli # Apenas CLI
docker-compose up -d kali-gui # Apenas GUI
```

## Métodos de Acesso

### Acesso ao Kali CLI
```bash
# Conectar ao container CLI
docker exec -it kali-cli /bin/bash
```

### Acesso ao Kali GUI
1. **Cliente VNC**: Conectar em `localhost:5901` (senha: `kalilinux`)
2. **Navegador Web**: Abrir `http://localhost:6080` (senha: `kalilinux`)
3. **Script auxiliar**: `./scripts/connect-gui.sh` ou `make connect-gui`
4. **Acesso via linha de comando**: `docker exec -it kali-gui /bin/bash`
5. **RealVNC/clients exigentes**: Defina `Encryption = Prefer off/Let server choose` e desmarque SSO ou smartcard. Esses clientes só completam o handshake se usarem autenticação `VNC password` pura.

## Ferramentas Incluídas

- **CLI**: continua com praticamente todo o catálogo (`kali-linux-everything` + toolsets extras).
- **GUI**: sai com `kali-linux-default`, navegador, XFCE e os utilitários listados abaixo. Caso precise de algo que só exista nos metapacotes gigantes, basta instalar via `apt` dentro do container.

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

## Especificações dos Containers

### Recursos do Sistema
- **RAM**: 2GB mínimo, 4GB recomendado
- **Armazenamento**: ~8GB por container
- **CPU**: Multi-core recomendado

### Persistência
- Diretórios home montados como volumes
- Configurações de ferramentas preservadas
- Scripts personalizados e payloads salvos

## Exemplos de Uso

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

## Notas de Segurança

- A senha VNC padrão deve ser alterada em produção
- Containers executam em redes isoladas
- Nenhum dado sensível deve ser armazenado permanentemente
- Atualizações regulares recomendadas: `docker-compose pull && docker-compose up -d`

## Solução de Problemas

### Problemas Comuns
1. **Conflitos de porta**: Verificar se as portas 5901/6080 estão disponíveis
2. **Performance**: Aumentar alocação de memória do Docker
3. **Conexão VNC**: Certifique-se de que 5901 está liberada e, em clientes como RealVNC, desative SSO/smartcard + force `VNC password` simples ou use direto o noVNC (`http://localhost:6080`)
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
---
**Nota**: Estes containers são projetados para fins educacionais e testes de penetração autorizados apenas. Sempre garanta que você tem autorização adequada antes de testar qualquer sistema.
