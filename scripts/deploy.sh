#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INFRA_DIR="$PROJECT_ROOT/infra"
SRC_DIR="$PROJECT_ROOT/src"

echo "======================================"
echo " AWS API Security - Deployment"
echo "======================================"

echo ""
echo "[1/5] Packaging Lambda..."
cd "$SRC_DIR"

rm -f index.zip
zip -q index.zip index.py

echo "Lambda package created: $SRC_DIR/index.zip"

echo ""
echo "[2/5] Initializing Terraform..."
cd "$INFRA_DIR"

terraform init

echo ""
echo "[3/5] Validating Terraform configuration..."
terraform fmt -check
terraform validate

echo ""
echo "[4/5] Creating Terraform plan..."
terraform plan

echo ""
echo "[5/5] Applying Terraform configuration..."
terraform apply

echo ""
echo "======================================"
echo " Deployment completed successfully!"
echo "======================================"