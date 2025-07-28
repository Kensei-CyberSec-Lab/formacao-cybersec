FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_BREAK_SYSTEM_PACKAGES=1

RUN apt update && \
    apt install -y nmap dnsutils sublist3r theharvester gobuster \
                   dirb wordlists curl iputils-ping python3-pip && \
    pip3 install googlesearch-python shodan

CMD ["/bin/bash"]
