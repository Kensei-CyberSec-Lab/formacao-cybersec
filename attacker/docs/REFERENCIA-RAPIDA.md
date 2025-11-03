# 🐉 Containers Kali Linux - Referência Rápida

## 🚀 Início Rápido
```bash
./scripts/setup.sh           # Configuração interativa
make up                      # Iniciar todos os containers
make connect-cli             # Conectar ao CLI
make connect-gui             # Informações de acesso GUI
```

## 🎯 Métodos de Acesso

### Container CLI
```bash
docker exec -it kali-cli /bin/bash
# ou
./scripts/connect-cli.sh
# ou  
make connect-cli
```

### Container GUI
- **Cliente VNC:** `localhost:5901` (senha: `kalilinux`)
- **Navegador Web:** `http://localhost:6080`
- **Terminal:** `docker exec -it kali-gui /bin/bash`

## 🛠️ Comandos Comuns

### Gerenciamento de Containers
```bash
make up              # Iniciar todos
make down            # Parar todos  
make cli             # Iniciar apenas CLI
make gui             # Iniciar apenas GUI
make status          # Mostrar status
make logs            # Ver logs
make clean           # Limpar
make rebuild         # Reconstruir todos
```

### Docker Compose
```bash
docker-compose up -d                    # Iniciar desconectado
docker-compose up -d kali-cli          # Iniciar apenas CLI
docker-compose up -d kali-gui          # Iniciar apenas GUI
docker-compose down                     # Parar todos
docker-compose logs -f                  # Seguir logs
docker-compose ps                       # Mostrar status
```

## 🔍 Acesso Rápido às Ferramentas Essenciais

### Varredura de Rede
```bash
nmap -sC -sV target
masscan -p1-65535 target --rate=1000
```

### Testes Web  
```bash
gobuster dir -u http://target -w /usr/share/wordlists/dirb/common.txt
nikto -h http://target
sqlmap -u "http://target/page?id=1"
```

### Senhas
```bash
hydra -l admin -P /usr/share/wordlists/rockyou.txt ssh://target
john --wordlist=/usr/share/wordlists/rockyou.txt hash.txt
hashcat -m 0 hash.txt /usr/share/wordlists/rockyou.txt
```

### Exploração
```bash
msfconsole
searchsploit apache 2.4
```

## 📁 Caminhos Importantes

### Wordlists
- `/usr/share/wordlists/` - Wordlists padrão do Kali
- `/root/wordlists/seclists/` - SecLists
- `/root/wordlists/fuzzdb/` - FuzzDB

### Ferramentas
- `/opt/tools/` - Ferramentas adicionais
- `/opt/tools/SecLists/` - Repositório SecLists  
- `/opt/tools/PayloadsAllTheThings/` - Coleção de payloads

### Compartilhado
- `/shared/` - Compartilhado com host (./shared/)

## 🎓 Dicas para CTF

### Caça às Flags
```bash
find / -name "*flag*" 2>/dev/null
grep -r "flag" /var/www/ 2>/dev/null  
strings binary | grep flag
```

### Escalação de Privilégios
```bash
cd /opt/tools/LinEnum && ./LinEnum.sh
cd /opt/tools/PEASS-ng/linPEAS && ./linpeas.sh
sudo -l
find / -perm -u=s -type f 2>/dev/null
```

### Descoberta de Rede
```bash
arp-scan -l
netdiscover -r 192.168.1.0/24
nmap -sn 192.168.1.0/24
```

## 🔧 Solução de Problemas

### Problemas com Container
```bash
docker logs kali-cli
docker logs kali-gui
docker restart kali-gui
```

### Problemas com VNC
```bash
docker exec -it kali-gui vncserver -kill :1
docker exec -it kali-gui vncserver :1 -geometry 1920x1080
```

### Resetar Tudo
```bash
make clean
make rebuild
```

## 📊 Monitoramento do Sistema
```bash
docker stats kali-cli kali-gui
docker exec -it kali-cli htop
make status
```

---
**💡 Dica Pro:** Mantenha sessões de terminal organizadas com `tmux` no container CLI!