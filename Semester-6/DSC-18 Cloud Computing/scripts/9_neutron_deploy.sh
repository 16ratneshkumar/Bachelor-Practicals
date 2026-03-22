#!/bin/env bash
# ================================================================
#  OPENSTACK NETWORK MANAGEMENT — DEPLOY
#  Configure OpenStack Neutron Networking (Native CLI via SSH)
#
#  Objective:
#    1) Verify networks (Internal/External).
#    2) Attach a router.
#    3) Assign floating IPs.
#
#  RUN: chmod +x 9_neutron_deploy.sh && ./9_neutron_deploy.sh
# ================================================================
set -euo pipefail

REGION="ap-south-1"
NODE_NAME="Practical-OpenStack-Node"
KEY_NAME="Practical-KeyPair"

G='\033[0;32m'; B='\033[0;34m'; Y='\033[1;33m'; C='\033[0;36m'; NC='\033[0m'
info()    { echo -e "${B}[INFO]${NC}    $*"; }
success() { echo -e "${G}[OK]${NC}      $*"; }
banner()  { echo -e "\n${Y}══════════════════════════════════════════${NC}"; \
            echo -e "${Y}  $*${NC}"; \
            echo -e "${Y}══════════════════════════════════════════${NC}\n"; }

banner "OPENSTACK — Networking (Neutron)"

info "Step 0 — Locating OpenStack Node..."
NODE_IP=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=$NODE_NAME" "Name=instance-state-name,Values=running" \
  --region "$REGION" --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

if [[ "$NODE_IP" == "None" || -z "$NODE_IP" ]]; then
  echo "Error: OpenStack Node ($NODE_NAME) not found. Run 7_foundation_deploy.sh first."
  exit 1
fi
success "Found OpenStack Node at $NODE_IP"

info "Step 1 — Create Custom Network & Subnet"
ssh -i "$HOME/${KEY_NAME}.pem" -o StrictHostKeyChecking=no ubuntu@$NODE_IP <<'EOF'
  source /home/ubuntu/devstack/openrc admin admin
  if ! openstack network show custom-network >/dev/null 2>&1; then
    openstack network create custom-network
    openstack subnet create --network custom-network \
      --subnet-range 192.168.100.0/24 \
      --dns-nameserver 8.8.8.8 custom-subnet
  else
    echo "Network 'custom-network' already exists."
  fi
EOF

info "Step 2 — Create Virtual Router & Attach Gateway"
ssh -i "$HOME/${KEY_NAME}.pem" -o StrictHostKeyChecking=no ubuntu@$NODE_IP <<'EOF'
  source /home/ubuntu/devstack/openrc admin admin
  if ! openstack router show custom-router >/dev/null 2>&1; then
    openstack router create custom-router
    # Connect router to the external public network
    openstack router set --external-gateway public custom-router
    # Attach our custom private subnet to the router
    openstack router add subnet custom-router custom-subnet
  else
    echo "Router 'custom-router' already exists."
  fi
EOF

info "Step 3 — Prepare Compute Requirements "
ssh -i "$HOME/${KEY_NAME}.pem" -o StrictHostKeyChecking=no ubuntu@$NODE_IP <<'EOF'
  source /home/ubuntu/devstack/openrc admin admin
  
  # Ensure keypair exists
  openstack keypair create my-key > /home/ubuntu/my-key.pem 2>/dev/null || true
  chmod 400 /home/ubuntu/my-key.pem 2>/dev/null || true
  
  # Ensure flavor exists
  openstack flavor create --ram 512 --disk 1 --vcpus 1 m1.nano 2>/dev/null || true
  
  # Ensure image exists
  if ! openstack image show "CirrOS 0.6.2" >/dev/null 2>&1; then
    wget -q -O /tmp/cirros.img http://download.cirros-cloud.net/0.6.2/cirros-0.6.2-x86_64-disk.img
    openstack image create "CirrOS 0.6.2" --file /tmp/cirros.img --disk-format qcow2 --container-format bare --public
    rm -f /tmp/cirros.img
  fi
  
  # Ensure basic security group limits are permissive for ICMP/SSH
  SG_ID=$(openstack security group list --project admin -f value -c ID | head -n 1)
  openstack security group rule create --proto icmp $SG_ID 2>/dev/null || true
  openstack security group rule create --proto tcp --dst-port 22 $SG_ID 2>/dev/null || true
EOF

info "Step 4 — Launch Instance on Custom Network"
ssh -i "$HOME/${KEY_NAME}.pem" -o StrictHostKeyChecking=no ubuntu@$NODE_IP <<'EOF'
  source /home/ubuntu/devstack/openrc admin admin
  if ! openstack server show advanced-net-instance >/dev/null 2>&1; then
    NET_ID=$(openstack network show custom-network -f value -c id)
    openstack server create \
      --flavor m1.nano \
      --image "CirrOS 0.6.2" \
      --network "$NET_ID" \
      --key-name my-key \
      advanced-net-instance >/dev/null
    echo "Waiting for instance to build (15s)..."
    sleep 15
  else
    echo "Instance 'advanced-net-instance' already exists."
  fi
EOF

info "Step 5 — Assign Floating IP"
ssh -i "$HOME/${KEY_NAME}.pem" -o StrictHostKeyChecking=no ubuntu@$NODE_IP <<'EOF'
  source /home/ubuntu/devstack/openrc admin admin
  INST_ID=$(openstack server show advanced-net-instance -f value -c id || echo "None")
  
  if [[ "$INST_ID" != "None" ]]; then
    # Check if a floating IP is already assigned
    HAS_FIP=$(openstack server show advanced-net-instance -f value -c addresses | grep -o '172.24.4.[0-9]*' || true)
    
    if [[ -z "$HAS_FIP" ]]; then
      FLOATING_IP=$(openstack floating ip create public -f value -c floating_ip_address)
      openstack server add floating ip advanced-net-instance $FLOATING_IP
      echo "Floating IP $FLOATING_IP assigned to our custom network instance."
    else
      echo "Instance already has Floating IP: $HAS_FIP"
    fi
  else
    echo "Instance not found. Skipping IP assignment."
  fi
  
  echo -e "\n=== FINAL NETWORK TOPOLOGY ==="
  openstack server list
EOF

banner "PRACTICAL 9 COMPLETE"
