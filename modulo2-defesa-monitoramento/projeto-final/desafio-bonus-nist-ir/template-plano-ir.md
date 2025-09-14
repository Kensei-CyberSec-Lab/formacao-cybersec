# 📋 Template: Plano de Resposta a Incidentes NIST

> **Cenário:** [Substitua pelo cenário escolhido: A, B ou C]  
> **Data:** [Data de criação do plano]  
> **Versão:** 1.0  
> **Responsável:** [Seu nome]

---

## 📊 Informações do Documento

| Campo | Valor |
|-------|--------|
| **Título** | Plano de Resposta a Incidentes - [Cenário] |
| **Classificação** | [Interno/Confidencial/Restrito] |
| **Aprovação** | [Nome do aprovador] |
| **Próxima Revisão** | [Data] |
| **Distribuição** | CSIRT, TI, Segurança, Jurídico |

---

## 🎯 Escopo e Objetivos

### **Escopo**
Este plano abrange a resposta a [tipo de incidente] em [tipo de organização], incluindo:
- [ ] Sistemas críticos afetados
- [ ] Dados envolvidos
- [ ] Stakeholders impactados
- [ ] Processos de negócio

### **Objetivos**
- [ ] Minimizar impacto operacional
- [ ] Preservar evidências para investigação
- [ ] Cumprir obrigações legais e regulatórias
- [ ] Restaurar operações normais rapidamente
- [ ] Prevenir recorrência do incidente

---

## 🏢 Contexto Organizacional

### **Perfil da Organização**
- **Setor:** [Ex: Financeiro, Saúde, E-commerce]
- **Porte:** [Ex: 500 funcionários, 10 filiais]
- **Receita:** [Ex: R$ 100M anuais]
- **Dados Críticos:** [Ex: PII, PHI, Cartões de crédito]

### **Infraestrutura Tecnológica**
- **Sistemas Críticos:** [Liste os principais]
- **Fornecedores:** [Cloud providers, terceirizados]
- **Compliance:** [LGPD, PCI-DSS, ISO 27001]

---

## 📞 Equipe de Resposta a Incidentes

### **CSIRT - Computer Security Incident Response Team**

| Função | Nome | Telefone | Email | Backup |
|--------|------|----------|-------|---------|
| **Coordenador CSIRT** | [Nome] | [Telefone] | [Email] | [Nome Backup] |
| **Líder Técnico** | [Nome] | [Telefone] | [Email] | [Nome Backup] |
| **Analista Forense** | [Nome] | [Telefone] | [Email] | [Nome Backup] |
| **Especialista em Redes** | [Nome] | [Telefone] | [Email] | [Nome Backup] |
| **Representante Jurídico** | [Nome] | [Telefone] | [Email] | [Nome Backup] |
| **Comunicação** | [Nome] | [Telefone] | [Email] | [Nome Backup] |

### **Stakeholders Externos**
- **Autoridades:** Polícia Civil/Federal, ANPD
- **Fornecedores:** [Cloud providers, consultores]
- **Clientes:** [Representantes de clientes importantes]
- **Mídia:** [Assessoria de imprensa]

---

## 🔴 FASE 1: PREPARAÇÃO

### **1.1 Políticas e Procedimentos**
- [ ] Política de Segurança da Informação aprovada
- [ ] Procedimentos de backup e recuperação testados
- [ ] Plano de Continuidade de Negócios atualizado
- [ ] Contratos com fornecedores incluem cláusulas de segurança

### **1.2 Ferramentas e Recursos**
- [ ] **SIEM:** [Ex: Splunk, QRadar, ELK Stack]
- [ ] **Análise Forense:** [Ex: Volatility, Autopsy, FTK]
- [ ] **Comunicação:** [Ex: Slack, Teams, PagerDuty]
- [ ] **Monitoramento:** [Ex: Nagios, Zabbix, Datadog]

### **1.3 Treinamento e Conscientização**
- [ ] Equipe CSIRT treinada trimestralmente
- [ ] Simulados de resposta a incidentes semestrais
- [ ] Funcionários treinados em identificação de ameaças
- [ ] Procedimentos de escalação conhecidos por todos

### **1.4 Métricas e Indicadores**
- **MTTD (Mean Time to Detection):** [Ex: < 30 minutos]
- **MTTR (Mean Time to Response):** [Ex: < 1 hora]
- **MTTR (Mean Time to Recovery):** [Ex: < 4 horas]
- **RTO (Recovery Time Objective):** [Ex: < 8 horas]

---

## 🔍 FASE 2: DETECÇÃO E ANÁLISE

### **2.1 Indicadores de Comprometimento (IoCs)**

