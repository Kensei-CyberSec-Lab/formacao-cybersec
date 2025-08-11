# Checksums (SHA256)

Gere os hashes para todas as OVAs e publique junto do Release.

## Como gerar
```bash
cd RELEASE
./checksums.sh
```
Isso cria `CHECKSUMS.sha256` no diretório atual contendo entradas `sha256sum` de cada `*.ova`.

## Como verificar
```bash
sha256sum -c CHECKSUMS.sha256
```