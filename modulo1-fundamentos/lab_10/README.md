## Laboratório Prático: Scan de Vulnerabilidades com OpenVAS (Greenbone)

Vamos usar o OpenVAS, uma das ferramentas de análise de vulnerabilidade mais robustas do mundo, para inspecionar um sistema-alvo em busca de falhas de segurança. Tudo isso em nosso ambiente Docker controlado e seguro.

**Objetivo:** Configurar e executar um scan de vulnerabilidades contra a máquina *Metasploitable* para identificar suas fraquezas.

---

## Parte 1: Iniciando o Ambiente (Setup Inicial)

1. Abra o terminal na pasta onde você salvou os arquivos `docker-compose.yml` e `setup-and-start-greenbone-community-edition.sh`.
2. Execute o script de inicialização:

```bash
./setup-and-start-greenbone-community-edition.sh
```

3. O script pedirá que você crie a senha para o usuário `admin`:

```plaintext
Password for admin user: ********
```

4. Aguarde a **sincronização dos feeds de segurança**.

> 🚨 **AVISO IMPORTANTE**: Este processo é **MUITO DEMORADO!** Pode levar de 30 minutos a várias horas. Acompanhe o progresso com:

```bash
docker compose logs -f gvmd
```

---

## Parte 2: Configurando e Executando o Scan

### Acesso à Interface Web

Acesse: [http://127.0.0.1:9392](http://127.0.0.1:9392)

- **Usuário**: `admin`
- **Senha**: A senha criada na Parte 1

---

### Criando o Alvo (Target)

1. Vá em: `Configuration > Targets`
2. Clique em **New Target** (`+` azul)
3. Preencha:
   - **Name**: `Alvo Metasploitable2`
   - **Hosts**: Selecione "Manually" e digite: `172.18.0.27`
4. Clique em **Save**

---

### Criando e Executando a Tarefa de Scan

1. Vá em: `Scans > Tasks`
2. Clique em **New Task** (`+` roxo)
3. Preencha:
   - **Name**: `Scan Completo no Alvo`
   - **Scan Target**: Selecione o alvo criado anteriormente
   - **Scan Config**: `Full and fast`
4. Clique em **Save**
5. Na lista de tarefas, clique em **Play (▶️)** para iniciar o scan

---

## Parte 3: Analisando os Resultados

1. Aguarde a finalização do scan (`Status: Done`)
2. Clique no link com a **data do relatório**
3. Explore os resultados por severidade:

- **High**: Críticas. Comece aqui!
- **Medium**: Relevantes
- **Low / Log**: Menor impacto

4. Clique em uma vulnerabilidade para ver detalhes:

- **Summary**
- **Detection Result**
- **Solution**

---

## Parte 4: Encerramento e Limpeza

Parabéns! Você acaba de realizar um scan de vulnerabilidades completo, como um analista de segurança de verdade faria.

Para desligar o ambiente:

```bash
docker compose down
```

Isso remove os contêineres e redes do laboratório.

---

## ⚙️ Extra: Kali Linux para testes ofensivos

O ambiente também possui uma máquina Kali Linux (container `kali-atacante`) conectada à mesma rede do laboratório.

Você pode acessá-la com:

```bash
docker exec -it kali-atacante bash
```

Ela vem com ferramentas pré-instaladas como:

- `nmap`
- `nikto`
- `burpsuite`
- `lynis`
- `curl`
- `ping`, `net-tools`, entre outros.

Use essa máquina para realizar testes ofensivos adicionais, exploração manual, ou até práticas de pivoting e análise ativa durante os scans.

---

## Dúvidas?

Qualquer dúvida, mandem no grupo!

**Bora pra cima! ⚔️**
