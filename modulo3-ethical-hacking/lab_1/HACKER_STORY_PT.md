# 🎭 A História do Hacker: Explorando Acme Corp

> *"Cada sistema tem uma história para contar. Você só precisa saber como ouvir."* - Anônimo

---

## 🌙 O Início da Jornada

**Meia-noite. Silêncio na cidade.**

Alex, um hacker ético experiente, estava sentado em seu setup noturno. A tela do monitor iluminava seu rosto enquanto ele navegava pelos fóruns de segurança. Uma mensagem interessante havia aparecido:

*"Alguém já investigou a Acme Corp? Parece ter uma infraestrutura interessante..."*

Alex sorriu. Era exatamente o tipo de desafio que ele gostava. Uma empresa aparentemente normal, mas com "infraestrutura interessante" geralmente significava uma coisa: vulnerabilidades mal configuradas e sistemas legados esquecidos.

*"Vamos ver o que essa empresa está escondendo,"* pensou Alex, preparando seu ambiente de investigação.

### Preparando o Ambiente Docker

Alex sabia que o laboratório estava configurado com Docker. Ele verificou se os contêineres estavam rodando e acessou o ambiente Kali Linux.

```bash
# Carregar os contêineres
docker-compose up -d

# Verificando se os contêineres estão rodando
docker-compose ps

# Entrando no contêiner Kali Linux
docker exec -it kensei_kali /bin/bash

# Criando workspace organizado dentro do contêiner
mkdir -p /home/kali/investigations/acme-corp
cd /home/kali/investigations/acme-corp
```

---

## 🔍 Fase 1: O Reconhecimento Inicial

### "Sempre comece pelo básico"

Alex sabia que a primeira regra do reconhecimento era não pular etapas. Ele começou com o mais básico: descobrir todos os domínios e subdomínios associados à empresa.

# "Primeiro, vamos ver o que o Subfinder consegue descobrir sobre acme-corp-lab.com"
```bash
subfinder -d acme-corp-lab.com -o subdomains.txt
```

*"Interessante,"* Alex murmurou enquanto observava os resultados. O Subfinder havia encontrado quatro subdomínios:

- `www.acme-corp-lab.com`
- `admin.acme-corp-lab.com` 
- `dev.acme-corp-lab.com`
- `old.acme-corp-lab.com`

*"Agora isso é interessante. Um subdomínio 'old' geralmente significa sistemas legados. E sistemas legados geralmente significam... vulnerabilidades."*

### "Vamos tentar o Amass também, mas sem perder tempo"

Alex sabia que o Amass poderia encontrar subdomínios adicionais, mas também sabia que poderia ser muito lento.

```bash
# "Vamos tentar o Amass, mas com timeout para não perder tempo"
timeout 300 amass enum -passive -d acme-corp-lab.com -o amass_results.txt -v || echo "Amass timeout - continuando com Subfinder"

# Verificando se o Amass completou
if [ -f amass_results.txt ]; then
    echo "=== RESULTADOS DO AMASS ==="
    cat amass_results.txt
else
    echo "Amass não completou - usando apenas resultados do Subfinder"
fi
```

*"Como esperado, o Amass demorou muito. Mas não importa - o Subfinder já nos deu uma boa base para trabalhar."*

### "Sempre verifique se os sistemas estão realmente ativos"

Alex sabia que nem todos os subdomínios descobertos estariam ativos. Ele precisava verificar quais realmente respondiam.

```bash
# "Vamos ver quais desses subdomínios realmente existem"
cat subdomains.txt | dnsx -resp -silent -o resolved_subdomains.txt
```

Os resultados mostraram que todos os quatro subdomínios resolviam para IPs diferentes. *"Múltiplos IPs... isso pode significar uma infraestrutura distribuída ou balanceamento de carga."*

### "Agora vamos ver o que esses serviços realmente fazem"

```bash
# "Vamos sondar quais serviços web estão rodando"
cat subdomains.txt | httpx -title -tech-detect -status-code -o live_web_services.txt
```

Alex analisou os resultados:

- `www.acme-corp-lab.com` - S3 estático, normal para um site principal
- `admin.acme-corp-lab.com` - WordPress! *"Isso é interessante. Painéis administrativos WordPress são alvos frequentes."*
- `old.acme-corp-lab.com` - Retornou 301 (redirecionamento) *"Hmm, um redirecionamento. Vamos investigar isso."*

---

## 🎯 Fase 2: A Descoberta do Hub Central

### "Sempre investigue redirecionamentos"

O redirecionamento 301 no subdomínio `old` chamou a atenção de Alex. Ele sabia que redirecionamentos muitas vezes revelavam informações interessantes.

```bash
# "Vamos seguir esse redirecionamento e ver o que está por trás"
curl -L -s http://old.acme-corp-lab.com/ > legacy_page.html

# "Alternativamente, vamos acessar diretamente via IP para ser mais confiável"
curl -s http://3.94.82.59/ > legacy_page.html
```

