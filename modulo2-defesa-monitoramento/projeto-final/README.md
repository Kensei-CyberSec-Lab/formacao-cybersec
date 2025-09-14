# Projeto Final – Módulo 2: Defesa & Monitoramento

Este repositório contém **duas opções de projeto final**. Escolha **uma** (ou combine, se aprovado pelo instrutor).  
O objetivo é **demonstrar competência prática e estratégica** em defesa, monitoramento e resposta a incidentes.

## 📌 Opções de Projeto

### 🔧 Opção 1 – Técnico (Hands‑on)
Monte um ambiente defensivo, **execute um ataque controlado** e **comprove defesa, monitoramento e resposta** com evidências.
- Hardening + firewall (iptables) no host de defesa
- WAF com ModSecurity/OWASP CRS (modo detecção → bloqueio)
- Simular ataques (SQLi, XSS) e **coletar logs**
- Responder ao incidente (NIST IR): detecção, contenção, erradicação, recuperação
- **Entrega**: relatório técnico + prints/logs + diagrama

👉 Pasta: [`opcao1-hands-on/`](opcao1-hands-on/)

### 🧭 Opção 2 – Conceitual (Consultoria)
Atue como **consultor Blue Team**: proponha **defesa em profundidade**, **plano de monitoramento/SIEM** e **plano de IR** (NIST).
- Arquitetura de defesa (camadas, WAF, IDS/IPS, SIEM, patching)
- Plano de monitoramento (fontes de log, regras/alertas, KPIs/Metrics)
- Plano de resposta a incidentes (NIST IR) + runbooks de contenção
- Recomendações priorizadas (80/20) + roadmap
- **Entrega**: documento profissional + diagrama + sumário executivo

👉 Pasta: [`opcao2-consultoria/`](opcao2-consultoria/)

---

## ✅ Requisitos de Entrega (para ambas)
- **Formato**: Markdown (`.md`) ou PDF
- **Estrutura mínima**: capa, sumário executivo, objetivo, escopo, metodologia, diagrama, evidências/diagnóstico, recomendações, plano de ação, conclusão, anexos
- **Clareza executiva**: 1 página de **sumário executivo** obrigatória
- **Rastreabilidade**: referencie prints/logs (com data/hora) e anexe configs

## 🧪 Avaliação (Rubrica 0–10)
| Critério | Peso |
|---|---:|
| Metodologia e justificativas técnicas | 2.0 |
| Qualidade da arquitetura/defesa (camadas) | 2.0 |
| Monitoramento e evidências (logs/alertas) | 2.0 |
| Resposta a incidente (ciclo NIST IR) | 2.0 |
| Comunicação (sumário executivo, clareza) | 2.0 |

> **Bônus** (+0.5): automações, dashboards, runbooks acionáveis, diagramas mermaid bem comentados.

## ⏱️ Linha do Tempo Sugerida
- **Checkpoint 1**: Diagrama + Metodologia
- **Checkpoint 2**: Entrega final (relatório + anexos)
- **Apresentação**: 5–8 min por grupo (demonstração ou walkthrough)

## ⚠️ Ética e Segurança
Exercícios apenas em **ambiente controlado** do curso. Respeite o **juramento Kensei** e práticas de **divulgação responsável**.
