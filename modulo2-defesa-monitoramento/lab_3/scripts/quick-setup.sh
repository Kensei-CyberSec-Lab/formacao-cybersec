#!/bin/bash

# =============================================================================
# Script de Configuração Rápida: Setup Automatizado do Laboratório
# Laboratório de Defesa e Monitoramento - Módulo 2
# =============================================================================

echo "⚡ Configuração Rápida - Setup Automatizado"
echo "==========================================="

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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
    esac
}

# Função para verificar se está rodando como root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "❌ Este script deve ser executado como root"
        echo "Use: sudo $0"
        exit 1
    fi
}

# Função para iniciar serviços essenciais
start_essential_services() {
    print_status "INFO" "Iniciando serviços essenciais..."
    
    # Iniciar SSH se não estiver rodando
    if ! service ssh status >/dev/null 2>&1; then
        print_status "INFO" "Iniciando SSH..."
        service ssh start
        print_status "SUCCESS" "SSH iniciado com sucesso"
    else
        print_status "SUCCESS" "SSH já está rodando"
    fi
    
    # Verificar se iptables está disponível
    if ! command -v iptables >/dev/null 2>&1; then
        print_status "WARN" "iptables não está instalado. Instalando..."
        apt-get update && apt-get install -y iptables
        print_status "SUCCESS" "iptables instalado"
    else
        print_status "SUCCESS" "iptables já está instalado"
    fi
}

# Função para aplicar configuração básica de firewall
apply_basic_firewall() {
    print_status "INFO" "Aplicando configuração básica de firewall..."
    
    # Limpar regras existentes
    iptables -F
    iptables -X
    iptables -t nat -F
    iptables -t nat -X
    iptables -t mangle -F
    iptables -t mangle -X
    
    # Definir política padrão
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT
    
    # Permitir conexões estabelecidas
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    
    # Permitir tráfego local
    iptables -A INPUT -i lo -j ACCEPT
    
    # Permitir HTTP
    iptables -A INPUT -p tcp --dport 80 -j ACCEPT
    
    # Bloquear SSH do Kali
    iptables -A INPUT -s 192.168.100.11 -p tcp --dport 22 -j DROP
    
    # Permitir SSH de outros IPs
    iptables -A INPUT -p tcp --dport 22 -j ACCEPT
    
    # Adicionar logging
    iptables -A INPUT -s 192.168.100.11 -j LOG --log-prefix "BLOCKED_KALI: "
    
    print_status "SUCCESS" "Configuração básica de firewall aplicada"
}

# Função para salvar configurações
save_configurations() {
    print_status "INFO" "Salvando configurações..."
    
    # Criar diretório para iptables se não existir
    mkdir -p /etc/iptables
    
    # Salvar regras de iptables
    iptables-save > /etc/iptables/rules.v4
    
    print_status "SUCCESS" "Configurações salvas em /etc/iptables/rules.v4"
}

# Função para testar configuração
test_configuration() {
    print_status "INFO" "Testando configuração..."
    
    echo ""
    echo "📋 Regras de firewall aplicadas:"
    echo "================================"
    iptables -L INPUT --line-numbers
    
    echo ""
    echo "🌐 Testando conectividade:"
    echo "=========================="
    
    # Testar ping para o Kali
    if ping -c 1 192.168.100.11 >/dev/null 2>&1; then
        print_status "SUCCESS" "Ping para Kali: FUNCIONANDO"
    else
        print_status "WARN" "Ping para Kali: FALHOU"
    fi
    
    # Verificar se SSH está rodando
    if netstat -tuln | grep -q ":22 "; then
        print_status "SUCCESS" "SSH está rodando na porta 22"
    else
        print_status "WARN" "SSH não está rodando na porta 22"
    fi
}

# Função para mostrar próximos passos
show_next_steps() {
    echo ""
    echo "🎯 Próximos Passos"
    echo "=================="
    echo ""
    echo "1. Teste a conectividade SSH do Kali:"
    echo "   docker exec -it kali_lab_19 ssh root@192.168.100.10"
    echo ""
    echo "2. Verifique os logs de firewall:"
    echo "   tail -f /var/log/syslog | grep BLOCKED_KALI"
    echo ""
    echo "3. Execute testes completos:"
    echo "   ./scripts/test-firewall.sh all"
    echo ""
    echo "4. Acesse a interface gráfica:"
    echo "   Navegador: http://localhost:6080"
    echo "   VNC: localhost:5901 (senha: kenseilab)"
    echo ""
    echo "5. Para mais opções de firewall:"
    echo "   /opt/lab-scripts/iptables-example.sh help"
}

# Função para configuração completa
full_setup() {
    print_status "INFO" "Iniciando configuração completa..."
    
    check_root
    start_essential_services
    apply_basic_firewall
    save_configurations
    test_configuration
    show_next_steps
    
    print_status "SUCCESS" "Configuração rápida concluída!"
}

# Função para mostrar ajuda
show_help() {
    echo "Uso: $0 [opção]"
    echo ""
    echo "Opções:"
    echo "  setup     - Configuração completa (padrão)"
    echo "  services  - Iniciar apenas serviços essenciais"
    echo "  firewall  - Aplicar apenas configuração de firewall"
    echo "  test      - Testar configuração atual"
    echo "  help      - Mostrar esta ajuda"
    echo ""
    echo "Exemplo:"
    echo "  $0 setup    # Configuração completa"
    echo "  $0 firewall # Apenas firewall"
}

# Função principal
main() {
    case "${1:-setup}" in
        "setup")
            full_setup
            ;;
        "services")
            check_root
            start_essential_services
            ;;
        "firewall")
            check_root
            apply_basic_firewall
            save_configurations
            ;;
        "test")
            test_configuration
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
