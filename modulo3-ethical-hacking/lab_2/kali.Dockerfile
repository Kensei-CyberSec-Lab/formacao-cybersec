FROM kalilinux/kali-rolling
RUN apt-get update && apt-get install -y \
  git \
  curl \
  jq \
  python3-pip \
  build-essential \
  golang-go \
  nmap \
  cargo \
  dnsutils \
  nikto \
  whatweb \
  && apt-get clean && rm -rf /var/lib/apt/lists/*
ENV GOPATH=/root/go
ENV PATH=$PATH:/root/go/bin:/root/.cargo/bin
RUN mkdir -p $GOPATH
RUN go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest \
        && go install github.com/projectdiscovery/httpx/cmd/httpx@latest \
        && go install github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest \
        && go install github.com/projectdiscovery/dnsx/cmd/dnsx@latest \
        && go install github.com/hakluke/hakrawler@latest \
        && go install github.com/zricethezav/gitleaks/v8@latest \
        && go install github.com/OJ/gobuster/v3@latest \
        && cargo install rustscan
WORKDIR /home/kali
CMD ["/bin/bash"]
