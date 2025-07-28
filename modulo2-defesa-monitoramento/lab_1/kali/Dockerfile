FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt install -y \
    nmap \
    netcat-traditional \
    curl \
    dnsutils \
    vim \
    python3 \
    whois \
    git && \
    apt clean

CMD ["/bin/bash"]
