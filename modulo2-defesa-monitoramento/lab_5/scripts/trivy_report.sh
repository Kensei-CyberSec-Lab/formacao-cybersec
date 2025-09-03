#!/bin/bash

# Script para gerar relatórios de segurança com Trivy
# Lab 5 - Container Security

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para exibir help
show_help() {
    echo -e "${BLUE}🛡️  Gerador de Relatórios Trivy - Lab 5${NC}"
    echo ""
    echo "Uso: $0 [OPÇÕES] <imagem>"
    echo ""
    echo "Opções:"
    echo "  -f, --format FORMAT    Formato do relatório (html, json, csv, all) [padrão: html]"
    echo "  -o, --output DIR       Diretório de saída [padrão: /root/reports]"
    echo "  -s, --severity LEVELS  Níveis de severidade [padrão: LOW,MEDIUM,HIGH,CRITICAL]"
    echo "  -q, --quick           Scan rápido (apenas HIGH,CRITICAL)"
    echo "  -h, --help            Exibe esta ajuda"
    echo ""
    echo "Exemplos:"
    echo "  $0 bkimminich/juice-shop"
    echo "  $0 --format all nginx:latest"
    echo "  $0 --quick --format html ubuntu:20.04"
    echo ""
}

# Valores padrão
IMAGE=""
FORMAT="html"
OUTPUT_DIR="/root/reports"
SEVERITY="LOW,MEDIUM,HIGH,CRITICAL"
QUICK_MODE=false

# Parse dos argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--format)
            FORMAT="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -s|--severity)
            SEVERITY="$2"
            shift 2
            ;;
        -q|--quick)
            QUICK_MODE=true
            SEVERITY="HIGH,CRITICAL"
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            echo -e "${RED}❌ Opção desconhecida: $1${NC}"
            show_help
            exit 1
            ;;
        *)
            IMAGE="$1"
            shift
            ;;
    esac
done

# Verificar se a imagem foi fornecida
if [[ -z "$IMAGE" ]]; then
    echo -e "${RED}❌ Erro: Nome da imagem é obrigatório${NC}"
    show_help
    exit 1
fi

# Criar diretório de saída
mkdir -p "$OUTPUT_DIR"

# Timestamp para arquivos
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo -e "${BLUE}🔍 Iniciando scan de segurança...${NC}"
echo -e "📦 Imagem: ${YELLOW}$IMAGE${NC}"
echo -e "📊 Severidade: ${YELLOW}$SEVERITY${NC}"
echo -e "📁 Saída: ${YELLOW}$OUTPUT_DIR${NC}"
echo ""

# Função para gerar relatório JSON
generate_json_report() {
    echo -e "${BLUE}📄 Gerando relatório JSON...${NC}"
    local json_file="$OUTPUT_DIR/trivy_report_${TIMESTAMP}.json"
    
    trivy image \
        --format json \
        --severity "$SEVERITY" \
        --output "$json_file" \
        "$IMAGE"
    
    echo -e "${GREEN}✅ Relatório JSON salvo: $json_file${NC}"
}

