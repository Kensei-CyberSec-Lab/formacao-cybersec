# Guia Completo do Neo4j para OSINT

## 📋 Índice
1. [Introdução ao Neo4j](#introdução-ao-neo4j)
2. [Acesso ao Neo4j](#acesso-ao-neo4j)
3. [Conceitos Básicos](#conceitos-básicos)
4. [Preparando Dados OSINT](#preparando-dados-osint)
5. [Importando Dados](#importando-dados)
6. [Consultas Básicas](#consultas-básicas)
7. [Visualizações](#visualizações)
8. [Análises Avançadas](#análises-avançadas)
9. [Exemplos Práticos](#exemplos-práticos)
10. [Dicas e Melhores Práticas](#dicas-e-melhores-práticas)

---

## 🎯 Introdução ao Neo4j

O **Neo4j** é um banco de dados de grafos que permite visualizar e analisar relacionamentos entre dados de forma poderosa. No contexto OSINT, ele é especialmente útil para:

- **Visualizar conexões** entre domínios, IPs e serviços
- **Identificar padrões** na infraestrutura do alvo
- **Mapear relacionamentos** entre diferentes entidades
- **Descobrir pontos de entrada** e vulnerabilidades em cadeia

### Por que usar Neo4j para OSINT?
- **Visualização intuitiva** de dados complexos
- **Consultas em linguagem natural** (Cypher)
- **Descoberta de padrões** não óbvios
- **Análise de relacionamentos** em tempo real

---

## 🔗 Acesso ao Neo4j

### Informações de Conexão
- **URL:** `http://localhost:7474`
- **Usuário:** `neo4j`
- **Senha:** `test`
- **Protocolo Bolt:** `bolt://localhost:7687`

### Primeiro Acesso
1. Abra seu navegador
2. Navegue para `http://localhost:7474`
3. Faça login com as credenciais acima
4. Aceite os termos de uso
5. Você será direcionado para o **Neo4j Browser**

---

## 📚 Conceitos Básicos

### Nós (Nodes)
Representam **entidades** no grafo:
- **:Subdomain** - Subdomínios descobertos
- **:IP** - Endereços IP
- **:Domain** - Domínios principais
- **:Technology** - Tecnologias identificadas
- **:Vulnerability** - Vulnerabilidades encontradas

### Relacionamentos (Relationships)
Conectam nós e representam **conexões**:
- **:RESOLVES_TO** - Subdomínio resolve para IP
- **:HOSTS** - IP hospeda serviço
- **:EXPOSES** - Serviço expõe vulnerabilidade
- **:BELONGS_TO** - Entidade pertence a organização

### Propriedades (Properties)
Atributos dos nós e relacionamentos:
- **name** - Nome da entidade
- **type** - Tipo da entidade
- **status** - Status (ativo, inativo)
- **discovered_date** - Data de descoberta

---

## 📊 Preparando Dados OSINT

### Estrutura de Dados Recomendada

#### 1. Subdomínios
```csv
name,type,status,discovered_date
www.acme-corp-lab.com,subdomain,active,2024-01-15
admin.acme-corp-lab.com,subdomain,active,2024-01-15
dev.acme-corp-lab.com,subdomain,active,2024-01-15
old.acme-corp-lab.com,subdomain,active,2024-01-15
```

#### 2. Resoluções DNS
```csv
subdomain,ip,type,ttl
www.acme-corp-lab.com,18.239.69.111,ip,300
admin.acme-corp-lab.com,54.152.245.201,ip,300
dev.acme-corp-lab.com,34.207.53.34,ip,300
old.acme-corp-lab.com,3.94.82.59,ip,300
```

#### 3. Tecnologias Identificadas
```csv
domain,technology,version,confidence
www.acme-corp-lab.com,Apache,2.4.41,high
admin.acme-corp-lab.com,Nginx,1.18.0,high
dev.acme-corp-lab.com,Apache,2.4.41,medium
```

---

## 🚀 Importando Dados

### Método 1: Comandos Diretos (Recomendado para Iniciantes)

#### Passo 1: Criar Nós de Subdomínios
```cypher
CREATE (s1:Subdomain {name: 'www.acme-corp-lab.com', type: 'subdomain', status: 'active'})
CREATE (s2:Subdomain {name: 'admin.acme-corp-lab.com', type: 'subdomain', status: 'active'})
CREATE (s3:Subdomain {name: 'dev.acme-corp-lab.com', type: 'subdomain', status: 'active'})
CREATE (s4:Subdomain {name: 'old.acme-corp-lab.com', type: 'subdomain', status: 'active'})
```

#### Passo 2: Criar Nós de IPs
```cypher
CREATE (i1:IP {address: '18.239.69.111', type: 'ip', status: 'active'})
CREATE (i2:IP {address: '54.152.245.201', type: 'ip', status: 'active'})
CREATE (i3:IP {address: '34.207.53.34', type: 'ip', status: 'active'})
CREATE (i4:IP {address: '3.94.82.59', type: 'ip', status: 'active'})
```

#### Passo 3: Criar Relacionamentos DNS
```cypher
MATCH (s:Subdomain {name: 'www.acme-corp-lab.com'}), (i:IP {address: '18.239.69.111'})
CREATE (s)-[:RESOLVES_TO {ttl: 300, discovered_date: '2024-01-15'}]->(i)

MATCH (s:Subdomain {name: 'admin.acme-corp-lab.com'}), (i:IP {address: '54.152.245.201'})
CREATE (s)-[:RESOLVES_TO {ttl: 300, discovered_date: '2024-01-15'}]->(i)

MATCH (s:Subdomain {name: 'dev.acme-corp-lab.com'}), (i:IP {address: '34.207.53.34'})
CREATE (s)-[:RESOLVES_TO {ttl: 300, discovered_date: '2024-01-15'}]->(i)

MATCH (s:Subdomain {name: 'old.acme-corp-lab.com'}), (i:IP {address: '3.94.82.59'})
CREATE (s)-[:RESOLVES_TO {ttl: 300, discovered_date: '2024-01-15'}]->(i)
```

### Método 2: Importação via CSV (Avançado)

#### Preparar Arquivos CSV
```bash
# No terminal do Docker Kali
mkdir -p /home/kali/neo4j-data
cd /home/kali/neo4j-data

# Criar arquivo de subdomínios
cat > subdomains.csv << EOF
name,type,status,discovered_date
www.acme-corp-lab.com,subdomain,active,2024-01-15
admin.acme-corp-lab.com,subdomain,active,2024-01-15
dev.acme-corp-lab.com,subdomain,active,2024-01-15
old.acme-corp-lab.com,subdomain,active,2024-01-15
EOF

# Criar arquivo de IPs
cat > ips.csv << EOF
address,type,status,discovered_date
18.239.69.111,ip,active,2024-01-15
54.152.245.201,ip,active,2024-01-15
34.207.53.34,ip,active,2024-01-15
3.94.82.59,ip,active,2024-01-15
EOF

# Criar arquivo de relacionamentos
cat > dns_resolution.csv << EOF
subdomain,ip,ttl
www.acme-corp-lab.com,18.239.69.111,300
admin.acme-corp-lab.com,54.152.245.201,300
dev.acme-corp-lab.com,34.207.53.34,300
old.acme-corp-lab.com,3.94.82.59,300
EOF
```

#### Comandos de Importação
```cypher
// Importar subdomínios
LOAD CSV WITH HEADERS FROM 'file:///subdomains.csv' AS row
CREATE (s:Subdomain {name: row.name, type: row.type, status: row.status, discovered_date: row.discovered_date});

// Importar IPs
LOAD CSV WITH HEADERS FROM 'file:///ips.csv' AS row
CREATE (i:IP {address: row.address, type: row.type, status: row.status, discovered_date: row.discovered_date});

// Criar relacionamentos
LOAD CSV WITH HEADERS FROM 'file:///dns_resolution.csv' AS row
MATCH (s:Subdomain {name: row.subdomain})
MATCH (i:IP {address: row.ip})
CREATE (s)-[:RESOLVES_TO {ttl: toInteger(row.ttl)}]->(i);
```

---

## 🔍 Consultas Básicas

### 1. Visualizar Todo o Grafo
```cypher
MATCH (n)-[r]->(m)
RETURN n, r, m
LIMIT 50
```

### 2. Listar Todos os Subdomínios
```cypher
MATCH (s:Subdomain)
RETURN s.name, s.status
ORDER BY s.name
```

### 3. Listar Todos os IPs
```cypher
MATCH (i:IP)
RETURN i.address, i.status
ORDER BY i.address
```

### 4. Ver Relacionamentos DNS
```cypher
MATCH (s:Subdomain)-[r:RESOLVES_TO]->(i:IP)
RETURN s.name, i.address, r.ttl
ORDER BY s.name
```

### 5. Contar Entidades por Tipo
```cypher
MATCH (n)
RETURN labels(n)[0] as NodeType, count(n) as Count
ORDER BY Count DESC
```

---

## 🎨 Visualizações

### Configuração da Visualização

#### 1. Ajustar Layout
- **Force Atlas 2** - Para grafos complexos
- **Circular** - Para visualizações organizadas
- **Hierárquico** - Para estruturas hierárquicas

#### 2. Personalizar Cores
```cypher
// Subdomínios em azul, IPs em vermelho
MATCH (n)
RETURN n
```

#### 3. Ajustar Tamanhos
- **Subdomínios** - Tamanho médio
- **IPs** - Tamanho pequeno
- **Domínios principais** - Tamanho grande

### Consultas para Visualização

#### Visualizar Infraestrutura Completa
```cypher
MATCH (s:Subdomain)-[r:RESOLVES_TO]->(i:IP)
RETURN s, r, i
```

#### Destacar Pontos Críticos
```cypher
MATCH (s:Subdomain)-[r:RESOLVES_TO]->(i:IP)
WHERE s.name CONTAINS 'admin' OR s.name CONTAINS 'dev'
RETURN s, r, i
```

---

## 🔬 Análises Avançadas

### 1. Identificar IPs Compartilhados
```cypher
MATCH (i:IP)<-[:RESOLVES_TO]-(s:Subdomain)
WITH i, collect(s.name) as subdomains
WHERE size(subdomains) > 1
RETURN i.address, subdomains, size(subdomains) as count
ORDER BY count DESC
```

### 2. Mapear Estrutura Hierárquica
```cypher
MATCH (s:Subdomain)-[r:RESOLVES_TO]->(i:IP)
WHERE s.name CONTAINS 'acme-corp-lab.com'
RETURN s.name, i.address
ORDER BY s.name
```

### 3. Identificar Padrões de Nomenclatura
```cypher
MATCH (s:Subdomain)
WHERE s.name CONTAINS 'acme-corp-lab.com'
WITH s.name as subdomain, split(s.name, '.')[0] as prefix
RETURN prefix, count(*) as count
ORDER BY count DESC
```

### 4. Análise de Distribuição Geográfica (se disponível)
```cypher
MATCH (i:IP)
WHERE exists(i.country)
RETURN i.country, count(i) as ip_count
ORDER BY ip_count DESC
```

### 5. Identificar Sistemas Críticos
```cypher
MATCH (s:Subdomain)
WHERE s.name CONTAINS 'admin' OR s.name CONTAINS 'dev' OR s.name CONTAINS 'prod'
RETURN s.name, s.status
ORDER BY s.name
```

---

## 💡 Exemplos Práticos

### Cenário 1: Descoberta de Subdomínios
```cypher
// Adicionar novos subdomínios descobertos
CREATE (s5:Subdomain {name: 'api.acme-corp-lab.com', type: 'subdomain', status: 'active'})
CREATE (i5:IP {address: '52.91.123.45', type: 'ip', status: 'active'})

// Criar relacionamento
MATCH (s:Subdomain {name: 'api.acme-corp-lab.com'}), (i:IP {address: '52.91.123.45'})
CREATE (s)-[:RESOLVES_TO {ttl: 300}]->(i)

// Visualizar atualização
MATCH (n)-[r]->(m)
RETURN n, r, m
```

### Cenário 2: Identificar Vulnerabilidades
```cypher
// Adicionar vulnerabilidade
CREATE (v1:Vulnerability {name: 'CVE-2021-44228', severity: 'critical', description: 'Log4j RCE'})

// Conectar vulnerabilidade ao serviço
MATCH (s:Subdomain {name: 'admin.acme-corp-lab.com'}), (v:Vulnerability {name: 'CVE-2021-44228'})
CREATE (s)-[:EXPOSES {confidence: 'high', discovered_date: '2024-01-15'}]->(v)

// Consultar sistemas vulneráveis
MATCH (s:Subdomain)-[:EXPOSES]->(v:Vulnerability)
WHERE v.severity = 'critical'
RETURN s.name, v.name, v.severity
```

### Cenário 3: Análise de Tecnologias
```cypher
// Adicionar tecnologias identificadas
CREATE (t1:Technology {name: 'Apache', version: '2.4.41', confidence: 'high'})
CREATE (t2:Technology {name: 'PHP', version: '7.4.3', confidence: 'medium'})

// Conectar tecnologias aos serviços
MATCH (s:Subdomain {name: 'www.acme-corp-lab.com'}), (t:Technology {name: 'Apache'})
CREATE (s)-[:HOSTS {port: 80, protocol: 'http'}]->(t)

MATCH (s:Subdomain {name: 'www.acme-corp-lab.com'}), (t:Technology {name: 'PHP'})
CREATE (s)-[:HOSTS {port: 80, protocol: 'http'}]->(t)

// Consultar stack tecnológico
MATCH (s:Subdomain)-[:HOSTS]->(t:Technology)
RETURN s.name, collect(t.name) as technologies
```

---

## 🎯 Dicas e Melhores Práticas

### 1. Organização de Dados
- **Use labels consistentes** (:Subdomain, :IP, :Domain)
- **Padronize propriedades** (name, type, status)
- **Mantenha datas** de descoberta para auditoria
- **Use relacionamentos descritivos** (:RESOLVES_TO, :HOSTS, :EXPOSES)

### 2. Performance
- **Crie índices** para propriedades frequentemente consultadas
```cypher
CREATE INDEX subdomain_name FOR (s:Subdomain) ON (s.name)
CREATE INDEX ip_address FOR (i:IP) ON (i.address)
```
- **Limite resultados** com LIMIT em consultas grandes
- **Use WHERE** para filtrar dados antes de processar

### 3. Consultas Eficientes
- **Comece com MATCH** para encontrar nós
- **Use WITH** para processar dados intermediários
- **Aplique filtros** com WHERE antes de RETURN
- **Ordene resultados** com ORDER BY quando relevante

### 4. Visualização
- **Ajuste o layout** para melhor compreensão
- **Use cores** para diferenciar tipos de nós
- **Mantenha grafos** organizados e legíveis
- **Exporte imagens** para documentação

### 5. Manutenção
- **Limpe dados antigos** periodicamente
- **Atualize status** de entidades
- **Documente consultas** importantes
- **Faça backup** regular dos dados

---

## 🚨 Solução de Problemas

### Problema: Neo4j não responde
```bash
# Verificar se o container está rodando
docker ps | grep neo4j

# Reiniciar o container se necessário
docker restart kensei_neo4j
```

### Problema: Erro de autenticação
- Verifique usuário: `neo4j`
- Verifique senha: `test`
- Limpe cache do navegador

### Problema: Consulta muito lenta
- Adicione LIMIT à consulta
- Use índices apropriados
- Simplifique a consulta

### Problema: Dados não aparecem
- Verifique se os nós foram criados
- Confirme os labels e propriedades
- Execute consultas de verificação simples

---

## 📚 Recursos Adicionais

### Documentação Oficial
- [Neo4j Cypher Manual](https://neo4j.com/docs/cypher-manual/)
- [Neo4j Browser Guide](https://neo4j.com/docs/browser-manual/)
- [Neo4j Tutorials](https://neo4j.com/developer/cypher/)

### Comandos Úteis para Referência

#### Limpar Banco de Dados
```cypher
MATCH (n) DETACH DELETE n
```

#### Verificar Estatísticas
```cypher
CALL db.stats()
```

#### Listar Todos os Labels
```cypher
CALL db.labels()
```

#### Listar Todos os Relacionamentos
```cypher
CALL db.relationshipTypes()
```

---

## 🎓 Conclusão

O Neo4j é uma ferramenta poderosa para análise OSINT que transforma dados estáticos em visualizações dinâmicas e insights acionáveis. Com este guia, você pode:

- **Importar dados** OSINT de forma estruturada
- **Visualizar relacionamentos** entre entidades
- **Identificar padrões** e conexões ocultas
- **Analisar infraestrutura** de forma eficiente
- **Documentar descobertas** visualmente

Lembre-se: a prática leva à perfeição. Experimente diferentes consultas e visualizações para descobrir o poder completo do Neo4j em suas investigações OSINT!
