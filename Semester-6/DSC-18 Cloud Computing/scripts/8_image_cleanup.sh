#!/usr/bin/env bash
# ================================================================
#  OPENSTACK PHASE 8 — IMAGE MANAGEMENT CLEANUP (CloudShell)
#  Removes instances, flavors, images, and projects
#
#  RUN: chmod +x 8_image_cleanup.sh && ./8_image_cleanup.sh
# ================================================================
set -euo pipefail

REGION="ap-south-1"
NODE_NAME="Practical-OpenStack-Node"
KEY_NAME="Practical-KeyPair"

info() { echo -e "\033[0;34m[INFO]\033[0m  $*"; }
success() { echo -e "\033[0;32m[OK]\033[0m    $*"; }

info "Locating OpenStack Foundation Node..."
NODE_IP=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=$NODE_NAME" "Name=instance-state-name,Values=running" \
  --region "$REGION" --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

if [[ "$NODE_IP" == "None" || -z "$NODE_IP" ]]; then
  info "OpenStack Node not found. Assuming resources already gone."
  exit 0
fi

info "Cleaning up OpenStack objects via SSH..."

ssh -i "$HOME/${KEY_NAME}.pem" -o StrictHostKeyChecking=no ubuntu@$NODE_IP <<'EOF'
  source /home/ubuntu/devstack/openrc admin admin 2>/dev/null || exit 0
  
  echo "Deleting instance 'lab-instance'..."
  openstack server delete lab-instance 2>/dev/null || true
  
  echo "Deleting flavor 'm1.nano'..."
  openstack flavor delete m1.nano 2>/dev/null || true
  
  echo "Deleting image 'CirrOS 0.6.2'..."
  openstack image delete "CirrOS 0.6.2" 2>/dev/null || true
  
  echo "Deleting user 'labuser'..."
  openstack user delete labuser 2>/dev/null || true
  
  echo "Deleting project 'lab-project'..."
  openstack project delete lab-project 2>/dev/null || true
  
  echo "Removing local key pair file..."
  rm -f /home/ubuntu/my-key.pem
EOF

success "OpenStack resources successfully cleaned up."
