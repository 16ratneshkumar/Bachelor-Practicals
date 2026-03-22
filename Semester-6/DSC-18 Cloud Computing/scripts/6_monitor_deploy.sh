#!/usr/bin/env bash
# ================================================================
#  CLOUD MONITORING — DEPLOY
#  Monitor Resources Using AWS CloudWatch
#  Creates: EC2 + SNS Email + 3 Alarms + Dashboard
#
#  AMI    : Latest Ubuntu Server LTS
#  TYPE   : t3.micro (Free Tier eligible)
#  RUN    : chmod +x 6_monitor_deploy.sh && ./6_monitor_deploy.sh
#  DELETE : ./6_monitor_cleanup.sh
#  STATE  : $HOME/aws_state_monitor.txt
# ================================================================
set -euo pipefail

REGION="ap-south-1"
AMI_ID=$(aws ec2 describe-images --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*" \
  --region "$REGION" --query "sort_by(Images, &CreationDate)[-1].ImageId" --output text)
INSTANCE_TYPE="t3.micro"
KEY_NAME="Practical-KeyPair"
STATE_FILE="$HOME/aws_state_monitor.txt"
AVAILABILITY_ZONE=$(aws ec2 describe-availability-zones --region "$REGION" --query "AvailabilityZones[0].ZoneName" --output text)

# Resource Names
TOPIC_NAME="Practical-Monitoring-Alerts"
INST_NAME="Monitor-Target-Instance"
SG_NAME="Practical-Monitoring-SG"
DASHBOARD_NAME="Practical-Compute-Dashboard"

G='\033[0;32m'; B='\033[0;34m'; Y='\033[1;33m'; NC='\033[0m'
info()    { echo -e "${B}[INFO]${NC}  $*"; }
success() { echo -e "${G}[OK]${NC}    $*"; }
banner()  { echo -e "\n${Y}══════════════════════════════════════════${NC}"; \
            echo -e "${Y}  $*${NC}"; \
            echo -e "${Y}══════════════════════════════════════════${NC}\n"; }

banner "CLOUD MONITORING — CloudWatch Setup"

echo ""
read -rp "  Enter your email for CloudWatch alert notifications: " ALERT_EMAIL
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
  info "  No suitable VPC found. Creating 'Practical-Monitor-VPC'..."
  VPC_ID=$(aws ec2 create-vpc --cidr-block "10.60.0.0/16" --region "$REGION" --query "Vpc.VpcId" --output text)
  aws ec2 create-tags --resources "$VPC_ID" --region "$REGION" --tags Key=Name,Value="Practical-Monitor-VPC"
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
  SUBNET_ID=$(aws ec2 create-subnet --vpc-id "$VPC_ID" --cidr-block "10.60.1.0/24" --availability-zone "$AVAILABILITY_ZONE" --region "$REGION" --query "Subnet.SubnetId" --output text 2>/dev/null || \
           aws ec2 create-default-subnet --availability-zone "$AVAILABILITY_ZONE" --region "$REGION" --query "Subnet.SubnetId" --output text)
fi
success "VPC: $VPC_ID | Subnet: $SUBNET_ID"

# ── Step 2: Security Group ───────────────────────────────────
info "Step 2 — Security Group: $SG_NAME"
SG_ID=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" "Name=group-name,Values=$SG_NAME" \
  --region "$REGION" --query "SecurityGroups[0].GroupId" --output text 2>/dev/null || echo "None")

if [[ "$SG_ID" == "None" || "$SG_ID" == "null" ]]; then
  info "  Creating Security Group..."
  SG_ID=$(aws ec2 create-security-group \
    --group-name "$SG_NAME" --description "CloudWatch Monitoring Demo" \
    --vpc-id "$VPC_ID" --region "$REGION" --query "GroupId" --output text)
  aws ec2 create-tags --resources "$SG_ID" --region "$REGION" \
    --tags Key=Name,Value="$SG_NAME"
  success "Security Group created: $SG_ID"
else
  info "  Security Group already exists ($SG_ID)."
fi
aws ec2 authorize-security-group-ingress \
  --group-id "$SG_ID" --protocol tcp --port 22 --cidr "0.0.0.0/0" --region "$REGION" 2>/dev/null || true

# ── Step 3: EC2 Instance ──────────────────────────────────────
info "Step 3 — EC2 Instance: $INST_NAME"
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$INST_NAME" "Name=instance-state-name,Values=running" \
  --region "$REGION" --query "Reservations[0].Instances[0].InstanceId" --output text 2>/dev/null || echo "None")

if [[ "$INSTANCE_ID" == "None" || "$INSTANCE_ID" == "null" ]]; then
  info "  Launching EC2 Instance..."
  INSTANCE_ID=$(aws ec2 run-instances \
    --image-id "$AMI_ID" --instance-type "$INSTANCE_TYPE" \
    --key-name "$KEY_NAME" --security-group-ids "$SG_ID" \
    --subnet-id "$SUBNET_ID" \
    --monitoring "Enabled=true" --region "$REGION" --count 1 \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INST_NAME}]" \
    --query "Instances[0].InstanceId" --output text)
  aws ec2 wait instance-running --instance-ids "$INSTANCE_ID" --region "$REGION"
  success "Instance launched: $INSTANCE_ID"
