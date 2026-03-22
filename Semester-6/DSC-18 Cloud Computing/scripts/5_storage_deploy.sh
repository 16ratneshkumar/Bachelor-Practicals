#!/usr/bin/env bash
# ================================================================
#  STATIC WEBSITE — DEPLOY
#  Deploy a Static Website on AWS S3
#  RUN: chmod +x 5_storage_deploy.sh && ./5_storage_deploy.sh
#  STATE: $HOME/aws_state_storage.txt
# ================================================================
set -euo pipefail

REGION="ap-south-1"
STATE_FILE="$HOME/aws_state_storage.txt"

# ── Step 0: Load existing state ─────────────────────────────
if [[ -f "$STATE_FILE" ]]; then
  source "$STATE_FILE"
  info "  Loaded existing bucket: $BUCKET"
else
  BUCKET="practical-static-site-$(date +%s)"
fi
SITE_DIR="$HOME/web_content"

G='\033[0;32m'; B='\033[0;34m'; Y='\033[1;33m'; NC='\033[0m'
info()    { echo -e "${B}[INFO]${NC}  $*"; }
success() { echo -e "${G}[OK]${NC}    $*"; }
banner()  { echo -e "\n${Y}══════════════════════════════════════════${NC}"; \
            echo -e "${Y}  $*${NC}"; \
            echo -e "${Y}══════════════════════════════════════════${NC}\n"; }

banner "STATIC WEBSITE — S3 Hosting"

# ── Step 1: Create S3 Bucket ──────────────────────────────────
info "Step 1 — S3 Bucket: $BUCKET"
if aws s3api head-bucket --bucket "$BUCKET" --region "$REGION" 2>/dev/null; then
  info "  Bucket '$BUCKET' already exists. Using it."
else
  info "  Creating bucket: $BUCKET"
  aws s3api create-bucket \
    --bucket "$BUCKET" \
    --region "$REGION" \
    --create-bucket-configuration LocationConstraint="$REGION" > /dev/null
  success "Bucket created: $BUCKET"
fi

info "  Disabling Block Public Access..."
aws s3api put-public-access-block \
  --bucket "$BUCKET" \
  --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false" \
  --region "$REGION" 2>/dev/null || true
success "Public access unblocked."

# ── Step 2: Bucket Policy ─────────────────────────────────────
info "Step 2 — Applying Public Read Policy"
POLICY='{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicRead",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::'$BUCKET'/*"
    }
  ]
}'
aws s3api put-bucket-policy --bucket "$BUCKET" --policy "$POLICY" --region "$REGION"
success "Bucket policy applied."

info "Step 3 — Enabling Static Website Hosting"
aws s3api put-bucket-website --bucket "$BUCKET" \
  --website-configuration '{"IndexDocument":{"Suffix":"index.html"},"ErrorDocument":{"Key":"error.html"}}' \
  --region "$REGION"
success "Static website hosting enabled."

