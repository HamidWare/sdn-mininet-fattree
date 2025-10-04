#!/usr/bin/env bash
set -euo pipefail

# Command lines
POX_CMD='cd "$HOME/pox" && ./pox.py openflow.discovery CloudNetController --firewall_capability=True --migration_capability=True'
TOPO_CMD='sudo python "$(git rev-parse --show-toplevel)/src/mininet_topos/fattree_topo.py" -k 4'

# Prefer gnome-terminal; fall back to xterm; else run inline
if command -v gnome-terminal >/dev/null 2>&1; then
  gnome-terminal -- bash -lc "$POX_CMD"
  gnome-terminal -- bash -lc "$TOPO_CMD"
elif command -v xterm >/dev/null 2>&1; then
  xterm -e bash -lc "$POX_CMD" &
  xterm -e bash -lc "$TOPO_CMD" &
else
  echo "No terminal launcher found; running both in this shell."
  bash -lc "$POX_CMD" &
  sleep 3
  bash -lc "$TOPO_CMD"
fi
