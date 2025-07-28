# Dockerfile ATUALIZADO com correção de mirror
FROM kalilinux/kali-rolling

# <<< A MÁGICA ACONTECE AQUI >>>
# Força o uso do repositório HTTP principal do Kali, evitando mirrors instáveis.
RUN echo "deb http://http.kali.org/kali kali-rolling main non-free contrib" > /etc/apt/sources.list

ARG VNC_PASSWORD=kensei
ENV VNC_PASSWORD=${VNC_PASSWORD}
ENV USER=root

# Agora o apt-get vai usar a fonte que definimos acima
RUN apt-get update && \
    apt-get install -y kali-desktop-xfce kali-linux-default tightvncserver && \
    apt-get clean

# O desafio continua sendo incluído
RUN mkdir -p /root/.diretorio_secreto && \
    echo "KenseiCyberSec{D3s4f10_CLI_C0nclu1d0!}" > /root/.diretorio_secreto/.segredo_dojo

COPY xstartup /root/.vnc/xstartup
RUN chmod +x /root/.vnc/xstartup

COPY startup.sh /startup.sh
RUN chmod +x /startup.sh

EXPOSE 5901
CMD ["/startup.sh"]