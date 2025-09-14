# ⚡ Playbook: Contenção de Incidentes

Este playbook fornece procedimentos técnicos específicos para contenção imediata de diferentes tipos de incidentes de segurança.

---

## 🎯 Objetivos da Contenção

1. **Parar a propagação** do incidente
2. **Preservar evidências** para análise forense
3. **Minimizar o impacto** operacional
4. **Manter sistemas críticos** funcionando
5. **Preparar para erradicação** e recuperação

---

## 🦠 Contenção de Malware/Ransomware

### **⚡ Ações Imediatas (< 30 min)**

#### **1. Isolamento de Rede**
```bash
# Windows - Desabilitar adaptadores de rede
netsh interface set interface "Ethernet" admin=disable
netsh interface set interface "Wi-Fi" admin=disable

# Linux - Bloquear tráfego
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# Manter apenas SSH para administração remota
iptables -A INPUT -p tcp --dport 22 -s [IP_ADMIN] -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -d [IP_ADMIN] -j ACCEPT
```

#### **2. Identificação de Sistemas Comprometidos**
```bash
# Verificar processos suspeitos
Get-Process | Where-Object {$_.CPU -gt 50} | Sort-Object CPU -Descending

# Listar conexões de rede ativas
netstat -antb | findstr ESTABLISHED

# Verificar arquivos recentemente modificados
Get-ChildItem -Path "C:\" -Recurse | Where-Object {$_.LastWriteTime -gt (Get-Date).AddHours(-2)}

# Procurar por arquivos criptografados (ransomware)
Get-ChildItem -Path "C:\" -Recurse -Filter "*.*" | Where-Object {$_.Extension -match "\.(locked|encrypted|crypto|encode)$"}
```

#### **3. Preservação de Evidências**
```bash
# Capturar memória RAM (Windows)
winpmem_mini_x64.exe -o physmem.raw

# Capturar logs do sistema
wevtutil epl System C:\forensics\System_$(Get-Date -f yyyyMMdd-HHmm).evtx
wevtutil epl Security C:\forensics\Security_$(Get-Date -f yyyyMMdd-HHmm).evtx
wevtutil epl Application C:\forensics\Application_$(Get-Date -f yyyyMMdd-HHmm).evtx

# Capturar tráfego de rede
tcpdump -i any -w /forensics/network_$(date +%Y%m%d-%H%M).pcap &

# Snapshot de VM (se aplicável)
vmware-cmd [path/to/vm.vmx] createsnapshot "incident_$(date +%Y%m%d-%H%M)" "Pre-remediation snapshot"
```

#### **4. Contenção Específica para Ransomware**
```bash
# Desconectar backups online
net stop "Veeam Backup Service"
net stop "Windows Backup Service"

# Desabilitar Volume Shadow Copy (impedir destruição)
vssadmin list shadows
# NÃO executar comandos de limpeza que o ransomware pode tentar

# Proteger Domain Controllers
# Isolar DCs da rede geral, manter apenas comunicação entre DCs
```

### **📋 Checklist de Contenção - Malware**
- [ ] ⏰ **Timestamp:** [HH:MM] - Incidente confirmado
- [ ] 🔌 **Isolamento:** Sistemas comprometidos desconectados
- [ ] 💾 **Evidências:** Memória e logs capturados
- [ ] 📸 **Snapshots:** VMs preservadas
- [ ] 🛡️ **Proteção:** Backups e DCs protegidos
- [ ] 📞 **Comunicação:** Equipe e stakeholders notificados
- [ ] 📝 **Documentação:** Ações registradas

---

## 🎣 Contenção de Phishing/Compromisso de Email

### **⚡ Ações Imediatas (< 30 min)**

#### **1. Isolamento da Conta Comprometida**
```powershell
# Office 365/Exchange Online
Connect-ExchangeOnline
Set-Mailbox -Identity "usuario@empresa.com" -AccountDisabled $true
Set-CASMailbox -Identity "usuario@empresa.com" -OWAEnabled $false -ActiveSyncEnabled $false

# Revogar tokens de autenticação
Revoke-AzureADUserAllRefreshToken -ObjectId [User-ObjectID]

# Exchange On-Premises
Disable-Mailbox -Identity "usuario@empresa.com"
```

#### **2. Análise de Emails Maliciosos**
```powershell
# Buscar emails suspeitos
Get-MessageTrace -SenderAddress "atacante@malicioso.com" -StartDate (Get-Date).AddDays(-7)

# Listar emails enviados pela conta comprometida
Get-MessageTrace -SenderAddress "usuario@empresa.com" -StartDate (Get-Date).AddHours(-24)

# Verificar regras de encaminhamento suspeitas
Get-InboxRule -Mailbox "usuario@empresa.com"
```

