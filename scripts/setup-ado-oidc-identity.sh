#!/usr/bin/env bash
# Step 0.4 helper — Create User Assigned Managed Identity for ADO OIDC (manual federation path)
set -euo pipefail

SUBSCRIPTION_ID="${SUBSCRIPTION_ID:-c09dd6ef-0111-4bf0-a0d4-3600979a0c7d}"
LOCATION="${LOCATION:-southeastasia}"
RG_NAME="${RG_NAME:-rg-migration-assessement}"
IDENTITY_NAME="${IDENTITY_NAME:-id-ado-migration-assessment}"
ROLE="${ROLE:-Contributor}"

if [ -z "$SUBSCRIPTION_ID" ]; then
  echo "ERROR: Set SUBSCRIPTION_ID before running."
  echo "  export SUBSCRIPTION_ID=\$(az account show --query id -o tsv)"
  exit 1
fi

if ! command -v az &>/dev/null; then
  echo "ERROR: Azure CLI (az) not installed. Run: brew install azure-cli && az login"
  exit 1
fi

az account set --subscription "$SUBSCRIPTION_ID"
TENANT_ID=$(az account show --query tenantId -o tsv)

echo "=== Creating resource group: $RG_NAME ==="
az group create --name "$RG_NAME" --location "$LOCATION" -o none

echo "=== Creating user-assigned managed identity: $IDENTITY_NAME ==="
az identity create \
  --resource-group "$RG_NAME" \
  --name "$IDENTITY_NAME" \
  --location "$LOCATION" \
  -o none

PRINCIPAL_ID=$(az identity show -g "$RG_NAME" -n "$IDENTITY_NAME" --query principalId -o tsv)
CLIENT_ID=$(az identity show -g "$RG_NAME" -n "$IDENTITY_NAME" --query clientId -o tsv)

echo "=== Assigning $ROLE on subscription (assessment scope) ==="
az role assignment create \
  --assignee "$PRINCIPAL_ID" \
  --role "$ROLE" \
  --scope "/subscriptions/$SUBSCRIPTION_ID" \
  -o none

ISSUER="https://login.microsoftonline.com/${TENANT_ID}/v2.0"

cat <<EOF

=== Azure side ready ===
Resource group:     $RG_NAME
Managed identity:   $IDENTITY_NAME
Client ID:          $CLIENT_ID
Principal ID:       $PRINCIPAL_ID
Tenant ID:          $TENANT_ID
Suggested issuer:   $ISSUER

=== ADO manual service connection (next) ===
1. Project Settings → Service connections → New → Azure Resource Manager
2. Choose: Workload Identity federation (manual)
3. Service connection name: azure-migration-sc
4. Subscription ID: $SUBSCRIPTION_ID
5. Management identity client ID: $CLIENT_ID
6. After ADO shows Issuer + Subject, run:

   export ADO_ISSUER='<paste-from-ADO>'
   export ADO_SUBJECT='<paste-from-ADO>'
   ./scripts/setup-ado-oidc-federated-credential.sh

Or use Automatic wizard if you prefer (skip federated credential script).

EOF
