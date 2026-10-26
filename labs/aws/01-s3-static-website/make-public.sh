#!/usr/bin/env bash
# ---------------------------------------------------------------
# Makes the objects in ONE bucket publicly readable, for the
# static website demo. Do not do this for buckets with private data.
#
# Usage: ./make-public.sh <bucket-name>
# ---------------------------------------------------------------
set -euo pipefail

BUCKET="${1:?Usage: ./make-public.sh <bucket-name>}"

# Step 3: relax Block Public Access for THIS bucket so a public policy is allowed.
# ACL-based public access stays blocked; only the bucket policy below is used.
aws s3api put-public-access-block \
  --bucket "$BUCKET" \
  --public-access-block-configuration \
  "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=false,RestrictPublicBuckets=false"

# Step 4: bucket policy that lets anyone READ (GetObject) the files. Nothing else.
POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadForStaticWebsite",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::$BUCKET/*"
    }
  ]
}
EOF
)

aws s3api put-bucket-policy --bucket "$BUCKET" --policy "$POLICY"

echo "    Public read enabled for s3://$BUCKET"
