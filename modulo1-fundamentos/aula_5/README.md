# Lab de Reconhecimento & Footprinting – Aula #5

Este repositório traz um **ambiente Docker completo** para praticar enumeração
e OSINT de forma segura, pensado para iniciantes da Formação CyberSec.

## Estrutura

```
aula_5/
├── docker-compose.yml
├── kali/
│   └── Dockerfile
└── lab_target/
    ├── Dockerfile
    └── resources/
        └── vault/
            └── flag.txt
```

* **kali/** – container com ferramentas ofensivas (gobuster, theHarvester, nmap…).
* **lab_target/** – servidor Apache expondo um diretório “oculto” `/vault/` com a flag.
* **flag.txt** – arquivo que você deve descobrir usando as técnicas de aula.

## Pré‑requisitos

* Docker + Docker Compose (v2 ou superior).

## Subindo o lab

```bash
git clone <este‑repo-ou-descompacte-o-zip>
cd aula_5
docker compose up -d --build
```

## Passo‑a‑passo sugerido

1. **Entrar no Kali**

   ```bash
   docker exec -it kali_lab_5 /bin/bash
   ```

2. **Checar se o alvo responde**

   ```bash
   curl -I http://lab_target   # ou ping lab_target
   ```

3. **Enumerar diretórios** (footprinting ativo):

   ```bash
   gobuster dir -u http://lab_target/ \
                -w /usr/share/wordlists/dirb/common.txt -t 20
   # Deve aparecer /vault/
   ```

4. **Descobrir a flag**

   ```bash
   curl http://lab_target/vault/flag.txt
   # Saída: FLAG-{RECON-STARTS-WITH-OSINT}
   ```

5. **Gerar o SHA‑256**

   ```bash
   echo -n "FLAG-{RECON-STARTS-WITH-OSINT}" | sha256sum
   ```

6. **CTA – o que entregar**

   Poste no grupo/portal:
   ```
   Flag: FLAG-{RECON-STARTS-WITH-OSINT}
   SHA‑256: <hash>
   Risco: diretório público não listado expõe dados sensíveis.
   ```

## Finalizar

```bash
docker compose down
```

---

### Por que esse lab é importante?

* **OSINT + Footprinting** são as **primeiras fases** da Cyber Kill Chain.
* Você pratica a transição de coleta **passiva** (descobrir IP/host) para **ativa** (varrer diretórios).
* Aprende a **validar integridade** via hash (Confidencialidade & Integridade do modelo CIA).

Bons estudos – e lembre‑se: **informação exposta é convite para invasores.** Proteja antes que alguém a encontre!
