#!/bin/bash

echo "🐳 Lab 5 Mod2 – Container Security (Docker Bench & Trivy)"
echo "=========================================================="
echo ""

# Verificar se o Docker está rodando
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker não está rodando. Por favor, inicie o Docker Desktop."
    exit 1
fi

echo "🚀 Iniciando o ambiente de laboratório..."
docker compose up -d --build

echo ""
echo "✅ Ambiente iniciado com sucesso!"
echo ""
echo "📋 Containers disponíveis:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

echo "🔍 Para executar scan básico do Trivy:"
echo "   docker exec -it kali_lab_31 trivy image --severity HIGH,CRITICAL bkimminich/juice-shop"
echo ""
echo "📊 Para gerar relatório HTML profissional:"
echo "   docker exec -it kali_lab_31 trivy_report.sh --format html bkimminich/juice-shop"
echo ""
echo "📈 Para gerar relatórios em todos os formatos:"
echo "   docker exec -it kali_lab_31 trivy_report.sh --format all bkimminich/juice-shop"
echo ""
echo "⚡ Para scan rápido (apenas críticas/altas):"
echo "   docker exec -it kali_lab_31 trivy_report.sh --quick bkimminich/juice-shop"
echo ""
echo "🌐 Acesse o Juice Shop em: http://localhost:3000"
echo "📁 Relatórios salvos em: ./reports/"
echo ""
echo "📚 Para parar o lab: docker compose down"
