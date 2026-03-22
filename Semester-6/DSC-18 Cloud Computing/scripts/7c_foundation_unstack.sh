#!/bin/bash
# ================================================================
#  OPENSTACK PHASE 3 — REVERSION (Target Instance)
#  Rollback DevStack processes and clean environment
#  RUN: Inside the EC2 instance manually
# ================================================================
set -euo pipefail

G='\033[0;32m'; B='\033[0;34m'; Y='\033[1;33m'; R='\033[0;31m'; NC='\033[0m'
info()    { echo -e "${B}[INFO]${NC}    $*"; }
success() { echo -e "${G}[OK]${NC}      $*"; }
error()   { echo -e "${R}[ERROR]${NC}   $*"; }
banner()  { echo -e "\n${Y}══════════════════════════════════════════${NC}"; \
            echo -e "${Y}  $*${NC}"; \
            echo -e "${Y}══════════════════════════════════════════${NC}\n"; }

banner "OPENSTACK REVERSION — DevStack Cleanup"

if [[ ! -d "devstack" ]]; then
    error "DevStack directory not found. Nothing to reverse."
    exit 1
fi

cd devstack

# ── 1. Unstack ───────────────────────────────────────────────
info "Step 1 — Gracefully stopping services (unstack.sh)..."
if [[ -f "./unstack.sh" ]]; then
    ./unstack.sh || info "  Some services already stopped."
else
    error "unstack.sh not found."
fi

# ── 2. Clean ─────────────────────────────────────────────────
info "Step 2 — Scouring environment (clean.sh)..."
if [[ -f "./clean.sh" ]]; then
    # clean.sh removes OVS bridges and reset databases
    ./clean.sh || info "  Partial cleanup completed."
else
    error "clean.sh not found."
fi

# ── 3. Post-Clean ────────────────────────────────────────────
info "Step 3 — Removing configuration locks..."
sudo rm -rf /opt/stack
sudo rm -rf /etc/openstack
sudo rm -rf /var/log/openstack

banner "REVERSION COMPLETE"
echo -e "  Environment has been ${G}RESET${NC}."
echo -e "  You can now run ${Y}./7b_foundation_install.sh${NC} again."

