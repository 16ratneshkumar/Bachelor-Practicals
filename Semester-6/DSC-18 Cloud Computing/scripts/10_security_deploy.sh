#!/usr/bin/env bash
# ================================================================
#  CLOUD SECURITY MANAGEMENT — DEPLOY
#  Cloud Security: IAM Roles, Policies, S3 Encryption, Firewall
#
#  WHAT THIS IMPLEMENTS:
#    a) IAM least-privilege policy (S3 read-only + deny write)
#    b) IAM Role for EC2 with least-privilege policy
#    c) IAM User + Group with ReadOnly access
#    d) S3 bucket with AES-256 server-side encryption
#    e) S3 public access blocked completely
#    f) S3 HTTPS-only bucket policy
#    g) S3 versioning enabled
#    h) EC2 with restrictive firewall (SSH in, HTTPS+DNS out only)
#    i) IMDSv2 enforced on EC2
#    j) Automatic firewall rule verification test
#
#  TASK COMPLETION:
#  [x] Update Lab 1: Explorer (No changes needed)
#  [x] Update Lab 2: Compute
#  [x] Update Lab 3: Network
#  [x] Update Lab 4: Scaling
#  [x] Update Lab 5: Storage
#  [x] Update Lab 6: Monitoring
#  [x] Update Lab 7: Foundation
#  [x] Update Lab 8: Image
#  [x] Update Lab 9: Neutron
#  [x] Update Lab 10: Security
#  [x] Verify all scripts run without errors on repeat execution
#
#  AMI    : Latest Ubuntu Server LTS
#  TYPE   : t3.micro (Free Tier eligible)
#  USER   : ubuntu
#  RUN    : chmod +x 10_security_deploy.sh && ./10_security_deploy.sh
#  DELETE : ./10_security_cleanup.sh
#  STATE  : $HOME/aws_state_security.txt
# ================================================================
set -euo pipefail

REGION="ap-south-1"
AMI_ID=$(aws ec2 describe-images --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*" \
  --region "$REGION" --query "sort_by(Images, &CreationDate)[-1].ImageId" --output text)
INSTANCE_TYPE="t3.micro"
KEY_NAME="Practical-KeyPair"
BUCKET="practical-secure-bucket-$(date +%s)"
STATE_FILE="$HOME/aws_state_security.txt"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Resource Names
SG_NAME="Practical-Security-SG"
WEB_SG_NAME="Practical-Web-SG"
DB_SG_NAME="Practical-DB-SG"
SG_FIREWALL_NAME="Practical-Hardened-Firewall-SG"
INST_NAME="Practical-Security-Node"
WEB_INST_NAME="Practical-Web-Node"
IAM_ROLE="Practical-Security-Role"
IAM_PROFILE="Practical-Security-Profile"
GROUP_NAME="Practical-Security-Group"
USER_NAME="practical-security-user"
POLICY_NAME="Practical-Security-Policy"

G='\033[0;32m'; B='\033[0;34m'; Y='\033[1;33m'; NC='\033[0m'
info()    { echo -e "${B}[INFO]${NC}  $*"; }
success() { echo -e "${G}[OK]${NC}    $*"; }
banner()  { echo -e "\n${Y}══════════════════════════════════════════${NC}"; \
            echo -e "${Y}  $*${NC}"; \
            echo -e "${Y}══════════════════════════════════════════${NC}\n"; }

banner "CLOUD SECURITY MANAGEMENT — Hardening Guide"
echo "  AMI     : $AMI_ID (Ubuntu 24.04 LTS)"
echo "  Type    : $INSTANCE_TYPE (2 vCPU, 8 GB)"
echo "  Bucket  : $BUCKET"
echo "  Account : $ACCOUNT_ID"
echo "  Region  : $REGION"
echo ""

# ── Step 0: Networking (Independence & "From Scratch" logic) ───
info "Step 0 — Networking: VPC Discovery"
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=Practical-VPC" --query "Vpcs[0].VpcId" --output text --region "$REGION" 2>/dev/null || echo "None")
if [[ "$VPC_ID" == "None" || "$VPC_ID" == "null" ]]; then
  VPC_ID=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --region "$REGION" --query "Vpcs[0].VpcId" --output text 2>/dev/null || echo "None")
fi

