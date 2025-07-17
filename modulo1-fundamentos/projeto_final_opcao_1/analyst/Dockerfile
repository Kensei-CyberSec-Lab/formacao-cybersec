FROM kalilinux/kali-rolling
  
RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
      iproute2 \
      iputils-ping \
      dnsutils \
      net-tools \
      nmap \
      curl \
      wget \
      git && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m analyst

WORKDIR /home/analyst

RUN wget https://github.com/RustScan/RustScan/releases/download/2.0.1/rustscan_2.0.1_amd64.deb && \
    apt install -y ./rustscan_2.0.1_amd64.deb && \
    rm rustscan_2.0.1_amd64.deb

RUN curl -L "https://gist.githubusercontent.com/jcarlos78/8111a9f0d7466f0d76217fa617827e27/raw/70f453a430af0284dc7641af7da5ac3b256cf244/N%25C3%2583O%2520APAGAR" \
    -o /home/analyst/.ANOTACAO-ULTIMO-SCAN.TXT && \
    chmod 644 /home/analyst/.ANOTACAO-ULTIMO-SCAN.TXT

CMD ["tail", "-f", "/dev/null"]
