#!/bin/bash

# Define a variável de ambiente USER para o root
export USER=root  # <<< A LINHA DA CORREÇÃO!

# Cria o diretório de configuração do VNC se ele não existir
mkdir -p ~/.vnc

# Define a senha do VNC a partir da variável de ambiente
(echo "$VNC_PASSWORD"; echo "$VNC_PASSWORD") | vncpasswd

# Inicia o servidor VNC na tela :1, com a geometria desejada e profundidade de cor
vncserver :1 -geometry 1280x800 -depth 24

# Mantém o container rodando exibindo os logs do VNC
tail -f ~/.vnc/*.log