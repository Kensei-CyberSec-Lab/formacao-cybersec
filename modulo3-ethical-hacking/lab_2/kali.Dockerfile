FROM kalilinux/kali-rolling

# Remove problematic mirrors and use only reliable ones
RUN echo "deb http://http.kali.org/kali kali-rolling main non-free contrib" > /etc/apt/sources.list && \
    echo "deb http://kali.download/kali kali-rolling main non-free contrib" >> /etc/apt/sources.list && \
    rm -f /etc/apt/sources.list.d/*

# Update package lists with clean sources
RUN apt-get update --allow-releaseinfo-change || true

# Install essential packages first
RUN apt-get install -y --no-install-recommends --fix-missing \
  ca-certificates \
  wget \
  && apt-get clean

# Update package lists again
RUN apt-get update || true

# Install packages in smaller batches with retry logic
RUN apt-get install -y --no-install-recommends --fix-missing \
  git \
  curl \
  jq \
  && apt-get clean || true

RUN apt-get install -y --no-install-recommends --fix-missing \
  python3-pip \
  build-essential \
  && apt-get clean || true

RUN apt-get install -y --no-install-recommends --fix-missing \
  golang-go \
  nmap \
  cargo \
  && apt-get clean || true

RUN apt-get install -y --no-install-recommends --fix-missing \
  dnsutils \
  nikto \
  whatweb \
  && apt-get clean || true
ENV GOPATH=/root/go
ENV PATH=/root/go/bin:/root/.cargo/bin:$PATH
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