else
  info "  Instance already exists ($INSTANCE_ID)."
fi

PUBLIC_IP=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" \
  --region "$REGION" \
  --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
success "EC2: $INSTANCE_ID  ($PUBLIC_IP) — detailed monitoring ON"

# ── Step 4: SNS Topic and Subscription ───────────────────────
info "Step 4 — SNS Topic: $TOPIC_NAME"
SNS_ARN=$(aws sns create-topic --name "$TOPIC_NAME" \
  --region "$REGION" --query "TopicArn" --output text)
success "SNS Topic checked/created: $SNS_ARN"

info "  SNS Subscription for: $ALERT_EMAIL"
aws sns subscribe --topic-arn "$SNS_ARN" \
  --protocol email --notification-endpoint "$ALERT_EMAIL" \
  --region "$REGION" > /dev/null 2>/dev/null || true
success "SNS Subscription checked/created."
echo ""
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║  ✉️  Check $ALERT_EMAIL         "
echo "  ║     Confirm the AWS SNS subscription NOW.       ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# ── Step 5: CloudWatch Alarms ─────────────────────────────────
info "Step 5 — Creating Alarm: CPU > 70%"
aws cloudwatch put-metric-alarm \
  --alarm-name "HighCPU-Alarm" \
  --alarm-description "CPU > 70% for 2 consecutive minutes" \
  --metric-name "CPUUtilization" --namespace "AWS/EC2" --statistic "Average" \
  --dimensions "Name=InstanceId,Value=$INSTANCE_ID" \
  --period 60 --evaluation-periods 2 --threshold 70 \
  --comparison-operator "GreaterThanThreshold" \
  --alarm-actions "$SNS_ARN" --ok-actions "$SNS_ARN" \
  --treat-missing-data "notBreaching" --region "$REGION" 2>/dev/null || true
success "Alarm: HighCPU-Alarm (CPU > 70%)"

info "Step 6 — Creating Alarm: Status Check Failed"
aws cloudwatch put-metric-alarm \
  --alarm-name "StatusCheck-Alarm" \
  --alarm-description "EC2 status check failed" \
  --metric-name "StatusCheckFailed" --namespace "AWS/EC2" --statistic "Maximum" \
  --dimensions "Name=InstanceId,Value=$INSTANCE_ID" \
  --period 60 --evaluation-periods 2 --threshold 1 \
  --comparison-operator "GreaterThanOrEqualToThreshold" \
  --alarm-actions "$SNS_ARN" \
  --treat-missing-data "notBreaching" --region "$REGION" 2>/dev/null || true
success "Alarm: StatusCheck-Alarm"

info "Step 7 — Creating Alarm: High Network In (>5MB)"
aws cloudwatch put-metric-alarm \
  --alarm-name "HighNetwork-Alarm" \
  --alarm-description "Network In > 5MB" \
  --metric-name "NetworkIn" --namespace "AWS/EC2" --statistic "Average" \
  --dimensions "Name=InstanceId,Value=$INSTANCE_ID" \
  --period 300 --evaluation-periods 1 --threshold 5000000 \
  --comparison-operator "GreaterThanThreshold" \
  --alarm-actions "$SNS_ARN" \
  --treat-missing-data "notBreaching" --region "$REGION" 2>/dev/null || true
success "Alarm: HighNetwork-Alarm"

