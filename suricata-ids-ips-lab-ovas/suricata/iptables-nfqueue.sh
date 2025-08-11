#!/usr/bin/env bash
set -euo pipefail
sudo sysctl -w net.ipv4.ip_forward=1 >/dev/null
sudo iptables -F || true
sudo iptables -t nat -F || true
sudo iptables -t mangle -F || true
sudo iptables -P FORWARD ACCEPT
sudo iptables -I FORWARD -j NFQUEUE --queue-num 0
sudo iptables -I INPUT   -j NFQUEUE --queue-num 0
sudo iptables -I OUTPUT  -j NFQUEUE --queue-num 0
echo "NFQUEUE pronto. Rode: sudo suricata -q 0 -k none"