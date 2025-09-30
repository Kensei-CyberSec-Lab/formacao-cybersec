#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob
for f in *.ova; do
  sha256sum "$f" >> CHECKSUMS.sha256
done
echo "CHECKSUMS.sha256 gerado."