#!/usr/bin/env bash
# ---------------------------------------------------------------
# Deletes every file in the bucket, then deletes the bucket.
#
# Usage: ./cleanup.sh <bucket-name>
# ---------------------------------------------------------------
set -euo pipefail

BUCKET="${1:?Usage: ./cleanup.sh <bucket-name>}"

read -r -p "This permanently deletes s3://$BUCKET and everything in it. Type the bucket name to confirm: " CONFIRM
if [ "$CONFIRM" != "$BUCKET" ]; then
  echo "Names did not match. Nothing was deleted."
  exit 1
fi

aws s3 rb "s3://$BUCKET" --force
echo "Deleted s3://$BUCKET. Nothing left to bill."