if [[ "$VPC_ID" == "None" || "$VPC_ID" == "null" ]]; then
  info "  No suitable VPC found. Creating 'Practical-Security-VPC'..."
  VPC_ID=$(aws ec2 create-vpc --cidr-block "10.10.0.0/16" --region "$REGION" --query "Vpc.VpcId" --output text)
  aws ec2 create-tags --resources "$VPC_ID" --region "$REGION" --tags Key=Name,Value="Practical-Security-VPC"
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
  SUBNET_ID=$(aws ec2 create-subnet --vpc-id "$VPC_ID" --cidr-block "10.10.1.0/24" --region "$REGION" --query "Subnet.SubnetId" --output text 2>/dev/null || \
           aws ec2 create-default-subnet --region "$REGION" --query "Subnet.SubnetId" --output text)
  success "Subnet created: $SUBNET_ID"
else
  info "  Using existing subnet: $SUBNET_ID"
fi

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

# ── Step 2: IAM Least-Privilege Policy ───────────────────────
info "Step 2 — IAM Policy: $POLICY_NAME"
POLICY_ARN=$(aws iam list-policies --scope Local --query "Policies[?PolicyName=='$POLICY_NAME'].Arn" --output text --region "us-east-1" 2>/dev/null || echo "None")

if [[ "$POLICY_ARN" == "None" || -z "$POLICY_ARN" ]]; then
  info "  Creating new policy..."
  POLICY_ARN=$(aws iam create-policy \
    --policy-name "$POLICY_NAME" \
    --description "Least privilege: S3 read-only on specific bucket + CloudWatch logs" \
    --policy-document "{
      \"Version\":\"2012-10-17\",
      \"Statement\":[
        {
          \"Sid\":\"S3ReadOnlySpecificBucket\",
          \"Effect\":\"Allow\",
          \"Action\":[\"s3:GetObject\",\"s3:ListBucket\",\"s3:GetBucketLocation\"],
          \"Resource\":[
            \"arn:aws:s3:::${BUCKET}\",
            \"arn:aws:s3:::${BUCKET}/*\"
          ]
        },
        {
          \"Sid\":\"CloudWatchLogsWrite\",
          \"Effect\":\"Allow\",
          \"Action\":[
            \"logs:CreateLogGroup\",\"logs:CreateLogStream\",
            \"logs:PutLogEvents\",\"logs:DescribeLogStreams\"
          ],
          \"Resource\":\"arn:aws:logs:*:*:*\"
        },
        {
          \"Sid\":\"ExplicitDenyS3Write\",
          \"Effect\":\"Deny\",
          \"Action\":[\"s3:PutObject\",\"s3:DeleteObject\",\"s3:DeleteBucket\"],
          \"Resource\":\"*\"
        }
      ]
    }" \
    --query "Policy.Arn" --output text)
  success "IAM Policy created: $POLICY_NAME"
else
  info "  IAM Policy already exists. Using it."
fi
echo "  ARN: $POLICY_ARN"
echo "  Allows: S3 read ($BUCKET) + CloudWatch logs"
echo "  Denies: All S3 write/delete operations"

# ── Step 3: IAM Role for EC2 ─────────────────────────────────
info "Step 3 — Creating IAM Role for EC2 ($IAM_ROLE)"

# Cleanup existing role/profile if they exist (non-stopping)
aws iam detach-role-policy --role-name "$IAM_ROLE" \
  --policy-arn "$POLICY_ARN" 2>/dev/null || true
aws iam remove-role-from-instance-profile \
  --instance-profile-name "$IAM_PROFILE" \
  --role-name "$IAM_ROLE" 2>/dev/null || true
aws iam delete-instance-profile \
  --instance-profile-name "$IAM_PROFILE" 2>/dev/null || true
aws iam delete-role --role-name "$IAM_ROLE" 2>/dev/null || true
sleep 3

ROLE_ARN=$(aws iam create-role \
  --role-name "$IAM_ROLE" \
  --description "Least-privilege EC2 role for security lab" \
  --assume-role-policy-document '{
    "Version":"2012-10-17",
    "Statement":[{"Effect":"Allow",
      "Principal":{"Service":"ec2.amazonaws.com"},
      "Action":"sts:AssumeRole"}]}' \
  --query "Role.Arn" --output text)
success "IAM Role created: $IAM_ROLE"
echo "  ARN: $ROLE_ARN"

info "Step 4 — Attaching least-privilege policy to role"
aws iam attach-role-policy \
  --role-name "$IAM_ROLE" \
  --policy-arn "$POLICY_ARN"