#### **3. Contenção de Propagação**
```powershell
# Remover emails maliciosos de todas as caixas postais
New-ComplianceSearch -Name "PhishingRemoval" -ExchangeLocation All -ContentMatchQuery "Subject:'Urgent Payment Required'"
Start-ComplianceSearch -Identity "PhishingRemoval"
# Após conclusão da busca:
New-ComplianceSearchAction -SearchName "PhishingRemoval" -Purge -PurgeType SoftDelete

# Bloquear sender externo
New-TransportRule -Name "Block-Phishing-Sender" -SenderAddressContainsWords "atacante@malicioso.com" -DeleteMessage $true
```

### **📋 Checklist de Contenção - Phishing**
- [ ] ⏰ **Timestamp:** [HH:MM] - Phishing confirmado
- [ ] 🚫 **Conta Bloqueada:** Acesso da conta comprometida revogado
- [ ] 🔍 **Emails Localizados:** Mensagens maliciosas identificadas
- [ ] 🗑️ **Remoção:** Emails maliciosos removidos das caixas
- [ ] 🚧 **Bloqueio:** Sender malicioso bloqueado
- [ ] 🔑 **Credenciais:** Senhas alteradas
- [ ] 📞 **Usuários:** Afetados notificados

---

## 💥 Contenção de DDoS

### **⚡ Ações Imediatas (< 30 min)**

#### **1. Análise de Tráfego**
```bash
# Verificar conexões ativas
netstat -an | grep :80 | wc -l
netstat -an | grep :443 | wc -l

# Top IPs conectando
netstat -an | grep :80 | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -nr | head -20

# Monitorar largura de banda
iftop -i eth0
nethogs
```

#### **2. Filtragem Imediata**
```bash
# Bloquear IPs com mais de 100 conexões
netstat -an | grep :80 | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | awk '$1 > 100 {print $2}' > /tmp/block_ips.txt

# Aplicar bloqueios via iptables
while read ip; do
    iptables -A INPUT -s $ip -j DROP
done < /tmp/block_ips.txt

# Rate limiting
iptables -A INPUT -p tcp --dport 80 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j DROP
```

#### **3. Ativação de Mitigação**
```bash
# Cloudflare - Ativar "I'm Under Attack Mode"
curl -X PATCH "https://api.cloudflare.com/client/v4/zones/[ZONE_ID]/settings/security_level" \
     -H "Authorization: Bearer [API_TOKEN]" \
     -H "Content-Type: application/json" \
     --data '{"value":"under_attack"}'

# AWS - Ativar AWS Shield Advanced (se disponível)
aws shield subscribe-to-proactive-engagement
```

### **📋 Checklist de Contenção - DDoS**
- [ ] ⏰ **Timestamp:** [HH:MM] - DDoS detectado
- [ ] 📊 **Análise:** Tráfego analisado e padrões identificados
- [ ] 🚫 **Bloqueios:** IPs maliciosos bloqueados
- [ ] ⚡ **Rate Limiting:** Limitação de taxa implementada
- [ ] ☁️ **CDN/WAF:** Proteção em nuvem ativada
- [ ] 📈 **Monitoramento:** Dashboards de tráfego ativos
- [ ] 📞 **ISP:** Provedor notificado (se necessário)

---

## 🗃️ Contenção de Data Breach

### **⚡ Ações Imediatas (< 30 min)**

#### **1. Isolamento da Vulnerabilidade**
```bash
# Web Application - Bloquear exploração
# Exemplo para SQLi
iptables -A INPUT -p tcp --dport 80 -m string --string "UNION SELECT" --algo bm -j DROP
iptables -A INPUT -p tcp --dport 80 -m string --string "OR 1=1" --algo bm -j DROP

# Desabilitar aplicação temporariamente
systemctl stop apache2
systemctl stop nginx

# Banco de dados - Isolar servidor
iptables -A INPUT -p tcp --dport 3306 ! -s [IP_APLICACAO] -j DROP
```

#### **2. Preservação de Evidências**
```bash
# Capturar logs de aplicação
cp /var/log/apache2/access.log /forensics/access_$(date +%Y%m%d-%H%M).log
cp /var/log/apache2/error.log /forensics/error_$(date +%Y%m%d-%H%M).log

# Logs de banco de dados
mysqldump --routines --triggers --all-databases > /forensics/mysql_backup_$(date +%Y%m%d-%H%M).sql

# Capturar queries suspeitas
mysql -e "SELECT * FROM mysql.general_log WHERE command_type='Query' AND argument LIKE '%UNION%' ORDER BY event_time DESC LIMIT 100;" > /forensics/suspicious_queries.txt
```

