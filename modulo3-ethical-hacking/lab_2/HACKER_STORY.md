# 🎭 A História do Hacker: Enumeração Ativa de Serviços Web
## Lab 2: Descobrindo os Segredos dos Servidores Web

> *"OSINT revela o que está visível. Enumeração ativa descobre o que está escondido."* - Anônimo

---

## 🌅 A Continuação da Jornada

**7 da manhã. Alex acorda depois de poucas horas de sono.**

A investigação OSINT do Lab 1 havia revelado informações valiosas sobre a Acme Corp: subdomínios expostos, buckets S3 mal configurados, endpoints de API vazando credenciais, e uma página legacy (`http://old.acme-corp-lab.com/`) servindo como hub central desprotegido. Mas Alex sabia que aquilo era apenas a superfície.

*"OSINT me mostrou o que está público. Agora preciso entender o que está rodando DENTRO desses sistemas,"* pensou Alex, abrindo seu laptop e o arquivo `target_ips.txt` que havia criado na noite anterior.

A empresa havia autorizado um teste de penetração completo. Alex tinha em mãos uma lista de endereços IP autorizados — todos coletados durante a investigação OSINT:

```
IPs descobertos no Lab 1:
- 3.94.82.59 old.acme-corp-lab.com (página legacy)
- 34.207.53.34 (dev.acme-corp-lab.com - API de desenvolvimento)
- 54.152.245.201 (admin.acme-corp-lab.com - WordPress)
- IP do servidor www.acme-corp-lab.com (site principal)
```

Era hora de ir além do reconhecimento passivo e interagir diretamente com os sistemas web. Cada IP seria alvo de enumeração ativa: scan de portas, análise detalhada de serviços HTTP/HTTPS, enumeração de diretórios, banner grabbing, e análise de APIs.

*"Vamos ver o que esses servidores web realmente estão executando. Apache? Nginx? IIS? Que versões? Que tecnologias? Que endpoints estão expostos? Cada serviço conta uma história diferente sobre como a aplicação foi configurada."*

---

## 🎯 Objetivos do Aluno

Ao completar este laboratório, você será capaz de:

1. **Identificar serviços ativos** em servidores web usando scan de portas
2. **Enumerar serviços HTTP/HTTPS** para descobrir tecnologias e versões
3. **Analisar APIs** para descobrir endpoints e métodos expostos
4. **Realizar enumeração de diretórios** para descobrir arquivos sensíveis
5. **Executar banner grabbing** para identificar versões exatas de software
6. **Documentar achados** de forma profissional e estruturada
7. **Propor mitigações** baseadas em vulnerabilidades descobertas

---

## 🛠️ Ferramentas Permitidas

Este laboratório utiliza as seguintes ferramentas:

- **nmap** — Scanner de portas e serviços (versão e scripts NSE)
- **rustscan** — Scanner rápido de portas para identificação inicial
- **curl** — Cliente HTTP para requisições manuais e análise de headers
- **httpx** — Ferramenta para análise rápida de serviços HTTP/HTTPS
- **gobuster** — Enumeração de diretórios e arquivos web
- **nikto** — Scanner de vulnerabilidades web
- **netcat (nc)** — Ferramenta para banner grabbing manual
- **jq** — Processador JSON para análise de APIs
- **whatweb** — Identificação de tecnologias web

---

## 📋 Checklist de Entregáveis

Ao final deste laboratório, você deve ter os seguintes arquivos:

### Arquivos de Evidências

- `rustscan_<IP>.gnmap` — Resultado do scan rápido de portas
- `nmap_<IP>.txt` — Resultado do scan detalhado com versões
- `httpx_<IP>.txt` — Análise de serviços HTTP/HTTPS
- `whatweb_<IP>.txt` — Identificação de tecnologias web
- `gobuster_<IP>.txt` — Enumeração de diretórios e arquivos
- `curl_headers_<IP>.txt` — Headers HTTP detalhados
- `api_endpoints_<IP>.txt` — Endpoints de API descobertos
- `nikto_<IP>.txt` — Scan de vulnerabilidades web
- `banner_<IP>_<port>.txt` — Banners capturados manualmente

### Documentação