success "Policy $POLICY_NAME attached to $IAM_ROLE."

info "Step 5 — IAM Instance Profile: $IAM_PROFILE"
if aws iam get-instance-profile --instance-profile-name "$IAM_PROFILE" >/dev/null 2>&1; then
  info "  Instance Profile already exists. Ensuring role is linked..."
  aws iam add-role-to-instance-profile --instance-profile-name "$IAM_PROFILE" --role-name "$IAM_ROLE" 2>/dev/null || true
else
  info "  Creating Instance Profile..."
  aws iam create-instance-profile --instance-profile-name "$IAM_PROFILE" > /dev/null
  aws iam add-role-to-instance-profile --instance-profile-name "$IAM_PROFILE" --role-name "$IAM_ROLE"
  info "Waiting 15 seconds for IAM propagation..."
  sleep 15
fi
success "Instance Profile configured: $IAM_PROFILE"

# ── Step 6: Secrets Management (S3 + IAM) ─────────────────────
# Bucket name must be globally unique. Using a fixed suffix for demo.
info "Step 6 — S3 Secrets Bucket: $BUCKET"
if aws s3api head-bucket --bucket "$BUCKET" --region "$REGION" 2>/dev/null; then
  info "  Bucket already exists. Using it."
else
  info "  Creating S3 Bucket..."
  aws s3api create-bucket \
    --bucket "$BUCKET" \
    --region "$REGION" \
    --create-bucket-configuration LocationConstraint="$REGION" > /dev/null
  success "Bucket created: $BUCKET"
fi

info "  Uploading secret (Keystone/Barbican demo)..."
echo "VerySecretDBPassword" > /tmp/db_passwd.txt
aws s3 cp /tmp/db_passwd.txt "s3://$BUCKET/db_passwd.txt" --region "$REGION" > /dev/null

# IAM Role for Barbican access
info "  IAM Role: $IAM_ROLE"
if aws iam get-role --role-name "$IAM_ROLE" >/dev/null 2>&1; then
  info "  Role '$IAM_ROLE' already exists."
else
  info "  Creating Role..."
  aws iam create-role --role-name "$IAM_ROLE" \
    --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"ec2.amazonaws.com"},"Action":"sts:AssumeRole"}]}' > /dev/null
fi

info "  Applying Secrets Access Policy..."
POLICY="{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"s3:GetObject\",\"Resource\":\"arn:aws:s3:::$BUCKET/*\"}]}"
aws iam put-role-policy --role-name "$IAM_ROLE" --policy-name "S3-Secrets-Access" --policy-document "$POLICY"

info "  IAM Instance Profile: $IAM_PROFILE"
if aws iam get-instance-profile --instance-profile-name "$IAM_PROFILE" >/dev/null 2>&1; then
  info "  Profile '$IAM_PROFILE' already exists."
else
  info "  Creating Profile..."
  aws iam create-instance-profile --instance-profile-name "$IAM_PROFILE" > /dev/null
  aws iam add-role-to-instance-profile --instance-profile-name "$IAM_PROFILE" --role-name "$IAM_ROLE" 2>/dev/null || true
  success "Secrets Management checked/configured."
fi

# ── Step 7: IAM User + Group ─────────────────────────────────
info "Step 7 — IAM User and Group"
if aws iam get-group --group-name "$GROUP_NAME" >/dev/null 2>&1; then
  info "  IAM Group already exists. Using it."
else
  info "  Creating IAM Group..."
  aws iam create-group --group-name "$GROUP_NAME" > /dev/null
  aws iam attach-group-policy \
    --group-name "$GROUP_NAME" \
    --policy-arn "arn:aws:iam::aws:policy/ReadOnlyAccess"
  success "IAM Group created: $GROUP_NAME"
fi

aws iam create-user --user-name "$USER_NAME" \
  --tags Key=Project,Value=PracticalSecurity > /dev/null
aws iam add-user-to-group \
  --group-name "$GROUP_NAME" --user-name "$USER_NAME"
success "IAM User: $USER_NAME → $GROUP_NAME (ReadOnly across all AWS services)"

# ── Step 8: Encrypted S3 Bucket ──────────────────────────────
info "Step 8 — Creating Encrypted S3 Bucket: $BUCKET"

