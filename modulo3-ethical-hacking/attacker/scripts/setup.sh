#!/bin/bash

# Script de Configuração Rápida para Containers Kali Linux
# Este script irá construir e iniciar os containers

set -e

echo "🐉 Configuração do Ambiente de Testes de Penetração Kali Linux"
echo "================================================================"
echo ""
echo "Este script irá:"
echo "1. Construir o container Kali CLI"
echo "2. Construir o container Kali GUI"  
echo "3. Iniciar ambos os containers"
echo "4. Mostrar informações de acesso"
echo ""

# Verificar se o Docker está executando
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker não está executando. Por favor inicie o Docker e tente novamente."
    exit 1
fi

# Verificar se docker-compose está disponível
if ! command -v docker-compose > /dev/null 2>&1; then
    echo "❌ docker-compose não está instalado. Por favor instale e tente novamente."
    exit 1
fi

echo "✅ Docker está executando"
echo ""

# Tornar scripts executáveis
echo "🔧 Configurando scripts..."
chmod +x scripts/connect-cli.sh
chmod +x scripts/connect-gui.sh
chmod +x scripts/setup.sh
echo "✅ Scripts agora são executáveis"
echo ""

read -p "Gostaria de construir os containers agora? Isso pode levar 15-30 minutos. (s/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[SsYy]$ ]]; then
    echo ""
    echo "🔨 Construindo containers... Isso levará algum tempo..."
    echo "Você pode monitorar o progresso em outro terminal com: cd conf && docker-compose logs -f"
    echo ""
    
    # Construir containers
    cd conf && docker-compose build
    
    echo ""
    echo "🚀 Iniciando containers..."
    docker-compose up -d
    cd ..
    
    echo ""
    echo "✅ Configuração concluída!"
    echo ""
    echo "================================================"
    echo "🎯 INFORMAÇÕES DE ACESSO"
    echo "================================================"
    echo ""
    echo "🖥️  Kali CLI (Terminal):"
    echo "   Comando: ./scripts/connect-cli.sh"
    echo "   Ou:      docker exec -it kali-cli /bin/bash"
    echo ""
    echo "🎨 Kali GUI (Desktop):"
    echo "   Cliente VNC: localhost:5901"
    echo "   Web VNC:     http://localhost:6080"
    echo "   Senha:       kalilinux"
    echo "   Comando:     ./scripts/connect-gui.sh"
    echo ""
    echo "📁 Pasta Compartilhada:"
    echo "   Host:       ./shared/"
    echo "   Container:  /shared"
    echo ""
    echo "🛠️  Gerenciamento:"
    echo "   Iniciar todos: make up"
    echo "   Parar todos:   make down"
    echo "   Apenas CLI:    make cli"
    echo "   Apenas GUI:    make gui"
    echo "   Status:        make status"
    echo "   Ajuda:         make help"
    echo ""
    echo "================================================"
    echo ""
    
    # Mostrar status atual
    echo "📊 Status Atual:"
    cd conf && docker-compose ps && cd ..
    
else
    echo ""
    echo "📝 Para construir depois, execute:"
    echo "   cd conf && docker-compose build"
    echo "   cd conf && docker-compose up -d"
    echo ""
    echo "Ou use o Makefile:"
    echo "   make build"
    echo "   make up"
fi

echo ""
echo "🎓 Pronto para desafios CTF e laboratórios de testes de penetração!"
echo ""