- `notes.md` — Documentação estruturada contendo:
  - **Resumo Executivo**: 3 achados principais com descrição clara
  - **Análise de Risco**: Classificação de severidade (baixa/média/alta/crítica)
  - **3 Recomendações de Mitigação**: Ações práticas e objetivas

### Estrutura de Diretórios

```
/home/kali/investigations/acme-corp/
├── results/
│   ├── <IP_1>/
│   │   ├── nmap_<IP_1>.txt
│   │   ├── httpx_<IP_1>.txt
│   │   ├── whatweb_<IP_1>.txt
│   │   ├── gobuster_<IP_1>.txt
│   │   └── ...
│   ├── <IP_2>/
│   │   └── ...
└── notes.md
```

---

## 🔬 Preparando o Ambiente

### "Organização é a chave para um trabalho eficiente"

Alex sempre começava criando uma estrutura organizada. Isso facilitaria a análise posterior e garantiria que nenhuma evidência fosse perdida.

```bash
# Acessar o contêiner Kali
docker exec -it kensei_kali /bin/bash

# Navegar para o workspace da investigação (criado no Lab 1)
cd /home/kali/investigations/acme-corp

# Verificar se o arquivo target_ips.txt existe (do Lab 1)
ls -la target_ips.txt

# Criar estrutura de diretórios para os resultados do Lab 2
mkdir -p results
```

**Nota:** Se você está começando direto no Lab 2 sem ter feito o Lab 1, crie o arquivo `target_ips.txt` com os IPs autorizados fornecidos pelo instrutor.

#### Coletando IPs da Página old.acme-corp-lab.com

Alex precisava dos IPs reais dos servidores. Como os domínios usam redirecionamentos S3, ele precisava seguir os redirecionamentos HTTP para descobrir os IPs finais:

*"O domínio resolve para S3, mas os redirecionamentos HTTP me levam aos IPs reais dos servidores."*

#### Testando Cada Link da Página Legacy

*"A página old.acme-corp-lab.com é o ponto de partida perfeito. Seus links me levam aos IPs reais dos serviços internos através de redirecionamentos S3."*

*"Cada IP terá sua própria pasta. Cada serviço, seu próprio arquivo de evidência."*

---

## 🚀 Passo 1: Reconhecimento Rápido de Portas

### "Primeiro, descubra o que está aberto"

Alex sabia que o primeiro passo era identificar rapidamente quais portas estavam abertas. O `rustscan` era perfeito para isso — rápido e eficiente.

```bash
# Criar diretório para o IP alvo
mkdir -p results/<IP>

# Estratégia 1: Scan rápido de portas comuns primeiro
nmap -sT --top-ports 1000 <IP> -oN results/<IP>/nmap_top1000_<IP>.txt

# Estratégia 2: Se rustscan funcionar, usar para descobrir portas
rustscan -a <IP> --ulimit 5000 -- -sT -T4 -oA results/<IP>/rustscan_<IP>

# Estratégia 3: Scan de portas web específicas (mais rápido)
nmap -sT -T4 -p 80,443,3000,8080,8443,8000,9000 <IP> -oN results/<IP>/nmap_web_<IP>.txt
```

**Por quê?** Nem todos os servidores respondem bem ao `rustscan` (SYN scan). Usar múltiplas estratégias garante que você encontre as portas abertas:

- **Estratégia 1**: Scan das 1000 portas mais comuns (rápido e eficiente)
- **Estratégia 2**: Rustscan para descobrir portas não-padrão
- **Estratégia 3**: Foco em portas web comuns (ideal para pentesting web)

**O que procurar na saída:**
- Portas abertas (ex: 22, 80, 443, 3000, 8080, 8443)
- Serviços web (HTTP, HTTPS, APIs, SSH)

*"Porta 22 aberta... SSH para administração. Porta 3000 aberta... API de desenvolvimento. Porta 80 fechada mas 443 pode estar aberta... Vamos verificar."*

---

## 🔍 Passo 2: Scan Detalhado de Serviços

### "Agora, descubra COMO cada serviço está configurado"

Com as portas abertas identificadas, Alex executou um scan detalhado para obter versões e banners dos serviços.

```bash

# Scan detalhado nas portas identificadas (substitua <ports> pelas portas encontradas)
nmap -sC -sV -p <ports> <IP> -oN results/<IP>/nmap_<IP>.txt
```

