# 📦 Projeto Docker Lab #6: Explorando a Rede - Infraestrutura e Comandos Essenciais

Este projeto contém o ambiente Docker para o laboratório prático da Aula #6 da Formação CyberSec, focada em Infraestrutura de Rede e comandos essenciais de reconhecimento.

---

### 🎯 Objetivos do Lab

* Utilizar comandos básicos de linha de comando (`ping`, `traceroute`, `dig`) dentro de um container Kali Linux.
* Visualizar o tráfego e a resolução de nomes em um ambiente de rede simulado com Docker.
* Identificar informações de domínio e rastrear rotas, consolidando o entendimento sobre a infraestrutura de rede.

---

### 📋 Pré-requisitos

Antes de começar, certifique-se de ter o seguinte instalado em sua máquina:

* **Docker Desktop** (para Windows/macOS) ou **Docker Engine** (para Linux).

    * Instalação Docker Desktop: \[https://www.docker.com/products/docker-desktop/](https://www.docker.com/products/docker-desktop/)
* **Git** (para clonar este repositório).

    * Instalação Git: \[https://git-scm.com/downloads](https://git-scm.com/downloads)
* **WSL 2** (apenas para usuários Windows que não usam Docker Desktop).

    * Instalação WSL: \[https://learn.microsoft.com/pt-br/windows/wsl/install](https://learn.microsoft.com/pt-br/windows/wsl/install)

---

### 🚀 Setup do Lab

Siga os passos abaixo para configurar e iniciar seu ambiente de laboratório:

1.  **Clone o repositório da Formação CyberSec:**

    Se você ainda não clonou o repositório principal do curso, faça-o agora:

    ```bash
    git clone [https://github.com/Kensei-CyberSec-Lab/formacao-cybersec.git](https://github.com/Kensei-CyberSec-Lab/formacao-cybersec.git)
    ```
2.  **Navegue até a pasta do Lab da Aula #6:**

    ```bash
    cd formacao-cybersec/modulo1-fundamentos/aula_6
    ```

    * Dentro desta pasta, você encontrará os arquivos `docker-compose.yml`, `Corefile` e a subpasta `kali-custom` com o `Dockerfile`.
3.  **Inicie os containers Docker (e construa a imagem Kali personalizada):**

    Este comando construirá a imagem customizada do Kali (na primeira vez ou se houver mudanças no `Dockerfile`) e iniciará os três containers definidos no `docker-compose.yml` em segundo plano (`-d`).

    ```bash
    docker compose up --build -d
    ```

    * **Verifique se os containers estão rodando:**

        ```bash
        docker ps
        ```

        Você deverá ver `kali_lab_6`, `web_server_target_lab_6` e `dns_server_lab_6` na lista.

---

### 🛠️ Passo a Passo do Laboratório

Siga estas instruções para executar os comandos e entender a infraestrutura de rede:

1.  **Ajustar o `Corefile` com o IP predefinido do `web-server-target`:**

    O `dns-server` precisa saber o IP interno do `web-server-target` para resolver o nome `target.lab`.

    * **Edite o arquivo `Corefile`** que está na mesma pasta do `docker-compose.yml`. Substitua o placeholder `<IP_REAL_DO_WEB_SERVER_TARGET>` pelo IP predefinido do `web-server-target`, que é **`172.18.0.20`**.

        ```
        # Corefile para o dns-server
        . {
            health
            ready
            log
            errors
            hosts {
                172.18.0.20 target.lab # IP predefinido para o web-server-target
                fallthrough
            }
            forward . 8.8.8.8 # Encaminha outras requisições para o DNS público do Google
        }
        ```
    * **Reinicie o container `dns-server`** para que as mudanças no `Corefile` sejam aplicadas:

        ```bash
        docker restart dns_server_lab_6
        ```
2.  **Entrar no container Kali Linux:**

    Este será o ambiente onde você executará todos os comandos de rede. As ferramentas essenciais já estarão instaladas.

    ```bash
    docker exec -it kali_lab_6 /bin/bash
    ```

    * **Importante:** A partir daqui, todos os comandos são executados *dentro do terminal do Kali Linux* que você acabou de acessar (o prompt será `kali@<container_id>:` ou similar).
3.  **Configurar o DNS no Kali para usar nosso `dns-server`:**

    Para que o Kali consiga resolver o nome `target.lab` que criamos, precisamos apontá-lo para nosso servidor DNS interno.

    * Dentro do Kali, execute o comando com `sudo bash -c` para definir o nameserver. **A senha para o usuário `kali` é `kali`.**

        ```bash
        sudo bash -c 'echo "nameserver 172.18.0.30" > /etc/resolv.conf'
        ```
        password for kali: kali

4.  **Testar conectividade com `ping` e `traceroute`:**

    * **`ping target.lab`**: Verifica a conectividade básica com o `web-server-target` usando o nome de domínio.

        ```bash
        ping -c 4 target.lab
        ```

        * **Observação:** Você deve ver respostas, indicando que a resolução DNS e a conectividade estão funcionando.
    * **`traceroute target.lab`**: Rastreia o caminho que os pacotes levam até o `web-server-target`. Em um ambiente Docker, você verá os "saltos" internos da rede.

        ```bash
        traceroute target.lab
        ```

        * **Observação:** Analise os IPs dos "hospedeiros" que aparecem no caminho.
5.  **Consultar informações de domínio com `dig`:**

    * **`dig google.com A`**: Consulta o registro `A` (endereço IP) para `google.com`.

        ```bash
        dig google.com A
        ```

        * **Observação:** Você verá os endereços IP (IPv4) associados ao domínio.
    * **`dig google.com MX`**: Consulta os registros `MX` (Mail Exchange) para `google.com`, mostrando os servidores de e-mail.

        ```bash
        dig google.com MX
        ```

        * **Observação:** Estes são os servidores responsáveis por receber e-mails para o domínio.
    * **`dig google.com TXT`**: Consulta registros TXT, que podem conter informações importantes como registros SPF/DMARC para segurança de e-mail.

        ```bash
        dig google.com TXT
        ```

        * **Observação:** Explore a saída, mostrando como essas informações podem ser úteis para reconhecimento (ex: para identificar políticas de envio de e-mail).

### 🧹 Limpeza do Ambiente

Após concluir o laboratório, você pode parar e remover os containers para liberar recursos:

1.  **Saia do container Kali (se ainda estiver dentro):**

    ```bash
    exit
    ```
2.  **Pare e remova os containers e a rede criada:**

    ```bash
    docker compose down
    ```

---

### 🚀 Próximos Passos & Desafio Extra

Agora que você explorou os comandos básicos de rede e como interagem em um ambiente Docker, que tal expandir seu conhecimento?

* **Experimente com outros domínios:** Use o `dig` para investigar os registros de outros sites que você usa frequentemente. Que tipo de informações você consegue coletar?
* **Explore as opções do `traceroute`:** Tente usar as opções `-m` (máximo de saltos) e `-n` (não resolver nomes de host) para ver como elas alteram a saída.
* **Investigue o `nmap`:** Embora não tenhamos usado o `nmap` neste laboratório, ele é uma ferramenta essencial para varredura de redes. Que tal tentar instalar o `nmap` no container Kali e usá-lo para escanear o `web-server-target`?

Este laboratório é apenas o começo. A infraestrutura de rede é um campo vasto e fundamental para a segurança cibernética. Continue explorando e experimentando!