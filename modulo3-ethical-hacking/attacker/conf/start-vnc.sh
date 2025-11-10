#!/bin/bash
set -euo pipefail

export USER=root
export HOME=/root
export DISPLAY=${DISPLAY:-:1}
export VNC_GEOMETRY=${VNC_GEOMETRY:-1280x800}
export VNC_DEPTH=${VNC_DEPTH:-24}
export VNC_PASSWORD=${VNC_PASSWORD:-kalilinux}

mkdir -p /root/.vnc
chmod 700 /root/.vnc

# Configure VNC password non-interactively
if [ ! -f /root/.vnc/passwd ] || ! vncpasswd -t < /root/.vnc/passwd >/dev/null 2>&1; then
  (echo "${VNC_PASSWORD}"; echo "${VNC_PASSWORD}") | vncpasswd >/dev/null 2>&1
fi
chmod 600 /root/.vnc/passwd

# Copy XFCE startup script shipped with the image
cp /opt/vnc/xstartup /root/.vnc/xstartup
chmod +x /root/.vnc/xstartup

vncserver -kill "${DISPLAY}" >/dev/null 2>&1 || true
rm -f /root/.vnc/*.pid

echo "Starting VNC server on ${DISPLAY} (${VNC_GEOMETRY}@${VNC_DEPTH})"
vncserver "${DISPLAY}" -geometry "${VNC_GEOMETRY}" -depth "${VNC_DEPTH}" -localhost no

echo "Starting noVNC on port 6080"
websockify --web=/usr/share/novnc/ 6080 localhost:5901 &
NOVNC_PID=$!

trap 'vncserver -kill "${DISPLAY}" >/dev/null 2>&1 || true; kill ${NOVNC_PID} >/dev/null 2>&1 || true' SIGTERM SIGINT

LOG_PATTERN="/root/.vnc/*.log"
until ls ${LOG_PATTERN} >/dev/null 2>&1; do
  sleep 1
done
tail -F ${LOG_PATTERN}
