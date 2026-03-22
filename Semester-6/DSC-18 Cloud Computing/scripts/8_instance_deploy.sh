#!/usr/bin/env bash
# ================================================================
#  OPENSTACK PHASE 8 — IMAGE MANAGEMENT (CloudShell)
#  Launch Your First Instance in OpenStack via Remote CLI
#
#  PREREQ: Practical 7 must be running (Foundation Node)
#  RUN   : chmod +x 8_image_deploy.sh && ./8_image_deploy.sh
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

banner "OPENSTACK — Image Management & Instance Launch"

info "Step 0 — Locating OpenStack Foundation Node..."
NODE_IP=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=$NODE_NAME" "Name=instance-state-name,Values=running" \
  --region "$REGION" --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

if [[ "$NODE_IP" == "None" || -z "$NODE_IP" ]]; then
  echo -e "${Y}[ERROR] OpenStack Node not found. Run 7_foundation_deploy.sh first.${NC}"
  exit 1
fi
success "Found OpenStack Node at $NODE_IP"

# Base SSH command to execute OpenStack CLI on the controller
OSH="ssh -i $HOME/${KEY_NAME}.pem -o StrictHostKeyChecking=no ubuntu@$NODE_IP source /home/ubuntu/devstack/openrc admin admin &&"

# ── Step 1: Project & User Setup ─────────────────────────────
info "Step 1 — Creating Project and User"
ssh -i "$HOME/${KEY_NAME}.pem" -o StrictHostKeyChecking=no ubuntu@$NODE_IP <<'EOF'
  source /home/ubuntu/devstack/openrc admin admin
  openstack project create --description "Lab Project" lab-project 2>/dev/null || true
  openstack user create --password labpass labuser 2>/dev/null || true
  openstack role add --project lab-project --user admin admin 2>/dev/null || true
  openstack role add --project lab-project --user labuser member 2>/dev/null || true
EOF
success "Project: lab-project | User: labuser created."

# ── Step 2: Upload Image (Glance) ────────────────────────────
info "Step 2 — Downloading and Uploading Image (CirrOS - Lightweight)"
ssh -i "$HOME/${KEY_NAME}.pem" -o StrictHostKeyChecking=no ubuntu@$NODE_IP <<'EOF'
  source /home/ubuntu/devstack/openrc admin admin
  if ! openstack image show "CirrOS 0.6.2" >/dev/null 2>&1; then
    wget -q -O /tmp/cirros.img http://download.cirros-cloud.net/0.6.2/cirros-0.6.2-x86_64-disk.img
    openstack image create "CirrOS 0.6.2" \
      --file /tmp/cirros.img \
      --disk-format qcow2 --container-format bare --public
    rm -f /tmp/cirros.img
  fi
EOF
success "Image uploaded: CirrOS 0.6.2"

# ── Step 3: Create Flavor (Nova) ─────────────────────────────
info "Step 3 — Creating Custom Flavor"
ssh -i "$HOME/${KEY_NAME}.pem" -o StrictHostKeyChecking=no ubuntu@$NODE_IP <<'EOF'
  source /home/ubuntu/devstack/openrc admin admin
  openstack flavor create --ram 512 --disk 1 --vcpus 1 m1.nano 2>/dev/null || true
EOF
success "Flavor defined: m1.nano (512MB RAM, 1 vCPU, 1GB Disk)"

# ── Step 4: KeyPair & Security Group ─────────────────────────
info "Step 4 — Setting up Security Group & Key Pair"
ssh -i "$HOME/${KEY_NAME}.pem" -o StrictHostKeyChecking=no ubuntu@$NODE_IP <<'EOF'
  source /home/ubuntu/devstack/openrc admin admin
  openstack keypair create my-key > /home/ubuntu/my-key.pem 2>/dev/null || true
  chmod 400 /home/ubuntu/my-key.pem 2>/dev/null || true
  
  # Allow SSH and ICMP on default security group
  SG_ID=$(openstack security group list --project admin -f value -c ID | head -n 1)
  openstack security group rule create --proto icmp $SG_ID 2>/dev/null || true
  openstack security group rule create --proto tcp --dst-port 22 $SG_ID 2>/dev/null || true
EOF
success "Security rules applied."

# ── Step 5: Launch Instance ──────────────────────────────────
info "Step 5 — Launching First Instance"
ssh -i "$HOME/${KEY_NAME}.pem" -o StrictHostKeyChecking=no ubuntu@$NODE_IP <<'EOF'
  source /home/ubuntu/devstack/openrc admin admin
  NET_ID=$(openstack network list | grep private | awk '{print $2}' | head -n 1)
  if ! openstack server show lab-instance >/dev/null 2>&1; then
    openstack server create \
      --flavor m1.nano \
      --image "CirrOS 0.6.2" \
      --network "$NET_ID" \
      --key-name my-key \
      lab-instance >/dev/null
  fi
EOF

info "Waiting for instance to become ACTIVE..."
sleep 15
success "Instance launched."

banner "OPENSTACK INSTANCE SUMMARY"
# Run commands and capture output directly
ssh -i "$HOME/${KEY_NAME}.pem" -o StrictHostKeyChecking=no ubuntu@$NODE_IP <<'EOF'
  source /home/ubuntu/devstack/openrc admin admin
  echo -e "\nInstances:"
  openstack server list
  
  echo -e "\nServer Details (lab-instance):"
  openstack server show lab-instance -c status -c addresses -c flavor -c image -f table
EOF

echo -e "\n${Y}NOTE:${NC} To view the Horizon Dashboard:"
echo -e "      http://$NODE_IP/dashboard"
echo -e "      User: admin | Password: openstack"
