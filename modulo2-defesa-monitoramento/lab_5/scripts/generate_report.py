#!/usr/bin/env python3
"""
Gerador de Relatórios de Segurança - Trivy Scanner
Módulo 2 - Defesa e Monitoramento - Lab 5
"""

import json
import sys
import subprocess
import os
from datetime import datetime
from pathlib import Path
import argparse
from jinja2 import Template
import pandas as pd

class TrivyReportGenerator:
    def __init__(self):
        self.timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        self.reports_dir = Path("/root/reports")
        self.reports_dir.mkdir(exist_ok=True)
        
    def run_trivy_scan(self, image_name, output_format="json"):
        """Executa scan do Trivy e retorna os resultados"""
        print(f"🔍 Escaneando imagem: {image_name}")
        
        cmd = [
            "trivy", "image", 
            "--format", output_format,
            "--severity", "LOW,MEDIUM,HIGH,CRITICAL",
            image_name
        ]
        
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
            return result.stdout
        except subprocess.CalledProcessError as e:
            print(f"❌ Erro ao executar Trivy: {e}")
            sys.exit(1)
    
    def parse_json_results(self, json_data):
        """Parse dos resultados JSON do Trivy"""
        try:
            data = json.loads(json_data)
            return data
        except json.JSONDecodeError as e:
            print(f"❌ Erro ao fazer parse do JSON: {e}")
            sys.exit(1)
    
    def generate_statistics(self, results):
        """Gera estatísticas dos resultados"""
        stats = {
            "total_vulnerabilities": 0,
            "by_severity": {"LOW": 0, "MEDIUM": 0, "HIGH": 0, "CRITICAL": 0},
            "by_type": {},
            "critical_cves": [],
            "high_cves": [],
            "secrets_found": 0
        }
        
        if not results.get("Results"):
            return stats
        
        for result in results["Results"]:
            # Vulnerabilidades
            if "Vulnerabilities" in result:
                for vuln in result["Vulnerabilities"]:
                    stats["total_vulnerabilities"] += 1
                    severity = vuln.get("Severity", "UNKNOWN")
                    stats["by_severity"][severity] = stats["by_severity"].get(severity, 0) + 1
                    
                    # CVEs críticos e altos
                    if severity == "CRITICAL":
                        stats["critical_cves"].append({
                            "id": vuln.get("VulnerabilityID", "N/A"),
                            "title": vuln.get("Title", "N/A"),
                            "score": vuln.get("CVSS", {}).get("nvd", {}).get("V3Score", "N/A")
                        })
                    elif severity == "HIGH":
                        stats["high_cves"].append({
                            "id": vuln.get("VulnerabilityID", "N/A"),
                            "title": vuln.get("Title", "N/A"),
                            "score": vuln.get("CVSS", {}).get("nvd", {}).get("V3Score", "N/A")
                        })
            
            # Secrets
            if "Secrets" in result:
                stats["secrets_found"] += len(result["Secrets"])
            
            # Tipos de arquivos
            result_type = result.get("Type", "Unknown")
            stats["by_type"][result_type] = stats["by_type"].get(result_type, 0) + 1
        
        return stats
    
    def generate_html_report(self, results, stats, image_name):
        """Gera relatório em HTML"""
        template_html = """
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Relatório de Segurança - {{ image_name }}</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 0 20px rgba(0,0,0,0.1); }
        .header { text-align: center; border-bottom: 3px solid #2196F3; padding-bottom: 20px; margin-bottom: 30px; }
        .header h1 { color: #1976D2; margin: 0; font-size: 2.5em; }
        .header p { color: #666; font-size: 1.1em; margin: 10px 0; }
        .summary { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .card { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 10px; text-align: center; }
        .card h3 { margin: 0 0 10px 0; font-size: 1.2em; }
        .card .number { font-size: 2.5em; font-weight: bold; margin: 10px 0; }
        .severity-critical { background: linear-gradient(135deg, #ff4757 0%, #c44569 100%); }
        .severity-high { background: linear-gradient(135deg, #ff6b35 0%, #f7931e 100%); }
        .severity-medium { background: linear-gradient(135deg, #ffa726 0%, #fb8c00 100%); }
        .severity-low { background: linear-gradient(135deg, #66bb6a 0%, #43a047 100%); }
        .section { margin: 30px 0; }
        .section h2 { color: #1976D2; border-bottom: 2px solid #e0e0e0; padding-bottom: 10px; }
        .cve-table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        .cve-table th, .cve-table td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        .cve-table th { background: #f8f9fa; font-weight: bold; }
        .cve-table tr:hover { background: #f5f5f5; }
        .critical-badge { background: #f44336; color: white; padding: 4px 8px; border-radius: 4px; font-size: 0.8em; }
        .high-badge { background: #ff9800; color: white; padding: 4px 8px; border-radius: 4px; font-size: 0.8em; }
        .footer { text-align: center; margin-top: 40px; padding-top: 20px; border-top: 1px solid #e0e0e0; color: #666; }
        .risk-level { padding: 20px; border-radius: 8px; margin: 20px 0; }
        .risk-critical { background: #ffebee; border-left: 5px solid #f44336; }
        .risk-high { background: #fff3e0; border-left: 5px solid #ff9800; }
        .risk-medium { background: #f3e5f5; border-left: 5px solid #9c27b0; }
        .risk-low { background: #e8f5e8; border-left: 5px solid #4caf50; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🛡️ Relatório de Segurança</h1>
            <p><strong>Imagem:</strong> {{ image_name }}</p>
            <p><strong>Data/Hora:</strong> {{ timestamp }}</p>
            <p><strong>Ferramenta:</strong> Trivy Security Scanner</p>
        </div>

        <div class="summary">
            <div class="card">
                <h3>Total de Vulnerabilidades</h3>
                <div class="number">{{ stats.total_vulnerabilities }}</div>
            </div>
            <div class="card severity-critical">
                <h3>Críticas</h3>
                <div class="number">{{ stats.by_severity.CRITICAL }}</div>
            </div>
            <div class="card severity-high">
                <h3>Altas</h3>
                <div class="number">{{ stats.by_severity.HIGH }}</div>
            </div>
            <div class="card severity-medium">
                <h3>Médias</h3>
                <div class="number">{{ stats.by_severity.MEDIUM }}</div>
            </div>
            <div class="card severity-low">
                <h3>Baixas</h3>
                <div class="number">{{ stats.by_severity.LOW }}</div>
            </div>
            <div class="card">
                <h3>Secrets Encontrados</h3>
                <div class="number">{{ stats.secrets_found }}</div>
            </div>
        </div>

        <div class="section">
            <h2>📊 Análise de Risco</h2>
            {% if stats.by_severity.CRITICAL > 0 %}
            <div class="risk-level risk-critical">
                <h3>🚨 RISCO CRÍTICO</h3>
                <p>Encontradas <strong>{{ stats.by_severity.CRITICAL }}</strong> vulnerabilidades críticas que requerem ação imediata.</p>
            </div>
            {% elif stats.by_severity.HIGH > 0 %}
            <div class="risk-level risk-high">
                <h3>⚠️ RISCO ALTO</h3>
                <p>Encontradas <strong>{{ stats.by_severity.HIGH }}</strong> vulnerabilidades de alta severidade.</p>
            </div>
            {% elif stats.by_severity.MEDIUM > 0 %}
            <div class="risk-level risk-medium">
                <h3>📋 RISCO MÉDIO</h3>
                <p>Sistema possui vulnerabilidades de severidade média.</p>
            </div>
            {% else %}
            <div class="risk-level risk-low">
                <h3>✅ RISCO BAIXO</h3>
                <p>Não foram encontradas vulnerabilidades críticas ou altas.</p>
            </div>
            {% endif %}
        </div>

        {% if stats.critical_cves %}
        <div class="section">
            <h2>🔥 Vulnerabilidades Críticas (CVSS ≥ 9.0)</h2>
            <table class="cve-table">
                <thead>
                    <tr>
                        <th>CVE ID</th>
                        <th>Título</th>
                        <th>Score CVSS</th>
                        <th>Severidade</th>
                    </tr>
                </thead>
                <tbody>
                    {% for cve in stats.critical_cves[:10] %}
                    <tr>
                        <td><strong>{{ cve.id }}</strong></td>
                        <td>{{ cve.title }}</td>
                        <td>{{ cve.score }}</td>
                        <td><span class="critical-badge">CRÍTICA</span></td>
                    </tr>
                    {% endfor %}
                </tbody>
            </table>
        </div>
        {% endif %}

        {% if stats.high_cves %}
        <div class="section">
            <h2>⚡ Vulnerabilidades de Alta Severidade</h2>
            <table class="cve-table">
                <thead>
                    <tr>
                        <th>CVE ID</th>
                        <th>Título</th>
                        <th>Score CVSS</th>
                        <th>Severidade</th>
                    </tr>
                </thead>
                <tbody>
                    {% for cve in stats.high_cves[:10] %}
                    <tr>
                        <td><strong>{{ cve.id }}</strong></td>
                        <td>{{ cve.title }}</td>
                        <td>{{ cve.score }}</td>
                        <td><span class="high-badge">ALTA</span></td>
                    </tr>
                    {% endfor %}
                </tbody>
            </table>
        </div>
        {% endif %}

        <div class="section">
            <h2>📋 Recomendações de Segurança</h2>
            <ul>
                {% if stats.by_severity.CRITICAL > 0 %}
                <li><strong>Ação Imediata:</strong> Atualizar pacotes com vulnerabilidades críticas</li>
                <li><strong>Prioridade:</strong> Implementar patches de segurança</li>
                {% endif %}
                {% if stats.secrets_found > 0 %}
                <li><strong>Secrets:</strong> Remover credenciais expostas no código</li>
                {% endif %}
                <li><strong>Prevenção:</strong> Implementar scans automáticos no CI/CD</li>
                <li><strong>Monitoramento:</strong> Configurar alertas para novas vulnerabilidades</li>
                <li><strong>Base Images:</strong> Usar imagens minimalistas e atualizadas</li>
            </ul>
        </div>

        <div class="footer">
            <p>Relatório gerado por Trivy Scanner | Lab 5 - Container Security</p>
            <p>Formação em Cybersecurity - Módulo 2: Defesa e Monitoramento</p>
        </div>
    </div>
</body>
</html>
        """
        
        template = Template(template_html)
        html_content = template.render(
            image_name=image_name,
            timestamp=datetime.now().strftime("%d/%m/%Y %H:%M:%S"),
            stats=stats
        )
        
        filename = self.reports_dir / f"security_report_{self.timestamp}.html"
        with open(filename, 'w', encoding='utf-8') as f:
            f.write(html_content)
        
        return filename
    
    def generate_json_report(self, results, image_name):
        """Gera relatório detalhado em JSON"""
        report = {
            "metadata": {
                "image": image_name,
                "timestamp": datetime.now().isoformat(),
                "scanner": "Trivy",
                "report_version": "1.0"
            },
            "results": results
        }
        
        filename = self.reports_dir / f"detailed_report_{self.timestamp}.json"
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
        
        return filename
    
    def generate_csv_report(self, results, image_name):
        """Gera relatório em CSV para análise"""
        vulnerabilities = []
        
        if results.get("Results"):
            for result in results["Results"]:
                if "Vulnerabilities" in result:
                    for vuln in result["Vulnerabilities"]:
                        vulnerabilities.append({
                            "CVE_ID": vuln.get("VulnerabilityID", "N/A"),
                            "Severidade": vuln.get("Severity", "N/A"),
                            "Título": vuln.get("Title", "N/A"),
                            "Pacote": vuln.get("PkgName", "N/A"),
                            "Versão_Instalada": vuln.get("InstalledVersion", "N/A"),
                            "Versão_Corrigida": vuln.get("FixedVersion", "N/A"),
                            "Score_CVSS": vuln.get("CVSS", {}).get("nvd", {}).get("V3Score", "N/A"),
                            "Arquivo": result.get("Target", "N/A")
                        })
        
        if vulnerabilities:
            df = pd.DataFrame(vulnerabilities)
            filename = self.reports_dir / f"vulnerabilities_{self.timestamp}.csv"
            df.to_csv(filename, index=False, encoding='utf-8')
            return filename
        
        return None

