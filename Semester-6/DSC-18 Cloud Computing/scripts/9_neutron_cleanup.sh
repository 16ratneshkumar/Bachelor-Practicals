#!/bin/env bash
# ================================================================
#  OPENSTACK NETWORK MANAGEMENT — CLEANUP
# ================================================================
set -euo pipefail

REGION="ap-south-1"
NODE_NAME="Practical-OpenStack-Node"
KEY_NAME="Practical-KeyPair"

info() { echo -e "\033[0;34m[INFO]\033[0m  $*"; }
success() { echo -e "\033[0;32m[OK]\033[0m    $*"; }

info "Locating OpenStack Node..."
NODE_IP=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=$NODE_NAME" "Name=instance-state-name,Values=running" \
  --region "$REGION" --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

if [[ "$NODE_IP" == "None" || -z "$NODE_IP" ]]; then
  info "OpenStack Node not found. Skipping network cleanup."
  exit 0
fi

info "Cleaning up OpenStack networks via SSH..."
ssh -i "$HOME/${KEY_NAME}.pem" -o StrictHostKeyChecking=no ubuntu@$NODE_IP <<'EOF'
  source /home/ubuntu/devstack/openrc admin admin 2>/dev/null || exit 0
  
  echo "1. Deleting instance 'advanced-net-instance'..."
  openstack server delete advanced-net-instance 2>/dev/null || true
  sleep 5 # Wait for port detachment
  
  echo "2. Releasing Floating IPs..."
  for FIP in $(openstack floating ip list -f value -c "Floating IP Address"); do
    openstack floating ip delete $FIP 2>/dev/null || true
  done
  
  echo "3. Detaching subnet from router..."
  openstack router remove subnet custom-router custom-subnet 2>/dev/null || true
  
  echo "4. Deleting router 'custom-router'..."
  openstack router delete custom-router 2>/dev/null || true
  
  echo "5. Deleting network 'custom-network' and its subnets..."
  openstack network delete custom-network 2>/dev/null || true
  
  echo "6. Deleting compute prerequisites (Flavor, Image, KeyPair)..."
  openstack flavor delete m1.nano 2>/dev/null || true
  openstack image delete "CirrOS 0.6.2" 2>/dev/null || true
  openstack keypair delete my-key 2>/dev/null || true
  rm -f /home/ubuntu/my-key.pem
  
EOF

success "OpenStack network resources cleaned up."
