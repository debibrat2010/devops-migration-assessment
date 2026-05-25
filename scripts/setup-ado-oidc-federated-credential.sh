#!/usr/bin/env bash
# Step 0.4 — Add federated credential to UAMI using Issuer/Subject from ADO service connection
set -euo pipefail

RG_NAME="${RG_NAME:-rg-migration-assessement}"
IDENTITY_NAME="${IDENTITY_NAME:-id-ado-migration-assessment}"
ADO_ISSUER="${ADO_ISSUER:-}"
ADO_SUBJECT="${ADO_SUBJECT:-}"
CRED_NAME="${CRED_NAME:-ado-azure-migration-sc}"

if [ -z "$ADO_ISSUER" ] || [ -z "$ADO_SUBJECT" ]; then
  echo "ERROR: Set ADO_ISSUER and ADO_SUBJECT from the ADO service connection page."
  echo "  export ADO_ISSUER='https://vstoken.dev.azure.com/...'"
  echo "  export ADO_SUBJECT='sc://...'"
  exit 1
fi

az identity federated-credential create \
  --name "$CRED_NAME" \
  --identity-name "$IDENTITY_NAME" \
  --resource-group "$RG_NAME" \
  --issuer "$ADO_ISSUER" \
  --subject "$ADO_SUBJECT" \
  --audiences "api://AzureADTokenExchange"

echo "Federated credential created. In ADO, click Verify on service connection azure-migration-sc."
