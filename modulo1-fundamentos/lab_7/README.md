# Formação CyberSec ⚔️ - Guia de Aula Prática #9: Seu Dojo de Ataque no Kali Linux

Olá, guerreiro(a) cibernético(a)!

Este documento é a nossa **Aula Prática #9**. Hoje, vamos configurar e explorar a ferramenta mais essencial no arsenal de um profissional de segurança: o **Kali Linux**. Este não é apenas um arquivo de instruções; é a sua aula. Siga cada passo, leia as explicações e, o mais importante, execute os comandos para sentir o poder na ponta dos seus dedos.

Nosso objetivo é duplo:
1.  **Dominar o Terminal (CLI):** Aprender a "lâmina", a forma mais pura, rápida e poderosa de interagir com sistemas.
2.  **Explorar o Arsenal (GUI):** Entender quando e como usar a interface gráfica para ferramentas visuais e descoberta.

Vamos começar.

---

## Parte 1: O Que é o Kali Linux e Por Que Começamos pelo Terminal?

Antes de mergulhar na prática, entenda sua ferramenta. O **Kali Linux** é uma distribuição de Linux (baseada em Debian) criada especificamente para tarefas de segurança e pentest. Pense nele como um canivete suíço com centenas de lâminas afiadas: ferramentas para mapear redes, encontrar vulnerabilidades, explorar falhas, analisar senhas e muito mais.

Nós começamos pelo **Terminal (CLI - Command-Line Interface)** porque no mundo real:

* **É o que você encontra:** Na maioria das vezes, o acesso a um sistema invadido é uma tela preta, não um desktop bonito.
* **É rápido e eficiente:** Sem o peso de uma interface gráfica, os comandos voam.
* **É o caminho da automação:** Scripts que automatizam ataques ou defesas rodam no terminal.

Agora que a filosofia está clara, vamos sujar as mãos.

## Parte 2: Laboratório Prático 1 - O Caminho da Lâmina (CLI)

Nesta seção, vamos construir nosso dojo de linha de comando e praticar os movimentos fundamentais. O desafio da aula já está "assado" dentro do ambiente.

### 2.1 Preparando e Acessando seu Dojo

1.  **Navegue até a pasta do lab:**
    Abra seu terminal e certifique-se de que você está no diretório `kali-cli`.

2.  **Construa e inicie o ambiente:**
    ```bash
    # O comando --build é essencial na primeira vez para criar a imagem com o desafio.
    docker compose up -d --build
    ```

3.  **Entre no seu Dojo:**
    Com o ambiente rodando, vamos entrar no terminal interativo do Kali.
    ```bash
    # Este comando nos dá um shell de bash dentro do container 'kali_cli_kensei'
    docker exec -it kali_cli_kensei /bin/bash
    ```
    Seu prompt de comando mudou para `root@...:/#`. Você está dentro.

### 2.2 Dominando os Comandos Essenciais

Vamos treinar. Execute cada comando e entenda o que ele faz.

1.  **Onde estou? (`pwd`)**: Descubra o diretório atual.
2.  **O que há ao meu redor? (`ls -la`)**: Liste os arquivos e diretórios.
3.  **Indo para casa (`cd /root`)**: Navegue para o diretório "home" do usuário root.
4.  **Criando nosso espaço de treino (`mkdir espaco_de_treino`)**: Crie um diretório.
5.  **Escrevendo nosso primeiro pergaminho (`echo "texto" > arquivo.txt`)**: Crie um arquivo com conteúdo.
6.  **Lendo o pergaminho (`cat arquivo.txt`)**: Exiba o conteúdo de um arquivo.

### 2.3 Desafio: Encontrando o Pergaminho Secreto

Agora que você está aquecido, um teste final. O desafio (`.segredo_dojo`) já está no sistema.

* **Sua Missão:** Encontrar e ler o conteúdo do arquivo `.segredo_dojo`.
* **Pistas:**
    * Ele está em um diretório oculto (o nome do diretório começa com `.`).
    * Este diretório está na pasta `/root`.

