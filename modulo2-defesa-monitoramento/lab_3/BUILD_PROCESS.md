# 🔧 Processo de Build - Laboratório de Firewall

## 📋 Visão Geral

Este documento descreve o processo completo de build do laboratório de firewall, garantindo que todos os scripts sejam criados e disponibilizados corretamente para os usuários.

## 🎯 Objetivo

Garantir que quando um usuário iniciar um novo laboratório, todos os scripts necessários estejam disponíveis e funcionais.

## 📁 Estrutura de Scripts

### Scripts no Host (scripts/)
- `setup-lab.sh` - Script principal de configuração do laboratório
- `iptables-gui.sh` - Wrapper para interface gráfica
- `iptables-example.sh` - Exemplos de configuração de firewall
- `quick-setup.sh` - Configuração rápida
- `test-firewall.sh` - Testes de validação
- `troubleshooting.sh` - Diagnóstico e correção de problemas

### Scripts no Container Ubuntu (/opt/lab-scripts/)
- `iptables-example.sh` - Exemplos de configuração de firewall
- `quick-setup.sh` - Configuração rápida
- `test-firewall.sh` - Testes de validação
- `troubleshooting.sh` - Diagnóstico e correção de problemas

### Scripts no Container GUI (/usr/local/bin/)
- `iptables-gui` - Wrapper para interface gráfica

## 🔄 Processo de Build

### 1. Build dos Containers
```bash
# Reconstruir containers com todos os scripts
docker-compose build

# Ou reconstruir apenas o Ubuntu
docker-compose build ubuntu_lab_19
```

### 2. Inicialização do Laboratório
```bash
# Iniciar todos os containers
docker-compose up -d

# Ou usar o script de setup completo
./scripts/setup-lab.sh
```

### 3. Verificação de Scripts
```bash
# Verificar scripts no Ubuntu container
docker exec ubuntu_lab_19 ls -la /opt/lab-scripts/

# Verificar scripts no host
ls -la scripts/

# Verificar wrapper na GUI
docker exec ubuntu_gui which iptables-gui
```

## ✅ Checklist de Verificação

### Antes do Build
- [ ] Todos os scripts estão criados em `scripts/`
- [ ] Todos os scripts têm permissão de execução (`chmod +x`)
- [ ] Dockerfile.ubuntu copia todos os scripts necessários
- [ ] setup-lab.sh copia o wrapper para a GUI

### Durante o Build
- [ ] Docker build não apresenta erros
- [ ] Todos os scripts são copiados para `/opt/lab-scripts/`
- [ ] Permissões são definidas corretamente
- [ ] Wrapper é copiado para a GUI

### Após o Build
- [ ] Containers iniciam sem erros
- [ ] Scripts são executáveis nos containers
- [ ] Wrapper funciona na GUI
- [ ] Testes de conectividade passam

## 🛠️ Comandos de Verificação

### Verificar Build
```bash
# Reconstruir containers
docker-compose build

# Verificar se build foi bem-sucedido
docker images | grep lab_3
```

### Verificar Scripts
```bash
# Verificar scripts no Ubuntu
docker exec ubuntu_lab_19 ls -la /opt/lab-scripts/

# Verificar scripts no host
ls -la scripts/

# Testar execução de scripts
docker exec ubuntu_lab_19 /opt/lab-scripts/iptables-example.sh help
```

### Verificar Funcionalidade
```bash
# Teste completo
./scripts/test-firewall.sh all

# Diagnóstico completo
./scripts/troubleshooting.sh all

# Setup completo
./scripts/setup-lab.sh
```

## 🔧 Solução de Problemas

### Problema: Script não encontrado
```bash
# Verificar se script existe
ls -la scripts/nome-do-script.sh

# Verificar se foi copiado para container
docker exec ubuntu_lab_19 ls -la /opt/lab-scripts/

# Reconstruir container se necessário
docker-compose build ubuntu_lab_19
```

### Problema: Permissão negada
```bash
# Dar permissão de execução
chmod +x scripts/nome-do-script.sh

# Verificar permissões no container
docker exec ubuntu_lab_19 ls -la /opt/lab-scripts/
```

### Problema: Container não inicia
```bash
# Verificar logs
docker-compose logs

# Reiniciar containers
docker-compose down
docker-compose up -d
```

## 📚 Scripts Disponíveis

### Para Usuários Finais

#### 1. Setup Inicial
```bash
./scripts/setup-lab.sh
```
- Configura todo o ambiente
- Instala dependências
- Copia scripts para containers
- Inicia serviços

#### 2. Testes de Validação
```bash
./scripts/test-firewall.sh all
```
- Testa conectividade
- Verifica regras de firewall
- Valida configurações

#### 3. Diagnóstico
```bash
./scripts/troubleshooting.sh all
```
- Diagnostica problemas
- Sugere correções
- Verifica status dos serviços

### Para Administradores

#### 1. Configuração de Firewall
```bash
# No Ubuntu container
docker exec -it ubuntu_lab_19 /opt/lab-scripts/iptables-example.sh apply

# Na interface gráfica
iptables-gui -A
```

#### 2. Configuração Rápida
```bash
# No Ubuntu container
docker exec -it ubuntu_lab_19 /opt/lab-scripts/quick-setup.sh setup
```

#### 3. Testes Específicos
```bash
# Teste de conectividade
./scripts/test-firewall.sh basic

# Teste de SSH
./scripts/test-firewall.sh ssh

# Teste de regras
./scripts/test-firewall.sh rules
```

## 🎯 Garantias de Qualidade

### 1. Verificação Automática
- Todos os scripts são testados durante o build
- Permissões são verificadas automaticamente
- Funcionalidade é validada

### 2. Documentação
- README.md contém instruções completas
- Scripts têm ajuda integrada (`--help`)
- Exemplos de uso são fornecidos

### 3. Recuperação
- Scripts de troubleshooting identificam problemas
- Correções automáticas são aplicadas quando possível
- Logs detalhados para diagnóstico

## 🚀 Próximos Passos

1. **Para Usuários**: Execute `./scripts/setup-lab.sh` para iniciar
2. **Para Desenvolvedores**: Use `docker-compose build` para reconstruir
3. **Para Testes**: Execute `./scripts/test-firewall.sh all` para validar

## 📞 Suporte

Se encontrar problemas:
1. Execute `./scripts/troubleshooting.sh all`
2. Verifique os logs: `docker-compose logs`
3. Reconstrua os containers: `docker-compose build`
4. Consulte este documento para soluções específicas

---

**Status**: ✅ Build Process Validated  
**Última Atualização**: $(date)  
**Versão**: 1.0
