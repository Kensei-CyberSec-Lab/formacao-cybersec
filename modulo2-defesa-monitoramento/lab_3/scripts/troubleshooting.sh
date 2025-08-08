#!/bin/bash

# =============================================================================
# Script de Troubleshooting: Diagnóstico e Correção de Problemas
# Laboratório de Defesa e Monitoramento - Módulo 2
# =============================================================================

echo "🔧 Troubleshooting - Diagnóstico e Correção"
echo "============================================"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir com cores
print_status() {
    local status=$1
    local message=$2
    
    case $status in
        "OK")
            echo -e "${GREEN}✅ OK${NC}: $message"
            ;;
        "ERROR")
            echo -e "${RED}❌ ERROR${NC}: $message"
            ;;
        "WARN")
            echo -e "${YELLOW}⚠️  WARN${NC}: $message"
            ;;
        "INFO")
            echo -e "${BLUE}ℹ️  INFO${NC}: $message"
            ;;
        "FIX")
            echo -e "${YELLOW}🔧 FIX${NC}: $message"
            ;;
    esac
}

# Função para verificar se Docker está instalado
check_docker() {
    echo ""
    echo "🐳 Verificando Docker..."
    echo "========================"
    
    if command -v docker >/dev/null 2>&1; then
        print_status "OK" "Docker está instalado"
        docker --version
    else
        print_status "ERROR" "Docker não está instalado"
        print_status "FIX" "Instale o Docker: https://docs.docker.com/get-docker/"
        return 1
    fi
    
    if command -v docker-compose >/dev/null 2>&1; then
        print_status "OK" "Docker Compose está instalado"
        docker-compose --version
    else
        print_status "ERROR" "Docker Compose não está instalado"
        print_status "FIX" "Instale o Docker Compose: https://docs.docker.com/compose/install/"
        return 1
    fi
}

# Função para verificar containers
check_containers() {
    echo ""
    echo "📦 Verificando Containers..."
    echo "============================"
    
    # Verificar se os containers estão rodando
    local containers=("kali_lab_19" "ubuntu_lab_19" "ubuntu_gui")
    local all_running=true
    
    for container in "${containers[@]}"; do
        if docker ps --format "table {{.Names}}" | grep -q "^$container$"; then
            print_status "OK" "Container $container está rodando"
        else
            print_status "ERROR" "Container $container não está rodando"
            all_running=false
        fi
    done
    
    if [ "$all_running" = false ]; then
        print_status "FIX" "Execute: docker-compose up -d"
        return 1
    fi
    
    return 0
}

# Função para verificar rede
check_network() {
    echo ""
    echo "🌐 Verificando Rede..."
    echo "====================="
    
    # Verificar se a rede existe
    if docker network ls | grep -q "lab_3_cybersec_lab_19"; then
        print_status "OK" "Rede lab_3_cybersec_lab_19 existe"
    else
        print_status "ERROR" "Rede lab_3_cybersec_lab_19 não existe"
        print_status "FIX" "Execute: docker-compose up -d"
        return 1
    fi
    
    # Testar conectividade entre containers
    print_status "INFO" "Testando conectividade entre containers..."
    
    if docker exec kali_lab_19 ping -c 1 192.168.100.10 >/dev/null 2>&1; then
        print_status "OK" "Kali pode acessar Ubuntu"
    else
        print_status "ERROR" "Kali não consegue acessar Ubuntu"
        print_status "FIX" "Verifique a configuração de rede"
    fi
    
    if docker exec ubuntu_lab_19 ping -c 1 192.168.100.11 >/dev/null 2>&1; then
        print_status "OK" "Ubuntu pode acessar Kali"
    else
        print_status "ERROR" "Ubuntu não consegue acessar Kali"
        print_status "FIX" "Verifique a configuração de rede"
    fi
}

