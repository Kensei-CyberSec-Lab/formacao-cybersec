# Briefing – Empresa Fictícia "LojaZeta"
- E-commerce em crescimento (stack: Nginx + Node.js + PostgreSQL)
- Infra em nuvem (IaaS) com exposição pública do web/app
- Incidentes recentes: tentativas de SQLi, XSS e brute-force em /login
- Não há SIEM; logs espalhados em instâncias
- Backups feitos, mas sem testes de restauração
- Time pequeno (2 devs, 1 ops); orçamento limitado

## Requisitos
- **Segurança em camadas** com foco em web/app e identidade
- **Monitoramento centralizado** (mínimo viável) com alertas acionáveis
- **Resposta a incidentes**: procedimentos simples e claros
- **Plano 80/20** com quick wins em 30 dias
