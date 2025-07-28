#!/bin/bash

echo "[*] Desligando e removendo containers..."
docker-compose down

echo "[*] Removendo volumes antigos..."
docker volume prune -f

echo "[*] Subindo ambiente limpo..."
docker-compose up -d

echo "[*] Ambiente reiniciado com sucesso!"