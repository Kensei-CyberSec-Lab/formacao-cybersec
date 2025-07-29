#!/bin/bash

# Garante permissões de acesso e configurações
echo "root:rootlab" | chpasswd

# Ajusta configurações do SSH
sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Reinicia o SSH se estiver rodando
pgrep sshd && /etc/init.d/ssh restart || /usr/sbin/sshd -D &