**Por quê?** O parâmetro `-sC` executa scripts NSE padrão (detecção de vulnerabilidades conhecidas). O `-sV` identifica versões exatas dos serviços.

**O que procurar na saída:**
- Versão do sistema operacional
- Versão exata de cada serviço (ex: Apache 2.4.41, nginx 1.18.0, OpenSSH 7.4)
- Scripts NSE que revelam configurações (ex: `http-title`, `http-headers`, `http-methods`)

```bash
# Visualizar o resultado
cat results/<IP>/nmap_<IP>.txt
```

*"Apache 2.4.41 no Ubuntu... nginx 1.18.0... Node.js 14.21.0 na porta 3000... Cada versão pode ter vulnerabilidades conhecidas."*

---

## 🌐 Passo 3: Análise Detalhada de Serviços HTTP/HTTPS

### "Agora vamos descobrir que tecnologias estão rodando"

Com as portas web identificadas, Alex executou uma análise detalhada dos serviços HTTP/HTTPS para descobrir tecnologias, versões e configurações.

#### 3.1: Identificação de Tecnologias com httpx

```bash
# Análise rápida de serviços HTTP/HTTPS
httpx -u http://<IP> -title -tech-detect -status-code -o results/<IP>/httpx_<IP>.txt
```

**Por quê?** O `httpx` identifica rapidamente tecnologias web (PHP, ASP.NET, Node.js, etc.), títulos de páginas, e códigos de status HTTP.

**O que procurar na saída:**
- Tecnologias detectadas (ex: PHP 7.4, ASP.NET, Node.js)
- Título da página web
- Códigos de status (200, 301, 403, 404)

#### 3.2: Identificação Avançada com whatweb

```bash
# Identificação detalhada de tecnologias web
whatweb -a 3 http://<IP> > results/<IP>/whatweb_<IP>.txt
```

**Por quê?** O `whatweb` é mais detalhado que o `httpx`, identificando versões específicas de frameworks, CMS, e bibliotecas JavaScript.

**O que procurar na saída:**
- Versões exatas (ex: WordPress 5.8.1, jQuery 3.6.0)
- Plugins e temas WordPress
- Frameworks JavaScript (React, Vue, Angular)

```bash
# Visualizar resultados
cat results/<IP>/whatweb_<IP>.txt
```

*"WordPress 5.8.1 com tema Twenty Twenty-One... jQuery 3.6.0... Isso me dá informações valiosas sobre possíveis vulnerabilidades."*

---

## 📁 Passo 4: Enumeração de Diretórios e Arquivos

### "Vamos descobrir o que está escondido nos diretórios"

Alex sabia que aplicações web frequentemente expõem diretórios e arquivos sensíveis: backups, logs, configurações, e até código-fonte.

#### 4.1: Enumeração de Diretórios com gobuster

```bash
# Enumeração de diretórios web
gobuster dir -u http://<IP> -w /usr/share/wordlists/dirb/common.txt -o results/<IP>/gobuster_<IP>.txt -q
```

**Por quê?** O `gobuster` descobre diretórios e arquivos que não estão listados publicamente, mas podem ser acessados diretamente.

**O que procurar na saída:**
- Diretórios administrativos (ex: `/admin/`, `/wp-admin/`, `/phpmyadmin/`)
- Arquivos de backup (ex: `/backup/`, `/backups/`, `*.bak`)
- Arquivos de configuração (ex: `/config/`, `*.conf`, `*.ini`)

#### 4.2: Enumeração com Wordlist Personalizada

```bash
# Criar wordlist personalizada baseada no que já sabemos
echo -e 'admin\napi\nbackup\nconfig\ndev\ngit\nlogin\nphpinfo\nphpmyadmin\ntest\nwww\nwp-admin\nwp-content\nwp-includes\nuploads\nfiles\nimages\ncss\njs\nassets\n.htaccess\nrobots.txt\nsitemap.xml' > custom_wordlist.txt

# Usar wordlist personalizada
gobuster dir -u http://<IP> -w custom_wordlist.txt -o results/<IP>/gobuster_custom_<IP>.txt -q
```

**Por quê?** Wordlists personalizadas são mais eficientes para alvos específicos, focando em diretórios comuns para WordPress, APIs, e aplicações web.

#### 4.3: Buscar Arquivos Sensíveis