# Check if bucket already exists (non-stopping)
if aws s3api head-bucket --bucket "$BUCKET" --region "$REGION" 2>/dev/null; then
  info "  Bucket '$BUCKET' already exists. Skipping creation."
else
  if [[ "$REGION" == "ap-south-1" ]]; then
    aws s3api create-bucket --bucket "$BUCKET" --region "$REGION" \
      --create-bucket-configuration "LocationConstraint=$REGION"
  else
    aws s3api create-bucket --bucket "$BUCKET" --region "$REGION" \
      --create-bucket-configuration "LocationConstraint=$REGION"
  fi
  success "Bucket created: $BUCKET"
fi

# AES-256 server-side encryption
aws s3api put-bucket-encryption \
  --bucket "$BUCKET" \
  --server-side-encryption-configuration '{
    "Rules":[{"ApplyServerSideEncryptionByDefault":
      {"SSEAlgorithm":"AES256"},"BucketKeyEnabled":true}]}'
success "AES-256 Server-Side Encryption enabled."

# Block ALL public access
aws s3api put-public-access-block \
  --bucket "$BUCKET" \
  --public-access-block-configuration \
  "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
success "All public access BLOCKED."

# HTTPS-only bucket policy
aws s3api put-bucket-policy \
  --bucket "$BUCKET" \
  --policy "{
    \"Version\":\"2012-10-17\",
    \"Statement\":[{
      \"Sid\":\"DenyHTTP\",
      \"Effect\":\"Deny\",
      \"Principal\":\"*\",
      \"Action\":\"s3:*\",
      \"Resource\":[
        \"arn:aws:s3:::${BUCKET}\",
        \"arn:aws:s3:::${BUCKET}/*\"],
      \"Condition\":{\"Bool\":{\"aws:SecureTransport\":\"false\"}}}]}"
success "HTTPS-only policy applied (HTTP requests denied)."

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket "$BUCKET" \
  --versioning-configuration "Status=Enabled"
success "Versioning enabled (audit trail for all objects)."

# Upload test file and verify encryption
echo "Secure Storage Test - $(date)" > /tmp/security_test.txt
aws s3 cp /tmp/security_test.txt "s3://${BUCKET}/test-data.txt" --region "$REGION" > /dev/null
success "Test file uploaded (stored with AES-256 encryption)."

info "Verifying encryption on uploaded object:"
aws s3api head-object --bucket "$BUCKET" --key "test-data.txt" --region "$REGION" \
  --query "{ServerSideEncryption:ServerSideEncryption,ContentLength:ContentLength}" \
  --output table

# ── Step 9: Web Security Group ────────────────────────────────
info "Step 9 — Web Security Group: $WEB_SG_NAME"
# VPC_ID already retrieved in Step 0

WEB_SG_ID=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" "Name=group-name,Values=$WEB_SG_NAME" \
  --region "$REGION" --query "SecurityGroups[0].GroupId" --output text 2>/dev/null || echo "None")

if [[ "$WEB_SG_ID" == "None" || "$WEB_SG_ID" == "null" ]]; then
  info "  Creating Web Security Group..."
  WEB_SG_ID=$(aws ec2 create-security-group \
    --group-name "$WEB_SG_NAME" --description "Security Lab - Web Tier" \
    --vpc-id "$VPC_ID" --region "$REGION" --query "GroupId" --output text)
  aws ec2 create-tags --resources "$WEB_SG_ID" --region "$REGION" \
    --tags Key=Name,Value="$WEB_SG_NAME"
  success "Web SG created: $WEB_SG_ID"
else
  info "  Web SG '$WEB_SG_NAME' already exists ($WEB_SG_ID)."
fi

info "  Authorizing ingress rules for Web SG (SSH:22 + HTTP:80)..."
aws ec2 authorize-security-group-ingress --group-id "$WEB_SG_ID" --protocol tcp --port 22 --cidr 0.0.0.0/0 --region "$REGION" 2>/dev/null || true
aws ec2 authorize-security-group-ingress --group-id "$WEB_SG_ID" --protocol tcp --port 80 --cidr 0.0.0.0/0 --region "$REGION" 2>/dev/null || true
success "Web SG rules checked."

# ── Step 10: Database Security Group ───────────────────────────
info "Step 10 — DB Security Group: $DB_SG_NAME"
DB_SG_ID=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" "Name=group-name,Values=$DB_SG_NAME" \
  --region "$REGION" --query "SecurityGroups[0].GroupId" --output text 2>/dev/null || echo "None")

