#!/bin/bash

# Script para visualizar relatórios gerados
# Lab 5 - Container Security

echo "🛡️ Visualizador de Relatórios - Lab 5"
echo "======================================"
echo ""

# Verificar se existem relatórios
if [ ! -d "reports" ] || [ -z "$(ls -A reports 2>/dev/null)" ]; then
    echo "❌ Nenhum relatório encontrado em ./reports/"
    echo "   Execute primeiro: docker exec -it kali_lab_31 trivy_report.sh bkimminich/juice-shop"
    exit 1
fi

echo "📁 Relatórios disponíveis:"
ls -la reports/
echo ""

# Contar tipos de relatórios
html_count=$(ls reports/*.html 2>/dev/null | wc -l)
json_count=$(ls reports/*.json 2>/dev/null | wc -l) 
csv_count=$(ls reports/*.csv 2>/dev/null | wc -l)
txt_count=$(ls reports/*.txt 2>/dev/null | wc -l)

echo "📊 Resumo:"
echo "   📄 HTML: $html_count arquivo(s)"
echo "   📋 JSON: $json_count arquivo(s)" 
echo "   📈 CSV:  $csv_count arquivo(s)"
echo "   📝 TXT:  $txt_count arquivo(s)"
echo ""

# Opções de visualização
echo "🌐 Para visualizar relatórios HTML:"
echo "   Opção 1: Abrir diretamente no navegador:"
echo "            open reports/*.html"
echo ""
echo "   Opção 2: Servidor web local:"
echo "            python3 -m http.server 8080 --directory reports"
echo "            Acesse: http://localhost:8080"
echo ""

echo "📊 Para analisar dados CSV:"
echo "   Excel/LibreOffice: open reports/*.csv"
echo "   Terminal: cat reports/*.csv | head -10"
echo ""

echo "🔍 Para ver resumo em texto:"
echo "   less reports/*.txt"
echo "   grep -E 'HIGH|CRITICAL' reports/*.txt"
echo ""

# Oferecer iniciar servidor web
echo "🚀 Deseja iniciar servidor web para visualizar relatórios HTML? (y/n)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "🌐 Iniciando servidor web em http://localhost:8080"
    echo "   Pressione Ctrl+C para parar"
    python3 -m http.server 8080 --directory reports
fi