```bash
# Buscar arquivos específicos que podem conter informações sensíveis
gobuster dir -u http://<IP> -w /usr/share/wordlists/dirb/common.txt -x php,html,txt,conf,ini,bak,log -o results/<IP>/gobuster_files_<IP>.txt -q
```

**Por quê?** O parâmetro `-x` especifica extensões de arquivo para buscar. Arquivos `.conf`, `.ini`, `.bak` frequentemente contêm credenciais ou configurações sensíveis.

```bash
# Visualizar resultados
cat results/<IP>/gobuster_<IP>.txt
```

*"Diretório `/admin/` acessível... `/backup/` também... E arquivo `config.php.bak` encontrado. Isso pode conter credenciais de banco de dados."*

---

## 🔌 Passo 5: Análise de APIs e Endpoints

### "APIs são a porta de entrada para dados sensíveis"

Alex sabia que APIs modernas frequentemente expõem endpoints sensíveis, métodos HTTP perigosos, e até credenciais em respostas JSON.

#### 5.1: Descobrir Endpoints de API

```bash
# Buscar endpoints de API comuns
gobuster dir -u http://<IP> -w /usr/share/wordlists/dirb/common.txt -x json,php,py,js -o results/<IP>/api_endpoints_<IP>.txt -q

# Buscar especificamente por APIs
echo -e 'api\nv1\nv2\nrest\ngraphql\nswagger\ndocs\nopenapi\nendpoints\n' > api_wordlist.txt
gobuster dir -u http://<IP> -w api_wordlist.txt -o results/<IP>/api_discovery_<IP>.txt -q
```

**Por quê?** APIs frequentemente usam caminhos padronizados como `/api/`, `/v1/`, `/rest/`. Descobrir esses endpoints é o primeiro passo para explorar APIs.

#### 5.2: Testar Métodos HTTP

```bash
# Testar métodos HTTP em endpoints descobertos
curl -X OPTIONS http://<IP>/api/ -v > results/<IP>/http_methods_<IP>.txt 2>&1
curl -X GET http://<IP>/api/ -v >> results/<IP>/http_methods_<IP>.txt 2>&1
curl -X POST http://<IP>/api/ -v >> results/<IP>/http_methods_<IP>.txt 2>&1
```

**Por quê?** Métodos HTTP como PUT, DELETE, PATCH podem permitir modificação de dados. OPTIONS revela métodos permitidos.

#### 5.3: Analisar Respostas JSON

```bash
# Testar endpoints de API e analisar respostas
curl -s http://<IP>/api/health | jq . > results/<IP>/api_health_<IP>.json
curl -s http://<IP>/api/system-info | jq . > results/<IP>/api_system_<IP>.json
```

**Por quê?** APIs frequentemente expõem informações do sistema, versões, e até credenciais em respostas JSON. O `jq` formata o JSON para análise.

```bash
# Procurar por padrões sensíveis nas respostas
grep -i "password\|secret\|key\|token" results/<IP>/api_*.json
```

*"API `/api/system-info` retorna credenciais de banco de dados em JSON... isso é crítico."*

---

## 🔌 Passo 6: Banner Grabbing e Headers Detalhados

### "Às vezes, é preciso conversar diretamente com o serviço"

Nem todo serviço web responde bem a ferramentas automatizadas. Banner grabbing manual e análise detalhada de headers podem revelar informações adicionais.

#### 6.1: Banner Grabbing Manual

```bash
# Banner grab na porta HTTP
timeout 2 bash -c "echo | nc <IP> 80" > results/<IP>/banner_<IP>_80.txt

# Banner grab em outras portas (exemplo: SSH na porta 22)
timeout 2 bash -c "echo | nc <IP> 22" > results/<IP>/banner_<IP>_22.txt

# Banner grab em porta de API (exemplo: 3000)
timeout 2 bash -c "echo | nc <IP> 3000" > results/<IP>/banner_<IP>_3000.txt
```

**Por quê?** Banners revelam versões exatas de software, que podem ser pesquisadas em bancos de dados de vulnerabilidades (CVE).

#### 6.2: Análise Detalhada de Headers HTTP

```bash
# Capturar headers HTTP detalhados
curl -I http://<IP> > results/<IP>/curl_headers_<IP>.txt

# Se HTTPS estiver disponível
curl -I -k https://<IP> > results/<IP>/curl_headers_https_<IP>.txt

# Headers com informações de segurança
curl -I -H "User-Agent: Mozilla/5.0" http://<IP> > results/<IP>/curl_headers_ua_<IP>.txt
```

