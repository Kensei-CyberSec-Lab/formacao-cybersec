# NIST IR Lab – SQL Injection + WAF (Nginx/ModSecurity) com Docker (v2)

> **Atualização importante:** corrigimos o erro de filesystem read-only removendo o mount de `/etc/nginx/nginx.conf` 
> e usando o caminho correto de overrides do ModSecurity: `/etc/nginx/modsecurity.d/modsecurity-override.conf`.
> 
> **Logs do ModSecurity:** Os logs são direcionados para stdout e devem ser acessados via `docker logs waf_proxy` 
> ao invés de arquivos internos no container.

## 1) Subir o ambiente
```bash
docker compose up -d
docker ps
```
Acesse via WAF: http://localhost:8080

## 2) Verificar logs do WAF
```bash
docker logs -f waf_proxy
docker logs --tail 20 waf_proxy
```

## 3) Ataque (Detecção)
```bash
docker exec -it kali_attacker bash
apt update && apt -y install sqlmap curl
sqlmap -u "http://waf_proxy/rest/products/search?q=1" --batch --risk=3 --level=5 --dbs
```
Procurar evidências (regras 942* do CRS):
```bash
docker logs waf_proxy | grep -E "942|SQL Injection" | head -n 40
docker logs waf_proxy | grep -o '"ruleId":"942[0-9]*"' | sort | uniq -c | sort -nr
```

## 4) Contenção (Bloqueio)
Edite **modsecurity/modsecurity-override.conf** e altere:
```
SecRuleEngine On
```
Reinicie o WAF:
```bash
docker compose restart waf
```
Re-teste para verificar bloqueio:
```bash
# Teste normal (deve retornar 200)
curl -s -o /dev/null -w "%{http_code}" http://localhost:8080

# Teste ataque (deve retornar 403)
curl -s -w "%{http_code}" "http://localhost:8080/rest/products/search?q=1' UNION SELECT 1,2,3--"

# Verificar logs de bloqueio
docker logs --tail 10 waf_proxy | grep "403 Forbidden"
```

## 5) Recuperação e Post-Mortem
- `docker compose restart juice-shop`
- Valide o serviço e colete evidências
- Faça o mini-relatório conforme o README original

## 6) Relatório Visual (Opcional)
Gere um relatório HTML interativo com gráficos e filtros:
```bash
# Gerar relatório dos logs atuais
python3 generate_report.py

# Ou visualizar relatório de demonstração
open demo_report.html
```

O relatório inclui:
- 📊 **Dashboard com métricas** (ataques bloqueados vs detectados)
- 📈 **Gráficos interativos** (regras mais ativadas, tipos de ataque, timeline)
- 🔍 **Logs detalhados com filtros** (por IP, regra, status)
- 🎯 **Análise de tendências** e estatísticas de segurança

## 7) Limpeza
```bash
docker compose down -v
```
