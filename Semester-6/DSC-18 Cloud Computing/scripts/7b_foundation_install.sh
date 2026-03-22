#!/bin/bash
# ================================================================
#  OPENSTACK PHASE 2 — INSTALLATION (Target Instance)
#  Install and Configure DevStack for Private Cloud Setup
#  Optimized for: 2 vCPU / 8 GB RAM (m7i-flex.large)
#  RUN: Inside the EC2 instance manually
# ================================================================
set -eo pipefail   # no -u: DevStack scripts use unset variables

G='\033[0;32m'; B='\033[0;34m'; Y='\033[1;33m'; C='\033[0;36m'; NC='\033[0m'
info()    { echo -e "${B}[INFO]${NC}    $*"; }
success() { echo -e "${G}[OK]${NC}      $*"; }
banner()  { echo -e "\n${Y}══════════════════════════════════════════${NC}"; \
            echo -e "${Y}  $*${NC}"; \
            echo -e "${Y}══════════════════════════════════════════${NC}\n"; }

banner "OPENSTACK PHASE 2 — DevStack Installation"

# ── 0. Ensure we are NOT root ────────────────────────────────
if [[ $EUID -eq 0 ]]; then
  echo -e "${Y}[WARN]${NC} DevStack must NOT run as root."
  echo -e "       Re-run this script as a normal user (e.g. ubuntu)."
  exit 1
fi

# ── 1. System Dependencies ───────────────────────────────────
info "Step 1 — Updating System & Installing Prerequisites"
sudo apt-get update -y
sudo apt-get install -y git python3-pip jq unzip cockpit
sudo systemctl enable --now cockpit.socket
success "Prerequisites installed."

# ── 2. Add Swap (critical for 8 GB instances) ────────────────
if ! swapon --show | grep -q '/swapfile'; then
  info "Step 2 — Creating 4 GB swap file"
  sudo fallocate -l 4G /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab > /dev/null
  success "Swap enabled (4 GB)."
else
  info "Step 2 — Swap already active. Skipping."
fi

# ── 3. Clone DevStack ────────────────────────────────────────
info "Step 3 — Cloning OpenStack DevStack Repository"
if [[ ! -d "devstack" ]]; then
  git clone https://opendev.org/openstack/devstack
else
  info "  DevStack repository already exists. Skipping clone."
fi
success "Source code ready."

# ── 4. Configuration (local.conf) ────────────────────────────
info "Step 4 — Generating OpenStack Configuration (local.conf)"
HOST_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
cat > devstack/local.conf <<EOF
[[local|localrc]]
ADMIN_PASSWORD=openstack
DATABASE_PASSWORD=\$ADMIN_PASSWORD
RABBIT_PASSWORD=\$ADMIN_PASSWORD
SERVICE_PASSWORD=\$ADMIN_PASSWORD
HOST_IP=$HOST_IP

# Allow re-run after failure
RECLONE=yes

# ── Minimal Services (2 vCPU / 8 GB optimized) ───────────
# Core Infrastructure
ENABLED_SERVICES=key,mysql,rabbit
# Glance — Image Service
ENABLED_SERVICES+=,g-api,g-reg
# Nova — Compute (no VNC console to save RAM)
ENABLED_SERVICES+=,n-api,n-cpu,n-sch,n-cond,n-api-meta
# Placement — Required by Nova Scheduler
ENABLED_SERVICES+=,placement,placement-api,placement-client
# Horizon — Web Dashboard
ENABLED_SERVICES+=,horizon
# Neutron — OVN Networking (lightweight)
ENABLED_SERVICES+=,q-svc,q-ovn-metadata-agent,ovn-northd,ovn-controller

# OVN networking backend
Q_AGENT=ovn
Q_ML2_PLUGIN_MECHANISM_DRIVERS=ovn,logger
Q_ML2_PLUGIN_TYPE_DRIVERS=local,flat,vlan,geneve
Q_ML2_TENANT_NETWORK_TYPE=geneve

# ── Memory Optimizations ─────────────────────────────────
# Single API worker per service (saves ~1 GB RAM)
API_WORKERS=1
# Disable services we don't need
disable_service tempest dstat
# Disable etcd (not required for basic compute)
disable_service etcd3
# No TLS overhead for lab environment
disable_service tls-proxy
# No Cinder (block storage) — uses ephemeral disks only
disable_service c-api c-vol c-sch
# No Swift (object storage)
disable_service s-proxy s-object s-container s-account

# Logging (reduce disk I/O)
LOGFILE=/opt/stack/logs/stack.sh.log
LOG_COLOR=True
LOGDAYS=1
EOF
success "Configuration generated for IP: $HOST_IP"

# ── 5. Execute Stack ─────────────────────────────────────────
banner "READY TO INSTALL"
echo -e "The next step will take ${Y}15-20 minutes${NC}."
echo -e "You are about to run: ${C}./stack.sh${NC}"
echo -e "\n${Y}NOTE:${NC} Stay connected to this SSH session."
echo ""
read -p "Proceed with installation? (y/n): " -n 1 -r
echo
[[ ! $REPLY =~ ^[Yy]$ ]] && exit 1

cd devstack
./stack.sh

banner "OPENSTACK INSTALLATION COMPLETE"
echo -e "Horizon Dashboard: ${G}http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)/dashboard${NC}"
echo -e "Username: admin | Password: openstack"
