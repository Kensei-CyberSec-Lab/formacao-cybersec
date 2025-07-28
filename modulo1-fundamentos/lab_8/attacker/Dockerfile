# attacker/Dockerfile
# Versão 6: Adiciona o netcat-traditional para a captura de flags.

FROM kalilinux/kali-rolling

ARG TARGETARCH=amd64
ENV DEBIAN_FRONTEND=noninteractive

# Instala todas as ferramentas necessárias para o laboratório
RUN apt-get update && \
    apt-get install -y wget nmap net-tools iproute2 smbclient default-mysql-client curl netcat-traditional telnet && \
    wget https://github.com/RustScan/RustScan/releases/download/2.0.1/rustscan_2.0.1_amd64.deb -O /tmp/rustscan.deb && \
    dpkg -i /tmp/rustscan.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/rustscan.deb

WORKDIR /root
CMD ["/bin/bash"]