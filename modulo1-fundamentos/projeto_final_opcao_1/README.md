# Kensei CyberSec Lab - Docker Network Simulation

Este laboratório simula uma rede corporativa segmentada utilizando containers Docker.  
Ele é utilizado como parte da formação em cibersegurança do Módulo 1 - Reconhecimento e Mapeamento de Redes.

## Objetivo

Permitir que estudantes e profissionais pratiquem:

- Reconhecimento de rede (nmap, rustscan, netdiscover, arp-scan, etc.)
- Identificação e inventário de ativos
- Análise de exposição de serviços
- Documentação técnica com foco em valor e clareza

## Arquitetura Simulada

A rede simulada contém:

- Estações de trabalho (workstations)
- Dispositivos convidados (guest)
- Impressoras em rede
- Servidor de arquivos
- Servidor web
- Três sub-redes segmentadas (corporativa, visitante e infraestrutura)

## Como Rodar o Lab

Pré-requisitos: Docker e Docker Compose

```bash
git clone https://github.com/Kensei-CyberSec-Lab/formacao-cybersec/
cd formacao-cybersec/modulo1-fundamentos/projeto_final_opcao_1/
docker-compose up -d
```

Acesse os serviços simulados:
- Webserver: http://localhost:8080

Utilize ferramentas como `nmap`, `rustscan`, `netdiscover` ou Wireshark para explorar a rede.

## Documentação do Projeto

A pasta `/docs` conterá:
- Instruções detalhadas para o aluno
- Roteiro de análise sugerido
- Modelo de relatório técnico

## Licença

MIT – Kensei CyberSec Lab
