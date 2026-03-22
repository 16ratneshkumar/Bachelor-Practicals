#!/bin/env bash
# ================================================================
#  AUTO SCALING — CLEANUP
#  RUN: chmod +x 4_scaling_cleanup.sh && ./4_scaling_cleanup.sh
# ================================================================
set -euo pipefail

STATE_FILE="$HOME/aws_state_scaling.txt"
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

banner "AUTO SCALING — CLEANUP"

# Standardized Names
ASG_NAME="Practical-Web-ASG"
ALB_NAME="Practical-Web-ALB"
TG_NAME="Practical-Web-TG"
LT_NAME="Practical-Web-LT"
SG_NAME="Practical-Web-SG"
KEY_NAME="Practical-KeyPair"
VPC_SCRATCH_NAME="Practical-Scaling-VPC"

info "Step 1 — Deleting Auto Scaling Group: $ASG_NAME"
if [[ $(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "$ASG_NAME" --region "$REGION" --query "length(AutoScalingGroups)" --output text 2>/dev/null) -gt 0 ]]; then
  aws autoscaling delete-auto-scaling-group --auto-scaling-group-name "$ASG_NAME" --force-delete --region "$REGION"
  info "  Waiting for instances to terminate..."
  sleep 40
  success "ASG deleted."
else
  info "  ASG '$ASG_NAME' not found. Skipping."
fi

info "Step 2 — Deleting Load Balancer: $ALB_NAME"
ALB_ARN=${ALB_ARN:-$(aws elbv2 describe-load-balancers --names "$ALB_NAME" --region "$REGION" --query "LoadBalancers[0].LoadBalancerArn" --output text 2>/dev/null || echo "None")}
if [[ "$ALB_ARN" != "None" ]]; then
  aws elbv2 delete-load-balancer --load-balancer-arn "$ALB_ARN" --region "$REGION" > /dev/null
  aws elbv2 wait load-balancers-deleted --load-balancer-arns "$ALB_ARN" --region "$REGION" 2>/dev/null || true
  success "ALB deleted."
fi

info "Step 3 — Deleting Target Group: $TG_NAME"
sleep 5 # Allow ALB listeners to decompose
TG_ARN=${TG_ARN:-$(aws elbv2 describe-target-groups --names "$TG_NAME" --region "$REGION" --query "TargetGroups[0].TargetGroupArn" --output text 2>/dev/null || echo "None")}
if [[ "$TG_ARN" != "None" && "$TG_ARN" != "null" ]]; then
  info "  Attempting to delete Target Group..."
  aws elbv2 delete-target-group --target-group-arn "$TG_ARN" --region "$REGION" 2>/dev/null || {
    info "  Target Group still in use, retrying in 10s..."
    sleep 10
    aws elbv2 delete-target-group --target-group-arn "$TG_ARN" --region "$REGION" || true
  }
  success "Target Group deleted."
fi

info "Step 4 — Deleting Launch Template: $LT_NAME"
aws ec2 delete-launch-template --launch-template-name "$LT_NAME" --region "$REGION" 2>/dev/null || true
success "Launch Template check/deleted."

info "Step 5 — Deleting Security Group: $SG_NAME"
for SG in $(aws ec2 describe-security-groups --filters "Name=group-name,Values=$SG_NAME" --region "$REGION" --query "SecurityGroups[].GroupId" --output text); do
  aws ec2 delete-security-group --group-id "$SG" --region "$REGION" 2>/dev/null || true
done
success "Security Group check/deleted."

info "Step 6 — Deleting Key Pair..."
aws ec2 delete-key-pair --key-name "$KEY_NAME" --region "$REGION" 2>/dev/null || true
rm -f "$HOME/${KEY_NAME}.pem"

info "Step 7 — Scratch VPC Cleanup: $VPC_SCRATCH_NAME"
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=$VPC_SCRATCH_NAME" --region "$REGION" --query "Vpcs[0].VpcId" --output text 2>/dev/null || echo "None")
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
  aws ec2 delete-vpc --vpc-id "$VPC_ID" --region "$REGION" || true
  success "Scratch VPC deleted."
fi

rm -f "$STATE_FILE"
success "Cleanup complete."
