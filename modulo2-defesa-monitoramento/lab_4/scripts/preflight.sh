#!/bin/bash
set -euo pipefail

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔍 Pré-Flight Check - Lab IDS/IPS Suricata"
echo "=========================================="

# Contador de checks
TOTAL_CHECKS=0
PASSED_CHECKS=0

# Função para verificar e reportar
check() {
    local name="$1"
    local command="$2"
    local expected="$3"
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if eval "$command" >/dev/null 2>&1; then
        echo -e "${GREEN}[OK]${NC} $name: $expected"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        echo -e "${RED}[FAIL]${NC} $name: falhou"
        return 1
    fi
}

# Função para verificar versão
check_version() {
    local name="$1"
    local command="$2"
    local min_version="$3"
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if version=$(eval "$command" 2>/dev/null); then
        echo -e "${GREEN}[OK]${NC} $name: $version"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        echo -e "${RED}[FAIL]${NC} $name: não encontrado"
        return 1
    fi
}

echo ""
echo "📦 Verificando Docker e Compose..."

# Check Docker
if check_version "Docker" "docker --version" "versão encontrada"; then
    # Verificar se Docker está rodando
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if docker info >/dev/null 2>&1; then
        echo -e "${GREEN}[OK]${NC} Docker daemon: rodando"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo -e "${RED}[FAIL]${NC} Docker daemon: não está rodando"
        echo "   💡 Execute: sudo systemctl start docker (Linux) ou abra Docker Desktop (macOS)"
    fi
fi

# Check Docker Compose
check_version "Docker Compose" "docker compose version" "versão encontrada"

echo ""
echo "🌐 Verificando portas..."

# Check portas
PORTS=(8080 5636 8088)
for port in "${PORTS[@]}"; do
    if lsof -i ":$port" >/dev/null 2>&1; then
        echo -e "${RED}[FAIL]${NC} Porta $port: ocupada"
        echo "   💡 Execute: lsof -ti:$port | xargs kill -9"
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    else
        echo -e "${GREEN}[OK]${NC} Porta $port: livre"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    fi
done

echo ""
echo "💾 Verificando recursos..."

# Check RAM
if command -v free >/dev/null 2>&1; then
    # Linux
    ram_gb=$(free -g | awk '/^Mem:/{print $2}')
    if [ "$ram_gb" -ge 4 ]; then
        echo -e "${GREEN}[OK]${NC} RAM: ${ram_gb}GB disponível"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo -e "${YELLOW}[WARN]${NC} RAM: ${ram_gb}GB (mínimo 4GB recomendado)"
    fi
elif command -v sysctl >/dev/null 2>&1; then
    # macOS
    ram_bytes=$(sysctl -n hw.memsize 2>/dev/null || echo "0")
    ram_gb=$((ram_bytes / 1024 / 1024 / 1024))
    if [ "$ram_gb" -ge 4 ]; then
        echo -e "${GREEN}[OK]${NC} RAM: ${ram_gb}GB disponível"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo -e "${YELLOW}[WARN]${NC} RAM: ${ram_gb}GB (mínimo 4GB recomendado)"
    fi
else
    echo -e "${YELLOW}[WARN]${NC} RAM: não foi possível verificar"
fi
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

# Check arquitetura
arch=$(uname -m)
case $arch in
    x86_64)
        echo -e "${GREEN}[OK]${NC} Arquitetura: x86_64 (Intel/AMD)"
        ;;
    arm64|aarch64)
        echo -e "${GREEN}[OK]${NC} Arquitetura: arm64 (Apple Silicon/ARM)"
        ;;
    *)
        echo -e "${YELLOW}[WARN]${NC} Arquitetura: $arch (pode ter limitações)"
        ;;
esac
PASSED_CHECKS=$((PASSED_CHECKS + 1))
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

echo ""
echo "📁 Verificando estrutura do projeto..."

# Check arquivos essenciais
ESSENTIAL_FILES=(
    "docker-compose.yml"
    "suricata/suricata.yaml"
    "suricata/rules/local.rules"
    "web_victim/html/index.html"
)

for file in "${ESSENTIAL_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}[OK]${NC} $file: encontrado"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo -e "${RED}[FAIL]${NC} $file: não encontrado"
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
done

echo ""
echo "🔧 Verificando permissões..."

# Check permissões de logs
if [ -d "suricata/logs" ]; then
    if [ -w "suricata/logs" ]; then
        echo -e "${GREEN}[OK]${NC} Permissões logs: gravável"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo -e "${RED}[FAIL]${NC} Permissões logs: sem permissão de escrita"
        echo "   💡 Execute: sudo chown -R \$USER:\$USER ./suricata/logs/"
    fi
else
    echo -e "${YELLOW}[WARN]${NC} Diretório logs: não existe (será criado)"
fi
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

echo ""
echo "📊 Resumo dos Checks"
echo "==================="
echo "Total de checks: $TOTAL_CHECKS"
echo "Passou: $PASSED_CHECKS"
echo "Falhou: $((TOTAL_CHECKS - PASSED_CHECKS))"


if [ $PASSED_CHECKS -eq $TOTAL_CHECKS ]; then
    echo ""
    echo -e "${GREEN}🎉 Todos os checks passaram! ✅${NC}"
    echo "   Você pode prosseguir com o lab."
    exit 0
else
    echo ""
    echo -e "${YELLOW}⚠️  Alguns checks falharam.${NC}"
    echo "   Corrija os problemas antes de continuar."
    echo ""
    echo "💡 Dicas rápidas:"
    echo "   - Docker não roda: sudo systemctl start docker (Linux) ou Docker Desktop (macOS)"
    echo "   - Porta ocupada: lsof -ti:PORTA | xargs kill -9"
    echo "   - Permissões: sudo chown -R \$USER:\$USER ./suricata/logs/"
    echo "   - RAM baixa: feche outros programas ou use docker system prune -f"
    exit 1
fi