# Função para gerar relatório HTML simples
generate_html_simple() {
    echo -e "${BLUE}🌐 Gerando relatório HTML...${NC}"
    local html_file="$OUTPUT_DIR/trivy_report_${TIMESTAMP}.html"
    
    # Gerar dados JSON primeiro
    local temp_json="/tmp/trivy_temp_${TIMESTAMP}.json"
    trivy image \
        --format json \
        --severity "$SEVERITY" \
        "$IMAGE" > "$temp_json"
    
    # Gerar HTML usando template simples
    cat > "$html_file" << EOF
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Relatório Trivy - $IMAGE</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { text-align: center; border-bottom: 2px solid #007acc; padding-bottom: 15px; margin-bottom: 20px; }
        .stats { display: flex; justify-content: space-around; margin: 20px 0; }
        .stat-card { text-align: center; padding: 15px; border-radius: 8px; color: white; min-width: 120px; }
        .critical { background: #d32f2f; }
        .high { background: #f57c00; }
        .medium { background: #fbc02d; color: #333; }
        .low { background: #388e3c; }
        .vuln-table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        .vuln-table th, .vuln-table td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
        .vuln-table th { background: #f8f9fa; }
        .severity-badge { padding: 3px 8px; border-radius: 3px; color: white; font-size: 0.8em; }
        .badge-critical { background: #d32f2f; }
        .badge-high { background: #f57c00; }
        .badge-medium { background: #fbc02d; color: #333; }
        .badge-low { background: #388e3c; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🛡️ Relatório de Segurança Trivy</h1>
            <p><strong>Imagem:</strong> $IMAGE</p>
            <p><strong>Data:</strong> $(date '+%d/%m/%Y %H:%M:%S')</p>
        </div>
        
        <div class="stats">
EOF

    # Extrair estatísticas do JSON
    if command -v jq >/dev/null 2>&1; then
        local critical=$(jq -r '[.Results[]?.Vulnerabilities[]? | select(.Severity == "CRITICAL")] | length' "$temp_json" 2>/dev/null || echo "0")
        local high=$(jq -r '[.Results[]?.Vulnerabilities[]? | select(.Severity == "HIGH")] | length' "$temp_json" 2>/dev/null || echo "0")
        local medium=$(jq -r '[.Results[]?.Vulnerabilities[]? | select(.Severity == "MEDIUM")] | length' "$temp_json" 2>/dev/null || echo "0")
        local low=$(jq -r '[.Results[]?.Vulnerabilities[]? | select(.Severity == "LOW")] | length' "$temp_json" 2>/dev/null || echo "0")
        
        cat >> "$html_file" << EOF
            <div class="stat-card critical">
                <h3>CRÍTICAS</h3>
                <div style="font-size: 2em; font-weight: bold;">$critical</div>
            </div>
            <div class="stat-card high">
                <h3>ALTAS</h3>
                <div style="font-size: 2em; font-weight: bold;">$high</div>
            </div>
            <div class="stat-card medium">
                <h3>MÉDIAS</h3>
                <div style="font-size: 2em; font-weight: bold;">$medium</div>
            </div>
            <div class="stat-card low">
                <h3>BAIXAS</h3>
                <div style="font-size: 2em; font-weight: bold;">$low</div>
            </div>
EOF
    fi

    cat >> "$html_file" << EOF
        </div>
        
        <h2>📋 Vulnerabilidades Encontradas</h2>
        <table class="vuln-table">
            <thead>
                <tr>
                    <th>CVE ID</th>
                    <th>Severidade</th>
                    <th>Pacote</th>
                    <th>Versão Instalada</th>
                    <th>Versão Corrigida</th>
                    <th>Título</th>
                </tr>
            </thead>
            <tbody>
EOF

    # Adicionar vulnerabilidades à tabela (usando jq se disponível)
    if command -v jq >/dev/null 2>&1; then
        jq -r '.Results[]?.Vulnerabilities[]? | 
            "<tr>
                <td><strong>" + (.VulnerabilityID // "N/A") + "</strong></td>
                <td><span class=\"severity-badge badge-" + (.Severity | ascii_downcase) + "\">" + (.Severity // "N/A") + "</span></td>
                <td>" + (.PkgName // "N/A") + "</td>
                <td>" + (.InstalledVersion // "N/A") + "</td>
                <td>" + (.FixedVersion // "N/A") + "</td>
                <td>" + (.Title // "N/A") + "</td>
            </tr>"' "$temp_json" 2>/dev/null >> "$html_file" || echo "<tr><td colspan='6'>Erro ao processar vulnerabilidades</td></tr>" >> "$html_file"
    fi

    cat >> "$html_file" << EOF
            </tbody>
        </table>
        
        <div style="text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; color: #666;">
            <p>Relatório gerado por Trivy Scanner | Lab 5 - Container Security</p>
        </div>
    </div>
</body>
</html>
EOF

    rm -f "$temp_json"
    echo -e "${GREEN}✅ Relatório HTML salvo: $html_file${NC}"
}

# Função para gerar relatório CSV
generate_csv_report() {
    echo -e "${BLUE}📊 Gerando relatório CSV...${NC}"
    local csv_file="$OUTPUT_DIR/trivy_report_${TIMESTAMP}.csv"
    
    # Gerar JSON temporário
    local temp_json="/tmp/trivy_temp_csv_${TIMESTAMP}.json"
    trivy image \
        --format json \
        --severity "$SEVERITY" \
        "$IMAGE" > "$temp_json"
    
    # Cabeçalho CSV
    echo "CVE_ID,Severidade,Pacote,Versao_Instalada,Versao_Corrigida,Titulo,Score_CVSS" > "$csv_file"
    
    # Extrair dados usando jq
    if command -v jq >/dev/null 2>&1; then
        jq -r '.Results[]?.Vulnerabilities[]? | 
            [.VulnerabilityID // "N/A", 
             .Severity // "N/A", 
             .PkgName // "N/A", 
             .InstalledVersion // "N/A", 
             .FixedVersion // "N/A", 
             (.Title // "N/A" | gsub(","; ";")), 
             (.CVSS.nvd.V3Score // "N/A")] | 
            @csv' "$temp_json" 2>/dev/null >> "$csv_file" || echo "Erro ao processar dados" >> "$csv_file"
    fi
    
    rm -f "$temp_json"
    echo -e "${GREEN}✅ Relatório CSV salvo: $csv_file${NC}"
}

# Função para gerar relatório de texto
generate_text_report() {
    echo -e "${BLUE}📝 Gerando relatório de texto...${NC}"
    local text_file="$OUTPUT_DIR/trivy_report_${TIMESTAMP}.txt"
    
    trivy image \
        --format table \
        --severity "$SEVERITY" \
        "$IMAGE" > "$text_file"
    
    echo -e "${GREEN}✅ Relatório TXT salvo: $text_file${NC}"
}

# Gerar relatórios baseado no formato escolhido
case $FORMAT in
    json)
        generate_json_report
        ;;
    html)
        generate_html_simple
        ;;
    csv)
        generate_csv_report
        ;;
    txt|text)
        generate_text_report
        ;;
    all)
        generate_json_report
        generate_html_simple
        generate_csv_report
        generate_text_report
        ;;
    *)
        echo -e "${RED}❌ Formato inválido: $FORMAT${NC}"
        echo "Formatos disponíveis: json, html, csv, txt, all"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}🎉 Relatórios gerados com sucesso!${NC}"
echo -e "📁 Localização: ${YELLOW}$OUTPUT_DIR${NC}"
echo -e "📋 Para visualizar arquivos: ${BLUE}ls -la $OUTPUT_DIR${NC}"

if [[ "$FORMAT" == "html" || "$FORMAT" == "all" ]]; then
    echo ""
    echo -e "${BLUE}💡 Dica: Para visualizar o relatório HTML:${NC}"
    echo -e "   No container: python3 -m http.server 8080 --directory $OUTPUT_DIR"
    echo -e "   No host: http://localhost:8080"
fi
