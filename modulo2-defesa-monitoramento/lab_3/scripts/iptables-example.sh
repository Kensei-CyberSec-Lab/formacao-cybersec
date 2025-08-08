#!/bin/bash

# =============================================================================
# Script de Exemplo: Configuração de Firewall com iptables
# Laboratório de Defesa e Monitoramento - Módulo 2
# =============================================================================

echo "🔥 Configurando Firewall - Exemplo de Regras"
echo "=============================================="

# Função para limpar regras existentes
clear_rules() {
    echo "🧹 Limpando regras existentes..."
    iptables -F
    iptables -X
    iptables -t nat -F
    iptables -t nat -X
    iptables -t mangle -F
    iptables -t mangle -X
}

# Função para aplicar política padrão
set_default_policy() {
    echo "🛡️ Definindo política padrão: DROP para INPUT e FORWARD..."
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT
}

# Função para permitir conexões estabelecidas
allow_established() {
    echo "✅ Permitindo conexões já estabelecidas..."
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
}

# Função para permitir tráfego local
allow_localhost() {
    echo "🏠 Permitindo tráfego local (loopback)..."
    iptables -A INPUT -i lo -j ACCEPT
}

# Função para permitir HTTP
allow_http() {
    echo "🌐 Permitindo tráfego HTTP (porta 80)..."
    iptables -A INPUT -p tcp --dport 80 -j ACCEPT
}

# Função para adicionar logging
add_logging() {
    echo "📝 Adicionando logging para auditoria..."
    iptables -A INPUT -s 192.168.100.11 -j LOG --log-prefix "BLOCKED_KALI: "
}

# Função para bloquear SSH do Kali
block_kali_ssh() {
    echo "🚫 Bloqueando SSH do Kali Linux (192.168.100.11)..."
    iptables -A INPUT -s 192.168.100.11 -p tcp --dport 22 -j DROP
}

# Função para permitir SSH de outros IPs
allow_ssh_others() {
    echo "🔓 Permitindo SSH de outros IPs..."
    iptables -A INPUT -p tcp --dport 22 -j ACCEPT
}

# Função para mostrar regras
show_rules() {
    echo ""
    echo "📋 Regras configuradas:"
    echo "========================"
    iptables -L -v -n
}

# Função para mostrar estatísticas
show_stats() {
    echo ""
    echo "📊 Estatísticas das regras:"
    echo "============================"
    iptables -L -v
}

# Função para salvar regras
save_rules() {
    echo "💾 Salvando regras..."
    mkdir -p /etc/iptables
    iptables-save > /etc/iptables/rules.v4
    echo "✅ Regras salvas em /etc/iptables/rules.v4"
}

# Função para testar conectividade
test_connectivity() {
    echo ""
    echo "🧪 Testando conectividade..."
    echo "============================"
    
    echo "1. Testando ping para o Kali..."
    ping -c 3 192.168.100.11
    
    echo ""
    echo "2. Verificando portas abertas..."
    netstat -tuln | grep -E ":(22|80)"
    
    echo ""
    echo "3. Verificando logs de bloqueio..."
    tail -n 5 /var/log/syslog | grep BLOCKED_KALI || echo "Nenhum log de bloqueio encontrado ainda."
}

# Função para mostrar ajuda
show_help() {
    echo "Uso: $0 [opção]"
    echo ""
    echo "Opções:"
    echo "  apply     - Aplicar todas as regras de exemplo"
    echo "  clear     - Limpar todas as regras"
    echo "  show      - Mostrar regras atuais"
    echo "  stats     - Mostrar estatísticas"
    echo "  save      - Salvar regras"
    echo "  test      - Testar conectividade"
    echo "  help      - Mostrar esta ajuda"
    echo ""
    echo "Exemplo:"
    echo "  $0 apply    # Aplicar regras de exemplo"
    echo "  $0 show     # Ver regras configuradas"
}

# Função principal para aplicar todas as regras
apply_example_rules() {
    echo "🚀 Aplicando regras de exemplo..."
    echo "=================================="
    
    clear_rules
    set_default_policy
    allow_established
    allow_localhost
    allow_http
    add_logging
    block_kali_ssh
    allow_ssh_others
    
    echo ""
    echo "✅ Regras de exemplo aplicadas com sucesso!"
    echo ""
    echo "📋 Resumo das regras aplicadas:"
    echo "1. Política padrão: DROP para INPUT/FORWARD"
    echo "2. Conexões estabelecidas: PERMITIDAS"
    echo "3. Tráfego local: PERMITIDO"
    echo "4. HTTP (porta 80): PERMITIDO"
    echo "5. SSH do Kali (192.168.100.11): BLOQUEADO"
    echo "6. SSH de outros IPs: PERMITIDO"
    echo "7. Logging: ATIVADO para tentativas do Kali"
    
    show_rules
    save_rules
}

# Verificar se está rodando como root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Este script deve ser executado como root"
    echo "Use: sudo $0 [opção]"
    exit 1
fi

# Processar argumentos da linha de comando
case "${1:-apply}" in
    "apply")
        apply_example_rules
        ;;
    "clear")
        clear_rules
        echo "✅ Regras limpas!"
        ;;
    "show")
        show_rules
        ;;
    "stats")
        show_stats
        ;;
    "save")
        save_rules
        ;;
    "test")
        test_connectivity
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

echo ""
echo "🎯 Dica: Use '$0 test' para testar a conectividade após aplicar as regras!"
