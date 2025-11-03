# Índice da Documentação

## 📚 Documentação Principal

### Começando
- **[README.md](../README.md)** - Documentação principal do projeto e guia de início rápido
- **[REFERENCIA-RAPIDA.md](REFERENCIA-RAPIDA.md)** - Referência rápida de comandos e tarefas comuns
- **[SOLUCAO-PROBLEMAS.md](SOLUCAO-PROBLEMAS.md)** - Problemas comuns e soluções

### Como Começar
1. Leia o [README.md](../README.md) principal
2. Execute `./scripts/setup.sh` para configuração interativa
3. Use [REFERENCIA-RAPIDA.md](REFERENCIA-RAPIDA.md) para operações diárias
4. Consulte [SOLUCAO-PROBLEMAS.md](SOLUCAO-PROBLEMAS.md) se surgirem problemas

## 📁 Estrutura do Projeto

```
attacker/
├── README.md                    # Documentação principal
├── Makefile                     # Comandos de build e gerenciamento
├── conf/                        # Arquivos de configuração
│   ├── docker-compose.yml       # Orquestração de containers
│   ├── .env                     # Variáveis de ambiente
│   ├── supervisord.conf         # Configuração do supervisor de processos
│   ├── Dockerfile.kali-cli      # Definição do container CLI
│   ├── Dockerfile.kali-gui      # Definição do container GUI
│   └── .dockerignore            # Regras de ignore do Docker
├── scripts/                     # Scripts auxiliares
│   ├── setup.sh                # Configuração interativa
│   ├── connect-cli.sh           # Conectar ao container CLI
│   └── connect-gui.sh           # Auxiliar de conexão GUI
├── docs/                        # Documentação
│   ├── README.md                # Documentação detalhada
│   ├── REFERENCIA-RAPIDA.md     # Referência rápida
│   └── SOLUCAO-PROBLEMAS.md     # Solução de problemas
└── shared/                      # Pasta compartilhada entre host e containers
```

## 🎯 Acesso Rápido

### Para Estudantes
- **Comece aqui**: [README Principal](../README.md)
- **Comandos rápidos**: [Referência Rápida](REFERENCIA-RAPIDA.md)
- **Problemas?**: [Solução de Problemas](SOLUCAO-PROBLEMAS.md)

### Para Instrutores
- **Configuração**: Use `make setup && make build && make up`
- **Gerenciamento**: Consulte o [Makefile](../Makefile) para todos os comandos
- **Monitoramento**: Use `make status` e `make logs`

## 🚀 Comandos Essenciais

### Configuração Inicial
```bash
./scripts/setup.sh    # Configuração guiada passo a passo
```

### Operação Diária
```bash
make up               # Iniciar ambiente
make connect-cli      # Acessar terminal CLI
make connect-gui      # Informações acesso GUI
make down            # Parar ambiente
```

### Solução de Problemas
```bash
make status          # Verificar status
make logs           # Ver logs dos containers
make clean          # Limpeza completa
make rebuild        # Reconstruir tudo
```

## 📖 Sobre este Ambiente

Este ambiente de containers Kali Linux foi projetado especificamente para:

✅ **Educação em Cibersegurança** - Ferramentas completas para aprendizado
✅ **Desafios CTF** - Ambiente isolado e seguro para competições
✅ **Testes de Penetração** - Suite completa de ferramentas profissionais
✅ **Laboratórios Práticos** - Configuração rápida e fácil reset

### Características Principais
- **Dois ambientes**: CLI (terminal) e GUI (desktop)
- **Ferramentas completas**: Todas as ferramentas do Kali Linux
- **Isolamento**: Containers isolados do sistema host
- **Persistência**: Dados preservados entre reinicializações
- **Compartilhamento**: Pasta compartilhada entre host e containers