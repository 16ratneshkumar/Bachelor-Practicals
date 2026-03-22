#!/bin/env bash
# ================================================================
#  OPENSTACK PHASE 1 — INFRASTRUCTURE (CloudShell)
#  Provision AWS Resources for Private Cloud Foundation
#  RUN: chmod +x 7a_foundation_infra.sh && ./7a_foundation_infra.sh
# ================================================================
set -euo pipefail

REGION="ap-south-1"
AMI_ID=$(aws ec2 describe-images --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*" \
  --region "$REGION" --query "sort_by(Images, &CreationDate)[-1].ImageId" --output text)
INSTANCE_TYPE="m7i-flex.large" # High-performance 8GB RAM instance for stable OpenStack
KEY_NAME="Practical-KeyPair"
STATE_FILE="$HOME/aws_state_foundation.txt"

# Resource Names
VPC_NAME="Practical-OpenStack-VPC"
SUB_NAME="Practical-OpenStack-Subnet"
SG_NAME="Practical-OpenStack-SG"
INST_NAME="Practical-OpenStack-Node"
IAM_ROLE="Practical-OpenStack-Role"
IAM_PROFILE="Practical-OpenStack-Profile"

G='\033[0;32m'; B='\033[0;34m'; Y='\033[1;33m'; C='\033[0;36m'; NC='\033[0m'
info()    { echo -e "${B}[INFO]${NC}    $*"; }
success() { echo -e "${G}[OK]${NC}      $*"; }
banner()  { echo -e "\n${Y}══════════════════════════════════════════${NC}"; \
            echo -e "${Y}  $*${NC}"; \
            echo -e "${Y}══════════════════════════════════════════${NC}\n"; }

banner "OPENSTACK PHASE 1 — AWS Infrastructure"

# ── Step 0: Key Pair ─────────────────────────────────────────
info "Step 0 — Key Pair: $KEY_NAME"
if aws ec2 describe-key-pairs --key-names "$KEY_NAME" --region "$REGION" >/dev/null 2>&1; then
  info "  Key Pair '$KEY_NAME' already exists. Using it."
else
  info "  Creating Key Pair: $KEY_NAME"
  aws ec2 create-key-pair --key-name "$KEY_NAME" --region "$REGION" \
    --query "KeyMaterial" --output text > "$HOME/${KEY_NAME}.pem"
  chmod 400 "$HOME/${KEY_NAME}.pem"
  success "Key Pair created → $HOME/${KEY_NAME}.pem"
fi

# ── 1. Create VPC ────────────────────────────────────────────
info "Step 1 — Creating Isolated VPC: $VPC_NAME"
VPC_ID=$(aws ec2 create-vpc --cidr-block "10.70.0.0/16" --region "$REGION" --query "Vpc.VpcId" --output text)
aws ec2 create-tags --resources "$VPC_ID" --region "$REGION" --tags Key=Name,Value="$VPC_NAME"
aws ec2 modify-vpc-attribute --vpc-id "$VPC_ID" --enable-dns-hostnames --region "$REGION"
aws ec2 modify-vpc-attribute --vpc-id "$VPC_ID" --enable-dns-support --region "$REGION"
success "VPC Created: $VPC_ID"

# ── 2. Create Subnet & IGW ──────────────────────────────────
info "Step 2 — Networking: Subnet & Gateway"
IGW_ID=$(aws ec2 create-internet-gateway --region "$REGION" --query "InternetGateway.InternetGatewayId" --output text)
aws ec2 attach-internet-gateway --internet-gateway-id "$IGW_ID" --vpc-id "$VPC_ID" --region "$REGION"
SUB_ID=$(aws ec2 create-subnet --vpc-id "$VPC_ID" --cidr-block "10.70.1.0/24" --region "$REGION" --query "Subnet.SubnetId" --output text)
aws ec2 create-tags --resources "$SUB_ID" --region "$REGION" --tags Key=Name,Value="$SUB_NAME"
aws ec2 modify-subnet-attribute --subnet-id "$SUB_ID" --map-public-ip-on-launch --region "$REGION"
RT_ID=$(aws ec2 create-route-table --vpc-id "$VPC_ID" --region "$REGION" --query "RouteTable.RouteTableId" --output text)
aws ec2 create-route --route-table-id "$RT_ID" --destination-cidr-block "0.0.0.0/0" --gateway-id "$IGW_ID" --region "$REGION" > /dev/null
aws ec2 associate-route-table --route-table-id "$RT_ID" --subnet-id "$SUB_ID" --region "$REGION" > /dev/null
success "Network Foundation Ready."

# ── 3. IAM Role & Profile ────────────────────────────────────
info "Step 3 — Security: IAM Role"
if ! aws iam get-role --role-name "$IAM_ROLE" >/dev/null 2>&1; then
  aws iam create-role --role-name "$IAM_ROLE" --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"ec2.amazonaws.com"},"Action":"sts:AssumeRole"}]}' > /dev/null
  aws iam attach-role-policy --role-name "$IAM_ROLE" --policy-arn "arn:aws:iam::aws:policy/PowerUserAccess"
