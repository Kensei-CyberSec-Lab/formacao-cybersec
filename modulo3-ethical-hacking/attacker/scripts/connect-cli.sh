#!/bin/bash

# Conectar ao Container Kali CLI
# Uso: ./connect-cli.sh

echo "🐉 Conectando ao container Kali CLI..."
echo "========================================"

# Verificar se o container está executando
if ! docker ps | grep -q "kali-cli"; then
    echo "❌ Container Kali CLI não está executando!"
    echo "Inicie com: docker-compose up -d kali-cli"
    exit 1
fi

echo "✅ Container está executando. Conectando..."
echo "========================================"

# Conectar ao container
docker exec -it kali-cli /bin/bash