Use `ls -la`, `cd` e `cat` para encontrar a flag!

### 2.4 Limpando o Dojo

1.  **Saindo do Kali:** `exit`
2.  **Desligando o Ambiente:** Na pasta `kali-cli`, rode `docker compose down`.

---

## Parte 3: Laboratório Prático 2 - O Arsenal Completo (GUI)

Você provou que pode lutar com a lâmina nua. Agora, vamos explorar o arsenal tecnológico que uma interface gráfica oferece.

### 3.1 Ferramenta Essencial: O VNC Viewer

Para acessar o desktop do nosso Kali, que está rodando "escondido" no Docker, precisamos de um programa cliente. Pense no VNC (Virtual Network Computing) como uma "janela" mágica para dentro do container.

Escolha o instalador para o seu sistema operacional:

* **Para Windows:** Baixe e instale o **[RealVNC Viewer](https://www.realvnc.com/en/connect/download/viewer/windows/)**. A instalação é um processo padrão de "próximo-próximo-concluir".

* **Para macOS:** Você pode usar o cliente nativo.
    1.  Clique em qualquer lugar da sua Mesa (Desktop).
    2.  No menu superior, vá em `Ir > Conectar ao Servidor...`.
    3.  Digite `vnc://localhost:5901` e clique em Conectar.
    * Como alternativa, você também pode baixar o **[RealVNC Viewer para Mac](https://www.realvnc.com/en/connect/download/viewer/macos/)**.

* **Para Linux (Debian/Ubuntu):** Instale o **Remmina**, um cliente excelente e versátil.
    ```bash
    sudo apt-get update
    sudo apt-get install -y remmina remmina-plugin-vnc
    ```
    Depois de instalar, procure por "Remmina" nos seus aplicativos.

Com seu cliente VNC instalado, você está pronto para o próximo passo.

### 3.2 Preparando e Acessando o Ambiente Gráfico

1.  **Navegue e Inicie:**
    Vá para a pasta `kali-gui` no seu terminal e execute:
    ```bash
    # Este build pode ser demorado, pois instala centenas de ferramentas.
    docker compose up -d --build
    ```

2.  **Conecte-se via VNC:**
    * Abra o seu programa VNC Viewer instalado no passo anterior.
    * Ele pedirá um endereço de servidor para se conectar. Digite: `localhost:5901`
    * Pressione Enter. Quando a senha for solicitada, digite: `kensei`

Bem-vindo ao desktop completo do Kali!

### 3.3 Explorando o Arsenal Visual (Alinhado ao MITRE ATT&CK®)

Clique no menu de aplicações (o ícone do dragão do Kali). Você notará que as categorias seguem as táticas do framework **MITRE ATT&CK®**, o padrão da indústria. Sua tarefa é explorar:

* Em `01 - Reconnaissance` (Reconhecimento), você encontrará ferramentas como `nmap` e `maltego`.
* Em `08 - Credential Access` (Acesso a Credenciais), você achará o arsenal para quebra de senhas, como `hashcat` e `john`.
* Em `03 - Initial Access` (Acesso Inicial) e `04 - Execution` (Execução), você encontrará o poderoso `metasploit-framework`.

Crie este novo mapa mental, que é muito mais alinhado com um processo de pentest profissional.

### 3.4 Encerrando o Laboratório Gráfico

1.  Feche a janela do VNC Viewer.
2.  No seu terminal, na pasta `kali-gui`, desligue o ambiente: `docker compose down`.

---

## Conclusão da Aula

Parabéns! Hoje você montou e explorou seu **dojo de ataque com Kali Linux**, uma peça fundamental que se junta ao seu crescente arsenal de laboratórios de segurança. Você aprendeu a importância do terminal, praticou os comandos essenciais e entendeu o lugar da interface gráfica no seu cinto de ferramentas.

A prática constante leva à maestria. Repita esses laboratórios, assim como os anteriores, até que os comandos se tornem memória muscular.

Até a próxima aula, onde usaremos nosso novo dojo CLI para a primeira missão real: Reconhecimento com Nmap.

**desligando.** 🥷
