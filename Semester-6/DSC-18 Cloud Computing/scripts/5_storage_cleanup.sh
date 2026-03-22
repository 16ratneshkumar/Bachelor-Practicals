#!/bin/env bash
# ================================================================
#  STATIC WEBSITE — CLEANUP
#  Empty and delete S3 bucket
#  RUN: chmod +x 5_storage_cleanup.sh && ./5_storage_cleanup.sh
# ================================================================
set -euo pipefail

STATE_FILE="$HOME/aws_state_storage.txt"
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

banner "STATIC WEBSITE — CLEANUP"

# Standardized Prefix
BUCKET_PREFIX="practical-static-site-"

info "Step 1 — Discovering and Deleting S3 Buckets..."
# Discovery for buckets starting with the prefix if BUCKET is not set
for BKT in ${BUCKET:-$(aws s3api list-buckets --query "Buckets[?starts_with(Name, '$BUCKET_PREFIX')].Name" --output text)}; do
  if [[ -n "$BKT" && "$BKT" != "None" ]]; then
    info "  Emptying bucket: $BKT"
    aws s3 rm "s3://$BKT" --recursive 2>/dev/null || true
    info "  Deleting bucket: $BKT"
    aws s3api delete-bucket --bucket "$BKT" --region "$REGION" 2>/dev/null || true
    success "Bucket $BKT deleted."
  fi
done

info "Step 2 — Removing local files..."
rm -rf "$HOME/web_content" "$STATE_FILE"
success "Cleanup complete."
