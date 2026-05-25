#!/usr/bin/env bash
# Remove Bicep-created RG (if any) and redeploy with Terraform only
set -euo pipefail

SUBSCRIPTION_ID="${AZURE_SUBSCRIPTION_ID:-c09dd6ef-0111-4bf0-a0d4-3600979a0c7d}"
RG="${RESOURCE_GROUP_NAME:-rg-migration-assessement}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPORTS_DIR="$(cd "$SCRIPT_DIR/../../reports" && pwd)"

az account set --subscription "$SUBSCRIPTION_ID"

echo "=== WARNING: This deletes resource group: $RG and all resources inside ==="
read -r -p "Continue? [y/N] " ans
if [[ ! "$ans" =~ ^[Yy]$ ]]; then
  echo "Cancelled."
  exit 0
fi

echo "=== Deleting resource group (removes Bicep/Terraform resources) ==="
az group delete --name "$RG" --yes --no-wait
echo "Waiting for deletion..."
az group wait --name "$RG" --deleted 2>/dev/null || sleep 30

echo "=== Terraform init + apply ==="
cd "$SCRIPT_DIR"
terraform init -input=false
terraform plan -out=tfplan -input=false | tee "$REPORTS_DIR/terraform-plan.txt"
terraform apply -input=false -auto-approve tfplan
terraform output -json | tee "$REPORTS_DIR/terraform-outputs.json"

echo "=== Done. Outputs in reports/terraform-outputs.json ==="