**Por quê?** Headers HTTP revelam servidor web (Apache, IIS, nginx), versões, frameworks (PHP, ASP.NET), e configurações de segurança.

**O que procurar:**
- Header `Server:` (ex: Apache/2.4.41, nginx/1.18.0)
- Header `X-Powered-By:` (ex: PHP/7.4.3, ASP.NET)
- Headers de segurança ausentes (X-Frame-Options, Content-Security-Policy)
- Headers de cache e performance

#### 6.3: Scan de Vulnerabilidades com Nikto

```bash
# Scan de vulnerabilidades web (pode demorar alguns minutos)
nikto -host http://<IP> -output results/<IP>/nikto_<IP>.txt
```

**Por quê?** O `nikto` procura por configurações inseguras, arquivos sensíveis (backup, logs), e vulnerabilidades conhecidas.

**O que procurar na saída:**
- Arquivos expostos (ex: `/backup/`, `/.git/`, `/admin/`)
- Métodos HTTP perigosos habilitados (PUT, DELETE)
- Versões vulneráveis de software

```bash
# Visualizar resultados do nikto
cat results/<IP>/nikto_<IP>.txt
```

*"Diretório /.git/ acessível... o código-fonte pode estar exposto. E métodos PUT habilitados... possibilidade de upload de arquivos."*

---

## 📝 Passo 8: Documentação e Análise

### "Conhecimento sem documentação é conhecimento perdido"

Alex sempre reservava tempo para documentar seus achados de forma estruturada. Isso facilitava a comunicação com clientes e garantia que nenhuma descoberta fosse esquecida.

```bash
# Criar arquivo de notas
nano notes.md
```

#### Estrutura do `notes.md`:

```markdown
# Relatório de Enumeração Ativa - Acme Corp
**Data:** <DATA>
**Investigador:** <SEU_NOME>
**Alvo(s):** <IP_LIST>

---

## Resumo Executivo

### Achado 1: API Expõe Credenciais de Banco de Dados
**Descrição:** O endpoint `/api/system-info` retorna credenciais de banco de dados em texto claro na resposta JSON.
**Evidência:** `api_system_<IP>.json` linha 8
**Impacto:** Comprometimento completo do banco de dados e possivelmente toda a aplicação.

### Achado 2: Diretório de Backup Acessível Publicamente
**Descrição:** O diretório `/backup/` está acessível sem autenticação e contém arquivos sensíveis.
**Evidência:** `gobuster_<IP>.txt` linha 23
**Impacto:** Exposição de backups de banco de dados e arquivos de configuração.

### Achado 3: Versão Vulnerável do WordPress
**Descrição:** O servidor executa WordPress 5.8.1, que possui vulnerabilidades conhecidas (CVE-2021-44228).
**Evidência:** `whatweb_<IP>.txt` linha 5
**Impacto:** Possibilidade de execução remota de código e comprometimento do servidor.

---

## Análise de Risco

| Achado | Severidade | Probabilidade | Risco Final |
|--------|-----------|---------------|-------------|
| API expõe credenciais | Crítica | Alta | **CRÍTICO** |
| Backup público | Alta | Alta | **ALTO** |
| WordPress vulnerável | Alta | Média | **ALTO** |

---

## Recomendações de Mitigação

### 1. Remover Credenciais de APIs
- Implementar autenticação adequada em todos os endpoints de API
- Usar variáveis de ambiente para credenciais sensíveis
- Implementar rotação de credenciais e princípio do menor privilégio
- Adicionar logging e monitoramento de acesso às APIs

### 2. Proteger Diretórios Sensíveis
- Remover ou proteger adequadamente diretórios de backup
- Implementar autenticação para acesso a arquivos sensíveis
- Usar .htaccess ou configurações de servidor para restringir acesso
- Implementar backup seguro fora do diretório web público

### 3. Atualizar WordPress e Plugins
- Atualizar WordPress para a versão mais recente (6.0+)
- Atualizar todos os plugins e temas para versões sem vulnerabilidades conhecidas
- Implementar WAF (Web Application Firewall) para proteção adicional
- Configurar atualizações automáticas de segurança

---

## Próximos Passos
- [ ] Validar credenciais de API encontradas (somente em ambiente autorizado)
- [ ] Realizar scan de vulnerabilidades (CVE) nas versões identificadas
- [ ] Testar exploits conhecidos em ambiente controlado
- [ ] Analisar arquivos de backup descobertos
- [ ] Preparar relatório executivo para o cliente
```

