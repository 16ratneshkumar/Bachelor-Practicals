#!/usr/bin/env bash
# ================================================================
#  SCALABLE WEB CLUSTER — DEPLOY
#  Configure Auto Scaling Group + Application Load Balancer
#
#  AMI    : Latest Ubuntu Server LTS
#  TYPE   : t3.micro (Free Tier eligible)
#  USER   : ubuntu
#  RUN    : chmod +x 4_scaling_deploy.sh && ./4_scaling_deploy.sh
#  DELETE : ./4_scaling_cleanup.sh
#  STATE  : $HOME/aws_state_scaling.txt
# ================================================================
set -euo pipefail

REGION="ap-south-1"
AMI_ID=$(aws ec2 describe-images --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*" \
  --region "$REGION" --query "sort_by(Images, &CreationDate)[-1].ImageId" --output text)
INSTANCE_TYPE="t3.micro"
KEY_NAME="Practical-KeyPair"
STATE_FILE="$HOME/aws_state_scaling.txt"

# Resource Names
SG_NAME="Practical-Web-SG"
LT_NAME="Practical-Web-LT"
TG_NAME="Practical-Web-TG"
ALB_NAME="Practical-Web-ALB"
ASG_NAME="Practical-Web-ASG"

G='\033[0;32m'; B='\033[0;34m'; Y='\033[1;33m'; NC='\033[0m'
info()    { echo -e "${B}[INFO]${NC}  $*"; }
success() { echo -e "${G}[OK]${NC}    $*"; }
banner()  { echo -e "\n${Y}══════════════════════════════════════════${NC}"; \
            echo -e "${Y}  $*${NC}"; \
            echo -e "${Y}══════════════════════════════════════════${NC}\n"; }

banner "SCALABLE WEB CLUSTER — ASG + ALB"
echo "  AMI: $AMI_ID (Ubuntu 24.04 LTS) | Type: $INSTANCE_TYPE | Region: $REGION"

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
info "Step 2 — Networking: VPC & Dual-AZ Subnets (Required for ALB)"
# Try to find Practical-VPC first, fallback to Default
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=Practical-VPC" --query "Vpcs[0].VpcId" --output text --region "$REGION" 2>/dev/null || echo "None")
if [[ "$VPC_ID" == "None" || "$VPC_ID" == "null" ]]; then
  VPC_ID=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --region "$REGION" --query "Vpcs[0].VpcId" --output text 2>/dev/null || echo "None")
fi

if [[ "$VPC_ID" == "None" || "$VPC_ID" == "null" ]]; then
  info "  No suitable VPC found. Creating a dedicated 'Practical-Scaling-VPC'..."
  VPC_ID=$(aws ec2 create-vpc --cidr-block "10.40.0.0/16" --region "$REGION" --query "Vpc.VpcId" --output text)
  aws ec2 create-tags --resources "$VPC_ID" --region "$REGION" --tags Key=Name,Value="Practical-Scaling-VPC"
  aws ec2 modify-vpc-attribute --vpc-id "$VPC_ID" --enable-dns-hostnames --region "$REGION"
  aws ec2 modify-vpc-attribute --vpc-id "$VPC_ID" --enable-dns-support --region "$REGION"
  # IGW for public access
  IGW_ID=$(aws ec2 create-internet-gateway --region "$REGION" --query "InternetGateway.InternetGatewayId" --output text)
  aws ec2 attach-internet-gateway --internet-gateway-id "$IGW_ID" --vpc-id "$VPC_ID" --region "$REGION"
  # Route Table
  RT_ID=$(aws ec2 create-route-table --vpc-id "$VPC_ID" --region "$REGION" --query "RouteTable.RouteTableId" --output text)
  aws ec2 create-route --route-table-id "$RT_ID" --destination-cidr-block "0.0.0.0/0" --gateway-id "$IGW_ID" --region "$REGION" > /dev/null
fi

# Multi-AZ Subnets setup
AZS=$(aws ec2 describe-availability-zones --region "$REGION" --query "AvailabilityZones[0:2].ZoneName" --output text)
AZ1=$(echo "$AZS" | awk '{print $1}')
AZ2=$(echo "$AZS" | awk '{print $2}')

