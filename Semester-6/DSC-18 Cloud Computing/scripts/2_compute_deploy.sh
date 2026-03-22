#  AMI    : Latest Ubuntu Server LTS
#  TYPE   : t3.micro (Free Tier eligible)
#  USER   : ubuntu
#  RUN    : chmod +x 2_compute_deploy.sh && ./2_compute_deploy.sh
#  DELETE : ./2_compute_cleanup.sh
#  STATE  : $HOME/aws_state_compute.txt
# ================================================================
set -euo pipefail

REGION="ap-south-1"
AMI_ID=$(aws ec2 describe-images --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*" \
  --region "$REGION" --query "sort_by(Images, &CreationDate)[-1].ImageId" --output text)
INSTANCE_TYPE="t3.micro"
KEY_NAME="Practical-KeyPair"
SG_NAME="Practical-FirstEC2-SG"
INST_NAME="First-EC2-Instance"
STATE_FILE="$HOME/aws_state_compute.txt"

G='\033[0;32m'; B='\033[0;34m'; Y='\033[1;33m'; NC='\033[0m'
info()    { echo -e "${B}[INFO]${NC}  $*"; }
success() { echo -e "${G}[OK]${NC}    $*"; }
banner()  { echo -e "\n${Y}══════════════════════════════════════════${NC}"; \
            echo -e "${Y}  $*${NC}"; \
            echo -e "${Y}══════════════════════════════════════════${NC}\n"; }

banner "AWS COMPUTE — Launch EC2 Instance"
echo "  AMI    : $AMI_ID (Ubuntu 24.04 LTS)"
echo "  Type   : $INSTANCE_TYPE (2 vCPU, 8 GB)"
echo "  Region : $REGION"
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

# ── Step 2: Networking (Independence & "From Scratch" logic) ───
info "Step 2 — Networking: VPC Discovery"
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=Practical-VPC" --query "Vpcs[0].VpcId" --output text --region "$REGION" 2>/dev/null || echo "None")
if [[ "$VPC_ID" == "None" || "$VPC_ID" == "null" ]]; then
  VPC_ID=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --region "$REGION" --query "Vpcs[0].VpcId" --output text 2>/dev/null || echo "None")
fi

if [[ "$VPC_ID" == "None" || "$VPC_ID" == "null" ]]; then
  info "  No suitable VPC found. Creating 'Practical-Compute-VPC'..."
  VPC_ID=$(aws ec2 create-vpc --cidr-block "10.20.0.0/16" --region "$REGION" --query "Vpc.VpcId" --output text)
  aws ec2 create-tags --resources "$VPC_ID" --region "$REGION" --tags Key=Name,Value="Practical-Compute-VPC"
  aws ec2 modify-vpc-attribute --vpc-id "$VPC_ID" --enable-dns-hostnames --region "$REGION"
  aws ec2 modify-vpc-attribute --vpc-id "$VPC_ID" --enable-dns-support --region "$REGION"
  IGW_ID=$(aws ec2 create-internet-gateway --region "$REGION" --query "InternetGateway.InternetGatewayId" --output text)
  aws ec2 attach-internet-gateway --internet-gateway-id "$IGW_ID" --vpc-id "$VPC_ID" --region "$REGION"
  # Route Table
  RT_ID=$(aws ec2 create-route-table --vpc-id "$VPC_ID" --region "$REGION" --query "RouteTable.RouteTableId" --output text)
  aws ec2 create-route --route-table-id "$RT_ID" --destination-cidr-block "0.0.0.0/0" --gateway-id "$IGW_ID" --region "$REGION" > /dev/null
fi

SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --region "$REGION" --query "Subnets[0].SubnetId" --output text 2>/dev/null || echo "None")
if [[ "$SUBNET_ID" == "None" || "$SUBNET_ID" == "null" ]]; then
  info "  Creating subnet..."
  SUBNET_ID=$(aws ec2 create-subnet --vpc-id "$VPC_ID" --cidr-block "10.20.1.0/24" --region "$REGION" --query "Subnet.SubnetId" --output text 2>/dev/null || \
           aws ec2 create-default-subnet --region "$REGION" --query "Subnet.SubnetId" --output text)
fi
success "VPC: $VPC_ID | Subnet: $SUBNET_ID"

SG_ID=$(aws ec2 describe-security-groups --group-names "$SG_NAME" --region "$REGION" \
  --query "SecurityGroups[0].GroupId" --output text 2>/dev/null || echo "NOT_FOUND")

if [[ "$SG_ID" == "NOT_FOUND" ]]; then
  info "  Creating Security Group..."
  SG_ID=$(aws ec2 create-security-group \
    --group-name "$SG_NAME" \
    --description "Allow SSH Access" \
    --vpc-id "$VPC_ID" \
    --region "$REGION" \
    --query "GroupId" --output text)
  aws ec2 create-tags --resources "$SG_ID" \
    --tags Key=Name,Value="$SG_NAME" --region "$REGION"
  success "Security Group created: $SG_ID"
