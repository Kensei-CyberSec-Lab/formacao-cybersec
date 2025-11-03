# Ambiente de Testes de Penetração Kali Linux
# Makefile para facilitar o gerenciamento de containers

.PHONY: help build up down cli gui logs clean rebuild connect-cli connect-gui status

# Target padrão
help:
	@echo "🐉 Ambiente de Testes de Penetração Kali Linux"
	@echo "==============================================="
	@echo ""
	@echo "Comandos disponíveis:"
	@echo "  make build       - Construir todos os containers"
	@echo "  make up          - Iniciar todos os containers"
	@echo "  make down        - Parar todos os containers"
	@echo "  make cli         - Iniciar apenas o container CLI"
	@echo "  make gui         - Iniciar apenas o container GUI"
	@echo "  make connect-cli - Conectar ao container CLI"
	@echo "  make connect-gui - Mostrar informações de conexão GUI"
	@echo "  make logs        - Mostrar logs dos containers"
	@echo "  make status      - Mostrar status dos containers"
	@echo "  make clean       - Limpar containers e volumes"
	@echo "  make rebuild     - Reconstruir e reiniciar containers"
	@echo ""
	@echo "Acesso GUI:"
	@echo "  Cliente VNC: localhost:5901 (senha: kalilinux)"
	@echo "  Web VNC:     http://localhost:6080"

# Construir todos os containers
build:
	@echo "🔨 Construindo containers Kali Linux..."
	cd conf && docker-compose build

# Iniciar todos os containers
up:
	@echo "🚀 Iniciando todos os containers..."
	cd conf && docker-compose up -d
	@echo "✅ Containers iniciados!"
	@echo ""
	@echo "Acesso CLI: make connect-cli"
	@echo "Acesso GUI: make connect-gui"

# Parar todos os containers
down:
	@echo "🛑 Parando todos os containers..."
	cd conf && docker-compose down

# Iniciar apenas o container CLI
cli:
	@echo "🚀 Iniciando container Kali CLI..."
	cd conf && docker-compose up -d kali-cli
	@echo "✅ Container CLI iniciado!"
	@echo "Conectar com: make connect-cli"

# Iniciar apenas o container GUI
gui:
	@echo "🚀 Iniciando container Kali GUI..."
	cd conf && docker-compose up -d kali-gui
	@echo "✅ Container GUI iniciado!"
	@echo "Conectar com: make connect-gui"

# Conectar ao container CLI
connect-cli:
	@./scripts/connect-cli.sh

# Mostrar informações de conexão GUI
connect-gui:
	@./scripts/connect-gui.sh

# Mostrar logs dos containers
logs:
	@echo "📋 Logs dos containers:"
	cd conf && docker-compose logs -f

# Mostrar status dos containers
status:
	@echo "📊 Status dos containers:"
	cd conf && docker-compose ps
	@echo ""
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" --filter "name=kali"

# Limpar tudo
clean:
	@echo "🧹 Limpando containers e volumes..."
	cd conf && docker-compose down -v --remove-orphans
	docker system prune -f
	@echo "✅ Limpeza concluída!"

# Reconstruir e reiniciar
rebuild:
	@echo "🔄 Reconstruindo containers..."
	cd conf && docker-compose down
	cd conf && docker-compose build --no-cache
	cd conf && docker-compose up -d
	@echo "✅ Reconstrução concluída!"

# Tornar scripts executáveis
setup:
	@echo "🔧 Configurando scripts..."
	chmod +x scripts/connect-cli.sh
	chmod +x scripts/connect-gui.sh
	chmod +x scripts/setup.sh
	@echo "✅ Scripts agora são executáveis!"