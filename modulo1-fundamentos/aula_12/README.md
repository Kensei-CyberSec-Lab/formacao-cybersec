# Lab : Scan de Vulnerabilidades com OpenVAS

Olá, pessoal!

Bem-vindos ao nosso laboratório de scan automatizado. Hoje, vamos usar uma das ferramentas mais poderosas do arsenal de um profissional de segurança, o OpenVAS/Greenbone, para realizar uma varredura completa em um alvo vulnerável. Nosso objetivo é entender o fluxo de trabalho de um analista de segurança, desde a configuração do scan até a interpretação dos resultados.

## Objetivo do Laboratório

* **Montar o Ambiente**: Iniciar o ambiente de scan de vulnerabilidades que já foi preparado com Docker.
* **Executar um Scan**: Aprender a configurar e lançar uma varredura a partir da interface web do Greenbone.
* **Analisar os Resultados**: Interpretar o relatório gerado, entendendo os níveis de severidade (CVSS) e identificando as falhas mais críticas.

## Arquitetura do Lab

Nosso laboratório terá dois componentes principais, orquestrados pelo docker-compose:

* **greenbone**: Um container com a suíte completa do Greenbone Community Edition, nossa plataforma de scan.
* **alvo-vulneravel**: Um container rodando a imagem tleemcjr/metasploitable2, um sistema operacional Linux deliberadamente cheio de vulnerabilidades para fins de treinamento.

## ⚠️ Aviso Importante sobre Recursos

O OpenVAS/Greenbone é uma ferramenta poderosa e, por isso, consome bastante memória RAM e CPU. Além disso, no primeiro boot, ele precisa baixar todo o banco de dados de vulnerabilidades (NVTs, SCAP, etc.), o que pode levar de 30 minutos a mais de uma hora, dependendo da sua conexão com a internet e da performance da sua máquina.

Tenha paciência! Este é um passo crucial e simula o setup em um ambiente real.

## Pré-requisitos do Lab

Para executar este laboratório, você precisa ter:

* Docker e Docker Compose instalados.
* O arquivo docker-compose.yml deste laboratório já presente no seu diretório de trabalho.

## Passo a Passo da Missão

### Passo 0: Iniciando o Laboratório (e o Teste de Paciência)

No seu terminal, dentro da pasta do laboratório, execute o comando:

```bash
docker compose up -d
```

* `docker compose up`: Comando que lê o arquivo docker-compose.yml e cria/inicia os serviços definidos.
* `-d`: (detached) Roda os containers em segundo plano, liberando seu terminal para outros comandos.

Agora, espere. O container greenbone vai começar um longo processo de download e sincronização dos feeds de vulnerabilidade.

Para acompanhar o progresso, use o seguinte comando em um terminal separado:

```bash
docker compose logs -f greenbone
```

* `docker compose logs`: Exibe os logs (saídas de texto) de um serviço.
* `-f`: (follow) Segue os logs em tempo real, mostrando novas linhas assim que são geradas.
* `greenbone`: O nome do serviço (definido no .yml) cujos logs queremos ver.

O processo estará pronto quando você vir uma mensagem indicando que o serviço gsad (Greenbone Security Assistant Daemon) está rodando. Procure por algo como:

```
start_http_service: http service started on port 9392
```

### Passo 1: Acessando a Interface do Greenbone (GSA)

Após a conclusão da sincronização, abra seu navegador e acesse:

[https://localhost:9392](https://localhost:9392)

(Seu navegador vai reclamar do certificado de segurança com um aviso. Isso é normal, pois o certificado foi auto-assinado pelo próprio Greenbone. Clique em "Avançado" e "Aceitar o risco e continuar").

**Use as seguintes credenciais para fazer o login:**

* Usuário: `admin`
* Senha: `admin`

### Passo 2: Configurando e Lançando o Scan

**Descubra o IP do Alvo:**

Primeiro, precisamos saber o IP do nosso container metasploitable-alvo. Em um terminal, rode:

```bash
docker inspect metasploitable-alvo | grep "IPAddress"
```

* `docker inspect`: Fornece informações detalhadas em formato JSON sobre um objeto Docker (neste caso, nosso container alvo).
* `|` (pipe): Pega a saída massiva do inspect e a usa como entrada para o próximo comando.
* `grep "IPAddress"`: Filtra a entrada, mostrando apenas as linhas que contêm "IPAddress".

**Resultado:** Anote o endereço IP que aparecer (será algo como 172.x.0.x).

### Antes de Começar o scan

#### Verifique o Status dos Feeds:

Na interface do GSA, navegue até `Administration > Feed Status`.

Verifique se todos os feeds (NVT, SCAP, CERT) estão com o status Current e mostram uma data recente. Se eles ainda estiverem atualizando, você precisa esperar mais.

**Crie o Alvo (Target) no Greenbone:**

* Navegue até `Configuration > Targets`
* Clique no ícone de estrela azul (New Target)
* Dê um nome (ex: Alvo Metasploitable)
* No campo Hosts, coloque o endereço IP que você acabou de descobrir
* Clique em Save

**Crie e Inicie a Tarefa (Task):**

* Navegue até `Scans > Tasks`
* Clique no ícone de estrela azul (New Task)
* Dê um nome para a tarefa (ex: Primeiro Scan)
* Em Scan Targets, selecione o alvo Alvo Metasploitable que você criou
* Clique em Save. Você voltará para a lista de tarefas
* Encontre sua tarefa na lista e clique no botão de Play (▶) para iniciá-la

### Passo 3: Analisando o Relatório

A varredura levará alguns minutos. Você pode acompanhar o progresso na própria página de tarefas.

Quando o status mudar para Done, clique no nome da tarefa e depois na data sob a coluna Report.

Explore o relatório! Você verá um dashboard com gráficos e uma lista de todas as vulnerabilidades encontradas, ordenadas por severidade (do Crítico ao Baixo).

Clique em uma das vulnerabilidades com severidade High ou Critical para ver os detalhes:

* **Summary**: Resumo do que é a vulnerabilidade
* **Vulnerability Detection Result**: Como o scanner detectou a falha
* **Impact**: O que um atacante poderia fazer ao explorá-la
* **Solution**: Como corrigir o problema

## Desafio Kensei

Encontre no relatório a vulnerabilidade "VSFTPD 2.3.4 Backdoor Command Execution".

Anote o CVE (Common Vulnerabilities and Exposures) associado a ela. Este é o identificador único e universal para essa falha.

Pesquise no Google por:

```text
VSFTPD 2.3.4 exploit metasploit
```

Veja como o resultado da sua pesquisa te leva a tutoriais e módulos de exploração, alinhando-se perfeitamente com as informações que o OpenVAS te deu.

## Limpeza do Ambiente

Quando terminar seus estudos, desligue e remova todo o ambiente com o comando:

```bash
docker compose down -v
```

* `docker compose down`: Para e remove os containers e a rede
* `-v`: É crucial para remover os volumes (neste caso, gvm\_data). Se você não usar `-v`, na próxima vez que subir o lab, ele reutilizará os dados antigos.

---

Feito com 💀 e paciência por ninjas da cibersegurança.

```
```
