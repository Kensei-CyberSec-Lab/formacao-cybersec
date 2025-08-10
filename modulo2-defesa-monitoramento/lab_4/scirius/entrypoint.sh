#!/usr/bin/env bash
set -e

cd /opt/scirius

# Usa SQLite por padrão, apontando para /data/scirius.sqlite3
# Se desejar usar outro DB, configure via variáveis do Django antes de buildar.
export DJANGO_SETTINGS_MODULE=scirius.settings

# Migrar DB
python manage.py migrate --noinput

# Criar superusuário se ainda não existir
python - <<'PYCODE'
import os
import django
from django.core.management import call_command
from django.contrib.auth import get_user_model

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "scirius.settings")
django.setup()
User = get_user_model()
username = os.environ.get("DJANGO_SUPERUSER_USERNAME", "admin")
email = os.environ.get("DJANGO_SUPERUSER_EMAIL", "admin@example.com")
password = os.environ.get("DJANGO_SUPERUSER_PASSWORD", "changeme")

if not User.objects.filter(username=username).exists():
    User.objects.create_superuser(username=username, email=email, password=password)
    print(f"[scirius] Superuser '{username}' criado.")
else:
    print(f"[scirius] Superuser '{username}' já existe.")
PYCODE

# Iniciar via gunicorn
exec gunicorn scirius.wsgi:application -b ${SCIRIUS_BIND} --workers 3 --timeout 120