*"Ahá!"* Alex exclamou quando viu o conteúdo da página. Era uma página legacy com links para outros serviços:

```html
<h1>Legacy System</h1>
<p>Sistema legado em operação desde 2015</p>
<ul>
<li><a href="/phpinfo.php">PHP Info</a></li>
<li><a href="http://admin.acme-corp-lab.com.s3-website-us-east-1.amazonaws.com">Admin Panel</a></li>
<li><a href="http://dev.acme-corp-lab.com.s3-website-us-east-1.amazonaws.com">API</a></li>
</ul>
```

*"Perfeito! Esta página legacy é um hub central. Ela conecta todos os outros serviços. E veja só - há comentários HTML com URLs S3 adicionais!"*

Alex rapidamente extraiu os comentários:

```bash
# "Vamos ver o que mais está escondido nos comentários"
awk '/^<!--/,/-->$/' legacy_page.html
```

*"Excelente! URLs S3 públicas com arquivos da empresa. Isso pode conter informações valiosas."*

### "Sempre verifique arquivos públicos em S3"

```bash
# "Vamos baixar esses arquivos S3"
curl -s https://acme-corp-lab-public-files-6nssymq7.s3.us-east-1.amazonaws.com/company_info.txt
curl -s https://acme-corp-lab-public-files-6nssymq7.s3.us-east-1.amazonaws.com/employees.csv
```

*"Jackpot!"* Alex sorriu. Os arquivos continham informações detalhadas da empresa:

- Lista completa de funcionários com emails e telefones
- Informações sobre infraestrutura da empresa
- Endereços de escritórios
- Servidores de email e DNS

*"Esta empresa está vazando informações sensíveis. Em uma situação real, isso seria um problema sério de segurança."*

---

## 🔍 Fase 3: Explorando os Serviços Descobertos

### "Agora vamos testar esses links S3"

Alex sabia que os links S3 na página legacy provavelmente redirecionariam para IPs diretos. Ele testou cada um:

```bash
# "Vamos ver para onde esses links S3 redirecionam"
curl -I http://admin.acme-corp-lab.com.s3-website-us-east-1.amazonaws.com
curl -I http://dev.acme-corp-lab.com.s3-website-us-east-1.amazonaws.com
```

*"Como esperado! Redirecionamentos para IPs diretos. Isso é comum em infraestruturas AWS."*

### "Vamos acessar diretamente os IPs"

```bash
# "Acessando o serviço admin via IP direto"
curl -I http://54.152.245.201:80/

# "E o serviço dev"
curl -s http://34.207.53.34:3000/ | head -5
```

O serviço admin retornou informações sobre WordPress, e o serviço dev mostrou uma API JSON com endpoints interessantes.

### "APIs são sempre alvos interessantes"

Alex testou os endpoints da API:

```bash
# "Vamos ver o que essa API pode nos contar"
curl -s http://34.207.53.34:3000/api/health
curl -s http://34.207.53.34:3000/api/system-info
```

*"Oh não..."* Alex suspirou quando viu o resultado do `/api/system-info`. A API estava expondo credenciais de banco de dados, chaves de API e informações sensíveis:

```json
{
  "database": {
    "host": "localhost",
    "user": "dev_user", 
    "password": "DevPass2024"
  },
  "api_keys": {
    "stripe": "sk_test_51AcmeCorp123456789",
    "aws": "AKIAIOSFODNN7EXAMPLE"
  }
}
```

*"Isso é um desastre de segurança. Em um ambiente de produção, essas credenciais poderiam ser usadas para comprometer toda a infraestrutura."*

---

## 🔍 Fase 4: Enumeração de Diretórios

### "Vamos ver o que mais está escondido no WordPress"

Alex decidiu fazer uma enumeração de diretórios no serviço admin para ver se havia outros caminhos interessantes:

```bash
# "Criando uma wordlist personalizada baseada no que já sabemos"
echo -e 'admin\napi\nbackup\nconfig\ndev\ngit\nlogin\nphpinfo\nphpmyadmin\ntest\nwww\nwp-admin\nwp-content\nwp-includes\nuploads\nfiles\nimages\ncss\njs\nassets' > custom_wordlist.txt

# "Vamos ver o que encontramos"
gobuster dir -u http://54.152.245.201:80 -w custom_wordlist.txt -o gobuster_results.txt -q
```

*"Interessante! Encontramos diretórios WordPress padrão. Isso confirma que é realmente um WordPress."*

---

## 🔍 Fase 5: Análise com Ferramentas Avançadas

### "Vamos usar o SpiderFoot para uma análise mais profunda"

Alex sabia que o laboratório incluía o SpiderFoot rodando no Docker. Ele abriu o navegador e acessou `http://localhost:5001`.

*"Perfeito! O SpiderFoot está rodando no contêiner. Vou criar um novo scan para acme-corp-lab.com."*

Alex criou um novo scan no SpiderFoot, selecionando módulos relevantes para DNS, HTTP e outras fontes de dados.

