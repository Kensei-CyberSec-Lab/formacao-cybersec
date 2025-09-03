#!/bin/bash

# Script de Limpeza - Lab 5 Container Security
# Remove containers, imagens, relatórios e limpa o ambiente

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para exibir help
show_help() {
    echo -e "${BLUE}🧹 Script de Limpeza - Lab 5 Container Security${NC}"
    echo ""
    echo "Uso: $0 [OPÇÕES]"
    echo ""
    echo "Opções:"
    echo "  -a, --all          Limpeza completa (containers + imagens + relatórios)"
    echo "  -c, --containers   Remove apenas containers do lab"
    echo "  -i, --images       Remove imagens do lab"
    echo "  -r, --reports      Limpa apenas relatórios antigos"
    echo "  -n, --networks     Remove redes Docker órfãs"
    echo "  -v, --volumes      Remove volumes Docker não utilizados"
    echo "  -d, --docker       Limpeza geral do Docker (prune)"
    echo "  -f, --force        Força remoção sem confirmação"
    echo "  -h, --help         Exibe esta ajuda"
    echo ""
    echo "Exemplos:"
    echo "  $0 --all           # Limpeza completa"
    echo "  $0 --reports       # Remove apenas relatórios"
    echo "  $0 --containers    # Para e remove containers"
    echo "  $0 --docker --force # Limpeza Docker sem confirmação"
    echo ""
}

# Função para confirmar ação
confirm_action() {
    local message="$1"
    if [[ "$FORCE" == "true" ]]; then
        return 0
    fi
    
    echo -e "${YELLOW}⚠️  $message${NC}"
    echo -n "Continuar? (y/N): "
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}ℹ️  Operação cancelada${NC}"
        return 1
    fi
    return 0
}

# Função para remover containers
cleanup_containers() {
    echo -e "${BLUE}🐳 Removendo containers do lab...${NC}"
    
    if confirm_action "Isso irá parar e remover os containers do Lab 5"; then
        # Parar containers se estiverem rodando
        if docker ps -q --filter "name=juice_shop" | grep -q .; then
            echo "Parando container juice_shop..."
            docker stop juice_shop 2>/dev/null || true
        fi
        
        if docker ps -q --filter "name=kali_lab_31" | grep -q .; then
            echo "Parando container kali_lab_31..."
            docker stop kali_lab_31 2>/dev/null || true
        fi
        
        # Remover containers
        if docker ps -aq --filter "name=juice_shop" | grep -q .; then
            echo "Removendo container juice_shop..."
            docker rm juice_shop 2>/dev/null || true
        fi
        
        if docker ps -aq --filter "name=kali_lab_31" | grep -q .; then
            echo "Removendo container kali_lab_31..."
            docker rm kali_lab_31 2>/dev/null || true
        fi
        
        # Usar docker compose down para garantir
        if [ -f "docker-compose.yml" ]; then
            echo "Executando docker compose down..."
            docker compose down 2>/dev/null || true
        fi
        
        echo -e "${GREEN}✅ Containers removidos${NC}"
    fi
}

# Função para remover imagens
cleanup_images() {
    echo -e "${BLUE}🖼️  Removendo imagens do lab...${NC}"
    
    if confirm_action "Isso irá remover as imagens Docker do Lab 5"; then
        # Remover imagem customizada do Kali
        if docker images -q "lab_5-kali_lab_31" | grep -q .; then
            echo "Removendo imagem lab_5-kali_lab_31..."
            docker rmi lab_5-kali_lab_31 2>/dev/null || true
        fi
        
        # Remover imagem do Juice Shop (opcional)
        echo -n "Remover também a imagem bkimminich/juice-shop? (y/N): "
        if [[ "$FORCE" == "true" ]]; then
            response="y"
        else
            read -r response
        fi
        
        if [[ "$response" =~ ^[Yy]$ ]]; then
            if docker images -q "bkimminich/juice-shop" | grep -q .; then
                echo "Removendo imagem bkimminich/juice-shop..."
                docker rmi bkimminich/juice-shop 2>/dev/null || true
            fi
        fi
        
        # Remover imagem base do Kali (opcional)
        echo -n "Remover também a imagem base kalilinux/kali-rolling? (y/N): "
        if [[ "$FORCE" == "true" ]]; then
            response="n"
        else
            read -r response
        fi
        
        if [[ "$response" =~ ^[Yy]$ ]]; then
            if docker images -q "kalilinux/kali-rolling" | grep -q .; then
                echo "Removendo imagem kalilinux/kali-rolling..."
                docker rmi kalilinux/kali-rolling 2>/dev/null || true
            fi
        fi
        
        echo -e "${GREEN}✅ Imagens removidas${NC}"
    fi
}

# Função para limpar relatórios
cleanup_reports() {
    echo -e "${BLUE}📊 Limpando relatórios...${NC}"
    
    if [ ! -d "reports" ]; then
        echo -e "${YELLOW}⚠️  Diretório reports/ não encontrado${NC}"
        return
    fi
    
    # Contar arquivos
    report_count=$(find reports/ -type f 2>/dev/null | wc -l)
    
    if [ "$report_count" -eq 0 ]; then
        echo -e "${BLUE}ℹ️  Nenhum relatório encontrado${NC}"
        return
    fi
    
    echo -e "${YELLOW}📋 Relatórios encontrados: $report_count arquivo(s)${NC}"
    ls -la reports/ 2>/dev/null || true
    echo ""
    
    if confirm_action "Isso irá remover todos os relatórios em reports/"; then
        # Manter estrutura do diretório, remover apenas arquivos
        find reports/ -type f -delete 2>/dev/null || true
        echo -e "${GREEN}✅ Relatórios removidos${NC}"
        
        # Recriar diretório se foi removido
        mkdir -p reports/
    fi
}

