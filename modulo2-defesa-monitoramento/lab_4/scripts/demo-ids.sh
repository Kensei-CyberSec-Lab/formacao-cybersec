#!/bin/bash

# Script de demonstração do IDS Suricata
# Captura tráfego e analisa com regras customizadas

echo "🚨 DEMONSTRAÇÃO IDS/IPS SURICATA"
echo "=================================="

# Verificar se os containers estão rodando
echo "📋 Verificando status dos containers..."
if ! docker ps | grep -q suricata_lab; then
    echo "❌ Container Suricata não está rodando"
    exit 1
fi

if ! docker ps | grep -q kali_lab; then
    echo "❌ Container Kali não está rodando"
    exit 1
fi

if ! docker ps | grep -q web_victim; then
    echo "❌ Container Web Victim não está rodando"
    exit 1
fi

echo "✅ Todos os containers estão rodando"

# Criar diretório de capturas se não existir
mkdir -p ./suricata/captures

# 1. Capturar tráfego de rede
echo ""
echo "📡 Etapa 1: Capturando tráfego de rede..."
echo "Executando nmap scan e HTTP requests..."

# Capturar tráfego com tcpdump no container Suricata
docker exec suricata_lab timeout 10 tcpdump -i eth0 -w /var/log/suricata/captures/test_traffic.pcap &
TCPDUMP_PID=$!

# Aguardar tcpdump iniciar
sleep 2

# Executar ataques/testes
echo "   - Executando nmap scan..."
docker exec kali_lab nmap -sS -p 80 192.168.25.20 > /dev/null 2>&1

echo "   - Executando HTTP requests..."
docker exec kali_lab curl -s http://192.168.25.20/admin > /dev/null 2>&1
docker exec kali_lab curl -s "http://192.168.25.20/search?q=<script>alert('xss')</script>" > /dev/null 2>&1
docker exec kali_lab curl -s -X POST http://192.168.25.20/login -d "user=admin&password=123456" > /dev/null 2>&1

# Aguardar tcpdump terminar
wait $TCPDUMP_PID

echo "✅ Captura de tráfego concluída"

# 2. Analisar PCAP com Suricata
echo ""
echo "🔍 Etapa 2: Analisando tráfego com Suricata..."

# Verificar se o arquivo PCAP foi criado
if [ ! -f "./suricata/captures/test_traffic.pcap" ]; then
    echo "❌ Arquivo PCAP não foi criado"
    exit 1
fi

echo "   - Arquivo PCAP criado: ./suricata/captures/test_traffic.pcap"
echo "   - Tamanho: $(du -h ./suricata/captures/test_traffic.pcap | cut -f1)"

# Analisar PCAP com Suricata
echo "   - Executando análise Suricata..."
docker exec suricata_lab suricata --pcap /var/log/suricata/captures/test_traffic.pcap -c /etc/suricata/suricata.yaml

# Aguardar processamento
sleep 5

# 3. Verificar resultados
echo ""
echo "📊 Etapa 3: Verificando resultados..."

# Verificar se há alertas
echo "   - Verificando alertas gerados..."

# Contar alertas por tipo
ADMIN_ALERTS=$(grep -c "Acesso à área administrativa" ./suricata/logs/eve.json 2>/dev/null || echo "0")
XSS_ALERTS=$(grep -c "Possível XSS detectado" ./suricata/logs/eve.json 2>/dev/null || echo "0")
SQLI_ALERTS=$(grep -c "Possível SQL Injection detectado" ./suricata/logs/eve.json 2>/dev/null || echo "0")
PASSWORD_ALERTS=$(grep -c "Parâmetro password detectado" ./suricata/logs/eve.json 2>/dev/null || echo "0")
SCAN_ALERTS=$(grep -c "Scan de portas detectado" ./suricata/logs/eve.json 2>/dev/null || echo "0")
TCP_ALERTS=$(grep -c "TCP traffic detected" ./suricata/logs/eve.json 2>/dev/null || echo "0")

echo "   📈 Resultados:"
echo "      - Admin access: $ADMIN_ALERTS alerta(s)"
echo "      - XSS: $XSS_ALERTS alerta(s)"
echo "      - SQL Injection: $SQLI_ALERTS alerta(s)"
echo "      - Password param: $PASSWORD_ALERTS alerta(s)"
echo "      - Port scan: $SCAN_ALERTS alerta(s)"
echo "      - TCP traffic: $TCP_ALERTS alerta(s)"

# Verificar total de alertas
TOTAL_ALERTS=$(grep -c '"event_type":"alert"' ./suricata/logs/eve.json 2>/dev/null || echo "0")
echo "      - Total de alertas: $TOTAL_ALERTS"

# 4. Mostrar exemplos de alertas
echo ""
echo "🔍 Etapa 4: Exemplos de alertas gerados..."

if [ "$TOTAL_ALERTS" -gt 0 ]; then
    echo "   - Últimos alertas:"
    grep '"event_type":"alert"' ./suricata/logs/eve.json | tail -3 | while read -r alert; do
        echo "     $alert" | jq -r '.msg' 2>/dev/null || echo "     $alert"
    done
else
    echo "   - Nenhum alerta foi gerado"
    echo "   - Verificando logs para debug..."
    echo "   - Últimas entradas em eve.json:"
    tail -3 ./suricata/logs/eve.json
fi

echo ""
echo "✅ Demonstração concluída!"
echo ""
echo "📁 Arquivos gerados:"
echo "   - PCAP: ./suricata/captures/test_traffic.pcap"
echo "   - Logs: ./suricata/logs/eve.json"
echo "   - Alertas: ./suricata/logs/fast.log"