*"Documentação clara é a diferença entre um pentester amador e um profissional."*

---

## ⚖️ Regras de Engajamento e Ética

### "Com grandes poderes vêm grandes responsabilidades"

Alex sempre seguia regras rígidas ao realizar enumeração ativa:

#### ✅ SEMPRE:

1. **Trabalhe apenas contra alvos autorizados** — Verifique a lista de IPs autorizados antes de executar qualquer comando
2. **Documente tudo** — Cada comando, cada resultado, cada observação
3. **Respeite os limites** — Se o comando falhar ou o sistema responder de forma estranha, PARE
4. **Mantenha confidencialidade** — Nunca compartilhe credenciais ou dados sensíveis fora do contexto do laboratório
5. **Relate responsavelmente** — Comunique vulnerabilidades ao responsável antes de divulgar

#### ❌ NUNCA:

1. **Executar exploits destrutivos** sem autorização explícita
2. **Modificar configurações** de sistemas de produção
3. **Exfiltrar dados** sem permissão documentada
4. **Realizar ataques de negação de serviço** (DoS/DDoS)
5. **Compartilhar vulnerabilidades publicamente** antes da correção

#### 🛑 EM CASO DE DÚVIDA:

- **PARE** imediatamente
- **DOCUMENTE** o que foi feito até o momento
- **CONSULTE** o responsável pelo laboratório
- **AGUARDE** autorização explícita antes de continuar

*"Hacking ético não é sobre explorar sistemas — é sobre entendê-los para protegê-los melhor."*

---

## 🎓 Boas Práticas de Documentação

### "Organização é eficiência"

Alex seguia um checklist mental para garantir documentação de qualidade:

#### Durante a Investigação:

1. **Salve todas as saídas** — Nunca confie apenas na memória
2. **Use nomes descritivos** — `nmap_<IP>.txt` é melhor que `scan1.txt`
3. **Organize por IP** — Crie pastas separadas para cada alvo
4. **Anote observações imediatas** — Pensamentos e insights no momento da descoberta

#### Ao Analisar Resultados:

1. **Use grep para filtrar** — `grep -i "password" results/<IP>/*.txt`
2. **Compare versões com CVE** — Pesquise versões no NIST NVD ou Exploit-DB
3. **Identifique padrões** — Múltiplos servidores com mesma configuração fraca?
4. **Priorize por risco** — Nem tudo é igualmente crítico

#### Ao Preparar Relatório:

1. **Escreva para o público-alvo** — Gestores precisam de resumo executivo, técnicos precisam de detalhes
2. **Inclua evidências** — Screenshots, trechos de logs, comandos executados
3. **Seja específico nas recomendações** — "Corrigir configurações" é vago; "Desabilitar null sessions no SMB" é claro
4. **Revise antes de entregar** — Erros de digitação prejudicam credibilidade

---

## 🎯 Revisão dos Entregáveis

Antes de finalizar o laboratório, verifique se você tem:

### Arquivos de Evidência:

- [ ] `rustscan_<IP>.gnmap` — Scan rápido de portas
- [ ] `nmap_<IP>.txt` — Scan detalhado com versões e scripts
- [ ] `enum4linux_<IP>.txt` — Enumeração completa de SMB
- [ ] `smbclient_<IP>.txt` — Lista de compartilhamentos SMB
- [ ] `ldap_<IP>.txt` — Consultas LDAP completas
- [ ] `ldap_users_<IP>.txt` — Lista de usuários LDAP
- [ ] `curl_<IP>.txt` — Headers HTTP/HTTPS
- [ ] `nikto_<IP>.txt` — Scan de vulnerabilidades web (quando aplicável)
- [ ] `banner_<IP>_<port>.txt` — Banners capturados manualmente

### Documentação:

- [ ] `notes.md` contém 3 achados principais
- [ ] Cada achado tem descrição, evidência e impacto
- [ ] Análise de risco está presente e estruturada
- [ ] 3 recomendações de mitigação são específicas e práticas
- [ ] Próximos passos estão documentados

