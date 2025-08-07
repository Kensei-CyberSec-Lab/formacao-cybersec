#!/bin/bash

# =============================================================================
# Script de Teste: Validação de Configurações de Firewall
# Laboratório de Defesa e Monitoramento - Módulo 2
# =============================================================================

echo "🧪 Teste de Firewall - Validação de Configurações"
echo "=================================================="

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
        "PASS")
            echo -e "${GREEN}✅ PASS${NC}: $message"
            ;;
        "FAIL")
            echo -e "${RED}❌ FAIL${NC}: $message"
            ;;
        "WARN")
            echo -e "${YELLOW}⚠️  WARN${NC}: $message"
            ;;
        "INFO")
            echo -e "${BLUE}ℹ️  INFO${NC}: $message"
            ;;
    esac
}

# Função para testar conectividade básica
test_basic_connectivity() {
    echo ""
    echo "🔗 Teste 1: Conectividade Básica"
    echo "================================"
    
    # Teste ping do Kali para Ubuntu
    print_status "INFO" "Testando ping do Kali (192.168.100.11) para Ubuntu (192.168.100.10)..."
    if docker exec kali_lab_19 ping -c 3 192.168.100.10 > /dev/null 2>&1; then
        print_status "PASS" "Ping do Kali para Ubuntu: FUNCIONANDO"
    else
        print_status "FAIL" "Ping do Kali para Ubuntu: FALHOU"
    fi
    
    # Teste ping do Ubuntu para Kali
    print_status "INFO" "Testando ping do Ubuntu (192.168.100.10) para Kali (192.168.100.11)..."
    if docker exec ubuntu_lab_19 ping -c 3 192.168.100.11 > /dev/null 2>&1; then
        print_status "PASS" "Ping do Ubuntu para Kali: FUNCIONANDO"
    else
        print_status "FAIL" "Ping do Ubuntu para Kali: FALHOU"
    fi
}

# Função para testar SSH
test_ssh_access() {
    echo ""
    echo "🔐 Teste 2: Acesso SSH"
    echo "======================"
    
    # Teste SSH do Kali para Ubuntu (deve ser bloqueado se firewall estiver ativo)
    print_status "INFO" "Testando SSH do Kali para Ubuntu..."
    
    # Tentar SSH e capturar resultado
    local ssh_result=$(docker exec kali_lab_19 timeout 5 ssh -o ConnectTimeout=3 -o StrictHostKeyChecking=no root@192.168.100.10 "echo 'SSH_SUCCESS'" 2>&1)
    
    if echo "$ssh_result" | grep -q "SSH_SUCCESS"; then
        print_status "WARN" "SSH do Kali para Ubuntu: FUNCIONANDO (verifique se o firewall está ativo)"
    elif echo "$ssh_result" | grep -q "Connection refused\|Connection timed out\|No route to host"; then
        print_status "PASS" "SSH do Kali para Ubuntu: BLOQUEADO (firewall funcionando)"
    else
        print_status "FAIL" "SSH do Kali para Ubuntu: ERRO inesperado - $ssh_result"
    fi
}

# Função para verificar regras de firewall
check_firewall_rules() {
    echo ""
    echo "🛡️ Teste 3: Verificação de Regras de Firewall"
    echo "=============================================="
    
    # Verificar se há regras configuradas
    local rules_count=$(docker exec ubuntu_lab_19 iptables -L INPUT | wc -l)
    
    if [ "$rules_count" -gt 3 ]; then
        print_status "PASS" "Regras de firewall configuradas ($((rules_count-3)) regras customizadas)"
        
        # Mostrar regras principais
        echo ""
        print_status "INFO" "Regras de INPUT configuradas:"
        docker exec ubuntu_lab_19 iptables -L INPUT --line-numbers
    else
        print_status "WARN" "Poucas regras de firewall encontradas (apenas políticas padrão)"
    fi
    
    # Verificar política padrão
    local default_policy=$(docker exec ubuntu_lab_19 iptables -L INPUT | head -1 | awk '{print $4}')
    if [ "$default_policy" = "DROP" ]; then
        print_status "PASS" "Política padrão INPUT: DROP (seguro)"
    else
        print_status "WARN" "Política padrão INPUT: $default_policy (considere DROP para maior segurança)"
    fi
}