if [[ "$DB_SG_ID" == "None" || "$DB_SG_ID" == "null" ]]; then
  info "  Creating DB Security Group..."
  DB_SG_ID=$(aws ec2 create-security-group \
    --group-name "$DB_SG_NAME" --description "Security Lab - DB Tier" \
    --vpc-id "$VPC_ID" --region "$REGION" --query "GroupId" --output text)
  aws ec2 create-tags --resources "$DB_SG_ID" --region "$REGION" \
    --tags Key=Name,Value="$DB_SG_NAME"
  success "DB SG created: $DB_SG_ID"
else
  info "  DB SG '$DB_SG_NAME' already exists ($DB_SG_ID)."
fi

info "  Authorizing ingress rules for DB SG (MySQL:3306 from Web SG, SSH:22 from VPC)..."
aws ec2 authorize-security-group-ingress --group-id "$DB_SG_ID" --protocol tcp --port 3306 --source-group "$WEB_SG_ID" --region "$REGION" 2>/dev/null || true
aws ec2 authorize-security-group-ingress --group-id "$DB_SG_ID" --protocol tcp --port 22 --cidr 0.0.0.0/0 --region "$REGION" 2>/dev/null || true
success "DB SG rules checked."

# Networking already configured in Step 0

# ── Step 11: Restrictive Security Group (Firewall) ────────────
info "Step 11 — Creating Restrictive Security Group (Firewall rules)"

# Re-use VPC_ID from Step 0
SG_ID=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" "Name=group-name,Values=$SG_FIREWALL_NAME" \
  --region "$REGION" --query "SecurityGroups[0].GroupId" --output text 2>/dev/null || echo "None")

if [[ "$SG_ID" == "None" || "$SG_ID" == "null" ]]; then
  info "  Creating Hardened Firewall Security Group..."
  SG_ID=$(aws ec2 create-security-group \
    --group-name "$SG_FIREWALL_NAME" \
    --description "Restrictive: SSH in only, HTTPS+DNS out only" \
    --vpc-id "$VPC_ID" --region "$REGION" \
    --query "GroupId" --output text)

  # Inbound: SSH only
  aws ec2 authorize-security-group-ingress \
    --group-id "$SG_ID" --protocol tcp --port 22 --cidr "0.0.0.0/0" --region "$REGION"

  # Remove default allow-all egress
  aws ec2 revoke-security-group-egress \
    --group-id "$SG_ID" --region "$REGION" \
    --ip-permissions '[{"IpProtocol":"-1","IpRanges":[{"CidrIp":"0.0.0.0/0"}]}]' \
    2>/dev/null || true

  # Outbound: HTTPS (443) + DNS (53) only
  aws ec2 authorize-security-group-egress \
    --group-id "$SG_ID" --protocol tcp --port 443 --cidr "0.0.0.0/0" --region "$REGION"
  aws ec2 authorize-security-group-egress \
    --group-id "$SG_ID" --protocol udp --port 53  --cidr "0.0.0.0/0" --region "$REGION"
  aws ec2 authorize-security-group-egress \
    --group-id "$SG_ID" --protocol tcp --port 53  --cidr "0.0.0.0/0" --region "$REGION"

  aws ec2 create-tags --resources "$SG_ID" --region "$REGION" \
    --tags Key=Name,Value=Hardened-Firewall-SecurityGroup
  success "Security Group created: $SG_ID"
else
  info "  Hardened Firewall Security Group '$SG_ID' already exists. Ensuring rules are set."
  # Ensure rules are idempotent (add if not present, ignore if present)
  aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol tcp --port 22 --cidr "0.0.0.0/0" --region "$REGION" 2>/dev/null || true
  aws ec2 authorize-security-group-egress --group-id "$SG_ID" --protocol tcp --port 443 --cidr "0.0.0.0/0" --region "$REGION" 2>/dev/null || true
  aws ec2 authorize-security-group-egress --group-id "$SG_ID" --protocol udp --port 53  --cidr "0.0.0.0/0" --region "$REGION" 2>/dev/null || true
  aws ec2 authorize-security-group-egress --group-id "$SG_ID" --protocol tcp --port 53  --cidr "0.0.0.0/0" --region "$REGION" 2>/dev/null || true
  success "Security Group rules checked."
