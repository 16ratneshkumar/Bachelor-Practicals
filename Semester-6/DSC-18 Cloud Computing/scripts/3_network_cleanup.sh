#!/bin/env bash
# ================================================================
#  VPC NETWORK — CLEANUP
#  RUN: chmod +x 3_network_cleanup.sh && ./3_network_cleanup.sh
# ================================================================
set -euo pipefail

STATE_FILE="$HOME/aws_state_network.txt"
REGION="ap-south-1"

# Load state if exists
if [[ -f "$STATE_FILE" ]]; then
  source "$STATE_FILE"
fi

G='\033[0;32m'; B='\033[0;34m'; Y='\033[1;33m'; NC='\033[0m'
info()    { echo -e "${B}[INFO]${NC}  $*"; }
success() { echo -e "${G}[OK]${NC}    $*"; }
banner()  { echo -e "\n${Y}══════════════════════════════════════════${NC}"; \
            echo -e "${Y}  $*${NC}"; \
            echo -e "${Y}══════════════════════════════════════════${NC}\n"; }

banner "VPC NETWORK — CLEANUP"

# Standardized Names
VPC_NAME="Practical-VPC"
KEY_NAME="Practical-KeyPair"

info "Step 1 — Terminating Instances..."
IDS=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=Public-EC2-Instance,Private-EC2-Instance" "Name=instance-state-name,Values=running,pending,stopped" --region "$REGION" --query "Reservations[].Instances[].InstanceId" --output text)
if [[ -n "$IDS" ]]; then
  aws ec2 terminate-instances --instance-ids $IDS --region "$REGION" > /dev/null
  aws ec2 wait instance-terminated --instance-ids $IDS --region "$REGION" 2>/dev/null || true
fi
success "Instances check/terminated."

info "Step 2 — Deleting NAT Gateways..."
VPC_ID=${VPC_ID:-$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=$VPC_NAME" --region "$REGION" --query "Vpcs[0].VpcId" --output text 2>/dev/null || echo "None")}
if [[ "$VPC_ID" != "None" ]]; then
  for NAT in $(aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$VPC_ID" --region "$REGION" --query "NatGateways[?State!='deleted'].NatGatewayId" --output text); do
    aws ec2 delete-nat-gateway --nat-gateway-id "$NAT" --region "$REGION" > /dev/null
  done
  info "  Waiting for NAT Gateway deletion..."
  sleep 40
fi

info "Step 3 — Releasing Elastic IPs..."
for EIP in $(aws ec2 describe-addresses --filters "Name=tag:Name,Values=NAT-ElasticIP" --region "$REGION" --query "Addresses[].AllocationId" --output text); do
  aws ec2 release-address --allocation-id "$EIP" --region "$REGION" 2>/dev/null || true
done

info "Step 4 — Deleting Networking components..."
if [[ "$VPC_ID" != "None" ]]; then
  # SGs
  for SG in $(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" --region "$REGION" --query "SecurityGroups[?GroupName!='default'].GroupId" --output text); do
    aws ec2 delete-security-group --group-id "$SG" --region "$REGION" 2>/dev/null || true
  done
  # Subnets
  for SUB in $(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --region "$REGION" --query "Subnets[].SubnetId" --output text); do
    aws ec2 delete-subnet --subnet-id "$SUB" --region "$REGION" 2>/dev/null || true
  done
  # IGW
  IGW=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID" --region "$REGION" --query "InternetGateways[0].InternetGatewayId" --output text 2>/dev/null || echo "None")
  if [[ "$IGW" != "None" ]]; then
    aws ec2 detach-internet-gateway --internet-gateway-id "$IGW" --vpc-id "$VPC_ID" --region "$REGION" 2>/dev/null || true
    aws ec2 delete-internet-gateway --internet-gateway-id "$IGW" --region "$REGION" 2>/dev/null || true
  fi
  # RTs
  for RT in $(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" --region "$REGION" --query "RouteTables[?Associations[0].Main!=\`true\`].RouteTableId" --output text); do
    aws ec2 delete-route-table --route-table-id "$RT" --region "$REGION" 2>/dev/null || true
  done
  # VPC
  aws ec2 delete-vpc --vpc-id "$VPC_ID" --region "$REGION" 2>/dev/null || true
fi

info "Step 5 — Deleting Key Pair..."
aws ec2 delete-key-pair --key-name "$KEY_NAME" --region "$REGION" 2>/dev/null || true
rm -f "$HOME/${KEY_NAME}.pem"
rm -f "$STATE_FILE"
success "Cleanup complete."
