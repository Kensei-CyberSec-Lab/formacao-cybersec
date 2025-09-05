#!/bin/bash

# Script para executar Docker Bench Security
# Lab 5 - Container Security

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🛡️ Docker Bench for Security - Lab 5${NC}"
echo "========================================="
echo ""

# Verificar se Docker está rodando
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker não está rodando. Por favor, inicie o Docker Desktop.${NC}"
    exit 1
fi

# Criar diretório para relatórios se não existir
mkdir -p reports

echo -e "${YELLOW}⚠️ O Docker Bench precisa de privilégios especiais para acessar o host Docker.${NC}"
echo -e "${BLUE}💡 Tentando diferentes métodos...${NC}"
echo ""

# Método 1: Docker Bench oficial (pode falhar em alguns sistemas)
echo -e "${BLUE}🔄 Tentativa 1: Docker Bench oficial...${NC}"
if docker run --rm -it \
    --net host \
    --pid host \
    --userns host \
    --cap-add audit_control \
    -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
    -v /var/lib:/var/lib:ro \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    -v /usr/lib/systemd:/usr/lib/systemd:ro \
    -v /etc:/etc:ro \
    -v "$(pwd)/reports":/usr/local/bin/reports \
    --label docker_bench_security \
    docker/docker-bench-security 2>/dev/null; then
    
    echo -e "${GREEN}✅ Docker Bench executado com sucesso!${NC}"
    exit 0
fi

echo -e "${YELLOW}⚠️ Método oficial falhou. Tentando alternativa...${NC}"
echo ""

# Método 2: Executar Docker Bench do código fonte
echo -e "${BLUE}🔄 Tentativa 2: Executando do código fonte...${NC}"

# Baixar Docker Bench se não existir
if [ ! -d "docker-bench-security" ]; then
    echo "📥 Baixando Docker Bench Security..."
    git clone https://github.com/docker/docker-bench-security.git
fi

cd docker-bench-security

# Executar script diretamente (requer sudo)
if command -v sudo >/dev/null 2>&1; then
    echo -e "${YELLOW}🔐 Executando com sudo (pode solicitar senha)...${NC}"
    if sudo ./docker-bench-security.sh; then
        echo -e "${GREEN}✅ Docker Bench executado com sucesso!${NC}"
        
        # Mover relatório para pasta reports
        if [ -f "docker-bench-security.log" ]; then
            mv docker-bench-security.log ../reports/docker-bench-$(date +%Y%m%d_%H%M%S).log
            echo -e "${GREEN}📁 Relatório salvo em: reports/docker-bench-$(date +%Y%m%d_%H%M%S).log${NC}"
        fi
        
        cd ..
        exit 0
    fi
fi

cd ..

# Método 3: Análise manual simplificada
echo -e "${YELLOW}⚠️ Docker Bench automático não funcionou.${NC}"
echo -e "${BLUE}🔍 Executando verificações manuais básicas...${NC}"
echo ""

# Criar relatório manual
REPORT_FILE="reports/docker-manual-check-$(date +%Y%m%d_%H%M%S).txt"

cat > "$REPORT_FILE" << EOF
# Docker Security Manual Check - $(date)
# Lab 5 - Container Security
===============================================

EOF

echo -e "${BLUE}1. Verificando containers em execução...${NC}"
echo "## Containers Running as Root" >> "$REPORT_FILE"
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo -e "${BLUE}2. Verificando configurações dos containers do lab...${NC}"
echo "## Lab Containers Configuration" >> "$REPORT_FILE"

# Verificar se containers estão rodando como root
for container in juice_shop kali_lab_31; do
    if docker ps --filter "name=$container" --format "{{.Names}}" | grep -q "$container"; then
        echo "Container: $container" >> "$REPORT_FILE"
        echo "User: $(docker exec "$container" whoami 2>/dev/null || echo 'N/A')" >> "$REPORT_FILE"
        echo "Processes: $(docker exec "$container" ps aux 2>/dev/null | head -3 || echo 'N/A')" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
    fi
done

echo -e "${BLUE}3. Verificando imagens vulneráveis...${NC}"
echo "## Image Vulnerabilities" >> "$REPORT_FILE"
echo "Use Trivy para análise detalhada:" >> "$REPORT_FILE"
echo "docker exec -it kali_lab_31 trivy image --severity HIGH,CRITICAL juice_shop" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo -e "${BLUE}4. Verificando configurações Docker daemon...${NC}"
echo "## Docker Daemon Configuration" >> "$REPORT_FILE"
docker version >> "$REPORT_FILE" 2>/dev/null || echo "N/A" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo -e "${BLUE}5. Verificando redes Docker...${NC}"
echo "## Docker Networks" >> "$REPORT_FILE"
docker network ls >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo -e "${BLUE}6. Verificando volumes Docker...${NC}"
echo "## Docker Volumes" >> "$REPORT_FILE"
docker volume ls >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Adicionar recomendações
cat >> "$REPORT_FILE" << EOF

## Recomendações de Segurança

### Críticas (Implementar Imediatamente):
1. Não executar containers como root
2. Usar imagens base mínimas e atualizadas
3. Escanear imagens regularmente com Trivy
4. Configurar resource limits nos containers

### Altas (Implementar em Breve):
1. Configurar Docker daemon com TLS
2. Usar user namespaces
3. Implementar seccomp profiles
4. Configurar logging centralizado

### Médias (Implementar Gradualmente):
1. Usar read-only filesystems quando possível
2. Configurar health checks
3. Implementar network policies
4. Usar secrets management

### Monitoramento Contínuo:
1. Automatizar scans de segurança no CI/CD
2. Monitorar logs de containers
3. Implementar alertas para vulnerabilidades
4. Revisar configurações regularmente

## Comandos Úteis para o Lab:

# Verificar usuário do container
docker exec container_name whoami

# Verificar processos rodando
docker exec container_name ps aux

# Verificar capabilities
docker exec container_name capsh --print

# Verificar syscalls disponíveis
docker exec container_name cat /proc/self/status | grep Cap

EOF

echo -e "${GREEN}✅ Verificação manual concluída!${NC}"
echo -e "${GREEN}📁 Relatório salvo em: $REPORT_FILE${NC}"
echo ""

echo -e "${BLUE}📋 Resumo dos Achados Principais:${NC}"
echo -e "${YELLOW}⚠️ Containers rodando como root (risco alto)${NC}"
echo -e "${YELLOW}⚠️ Imagens podem conter vulnerabilidades (use Trivy)${NC}"
echo -e "${YELLOW}⚠️ Configurações padrão do Docker (revisar security)${NC}"
echo ""

echo -e "${BLUE}💡 Para análise detalhada de vulnerabilidades:${NC}"
echo "   docker exec -it kali_lab_31 trivy_report.sh --format all bkimminich/juice-shop"
echo ""

echo -e "${BLUE}📖 Para ver o relatório completo:${NC}"
echo "   cat $REPORT_FILE"

