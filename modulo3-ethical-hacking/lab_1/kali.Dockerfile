FROM kalilinux/kali-rolling
RUN apt-get update && apt-get install -y \
  git \
  curl \
  jq \
  python3-pip \
  build-essential \
  golang-go \
  amass \
  && apt-get clean && rm -rf /var/lib/apt/lists/*
ENV GOPATH=/root/go
ENV PATH=$PATH:/root/go/bin
RUN mkdir -p $GOPATH
RUN go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest \
        && go install github.com/projectdiscovery/httpx/cmd/httpx@latest \
        && go install github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest \
        && go install github.com/hakluke/hakrawler@latest \
        && go install github.com/zricethezav/gitleaks/v8@latest
COPY scripts /home/kali/scripts
WORKDIR /home/kali
CMD ["/bin/bash"]
