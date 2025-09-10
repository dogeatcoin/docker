#!/usr/bin/env bash
set -euo pipefail

# Expected env:
#  EXPRESSVPN_DEB_URL   -> URL to .deb installer
#  EXPRESSVPN_CODE      -> activation code (required first time)
#  PROXY_PORT           -> Tinyproxy port (default 8080)
#  CONTROL_PORT         -> Flask API port (default 8088)
#  KILLSWITCH=1         -> strict iptables (only tun0/lo)

install_expressvpn() {
  if ! command -v expressvpn >/dev/null 2>&1; then
    if [ -z "${EXPRESSVPN_DEB_URL:-}" ]; then
      echo "ERROR: EXPRESSVPN_DEB_URL is not set and ExpressVPN is missing." >&2
      exit 1
    fi
    echo "Installing ExpressVPN from ${EXPRESSVPN_DEB_URL}..."
    apt-get update
    curl -fsSL "$EXPRESSVPN_DEB_URL" -o /tmp/expressvpn.deb
    apt-get install -y /tmp/expressvpn.deb
    rm -f /tmp/expressvpn.deb
    rm -rf /var/lib/apt/lists/*
  fi
}

activate_expressvpn() {
  status_output="$(expressvpn status 2>&1 || true)"
  echo "[expressvpn] status output:"
  echo "$status_output"

  if echo "$status_output" | grep -qi "not *activated"; then
    echo "[expressvpn] ERROR: ExpressVPN is not activated."
    if [ -n "${EXPRESSVPN_CODE:-}" ]; then
      echo "[expressvpn] Activation code provided, attempting activation..."
      expect <<'EOF'
set timeout -1
log_user 1
spawn expressvpn activate
expect {
  -re "(?i)enter.*code" { }
  -re "(?i)code:" { }
}
send "$::env(EXPRESSVPN_CODE)\r"
expect {
  -re "(?i)activated" { }
  eof { }
  timeout { }
}
EOF
    else
      echo "[expressvpn] No activation code provided."
    fi
  else
    echo "[expressvpn] Already activated."
  fi
}

configure_tinyproxy() {
  sed -ri "s/^Port .*/Port ${PROXY_PORT}/" /etc/tinyproxy/tinyproxy.conf
  sed -i '/^Allow /d' /etc/tinyproxy/tinyproxy.conf
  echo "Allow 0.0.0.0/0" >> /etc/tinyproxy/tinyproxy.conf
  service tinyproxy start
}

enable_killswitch() {
  if [ "${KILLSWITCH:-0}" = "1" ]; then
    echo "Enabling strict iptables killswitch..."
    # allow reply packets
    iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    # keep existing
    iptables -A OUTPUT -o lo -j ACCEPT
    iptables -A OUTPUT -o tun0 -j ACCEPT
  fi
}

install_expressvpn
activate_expressvpn
configure_tinyproxy
enable_killswitch

# Start control API
exec python3 /usr/local/bin/controller.py