SUBNET_1=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" "Name=availability-zone,Values=$AZ1" --region "$REGION" --query "Subnets[0].SubnetId" --output text 2>/dev/null || echo "None")
if [[ "$SUBNET_1" == "None" || "$SUBNET_1" == "null" ]]; then
  info "  Creating subnet in $AZ1..."
  SUBNET_1=$(aws ec2 create-subnet --vpc-id "$VPC_ID" --cidr-block "10.40.1.0/24" --availability-zone "$AZ1" --region "$REGION" --query "Subnet.SubnetId" --output text 2>/dev/null || \
             aws ec2 create-default-subnet --availability-zone "$AZ1" --region "$REGION" --query "Subnet.SubnetId" --output text)
fi

SUBNET_2=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" "Name=availability-zone,Values=$AZ2" --region "$REGION" --query "Subnets[0].SubnetId" --output text 2>/dev/null || echo "None")
if [[ "$SUBNET_2" == "None" || "$SUBNET_2" == "null" ]]; then
  info "  Creating subnet in $AZ2..."
  SUBNET_2=$(aws ec2 create-subnet --vpc-id "$VPC_ID" --cidr-block "10.40.2.0/24" --availability-zone "$AZ2" --region "$REGION" --query "Subnet.SubnetId" --output text 2>/dev/null || \
             aws ec2 create-default-subnet --availability-zone "$AZ2" --region "$REGION" --query "Subnet.SubnetId" --output text)
fi

SUBNETS_CSV="$SUBNET_1,$SUBNET_2"
success "VPC: $VPC_ID | Subnets: $SUBNETS_CSV ($AZ1, $AZ2)"

# ── Step 3: Security Group ────────────────────────────────────
info "Step 3 — Security Group: $SG_NAME"
SG_ID=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=$SG_NAME" --region "$REGION" \
  --query "SecurityGroups[0].GroupId" --output text 2>/dev/null || echo "None")

if [[ "$SG_ID" == "None" || "$SG_ID" == "null" ]]; then
  info "  Creating Security Group..."
  SG_ID=$(aws ec2 create-security-group \
    --group-name "$SG_NAME" \
    --description "Web Security Group" \
    --vpc-id "$VPC_ID" \
    --region "$REGION" \
    --query "GroupId" --output text)
  aws ec2 create-tags --resources "$SG_ID" --region "$REGION" \
    --tags Key=Name,Value="$SG_NAME"
  success "Security Group created: $SG_ID"
else
  info "  Security Group already exists ($SG_ID)."
fi

info "  Adding inbound rules (80, 22)..."
aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol tcp --port 80 --cidr 0.0.0.0/0 --region "$REGION" 2>/dev/null || true
aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol tcp --port 22 --cidr 0.0.0.0/0 --region "$REGION" 2>/dev/null || true
success "Security Group rules checked."

