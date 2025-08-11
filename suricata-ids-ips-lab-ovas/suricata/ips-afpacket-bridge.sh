#!/usr/bin/env bash
set -euo pipefail
IFACE_IN=${1:-eth1}
IFACE_OUT=${2:-eth2}
sudo ip link set "$IFACE_IN" up promisc on
sudo ip link set "$IFACE_OUT" up promisc on
sudo sysctl -w net.ipv4.ip_forward=0 >/dev/null
sudo iptables -F || true
echo "AF_PACKET inline preparado para $IFACE_IN <-> $IFACE_OUT. Ajuste suricata.yaml e reinicie o serviço."