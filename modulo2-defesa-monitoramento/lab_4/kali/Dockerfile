FROM kalilinux/kali-rolling

RUN apt-get update &&     DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends       nmap curl iputils-ping net-tools procps dnsutils     && apt-get clean && rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]