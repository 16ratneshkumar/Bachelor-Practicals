#!/bin/env bash
# ================================================================
#  PRIVATE CLOUD FOUNDATION — CLEANUP
#  Destroy AWS Resources for OpenStack Node
#  RUN: chmod +x 7_foundation_cleanup.sh && ./7_foundation_cleanup.sh
# ================================================================
set -euo pipefail

STATE_FILE="$HOME/aws_state_foundation.txt"
REGION="ap-south-1"

# Load state if exists
if [[ -f "$STATE_FILE" ]]; then
  source "$STATE_FILE"
fi

G='\033[0;32m'; B='\033[0;34m'; Y='\033[1;33m'; NC='\033[0m'
info()    { echo -e "${B}[INFO]${NC}    $*"; }
success() { echo -e "${G}[OK]${NC}      $*"; }
banner()  { echo -e "\n${Y}══════════════════════════════════════════${NC}"; \
            echo -e "${Y}  $*${NC}"; \
            echo -e "${Y}══════════════════════════════════════════${NC}\n"; }

banner "PRIVATE CLOUD FOUNDATION — CLEANUP"

# Standardized Names
INST_NAME="Practical-OpenStack-Node"
VPC_NAME="Practical-OpenStack-VPC"
SG_NAME="Practical-OpenStack-SG"
IAM_ROLE="Practical-OpenStack-Role"
IAM_PROFILE="Practical-OpenStack-Profile"
KEY_NAME="Practical-KeyPair"

# ── 1. Instance ──────────────────────────────────────────────
info "Step 1 — Terminating OpenStack Instance..."
IDS=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$INST_NAME" "Name=instance-state-name,Values=running,pending,stopped" --region "$REGION" --query "Reservations[].Instances[].InstanceId" --output text)
if [[ -n "$IDS" && "$IDS" != "None" ]]; then
  aws ec2 terminate-instances --instance-ids $IDS --region "$REGION" > /dev/null
  info "  Waiting for termination..."
  aws ec2 wait instance-terminated --instance-ids $IDS --region "$REGION"
  success "Instance terminated."
fi

# ── 2. Networking ────────────────────────────────────────────
info "Step 2 — Deleting Network Infrastructure: $VPC_NAME"
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=$VPC_NAME" --region "$REGION" --query "Vpcs[0].VpcId" --output text 2>/dev/null || echo "None")

if [[ "$VPC_ID" != "None" && "$VPC_ID" != "null" ]]; then
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
  # SG
  for SG in $(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" --region "$REGION" --query "SecurityGroups[?GroupName!='default'].GroupId" --output text); do
    aws ec2 delete-security-group --group-id "$SG" --region "$REGION" || true
  done
  # VPC
  aws ec2 delete-vpc --vpc-id "$VPC_ID" --region "$REGION" || true
  success "VPC Deleted."
fi

# ── 3. IAM ───────────────────────────────────────────────────
info "Step 3 — IAM Cleanup: $IAM_ROLE"
aws iam remove-role-from-instance-profile --instance-profile-name "$IAM_PROFILE" --role-name "$IAM_ROLE" 2>/dev/null || true
aws iam delete-instance-profile --instance-profile-name "$IAM_PROFILE" 2>/dev/null || true
for POL in $(aws iam list-attached-role-policies --role-name "$IAM_ROLE" --query "AttachedPolicies[].PolicyArn" --output text 2>/dev/null); do
  aws iam detach-role-policy --role-name "$IAM_ROLE" --policy-arn "$POL"
done
aws iam delete-role --role-name "$IAM_ROLE" 2>/dev/null || true
success "IAM resources check/deleted."

# ── 4. Key Pair ──────────────────────────────────────────────
info "Step 4 — Deleting Key Pair: $KEY_NAME"
aws ec2 delete-key-pair --key-name "$KEY_NAME" --region "$REGION" 2>/dev/null || true
rm -f "$HOME/${KEY_NAME}.pem"

rm -f "$STATE_FILE"
success "Cleanup complete."
