#!/usr/bin/env python3
"""
ModSecurity WAF Log Report Generator
Gera relatório HTML visual dos logs do ModSecurity para análise de ataques SQL injection
"""

import json
import re
import subprocess
import sys
from datetime import datetime
from collections import Counter, defaultdict

def get_waf_logs():
    """Extrai logs do container WAF"""
    try:
        result = subprocess.run(['docker', 'logs', 'waf_proxy'], 
                              capture_output=True, text=True, check=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"Erro ao obter logs: {e}")
        return ""

def parse_modsecurity_logs(logs):
    """Parse dos logs JSON do ModSecurity"""
    events = []
    # Improved regex to match complete JSON objects
    json_pattern = r'\{"transaction":\{.*?"messages":\[.*?\]\}\}'
    
    for match in re.finditer(json_pattern, logs, re.DOTALL):
        try:
            event = json.loads(match.group())
            if 'transaction' in event:
                events.append(event)
        except json.JSONDecodeError:
            continue
    
    return events

def analyze_events(events):
    """Análise estatística dos eventos"""
    stats = {
        'total_events': len(events),
        'rule_counts': Counter(),
        'attack_types': Counter(),
        'blocked_vs_detected': {'blocked': 0, 'detected': 0},
        'timeline': defaultdict(int),
        'top_ips': Counter(),
        'severity_levels': Counter()
    }
    
    for event in events:
        transaction = event['transaction']
        
        # IPs mais ativos
        client_ip = transaction.get('client_ip', 'Unknown')
        stats['top_ips'][client_ip] += 1
        
        # Timeline por hora
        timestamp = transaction.get('time_stamp', '')
        if timestamp:
            try:
                dt = datetime.strptime(timestamp, '%a %b %d %H:%M:%S %Y')
                hour_key = dt.strftime('%H:00')
                stats['timeline'][hour_key] += 1
            except:
                pass
        
        # Status (bloqueado vs detectado)
        response_code = transaction.get('response', {}).get('http_code', 0)
        if response_code == 403:
            stats['blocked_vs_detected']['blocked'] += 1
        else:
            stats['blocked_vs_detected']['detected'] += 1
        
        # Análise das mensagens/regras
        messages = event.get('messages', [])
        for msg in messages:
            rule_id = msg.get('ruleId', '')
            if rule_id:
                stats['rule_counts'][rule_id] += 1
            
            # Tipos de ataque
            message_text = msg.get('message', '').lower()
            if 'sql injection' in message_text:
                stats['attack_types']['SQL Injection'] += 1
            elif 'xss' in message_text:
                stats['attack_types']['XSS'] += 1
            elif 'scanner' in message_text:
                stats['attack_types']['Scanner Detection'] += 1
            elif 'path traversal' in message_text:
                stats['attack_types']['Path Traversal'] += 1
            elif 'command injection' in message_text:
                stats['attack_types']['Command Injection'] += 1
            
            # Severidade
            severity = msg.get('severity', 'Unknown')
            stats['severity_levels'][severity] += 1
    
    return stats