#### **3. Avaliação de Exposição**
```sql
-- Verificar dados acessados
SELECT table_name, table_rows 
FROM information_schema.tables 
WHERE table_schema = 'production';

-- Logs de acesso a dados sensíveis
SELECT * FROM audit_log 
WHERE table_name IN ('users', 'credit_cards', 'personal_data') 
AND action = 'SELECT' 
AND timestamp > DATE_SUB(NOW(), INTERVAL 24 HOUR);
```

### **📋 Checklist de Contenção - Data Breach**
- [ ] ⏰ **Timestamp:** [HH:MM] - Breach confirmado
- [ ] 🔌 **Aplicação:** Aplicação vulnerável isolada/desligada
- [ ] 🗄️ **Banco:** Base de dados protegida
- [ ] 💾 **Evidências:** Logs e dados preservados
- [ ] 📊 **Avaliação:** Escopo da exposição mapeado
- [ ] ⚖️ **Jurídico:** Equipe legal notificada
- [ ] 📋 **Compliance:** Órgãos reguladores identificados

---

## 🔐 Contenção de Compromisso de Conta

### **⚡ Ações Imediatas (< 30 min)**

#### **1. Desabilitação Imediata**
```powershell
# Active Directory
Disable-ADAccount -Identity "usuario.comprometido"
Set-ADUser -Identity "usuario.comprometido" -ChangePasswordAtLogon $true

# Revogar sessões ativas
Get-ADUser "usuario.comprometido" | Set-ADUser -Replace @{userAccountControl=514}

# Office 365
Set-MsolUser -UserPrincipalName "usuario@empresa.com" -BlockCredential $true
Revoke-AzureADUserAllRefreshToken -ObjectId [User-ObjectID]
```

#### **2. Análise de Atividade**
```powershell
# Logs de logon
Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4624,4625; StartTime=(Get-Date).AddHours(-24)} | 
Where-Object {$_.Properties[5].Value -eq "usuario.comprometido"}

# Atividades suspeitas no AD
Search-ADAccount -AccountDisabled -UsersOnly | Where-Object {$_.SamAccountName -eq "usuario.comprometido"}

# Verificar grupos de segurança
Get-ADUser "usuario.comprometido" -Properties MemberOf | Select-Object -ExpandProperty MemberOf
```

#### **3. Contenção de Acesso Lateral**
```powershell
# Verificar outros sistemas acessados
# Logs de RDP
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-TerminalServices-LocalSessionManager/Operational'; ID=21,23,24,25} | 
Where-Object {$_.Properties[0].Value -eq "usuario.comprometido"}

# Verificar tokens/tickets Kerberos
klist tickets
# Purgar tickets se necessário
klist purge
```

### **📋 Checklist de Contenção - Compromisso de Conta**
- [ ] ⏰ **Timestamp:** [HH:MM] - Compromisso confirmado
- [ ] 🚫 **Conta Desabilitada:** Acesso imediatamente revogado
- [ ] 🎫 **Sessões:** Tokens e sessões invalidados
- [ ] 🔍 **Atividade:** Logs de atividade analisados
- [ ] 🏃 **Lateral Movement:** Acesso a outros sistemas verificado
- [ ] 👥 **Grupos:** Permissões e grupos auditados
- [ ] 🔑 **Credenciais:** Senhas alteradas

---

## 🌐 Contenção de Defacement

### **⚡ Ações Imediatas (< 30 min)**

#### **1. Isolamento do Site**
```bash
# Nginx - Redirecionar para página de manutenção
server {
    listen 80;
    server_name www.empresa.com;
    return 503;
}

# Apache - Desabilitar site
a2dissite www.empresa.com
systemctl reload apache2

# DNS - Apontar para página alternativa
# Alterar registros DNS para IP de servidor de backup
```

#### **2. Preservação de Evidências**
```bash
# Backup do site comprometido
tar -czf /forensics/website_compromised_$(date +%Y%m%d-%H%M).tar.gz /var/www/html/

# Capturar logs do servidor web
cp /var/log/apache2/access.log /forensics/
cp /var/log/apache2/error.log /forensics/

# Screenshot da página comprometida
wkhtmltoimage --width 1920 --height 1080 http://www.empresa.com /forensics/defacement_$(date +%Y%m%d-%H%M).png
```