fi
if ! aws iam get-instance-profile --instance-profile-name "$IAM_PROFILE" >/dev/null 2>&1; then
  aws iam create-instance-profile --instance-profile-name "$IAM_PROFILE" > /dev/null
  aws iam add-role-to-instance-profile --instance-profile-name "$IAM_PROFILE" --role-name "$IAM_ROLE"
  info "  Waiting 15 seconds for IAM propagation..."
  sleep 15
fi
success "IAM Role/Profile Ready."

# ── 4. Security Group ────────────────────────────────────────
info "Step 4 — Firewall Configuration"
SG_ID=$(aws ec2 create-security-group --group-name "$SG_NAME" --description "OpenStack Node Rules" --vpc-id "$VPC_ID" --region "$REGION" --query "GroupId" --output text)
aws ec2 create-tags --resources "$SG_ID" --region "$REGION" --tags Key=Name,Value="$SG_NAME"
aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol tcp --port 22 --cidr 0.0.0.0/0 --region "$REGION" > /dev/null
aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol tcp --port 80 --cidr 0.0.0.0/0 --region "$REGION" > /dev/null
aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol tcp --port 9090 --cidr 0.0.0.0/0 --region "$REGION" > /dev/null
success "Security Group Ready: $SG_ID"

# ── 5. Launch EC2 ────────────────────────────────────────────
info "Step 5 — Launching OpenStack Foundation Node"
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id "$AMI_ID" --instance-type "$INSTANCE_TYPE" \
  --key-name "$KEY_NAME" --subnet-id "$SUB_ID" --security-group-ids "$SG_ID" \
  --iam-instance-profile "Name=$IAM_PROFILE" \
  --associate-public-ip-address \
  --block-device-mappings "DeviceName=/dev/sda1,Ebs={VolumeSize=80,VolumeType=gp3}" \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INST_NAME}]" \
  --query "Instances[0].InstanceId" --output text)
info "  Waiting for Public IP..."
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID" --region "$REGION"
PUBLIC_IP=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --region "$REGION" --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

# Save state
echo "VPC_ID=$VPC_ID" > "$STATE_FILE"
echo "INSTANCE_ID=$INSTANCE_ID" >> "$STATE_FILE"
echo "PUBLIC_IP=$PUBLIC_IP" >> "$STATE_FILE"

banner "PHASE 1 COMPLETE"
echo -e "  Public IP : ${G}$PUBLIC_IP${NC}"
echo -e "  Manual    : Now run Phase 2 inside the instance."
echo -e "\n  ${C}NEXT STEPS:${NC}"
echo -e "  1. Copy Phase 2 script to instance:"
echo -e "     scp -i ~/$KEY_NAME.pem ./7b_foundation_install.sh ubuntu@$PUBLIC_IP:~/"
echo -e "  2. SSH into the instance:"
echo -e "     ssh -i ~/$KEY_NAME.pem ubuntu@$PUBLIC_IP"
echo -e "  3. Run the installation script inside the instance:"
echo -e "     chmod +x 7b_foundation_install.sh && ./7b_foundation_install.sh"
