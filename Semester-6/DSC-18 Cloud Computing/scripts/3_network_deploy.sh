#!/usr/bin/env bash
# ================================================================
#  VPC NETWORK — DEPLOY
#  Set Up a VPC with Public & Private Subnets,
#  Internet Gateway, NAT Gateway, EC2 in each subnet
#
#  AMI    : Latest Ubuntu Server LTS
#  TYPE   : t3.micro (Free Tier eligible)
#  USER   : ubuntu
#  RUN    : chmod +x 3_network_deploy.sh && ./3_network_deploy.sh
#  DELETE : ./3_network_cleanup.sh
#  STATE  : $HOME/aws_state_network.txt
#  ⚠️   NAT Gateway costs ~$0.045/hr — cleanup when done!
# ================================================================
set -euo pipefail

REGION="ap-south-1"
AMI_ID=$(aws ec2 describe-images --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*" \
  --region "$REGION" --query "sort_by(Images, &CreationDate)[-1].ImageId" --output text)
INSTANCE_TYPE="t3.micro"
KEY_NAME="Practical-KeyPair"
VPC_NAME="Practical-VPC"
PUB_SUB_NAME="Practical-Public-Subnet"
PRIV_SUB_NAME="Practical-Private-Subnet"
STATE_FILE="$HOME/aws_state_network.txt"

G='\033[0;32m'; B='\033[0;34m'; Y='\033[1;33m'; NC='\033[0m'
info()    { echo -e "${B}[INFO]${NC}  $*"; }
success() { echo -e "${G}[OK]${NC}    $*"; }
banner()  { echo -e "\n${Y}══════════════════════════════════════════${NC}"; \
            echo -e "${Y}  $*${NC}"; \
            echo -e "${Y}══════════════════════════════════════════${NC}\n"; }

banner "VPC NETWORK — Set Up Infrastructure"
echo "  AMI    : $AMI_ID (Ubuntu 24.04 LTS)"
echo "  Type   : $INSTANCE_TYPE | Region: $REGION"
echo ""

# ── Step 1: Key Pair ─────────────────────────────────────────
info "Step 1 — Key Pair: $KEY_NAME"
if aws ec2 describe-key-pairs --key-names "$KEY_NAME" --region "$REGION" >/dev/null 2>&1; then
  info "  Key Pair '$KEY_NAME' already exists. Using it."
else
  info "  Creating Key Pair: $KEY_NAME"
  aws ec2 create-key-pair --key-name "$KEY_NAME" --region "$REGION" \
    --query "KeyMaterial" --output text > "$HOME/${KEY_NAME}.pem"
  chmod 400 "$HOME/${KEY_NAME}.pem"
  success "Key Pair created → $HOME/${KEY_NAME}.pem"
fi

# ── Step 2: VPC ──────────────────────────────────────────────
info "Step 2 — VPC: $VPC_NAME"
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=$VPC_NAME" \
  --region "$REGION" --query "Vpcs[0].VpcId" --output text 2>/dev/null || echo "None")

if [[ "$VPC_ID" == "None" || "$VPC_ID" == "null" ]]; then
  info "  Creating VPC (10.10.0.0/16)..."
  VPC_ID=$(aws ec2 create-vpc --cidr-block "10.10.0.0/16" --region "$REGION" \
    --query "Vpc.VpcId" --output text)
  aws ec2 create-tags --resources "$VPC_ID" --region "$REGION" \
    --tags Key=Name,Value="$VPC_NAME"
  aws ec2 modify-vpc-attribute --vpc-id "$VPC_ID" --enable-dns-hostnames --region "$REGION"
  aws ec2 modify-vpc-attribute --vpc-id "$VPC_ID" --enable-dns-support   --region "$REGION"
  success "VPC created: $VPC_ID"
else
  info "  VPC '$VPC_NAME' already exists ($VPC_ID). Using it."
fi

# ── Step 3: Public Subnet ────────────────────────────────────
info "Step 3 — Public Subnet: $PUB_SUB_NAME"
PUB_SUBNET=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=$PUB_SUB_NAME" \
  --region "$REGION" --query "Subnets[0].SubnetId" --output text 2>/dev/null || echo "None")

if [[ "$PUB_SUBNET" == "None" || "$PUB_SUBNET" == "null" ]]; then
  info "  Creating Public Subnet (10.10.1.0/24)..."
  AZ=$(aws ec2 describe-availability-zones --region "$REGION" --query "AvailabilityZones[0].ZoneName" --output text)
  PUB_SUBNET=$(aws ec2 create-subnet \
    --vpc-id "$VPC_ID" --cidr-block "10.10.1.0/24" \
    --availability-zone "$AZ" --region "$REGION" \
    --query "Subnet.SubnetId" --output text)
  aws ec2 create-tags --resources "$PUB_SUBNET" --region "$REGION" \
    --tags Key=Name,Value="$PUB_SUB_NAME" Key=Type,Value=Public
  aws ec2 modify-subnet-attribute \
    --subnet-id "$PUB_SUBNET" --map-public-ip-on-launch --region "$REGION"
  success "Public Subnet created: $PUB_SUBNET"
else
  info "  Public Subnet already exists ($PUB_SUBNET). Using it."
fi

# ── Step 4: Private Subnet ───────────────────────────────────
info "Step 4 — Private Subnet: $PRIV_SUB_NAME"
PRIV_SUBNET=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=$PRIV_SUB_NAME" \
  --region "$REGION" --query "Subnets[0].SubnetId" --output text 2>/dev/null || echo "None")

if [[ "$PRIV_SUBNET" == "None" || "$PRIV_SUBNET" == "null" ]]; then
  info "  Creating Private Subnet (10.10.2.0/24)..."
  PRIV_SUBNET=$(aws ec2 create-subnet \
    --vpc-id "$VPC_ID" --cidr-block "10.10.2.0/24" \
    --availability-zone "$AZ" --region "$REGION" \
    --query "Subnet.SubnetId" --output text)
  aws ec2 create-tags --resources "$PRIV_SUBNET" --region "$REGION" \
    --tags Key=Name,Value="$PRIV_SUB_NAME" Key=Type,Value=Private
  success "Private Subnet created: $PRIV_SUBNET"
else
  info "  Private Subnet already exists ($PRIV_SUBNET). Using it."
fi

# ── Step 5: Internet Gateway ─────────────────────────────────
info "Step 5 — Internet Gateway"
IGW_ID=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID" \
  --region "$REGION" --query "InternetGateways[0].InternetGatewayId" --output text 2>/dev/null || echo "None")

if [[ "$IGW_ID" == "None" || "$IGW_ID" == "null" ]]; then
  info "  Creating & Attaching Internet Gateway..."
  IGW_ID=$(aws ec2 create-internet-gateway --region "$REGION" \
    --query "InternetGateway.InternetGatewayId" --output text)
  aws ec2 create-tags --resources "$IGW_ID" --region "$REGION" \
    --tags Key=Name,Value="Practical-IGW"
  aws ec2 attach-internet-gateway \
    --internet-gateway-id "$IGW_ID" --vpc-id "$VPC_ID" --region "$REGION"
  success "Internet Gateway created and attached: $IGW_ID"
else
  info "  Internet Gateway already exists and attached ($IGW_ID). Using it."
fi

# ── Step 6: Public Route Table ───────────────────────────────
info "Step 6 — Public Route Table"
PUB_RT=$(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=Public-RouteTable" \
  --region "$REGION" --query "RouteTables[0].RouteTableId" --output text 2>/dev/null || echo "None")

if [[ "$PUB_RT" == "None" || "$PUB_RT" == "null" ]]; then
  info "  Creating Public Route Table..."
  PUB_RT=$(aws ec2 create-route-table --vpc-id "$VPC_ID" --region "$REGION" \
    --query "RouteTable.RouteTableId" --output text)
  aws ec2 create-tags --resources "$PUB_RT" --region "$REGION" \
    --tags Key=Name,Value=Public-RouteTable
  aws ec2 create-route \
    --route-table-id "$PUB_RT" \
    --destination-cidr-block "0.0.0.0/0" \
    --gateway-id "$IGW_ID" --region "$REGION" > /dev/null
  PUB_RT_ASSOC=$(aws ec2 associate-route-table \
    --route-table-id "$PUB_RT" --subnet-id "$PUB_SUBNET" --region "$REGION" \
    --query "AssociationId" --output text)
  success "Public Route Table created: $PUB_RT"
else
  info "  Public Route Table already exists ($PUB_RT). Using it."
  PUB_RT_ASSOC=$(aws ec2 describe-route-tables --route-table-ids "$PUB_RT" --region "$REGION" \
    --query "RouteTables[0].Associations[?SubnetId=='$PUB_SUBNET'].RouteTableAssociationId" --output text 2>/dev/null || echo "None")
fi

# ── Step 7: Elastic IP for NAT ───────────────────────────────
info "Step 7 — Elastic IP for NAT Gateway"
EIP_ALLOC=$(aws ec2 describe-addresses --filters "Name=tag:Name,Values=NAT-ElasticIP" \
  --region "$REGION" --query "Addresses[0].AllocationId" --output text 2>/dev/null || echo "None")

if [[ "$EIP_ALLOC" == "None" || "$EIP_ALLOC" == "null" ]]; then
  info "  Allocating new Elastic IP..."
  EIP_ALLOC=$(aws ec2 allocate-address --domain vpc --region "$REGION" \
    --query "AllocationId" --output text)
  aws ec2 create-tags --resources "$EIP_ALLOC" --region "$REGION" \
    --tags Key=Name,Value=NAT-ElasticIP
fi
EIP_IP=$(aws ec2 describe-addresses --allocation-ids "$EIP_ALLOC" --region "$REGION" \
  --query "Addresses[0].PublicIp" --output text)
success "Elastic IP: $EIP_IP (Allocation: $EIP_ALLOC)"

# ── Step 8: NAT Gateway ──────────────────────────────────────
info "Step 8 — NAT Gateway"
NAT_GW=$(aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=NAT-Gateway" "Name=state,Values=available,pending" \
  --region "$REGION" --query "NatGateways[0].NatGatewayId" --output text 2>/dev/null || echo "None")

if [[ "$NAT_GW" == "None" || "$NAT_GW" == "null" ]]; then
  info "  Creating NAT Gateway in Public Subnet (~60 seconds)..."
  NAT_GW=$(aws ec2 create-nat-gateway \
    --subnet-id "$PUB_SUBNET" --allocation-id "$EIP_ALLOC" --region "$REGION" \
    --tag-specifications "ResourceType=natgateway,Tags=[{Key=Name,Value=NAT-Gateway}]" \
    --query "NatGateway.NatGatewayId" --output text)
  echo "  NAT GW: $NAT_GW — waiting for available state..."
  aws ec2 wait nat-gateway-available --nat-gateway-ids "$NAT_GW" --region "$REGION"
  success "NAT Gateway created: $NAT_GW"
else
  info "  NAT Gateway already exists ($NAT_GW). Using it."
fi

# ── Step 9: Private Route Table ──────────────────────────────
info "Step 9 — Private Route Table"
PRIV_RT=$(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=Private-RouteTable" \
  --region "$REGION" --query "RouteTables[0].RouteTableId" --output text 2>/dev/null || echo "None")

if [[ "$PRIV_RT" == "None" || "$PRIV_RT" == "null" ]]; then
  info "  Creating Private Route Table (via NAT)..."
  PRIV_RT=$(aws ec2 create-route-table --vpc-id "$VPC_ID" --region "$REGION" \
    --query "RouteTable.RouteTableId" --output text)
  aws ec2 create-tags --resources "$PRIV_RT" --region "$REGION" \
    --tags Key=Name,Value=Private-RouteTable
  aws ec2 create-route \
    --route-table-id "$PRIV_RT" \
    --destination-cidr-block "0.0.0.0/0" \
    --nat-gateway-id "$NAT_GW" --region "$REGION" > /dev/null
  PRIV_RT_ASSOC=$(aws ec2 associate-route-table \
    --route-table-id "$PRIV_RT" --subnet-id "$PRIV_SUBNET" --region "$REGION" \
    --query "AssociationId" --output text)
  success "Private Route Table created: $PRIV_RT"
else
  info "  Private Route Table already exists ($PRIV_RT). Using it."
  PRIV_RT_ASSOC=$(aws ec2 describe-route-tables --route-table-ids "$PRIV_RT" --region "$REGION" \
    --query "RouteTables[0].Associations[?SubnetId=='$PRIV_SUBNET'].RouteTableAssociationId" --output text 2>/dev/null || echo "None")
fi

# ── Step 10: Security Groups ─────────────────────────────────
info "Step 10 — Security Groups"
PUB_SG=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" "Name=group-name,Values=Practical-Public-SG" \
  --region "$REGION" --query "SecurityGroups[0].GroupId" --output text 2>/dev/null || echo "None")

if [[ "$PUB_SG" == "None" || "$PUB_SG" == "null" ]]; then
  info "  Creating Public Security Group..."
  PUB_SG=$(aws ec2 create-security-group \
    --group-name "Practical-Public-SG" --description "SSH from internet" \
    --vpc-id "$VPC_ID" --region "$REGION" --query "GroupId" --output text)
  aws ec2 create-tags --resources "$PUB_SG" --region "$REGION" \
    --tags Key=Name,Value="Practical-Public-SG"
else
  info "  Public Security Group already exists ($PUB_SG)."
fi
aws ec2 authorize-security-group-ingress \
  --group-id "$PUB_SG" --protocol tcp --port 22 --cidr "0.0.0.0/0" --region "$REGION" 2>/dev/null || true

PRIV_SG=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" "Name=group-name,Values=Practical-Private-SG" \
  --region "$REGION" --query "SecurityGroups[0].GroupId" --output text 2>/dev/null || echo "None")

if [[ "$PRIV_SG" == "None" || "$PRIV_SG" == "null" ]]; then
  info "  Creating Private Security Group..."
  PRIV_SG=$(aws ec2 create-security-group \
    --group-name "Practical-Private-SG" --description "SSH from public subnet only" \
    --vpc-id "$VPC_ID" --region "$REGION" --query "GroupId" --output text)
  aws ec2 create-tags --resources "$PRIV_SG" --region "$REGION" \
    --tags Key=Name,Value="Practical-Private-SG"
else
  info "  Private Security Group already exists ($PRIV_SG)."
fi
aws ec2 authorize-security-group-ingress \
  --group-id "$PRIV_SG" --protocol tcp --port 22 --cidr "10.10.1.0/24" --region "$REGION" 2>/dev/null || true
aws ec2 authorize-security-group-ingress \
  --group-id "$PRIV_SG" --protocol icmp --port -1 --cidr "10.10.0.0/16" --region "$REGION" 2>/dev/null || true
success "Security Groups checked/configured."

# ── Step 11: Launch EC2 instances ────────────────────────────
info "Step 11 — Public Compute Instance"
PUB_INST=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=Public-EC2-Instance" "Name=instance-state-name,Values=running" "Name=vpc-id,Values=$VPC_ID" \
  --region "$REGION" --query "Reservations[0].Instances[0].InstanceId" --output text 2>/dev/null || echo "None")

if [[ "$PUB_INST" == "None" || "$PUB_INST" == "null" ]]; then
  info "  Launching EC2 in Public Subnet..."
  PUB_INST=$(aws ec2 run-instances \
    --image-id "$AMI_ID" --instance-type "$INSTANCE_TYPE" \
    --key-name "$KEY_NAME" --subnet-id "$PUB_SUBNET" \
    --security-group-ids "$PUB_SG" --region "$REGION" --count 1 \
    --associate-public-ip-address \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=Public-EC2-Instance}]" \
    --query "Instances[0].InstanceId" --output text)
  success "Public EC2 launched: $PUB_INST"
else
  info "  Public Compute Node already exists ($PUB_INST). Using it."
fi

info "Step 12 — Private Compute Instance"
PRIV_INST=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=Private-EC2-Instance" "Name=instance-state-name,Values=running" "Name=vpc-id,Values=$VPC_ID" \
  --region "$REGION" --query "Reservations[0].Instances[0].InstanceId" --output text 2>/dev/null || echo "None")

if [[ "$PRIV_INST" == "None" || "$PRIV_INST" == "null" ]]; then
  info "  Launching EC2 in Private Subnet..."
  PRIV_INST=$(aws ec2 run-instances \
    --image-id "$AMI_ID" --instance-type "$INSTANCE_TYPE" \
    --key-name "$KEY_NAME" --subnet-id "$PRIV_SUBNET" \
    --security-group-ids "$PRIV_SG" --region "$REGION" --count 1 \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=Private-EC2-Instance}]" \
    --query "Instances[0].InstanceId" --output text)
  success "Private EC2 launched: $PRIV_INST"
else
  info "  Private Compute Node already exists ($PRIV_INST). Using it."
fi

info "Waiting for both instances to be running..."
aws ec2 wait instance-running \
  --instance-ids "$PUB_INST" "$PRIV_INST" --region "$REGION"

PUB_IP=$(aws ec2 describe-instances --instance-ids "$PUB_INST" --region "$REGION" \
  --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
PRIV_IP=$(aws ec2 describe-instances --instance-ids "$PRIV_INST" --region "$REGION" \
  --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)

# ── Save State ────────────────────────────────────────────────
cat > "$STATE_FILE" <<EOF
REGION=$REGION
VPC_ID=$VPC_ID
PUB_SUBNET=$PUB_SUBNET
PRIV_SUBNET=$PRIV_SUBNET
IGW_ID=$IGW_ID
PUB_RT=$PUB_RT
PRIV_RT=$PRIV_RT
PUB_RT_ASSOC=$PUB_RT_ASSOC
PRIV_RT_ASSOC=$PRIV_RT_ASSOC
EIP_ALLOC=$EIP_ALLOC
EIP_IP=$EIP_IP
NAT_GW=$NAT_GW
PUB_SG=$PUB_SG
PRIV_SG=$PRIV_SG
PUB_INST=$PUB_INST
PRIV_INST=$PRIV_INST
KEY_NAME=$KEY_NAME
PUB_IP=$PUB_IP
PRIV_IP=$PRIV_IP
AMI_ID=$AMI_ID
EOF

banner "VPC NETWORK — COMPLETE SUMMARY"
cat <<SUMMARY
  ╔══════════════════════════════════════════════════════════════╗
  ║              RESOURCES DEPLOYED                              ║
  ╠═══════════════════════╦══════════════════════════════════════╣
  ║ Resource              ║ Value                                ║
  ╠═══════════════════════╬══════════════════════════════════════╣
  ║ VPC ID                ║ $VPC_ID                               ║
  ║ VPC CIDR              ║ 10.0.0.0/16                          ║
  ║ Public Subnet         ║ $PUB_SUBNET  10.0.1.0/24             ║
  ║ Private Subnet        ║ $PRIV_SUBNET  10.0.2.0/24            ║
  ║ Internet Gateway      ║ $IGW_ID                              ║
  ║ NAT Gateway           ║ $NAT_GW                              ║
  ║ NAT EIP               ║ $EIP_IP  ($EIP_ALLOC)                ║
  ║ Public Route Table    ║ $PUB_RT                              ║
  ║ Private Route Table   ║ $PRIV_RT                             ║
  ║ Public SG             ║ $PUB_SG                              ║
  ║ Private SG            ║ $PRIV_SG                             ║
  ║ Public Compute Node   ║ $PUB_INST   IP: $PUB_IP              ║
  ║ Private Compute Node  ║ $PRIV_INST  IP: $PRIV_IP             ║
  ║ Key Pair              ║ $KEY_NAME                            ║
  ║ Key File              ║ $HOME/${KEY_NAME}.pem                ║
  ║ AMI Used              ║ $AMI_ID                              ║
  ║ Region                ║ $REGION                              ║
  ╠═══════════════════════╩══════════════════════════════════════╣
  ║              DETAILS NEEDED TO CLEANUP                       ║
  ╠══════════════════════════════════════════════════════════════╣
  ║  VPC:         $VPC_ID                                        ║
  ║  Instances:   $PUB_INST  $PRIV_INST                          ║
  ║  NAT Gateway: $NAT_GW                                        ║
  ║  EIP Alloc:   $EIP_ALLOC                                     ║
  ║  IGW:         $IGW_ID                                        ║
  ║  State File:  $STATE_FILE                                    ║
  ╠══════════════════════════════════════════════════════════════╣
  ║  Run: ./3_network_cleanup.sh  (reads state file automatically) ║
  ║  ⚠️  NAT Gateway costs ~\$0.045/hr — cleanup when done!      ║
  ╚══════════════════════════════════════════════════════════════╝

  Connect: EC2 Console → $PUB_INST → Connect → EC2 Instance Connect
SUMMARY
