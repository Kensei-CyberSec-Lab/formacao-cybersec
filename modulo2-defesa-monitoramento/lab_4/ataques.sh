#!/usr/bin/env bash
set -e

echo "🚨 [LAB IDS/IPS] Script de Testes Automáticos"
echo "================================================"

echo ""
echo "[*] Teste 1: Pingando o Suricata (gera alerta ICMP)..."
ping -c 2 192.168.25.10 || true

echo ""
echo "[*] Teste 2: Varredura rápida com Nmap (gera alerta SYN scan)..."
nmap -sS -Pn -p 1-1000 192.168.25.10 || true

echo ""
echo "[*] Teste 3: Acesso HTTP benigno ao web_victim..."
curl -s -o /dev/null http://192.168.25.20/

echo ""
echo "[*] Teste 4: Acesso à área administrativa (deve disparar regra 1000001)..."
curl -s -o /dev/null http://192.168.25.20/admin

echo ""
echo "[*] Teste 5: Tentativa de XSS (deve disparar regra 1000002)..."
curl -s "http://192.168.25.20/search?q=<script>alert('xss')</script>" -o /dev/null

echo ""
echo "[*] Teste 6: SQL Injection (deve disparar regra 1000003)..."
curl -s "http://192.168.25.20/search?q=' OR '1'='1" -o /dev/null

echo ""
echo "[*] Teste 7: POST com password (deve disparar regra 1000004)..."
curl -s -X POST http://192.168.25.20/login -d "user=admin&password=123456" -o /dev/null

echo ""
echo "[*] Teste 8: User-Agent malicioso (deve disparar regra 1000005)..."
curl -s -H "User-Agent: sqlmap/1.0" http://192.168.25.20/ -o /dev/null

echo ""
echo "✅ Testes finalizados!"
echo ""
echo "🔍 Para ver os alertas em tempo real:"
echo "   docker logs -f suricata_lab"
echo ""
echo "📊 Para ver logs detalhados:"
echo "   tail -f ./suricata/logs/eve.json | grep 'alert'"
echo ""
echo "🌐 Para acessar Scirius UI:"
echo "   http://localhost:8080"
echo ""
echo "📈 Para acessar EveBox:"
echo "   http://localhost:5636"