#### **3. Análise de Comprometimento**
```bash
# Verificar arquivos modificados recentemente
find /var/www/html -type f -mtime -1 -ls

# Verificar uploads suspeitos
find /var/www/html -name "*.php" -o -name "*.jsp" -o -name "*.asp" | xargs grep -l "eval\|system\|exec"

# Verificar permissões alteradas
find /var/www/html -type f -perm 777 -ls
```

### **📋 Checklist de Contenção - Defacement**
- [ ] ⏰ **Timestamp:** [HH:MM] - Defacement detectado
- [ ] 🚫 **Site Isolado:** Website temporariamente indisponível
- [ ] 📸 **Evidências:** Screenshots e arquivos preservados
- [ ] 🔍 **Análise:** Método de comprometimento identificado
- [ ] 🌐 **DNS:** Tráfego redirecionado se necessário
- [ ] 📞 **Comunicação:** Stakeholders notificados
- [ ] 📝 **Documentação:** Impacto e timeline registrados

---

## 🕵️ Contenção de APT/Ameaça Persistente

### **⚡ Ações Imediatas (< 30 min)**

#### **1. Monitoramento Discreto**
```bash
# NÃO alertar o atacante - manter observação
# Capturar atividade sem interromper
tcpdump -i any -w /forensics/apt_activity_$(date +%Y%m%d-%H%M).pcap &

# Monitorar processos e conexões
while true; do
    netstat -antup >> /forensics/connections_$(date +%Y%m%d).log
    ps aux >> /forensics/processes_$(date +%Y%m%d).log
    sleep 60
done &
```

#### **2. Contenção Seletiva**
```bash
# Isolar sistemas críticos sem alertar
# Implementar honeypots para desviar atenção
# Alterar credenciais de contas não observadas pelo atacante

# Segmentação de rede silenciosa
iptables -A FORWARD -s [ATTACKER_IP] -d [CRITICAL_SUBNET] -j DROP
```

#### **3. Coleta de Intelligence**
```bash
# Capturar payloads e ferramentas
strings /proc/[PID]/exe > /forensics/malware_strings.txt
cp /proc/[PID]/exe /forensics/apt_binary_$(date +%Y%m%d-%H%M)

# Monitorar C&C communications
# Configurar proxy transparente para capturar tráfego
```

### **📋 Checklist de Contenção - APT**
- [ ] ⏰ **Timestamp:** [HH:MM] - APT identificado
- [ ] 👁️ **Monitoramento:** Observação discreta ativada
- [ ] 🛡️ **Proteção:** Sistemas críticos protegidos silenciosamente
- [ ] 🕵️ **Intelligence:** Coleta de TTPs e IOCs
- [ ] 🔗 **Comunicação:** C&C monitorado
- [ ] 👥 **Expertise:** Especialistas em APT acionados
- [ ] ⚖️ **Legal:** Autoridades apropriadas consultadas

---

## 📞 Comunicação Durante Contenção

### **Template de Comunicação Interna**
```
ASSUNTO: [CRÍTICO] Incidente de Segurança - Contenção em Andamento

RESUMO:
- Tipo: [Categoria do incidente]
- Severidade: [Nível]
- Status: CONTENÇÃO EM ANDAMENTO
- ETA Resolução: [Estimativa]

IMPACTO:
- Sistemas Afetados: [Lista]
- Usuários Impactados: [Número/Grupos]
- Serviços Indisponíveis: [Lista]

AÇÕES TOMADAS:
- [Ação 1 - HH:MM]
- [Ação 2 - HH:MM]
- [Ação 3 - HH:MM]

PRÓXIMAS ATUALIZAÇÕES: [Frequência]

Equipe CSIRT
```

### **Escalação de Contenção**
- **5 min:** Não foi possível isolar
- **15 min:** Propagação continua
- **30 min:** Sistemas críticos em risco
- **1 hora:** Contenção falhou

---

## 📊 Métricas de Contenção

### **KPIs Principais**
- **Time to Containment (TTC):** < 1 hora para P1
- **Containment Effectiveness:** > 95% de propagação bloqueada
- **Evidence Preservation:** 100% de evidências críticas preservadas
- **False Containment Rate:** < 5% de bloqueios desnecessários

### **Registro de Métricas**
```
Incidente: INC-YYYY-NNNN
Detecção: HH:MM
Início Contenção: HH:MM
Contenção Completa: HH:MM
TTC: [tempo]
Sistemas Isolados: [número]
Evidências Preservadas: [lista]
```

---

**⚡ Este playbook deve ser executado rapidamente, mas com precisão. Cada minuto conta na contenção efetiva de incidentes!**
