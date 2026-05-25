#!/usr/bin/env bash
# Module E — Terraform deploy (single RG: rg-migration-assessement)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPORTS_DIR="$(cd "$SCRIPT_DIR/../../reports" && pwd)"

cd "$SCRIPT_DIR"

az account set --subscription "$(grep subscription_id terraform.tfvars | awk -F'"' '{print $2}')"

echo "=== Terraform init ==="
terraform init -input=false

echo "=== Terraform plan ==="
terraform plan -out=tfplan -input=false 2>&1 | tee "$REPORTS_DIR/terraform-plan.txt"

echo ""
read -r -p "Apply this plan? [y/N] " ans
if [[ "$ans" =~ ^[Yy]$ ]]; then
  terraform apply -input=false tfplan
  terraform output -json | tee "$REPORTS_DIR/terraform-outputs.json"
  echo "Outputs saved to reports/terraform-outputs.json"
else
  echo "Skipped apply. Run: terraform apply tfplan"
fi
