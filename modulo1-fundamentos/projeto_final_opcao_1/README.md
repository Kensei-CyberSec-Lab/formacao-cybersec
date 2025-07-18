
# Projeto Técnico: Mapeamento de Rede Corporativa – Lab Docker

Este projeto é parte da Trilha de Formação em Cybersecurity – Módulo 1.  
O objetivo é simular uma rede corporativa segmentada com estações de trabalho, servidores e dispositivos pessoais para que você possa treinar suas habilidades de reconhecimento e análise de exposição.

---

## 🎯 Desafio

Seu desafio é assumir o papel de um analista de segurança que recebeu acesso à rede interna de uma empresa para realizar um mapeamento de ativos e sub-redes.

### Objetivos:
- Identificar todas as máquinas acessíveis.
- Determinar as sub-redes existentes e seus propósitos.
- Criar um inventário técnico com IPs, nomes e sistemas detectados.
- Elaborar um relatório com diagnóstico, recomendações e plano de ação 80/20.

---

## 🛠️ Como rodar o ambiente

### Pré-requisitos
- Docker e Docker Compose instalados

### Passos:
1. Clone o repositório:
   ```bash
   git clone https://github.com/Kensei-CyberSec-Lab/formacao-cybersec.git
   cd formacao-cybersec/modulo1-fundamentos/projeto_final_opcao_1
   ```

2. Suba o ambiente:
   ```bash
   docker compose up -d
   ```

---

## 💻 Máquina Analyst

Você realizará as análises a partir do container `analyst`, que já possui ferramentas como `nmap`, `rustscan`, `net-tools` e `dig`.

Acesse com:
```bash
docker exec -it analyst bash
```

A `analyst` está conectada na rede `corp_net` com IP Dinâmico em `10.10.10.0/24`.
A `analyst` está conectada na rede `guest_net` com IP Dinâmico em `10.10.30.0/24`.
A `analyst` está conectada na rede `infra_net` com IP Dinâmico em `10.10.50.0/24`.

---

## 🌐 Acesso às Redes

O ambiente está segmentado em 3 redes principais:

| Rede        | Subnet           | Descrição                                    |
|-------------|------------------|----------------------------------------------|
| `corp_net`  | 10.10.10.0/24  | Rede corporativa (estações e web server)     |
| `guest_net` | 10.10.30.0/24  | Rede de visitantes e dispositivos pessoais   |
| `infra_net` | 10.10.50.0/24  | Rede de infraestrutura crítica (servidores)  |

Você pode testar o acesso às redes e suas máquinas com:
```bash
ping 10.10.10.10    # Teste uma estação corporativa
ping 10.10.30.11    # Teste o MySQL da infraestrutura
```

> Para explorar de forma mais avançada, utilize `nmap`, `rustscan`, `dig`, `telnet`, etc.

---

## 🧩 Dica

Explore os nomes e IPs das máquinas, anote padrões e tente encontrar ativos fora do padrão — isso também é parte do diagnóstico.

---

## 📄 Exemplos e Modelo de Relatório

Você pode se basear no arquivo `exemplo_documentacao_redes.md` e no modelo de estrutura apresentado na aula “Como Fazer Documentação Técnica Profissional”.

---

Bons testes!
