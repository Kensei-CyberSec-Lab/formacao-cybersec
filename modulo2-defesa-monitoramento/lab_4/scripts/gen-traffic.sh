#!/bin/bash
set -euo pipefail

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🚀 Gerador de Tráfego - Teste de Regras Customizadas"
echo "===================================================="

# Função para aguardar e verificar alertas
wait_and_check() {
    local rule_name="$1"
    local expected_count="$2"
    local search_pattern="$3"
    
    echo -n "   Aguardando processamento... "
    sleep 5
    
    # Verificar se alerta foi gerado
    local actual_count=0
    if [ -f "./suricata/logs/eve.json" ]; then
        actual_count=$(grep -c "$search_pattern" "./suricata/logs/eve.json" 2>/dev/null || echo "0")
    fi
    
    if [ "$actual_count" -eq "$expected_count" ]; then
        echo -e "${GREEN}[OK]${NC}"
        return 0
    else
        echo -e "${RED}[FAIL]${NC}"
        echo "      Esperado: $expected_count, Encontrado: $actual_count"
        return 1
    fi
}

# Função para executar teste
run_test() {
    local test_name="$1"
    local command="$2"
    local rule_name="$3"
    local expected_count="$4"
    local search_pattern="$5"
    
    echo ""
    echo "🔍 Teste: $test_name"
    echo "   Comando: $command"
    
    # Executar comando
    if docker exec kali_lab bash -c "$command" >/dev/null 2>&1; then
        echo "   ✅ Comando executado com sucesso"
        
        # Aguardar e verificar alerta
        if wait_and_check "$rule_name" "$expected_count" "$search_pattern"; then
            echo -e "   ${GREEN}[OK] $rule_name: $expected_count alerta gerado${NC}"
            return 0
        else
            echo -e "   ${RED}[FAIL] $rule_name: alerta não gerado corretamente${NC}"
            return 1
        fi
    else
        echo -e "   ${RED}[FAIL] Comando falhou${NC}"
        return 1
    fi
}

# Verificar se ambiente está rodando
echo "📋 Verificando ambiente..."

if ! docker ps | grep -q "kali_lab"; then
    echo -e "${RED}[ERRO] Container kali_lab não está rodando${NC}"
    echo "   💡 Execute: docker compose --profile suricata-core up -d"
    exit 1
fi

if ! docker ps | grep -q "suricata_lab"; then
    echo -e "${RED}[ERRO] Container suricata_lab não está rodando${NC}"
    echo "   💡 Execute: docker compose --profile suricata-core up -d"
    exit 1
fi

if ! docker ps | grep -q "web_victim"; then
    echo -e "${RED}[ERRO] Container web_victim não está rodando${NC}"
    echo "   💡 Execute: docker compose --profile suricata-core up -d"
    exit 1
fi

echo -e "${GREEN}[OK] Ambiente verificado${NC}"

# Verificar se regras estão carregadas
echo ""
echo "📜 Verificando regras customizadas..."

rules_loaded=$(docker exec suricata_lab suricata --list-rules 2>/dev/null | grep -c "local.rules" || echo "0")

if [ "$rules_loaded" -gt 0 ]; then
    echo -e "${GREEN}[OK] $rules_loaded regra(s) local carregada(s)${NC}"
else
    echo -e "${YELLOW}[WARN] Nenhuma regra local encontrada${NC}"
    echo "   💡 Verifique: ./suricata/rules/local.rules"
fi

# Contador de testes
TOTAL_TESTS=0
PASSED_TESTS=0

echo ""
echo "🎯 Iniciando testes de regras customizadas..."

# Teste 1: ADMIN-PATH (SID 1000001)
TOTAL_TESTS=$((TOTAL_TESTS + 1))
if run_test "Acesso à área administrativa" \
    "curl -s 'http://192.168.25.20/admin' > /dev/null" \
    "ADMIN-PATH" "1" "área administrativa detectado"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
fi

# Teste 2: XSS-QUERY (SID 1000002)
TOTAL_TESTS=$((TOTAL_TESTS + 1))
if run_test "XSS em query string" \
    "curl -s 'http://192.168.25.20/search?q=<script>alert(1)</script>' > /dev/null" \
    "XSS-QUERY" "1" "XSS detectado"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
fi

# Teste 3: SQLI-QUERY (SID 1000003)
TOTAL_TESTS=$((TOTAL_TESTS + 1))
if run_test "SQL Injection em query string" \
    "curl -s 'http://192.168.25.20/login?user=a&password=b%27%20OR%201=1--' > /dev/null" \
    "SQLI-QUERY" "1" "SQL Injection detectado"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
fi

echo ""
echo "📊 Resumo dos Testes"
echo "===================="
echo "Total de testes: $TOTAL_TESTS"
echo "Passou: $PASSED_TESTS"
echo "Falhou: $((TOTAL_TESTS - PASSED_TESTS))"

if [ $PASSED_TESTS -eq $TOTAL_TESTS ]; then
    echo ""
    echo -e "${GREEN}🎉 Todos os gatilhos funcionaram! ✅${NC}"
    echo "   As regras customizadas estão detectando corretamente."
    
    # Mostrar resumo dos alertas
    echo ""
    echo "📋 Resumo dos Alertas Gerados:"
    if [ -f "./suricata/logs/eve.json" ]; then
        echo "   ADMIN-PATH: $(grep -c "área administrativa detectado" "./suricata/logs/eve.json" 2>/dev/null || echo "0")"
        echo "   XSS-QUERY: $(grep -c "XSS detectado" "./suricata/logs/eve.json" 2>/dev/null || echo "0")"
        echo "   SQLI-QUERY: $(grep -c "SQL Injection detectado" "./suricata/logs/eve.json" 2>/dev/null || echo "0")"
    fi
    
    exit 0
else
    echo ""
    echo -e "${YELLOW}⚠️  Alguns testes falharam.${NC}"
    echo "   Verifique as regras e tente novamente."
    echo ""
    echo "💡 Dicas de troubleshooting:"
    echo "   - Verifique se regras estão em ./suricata/rules/local.rules"
    echo "   - Recarregue regras: docker exec suricata_lab suricata --reload-rules"
    echo "   - Verifique logs: docker logs suricata_lab"
    echo "   - Confirme endpoints: docker exec web_victim curl -s http://localhost/admin"
    exit 1
fi