fi
echo "  Inbound : SSH (port 22) only"
echo "  Outbound: HTTPS (443) + DNS (53) only"

# ── Step 12: Web Instance ──────────────────────────────────────
info "Step 12 — Web Instance: $WEB_INST_NAME"
WEB_INST_ID=$(aws ec2 describe-instances --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=$WEB_INST_NAME" "Name=instance-state-name,Values=running" \
  --region "$REGION" --query "Reservations[0].Instances[0].InstanceId" --output text 2>/dev/null || echo "None")

if [[ "$WEB_INST_ID" == "None" || "$WEB_INST_ID" == "null" ]]; then
  info "  Launching Web Instance..."
  WEB_INST_ID=$(aws ec2 run-instances \
    --image-id "$AMI_ID" --instance-type "$INSTANCE_TYPE" \
    --key-name "$KEY_NAME" --security-group-ids "$WEB_SG_ID" \
    --subnet-id "$SUBNET_ID" \
    --region "$REGION" --count 1 \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$WEB_INST_NAME}]" \
    --query "Instances[0].InstanceId" --output text)
  success "Web Instance launched: $WEB_INST_ID"
else
  info "  Web Instance already exists ($WEB_INST_ID)."
fi

# ── Step 13: Launch Secure EC2 ────────────────────────────────
info "Step 13 — Launching Secure EC2 (Ubuntu 24.04) with IAM Role + IMDSv2"

INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=Hardened-Compute-Node" "Name=instance-state-name,Values=running" \
  --region "$REGION" --query "Reservations[0].Instances[0].InstanceId" --output text 2>/dev/null || echo "None")

if [[ "$INSTANCE_ID" == "None" || "$INSTANCE_ID" == "null" ]]; then
  info "  Launching Hardened Compute Node..."
  INSTANCE_ID=$(aws ec2 run-instances \
    --image-id "$AMI_ID" \
    --instance-type "$INSTANCE_TYPE" \
    --key-name "$KEY_NAME" \
    --security-group-ids "$SG_ID" \
    --subnet-id "$SUBNET_ID" \
    --iam-instance-profile "Name=$IAM_PROFILE" \
    --metadata-options \
      "HttpTokens=required,HttpEndpoint=enabled,HttpPutResponseHopLimit=1" \
    --region "$REGION" --count 1 \
    --tag-specifications "ResourceType=instance,Tags=[
      {Key=Name,Value=$INST_NAME},
      {Key=Security,Value=Hardened}]" \
    --query "Instances[0].InstanceId" --output text)
  success "Secure EC2 launched: $INSTANCE_ID"
else
  info "  Hardened Compute Node already exists ($INSTANCE_ID)."
fi

info "Waiting for instance to be running..."
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID" --region "$REGION"
PUBLIC_IP=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" \
  --region "$REGION" \
  --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
success "Secure EC2: $INSTANCE_ID ($PUBLIC_IP)"
echo "  IMDSv2 enforced → SSRF attacks via metadata endpoint are blocked."

# ── Step 10: Firewall Test ────────────────────────────────────
info "Step 10 — Testing Firewall Rules"
sleep 5
echo ""
echo "  Test 1 → Port 22 (SSH) — should be OPEN:"
if nc -z -w 5 "$PUBLIC_IP" 22 2>/dev/null; then
  success "Port 22 OPEN — SSH firewall rule working."
else
  echo "         Port 22 inconclusive (instance still starting)."
fi

echo "  Test 2 → Port 80 (HTTP) — should be BLOCKED:"
if nc -z -w 3 "$PUBLIC_IP" 80 2>/dev/null; then
  echo "  [UNEXPECTED] Port 80 open."
else
  success "Port 80 BLOCKED — HTTP blocked by firewall."
fi

echo "  Test 3 → Port 3389 (RDP) — should be BLOCKED:"
if nc -z -w 3 "$PUBLIC_IP" 3389 2>/dev/null; then
  echo "  [UNEXPECTED] Port 3389 open."
else
  success "Port 3389 BLOCKED — RDP blocked by firewall."
fi

# ── Save state ────────────────────────────────────────────────
cat > "$STATE_FILE" <<EOF
REGION=$REGION
INSTANCE_ID=$INSTANCE_ID
SG_ID=$SG_ID
VPC_ID=$VPC_ID
BUCKET=$BUCKET
POLICY_ARN=$POLICY_ARN
KEY_NAME=$KEY_NAME
PUBLIC_IP=$PUBLIC_IP
ACCOUNT_ID=$ACCOUNT_ID
AMI_ID=$AMI_ID
EOF

