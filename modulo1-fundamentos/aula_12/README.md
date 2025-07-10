# Laboratório Prático: Scan de Vulnerabilidades com OpenVAS (Greenbone)

Vamos usar o OpenVAS, uma das ferramentas de análise de vulnerabilidade mais robustas do mundo, para inspecionar um sistema-alvo em busca de falhas de segurança. Tudo isso em nosso ambiente Docker controlado e seguro.

**Objetivo:** Configurar e executar um scan de vulnerabilidades contra a máquina *Metasploitable* para identificar suas fraquezas.

---

## Parte 1: Iniciando o Ambiente (Setup Inicial)

1. Abra o terminal na pasta onde você salvou os arquivos `docker-compose.yml` e `setup-and-start-greenbone-community-edition.sh`.
2. Execute o script de inicialização:

```bash
./setup-and-start-greenbone-community-edition.sh
```
3. O script pedirá que você crie a senha para o usuário admin:
```
Password for admin user: ********
```

