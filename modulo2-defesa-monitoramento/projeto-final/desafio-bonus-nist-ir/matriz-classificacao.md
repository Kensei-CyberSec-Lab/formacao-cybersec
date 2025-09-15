# 📊 Matriz de Classificação de Incidentes - NIST

Esta matriz padroniza a classificação de incidentes de segurança seguindo critérios objetivos e mensuráveis.

---

## 🎯 Categorias de Incidentes

### **1. 🦠 Malware**
- **Descrição:** Software malicioso (vírus, worms, trojans, ransomware)
- **Exemplos:** WannaCry, Emotet, Zeus Banking Trojan
- **Impacto Típico:** Confidencialidade, Integridade, Disponibilidade

### **2. 🎣 Phishing/Social Engineering**
- **Descrição:** Tentativas de obter informações através de engenharia social
- **Exemplos:** Emails falsos, vishing, sites fraudulentos
- **Impacto Típico:** Confidencialidade, Compliance

### **3. 💥 DDoS (Distributed Denial of Service)**
- **Descrição:** Ataques para tornar serviços indisponíveis
- **Exemplos:** Botnets, ataques volumétricos, ataques de aplicação
- **Impacto Típico:** Disponibilidade, Receita

### **4. 🗃️ Data Breach/Exfiltração**
- **Descrição:** Acesso não autorizado e exposição de dados sensíveis
- **Exemplos:** SQLi, vazamento de database, insider threat
- **Impacto Típico:** Confidencialidade, Regulatório, Reputação

### **5. 🔐 Comprometimento de Conta**
- **Descrição:** Acesso não autorizado a contas de usuário ou administrativas
- **Exemplos:** Credential stuffing, password spray, token theft
- **Impacto Típico:** Confidencialidade, Integridade

### **6. 🌐 Defacement/Alteração**
- **Descrição:** Modificação não autorizada de websites ou sistemas
- **Exemplos:** Hacktivismo, alteração de dados, sabotagem
- **Impacto Típico:** Integridade, Reputação

### **7. 🕵️ APT (Advanced Persistent Threat)**
- **Descrição:** Ataques sofisticados com persistência prolongada
- **Exemplos:** Espionagem industrial, nation-state actors
- **Impacto Típico:** Confidencialidade, Propriedade Intelectual

### **8. 👤 Insider Threat**
- **Descrição:** Ameaças originadas por colaboradores internos
- **Exemplos:** Roubo de dados, sabotagem, vazamento intencional
- **Impacto Típico:** Confidencialidade, Integridade, Confiança

---

## 🚨 Níveis de Severidade

### **🔴 CRÍTICO**
- **Definição:** Incidente com impacto operacional severo e imediato
- **Critérios:**
  - Sistemas críticos indisponíveis > 1 hora
  - Exposição de dados altamente sensíveis (> 10.000 registros)
  - Impacto financeiro > R$ 500.000
  - Violação de compliance com penalidades
  - Comprometimento de infraestrutura crítica
  - Repercussão midiática nacional
- **SLA Resposta:** < 30 minutos
- **Escalação:** CEO, CISO, Jurídico, Comunicação

### **🟠 ALTO**
- **Definição:** Incidente com impacto significativo nos negócios
- **Critérios:**
  - Sistemas importantes indisponíveis > 4 horas
  - Exposição de dados sensíveis (1.000-10.000 registros)
  - Impacto financeiro R$ 100.000 - R$ 500.000
  - Comprometimento de múltiplos sistemas
  - Possível violação regulatória
  - Repercussão midiática regional
- **SLA Resposta:** < 1 hora
- **Escalação:** CISO, TI, Jurídico

### **🟡 MÉDIO**
- **Definição:** Incidente com impacto moderado e controlado
- **Critérios:**
  - Sistemas não-críticos indisponíveis < 8 horas
  - Exposição limitada de dados (< 1.000 registros)
  - Impacto financeiro R$ 10.000 - R$ 100.000
  - Comprometimento de sistema isolado
  - Sem violação regulatória
  - Repercussão midiática local ou ausente
- **SLA Resposta:** < 4 horas
- **Escalação:** Líder de TI, Segurança

### **🟢 BAIXO**
- **Definição:** Incidente com impacto mínimo ou potencial
- **Critérios:**
  - Sistemas auxiliares indisponíveis < 24 horas
  - Nenhuma exposição de dados confirmada
  - Impacto financeiro < R$ 10.000
  - Tentativa de ataque sem sucesso
  - Violação de política interna
  - Sem repercussão externa
- **SLA Resposta:** < 8 horas
- **Escalação:** Analista de Segurança

---

## 📈 Matriz de Impacto CIA

### **Confidencialidade**

| Nível | Descrição | Exemplos |
|-------|-----------|----------|
| **ALTO** | Dados ultrassecretos ou regulamentados | CPF, cartões de crédito, dados médicos, PI |
| **MÉDIO** | Dados internos sensíveis | Estratégias de negócio, relatórios financeiros |
| **BAIXO** | Dados públicos ou de baixa sensibilidade | Informações de marketing, dados agregados |

### **Integridade**

| Nível | Descrição | Exemplos |
|-------|-----------|----------|
| **ALTO** | Sistemas críticos de missão | Core banking, controle industrial, emergência |
| **MÉDIO** | Sistemas importantes de negócio | ERP, CRM, e-commerce |
| **BAIXO** | Sistemas auxiliares | Intranet, sistemas de suporte |

### **Disponibilidade**