# ── Step 4: Launch Template ──────────────────────────────────
info "Step 4 — Launch Template: $LT_NAME"
USER_DATA=$(base64 -w 0 <<'SCRIPT'
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y apache2
systemctl start apache2
systemctl enable apache2

# Wait for Metadata Service (IMDSv2)
TOKEN="None"
until [[ "$TOKEN" != "None" && -n "$TOKEN" ]]; do
  TOKEN=$(curl -s -f -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
  sleep 2
done

INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)

cat > /var/www/html/index.html <<HTML
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CloudStack | High-Availability Cluster</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600&display=swap" rel="stylesheet">
    <style>
        :root { --primary: #0061ff; --secondary: #60efff; --dark: #0f172a; }
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family: 'Outfit', sans-serif; background: #f8fafc; color: var(--dark); line-height: 1.6; }
        .hero { background: linear-gradient(135deg, var(--dark) 0%, #1e293b 100%); color: white; padding: 100px 20px; text-align: center; position: relative; overflow: hidden; }
        .hero::after { content: ''; position: absolute; top:0; left:0; right:0; bottom:0; background: url('https://www.transparenttextures.com/patterns/cubes.png'); opacity: 0.1; }
        .container { max-width: 1200px; margin: 0 auto; position: relative; z-index: 1; }
        h1 { font-size: 3.5rem; font-weight: 600; margin-bottom: 20px; letter-spacing: -1px; background: linear-gradient(to right, #60efff, #0061ff); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .tagline { font-size: 1.25rem; color: #94a3b8; max-width: 700px; margin: 0 auto 40px; }
        .status-pill { display: inline-flex; align-items: center; background: rgba(16, 185, 129, 0.1); border: 1px solid #10b981; color: #10b981; padding: 6px 16px; border-radius: 999px; font-weight: 600; font-size: 0.875rem; margin-bottom: 20px; }
        .status-dot { width: 8px; height: 8px; background: #10b981; border-radius: 50%; margin-right: 8px; animation: pulse 2s infinite; }
        @keyframes pulse { 0% { opacity: 1; transform: scale(1); } 50% { opacity: 0.5; transform: scale(1.2); } 100% { opacity: 1; transform: scale(1); } }
        .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 30px; margin-top: -60px; padding: 0 20px; }
        .card { background: white; padding: 40px; border-radius: 20px; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1); border: 1px solid #e2e8f0; transition: transform 0.3s ease; }
        .card:hover { transform: translateY(-10px); }
        .meta-label { font-size: 0.75rem; text-transform: uppercase; color: #64748b; font-weight: 600; margin-bottom: 8px; display: block; }
        .meta-value { font-size: 1.125rem; font-weight: 600; color: var(--dark); font-family: monospace; word-break: break-all; }
        .features { padding: 100px 20px; text-align: center; }
        .feature-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 40px; margin-top: 50px; }
        .feat h3 { margin-bottom: 10px; color: var(--primary); }
        footer { background: var(--dark); color: #64748b; padding: 40px 20px; text-align: center; font-size: 0.875rem; }
    </style>
</head>
<body>
    <section class="hero">
        <div class="container">
            <div class="status-pill">
                <span class="status-dot"></span> Cluster Operational
            </div>
            <h1>CloudStack High-Availability</h1>
            <p class="tagline">Enterprise-grade infrastructure automatically scaling to meet global demand. This request was served by a node in our distributed edge network.</p>
        </div>
    </section>

    <div class="container">
        <div class="grid">
            <div class="card">
                <span class="meta-label">Node Identifier</span>
                <span class="meta-value">$INSTANCE_ID</span>
                <p style="margin-top:20px; font-size:0.875rem; color:#64748b;">The unique ID of the virtual machine currently processing your request.</p>
            </div>
            <div class="card">
                <span class="meta-label">Availability Zone</span>
                <span class="meta-value">$AZ</span>
                <p style="margin-top:20px; font-size:0.875rem; color:#64748b;">The physical isolated partition within our regional data center.</p>
            </div>
        </div>
    </div>

    <section class="features container">
        <h2>Infrastructure Architecture</h2>
        <div class="feature-grid">
            <div class="feat">
                <h3>Auto Scaling</h3>
                <p>Dynamically provisions capacity based on real-time traffic spikes.</p>
            </div>
            <div class="feat">
                <h3>Load Balancing</h3>
                <p>Intelligent distribution across multi-AZ fault-tolerant zones.</p>
            </div>
            <div class="feat">
                <h3>Self-Healing</h3>
                <p>Automatic replacement of unhealthy nodes to maintain 99.99% uptime.</p>
            </div>
        </div>
    </section>

    <footer>
        &copy; 2026 CloudStack Pro. Powered by Amazon Web Services.
    </footer>
</body>
</html>
HTML
SCRIPT
)
USER_DATA_B64="$USER_DATA" # Renaming for clarity as per snippet, though it's already base64

LT_ID=$(aws ec2 describe-launch-templates --launch-template-names "$LT_NAME" --region "$REGION" \
  --query "LaunchTemplates[0].LaunchTemplateId" --output text 2>/dev/null || echo "NOT_FOUND")

if [[ "$LT_ID" == "NOT_FOUND" ]]; then
  info "  Creating Launch Template..."
  LT_ID=$(aws ec2 create-launch-template \
    --launch-template-name "$LT_NAME" \
    --version-description "v1" \
    --region "$REGION" \
    --launch-template-data "{
      \"NetworkInterfaces\": [{\"AssociatePublicIpAddress\": true, \"DeviceIndex\": 0, \"Groups\": [\"$SG_ID\"]}],
      \"ImageId\": \"$AMI_ID\",
      \"InstanceType\": \"$INSTANCE_TYPE\",
      \"KeyName\": \"$KEY_NAME\",
      \"UserData\": \"$USER_DATA_B64\",
      \"TagSpecifications\":[{
        \"ResourceType\":\"instance\",
        \"Tags\":[{\"Key\":\"Name\",\"Value\":\"Practical-Web-Instance\"}]
      }]}" \
    --query "LaunchTemplate.LaunchTemplateId" --output text)
  success "Launch Template created: $LT_ID ($LT_NAME)"
else
  info "  Launch Template already exists. Creating a new version with latest UserData..."
  aws ec2 create-launch-template-version \
    --launch-template-id "$LT_ID" \
    --version-description "Updated via script" \
    --region "$REGION" \
    --launch-template-data "{
      \"ImageId\": \"$AMI_ID\",
      \"InstanceType\": \"$INSTANCE_TYPE\",
      \"UserData\": \"$USER_DATA_B64\"
    }" > /dev/null
  success "Launch Template $LT_NAME updated to latest version."
fi

# ── Step 5: Target Group ──────────────────────────────────────
info "Step 5 — Target Group: $TG_NAME"
TG_ARN=$(aws elbv2 describe-target-groups --names "$TG_NAME" --region "$REGION" \
  --query "TargetGroups[0].TargetGroupArn" --output text 2>/dev/null || echo "None")

if [[ "$TG_ARN" == "None" || "$TG_ARN" == "null" ]]; then
  info "  Creating Target Group..."
  TG_ARN=$(aws elbv2 create-target-group \
    --name "$TG_NAME" \
    --protocol HTTP \
    --port 80 \
    --vpc-id "$VPC_ID" \
    --health-check-path "/" \
    --health-check-interval-seconds 30 \
    --healthy-threshold-count 2 \
    --unhealthy-threshold-count 3 \
    --target-type instance \
    --region "$REGION" \
    --query "TargetGroups[0].TargetGroupArn" --output text)
  success "Target Group created: $TG_ARN"
else
  info "  Target Group already exists ($TG_ARN). Using it."
fi

# ── Step 6: Application Load Balancer ─────────────────────────
info "Step 6 — Load Balancer: $ALB_NAME"
ALB_ARN=$(aws elbv2 describe-load-balancers --names "$ALB_NAME" --region "$REGION" \
  --query "LoadBalancers[0].LoadBalancerArn" --output text 2>/dev/null || echo "None")

if [[ "$ALB_ARN" == "None" || "$ALB_ARN" == "null" ]]; then
  info "  Creating ALB (External)..."
  ALB_ARN=$(aws elbv2 create-load-balancer \
    --name "$ALB_NAME" \
    --subnets "$SUBNET_1" "$SUBNET_2" \
    --security-groups "$SG_ID" \
    --scheme internet-facing \
    --type application \
    --region "$REGION" \
    --query "LoadBalancers[0].LoadBalancerArn" --output text)
  success "ALB created: $ALB_ARN"
else
  info "  ALB already exists ($ALB_ARN). Using it."
fi

ALB_DNS=$(aws elbv2 describe-load-balancers --load-balancer-arns "$ALB_ARN" --region "$REGION" \
  --query "LoadBalancers[0].DNSName" --output text)

info "  Setting up HTTP Listener..."
LISTENER_ARN=$(aws elbv2 describe-listeners --load-balancer-arn "$ALB_ARN" --region "$REGION" \
  --query "Listeners[?Port==\`80\`].ListenerArn" --output text 2>/dev/null || echo "None")

if [[ "$LISTENER_ARN" == "None" || "$LISTENER_ARN" == "null" || -z "$LISTENER_ARN" ]]; then
  info "  Creating HTTP Listener..."
  LISTENER_ARN=$(aws elbv2 create-listener \
    --load-balancer-arn "$ALB_ARN" \
    --protocol HTTP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn="$TG_ARN" \
    --region "$REGION" --query "Listeners[0].ListenerArn" --output text)
else
  info "  HTTP Listener already exists ($LISTENER_ARN). Using it."
fi
success "ALB Listener configured: $LISTENER_ARN"

# ── Step 7: Auto Scaling Group ───────────────────────────────
ASG_LENGTH=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "$ASG_NAME" --region "$REGION" \
  --query "length(AutoScalingGroups)" --output text 2>/dev/null || echo "0")

if [[ "$ASG_LENGTH" == "0" ]]; then
  info "  Creating ASG (min=1, desired=2, max=4)..."
  aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name "$ASG_NAME" \
    --launch-template "LaunchTemplateId=$LT_ID,Version=\$Latest" \
    --min-size 1 --max-size 4 --desired-capacity 2 \
    --target-group-arns "$TG_ARN" \
    --vpc-zone-identifier "$SUBNETS_CSV" \
    --health-check-type ELB \
    --health-check-grace-period 300 \
    --region "$REGION" \
    --tags "Key=Name,Value=Practical-Web-Instance,PropagateAtLaunch=true"
  success "Auto Scaling Group '$ASG_NAME' created."
else
  info "  ASG already exists. Updating to use \$Latest Launch Template and 300s grace period..."
  aws autoscaling update-auto-scaling-group \
    --auto-scaling-group-name "$ASG_NAME" \
    --launch-template "LaunchTemplateId=$LT_ID,Version=\$Latest" \
    --health-check-grace-period 300 \
    --region "$REGION"
  success "Auto Scaling Group '$ASG_NAME' updated."
fi

# ── Step 8: Scaling Policy ───────────────────────────────────
info "Step 8 — Scaling Policy: CPU-Utilization-70"
aws autoscaling put-scaling-policy \
  --auto-scaling-group-name "$ASG_NAME" \
  --policy-name "ScalingPolicy-CPU" \
  --policy-type TargetTrackingScaling \
  --region "$REGION" \
  --target-tracking-configuration '{
    "PredefinedMetricSpecification":{"PredefinedMetricType":"ASGAverageCPUUtilization"},
    "TargetValue":70.0}' > /dev/null 2>&1 || true
success "CPU Scaling Policy created (target: 70% CPU)."

# ── Save State ────────────────────────────────────────────────
cat > "$STATE_FILE" <<EOF
REGION=$REGION
VPC_ID=$VPC_ID
SG_ID=$SG_ID
LT_ID=$LT_ID
TG_ARN=$TG_ARN
ALB_ARN=$ALB_ARN
LISTENER_ARN=$LISTENER_ARN
KEY_NAME=$KEY_NAME
ALB_DNS=$ALB_DNS
AMI_ID=$AMI_ID
EOF

# ── Step 9: Finalizing ───────────────────────────────────────
info "Step 9 — Deployment submitted. Custom enterprise site will be live shortly."

banner "SCALABLE WEB CLUSTER — COMPLETE SUMMARY"
cat <<SUMMARY
  ╔══════════════════════════════════════════════════════════════╗
  ║              RESOURCES DEPLOYED                              ║
  ╠═══════════════════════╦══════════════════════════════════════╣
  ║ Resource              ║ Value                                ║
  ╠═══════════════════════╬══════════════════════════════════════╣
  ║ Security Group        ║ $SG_ID                               ║
  ║ Launch Template       ║ $LT_ID                               ║
  ║ Target Group          ║ $TG_NAME                             ║
  ║ Load Balancer (ALB)   ║ $ALB_NAME                            ║
  ║ ALB DNS               ║ $ALB_DNS                             ║
  ║ ALB Listener          ║ HTTP:80 → Target Group               ║
  ║ Auto Scaling Group    ║ $ASG_NAME                            ║
  ║ Scaling Policy        ║ CPU > 70% → scale out                ║
  ║ Key Pair              ║ $KEY_NAME                            ║
  ║ AMI Used              ║ $AMI_ID                              ║
  ║ Region                ║ $REGION                              ║
  ╠═══════════════════════╩══════════════════════════════════════╣
  ║              DETAILS NEEDED TO CLEANUP                       ║
  ╠══════════════════════════════════════════════════════════════╣
  ║  ASG Name   : $ASG_NAME                            ║
  ║  ALB Name   : $ALB_NAME                            ║
  ║  TG Name    : $TG_NAME                             ║
  ║  LT ID      : $LT_ID                                         ║
  ║  SG ID      : $SG_ID                                         ║
  ║  State File : $STATE_FILE                                    ║ 
  ╠══════════════════════════════════════════════════════════════╣
  ║  Run: ./4_scaling_cleanup.sh (reads state file automatically)  ║
  ╚══════════════════════════════════════════════════════════════╝

  Test website: http://$ALB_DNS
  (Wait 2-3 min for health checks to pass, then refresh browser)

  AWS Console (Instances in ap-south-1):
  https://ap-south-1.console.aws.amazon.com/ec2/home?region=ap-south-1#Instances:search=Practical-Web-Instance

  Stress test (trigger scale-out):
  EC2 → connect to any WebCluster instance → EC2 Instance Connect
  sudo apt update && sudo apt install -y stress && stress --cpu 2 --timeout 300
SUMMARY
