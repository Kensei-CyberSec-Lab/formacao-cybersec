# Dockerfile final para o atacante, usando cargo para compilação

# Usamos a imagem mais recente do Kali como base.
FROM kalilinux/kali-rolling

# Define o diretório de trabalho padrão
WORKDIR /root

# IMPORTANTE: Adiciona o diretório de binários do Cargo ao PATH do sistema.
# Sem isso, o comando 'rustscan' não seria encontrado após a instalação.
ENV PATH="/root/.cargo/bin:${PATH}"

# Atualiza, instala as ferramentas necessárias (incluindo o cargo) e compila o RustScan
RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    nmap \
    enum4linux-ng \
    snmp \
    smbclient \
    ca-certificates \
    # O gerenciador de pacotes da linguagem Rust
    cargo && \
    # Usa o cargo para baixar o código-fonte e compilar o rustscan.
    # Isso funciona em qualquer arquitetura (amd64, arm64, etc.)
    echo "Instalando RustScan via cargo..." && \
    cargo install rustscan && \
    # Limpa o cache para manter a imagem enxuta
    echo "Limpando o sistema..." && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Define o comando padrão para o container
CMD ["/bin/bash"]