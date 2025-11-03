# Ambiente Atacante - Containers Kali Linux

Esta pasta contém dois ambientes completos do Kali Linux para testes de penetração e desafios CTF:

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

### Opção 1: Iniciar ambos os containers
```bash
docker-compose up -d
```

### Opção 2: Iniciar containers individuais
```bash
# Apenas CLI
docker-compose up -d kali-cli

# Apenas GUI  
docker-compose up -d kali-gui
```

## 🔧 Métodos de Acesso

### Acesso ao Kali CLI
```bash
# Conectar ao container CLI
docker exec -it kali-cli /bin/bash

# Ou usar o script fornecido
./scripts/connect-cli.sh
```

### Acesso ao Kali GUI
1. **Cliente VNC**: Conectar em `localhost:5901` (senha: `kalilinux`)
2. **Navegador Web**: Abrir `http://localhost:6080` (senha: `kalilinux`)
3. **Acesso via linha de comando**: `docker exec -it kali-gui /bin/bash`

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
docker-compose down -v
docker-compose up -d
```

## 📚 Recursos Adicionais

- [Documentação do Kali Linux](https://www.kali.org/docs/)
- [Guia do Docker Compose](https://docs.docker.com/compose/)
- [Guia de Configuração VNC](https://www.kali.org/docs/general-use/novnc-kali-in-browser/)

---
**Nota**: Estes containers são projetados para fins educacionais e testes de penetração autorizados apenas. Sempre garanta que você tem autorização adequada antes de testar qualquer sistema.