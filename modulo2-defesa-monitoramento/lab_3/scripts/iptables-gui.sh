#!/bin/bash

# =============================================================================
# Script Wrapper para Interface Gráfica - Interação com Container Ubuntu
# Laboratório de Defesa e Monitoramento - Módulo 2
# =============================================================================

echo "🖥️  Interface Gráfica - Wrapper de Firewall"
echo "============================================"

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Função para imprimir com cores
print_status() {
    local status=$1
    local message=$2
    
    case $status in
        "SUCCESS")
            echo -e "${GREEN}✅ $message${NC}"
            ;;
        "INFO")
            echo -e "${BLUE}ℹ️  $message${NC}"
            ;;
        "WARN")
            echo -e "${YELLOW}⚠️  $message${NC}"
            ;;
        "ERROR")
            echo -e "${RED}❌ $message${NC}"
            ;;
    esac
}

# Função para verificar se o container Ubuntu está rodando
check_ubuntu_container() {
    if ! docker ps | grep -q "ubuntu_lab_19"; then
        print_status "ERROR" "Container Ubuntu não está rodando"
        print_status "INFO" "Execute: docker-compose up -d"
        return 1
    fi
    return 0
}

# Função para mostrar regras de firewall
show_rules() {
    print_status "INFO" "Obtendo regras de firewall do container Ubuntu..."
    echo ""
    docker exec ubuntu_lab_19 iptables -L -v -n
}

# Função para aplicar regras de exemplo
apply_example_rules() {
    print_status "INFO" "Aplicando regras de exemplo no container Ubuntu..."
    docker exec ubuntu_lab_19 /opt/lab-scripts/iptables-example.sh apply
}

# Função para limpar regras
clear_rules() {
    print_status "INFO" "Limpando regras de firewall no container Ubuntu..."
    docker exec ubuntu_lab_19 /opt/lab-scripts/iptables-example.sh clear
}

# Função para testar conectividade
test_connectivity() {
    print_status "INFO" "Executando testes de conectividade..."
    echo ""
    print_status "INFO" "Teste 1: Ping do Kali para Ubuntu"
    docker exec kali_lab_19 ping -c 3 192.168.100.10
    echo ""
    print_status "INFO" "Teste 2: SSH do Kali para Ubuntu (deve ser bloqueado)"
    docker exec kali_lab_19 ssh -o ConnectTimeout=3 -o StrictHostKeyChecking=no root@192.168.100.10 "echo 'test'" 2>&1 || echo "SSH bloqueado (esperado)"
}

# Função para mostrar logs
show_logs() {
    print_status "INFO" "Mostrando logs do container Ubuntu..."
    echo ""
    docker logs ubuntu_lab_19 --tail 10
}

# Função para executar comando customizado
custom_command() {
    local cmd="$1"
    if [ -z "$cmd" ]; then
        print_status "ERROR" "Comando não especificado"
        return 1
    fi
    
    print_status "INFO" "Executando comando no container Ubuntu: $cmd"
    docker exec ubuntu_lab_19 bash -c "$cmd"
}

# Função para mostrar ajuda
show_help() {
    echo "Uso: $0 [opção] [comando]"
    echo ""
    echo "Opções:"
    echo "  -L, --list          - Mostrar regras de firewall"
    echo "  -A, --apply         - Aplicar regras de exemplo"
    echo "  -C, --clear         - Limpar todas as regras"
    echo "  -t, --test          - Testar conectividade"
    echo "  -l, --logs          - Mostrar logs do container"
    echo "  -e, --exec <cmd>    - Executar comando customizado"
    echo "  -h, --help          - Mostrar esta ajuda"
    echo ""
    echo "Exemplos:"
    echo "  $0 -L                    # Listar regras"
    echo "  $0 -A                    # Aplicar regras de exemplo"
    echo "  $0 -e 'iptables -L'      # Executar comando customizado"
    echo "  $0 -t                    # Testar conectividade"
}

# Função principal
main() {
    # Verificar se o container está rodando
    if ! check_ubuntu_container; then
        exit 1
    fi
    
    case "${1:-help}" in
        "-L"|"--list")
            show_rules
            ;;
        "-A"|"--apply")
            apply_example_rules
            ;;
        "-C"|"--clear")
            clear_rules
            ;;
        "-t"|"--test")
            test_connectivity
            ;;
        "-l"|"--logs")
            show_logs
            ;;
        "-e"|"--exec")
            custom_command "$2"
            ;;
        "-h"|"--help"|"help")
            show_help
            ;;
        *)
            print_status "ERROR" "Opção inválida: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Executar função principal
main "$@"