| Nível | Descrição | RTO | RPO |
|-------|-----------|-----|-----|
| **ALTO** | Sistemas 24/7 críticos | < 1 hora | < 15 min |
| **MÉDIO** | Sistemas horário comercial | < 4 horas | < 1 hora |
| **BAIXO** | Sistemas não-essenciais | < 24 horas | < 8 horas |

---

## ⚡ Matriz de Urgência

### **🚨 IMEDIATA (< 30 min)**
- **Critérios:**
  - Ataque em andamento
  - Sistemas críticos comprometidos
  - Exposição de dados em massa
  - Ameaça à segurança física
  - Ransomware ativo

### **🔥 ALTA (< 1 hora)**
- **Critérios:**
  - Evidências de comprometimento
  - Sistemas importantes afetados
  - Possível exposição de dados
  - Violação detectada por terceiros
  - Ameaça de deadline regulatório

### **⚠️ NORMAL (< 4 horas)**
- **Critérios:**
  - Incidente contido
  - Impacto limitado
  - Investigação necessária
  - Melhorias de segurança
  - Compliance preventivo

### **📋 BAIXA (< 8 horas)**
- **Critérios:**
  - Incidente resolvido
  - Análise pós-incidente
  - Documentação
  - Treinamento
  - Auditoria de rotina

---

## 🎯 Matriz de Priorização

| Severidade | Impacto Alto | Impacto Médio | Impacto Baixo |
|------------|--------------|---------------|---------------|
| **Crítico** | P1 - Imediata | P1 - Imediata | P2 - Alta |
| **Alto** | P1 - Imediata | P2 - Alta | P3 - Normal |
| **Médio** | P2 - Alta | P3 - Normal | P4 - Baixa |
| **Baixo** | P3 - Normal | P4 - Baixa | P4 - Baixa |

### **Definição das Prioridades:**

- **P1 (Imediata):** Resposta em < 30 min, equipe completa mobilizada
- **P2 (Alta):** Resposta em < 1 hora, líder técnico + especialistas
- **P3 (Normal):** Resposta em < 4 horas, analista de plantão
- **P4 (Baixa):** Resposta em < 8 horas, próxima janela de trabalho

---

## 📊 Exemplos de Classificação

### **Exemplo 1: Ransomware**
- **Categoria:** Malware
- **Severidade:** Crítico (sistemas indisponíveis)
- **Impacto:** Alto (disponibilidade + integridade)
- **Urgência:** Imediata (ataque ativo)
- **Prioridade:** P1
- **SLA:** < 30 minutos

### **Exemplo 2: Phishing bem-sucedido**
- **Categoria:** Phishing/Social Engineering
- **Severidade:** Alto (credenciais comprometidas)
- **Impacto:** Médio (confidencialidade)
- **Urgência:** Alta (acesso não autorizado)
- **Prioridade:** P2
- **SLA:** < 1 hora

### **Exemplo 3: Defacement de site**
- **Categoria:** Defacement/Alteração
- **Severidade:** Médio (reputação afetada)
- **Impacto:** Médio (integridade)
- **Urgência:** Alta (visibilidade pública)
- **Prioridade:** P2
- **SLA:** < 1 hora

### **Exemplo 4: Tentativa de DDoS bloqueada**
- **Categoria:** DDoS
- **Severidade:** Baixo (sem impacto)
- **Impacto:** Baixo (tentativa frustrada)
- **Urgência:** Normal (monitoramento)
- **Prioridade:** P3
- **SLA:** < 4 horas

---

## 🔄 Processo de Reclassificação

### **Quando Reclassificar:**
- Novas evidências encontradas
- Escopo do incidente expandido
- Impacto maior que inicialmente avaliado
- Mudança no status de contenção

### **Critérios para Upgrade:**
- Sistemas críticos adicionais afetados
- Exposição de dados maior que estimada
- Repercussão externa negativa
- Violação regulatória confirmada

### **Critérios para Downgrade:**
- Incidente contido com sucesso
- Impacto menor que inicialmente estimado
- Dados não foram realmente expostos
- Falso positivo confirmado

---

## 📝 Formulário de Classificação

```markdown
## CLASSIFICAÇÃO DE INCIDENTE

**ID do Incidente:** INC-YYYY-NNNN
**Data/Hora:** DD/MM/YYYY HH:MM
**Classificador:** [Nome]

### CATEGORIA
[ ] Malware
[ ] Phishing/Social Engineering  
[ ] DDoS
[ ] Data Breach/Exfiltração
[ ] Comprometimento de Conta
[ ] Defacement/Alteração
[ ] APT
[ ] Insider Threat
[ ] Outro: ________________

### SEVERIDADE
[ ] Crítico
[ ] Alto
[ ] Médio
[ ] Baixo

### IMPACTO
**Confidencialidade:** [ ] Alto [ ] Médio [ ] Baixo
**Integridade:** [ ] Alto [ ] Médio [ ] Baixo  
**Disponibilidade:** [ ] Alto [ ] Médio [ ] Baixo

### URGÊNCIA
[ ] Imediata (< 30 min)
[ ] Alta (< 1 hora)
[ ] Normal (< 4 horas)
[ ] Baixa (< 8 horas)

### PRIORIDADE CALCULADA
[ ] P1 - Imediata
[ ] P2 - Alta
[ ] P3 - Normal
[ ] P4 - Baixa

### JUSTIFICATIVA
[Explicar os critérios usados para classificação]

### PRÓXIMAS AÇÕES
[Definir ações imediatas baseadas na classificação]
```

---

**🎯 Esta matriz garante classificação consistente e resposta adequada a cada tipo de incidente de segurança!**