*"O SpiderFoot vai coletar dados de fontes que não consegui acessar manualmente. É sempre bom ter múltiplas perspectivas."*

---

## 📊 Fase 6: Documentando os Achados

### "Sempre documente tudo. Conhecimento sem documentação é conhecimento perdido."

Alex começou a compilar um relatório detalhado de sua investigação:

```bash
# "Criando um relatório profissional"
cat > investigation_report.md << 'EOF'
# Relatório de Investigação OSINT - Acme Corp

## Resumo Executivo
Investigação revelou múltiplas vulnerabilidades críticas de segurança...

## Achados Principais
1. **Exposição de Credenciais**: API dev expõe credenciais de banco de dados
2. **Arquivos Públicos S3**: Informações sensíveis da empresa expostas
3. **Sistema Legacy**: Página legacy serve como hub central desprotegido
4. **WordPress Exposto**: Painel administrativo acessível publicamente

## Recomendações Críticas
1. Remover credenciais da API de desenvolvimento
2. Proteger arquivos S3 sensíveis
3. Implementar autenticação na página legacy
4. Revisar configurações de segurança do WordPress
EOF
```

---

## 🤔 Reflexões sobre a Mentalidade Hacker

### "O que aprendemos com esta investigação?"

Enquanto Alex finalizava seu relatório, ele refletiu sobre o processo:

**1. Curiosidade é a chave**
*"Sempre questione o que vê. Um redirecionamento 301 não é apenas um redirecionamento - pode ser uma porta para sistemas esquecidos."*

**2. Siga os links, mas pense como um investigador**
*"Cada link, cada arquivo, cada endpoint pode conter informações valiosas. A página legacy foi o ponto de entrada para tudo."*

**3. Use múltiplas ferramentas e perspectivas**
*"Ferramentas de linha de comando são poderosas, mas interfaces visuais como SpiderFoot e Neo4j oferecem insights diferentes. O ambiente Docker torna tudo mais organizado e reproduzível."*

**4. Documente tudo**
*"Em uma investigação real, você pode precisar voltar aos dados meses depois. Documentação clara é essencial."*

**5. Pense em termos de relacionamentos**
*"Não são apenas sistemas isolados - são redes de conexões. Entender essas conexões é fundamental."*

### "A mentalidade hacker não é sobre quebrar sistemas - é sobre entender como eles funcionam."

Alex fechou seu laptop e sorriu. Esta investigação havia revelado vulnerabilidades sérias, mas também havia demonstrado algo importante: como uma abordagem sistemática e metódica pode revelar informações valiosas sobre qualquer alvo.

*"Cada sistema conta uma história. Você só precisa saber como ouvir."*

---

## 🎯 Lições Aprendidas

### Para Futuros Investigadores:

1. **Comece sempre pelo básico** - Enumeração de subdomínios e DNS
2. **Configure seu ambiente adequadamente** - Docker torna tudo mais organizado e reproduzível
3. **Investigue redirecionamentos** - Eles podem revelar infraestrutura oculta
4. **Procure por arquivos públicos** - S3 buckets mal configurados são comuns
5. **Teste APIs** - Endpoints de desenvolvimento frequentemente expõem credenciais
6. **Use visualização** - Grafos ajudam a entender relacionamentos complexos
7. **Combine ferramentas CLI e web** - Interfaces visuais complementam comandos
8. **Documente tudo** - Conhecimento sem documentação é conhecimento perdido

### A Mentalidade Ética:

Alex sabia que as vulnerabilidades que havia encontrado eram sérias. Em um cenário real, ele teria:

1. **Reportado responsavelmente** as vulnerabilidades à empresa
2. **Fornecido evidências claras** de cada achado
3. **Sugerido correções específicas** para cada problema
4. **Respeitado prazos** para correção antes de divulgação pública

*"O verdadeiro hacker é aquele que usa suas habilidades para proteger, não para atacar."*

---

## 🌅 O Fim da Jornada

**5 da manhã. Primeira luz do dia.**

Alex finalizou seu relatório e o salvou. Ele havia descoberto vulnerabilidades significativas, mas mais importante, havia demonstrado como uma investigação OSINT sistemática pode revelar a verdadeira postura de segurança de uma organização.

*"Esta empresa tem muito trabalho pela frente,"* pensou Alex, *"mas pelo menos agora eles sabem exatamente o que precisa ser corrigido."*

Ele fechou o laptop e se preparou para dormir, sabendo que havia usado suas habilidades para o bem - descobrindo vulnerabilidades para que pudessem ser corrigidas, não exploradas.

*"O ambiente Docker tornou tudo mais organizado e reproduzível. Amanhã será outro dia, com novos desafios e novos sistemas para entender. Mas pelo menos o setup estará sempre pronto."*

**Fim da história.**

---

*Esta história é uma representação fictícia de técnicas OSINT éticas. Em investigações reais, sempre obtenha autorização adequada e siga as leis e regulamentações aplicáveis.*