#### **Cenário Específico: [Detalhe os IoCs do seu cenário]**
- [ ] [Indicador 1 - Ex: Arquivos .encrypted]
- [ ] [Indicador 2 - Ex: Conexões para IPs maliciosos]
- [ ] [Indicador 3 - Ex: Processos suspeitos]
- [ ] [Indicador 4 - Ex: Tráfego anômalo]

### **2.2 Fontes de Detecção**
- [ ] **Logs de Sistema:** Windows Event Logs, Syslog
- [ ] **Logs de Rede:** Firewall, IPS/IDS, DNS
- [ ] **Logs de Aplicação:** Web servers, Databases
- [ ] **Usuários:** Relatos de funcionários/clientes
- [ ] **Terceiros:** Threat intelligence, fornecedores

### **2.3 Processo de Análise Inicial**

#### **Passo 1: Validação do Incidente (< 15 min)**
```bash
# Comandos para verificação inicial
[Adicione comandos específicos do cenário]
```

#### **Passo 2: Classificação (< 30 min)**
- **Severidade:** [Crítico/Alto/Médio/Baixo]
- **Impacto:** [Confidencialidade/Integridade/Disponibilidade]
- **Categoria:** [Malware/Phishing/DDoS/Data Breach/etc]
- **Urgência:** [Imediata/Alta/Normal/Baixa]

#### **Passo 3: Coleta de Evidências Iniciais**
- [ ] Screenshots de alertas/sistemas afetados
- [ ] Logs relevantes preservados
- [ ] Memória RAM capturada (se aplicável)
- [ ] Tráfego de rede capturado
- [ ] Depoimentos iniciais coletados

### **2.4 Escalação e Ativação**

#### **Critérios de Escalação**
- [ ] Impacto em sistemas críticos
- [ ] Exposição de dados sensíveis
- [ ] Paralisação de operações
- [ ] Repercussão midiática potencial
- [ ] Valor financeiro envolvido > R$ [valor]

#### **Processo de Ativação do CSIRT**
1. **Detecção inicial** → Analista de plantão
2. **Validação** → Líder técnico (< 15 min)
3. **Escalação** → Coordenador CSIRT (< 30 min)
4. **Ativação completa** → Toda a equipe (< 1 hora)

---

## ⚡ FASE 3: CONTENÇÃO, ERRADICAÇÃO E RECUPERAÇÃO

### **3.1 Contenção Imediata (< 1 hora)**

#### **Objetivos**
- [ ] Parar a propagação do incidente
- [ ] Preservar evidências
- [ ] Manter sistemas críticos funcionando
- [ ] Minimizar impacto nos negócios

#### **Ações de Contenção - [Cenário Específico]**
```bash
# Comandos de contenção específicos
[Adicione comandos específicos do seu cenário]
```

**Checklist de Contenção:**
- [ ] [Ação específica 1]
- [ ] [Ação específica 2]
- [ ] [Ação específica 3]
- [ ] [Ação específica 4]
- [ ] Comunicação às partes interessadas
- [ ] Documentação das ações realizadas

### **3.2 Coleta de Evidências Forenses**

#### **Ordem de Volatilidade (RFC 3227)**
1. **Memória RAM** → Mais volátil
2. **Estado do sistema** → Processos, conexões
3. **Disco rígido** → Arquivos, logs
4. **Logs remotos** → SIEM, syslog
5. **Configurações** → Menos volátil

#### **Procedimentos de Coleta**
```bash
# Exemplo de comandos forenses
[Adicione comandos específicos de coleta]
```

### **3.3 Erradicação (< 4 horas)**

#### **Identificação da Causa Raiz**
- [ ] Vetor de ataque identificado
- [ ] Vulnerabilidade explorada mapeada
- [ ] Timeline de comprometimento estabelecida
- [ ] Extensão do comprometimento avaliada

#### **Ações de Erradicação**
- [ ] [Ação específica 1 - Ex: Remoção de malware]
- [ ] [Ação específica 2 - Ex: Correção de vulnerabilidade]
- [ ] [Ação específica 3 - Ex: Revogação de credenciais]
- [ ] [Ação específica 4 - Ex: Atualização de sistemas]

### **3.4 Recuperação (< 8 horas)**

#### **Plano de Recuperação**
1. **Sistemas Críticos** (Prioridade 1)
   - [ ] [Sistema crítico 1]
   - [ ] [Sistema crítico 2]

2. **Sistemas Importantes** (Prioridade 2)
   - [ ] [Sistema importante 1]
   - [ ] [Sistema importante 2]