# ── Step 8: CloudWatch Dashboard ─────────────────────────────
info "Step 8 — Creating CloudWatch Dashboard: $DASHBOARD_NAME"
DASH_BODY=$(cat <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 0, "y": 0, "width": 12, "height": 6,
      "properties": {
        "title": "CPU Utilization",
        "region": "$REGION",
        "metrics": [["AWS/EC2","CPUUtilization","InstanceId","$INSTANCE_ID"]],
        "period": 60, "stat": "Average", "view": "timeSeries",
        "annotations":{"horizontal":[{"label":"Threshold","value":70}]}
      }
    },
    {
      "type": "metric",
      "x": 12, "y": 0, "width": 12, "height": 6,
      "properties": {
        "title": "Network In/Out",
        "region": "$REGION",
        "metrics": [
          ["AWS/EC2","NetworkIn","InstanceId","$INSTANCE_ID"],
          ["AWS/EC2","NetworkOut","InstanceId","$INSTANCE_ID"]
        ],
        "period": 60, "stat": "Average", "view": "timeSeries"
      }
    },
    {
      "type": "alarm",
      "x": 0, "y": 6, "width": 24, "height": 4,
      "properties": {
        "title": "Alarm Status",
        "alarms": [
          "arn:aws:cloudwatch:$REGION:$ACCOUNT_ID:alarm:HighCPU-Alarm",
          "arn:aws:cloudwatch:$REGION:$ACCOUNT_ID:alarm:StatusCheck-Alarm",
          "arn:aws:cloudwatch:$REGION:$ACCOUNT_ID:alarm:HighNetwork-Alarm"
        ]
      }
    }
  ]
}
EOF
)
aws cloudwatch put-dashboard \
  --dashboard-name "$DASHBOARD_NAME" \
  --dashboard-body "$DASH_BODY" \
  --region "$REGION"
success "Dashboard: $DASHBOARD_NAME (3 widgets)"

info "Alarm Status:"
aws cloudwatch describe-alarms \
  --alarm-names "HighCPU-Alarm" "StatusCheck-Alarm" "HighNetwork-Alarm" \
  --region "$REGION" \
  --query "MetricAlarms[].{Name:AlarmName,State:StateValue,Metric:MetricName,Threshold:Threshold}" \
  --output table

cat > "$STATE_FILE" <<EOF
REGION=$REGION
INSTANCE_ID=$INSTANCE_ID
SG_ID=$SG_ID
VPC_ID=$VPC_ID
SNS_ARN=$SNS_ARN
KEY_NAME=$KEY_NAME
PUBLIC_IP=$PUBLIC_IP
ALERT_EMAIL=$ALERT_EMAIL
AMI_ID=$AMI_ID
ACCOUNT_ID=$ACCOUNT_ID
EOF

banner "CLOUD MONITORING — COMPLETE SUMMARY"
cat <<SUMMARY
  ╔══════════════════════════════════════════════════════════════╗
  ║              RESOURCES CREATED                               ║
  ╠═══════════════════════╦══════════════════════════════════════╣
  ║ Resource              ║ Value                                ║
  ╠═══════════════════════╬══════════════════════════════════════╣
  ║ EC2 Instance          ║ $INSTANCE_ID                         ║
  ║ EC2 Public IP         ║ $PUBLIC_IP                           ║
  ║ Security Group        ║ $SG_ID                               ║
  ║ Key Pair              ║ $KEY_NAME                            ║
  ║ SNS Topic             ║ $TOPIC_NAME                     ║
  ║ SNS Email             ║ $ALERT_EMAIL                         ║
  ║ CW Alarm 1            ║ HighCPU-Alarm (CPU>70%, 2 periods)   ║
  ║ CW Alarm 2            ║ StatusCheck-Alarm (EC2 failure)      ║
  ║ CW Alarm 3            ║ HighNetwork-Alarm (>5MB)             ║
  ║ CW Dashboard          ║ $DASHBOARD_NAME         ║
  ║ AMI Used              ║ $AMI_ID                              ║
  ║ Region                ║ $REGION                              ║
  ╠═══════════════════════╩══════════════════════════════════════╣
  ║              DETAILS NEEDED TO DELETE                        ║
  ╠══════════════════════════════════════════════════════════════╣
  ║  Instance ID : $INSTANCE_ID                                  ║
  ║  SG ID       : $SG_ID                                        ║
  ║  SNS ARN     : (stored in state file)                        ║
  ║  Alarm Names : HighCPU, StatusCheck, HighNetwork             ║
  ║  Dashboard   : $DASHBOARD_NAME                  ║
  ║  State File  : $STATE_FILE                                   ║
  ╠══════════════════════════════════════════════════════════════╣
  ║  Run: ./6_monitor_cleanup.sh (reads state file automatically)  ║
  ╚══════════════════════════════════════════════════════════════╝

  View Dashboard: CloudWatch → Dashboards → Compute-Monitoring-Dashboard
  View Alarms:    CloudWatch → Alarms → All Alarms

  Stress test (trigger CPU alarm):
  EC2 Console → $INSTANCE_ID → Connect → EC2 Instance Connect
  sudo apt update && sudo apt install -y stress && stress --cpu 2 --timeout 300
SUMMARY