# Função para verificar serviços
check_services() {
    echo ""
    echo "🔧 Verificando Serviços..."
    echo "=========================="
    
    # Verificar SSH no Ubuntu
    if docker exec ubuntu_lab_19 service ssh status >/dev/null 2>&1; then
        print_status "OK" "SSH está rodando no Ubuntu"
    else
        print_status "ERROR" "SSH não está rodando no Ubuntu"
        print_status "FIX" "Execute: docker exec ubuntu_lab_19 service ssh start"
    fi
    
    # Verificar se as portas estão abertas
    if docker exec ubuntu_lab_19 netstat -tuln | grep -q ":22 "; then
        print_status "OK" "Porta 22 (SSH) está aberta no Ubuntu"
    else
        print_status "ERROR" "Porta 22 (SSH) não está aberta no Ubuntu"
        print_status "FIX" "Verifique se o SSH está rodando"
    fi
}

# Função para verificar ferramentas
check_tools() {
    echo ""
    echo "🛠️ Verificando Ferramentas..."
    echo "============================="
    
    # Verificar iptables no Ubuntu
    if docker exec ubuntu_lab_19 command -v iptables >/dev/null 2>&1; then
        print_status "OK" "iptables está instalado no Ubuntu"
    else
        print_status "ERROR" "iptables não está instalado no Ubuntu"
        print_status "FIX" "Execute: docker exec ubuntu_lab_19 apt-get update && apt-get install -y iptables"
    fi
    
    # Verificar nmap no Kali
    if docker exec kali_lab_19 command -v nmap >/dev/null 2>&1; then
        print_status "OK" "nmap está instalado no Kali"
    else
        print_status "ERROR" "nmap não está instalado no Kali"
        print_status "FIX" "Execute: docker exec kali_lab_19 apt-get update && apt-get install -y nmap"
    fi
    
    # Verificar scripts
    if docker exec ubuntu_lab_19 test -f /opt/lab-scripts/iptables-example.sh; then
        print_status "OK" "Script iptables-example.sh existe no Ubuntu"
    else
        print_status "ERROR" "Script iptables-example.sh não existe no Ubuntu"
        print_status "FIX" "Reconstrua os containers: docker-compose build"
    fi
}

# Função para verificar permissões
check_permissions() {
    echo ""
    echo "🔐 Verificando Permissões..."
    echo "============================"
    
    # Verificar se o script é executável
    if docker exec ubuntu_lab_19 test -x /opt/lab-scripts/iptables-example.sh; then
        print_status "OK" "Script iptables-example.sh é executável"
    else
        print_status "ERROR" "Script iptables-example.sh não é executável"
        print_status "FIX" "Execute: docker exec ubuntu_lab_19 chmod +x /opt/lab-scripts/iptables-example.sh"
    fi
}

# Função para verificar logs
check_logs() {
    echo ""
    echo "📝 Verificando Logs..."
    echo "======================"
    
    # Verificar logs do Docker
    print_status "INFO" "Últimos logs do container Ubuntu:"
    docker logs ubuntu_lab_19 --tail 5
    
    print_status "INFO" "Últimos logs do container Kali:"
    docker logs kali_lab_19 --tail 5
}

# Função para correção automática
auto_fix() {
    echo ""
    echo "🔧 Aplicando Correções Automáticas..."
    echo "===================================="
    
    # Reiniciar containers se necessário
    if ! docker ps --format "table {{.Names}}" | grep -q "kali_lab_19"; then
        print_status "FIX" "Reiniciando containers..."
        docker-compose down
        docker-compose up -d
    fi
    
    # Iniciar SSH se não estiver rodando
    if ! docker exec ubuntu_lab_19 service ssh status >/dev/null 2>&1; then
        print_status "FIX" "Iniciando SSH no Ubuntu..."
        docker exec ubuntu_lab_19 service ssh start
    fi
    
    # Tornar script executável se necessário
    if ! docker exec ubuntu_lab_19 test -x /opt/lab-scripts/iptables-example.sh; then
        print_status "FIX" "Tornando script executável..."
        docker exec ubuntu_lab_19 chmod +x /opt/lab-scripts/iptables-example.sh
    fi
}

