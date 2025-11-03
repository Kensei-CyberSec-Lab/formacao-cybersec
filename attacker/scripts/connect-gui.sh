#!/bin/bash

# Conectar ao Container Kali GUI
# Uso: ./connect-gui.sh

echo "🐉 Informações de Acesso ao Container Kali GUI"
echo "==============================================="

# Verificar se o container está executando
if ! docker ps | grep -q "kali-gui"; then
    echo "❌ Container Kali GUI não está executando!"
    echo "Inicie com: docker-compose up -d kali-gui"
    exit 1
fi

echo "✅ Container está executando!"
echo "==============================================="
echo "🖥️  Opções de Acesso GUI:"
echo "   1. Cliente VNC: localhost:5901"
echo "   2. Navegador Web: http://localhost:6080"
echo "   3. Senha: kalilinux"
echo ""
echo "💻 Acesso Terminal:"
echo "   docker exec -it kali-gui /bin/bash"
echo "==============================================="

# Perguntar o que o usuário quer fazer
echo ""
echo "O que você gostaria de fazer?"
echo "1) Abrir VNC web no navegador"
echo "2) Conectar via terminal"
echo "3) Apenas mostrar informações de conexão"
read -p "Escolha uma opção (1-3): " choice

case $choice in
    1)
        echo "Abrindo VNC web no navegador..."
        if command -v open >/dev/null 2>&1; then
            # macOS
            open http://localhost:6080
        elif command -v xdg-open >/dev/null 2>&1; then
            # Linux
            xdg-open http://localhost:6080
        else
            echo "Por favor abra http://localhost:6080 no seu navegador"
        fi
        ;;
    2)
        echo "Conectando ao terminal do container..."
        docker exec -it kali-gui /bin/bash
        ;;
    3)
        echo "Informações de conexão exibidas acima."
        ;;
    *)
        echo "Opção inválida. Informações de conexão exibidas acima."
        ;;
esac