def generate_html_report(events, stats):
    """Gera relatório HTML interativo"""
    
    # Preparar dados para gráficos
    rule_data = dict(stats['rule_counts'].most_common(10))
    attack_data = dict(stats['attack_types'])
    timeline_data = dict(sorted(stats['timeline'].items()))
    
    html_content = f"""
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ModSecurity WAF - Relatório de Segurança</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        body {{ 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }}
        .container {{
            max-width: 1200px;
            margin: 0 auto;
            background: rgba(255,255,255,0.95);
            border-radius: 15px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            overflow: hidden;
        }}
        .header {{
            background: linear-gradient(135deg, #ff6b6b, #ee5a24);
            color: white;
            padding: 30px;
            text-align: center;
        }}
        .header h1 {{
            font-size: 2.5em;
            margin-bottom: 10px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }}
        .header p {{
            font-size: 1.1em;
            opacity: 0.9;
        }}
        .stats-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            padding: 30px;
        }}
        .stat-card {{
            background: white;
            padding: 25px;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            text-align: center;
            border-left: 5px solid #3498db;
            transition: transform 0.3s ease;
        }}
        .stat-card:hover {{
            transform: translateY(-5px);
        }}
        .stat-number {{
            font-size: 2.5em;
            font-weight: bold;
            color: #2c3e50;
            margin-bottom: 10px;
        }}
        .stat-label {{
            font-size: 1em;
            color: #7f8c8d;
            text-transform: uppercase;
            letter-spacing: 1px;
        }}
        .blocked {{ border-left-color: #e74c3c; }}
        .detected {{ border-left-color: #f39c12; }}
        .rules {{ border-left-color: #27ae60; }}
        .attacks {{ border-left-color: #8e44ad; }}
        .charts-section {{
            padding: 30px;
            background: #f8f9fa;
        }}
        .chart-container {{
            margin-bottom: 40px;
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }}
        .chart-title {{
            font-size: 1.5em;
            margin-bottom: 20px;
            color: #2c3e50;
            text-align: center;
        }}
        .chart-row {{
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
        }}
        .logs-section {{
            padding: 30px;
        }}
        .filter-controls {{
            margin-bottom: 20px;
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
        }}
        .filter-input {{
            padding: 10px;
            border: 2px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
        }}
        .filter-button {{
            background: #3498db;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
        }}
        .filter-button:hover {{
            background: #2980b9;
        }}
        .log-entry {{
            background: #f8f9fa;
            margin-bottom: 15px;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }}
        .log-header {{
            background: #34495e;
            color: white;
            padding: 15px;
            cursor: pointer;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }}
        .log-header:hover {{
            background: #2c3e50;
        }}
        .log-details {{
            display: none;
            padding: 20px;
            background: white;
        }}
        .log-details.show {{
            display: block;
        }}
        .status-badge {{
            padding: 5px 10px;
            border-radius: 15px;
            font-size: 12px;
            font-weight: bold;
        }}
        .status-blocked {{
            background: #e74c3c;
            color: white;
        }}
        .status-detected {{
            background: #f39c12;
            color: white;
        }}
        .rule-tag {{
            display: inline-block;
            background: #3498db;
            color: white;
            padding: 3px 8px;
            border-radius: 3px;
            font-size: 11px;
            margin: 2px;
        }}
        .timestamp {{
            font-family: monospace;
            color: #7f8c8d;
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🛡️ ModSecurity WAF</h1>
            <p>Relatório de Análise de Segurança - Lab NIST IR</p>
            <p class="timestamp">Gerado em: {datetime.now().strftime('%d/%m/%Y às %H:%M:%S')}</p>
        </div>

        <div class="stats-grid">
            <div class="stat-card blocked">
                <div class="stat-number">{stats['blocked_vs_detected']['blocked']}</div>
                <div class="stat-label">Ataques Bloqueados</div>
            </div>
            <div class="stat-card detected">
                <div class="stat-number">{stats['blocked_vs_detected']['detected']}</div>
                <div class="stat-label">Ataques Detectados</div>
            </div>
            <div class="stat-card rules">
                <div class="stat-number">{len(stats['rule_counts'])}</div>
                <div class="stat-label">Regras Ativadas</div>
            </div>
            <div class="stat-card attacks">
                <div class="stat-number">{len(stats['attack_types'])}</div>
                <div class="stat-label">Tipos de Ataque</div>
            </div>
        </div>

        <div class="charts-section">
            <div class="chart-row">
                <div class="chart-container">
                    <h3 class="chart-title">Top 10 Regras Ativadas</h3>
                    <canvas id="rulesChart"></canvas>
                </div>
                <div class="chart-container">
                    <h3 class="chart-title">Tipos de Ataque</h3>
                    <canvas id="attacksChart"></canvas>
                </div>
            </div>
            
            <div class="chart-container">
                <h3 class="chart-title">Timeline de Eventos</h3>
                <canvas id="timelineChart"></canvas>
            </div>
        </div>

        <div class="logs-section">
            <h3 class="chart-title">Logs Detalhados</h3>
            
            <div class="filter-controls">
                <input type="text" id="filterRule" class="filter-input" placeholder="Filtrar por Rule ID (ex: 942100)">
                <input type="text" id="filterIP" class="filter-input" placeholder="Filtrar por IP">
                <select id="filterStatus" class="filter-input">
                    <option value="">Todos os Status</option>
                    <option value="403">Apenas Bloqueados (403)</option>
                    <option value="200">Apenas Detectados (200)</option>
                </select>
                <button class="filter-button" onclick="applyFilters()">Aplicar Filtros</button>
                <button class="filter-button" onclick="clearFilters()">Limpar</button>
            </div>

            <div id="logEntries">
"""

    # Adicionar entradas de log
    for i, event in enumerate(events[:50]):  # Limitar a 50 eventos mais recentes
        transaction = event['transaction']
        messages = event.get('messages', [])
        
        client_ip = transaction.get('client_ip', 'Unknown')
        timestamp = transaction.get('time_stamp', '')
        uri = transaction.get('request', {}).get('uri', '')
        http_code = transaction.get('response', {}).get('http_code', 0)
        
        status_class = 'blocked' if http_code == 403 else 'detected'
        status_text = 'BLOQUEADO' if http_code == 403 else 'DETECTADO'
        
        rule_ids = [msg.get('ruleId', '') for msg in messages if msg.get('ruleId')]
        rule_tags = ''.join([f'<span class="rule-tag">{rule_id}</span>' for rule_id in rule_ids[:5]])
        
        html_content += f"""
                <div class="log-entry" data-ip="{client_ip}" data-status="{http_code}" data-rules="{','.join(rule_ids)}">
                    <div class="log-header" onclick="toggleLogDetails({i})">
                        <div>
                            <strong>{timestamp}</strong> - {client_ip} → {uri[:80]}...
                        </div>
                        <div>
                            <span class="status-badge status-{status_class}">{status_text}</span>
                        </div>
                    </div>
                    <div class="log-details" id="logDetails{i}">
                        <p><strong>URL:</strong> {uri}</p>
                        <p><strong>Código HTTP:</strong> {http_code}</p>
                        <p><strong>IP Cliente:</strong> {client_ip}</p>
                        <p><strong>Regras Ativadas:</strong> {rule_tags}</p>
                        <h4>Mensagens de Segurança:</h4>
                        <ul>
"""
        
        for msg in messages:
            message_text = msg.get('message', '')
            rule_id = msg.get('ruleId', '')
            severity = msg.get('severity', '')
            html_content += f"<li><strong>[{rule_id}]</strong> {message_text} (Severidade: {severity})</li>"
        
        html_content += """
                        </ul>
                    </div>
                </div>
"""

    # Finalizar HTML com JavaScript
    html_content += f"""
            </div>
        </div>
    </div>

    <script>
        // Dados para os gráficos
        const rulesData = {json.dumps(rule_data)};
        const attacksData = {json.dumps(attack_data)};
        const timelineData = {json.dumps(timeline_data)};

        // Gráfico de Regras
        const rulesCtx = document.getElementById('rulesChart').getContext('2d');
        new Chart(rulesCtx, {{
            type: 'bar',
            data: {{
                labels: Object.keys(rulesData),
                datasets: [{{
                    label: 'Ativações',
                    data: Object.values(rulesData),
                    backgroundColor: 'rgba(52, 152, 219, 0.8)',
                    borderColor: 'rgba(52, 152, 219, 1)',
                    borderWidth: 2
                }}]
            }},
            options: {{
                responsive: true,
                plugins: {{
                    legend: {{ display: false }}
                }},
                scales: {{
                    y: {{ beginAtZero: true }}
                }}
            }}
        }});

        // Gráfico de Tipos de Ataque
        const attacksCtx = document.getElementById('attacksChart').getContext('2d');
        new Chart(attacksCtx, {{
            type: 'doughnut',
            data: {{
                labels: Object.keys(attacksData),
                datasets: [{{
                    data: Object.values(attacksData),
                    backgroundColor: [
                        '#e74c3c', '#f39c12', '#27ae60', '#8e44ad', '#3498db'
                    ]
                }}]
            }},
            options: {{
                responsive: true,
                plugins: {{
                    legend: {{ position: 'bottom' }}
                }}
            }}
        }});

        // Gráfico de Timeline
        const timelineCtx = document.getElementById('timelineChart').getContext('2d');
        new Chart(timelineCtx, {{
            type: 'line',
            data: {{
                labels: Object.keys(timelineData),
                datasets: [{{
                    label: 'Eventos por Hora',
                    data: Object.values(timelineData),
                    borderColor: '#e74c3c',
                    backgroundColor: 'rgba(231, 76, 60, 0.1)',
                    tension: 0.4,
                    fill: true
                }}]
            }},
            options: {{
                responsive: true,
                plugins: {{
                    legend: {{ display: false }}
                }},
                scales: {{
                    y: {{ beginAtZero: true }}
                }}
            }}
        }});

        // Funções JavaScript
        function toggleLogDetails(index) {{
            const details = document.getElementById('logDetails' + index);
            details.classList.toggle('show');
        }}

        function applyFilters() {{
            const ruleFilter = document.getElementById('filterRule').value.toLowerCase();
            const ipFilter = document.getElementById('filterIP').value.toLowerCase();
            const statusFilter = document.getElementById('filterStatus').value;
            
            const logEntries = document.querySelectorAll('.log-entry');
            
            logEntries.forEach(entry => {{
                const ip = entry.dataset.ip.toLowerCase();
                const status = entry.dataset.status;
                const rules = entry.dataset.rules.toLowerCase();
                
                let show = true;
                
                if (ruleFilter && !rules.includes(ruleFilter)) show = false;
                if (ipFilter && !ip.includes(ipFilter)) show = false;
                if (statusFilter && status !== statusFilter) show = false;
                
                entry.style.display = show ? 'block' : 'none';
            }});
        }}

        function clearFilters() {{
            document.getElementById('filterRule').value = '';
            document.getElementById('filterIP').value = '';
            document.getElementById('filterStatus').value = '';
            
            document.querySelectorAll('.log-entry').forEach(entry => {{
                entry.style.display = 'block';
            }});
        }}

        // Auto-aplicar filtros quando digitar
        document.getElementById('filterRule').addEventListener('input', applyFilters);
        document.getElementById('filterIP').addEventListener('input', applyFilters);
        document.getElementById('filterStatus').addEventListener('change', applyFilters);
    </script>
</body>
</html>
"""
    
    return html_content

