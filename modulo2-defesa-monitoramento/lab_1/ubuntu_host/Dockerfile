FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt install -y \
    net-tools \
    iputils-ping \
    curl \
    vim \
    openssh-server \
    ufw \
    sudo && \
    apt clean

# Criar usuário seguro para testes (não-root)
RUN useradd -m aluno && echo "aluno:senha123" | chpasswd && adduser aluno sudo

# Configurar SSH seguro (a ser ajustado na aula de hardening)
RUN mkdir /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

EXPOSE 22

CMD ["/bin/bash"]
