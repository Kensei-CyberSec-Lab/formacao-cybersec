# Desafio Bônus: Plano de Resposta a Incidentes NIST

## Objetivo do Desafio

Criar um **Plano de Resposta a Incidentes (IRP)** completo seguindo o framework **NIST SP 800-61 Rev. 2**, baseado em cenários reais de segurança cibernética.

## Framework NIST SP 800-61 Rev. 2

O NIST define **4 fases principais** para resposta a incidentes:

### 1. **Preparation (Preparação)**
- Estabelecer capacidades de resposta
- Treinar equipes
- Criar políticas e procedimentos

### 2. **Detection & Analysis (Detecção e Análise)**
- Identificar indicadores de comprometimento
- Analisar e validar incidentes
- Categorizar e priorizar

### 3. **Containment, Eradication & Recovery (Contenção, Erradicação e Recuperação)**
- Conter o incidente
- Eliminar a causa raiz
- Recuperar sistemas e serviços

### 4. **Post-Incident Activity (Atividades Pós-Incidente)**
- Lições aprendidas
- Melhorias no processo
- Documentação

---

## Cenários do Desafio

Escolha **UM** dos cenários abaixo e desenvolva um plano de resposta completo:

### **Cenário A: Ataque de Ransomware**
Uma empresa de médio porte teve seus sistemas criptografados por ransomware. Vários servidores estão inacessíveis e há uma nota de resgate exigindo pagamento em Bitcoin.

**Indicadores:**
- Arquivos com extensão `.encrypted`
- Nota de resgate em desktops
- Sistemas críticos indisponíveis
- Logs mostram acesso suspeito via RDP

### **Cenário B: Violação de Dados (Data Breach)**
Um e-commerce descobriu que dados de clientes (CPF, cartões de crédito, endereços) foram expostos através de uma vulnerabilidade SQL Injection não corrigida.

**Indicadores:**
- Tráfego anômalo no banco de dados
- Logs de WAF com ataques SQLi
- Dados de clientes encontrados em fóruns da dark web
- Reclamações de clientes sobre uso fraudulento de cartões

### **Cenário C: Comprometimento de Conta Privilegiada**
A conta de administrador de domínio foi comprometida. O atacante tem acesso total ao Active Directory e está realizando movimentação lateral na rede.

**Indicadores:**
- Logins de admin fora do horário comercial
- Criação de contas de usuário não autorizadas
- Acesso a sistemas críticos não relacionados às funções do admin
- Alterações não autorizadas em grupos de segurança

---

## Entregáveis

Crie os seguintes documentos para o cenário escolhido:

### 1. **Plano de Resposta a Incidentes** (`plano-ir-nist.md`)
Documento principal seguindo as 4 fases do NIST

### 2. **Procedimentos de Comunicação** (`comunicacao.md`)
- Matriz de comunicação (quem avisar, quando, como)
- Templates de comunicação interna e externa
- Procedimentos para autoridades e mídia

### 3. **Playbooks Técnicos** (`playbooks/`)
Procedimentos passo-a-passo para:
- Contenção imediata
- Coleta de evidências
- Análise forense
- Recuperação de sistemas

### 4. **Formulários e Checklists** (`forms/`)
- Formulário de relato de incidente
- Checklist de contenção
- Log de ações realizadas
- Relatório de lições aprendidas

### 5. **Matriz de Classificação** (`classificacao.md`)
Sistema para classificar incidentes por:
- Severidade (Crítico, Alto, Médio, Baixo)
- Impacto (Confidencialidade, Integridade, Disponibilidade)
- Tempo de resposta (SLA)

---

## Estrutura de Pastas Sugerida

