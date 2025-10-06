# Aula 40 – Metasploit básico

**Módulo:** Módulo 3 – Ethical Hacking e Projetos Reais

**Duração sugerida:** 1h30

**Nível:** Intermediário

**Alvo do lab:** https://acme-corp-lab.com/ — **Autorização:** executar apenas contra este ambiente de laboratório autorizado. Registre autorização escrita no relatório.

## Estrutura do repositório

- `HACKER_STORY.md` — narrativa que guia o aluno pelos passos do lab (modo hands-on com comandos). 
- `docker-compose.yml` — compose para Kali + Metasploit (multi-arch). 
- `investigation_report.md` — template de relatório para entrega. 
- `module_list_tested.txt` — arquivo para registrar módulos e parâmetros testados.
- `results/` — pasta gerada pelos alunos com saídas do Metasploit.

## Como usar

1. Clonar o repositório

```bash
git clone <repo-url>
cd aula_40_metasploit
```

2. Levantar o ambiente Docker

```bash
# para AMD64 (padrão)
docker-compose up -d --build

# em Apple Silicon / ARM64
PLATFORM=linux/arm64 docker-compose up -d --build
```

3. Entrar no container Kali e seguir o HACKER_STORY.md

```bash
docker exec -it kensei_kali /bin/bash
cd /home/kali/investigations
```

> IMPORTANT: Use somente IPs/domínios autorizados (acme-corp-lab.com) e siga as regras de engajamento.

## Entregáveis mínimos

- `results/msf_scan_http_version.txt`
- `results/msf_scan_ssh_version.txt`
- `results/db_export_msf.xml`
- `module_list_tested.txt`
- `investigation_report.md` preenchido
