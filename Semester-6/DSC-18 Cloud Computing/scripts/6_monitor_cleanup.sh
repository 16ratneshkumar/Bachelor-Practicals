#!/bin/env bash
# ================================================================
#  CLOUD MONITORING — CLEANUP
#  RUN: chmod +x 6_monitor_cleanup.sh && ./6_monitor_cleanup.sh
# ================================================================
set -euo pipefail

STATE_FILE="$HOME/aws_state_monitor.txt"
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

banner "CLOUD MONITORING — CLEANUP"

# Standardized Names
INST_NAME="Monitor-Target-Instance"
TOPIC_NAME="Practical-Monitoring-Alerts"
DASHBOARD_NAME="Practical-Compute-Dashboard"
SG_NAME="Practical-Monitoring-SG"
KEY_NAME="Practical-KeyPair"
VPC_SCRATCH_NAME="Practical-Monitor-VPC"

info "Step 1 — Deleting CloudWatch Alarms..."
aws cloudwatch delete-alarms \
  --alarm-names "HighCPU-Alarm" "StatusCheck-Alarm" "HighNetwork-Alarm" \
  --region "$REGION" 2>/dev/null || true
success "Alarms check/deleted."

info "Step 2 — Deleting CloudWatch Dashboard..."
aws cloudwatch delete-dashboards \
  --dashboard-names "$DASHBOARD_NAME" --region "$REGION" 2>/dev/null || true
success "Dashboard check/deleted."

info "Step 3 — Deleting SNS Topic: $TOPIC_NAME"
SNS_ARN=${SNS_ARN:-$(aws sns list-topics --region "$REGION" --query "Topics[?contains(TopicArn, '$TOPIC_NAME')].TopicArn" --output text 2>/dev/null || echo "None")}
if [[ "$SNS_ARN" != "None" && "$SNS_ARN" != "" ]]; then
  aws sns delete-topic --topic-arn "$SNS_ARN" --region "$REGION" > /dev/null
  success "SNS Topic deleted."
fi

info "Step 4 — Terminating EC2 Instance: $INST_NAME"
IDS=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$INST_NAME" "Name=instance-state-name,Values=running,pending,stopped" --region "$REGION" --query "Reservations[].Instances[].InstanceId" --output text)
if [[ -n "$IDS" ]]; then
  aws ec2 terminate-instances --instance-ids $IDS --region "$REGION" > /dev/null
  aws ec2 wait instance-terminated --instance-ids $IDS --region "$REGION" 2>/dev/null || true
  success "Instance terminated."
fi

info "Step 5 — Deleting Security Group: $SG_NAME"
for SG in $(aws ec2 describe-security-groups --filters "Name=group-name,Values=$SG_NAME" --region "$REGION" --query "SecurityGroups[].GroupId" --output text); do
  aws ec2 delete-security-group --group-id "$SG" --region "$REGION" 2>/dev/null || true
done

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