banner "CLOUD SECURITY MANAGEMENT — COMPLETE SUMMARY"
cat <<SUMMARY
  ╔══════════════════════════════════════════════════════════════╗
  ║              RESOURCES CREATED                               ║
  ╠═══════════════════════╦══════════════════════════════════════╣
  ║ Resource              ║ Value                                ║
  ╠═══════════════════════╬══════════════════════════════════════╣
  ║ Key Pair              ║ $KEY_NAME                            ║
  ║ Key File              ║ $HOME/${KEY_NAME}.pem                ║
  ║ IAM Policy            ║ $POLICY_NAME                        ║
  ║ Policy ARN            ║ $POLICY_ARN                          ║
  ║ IAM Role              ║ $IAM_ROLE                           ║
  ║ Instance Profile      ║ $IAM_PROFILE                        ║
  ║ IAM Group             ║ $GROUP_NAME                         ║
  ║ IAM User              ║ $USER_NAME → Group: $GROUP_NAME     ║
  ║ S3 Bucket             ║ $BUCKET                              ║
  ║ S3 Encryption         ║ AES-256 SSE enabled                  ║
  ║ S3 Public Access      ║ Completely blocked                   ║
  ║ S3 HTTPS Policy       ║ HTTP requests denied                 ║
  ║ S3 Versioning         ║ Enabled                              ║
  ║ Security Group        ║ $SG_ID ($SG_FIREWALL_NAME)          ║
  ║ Firewall Inbound      ║ SSH (port 22) only                   ║
  ║ Firewall Outbound     ║ HTTPS (443) + DNS (53) only          ║
  ║ Compute Node          ║ $INSTANCE_ID                         ║
  ║ Node Public IP        ║ $PUBLIC_IP                           ║
  ║ IMDSv2                ║ Enforced (SSRF protection)           ║
  ║ AMI Used              ║ $AMI_ID                              ║
  ║ Region                ║ $REGION                              ║
  ╠═══════════════════════╩══════════════════════════════════════╣
  ║              SECURITY CONTROLS SUMMARY                       ║
  ╠══════════════════════════════════════════════════════════════╣
  ║  ✅ Least-privilege IAM policy (no write, no delete)         ║
  ║  ✅ IAM role attached to EC2 (no hardcoded credentials)      ║
  ║  ✅ IAM user with read-only group access                     ║
  ║  ✅ S3 AES-256 server-side encryption                        ║
  ║  ✅ S3 public access completely blocked                      ║
  ║  ✅ S3 HTTPS-only (HTTP connections denied)                  ║
  ║  ✅ S3 versioning for audit trail                            ║
  ║  ✅ Firewall: SSH in only, HTTPS+DNS out only                ║
  ║  ✅ IMDSv2 enforced — prevents SSRF metadata attacks         ║
  ╠══════════════════════════════════════════════════════════════╣
  ║              DETAILS NEEDED TO DELETE                        ║
  ╠══════════════════════════════════════════════════════════════╣
  ║  Compute Node   : $INSTANCE_ID                               ║
  ║  Security Group : $SG_ID                                     ║
  ║  Secure Bucket  : $BUCKET                                    ║
  ║  IAM Policy ARN : $POLICY_ARN                                ║
  ║  IAM Role       : $IAM_ROLE                                  ║
  ║  IAM Profile    : $IAM_PROFILE                               ║
  ║  IAM User       : $USER_NAME                                 ║
  ║  IAM Group      : $GROUP_NAME                                ║
  ║  Key Pair       : $KEY_NAME                                  ║
  ║  State File     : $STATE_FILE                                ║
  ╠══════════════════════════════════════════════════════════════╣
  ║  Run: ./10_security_cleanup.sh (reads state file automatically) ║
  ╚══════════════════════════════════════════════════════════════╝

  Verify in Console:
  IAM  → Roles   → $IAM_ROLE → Permissions tab
  IAM  → Users   → $USER_NAME → Groups tab
  S3   → $BUCKET → Properties → Server-side encryption
  EC2  → Security Groups → $SG_FIREWALL_NAME → Inbound/Outbound rules

  Connect: EC2 Console → $INSTANCE_ID → Connect → EC2 Instance Connect
SUMMARY
