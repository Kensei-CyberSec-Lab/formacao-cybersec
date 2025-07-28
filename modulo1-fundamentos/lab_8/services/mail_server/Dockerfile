# services/mail_server/Dockerfile
# ATUALIZAÇÃO CTF: Adiciona uma flag no banner do serviço SMTP.
FROM juanluisbaptiste/postfix:latest
# Adiciona a flag diretamente no arquivo de configuração do Postfix.
RUN echo 'smtpd_banner = KENSEI{SMTP_BANNER_REVELADOR}' >> /etc/postfix/main.cf
EXPOSE 25 110 143