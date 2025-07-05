# Dockerfile para a imagem do alvo (alvo-enum)
# Adicionando o CTF

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    samba \
    snmpd \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /srv/samba/anonymous \
    && chown nobody:nogroup /srv/samba/anonymous \
    && echo "[global]" >> /etc/samba/smb.conf \
    && echo "    map to guest = bad user" >> /etc/samba/smb.conf \
    && echo "[anonymous]" >> /etc/samba/smb.conf \
    && echo "    path = /srv/samba/anonymous" >> /etc/samba/smb.conf \
    && echo "    browsable = yes" >> /etc/samba/smb.conf \
    && echo "    writable = no" >> /etc/samba/smb.conf \
    && echo "    guest ok = yes" >> /etc/samba/smb.conf

RUN echo "rocommunity public" > /etc/snmp/snmpd.conf \
    && echo "agentaddress udp:161" >> /etc/snmp/snmpd.conf

# AQUI ESTÁ A FLAG!
# Criamos um arquivo flag.txt dentro do compartilhamento anônimo.
RUN echo "Kensei{a_curiosidade_eh_a_chave_do_hacker}" > /srv/samba/anonymous/flag.txt

EXPOSE 139 445 161/udp
CMD service smbd start && service nmbd start && /usr/sbin/snmpd -f