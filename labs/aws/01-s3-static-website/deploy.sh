#!/usr/bin/env bash
# ---------------------------------------------------------------
# Demo 1: Host a static website on Amazon S3
#
# Usage:   ./deploy.sh <bucket-name> [region]
# Example: ./deploy.sh acm-demo-usman-2026 ap-south-1
#
# Needs: AWS CLI v2, configured with `aws configure`
# ---------------------------------------------------------------
set -euo pipefail

BUCKET="${1:?Usage: ./deploy.sh <bucket-name> [region]}"
REGION="${2:-ap-south-1}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SITE_DIR="$SCRIPT_DIR/site"

echo "==> 1/5 Creating bucket s3://$BUCKET in $REGION"
if aws s3api head-bucket --bucket "$BUCKET" 2>/dev/null; then
  echo "    Bucket already exists in your account, reusing it."
else
  aws s3 mb "s3://$BUCKET" --region "$REGION"
fi

echo "==> 2/5 Turning on static website hosting"
aws s3 website "s3://$BUCKET" \
  --index-document index.html \
  --error-document error.html

echo "==> 3/5 + 4/5 Allowing public read access (demo only)"
"$SCRIPT_DIR/make-public.sh" "$BUCKET"

echo "==> 5/5 Uploading the site"
aws s3 sync "$SITE_DIR" "s3://$BUCKET" --delete

# Older Regions use "s3-website-<region>", newer ones use "s3-website.<region>"
case "$REGION" in
  us-east-1|us-west-1|us-west-2|eu-west-1|ap-southeast-1|ap-southeast-2|ap-northeast-1|sa-east-1|us-gov-west-1)
    ENDPOINT="http://$BUCKET.s3-website-$REGION.amazonaws.com" ;;
  *)
    ENDPOINT="http://$BUCKET.s3-website.$REGION.amazonaws.com" ;;
esac

echo ""
echo "Done! Your website is live at:"
echo "   $ENDPOINT"
echo ""
echo "When you are finished, run: ./cleanup.sh $BUCKET"
