# Dockerfile para o Kali Linux personalizado
# Usaremos uma base Debian mais estável e instalaremos as ferramentas de whois e dns
FROM debian:stable-slim

# Instala o sudo, atualiza o sistema e instala as ferramentas de rede essenciais
RUN apt update && apt upgrade -y && apt install -y \
    sudo \
    iputils-ping \
    dnsutils \
    iproute2 \
    whois \
    netbase \
    traceroute \
    # Adicional para garantir libs de rede
    net-tools \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Cria um usuário não-root (boa prática de segurança, embora para lab seja opcional)
RUN useradd -m -s /bin/bash kali
RUN echo "kali:kali" | chpasswd
RUN adduser kali sudo

# Define o usuário padrão para o container
USER kali
WORKDIR /home/kali

# Define o ponto de entrada como o shell bash
CMD ["/bin/bash"]