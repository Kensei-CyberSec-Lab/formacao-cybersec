
# Formação CyberSec – Módulo 2

## Aula 1 – Defesa em Profundidade (Ambiente Base)

Este é o ambiente inicial do Módulo 2. Ele simula um cenário **sem nenhuma proteção**, onde você poderá observar vulnerabilidades em uma aplicação real.

---

### Serviços incluídos no lab

| Serviço       | Descrição                                 | Acesso                        | Host                        |
|---------------|-------------------------------------------|-------------------------------|                             |
| Juice Shop    | Aplicação web vulnerável OWASP            | http://localhost:3000         | juice_shop                  |
| Ubuntu Host   | Servidor Linux para aplicar hardening     | Acesso via `docker exec`      | ubuntu_host                 |
| Kali Linux    | Máquina de ataque com ferramentas         | Acesso via `docker exec`      | kali_host                   |

---

### Como subir o ambiente

1. Clone este repositório (se ainda não fez isso):

```bash
git clone https://github.com/Kensei-CyberSec-Lab/formacao-cybersec.git
cd formacao-cybersec/modulo2-defesa/aula_1
```

2. Suba o ambiente com Docker Compose:

```bash
docker compose up -d
```

3. Verifique os containers ativos:

```bash
docker ps
```

4. Acesse o Kali para começar os testes:

```bash
docker exec -it kali /bin/bash
```

---

### Objetivo da Aula 1

- Entender o conceito de **Defesa em Profundidade**
- Observar um ambiente vulnerável antes da aplicação de defesas
- Identificar riscos e pensar como um atacante

---

### Experimentos sugeridos

- Acessar o Juice Shop via navegador e explorar as páginas
- Listar os serviços rodando no Ubuntu (`ps aux`, `netstat`, etc.)
- Tentar escanear o Juice Shop a partir do Kali com `nmap`

---

### Observação

Este ambiente **ainda não possui firewall, hardening ou monitoramento**. Todas essas camadas serão adicionadas gradualmente nas próximas aulas.

---

### Para encerrar o ambiente

```bash
docker compose down
```

---

© Kensei CyberSec Lab – Formação CyberSec
