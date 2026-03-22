#!/bin/env bash
# ================================================================
#  CLOUD SECURITY — CLEANUP
#  RUN: chmod +x 10_security_cleanup.sh && ./10_security_cleanup.sh
# ================================================================
set -euo pipefail

STATE_FILE="$HOME/aws_state_security.txt"
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

banner "CLOUD SECURITY — CLEANUP"

# Standardized Names
INSTANCE_TAGS=("Practical-Security-Node" "Practical-Web-Node" "Hardened-Compute-Node")
SG_NAMES=("Practical-Security-SG" "Practical-Web-SG" "Practical-DB-SG" "Practical-Hardened-Firewall-SG")
IAM_ROLE="Practical-Security-Role"
IAM_PROFILE="Practical-Security-Profile"
IAM_USER="practical-security-user"
IAM_GROUP="Practical-Security-Group"
POLICY_NAME="Practical-Security-Policy"
KEY_NAME="Practical-KeyPair"
VPC_SCRATCH_NAME="Practical-Security-VPC"

info "Step 1 — Terminating Security Instances..."
for TAG in "${INSTANCE_TAGS[@]}"; do
  IDS=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$TAG" "Name=instance-state-name,Values=running,pending,stopped" --region "$REGION" --query "Reservations[].Instances[].InstanceId" --output text 2>/dev/null)
  if [[ -n "$IDS" && "$IDS" != "None" ]]; then
    info "  Terminating $TAG ($IDS)"
    aws ec2 terminate-instances --instance-ids $IDS --region "$REGION" > /dev/null
    aws ec2 wait instance-terminated --instance-ids $IDS --region "$REGION" 2>/dev/null || true
  fi
done

info "Step 2 — Deleting Security Groups..."
for NAME in "${SG_NAMES[@]}"; do
  for SG in $(aws ec2 describe-security-groups --filters "Name=group-name,Values=$NAME" --region "$REGION" --query "SecurityGroups[].GroupId" --output text 2>/dev/null); do
    if [[ -n "$SG" && "$SG" != "None" ]]; then
      info "  Deleting $NAME ($SG)"
      # Revoke egress/ingress rules first to break circular dependencies
      aws ec2 revoke-security-group-ingress --group-id "$SG" --ip-permissions "$(aws ec2 describe-security-groups --group-ids "$SG" --query 'SecurityGroups[0].IpPermissions' --region "$REGION")" --region "$REGION" 2>/dev/null || true
      aws ec2 delete-security-group --group-id "$SG" --region "$REGION" 2>/dev/null || true
    fi
  done
done

info "Step 3 — Deleting S3 Buckets..."
# Discovery for buckets starting with prefix
for BKT in $(aws s3api list-buckets --query "Buckets[?starts_with(Name, 'practical-secure-bucket')].Name" --output text); do
  if [[ -n "$BKT" && "$BKT" != "None" ]]; then
    info "  Emptying bucket: $BKT"
    aws s3 rm "s3://$BKT" --recursive --region "$REGION" 2>/dev/null || true
    # Remove versions/markers if enabled
    aws s3api delete-objects --bucket "$BKT" --delete "$(aws s3api list-object-versions --bucket "$BKT" --query '{Objects: Versions[].{Key: Key, VersionId: VersionId}}' --output json --region "$REGION")" 2>/dev/null || true
    aws s3api delete-objects --bucket "$BKT" --delete "$(aws s3api list-object-versions --bucket "$BKT" --query '{Objects: DeleteMarkers[].{Key: Key, VersionId: VersionId}}' --output json --region "$REGION")" 2>/dev/null || true
    aws s3api delete-bucket --bucket "$BKT" --region "$REGION" 2>/dev/null || true
    success "Bucket $BKT deleted."
  fi
done

info "Step 4 — Deleting IAM Role/Profile: $IAM_ROLE"
aws iam remove-role-from-instance-profile --instance-profile-name "$IAM_PROFILE" --role-name "$IAM_ROLE" 2>/dev/null || true
aws iam delete-instance-profile --instance-profile-name "$IAM_PROFILE" 2>/dev/null || true
for POL in $(aws iam list-attached-role-policies --role-name "$IAM_ROLE" --query "AttachedPolicies[].PolicyArn" --output text 2>/dev/null); do
  info "  Detaching managed policy: $POL"
  aws iam detach-role-policy --role-name "$IAM_ROLE" --policy-arn "$POL"
done
for POL in $(aws iam list-role-policies --role-name "$IAM_ROLE" --query "PolicyNames[]" --output text 2>/dev/null); do
  info "  Deleting inline policy: $POL"
  aws iam delete-role-policy --role-name "$IAM_ROLE" --policy-name "$POL"
done
aws iam delete-role --role-name "$IAM_ROLE" 2>/dev/null || true

info "Step 5 — Deleting IAM User/Group/Policy..."
aws iam remove-user-from-group --user-name "$IAM_USER" --group-name "$IAM_GROUP" 2>/dev/null || true
aws iam detach-group-policy --group-name "$IAM_GROUP" --policy-arn "arn:aws:iam::aws:policy/ReadOnlyAccess" 2>/dev/null || true
aws iam delete-group --group-name "$IAM_GROUP" 2>/dev/null || true
aws iam delete-user --user-name "$IAM_USER" 2>/dev/null || true

# Delete custom policy
POLICY_ARN=$(aws iam list-policies --scope Local --query "Policies[?PolicyName=='$POLICY_NAME'].Arn" --output text 2>/dev/null || echo "None")
if [[ "$POLICY_ARN" != "None" && -n "$POLICY_ARN" ]]; then
  info "  Deleting Custom Policy: $POLICY_NAME"
  aws iam delete-policy --policy-arn "$POLICY_ARN" 2>/dev/null || true
fi

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
