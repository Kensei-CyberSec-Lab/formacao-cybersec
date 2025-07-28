
#!/bin/bash

FLAG_FILE="$1"
KEY_FILE="private_key.pem"

if [ -z "$FLAG_FILE" ]; then
  echo "❌ Uso: ./verificar_flag.sh flag.txt"
  exit 1
fi

if [ ! -f "$KEY_FILE" ]; then
  echo "❌ Arquivo da chave privada 'private_key.pem' não encontrado."
  exit 2
fi

if [ ! -f "$FLAG_FILE" ]; then
  echo "❌ Arquivo de flag '$FLAG_FILE' não encontrado."
  exit 3
fi

echo "🔐 Verificando a flag..."

openssl rsautl -decrypt -inkey "$KEY_FILE" -in "$FLAG_FILE" 2>/dev/null

if [ $? -ne 0 ]; then
  echo "❌ Falha ao descriptografar a flag. Formato incorreto ou flag inválida."
else
  echo "✅ Flag verificada com sucesso!"
fi
