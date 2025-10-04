#!/usr/bin/env bash
set -euo pipefail

POX_DIR="${POX_DIR:-$HOME/pox}"
FIREWALL="${FIREWALL:-False}"
MIGRATION="${MIGRATION:-False}"

cd "$POX_DIR"

# Sanity: make sure your module + CSVs exist in pox/ext
for f in CloudNetController.py firewall_policies.csv migration_events.csv; do
  if [[ ! -f "ext/$f" ]]; then
    echo "Warning: ext/$f not found in $POX_DIR" >&2
  fi
done

# Start POX with topology discovery plus your app
./pox.py openflow.discovery CloudNetController \
  --firewall_capability="$FIREWALL" \
  --migration_capability="$MIGRATION"