# Função para limpar redes Docker
cleanup_networks() {
    echo -e "${BLUE}🌐 Limpando redes Docker órfãs...${NC}"
    
    if confirm_action "Isso irá remover redes Docker não utilizadas"; then
        # Remover rede específica do lab se existir
        if docker network ls -q --filter "name=lab_5_lab31_net" | grep -q .; then
            echo "Removendo rede lab_5_lab31_net..."
            docker network rm lab_5_lab31_net 2>/dev/null || true
        fi
        
        # Prune de redes não utilizadas
        docker network prune -f 2>/dev/null || true
        echo -e "${GREEN}✅ Redes limpas${NC}"
    fi
}

# Função para limpar volumes Docker
cleanup_volumes() {
    echo -e "${BLUE}💾 Limpando volumes Docker não utilizados...${NC}"
    
    if confirm_action "Isso irá remover volumes Docker não utilizados"; then
        docker volume prune -f 2>/dev/null || true
        echo -e "${GREEN}✅ Volumes limpos${NC}"
    fi
}

# Função para limpeza geral do Docker
cleanup_docker() {
    echo -e "${BLUE}🧹 Limpeza geral do Docker...${NC}"
    
    if confirm_action "Isso irá executar docker system prune"; then
        docker system prune -f 2>/dev/null || true
        echo -e "${GREEN}✅ Limpeza Docker concluída${NC}"
    fi
}

# Função para limpeza completa
cleanup_all() {
    echo -e "${BLUE}🚀 Iniciando limpeza completa do Lab 5...${NC}"
    echo ""
    
    cleanup_containers
    echo ""
    cleanup_images  
    echo ""
    cleanup_reports
    echo ""
    cleanup_networks
    echo ""
    cleanup_volumes
    echo ""
    
    echo -e "${GREEN}🎉 Limpeza completa finalizada!${NC}"
}

# Função para mostrar status atual
show_status() {
    echo -e "${BLUE}📊 Status atual do Lab 5:${NC}"
    echo ""
    
    echo -e "${YELLOW}Containers:${NC}"
    if docker ps -a --filter "name=juice_shop" --filter "name=kali_lab_31" --format "table {{.Names}}\t{{.Status}}\t{{.Image}}" | grep -q .; then
        docker ps -a --filter "name=juice_shop" --filter "name=kali_lab_31" --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
    else
        echo "  Nenhum container encontrado"
    fi
    echo ""
    
    echo -e "${YELLOW}Imagens:${NC}"
    if docker images --filter "reference=lab_5*" --filter "reference=bkimminich/juice-shop" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep -q .; then
        docker images --filter "reference=lab_5*" --filter "reference=bkimminich/juice-shop" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
    else
        echo "  Nenhuma imagem encontrada"
    fi
    echo ""
    
    echo -e "${YELLOW}Relatórios:${NC}"
    if [ -d "reports" ] && [ "$(find reports/ -type f 2>/dev/null | wc -l)" -gt 0 ]; then
        echo "  Arquivos: $(find reports/ -type f 2>/dev/null | wc -l)"
        echo "  Tamanho: $(du -sh reports/ 2>/dev/null | cut -f1)"
    else
        echo "  Nenhum relatório encontrado"
    fi
    echo ""
    
    echo -e "${YELLOW}Redes:${NC}"
    if docker network ls --filter "name=lab_5" --format "table {{.Name}}\t{{.Driver}}" | grep -q .; then
        docker network ls --filter "name=lab_5" --format "table {{.Name}}\t{{.Driver}}"
    else
        echo "  Nenhuma rede específica encontrada"
    fi
}

# Variáveis padrão
FORCE=false
ACTION=""

# Parse dos argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--all)
            ACTION="all"
            shift
            ;;
        -c|--containers)
            ACTION="containers"
            shift
            ;;
        -i|--images)
            ACTION="images"
            shift
            ;;
        -r|--reports)
            ACTION="reports"
            shift
            ;;
        -n|--networks)
            ACTION="networks"
            shift
            ;;
        -v|--volumes)
            ACTION="volumes"
            shift
            ;;
        -d|--docker)
            ACTION="docker"
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -s|--status)
            ACTION="status"
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Opção desconhecida: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Verificar se Docker está rodando
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker não está rodando. Por favor, inicie o Docker Desktop.${NC}"
    exit 1
fi

# Executar ação baseada no parâmetro
case $ACTION in
    all)
        cleanup_all
        ;;
    containers)
        cleanup_containers
        ;;
    images)
        cleanup_images
        ;;
    reports)
        cleanup_reports
        ;;
    networks)
        cleanup_networks
        ;;
    volumes)
        cleanup_volumes
        ;;
    docker)
        cleanup_docker
        ;;
    status)
        show_status
        ;;
    "")
        echo -e "${YELLOW}⚠️  Nenhuma ação especificada. Mostrando status atual:${NC}"
        echo ""
        show_status
        echo ""
        echo -e "${BLUE}💡 Use --help para ver opções disponíveis${NC}"
        ;;
esac
