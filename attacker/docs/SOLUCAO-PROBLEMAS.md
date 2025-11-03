# Guia de Solução de Problemas

## Problemas Comuns e Soluções

### 🐳 Problemas com Docker

#### Container não inicia
```bash
# Verificar se o Docker está executando
docker info

# Verificar logs do container
docker-compose logs kali-cli
docker-compose logs kali-gui

# Reiniciar serviço Docker (Linux)
sudo systemctl restart docker

# Reiniciar Docker Desktop (macOS/Windows)
# Usar interface do Docker Desktop
```

#### Conflitos de porta
```bash
# Verificar o que está usando as portas
lsof -i :5901  # porta VNC
lsof -i :6080  # porta noVNC

# Finalizar processos usando as portas
sudo kill -9 $(lsof -t -i :5901)
sudo kill -9 $(lsof -t -i :6080)

# Usar portas diferentes no docker-compose.yml
ports:
  - "5902:5901"  # Usar 5902 ao invés
  - "6081:6080"  # Usar 6081 ao invés
```

### 🖥️ Problemas com VNC

#### Não consegue conectar ao VNC
1. **Verificar se o container está executando:**
   ```bash
   docker ps | grep kali-gui
   ```

2. **Verificar serviço VNC dentro do container:**
   ```bash
   docker exec -it kali-gui ps aux | grep vnc
   ```

3. **Reiniciar serviço VNC:**
   ```bash
   docker exec -it kali-gui vncserver -kill :1
   docker exec -it kali-gui vncserver :1 -geometry 1920x1080
   ```

#### Problemas com senha VNC
```bash
# Resetar senha VNC dentro do container
docker exec -it kali-gui vncpasswd
```

#### Problemas de display no VNC
```bash
# Reiniciar ambiente desktop
docker exec -it kali-gui pkill -f xfce4
docker exec -it kali-gui startxfce4 &
```

### 🌐 Problemas com noVNC Web

#### Interface web não acessível
1. **Verificar serviço noVNC:**
   ```bash
   docker exec -it kali-gui ps aux | grep websockify
   ```

2. **Reiniciar noVNC:**
   ```bash
   docker exec -it kali-gui pkill websockify
   docker exec -it kali-gui websockify --web=/usr/share/novnc/ 6080 localhost:5901 &
   ```

3. **Verificar firewall:**
   ```bash
   # Linux
   sudo ufw status
   sudo ufw allow 6080

   # macOS
   # Verificar Preferências do Sistema > Segurança e Privacidade > Firewall
   ```

### 🛠️ Problemas com Ferramentas

#### Erros de banco de dados do Metasploit
```bash
# Reinicializar banco de dados
docker exec -it kali-cli msfdb reinit
docker exec -it kali-cli msfdb start
```

#### Ferramentas ausentes
```bash
# Atualizar lista de pacotes
docker exec -it kali-cli apt update

# Instalar ferramenta específica
docker exec -it kali-cli apt install -y nome-da-ferramenta

# Instalar todas as ferramentas do Kali
docker exec -it kali-cli apt install -y kali-linux-everything
```

### 💾 Problemas de Armazenamento

#### Container sem espaço
```bash
# Limpar sistema Docker
docker system prune -a

# Remover volumes não utilizados
docker volume prune

# Verificar uso do disco
docker exec -it kali-cli df -h
```

#### Problemas de montagem de volume
```bash
# Verificar montagens de volume
docker inspect kali-cli | grep -A 10 "Mounts"

# Recriar volumes
docker-compose down -v
docker-compose up -d
```

### 🔧 Problemas de Performance

#### Container executando lentamente
1. **Aumentar recursos do Docker:**
   - Docker Desktop: Preferências > Recursos
   - Aumentar RAM para 4GB+ e núcleos CPU para 2+

2. **Fechar aplicações desnecessárias:**
   ```bash
   docker exec -it kali-gui pkill firefox
   docker exec -it kali-gui pkill chromium
   ```

3. **Usar container CLI para tarefas pesadas:**
   ```bash
   # CLI é mais eficiente para ferramentas de linha de comando
   docker exec -it kali-cli nmap target
   ```

### 🖱️ Problemas com GUI

#### Desktop não responsivo
```bash
# Reiniciar sessão desktop
docker restart kali-gui

# Ou finalizar e reiniciar desktop
docker exec -it kali-gui pkill -f xfce4-session
docker exec -it kali-gui startxfce4 &
```

#### Aplicações não iniciam
```bash
# Verificar variável de ambiente display
docker exec -it kali-gui echo $DISPLAY

# Corrigir variável display
docker exec -it kali-gui export DISPLAY=:1
```

### 🔒 Problemas de Permissão

#### Não consegue acessar pasta compartilhada
```bash
# Verificar permissões
ls -la ./shared/

# Corrigir permissões
sudo chown -R $USER:$USER ./shared/
chmod -R 755 ./shared/
```

## 🚨 Reset de Emergência

Se nada mais funcionar, reset completo:

```bash
# Parar tudo
docker-compose down -v

# Remover imagens
docker rmi attacker_kali-cli attacker_kali-gui

# Limpar sistema
docker system prune -a

# Reconstruir do zero
docker-compose build --no-cache
docker-compose up -d
```

## 📞 Obtendo Ajuda

1. **Verificar logs primeiro:**
   ```bash
   docker-compose logs --tail=50 kali-cli
   docker-compose logs --tail=50 kali-gui
   ```

2. **Verificar uso de recursos do container:**
   ```bash
   docker stats kali-cli kali-gui
   ```

3. **Testar conectividade:**
   ```bash
   # Testar porta VNC
   telnet localhost 5901

   # Testar porta noVNC  
   curl -I http://localhost:6080
   ```

4. **Verificar saúde do container:**
   ```bash
   docker exec -it kali-cli uname -a
   docker exec -it kali-gui uname -a
   ```

## 📋 Requisitos do Sistema

### Mínimo:
- RAM: 4GB
- CPU: 2 núcleos
- Armazenamento: 20GB livres
- Docker: 20.10+

### Recomendado:
- RAM: 8GB+
- CPU: 4+ núcleos  
- Armazenamento: 50GB+ livres
- Armazenamento SSD para melhor performance