def main():
    parser = argparse.ArgumentParser(description="Gerador de Relatórios Trivy")
    parser.add_argument("image", help="Nome da imagem Docker para escanear")
    parser.add_argument("--format", choices=["html", "json", "csv", "all"], 
                       default="html", help="Formato do relatório")
    
    args = parser.parse_args()
    
    generator = TrivyReportGenerator()
    
    # Executar scan
    json_results = generator.run_trivy_scan(args.image)
    parsed_results = generator.parse_json_results(json_results)
    stats = generator.generate_statistics(parsed_results)
    
    # Gerar relatórios
    generated_files = []
    
    if args.format in ["html", "all"]:
        html_file = generator.generate_html_report(parsed_results, stats, args.image)
        generated_files.append(html_file)
        print(f"✅ Relatório HTML gerado: {html_file}")
    
    if args.format in ["json", "all"]:
        json_file = generator.generate_json_report(parsed_results, args.image)
        generated_files.append(json_file)
        print(f"✅ Relatório JSON gerado: {json_file}")
    
    if args.format in ["csv", "all"]:
        csv_file = generator.generate_csv_report(parsed_results, args.image)
        if csv_file:
            generated_files.append(csv_file)
            print(f"✅ Relatório CSV gerado: {csv_file}")
    
    # Resumo
    print(f"\n📊 Resumo do Scan:")
    print(f"🔍 Imagem: {args.image}")
    print(f"📈 Total de vulnerabilidades: {stats['total_vulnerabilities']}")
    print(f"🚨 Críticas: {stats['by_severity']['CRITICAL']}")
    print(f"⚠️  Altas: {stats['by_severity']['HIGH']}")
    print(f"📋 Médias: {stats['by_severity']['MEDIUM']}")
    print(f"✅ Baixas: {stats['by_severity']['LOW']}")
    print(f"🔐 Secrets encontrados: {stats['secrets_found']}")
    
    print(f"\n📁 Relatórios salvos em: /root/reports/")

if __name__ == "__main__":
    main()
