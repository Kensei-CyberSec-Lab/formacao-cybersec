# services/database_server/Dockerfile
# ATUALIZAÇÃO CTF: Garante que o script de inicialização tenha permissão para rodar.
FROM mariadb:10.5
# Copia o script SQL para o diretório de inicialização do MariaDB.
COPY init.sql /docker-entrypoint-initdb.d/
# Garante que o script tenha as permissões corretas para ser executado.
RUN chmod 644 /docker-entrypoint-initdb.d/init.sql
EXPOSE 3306