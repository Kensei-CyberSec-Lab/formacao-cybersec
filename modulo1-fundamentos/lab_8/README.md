Laboratório Aula 10: Metodologia de Scan Profissional
Bem-vindo ao laboratório de varredura de portas. Neste exercício, vamos aplicar uma metodologia de scan profissional em duas fases para mapear a infraestrutura de uma empresa fictícia, usando as ferramentas certas para cada tarefa.

🎯 Objetivo
Reconhecimento Inicial: Descobrir em quais redes estamos conectados.

Fase 1 (Descoberta de Hosts): Usar o nmap para identificar rapidamente quais hosts (IPs) estão ativos em cada segmento de rede.

Fase 2 (Análise de Portas): Usar o rustscan para escanear de forma ultra-rápida as portas dos hosts que descobrimos.

Analisar os resultados para entender a topologia e os serviços expostos.

🚀 Passo a Passo
1. Preparar e Acessar o Laboratório
```
# Se precisar, reconstrua o ambiente com as últimas atualizações
docker compose up -d --build

# Acesse o container do atacante
docker exec -it attacker-1 /bin/bash

2. Reconhecimento do Terreno (Onde Estou?)
Antes de atacar, um bom hacker primeiro olha ao seu redor para descobrir em quais redes a máquina está conectada.

ifconfig
```

Você verá que está conectado a duas redes: 172.18.0.0/24 (DMZ) e 172.19.0.0/24 (Rede Interna).

Nota Tática: Este laboratório simula um cenário onde você já "pivotou" da DMZ para a Rede Interna, por isso tem acesso a ambas.

3. Fase 1: Descoberta Rápida de Hosts com Nmap
Use o nmap no modo "ping scan" (-sn) para encontrar os hosts ativos em cada rede.


```
#DMZ: 
nmap -sn -T4 172.18.0.0/24 -oG - | grep "Up"

#Rede Interna: 
nmap -sn -T4 172.19.0.0/24 -oG - | grep "Up"
```

Anote os IPs que você encontrou.

4. Fase 2: Análise de Portas Direcionada com RustScan
Com a lista de alvos em mãos, vamos usar a velocidade do rustscan para uma varredura de portas profunda, mas apenas nos IPs que encontramos.

A. Análise da DMZ
# Substitua pelos IPs que você encontrou na DMZ
```
rustscan -a <IP_DMZ_1>,<IP_DMZ_2> -- -A -oN scan_dmz.nmap
```

B. Análise da Rede Interna
# Substitua pelos IPs que você encontrou na Rede Interna
```
rustscan -a <IP_INTERNO_1>,<IP_INTERNO_2>... -- -A -oN scan_interna.nmap
```

5. Análise dos Resultados
Inspecione os arquivos de saída (cat scan_dmz.nmap e cat scan_interna.nmap). Tente responder:

Quais serviços, portas e versões você conseguiu identificar em cada host?

Algum serviço parece ser uma versão antiga ou potencialmente vulnerável?

6. Próximo Passo: O Desafio!
Agora que você aprendeu a metodologia, aplique seu conhecimento no desafio prático! Siga as instruções no arquivo CTF.md.

7. Encerrar o Laboratório
Quando terminar tudo, saia do container (exit) e desligue o laboratório.

```
docker compose down
```