### Estrutura de Diretórios:

```bash
# Verificar estrutura
tree results/

# Deve exibir algo como:
# results/
# ├── <IP_1>/
# │   ├── nmap_<IP_1>.txt
# │   ├── enum4linux_<IP_1>.txt
# │   ├── smbclient_<IP_1>.txt
# │   ├── ldap_<IP_1>.txt
# │   └── ...
# └── <IP_2>/
#     └── ...
```

---

## 🌅 O Final de Mais Uma Jornada

**Meio-dia. O sol brilha forte.**

Alex salvou o último arquivo e fechou o terminal. A enumeração ativa havia revelado muito mais do que o OSINT inicial: APIs expondo credenciais, diretórios de backup públicos, versões vulneráveis de software.

*"OSINT mostrou a superfície. Enumeração ativa revelou o que estava embaixo,"* pensou Alex, satisfeito.

Ele abriu o arquivo `notes.md` e revisou os achados. Três vulnerabilidades críticas, todas documentadas com evidências claras. Três recomendações práticas para o cliente. Um relatório profissional e acionável.

*"Esta empresa tem problemas sérios de configuração. Mas agora eles sabem exatamente o que precisa ser corrigido — e como fazer isso."*

Alex enviou o relatório para o responsável pelo laboratório e se levantou para fazer uma pausa. Havia aprendido algo valioso: **enumeração não é sobre encontrar vulnerabilidades — é sobre entender sistemas profundamente.**

*"Cada porta aberta conta uma história. Cada serviço revela uma decisão de arquitetura. Cada configuração expõe uma prioridade do negócio. Entender isso é a diferença entre um scanner de vulnerabilidades e um pentester de verdade."*

Ele sorriu e fechou o laptop.

**Fim da história... por enquanto.**

---

## 📚 Lições Aprendidas

### Para Futuros Investigadores:

1. **OSINT primeiro, enumeração depois** — Reconhecimento passivo informa a enumeração ativa
2. **Organize antes de executar** — Estrutura de pastas economiza tempo
3. **Documente tudo, sempre** — Você vai esquecer detalhes; seus arquivos não
4. **Entenda o contexto** — Versões antigas podem indicar sistemas legados; isso importa
5. **Priorize por risco** — Nem toda vulnerabilidade é igualmente crítica
6. **Correlacione achados** — Uma API vulnerável + backup público = acesso completo aos dados
7. **Pense como um defensor** — Cada vulnerabilidade encontrada deve ter uma mitigação proposta
8. **Respeite os limites éticos** — Autorização não é opcional

### A Mentalidade do Pentester:

*"Hacking ético não é sobre quebrar sistemas. É sobre entender como eles funcionam, onde eles falham, e como protegê-los melhor. Cada teste é uma oportunidade de aprender. Cada vulnerabilidade encontrada é uma chance de fortalecer a segurança. E cada relatório é uma contribuição para um mundo digital mais seguro."*

---

## 📎 Placeholder para Professor

**Instruções para configuração do laboratório:**

### IPs Autorizados para Enumeração:
```
<IP_1>: _________________________
<IP_2>: _________________________
<IP_3>: _________________________
```

### Credenciais de Teste (se aplicável):
```
Usuário: _________________________
Senha: _________________________
Domínio: _________________________
```

### Serviços Web Configurados:
```
URL: http://<IP>
Tecnologia: WordPress, Node.js, Apache, nginx
Porta: 80 (HTTP) / 443 (HTTPS) / 3000 (API)
Endpoints de API: /api/, /v1/, /rest/
```

### Vulnerabilidades Simuladas:
```
- APIs expondo credenciais em JSON
- Diretórios de backup públicos (/backup/)
- Versões vulneráveis de WordPress
- Métodos HTTP perigosos habilitados
- Headers de segurança ausentes
```

### Notas Adicionais:
```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```

---

*Esta história é uma representação fictícia de técnicas de enumeração ativa de serviços web para fins educacionais. Em testes de penetração reais, sempre obtenha autorização explícita por escrito e siga as leis e regulamentações aplicáveis (LGPD, GDPR, CFAA, etc.).*

**Faça e aprenda. A prática constrói mestres.**
