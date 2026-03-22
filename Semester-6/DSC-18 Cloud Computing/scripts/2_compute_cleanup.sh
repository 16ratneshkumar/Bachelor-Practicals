#!/bin/env bash
# ================================================================
#  AWS COMPUTE — CLEANUP
#  Terminate Instance and Delete Security Group
#  RUN: chmod +x 2_compute_cleanup.sh && ./2_compute_cleanup.sh
# ================================================================
set -euo pipefail

STATE_FILE="$HOME/aws_state_compute.txt"
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

banner "AWS COMPUTE — CLEANUP"

# Standardized Names
INST_NAME="First-EC2-Instance"
SG_NAME="Practical-FirstEC2-SG"
KEY_NAME="Practical-KeyPair"
VPC_SCRATCH_NAME="Practical-Compute-VPC"

info "Step 1 — Terminating EC2 Instance: $INST_NAME"
IDS=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$INST_NAME" "Name=instance-state-name,Values=running,pending,stopped" --region "$REGION" --query "Reservations[].Instances[].InstanceId" --output text)
if [[ -n "$IDS" ]]; then
  aws ec2 terminate-instances --instance-ids $IDS --region "$REGION" > /dev/null 2>&1
  info "  Waiting for termination..."
  aws ec2 wait instance-terminated --instance-ids $IDS --region "$REGION" 2>/dev/null || true
  success "Instance terminated."
fi

info "Step 2 — Deleting Security Group: $SG_NAME"
# Find all SGs (might be in multiple VPCs)
for SG in $(aws ec2 describe-security-groups --filters "Name=group-name,Values=$SG_NAME" --region "$REGION" --query "SecurityGroups[].GroupId" --output text); do
  aws ec2 delete-security-group --group-id "$SG" --region "$REGION" 2>/dev/null || true
done
success "Security Group check/deleted."

info "Step 3 — Deleting Key Pair..."
aws ec2 delete-key-pair --key-name "$KEY_NAME" --region "$REGION" 2>/dev/null || true
rm -f "$HOME/${KEY_NAME}.pem"

info "Step 4 — Scratch VPC Cleanup: $VPC_SCRATCH_NAME"
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=$VPC_SCRATCH_NAME" --region "$REGION" --query "Vpcs[0].VpcId" --output text 2>/dev/null || echo "None")
if [[ "$VPC_ID" != "None" && "$VPC_ID" != "null" ]]; then
  info "  Cleaning up scratch networking ($VPC_ID)..."
  # Subnets
  for SUB in $(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --region "$REGION" --query "Subnets[].SubnetId" --output text); do
    aws ec2 delete-subnet --subnet-id "$SUB" --region "$REGION" || true
  done
  # IGW
  for IGW in $(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID" --region "$REGION" --query "InternetGateways[].InternetGatewayId" --output text); do
    aws ec2 detach-internet-gateway --internet-gateway-id "$IGW" --vpc-id "$VPC_ID" --region "$REGION" || true
    aws ec2 delete-internet-gateway --internet-gateway-id "$IGW" --region "$REGION" || true
  done
  # RT
  for RT in $(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" --region "$REGION" --query "RouteTables[?Associations[0].Main!=\`true\`].RouteTableId" --output text); do
    aws ec2 delete-route-table --route-table-id "$RT" --region "$REGION" || true
  done
  aws ec2 delete-vpc --vpc-id "$VPC_ID" --region "$REGION" || true
  success "Scratch VPC deleted."
fi

rm -f "$STATE_FILE"
success "Cleanup complete."
