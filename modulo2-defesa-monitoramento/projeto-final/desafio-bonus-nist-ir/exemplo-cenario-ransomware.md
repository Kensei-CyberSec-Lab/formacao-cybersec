# 🔐 Exemplo: Plano de Resposta - Ataque Ransomware

> **Este é um exemplo de como desenvolver o plano para o Cenário A**  
> **Use como referência para criar seu próprio plano completo**

---

## 🎯 Cenário A: Ataque de Ransomware

### **Situação**
Segunda-feira, 08:30h. A empresa TechCorp (500 funcionários, setor tecnologia) teve vários sistemas criptografados durante a madrugada. Funcionários reportam arquivos inacessíveis e notas de resgate aparecendo em suas telas.

### **Indicadores Detectados**
- ✅ Arquivos com extensão `.locked`
- ✅ Nota de resgate: `README_FOR_DECRYPT.txt`
- ✅ Servidores de arquivo inacessíveis
- ✅ Logs mostram login RDP suspeito às 02:30h
- ✅ Processo `encrypt.exe` detectado no EDR

---

## 🔍 FASE 2: DETECÇÃO E ANÁLISE - EXEMPLO

### **2.1 Validação Inicial (< 15 min)**

```bash
# Verificar sistemas afetados
ping fileserver01.techcorp.local
ping database01.techcorp.local

# Verificar processos suspeitos
Get-Process | Where-Object {$_.ProcessName -like "*encrypt*"}

# Listar arquivos criptografados
Get-ChildItem -Path "C:\\" -Recurse -Filter "*.locked" | Select-Object FullName
```

### **2.2 Classificação do Incidente**
- **Severidade:** 🔴 **CRÍTICA**
- **Impacto:** Disponibilidade (sistemas indisponíveis)
- **Categoria:** Malware - Ransomware
- **Urgência:** 🚨 **IMEDIATA**

### **2.3 Escalação Ativada**
- ⏰ **08:35h** - Coordenador CSIRT ativado
- ⏰ **08:45h** - Equipe completa mobilizada
- ⏰ **09:00h** - CEO e diretoria notificados

---

## ⚡ FASE 3: CONTENÇÃO - EXEMPLO

### **3.1 Contenção Imediata (< 1 hora)**

#### **Isolamento de Rede**
```bash
# Isolar sistemas comprometidos
iptables -A INPUT -s 192.168.1.0/24 -j DROP
iptables -A OUTPUT -d 192.168.1.0/24 -j DROP

# Desabilitar conexões RDP
netsh advfirewall firewall set rule group="remote desktop" new enable=No
```

#### **Preservação de Evidências**
```bash
# Capturar memória RAM
winpmem_mini_x64.exe physmem.raw

# Capturar logs críticos
wevtutil epl System C:\forensics\System.evtx
wevtutil epl Security C:\forensics\Security.evtx
```

#### **Checklist de Contenção Executado**
- ✅ **09:15h** - Sistemas afetados isolados da rede
- ✅ **09:20h** - RDP desabilitado em toda a rede
- ✅ **09:25h** - Backup de logs realizado
- ✅ **09:30h** - Snapshots de VMs comprometidas
- ✅ **09:35h** - Comunicação inicial às equipes

### **3.2 Identificação do Ransomware**

#### **Análise da Nota de Resgate**
```
=== SEUS ARQUIVOS FORAM CRIPTOGRAFADOS ===

Olá TechCorp!

Todos os seus arquivos importantes foram criptografados com algoritmo militar AES-256.
Você tem 72 horas para pagar o resgate de 10 Bitcoins (~$300,000 USD).

Para recuperar seus arquivos:
1. Baixe o navegador TOR
2. Acesse: http://[endereço-onion].onion
3. Use o ID: TECHCORP-2024-8847

NÃO tente descriptografar por conta própria!
NÃO contate autoridades!
NÃO desligue os computadores!

Tempo restante: 71:42:15
```

#### **Identificação da Família**
- **Ransomware:** LockBit 3.0 (baseado na nota e extensão)
- **Método:** RDP brute force + exploração de vulnerabilidade
- **Criptografia:** AES-256 + RSA-2048 (não descriptografável)

---

## 🛡️ FASE 3: ERRADICAÇÃO E RECUPERAÇÃO - EXEMPLO

### **3.3 Erradicação (< 4 horas)**

#### **Remoção do Malware**
```bash
# Verificar persistência
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"

# Remover arquivos maliciosos
Get-ChildItem -Path "C:\\" -Recurse -Filter "encrypt.exe" | Remove-Item -Force

# Limpar tarefas agendadas
Get-ScheduledTask | Where-Object {$_.TaskName -like "*encrypt*"} | Unregister-ScheduledTask
```

#### **Correção de Vulnerabilidades**
- ✅ **11:00h** - Patch do Windows Server aplicado
- ✅ **11:30h** - RDP configurado com 2FA obrigatório
- ✅ **12:00h** - Senhas de admin alteradas
- ✅ **12:30h** - Firewall reconfigurado

### **3.4 Recuperação (< 8 horas)**

#### **Restauração via Backup**
```bash
# Verificar integridade dos backups
rclone check backup-server:/techcorp/2024-03-15 /mnt/restore/

# Restaurar sistemas críticos (Prioridade 1)
restore-vm fileserver01 --snapshot "2024-03-15-23:00"
restore-vm database01 --snapshot "2024-03-15-23:00"
```

#### **Timeline de Recuperação**
- ✅ **13:00h** - Servidor de arquivos restaurado
- ✅ **14:30h** - Banco de dados restaurado e validado
- ✅ **15:00h** - Workstations principais restauradas
- ✅ **16:00h** - Rede corporativa reestabelecida
- ✅ **17:00h** - Operações normais retomadas

