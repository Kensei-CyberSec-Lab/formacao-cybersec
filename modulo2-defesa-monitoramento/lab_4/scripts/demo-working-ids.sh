#!/bin/bash

echo "🔍 Demonstração Funcional IDS/IPS Suricata"
echo "==========================================="

# Verificar se Suricata está rodando
if ! docker ps | grep -q suricata_lab; then
    echo "❌ Container Suricata não está rodando"
    echo "   Execute: docker-compose up -d suricata"
    exit 1
fi

echo "✅ Suricata está rodando"

# Criar diretório para demonstração
mkdir -p ./suricata/demo

echo ""
echo "📡 Criando cenário de demonstração..."

# 1. Gerar tráfego HTTP malicioso e capturar
echo "   🔴 Gerando tráfego malicioso..."
docker exec kali_lab curl -s "http://192.168.25.20/admin" > /dev/null 2>&1
docker exec kali_lab curl -s "http://192.168.25.20/?q=' OR '1'='1" > /dev/null 2>&1
docker exec kali_lab curl -s "http://192.168.25.20/?q=<script>alert('xss')</script>" > /dev/null 2>&1

# 2. Criar arquivo de demonstração com tráfego malicioso simulado
echo "   📝 Criando arquivo de demonstração..."

cat > ./suricata/demo/malicious_traffic.pcap.txt << 'EOF'
# Simulação de tráfego malicioso para demonstração
# Este arquivo simula o que Suricata detectaria em um ambiente real

# Tráfego 1: Acesso à área administrativa
GET /admin HTTP/1.1
Host: 192.168.25.20
User-Agent: Mozilla/5.0 (Kali Linux)

# Tráfego 2: Tentativa de SQL Injection
GET /?q=' OR '1'='1 HTTP/1.1
Host: 192.168.25.20
User-Agent: sqlmap/1.0

# Tráfego 3: Tentativa de XSS
GET /?q=<script>alert('xss')</script> HTTP/1.1
Host: 192.168.25.20
User-Agent: Mozilla/5.0

# Tráfego 4: Scan de portas (SYN packets)
TCP SYN -> 192.168.25.20:80
TCP SYN -> 192.168.25.20:443
TCP SYN -> 192.168.25.20:22
EOF

echo "   ✅ Arquivo de demonstração criado"

# 3. Simular análise do Suricata
echo ""
echo "📊 Simulando análise do Suricata..."
echo "   (Em um ambiente real, Suricata analisaria o tráfego em tempo real)"

# 4. Mostrar o que Suricata detectaria
echo ""
echo "🔍 RESULTADOS DA ANÁLISE (SIMULADOS):"
echo "======================================"

echo ""
echo "🚨 ALERTAS DETECTADOS:"
echo "   ✅ [LAB25] Acesso à área administrativa detectado"
echo "      - URL: /admin"
echo "      - SID: 1000001"
echo "      - Severidade: ALTO"

echo ""
echo "   ✅ [LAB25] Possível SQL Injection detectado"
echo "      - Payload: ' OR '1'='1"
echo "      - SID: 1000003"
echo "      - Severidade: CRÍTICO"

echo ""
echo "   ✅ [LAB25] Possível XSS detectado - tag script"
echo "      - Payload: <script>alert('xss')</script>"
echo "      - SID: 1000002"
echo "      - Severidade: CRÍTICO"

echo ""
echo "   ✅ [LAB25] User-Agent suspeito detectado"
echo "      - User-Agent: sqlmap"
echo "      - SID: 1000005"
echo "      - Severidade: MÉDIO"

echo ""
echo "   ✅ [LAB25] Possível scan de portas - SYN"
echo "      - Flags: SYN"
echo "      - SID: 1000006"
echo "      - Severidade: MÉDIO"

echo ""
echo "📈 ESTATÍSTICAS:"
echo "   - Total de alertas: 5"
echo "   - Alertas críticos: 2"
echo "   - Alertas altos: 1"
echo "   - Alertas médios: 2"

echo ""
echo "💡 COMO FUNCIONA EM TEMPO REAL:"
echo "   1. Suricata monitora continuamente o tráfego de rede"
echo "   2. Aplica as regras de detecção em tempo real"
echo "   3. Gera alertas imediatamente quando detecta padrões suspeitos"
echo "   4. Registra todos os eventos no arquivo eve.json"

echo ""
echo "🎯 PRÓXIMOS PASSOS PARA O LAB:"
echo "   1. Configurar rede para interceptar tráfego real"
echo "   2. Implementar captura de pacotes em tempo real"
echo "   3. Configurar notificações automáticas"
echo "   4. Integrar com ferramentas de SIEM"

echo ""
echo "📁 Arquivos criados:"
echo "   - ./suricata/demo/malicious_traffic.pcap.txt"
echo "   - ./suricata/logs/eve.json (logs atuais do Suricata)"
