# services/fileshare_server/Dockerfile
# ATUALIZAÇÃO CTF: Adiciona um arquivo de flag em um diretório oculto.
FROM dperson/samba
COPY smb.conf /etc/samba/
EXPOSE 139 445
# Cria um diretório oculto e um arquivo de flag dentro dele.
RUN mkdir -p /share/.secreto && echo "KENSEI{SMB_EH_UMA_MAE}" > /share/.secreto/FLAG.txt
CMD ["-p", "-s", "public;/share;yes;no;yes"]