### **3.5 Validação da Recuperação**
- ✅ Todos os sistemas funcionando normalmente
- ✅ Performance dentro dos parâmetros
- ✅ Dados íntegros (última verificação às 23:00h do dia anterior)
- ✅ Usuários conseguem acessar sistemas
- ✅ Malware erradicado (confirmed por scan completo)

---

## 📊 FASE 4: ATIVIDADES PÓS-INCIDENTE - EXEMPLO

### **4.1 Métricas Finais**

| Métrica | Valor Alcançado | Meta | Status |
|---------|-----------------|------|--------|
| **MTTD** | 30 minutos | < 1 hora | ✅ |
| **MTTR** | 45 minutos | < 1 hora | ✅ |
| **MTTR** | 8,5 horas | < 12 horas | ✅ |
| **Downtime** | 8,5 horas | < 12 horas | ✅ |

### **4.2 Impacto Financeiro**

| Item | Valor |
|------|-------|
| **Receita Perdida** | R$ 85.000 (8,5h parado) |
| **Custos de Resposta** | R$ 15.000 (equipe + consultores) |
| **Custos de Recuperação** | R$ 5.000 (infraestrutura) |
| **Total** | R$ 105.000 |
| **Resgate NÃO PAGO** | R$ 1.500.000 ECONOMIZADOS |

### **4.3 Lições Aprendidas**

#### **✅ O que funcionou bem:**
- Detecção rápida via EDR
- Equipe CSIRT bem treinada
- Backups íntegros e atualizados
- Procedimentos de isolamento eficazes
- Comunicação clara e transparente

#### **⚠️ O que precisa melhorar:**
- RDP exposto sem 2FA
- Patches de segurança atrasados
- Monitoramento 24/7 limitado
- Treinamento de usuários insuficiente
- Testes de restauração pouco frequentes

#### **🔧 Recomendações Implementadas:**

1. **Prevenção:**
   - ✅ 2FA obrigatório em todos os acessos remotos
   - ✅ Gestão de patches automatizada
   - ✅ VPN corporativa para acesso remoto

2. **Detecção:**
   - ✅ SOC 24/7 terceirizado contratado
   - ✅ Alertas de ransomware no SIEM
   - ✅ Monitoramento de comportamento anômalo

3. **Resposta:**
   - ✅ Playbook de ransomware atualizado
   - ✅ Treinamento trimestral da equipe
   - ✅ Simulados mensais de resposta

### **4.4 Comunicação Pós-Incidente**

#### **Comunicação Interna (17:30h)**
```
ASSUNTO: Resolução do Incidente de Segurança - Operações Normalizadas

Prezados colaboradores,

Informamos que o incidente de segurança detectado na manhã de hoje foi 
completamente resolvido. Todos os sistemas estão funcionando normalmente
e nenhum dado foi perdido.

Medidas adicionais de segurança foram implementadas e continuamos 
monitorando ativamente nossa infraestrutura.

Agradecemos a paciência de todos durante este período.

Atenciosamente,
Equipe de TI e Segurança
```

#### **Relatório Executivo (18:00h)**
Enviado para CEO, diretoria e board com:
- Resumo executivo do incidente
- Impacto financeiro e operacional
- Medidas implementadas
- Próximos passos

---

## 🔍 Análise Forense Detalhada

### **Vetor de Ataque Identificado**
1. **02:15h** - Ataque de força bruta em RDP (IP: 185.220.101.45)
2. **02:28h** - Login bem-sucedido (user: backup_admin)
3. **02:30h** - Download do ransomware via PowerShell
4. **02:35h** - Execução inicial em fileserver01
5. **02:45h** - Propagação lateral via SMB
6. **03:00h** - Início da criptografia de arquivos

### **IOCs (Indicators of Compromise)**
```
# IPs maliciosos
185.220.101.45 (origem do ataque)
194.169.175.22 (C&C server)

# Hashes SHA256
encrypt.exe: 8f14e45fceea167a5a36dedd4bea2543ef31d4b3e3c9b17a8b8c9e3f5d2a1b4c
launcher.ps1: 2c4a3b5e7f9d1a8c6e4b2f5a9c7e1d3f5b8a4c6e9f2d5a7c1e4b8f6a3d9c5e2

# Domínios
techcorp-decrypt[.]onion
backup-urgent[.]com

# Artifacts
README_FOR_DECRYPT.txt
.locked (extension)
```

---

## 📋 Checklist Completo de Resposta

### **✅ Detecção e Análise**
- [x] Incidente validado e classificado
- [x] Equipe CSIRT ativada
- [x] Evidências iniciais coletadas
- [x] Escopo preliminar definido

### **✅ Contenção**
- [x] Sistemas comprometidos isolados
- [x] Propagação interrompida
- [x] Evidências preservadas
- [x] Stakeholders notificados

### **✅ Erradicação**
- [x] Malware removido
- [x] Vulnerabilidades corrigidas
- [x] Credenciais comprometidas alteradas
- [x] Sistemas endurecidos

### **✅ Recuperação**
- [x] Sistemas restaurados a partir de backups
- [x] Funcionalidade validada
- [x] Monitoramento intensificado
- [x] Operações normalizadas

### **✅ Pós-Incidente**
- [x] Relatório de incidente criado
- [x] Lições aprendidas documentadas
- [x] Melhorias implementadas
- [x] Comunicação finalizada

---

**🎯 Este exemplo demonstra um plano de resposta completo e realista. Use-o como base para desenvolver seu próprio plano, adaptando para o cenário específico escolhido!**
