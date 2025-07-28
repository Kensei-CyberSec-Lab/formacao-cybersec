# Kensei CyberSec - Laboratório da Aula 8 (v2)
## Tema: Endereçamento IP, Sub-redes e Mapeamento de Rede

Olá, time! Este laboratório foi projetado para demonstrar de forma prática como o endereçamento IP e a divisão de redes (subnetting) funcionam para controlar a comunicação e segmentar ambientes. 🥷

### 🎯 **Objetivo**
- Entender como um dispositivo em múltiplas redes pode (ou não) se comunicar com outros.
- Usar ferramentas como `ip addr`, `nmap` e `arp-scan` para mapear a conectividade.
- Compreender a diferença de performance e uso entre diferentes ferramentas de descoberta.

### ⚙️ **Pré-requisitos**
- Docker e Docker Compose instalados e funcionando.
- Git para clonar o repositório.

### 🚀 **Como Iniciar o Laboratório**


    **Inicie os containers em segundo plano:**
    ```bash
    docker compose up -d
    ```

### ⚔️ **Mão na Massa: O Desafio**

#### **Passo 1: "Onde Estou?" - Identificando Nossas Conexões**
Acesse o terminal do atacante e verifique seus IPs.

```bash
docker exec -it maquina-atacante /bin/sh
ip addr
ifconfig
```
Você deve ver as interfaces `eth0` (rede RH, `172.20.10.100/24`) e `eth1` (rede Visitantes, `192.168.100.100/24`).

#### **Passo 2: "Quem Está Comigo?" - Mapeando a Vizinhança**
Agora vamos encontrar outros hosts. Temos duas ótimas opções.

##### **Método Padrão (Nmap)**
O Nmap é a ferramenta padrão por ser versátil e confiável.
```bash
# Escaneando a rede do RH
nmap -sn -T4 172.20.10.0/24

# Escaneando a rede de Visitantes
nmap -sn -T4 192.168.100.0/24
```
Você encontrará os hosts `.10` (servidor-rh) e `.30` (impressora) em suas respectivas redes.

##### **Método Rápido para Redes Locais (arp-scan) 🏆**
Para redes locais, `arp-scan` é especialista e muito mais rápido, pois foca apenas no protocolo ARP.

```bash
# Escaneando a rede do RH pela interface eth0
arp-scan -I eth0 --localnet

# Escaneando a rede de Visitantes pela interface eth1
arp-scan -I eth1 --localnet
```
A resposta será quase instantânea, mostrando os IPs e os MAC addresses dos hosts encontrados.

#### **🧠 Deep Dive: Por que `arp-scan` é mais rápido aqui?**

-   **`arp-scan`** envia pacotes ARP para todos os IPs da sub-rede. Como o ARP é um protocolo de camada 2, ele não precisa passar por camadas mais complexas do modelo OSI. A comunicação é direta com as placas de rede na rede local, tornando a resposta extremamente rápida.
-   **`nmap -sn`** é mais complexo. Por padrão, ele envia múltiplos pacotes para ter certeza: um ICMP echo request (ping), pacotes TCP para as portas 80 e 443, e um ARP request. Ele faz isso para ser eficaz em diferentes tipos de rede e contra firewalls. Toda essa lógica extra e a espera por timeouts de pacotes que não são ARP tornam o processo um pouco mais demorado.

### 🧹 **Limpeza do Ambiente**

Quando terminar, saia do container (`exit`) e derrube o ambiente na sua máquina host:

```bash
docker compose down
```
---