# services/web_server/Dockerfile
# ATUALIZAÇÃO CTF: Usa uma página HTML customizada com uma flag escondida.
FROM nginx:alpine
# Copia nossa página personalizada para o diretório do Nginx.
COPY index.html /usr/share/nginx/html/
EXPOSE 80 443