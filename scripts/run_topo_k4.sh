#!/usr/bin/env bash
set -euo pipefail

# Allow override: K=8 scripts/run_topo_k4.sh
K="${K:-4}"

# Resolve repo root even if called from elsewhere
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git -C "$SCRIPT_DIR/.." rev-parse --show-toplevel 2>/dev/null || cd "$SCRIPT_DIR/.." && pwd)"

sudo python "$REPO_ROOT/src/mininet_topos/fattree_topo.py" -k "$K"