else
  info "  Security Group '$SG_NAME' already exists ($SG_ID). Using it."
fi

# ── Step 3: SSH Inbound Rule ──────────────────────────────────
info "Step 3 — Adding SSH inbound rule (port 22)"
aws ec2 authorize-security-group-ingress \
  --group-id "$SG_ID" --protocol tcp --port 22 --cidr "0.0.0.0/0" \
  --region "$REGION" 2>/dev/null || true
success "SSH (port 22) rule checked/added."

# ── Step 4: Launch EC2 ───────────────────────────────────────
info "Step 4 — Compute Instance: $INST_NAME"
INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=$INST_NAME" "Name=instance-state-name,Values=running" \
  --region "$REGION" --query "Reservations[0].Instances[0].InstanceId" --output text 2>/dev/null || echo "None")

if [[ "$INSTANCE_ID" == "None" || "$INSTANCE_ID" == "null" ]]; then
  info "  Launching new instance..."
  INSTANCE_ID=$(aws ec2 run-instances \
    --image-id "$AMI_ID" \
    --instance-type "$INSTANCE_TYPE" \
    --key-name "$KEY_NAME" \
    --security-group-ids "$SG_ID" \
    --subnet-id "$SUBNET_ID" \
    --region "$REGION" \
    --count 1 \
    --tag-specifications \
      "ResourceType=instance,Tags=[
        {Key=Name,Value=$INST_NAME},
        {Key=AMI,Value=$AMI_ID}]" \
    --query "Instances[0].InstanceId" \
    --output text)
  success "Instance launched: $INSTANCE_ID"
else
  info "  Running instance 'EC2-ComputeNode' already exists ($INSTANCE_ID). Using it."
fi

# ── Step 5: Wait ──────────────────────────────────────────────
info "Step 5 — Waiting for 'running' state..."
aws ec2 wait instance-running \
  --instance-ids "$INSTANCE_ID" --region "$REGION"
success "Instance is RUNNING."

# ── Step 6: Fetch Details ─────────────────────────────────────
info "Step 6 — Fetching instance details"
aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" --region "$REGION" \
  --query "Reservations[0].Instances[0].{
      ID:InstanceId, State:State.Name,
      Type:InstanceType, PublicIP:PublicIpAddress,
      PrivateIP:PrivateIpAddress, AZ:Placement.AvailabilityZone,
      AMI:ImageId}" \
  --output table

PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" --region "$REGION" \
  --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

# ── Save state ────────────────────────────────────────────────
cat > "$STATE_FILE" <<EOF
REGION=$REGION
INSTANCE_ID=$INSTANCE_ID
SG_ID=$SG_ID
SG_NAME=$SG_NAME
VPC_ID=$VPC_ID
KEY_NAME=$KEY_NAME
PUBLIC_IP=$PUBLIC_IP
AMI_ID=$AMI_ID
INSTANCE_TYPE=$INSTANCE_TYPE
EOF

banner "AWS COMPUTE — COMPLETE SUMMARY"
cat <<SUMMARY
  ╔════════════════════════════════════════════════════════════════════════════════╗
  ║              RESOURCES DEPLOYED                                                ║
  ╠═══════════════════════╦════════════════════════════════════════════════════════╣
  ║ Resource              ║ Value                                                  ║
  ╠═══════════════════════╬════════════════════════════════════════════════════════╣
  ║ EC2 Instance ID       ║ $INSTANCE_ID                                           ║
  ║ Public IP             ║ $PUBLIC_IP                                             ║
  ║ Key Pair Name         ║ $KEY_NAME                                              ║
  ║ Key File Location     ║ $HOME/${KEY_NAME}.pem                                  ║
  ║ Security Group ID     ║ $SG_ID                                                 ║
  ║ Security Group Name   ║ $SG_NAME                                               ║
  ║ VPC ID                ║ $VPC_ID                                                ║
  ║ AMI Used              ║ $AMI_ID                                                ║
  ║ Instance Type         ║ $INSTANCE_TYPE                                         ║
  ║ Region                ║ $REGION                                                ║
  ╠═══════════════════════╩════════════════════════════════════════════════════════╣
  ║              DETAILS NEEDED TO CLEANUP                                         ║
  ╠════════════════════════════════════════════════════════════════════════════════╣
  ║  Instance ID  : $INSTANCE_ID                                                   ║
  ║  SG ID        : $SG_ID                                                         ║
  ║  Key Pair     : $KEY_NAME                                                      ║
  ║  Region       : $REGION                                                        ║
  ║  State File   : $STATE_FILE                                                    ║
  ╠════════════════════════════════════════════════════════════════════════════════╣
  ║  Run: ./2_compute_cleanup.sh  (reads state file automatically)                 ║
  ╚════════════════════════════════════════════════════════════════════════════════╝

  Connect to Instance:
  EC2 Console → Instances → $INSTANCE_ID → Connect → EC2 Instance Connect
SUMMARY