def main():
    print("🔍 Coletando logs do ModSecurity WAF...")
    logs = get_waf_logs()
    
    if not logs:
        print("❌ Nenhum log encontrado. Verifique se o container 'waf_proxy' está rodando.")
        sys.exit(1)
    
    print("📊 Analisando eventos de segurança...")
    events = parse_modsecurity_logs(logs)
    
    if not events:
        print("⚠️  Nenhum evento ModSecurity encontrado nos logs.")
        sys.exit(1)
    
    print(f"✅ Encontrados {len(events)} eventos de segurança")
    
    stats = analyze_events(events)
    
    print("🎨 Gerando relatório HTML...")
    html_report = generate_html_report(events, stats)
    
    # Salvar relatório
    report_file = 'modsecurity_report.html'
    with open(report_file, 'w', encoding='utf-8') as f:
        f.write(html_report)
    
    print(f"✅ Relatório gerado: {report_file}")
    print(f"📈 Resumo:")
    print(f"   • {stats['total_events']} eventos totais")
    print(f"   • {stats['blocked_vs_detected']['blocked']} ataques bloqueados")
    print(f"   • {stats['blocked_vs_detected']['detected']} ataques detectados")
    print(f"   • {len(stats['rule_counts'])} regras diferentes ativadas")
    print(f"   • {len(stats['attack_types'])} tipos de ataque identificados")
    print(f"\n🌐 Abra o arquivo '{report_file}' no seu navegador para visualizar o relatório!")

if __name__ == '__main__':
    main()
