#!/bin/bash

echo "🔍 Teste IDS/IPS Suricata"
echo "=========================="

# Verificar se Suricata está rodando
if ! docker ps | grep -q suricata_lab; then
    echo "❌ Container Suricata não está rodando"
    echo "   Execute: docker-compose up -d suricata"
    exit 1
fi

echo "✅ Suricata está rodando"

# Criar diretório de capturas se não existir
mkdir -p ./suricata/captures

echo ""
echo "📡 Gerando tráfego de teste..."

# Gerar tráfego HTTP para testar as regras
docker exec kali_lab curl -s "http://192.168.25.20/admin" > /dev/null 2>&1
docker exec kali_lab curl -s "http://192.168.25.20/?q=' OR '1'='1" > /dev/null 2>&1
docker exec kali_lab curl -s "http://192.168.25.20/?q=<script>alert('xss')</script>" > /dev/null 2>&1

echo "✅ Tráfego de teste gerado"

echo ""
echo "📊 Verificando logs do Suricata..."

# Verificar se há logs
if [ -f "./suricata/logs/eve.json" ]; then
    echo "✅ Arquivo de logs encontrado"
    
    # Contar linhas no arquivo
    total_lines=$(wc -l < ./suricata/logs/eve.json)
    echo "📄 Total de entradas no log: $total_lines"
    
    # Verificar se há novos logs (mais de 6 linhas)
    if [ "$total_lines" -gt 6 ]; then
        echo "🆕 Novos logs detectados!"
        
        echo ""
        echo "🔍 Verificando alertas específicos..."
        
        # Verificar alertas de admin
        admin_count=$(grep -c "área administrativa" ./suricata/logs/eve.json 2>/dev/null || echo "0")
        echo "   - Acesso à área administrativa: $admin_count"
        
        # Verificar alertas de SQL Injection
        sqli_count=$(grep -c "SQL Injection" ./suricata/logs/eve.json 2>/dev/null || echo "0")
        echo "   - SQL Injection: $sqli_count"
        
        # Verificar alertas de XSS
        xss_count=$(grep -c "XSS detectado" ./suricata/logs/eve.json 2>/dev/null || echo "0")
        echo "   - XSS: $xss_count"
        
        echo ""
        echo "📄 Últimas entradas do log:"
        tail -3 ./suricata/logs/eve.json | head -3
        
    else
        echo "⚠️  Nenhum novo log detectado"
        echo "   Isso pode indicar que o tráfego não está sendo capturado"
    fi
else
    echo "❌ Arquivo de logs não encontrado"
fi

echo ""
echo "💡 Para testar manualmente:"
echo "   1. Execute: docker exec kali_lab nmap -sS -p 80 192.168.25.20"
echo "   2. Verifique: grep 'scan de portas' ./suricata/logs/eve.json"
echo "   3. Ou execute: ./scripts/demo-ids.sh"