# Função para mostrar comandos úteis
show_useful_commands() {
    echo ""
    echo "💡 Comandos Úteis"
    echo "================="
    echo ""
    echo "🐳 Gerenciamento de Containers:"
    echo "  docker ps                    # Ver containers rodando"
    echo "  docker-compose up -d         # Iniciar containers"
    echo "  docker-compose down          # Parar containers"
    echo "  docker-compose restart       # Reiniciar containers"
    echo "  docker-compose logs          # Ver logs"
    echo ""
    echo "🔧 Acesso aos Containers:"
    echo "  docker exec -it kali_lab_19 bash     # Acessar Kali"
    echo "  docker exec -it ubuntu_lab_19 bash   # Acessar Ubuntu"
    echo ""
    echo "🛡️ Firewall:"
    echo "  docker exec ubuntu_lab_19 /opt/lab-scripts/iptables-example.sh apply"
    echo "  docker exec ubuntu_lab_19 iptables -L -v -n"
    echo "  docker exec ubuntu_lab_19 iptables -F"
    echo ""
    echo "🧪 Testes:"
    echo "  ./scripts/test-firewall.sh all"
    echo "  docker exec kali_lab_19 ping -c 3 192.168.100.10"
    echo "  docker exec kali_lab_19 ssh root@192.168.100.10"
    echo ""
    echo "📝 Logs:"
    echo "  docker exec ubuntu_lab_19 tail -f /var/log/syslog"
    echo "  docker logs ubuntu_lab_19"
    echo "  docker logs kali_lab_19"
}

# Função para diagnóstico completo
full_diagnosis() {
    echo "🔍 Iniciando Diagnóstico Completo..."
    echo "===================================="
    
    local issues_found=0
    
    # Executar todas as verificações
    check_docker || ((issues_found++))
    check_containers || ((issues_found++))
    check_network || ((issues_found++))
    check_services || ((issues_found++))
    check_tools || ((issues_found++))
    check_permissions || ((issues_found++))
    check_logs
    
    echo ""
    echo "📊 Resumo do Diagnóstico"
    echo "========================"
    
    if [ $issues_found -eq 0 ]; then
        print_status "OK" "Nenhum problema encontrado! O laboratório está funcionando corretamente."
    else
        print_status "WARN" "Encontrados $issues_found problema(s). Aplicando correções automáticas..."
        auto_fix
    fi
    
    show_useful_commands
}

# Função para mostrar ajuda
show_help() {
    echo "Uso: $0 [opção]"
    echo ""
    echo "Opções:"
    echo "  all       - Diagnóstico completo (padrão)"
    echo "  docker    - Verificar Docker e Docker Compose"
    echo "  containers - Verificar containers"
    echo "  network   - Verificar rede"
    echo "  services  - Verificar serviços"
    echo "  tools     - Verificar ferramentas"
    echo "  permissions - Verificar permissões"
    echo "  logs      - Verificar logs"
    echo "  fix       - Aplicar correções automáticas"
    echo "  commands  - Mostrar comandos úteis"
    echo "  help      - Mostrar esta ajuda"
    echo ""
    echo "Exemplo:"
    echo "  $0 all       # Diagnóstico completo"
    echo "  $0 network   # Verificar apenas rede"
    echo "  $0 fix       # Aplicar correções"
}

# Função principal
main() {
    case "${1:-all}" in
        "all")
            full_diagnosis
            ;;
        "docker")
            check_docker
            ;;
        "containers")
            check_containers
            ;;
        "network")
            check_network
            ;;
        "services")
            check_services
            ;;
        "tools")
            check_tools
            ;;
        "permissions")
            check_permissions
            ;;
        "logs")
            check_logs
            ;;
        "fix")
            auto_fix
            ;;
        "commands")
            show_useful_commands
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            echo "❌ Opção inválida: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Executar função principal
main "$@"
