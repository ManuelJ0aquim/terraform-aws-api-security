#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INFRA_DIR="$PROJECT_ROOT/infra"

echo "======================================"
echo " AWS API Security - Destroy"
echo "======================================"

echo ""
echo "WARNING: This will destroy the AWS infrastructure."
echo ""

read -r -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
    echo "Destroy cancelled."
    exit 0
fi

echo ""
echo "[1/2] Initializing Terraform..."
cd "$INFRA_DIR"

terraform init

echo ""
echo "[2/2] Destroying Terraform resources..."
terraform destroy

echo ""
echo "======================================"
echo " Infrastructure destroyed successfully!"
echo "======================================"