# Função para testar portas específicas
test_specific_ports() {
    echo ""
    echo "🔍 Teste 4: Verificação de Portas"
    echo "================================="
    
    # Verificar porta 22 (SSH)
    print_status "INFO" "Verificando porta 22 (SSH) no Ubuntu..."
    if docker exec ubuntu_lab_19 netstat -tuln | grep -q ":22 "; then
        print_status "PASS" "Porta 22 (SSH): ABERTA"
    else
        print_status "FAIL" "Porta 22 (SSH): FECHADA"
    fi
    
    # Verificar porta 80 (HTTP)
    print_status "INFO" "Verificando porta 80 (HTTP) no Ubuntu..."
    if docker exec ubuntu_lab_19 netstat -tuln | grep -q ":80 "; then
        print_status "PASS" "Porta 80 (HTTP): ABERTA"
    else
        print_status "INFO" "Porta 80 (HTTP): FECHADA (normal se não houver servidor web)"
    fi
}

# Função para verificar logs
check_firewall_logs() {
    echo ""
    echo "📝 Teste 5: Verificação de Logs"
    echo "==============================="
    
    # Verificar se há logs de firewall
    local log_count=$(docker exec ubuntu_lab_19 grep -c "BLOCKED_KALI" /var/log/syslog 2>/dev/null || echo "0")
    
    if [ "$log_count" -gt 0 ]; then
        print_status "PASS" "Logs de firewall encontrados ($log_count entradas)"
        
        # Mostrar últimos logs
        echo ""
        print_status "INFO" "Últimos logs de firewall:"
        docker exec ubuntu_lab_19 grep "BLOCKED_KALI" /var/log/syslog | tail -3
    else
        print_status "INFO" "Nenhum log de firewall encontrado (normal se não houve tentativas de acesso)"
    fi
}

# Função para teste de nmap
test_nmap_scan() {
    echo ""
    echo "🔍 Teste 6: Scan de Portas com Nmap"
    echo "==================================="
    
    print_status "INFO" "Executando scan de portas do Kali para Ubuntu..."
    
    # Executar nmap e capturar resultado
    local nmap_output=$(docker exec kali_lab_19 nmap -sS -p 22,80,443 192.168.100.10 2>/dev/null)
    
    echo "$nmap_output"
    
    # Verificar se SSH está sendo detectado
    if echo "$nmap_output" | grep -q "22/tcp.*open"; then
        print_status "PASS" "Porta 22 detectada como aberta"
    else
        print_status "WARN" "Porta 22 não detectada como aberta"
    fi
}

# Função para gerar relatório
generate_report() {
    echo ""
    echo "📊 Relatório de Teste"
    echo "====================="
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "Data/Hora: $timestamp"
    echo "Ambiente: Laboratório de Firewall"
    echo "Status: Teste concluído"
    
    echo ""
    echo "🎯 Recomendações:"
    echo "1. Verifique se as regras de firewall estão aplicadas corretamente"
    echo "2. Teste a conectividade SSH após aplicar as regras"
    echo "3. Monitore os logs para detectar tentativas de acesso"
    echo "4. Valide que o tráfego legítimo (HTTP) continua funcionando"
}

# Função para mostrar ajuda
show_help() {
    echo "Uso: $0 [opção]"
    echo ""
    echo "Opções:"
    echo "  all       - Executar todos os testes (padrão)"
    echo "  basic     - Teste de conectividade básica"
    echo "  ssh       - Teste de acesso SSH"
    echo "  rules     - Verificação de regras de firewall"
    echo "  ports     - Teste de portas específicas"
    echo "  logs      - Verificação de logs"
    echo "  nmap      - Scan de portas com nmap"
    echo "  help      - Mostrar esta ajuda"
    echo ""
    echo "Exemplo:"
    echo "  $0 all     # Executar todos os testes"
    echo "  $0 ssh     # Testar apenas SSH"
}

# Função principal
main() {
    case "${1:-all}" in
        "all")
            test_basic_connectivity
            test_ssh_access
            check_firewall_rules
            test_specific_ports
            check_firewall_logs
            test_nmap_scan
            generate_report
            ;;
        "basic")
            test_basic_connectivity
            ;;
        "ssh")
            test_ssh_access
            ;;
        "rules")
            check_firewall_rules
            ;;
        "ports")
            test_specific_ports
            ;;
        "logs")
            check_firewall_logs
            ;;
        "nmap")
            test_nmap_scan
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
