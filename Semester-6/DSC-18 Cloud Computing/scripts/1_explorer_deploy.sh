#!/usr/bin/env bash
# ================================================================
#  AWS CLOUD EXPLORER — DEPLOY
#  Explore AWS Services
#
#  AMI    : Ubuntu Server 24.04 LTS  ami-05d2d839d4f73aafb
#  REGION : ap-south-1
#  RUN    : chmod +x 1_explorer_deploy.sh && ./1_explorer_deploy.sh
#  DELETE : ./1_explorer_cleanup.sh
# ================================================================
set -euo pipefail

REGION="ap-south-1"
AMI_ID=$(aws ec2 describe-images --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" \
  --region "$REGION" --query "sort_by(Images, &CreationDate)[-1].ImageId" --output text)

G='\033[0;32m'; B='\033[0;34m'; Y='\033[1;33m'; NC='\033[0m'
info()    { echo -e "${B}[INFO]${NC}  $*"; }
success() { echo -e "${G}[OK]${NC}    $*"; }
banner()  { echo -e "\n${Y}══════════════════════════════════════════${NC}"; \
            echo -e "${Y}  $*${NC}"; \
            echo -e "${Y}══════════════════════════════════════════${NC}\n"; }

banner "AWS CLOUD EXPLORER — Exploration"

info "Step 1 — Verifying AWS Identity"
aws sts get-caller-identity --output table

info "Step 2 — Available AWS Regions"
aws ec2 describe-regions \
  --query "sort_by(Regions,&RegionName)[].{Region:RegionName,Status:OptInStatus}" \
  --output table

info "Step 3 — Common EC2 Instance Types"
aws ec2 describe-instance-types \
  --filters "Name=instance-type,Values=m7i-flex.large,t3.micro,t3.small,t3.medium" \
  --query "InstanceTypes[].{Type:InstanceType,vCPU:VCpuInfo.DefaultVCpus,RAM_MiB:MemoryInfo.SizeInMiB}" \
  --output table

info "Step 4 — Existing S3 Buckets"
aws s3 ls 2>/dev/null || echo "  No buckets found."

info "Step 5 — Existing VPCs"
aws ec2 describe-vpcs \
  --query "Vpcs[].{VpcId:VpcId,CIDR:CidrBlock,Default:IsDefault,State:State}" \
  --output table

info "Step 6 — Availability Zones in $REGION"
aws ec2 describe-availability-zones \
  --query "AvailabilityZones[?State=='available'].{AZ:ZoneName,State:State}" \
  --output table

info "Step 7 — IAM Summary"
echo "  Users:  $(aws iam list-users  --query 'length(Users)'  --output text)"
echo "  Groups: $(aws iam list-groups --query 'length(Groups)' --output text)"
echo "  Roles:  $(aws iam list-roles  --query 'length(Roles)'  --output text)"

info "Step 8 — Latest Ubuntu AMI Details"
aws ec2 describe-images --image-ids "$AMI_ID" --region "$REGION" \
  --query "Images[0].{AMI_ID:ImageId,Name:Name,State:State,Arch:Architecture,Owner:OwnerId}" \
  --output table

cat <<'EOF'

  ┌──────────────────────────────────────────────────────────────┐
  │                    AWS KEY SERVICES                          │
  ├──────────────────┬───────────────────────────────────────────┤
  │ Compute          │ EC2, Lambda, ECS, EKS, Batch              │
  │ Storage          │ S3, EBS, EFS, Glacier                     │
  │ Networking       │ VPC, Route 53, CloudFront, ELB            │
  │ Database         │ RDS, DynamoDB, ElastiCache, Redshift      │
  │ Security         │ IAM, KMS, Shield, WAF, Cognito            │
  │ Monitoring       │ CloudWatch, CloudTrail, Config            │
  └──────────────────┴───────────────────────────────────────────┘

  Pricing: https://calculator.aws/pricing/2/home
EOF

banner "CLOUD EXPLORER — COMPLETE SUMMARY"
cat <<SUMMARY
  ╔══════════════════════════════════════════════════════════════╗
  ║              RESOURCES DELETED (for cleanup reference)       ║
  ╠══════════════════════════════════════════════════════════════╣
  ║  NONE — This script only reads/explores existing AWS info.   ║
  ╠══════════════════════════════════════════════════════════════╣
  ║              DETAILS NEEDED TO CLEANUP                       ║
  ╠══════════════════════════════════════════════════════════════╣
  ║NONE — Run 1_explorer_cleanup.sh (confirms nothing to delete).║
  ╚══════════════════════════════════════════════════════════════╝
SUMMARY
