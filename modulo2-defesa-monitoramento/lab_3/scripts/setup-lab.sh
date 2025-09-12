#!/bin/bash

# Script de Setup para Laboratório de Firewall
# Autor: Formação CyberSec
# Versão: 1.0

echo "🔥 Configurando Laboratório de Firewall..."
echo "=========================================="

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir com cores
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar se Docker está instalado
print_status "Verificando Docker..."
if ! command -v docker &> /dev/null; then
    print_error "Docker não está instalado. Instale o Docker primeiro."
    exit 1
fi

# Verificar se Docker Compose está instalado
print_status "Verificando Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose não está instalado. Instale o Docker Compose primeiro."
    exit 1
fi

print_success "Docker e Docker Compose encontrados!"

# Verificar se as portas estão livres
print_status "Verificando portas necessárias..."
if netstat -tuln 2>/dev/null | grep -q ":6083 "; then
    print_warning "Porta 6083 já está em uso. Certifique-se de que não há conflitos."
fi

if netstat -tuln 2>/dev/null | grep -q ":5903 "; then
    print_warning "Porta 5903 já está em uso. Certifique-se de que não há conflitos."
fi

# Parar containers existentes se houver
print_status "Parando containers existentes..."
docker-compose down 2>/dev/null

# Iniciar containers
print_status "Iniciando containers do laboratório..."
docker-compose up -d

# Aguardar containers iniciarem
print_status "Aguardando containers iniciarem..."
sleep 15

# Verificar status dos containers
print_status "Verificando status dos containers..."
sleep 5  # Aguardar um pouco mais para os containers inicializarem

if docker ps | grep -q "firewall_lab3_kali" && \
   docker ps | grep -q "firewall_lab3_ubuntu" && \
   docker ps | grep -q "firewall_lab3_gui"; then
    print_success "Todos os containers estão rodando!"
else
    print_warning "Verificando containers disponíveis..."
    docker ps
    print_status "Aguardando mais tempo para inicialização..."
    sleep 10
    if docker ps | grep -q "firewall_lab3_kali" && \
       docker ps | grep -q "firewall_lab3_ubuntu" && \
       docker ps | grep -q "firewall_lab3_gui"; then
        print_success "Todos os containers estão rodando!"
    else
        print_error "Alguns containers não iniciaram corretamente."
        docker ps
        exit 1
    fi
fi

# Inicializar laboratório
print_status "Inicializando configurações do laboratório..."
# Iniciar rsyslog no container Ubuntu
docker exec firewall_lab3_ubuntu rsyslogd 2>/dev/null || true
# Iniciar SSH no container Ubuntu
docker exec firewall_lab3_ubuntu service ssh start 2>/dev/null || true
# Iniciar Apache no container Ubuntu
docker exec firewall_lab3_ubuntu service apache2 start 2>/dev/null || true

# Aguardar serviços iniciarem
print_status "Aguardando serviços iniciarem..."
sleep 3

# Configurar Ubuntu GUI (se necessário)
print_status "Configurando Ubuntu GUI..."
docker exec --user root firewall_lab3_gui bash -c "apt-get update && apt-get install -y iptables iptables-persistent sudo docker.io docker-compose" 2>/dev/null || true
docker exec --user root firewall_lab3_gui bash -c "useradd -m -s /bin/bash -u 1000 defaultuser 2>/dev/null || true" 2>/dev/null || true
docker exec --user root firewall_lab3_gui bash -c "echo 'defaultuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers" 2>/dev/null || true

# Copiar script wrapper para GUI
print_status "Copiando script wrapper para GUI..."
docker cp scripts/iptables-gui.sh firewall_lab3_gui:/usr/local/bin/iptables-gui
docker exec --user root firewall_lab3_gui chmod +x /usr/local/bin/iptables-gui

# Mostrar informações de acesso
echo ""
echo "🎉 Laboratório configurado com sucesso!"
echo "========================================"
echo ""
echo "📱 Acesse a interface gráfica:"
echo "   Navegador: http://localhost:6083"
echo "   VNC: localhost:5903 (senha: kenseilab)"
echo "   Usuário: defaultuser (já configurado com sudo)"
echo ""
echo "🔒 Configurações automáticas incluídas:"
echo "   ✅ iptables instalado e configurado"
echo "   ✅ sudo configurado para defaultuser"
echo "   ✅ Script wrapper: iptables-gui (na interface gráfica)"
echo "   ✅ Scripts de firewall disponíveis no Ubuntu container"
echo "   ✅ Scripts de teste disponíveis no host"
echo ""
echo "🖥️  Acesse os terminais:"
echo "   Kali: docker exec -it firewall_lab3_kali bash"
echo "   Ubuntu: docker exec -it firewall_lab3_ubuntu bash"
echo ""
echo "💡 Dicas rápidas:"
echo "   Na interface gráfica: iptables-gui -L (listar regras)"
echo "   Na interface gráfica: iptables-gui -A (aplicar regras)"
echo "   No Ubuntu container: docker exec -it firewall_lab3_ubuntu /opt/lab-scripts/iptables-example.sh apply"
echo "   Teste o firewall: ./scripts/test-firewall.sh all"
echo ""
echo "📚 Consulte o README.md para instruções detalhadas"
echo ""
print_success "Setup concluído! Bom estudo! 🚀"
