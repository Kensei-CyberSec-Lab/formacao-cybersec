FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    gvm \
    xml-twig-tools \
    curl \
    supervisor \
    && gvm-setup && gvm-check-setup && rm -rf /var/lib/apt/lists/*

EXPOSE 9392
CMD ["gsad", "--no-redirect", "--listen=0.0.0.0"]
