#!/bin/bash
set -euo pipefail

# Ensure PostgreSQL cluster is started (no systemd in container)
PGVER=$(ls /etc/postgresql | head -n1 || true)
if [ -n "${PGVER:-}" ]; then
  pg_ctlcluster "$PGVER" main start || true
fi

# Initialize Metasploit DB for user kali if possible
if id kali >/dev/null 2>&1; then
  su -l kali -c 'msfdb init' || true
fi

# Keep container interactive
exec bash -l