info "Step 5 — Creating website files"
mkdir -p "$SITE_DIR"
cat > "$SITE_DIR/index.html" <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Secure Login Portal — S3 Static Host</title>
    <style>
        :root { --primary: #6366f1; --bg: #0f172a; --card: #1e293b; --input: #334155; }
        body { font-family: 'Inter', system-ui, sans-serif; background: var(--bg); color: white; margin: 0; display: flex; align-items: center; justify-content: center; min-height: 100vh; }
        .login-card { background: var(--card); padding: 2.5rem; border-radius: 1rem; width: 100%; max-width: 400px; box-shadow: 0 25px 50px -12px rgba(0,0,0,0.5); border: 1px solid rgba(255,255,255,0.1); }
        .logo { font-size: 2rem; margin-bottom: 2rem; text-align: center; }
        h1 { font-size: 1.5rem; font-weight: 700; margin-bottom: 0.5rem; text-align: center; }
        p.subtitle { color: #94a3b8; font-size: 0.875rem; text-align: center; margin-bottom: 2rem; }
        .form-group { margin-bottom: 1.25rem; }
        label { display: block; font-size: 0.875rem; font-weight: 500; margin-bottom: 0.5rem; color: #cbd5e1; }
        input { width: 100%; padding: 0.75rem 1rem; background: var(--input); border: 1px solid rgba(255,255,255,0.1); border-radius: 0.5rem; color: white; box-sizing: border-box; transition: 0.2s; }
        input:focus { outline: none; border-color: var(--primary); box-shadow: 0 0 0 2px rgba(99,102,241,0.2); }
        button { width: 100%; padding: 0.75rem; background: var(--primary); color: white; border: none; border-radius: 0.5rem; font-weight: 600; cursor: pointer; transition: 0.2s; margin-top: 1rem; }
        button:hover { background: #4f46e5; }
        .footer-links { margin-top: 1.5rem; display: flex; justify-content: space-between; font-size: 0.75rem; color: #64748b; }
        .footer-links a { color: var(--primary); text-decoration: none; }
    </style>
</head>
<body>
    <div class="login-card">
        <div class="logo">👤</div>
        <h1>Portal Login</h1>
        <p class="subtitle">Cloud Infrastructure Management</p>
        <div class="form-group">
            <label>Employee Email</label>
            <input type="email" placeholder="name@company.com">
        </div>
        <div class="form-group">
            <label>Access Key</label>
            <input type="password" placeholder="••••••••">
        </div>
        <button type="submit">Unlock System</button>
        <div class="footer-links">
            <a href="error.html">Forgot Key?</a>
            <span>Powered by Amazon S3</span>
        </div>
    </div>
</body>
</html>
HTML

cat > "$SITE_DIR/error.html" <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Access Denied — 404</title>
    <style>
        :root { --bg: #0f172a; --card: #1e293b; --danger: #ef4444; }
        body { font-family: 'Inter', system-ui, sans-serif; background: var(--bg); color: white; margin: 0; display: flex; align-items: center; justify-content: center; min-height: 100vh; }
        .error-card { background: var(--card); padding: 3rem; border-radius: 1rem; text-align: center; max-width: 400px; border: 1px solid rgba(239,68,68,0.2); }
        .icon { font-size: 4rem; margin-bottom: 1rem; color: var(--danger); }
        h1 { font-size: 2rem; margin-bottom: 0.5rem; }
        p { color: #94a3b8; margin-bottom: 2rem; line-height: 1.5; }
        .btn { display: inline-block; padding: 0.75rem 1.5rem; background: rgba(255,255,255,0.05); color: white; text-decoration: none; border-radius: 0.5rem; border: 1px solid rgba(255,255,255,0.1); transition: 0.2s; }
        .btn:hover { background: rgba(255,255,255,0.1); }
    </style>
</head>
<body>
    <div class="error-card">
        <div class="icon">⚠️</div>
        <h1>404 Error</h1>
        <p>The requested security protocol or page was not found on this server. Please return to the primary portal.</p>
        <a href="index.html" class="btn">Back to Login</a>
    </div>
</body>
</html>
HTML
success "HTML files created in $SITE_DIR"

info "Step 6 — Uploading files to S3"
aws s3 cp "$SITE_DIR/index.html" "s3://${BUCKET}/index.html" --content-type "text/html"
aws s3 cp "$SITE_DIR/error.html" "s3://${BUCKET}/error.html" --content-type "text/html"
success "Files uploaded."

info "Step 7 — Verifying bucket contents"
aws s3 ls "s3://$BUCKET/" --human-readable

INDEX_URL="https://${BUCKET}.s3.${REGION}.amazonaws.com/index.html"
ERROR_URL="https://${BUCKET}.s3.${REGION}.amazonaws.com/error.html"

cat > "$STATE_FILE" <<EOF
REGION=$REGION
BUCKET=$BUCKET
INDEX_URL=$INDEX_URL
ERROR_URL=$ERROR_URL
SITE_DIR=$SITE_DIR
EOF

banner "STATIC WEBSITE — COMPLETE SUMMARY"
cat <<SUMMARY
  ╔══════════════════════════════════════════════════════════════╗
  ║              RESOURCES CREATED                               ║
  ╠═══════════════════════╦══════════════════════════════════════╣
  ║ Resource              ║ Value                                ║
  ╠═══════════════════════╬══════════════════════════════════════╣
  ║ S3 Bucket             ║ $BUCKET                              ║
  ║ Website URL (HTTP)    ║ http://${BUCKET}.s3-website.${REGION}.amazonaws.com ║
  ║ Error URL (HTTP)      ║ http://${BUCKET}.s3-website.${REGION}.amazonaws.com/error.html ║
  ║ Hosting Type          ║ Static Website (index.html)          ║
  ║ Bucket Policy         ║ Public read (s3:GetObject)           ║
  ║ Files Uploaded        ║ index.html, error.html               ║
  ║ Region                ║ $REGION                              ║
  ╠═══════════════════════╩══════════════════════════════════════╣
  ║              DETAILS NEEDED TO DELETE                        ║
  ╠══════════════════════════════════════════════════════════════╣
  ║  Bucket Name : $BUCKET                                       ║
  ║  Region      : $REGION                                       ║
  ║  State File  : $STATE_FILE                                   ║
  ╠══════════════════════════════════════════════════════════════╣
  ║  Run: ./5_storage_cleanup.sh  (reads state file automatically) ║
  ╚══════════════════════════════════════════════════════════════╝

  Website URL (HTTP): http://${BUCKET}.s3-website.${REGION}.amazonaws.com
  Error URL (HTTP)  : http://${BUCKET}.s3-website.${REGION}.amazonaws.com/error.html
SUMMARY