```
cenario-[A|B|C]/
├── plano-ir-nist.md
├── comunicacao.md
├── classificacao.md
├── playbooks/
│   ├── contencao.md
│   ├── evidencias.md
│   ├── analise-forense.md
│   └── recuperacao.md
├── forms/
│   ├── relato-incidente.md
│   ├── checklist-contencao.md
│   ├── log-acoes.md
│   └── licoes-aprendidas.md
└── templates/
    ├── comunicacao-interna.md
    ├── comunicacao-externa.md
    └── relatorio-executivo.md
```

---

## Critérios de Avaliação

### **Excelente (90-100 pontos)**
- Plano completo cobrindo todas as 4 fases do NIST
- Procedimentos detalhados e executáveis
- Matriz de comunicação bem definida
- Templates profissionais
- Considerações legais e regulatórias
- Timeline realista e bem estruturada

### **Bom (70-89 pontos)**
- Plano cobrindo as principais fases do NIST
- Procedimentos adequados mas não totalmente detalhados
- Comunicação básica definida
- Templates funcionais
- Algumas considerações legais

### **Satisfatório (50-69 pontos)**
- Plano básico seguindo estrutura NIST
- Procedimentos genéricos
- Comunicação superficial
- Templates simples

### **Insuficiente (<50 pontos)**
- Plano incompleto ou não segue NIST
- Procedimentos vagos ou irrealistas
- Falta de estrutura organizacional

---

## Dicas para Desenvolvimento

### **1. Pesquise o Cenário**
- Estude casos reais similares
- Entenda as técnicas dos atacantes
- Identifique vulnerabilidades exploradas

### **2. Seja Específico**
- Use comandos técnicos reais
- Defina tempos específicos (ex: "contenção em 30 minutos")
- Identifique ferramentas e responsáveis

### **3. Considere o Contexto**
- Tamanho da organização
- Setor de atuação (financeiro, saúde, varejo)
- Regulamentações aplicáveis (LGPD, PCI-DSS, etc.)

### **4. Pense na Prática**
- Como seria executado às 2h da manhã?
- E se o responsável estiver de férias?
- Como comunicar sem causar pânico?

---

## Recursos de Referência

### **Documentos NIST**
- [NIST SP 800-61 Rev. 2](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-61r2.pdf)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)

### **Frameworks Complementares**
- [SANS Incident Response Process](https://www.sans.org/reading-room/whitepapers/incident/incident-handlers-handbook-33901)
- [MITRE ATT&CK Framework](https://attack.mitre.org/)
- [OWASP Incident Response](https://owasp.org/www-community/Incident_Response)

### **Ferramentas Úteis**
- **Análise:** Volatility, Autopsy, Wireshark
- **Contenção:** iptables, PowerShell, Group Policy
- **Comunicação:** Slack, Microsoft Teams, PagerDuty
- **Documentação:** Mermaid (diagramas), Markdown

---

## Prazo e Entrega

### **Prazo:** 2 semanas a partir da data de lançamento

### **Forma de Entrega:**
1. Criar pasta com o nome do cenário escolhido
2. Organizar arquivos conforme estrutura sugerida
3. Incluir arquivo `README.md` explicando suas escolhas
4. Adicionar ao repositório do curso

### **Apresentação (Opcional):**
- Apresentação de 15 minutos do plano desenvolvido
- Simulação de uma fase do processo de resposta
- Q&A com discussão de melhorias

---

## Bônus Extra

### **+10 pontos:** Criar diagrama de fluxo do processo usando Mermaid
### **+10 pontos:** Incluir scripts automatizados para contenção
### **+10 pontos:** Desenvolver dashboard de métricas de resposta
### **+5 pontos:** Integração com ferramentas SIEM/SOAR

---

## Dúvidas e Suporte

- Consulte a documentação NIST SP 800-61 Rev. 2
- Analise casos reais de resposta a incidentes
- Discuta com colegas (colaboração é incentivada!)
- Pergunte ao instrutor em caso de dúvidas específicas

---

**Este desafio simula situações reais que profissionais de segurança enfrentam diariamente. Desenvolva um plano que você usaria em uma situação real!**
