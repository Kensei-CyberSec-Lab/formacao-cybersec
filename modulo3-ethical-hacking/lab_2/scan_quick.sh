#!/bin/bash
# scan_quick.sh — fluxo rápido: resolve hosts, rustscan, nmap direcionado e enumeração específica
HOSTS=("www.acme-corp-lab.com" "admin.acme-corp-lab.com" "dev.acme-corp-lab.com" "old.acme-corp-lab.com")
TIMESTAMP=$(date -u +%Y%m%dT%H%M%SZ)
OUTDIR="./evidence/${TIMESTAMP}"
mkdir -p "${OUTDIR}"

for H in "${HOSTS[@]}"; do
  echo "=== $(date -u +%Y-%m-%dT%H:%M:%SZ) ===" | tee -a "${OUTDIR}/runs.log"
  IP=$(dig +short "$H" | head -n1)
  echo "Resolving: $H -> ${IP:-UNRESOLVED}" | tee -a "${OUTDIR}/runs.log"

  if [ -z "$IP" ]; then
    echo "No IP for $H, pulando..." | tee -a "${OUTDIR}/runs.log"
    continue
  fi

  rustscan -a "$H" --ulimit 5000 -- -sS -T2 -oA "${OUTDIR}/${H}_rust_nmap" | tee -a "${OUTDIR}/runs.log"

  PORTS=$(grep -oP '(?<=Ports: ).*' "${OUTDIR}/${H}_rust_nmap.gnmap" 2>/dev/null | head -n1 | awk -F',' '{for(i=1;i<=NF;i++){print $i}}' | awk -F'/' '{print $1}' | paste -sd, -)
  if [ -z "$PORTS" ]; then
    echo "Nenhuma porta listada pelo rustscan para $H — pulando nmap direcionado" | tee -a "${OUTDIR}/runs.log"
  else
    echo "Portas detectadas em $H: $PORTS" | tee -a "${OUTDIR}/runs.log"
    nmap -sS -T2 -p "$PORTS" --script smb-enum-shares,smb-os-discovery,ldap-rootdse,rdp-enum-encryption -oA "${OUTDIR}/${H}_nmap_detalhado" "$IP" | tee -a "${OUTDIR}/runs.log"
  fi

  if echo "$PORTS" | grep -q "445"; then
    enum4linux -a "$IP" > "${OUTDIR}/${H}_enum4linux_out.txt"
  fi
  if echo "$PORTS" | grep -q "389"; then
    ldapsearch -x -H "ldap://$IP" -b "dc=acme,dc=local" '(objectClass=*)' > "${OUTDIR}/${H}_ldap_out.txt"
  fi
  if echo "$PORTS" | grep -q "3389"; then
    nmap -sS -T2 -p 3389 --script rdp-enum-encryption -oN "${OUTDIR}/${H}_rdp_out.txt" "$IP"
  fi

  echo "Scan para $H finalizado." | tee -a "${OUTDIR}/runs.log"
done

tar -czf "${OUTDIR}.tar.gz" -C "$(dirname "${OUTDIR}")" "$(basename "${OUTDIR}")"
sha256sum "${OUTDIR}.tar.gz" > "${OUTDIR}.sha256"
echo "Evidências salvas em ${OUTDIR}.tar.gz"