3. **Sistemas Auxiliares** (Prioridade 3)
   - [ ] [Sistema auxiliar 1]
   - [ ] [Sistema auxiliar 2]

#### **Validação da Recuperação**
- [ ] Funcionalidade restaurada
- [ ] Performance normal
- [ ] Conectividade verificada
- [ ] Dados íntegros
- [ ] Usuários conseguem acessar

---

## 📝 FASE 4: ATIVIDADES PÓS-INCIDENTE

### **4.1 Relatório de Incidente**

#### **Resumo Executivo**
- **Tipo de Incidente:** [Descrição breve]
- **Data/Hora:** [Início e fim do incidente]
- **Duração:** [Tempo total]
- **Sistemas Afetados:** [Lista dos sistemas]
- **Impacto:** [Descrição do impacto]
- **Custo Estimado:** [Valor financeiro]

#### **Timeline Detalhada**
| Timestamp | Evento | Responsável | Evidência |
|-----------|--------|-------------|-----------|
| [HH:MM] | [Descrição do evento] | [Nome] | [Link/referência] |

### **4.2 Lições Aprendidas**

#### **O que funcionou bem?**
- [ ] [Aspecto positivo 1]
- [ ] [Aspecto positivo 2]
- [ ] [Aspecto positivo 3]

#### **O que precisa melhorar?**
- [ ] [Ponto de melhoria 1]
- [ ] [Ponto de melhoria 2]
- [ ] [Ponto de melhoria 3]

#### **Recomendações**
1. **Prevenção:**
   - [ ] [Recomendação preventiva 1]
   - [ ] [Recomendação preventiva 2]

2. **Detecção:**
   - [ ] [Melhoria na detecção 1]
   - [ ] [Melhoria na detecção 2]

3. **Resposta:**
   - [ ] [Melhoria na resposta 1]
   - [ ] [Melhoria na resposta 2]

### **4.3 Plano de Ação**

| Ação | Responsável | Prazo | Status |
|------|-------------|-------|--------|
| [Ação 1] | [Nome] | [Data] | [Pendente/Em andamento/Concluído] |
| [Ação 2] | [Nome] | [Data] | [Pendente/Em andamento/Concluído] |

### **4.4 Métricas do Incidente**

| Métrica | Valor | Meta | Status |
|---------|-------|------|--------|
| **MTTD** | [tempo] | [meta] | [✅/❌] |
| **MTTR** | [tempo] | [meta] | [✅/❌] |
| **MTTR** | [tempo] | [meta] | [✅/❌] |
| **Downtime** | [tempo] | [meta] | [✅/❌] |

---

## 📞 Comunicação

### **Comunicação Interna**
- [ ] CEO/Diretoria notificada
- [ ] TI notificado
- [ ] RH notificado (se aplicável)
- [ ] Jurídico notificado
- [ ] Auditoria notificada

### **Comunicação Externa**
- [ ] Autoridades notificadas (se requerido)
- [ ] Clientes notificados (se aplicável)
- [ ] Fornecedores notificados (se aplicável)
- [ ] Seguradoras notificadas
- [ ] Mídia (se necessário)

### **Templates de Comunicação**
- [Link para template de comunicação interna]
- [Link para template de comunicação externa]
- [Link para template de notificação regulatória]

---

## ⚖️ Considerações Legais e Regulatórias

### **LGPD (Lei Geral de Proteção de Dados)**
- [ ] Incidente envolve dados pessoais?
- [ ] Notificação à ANPD necessária? (72 horas)
- [ ] Notificação aos titulares necessária?
- [ ] Registro no relatório de impacto

### **Outras Regulamentações**
- [ ] [Regulamentação específica do setor]
- [ ] [Padrão de compliance aplicável]
- [ ] [Certificação que pode ser impactada]

---

## 📚 Anexos

### **A. Procedimentos Técnicos Detalhados**
- [Link para playbook de contenção]
- [Link para playbook de análise forense]
- [Link para playbook de recuperação]

### **B. Formulários e Checklists**
- [Link para formulário de relato de incidente]
- [Link para checklist de contenção]
- [Link para log de ações]

### **C. Contatos de Emergência**
- [Lista completa de contatos]
- [Procedimentos de escalação 24/7]

### **D. Ferramentas e Recursos**
- [Lista de ferramentas disponíveis]
- [Credenciais de acesso (referência segura)]
- [Documentação técnica]

---

## 📝 Controle de Versões

| Versão | Data | Autor | Alterações |
|--------|------|-------|------------|
| 1.0 | [Data] | [Nome] | Versão inicial |

---

**🔒 Este documento contém informações sensíveis de segurança. Distribua apenas para pessoal autorizado.**
