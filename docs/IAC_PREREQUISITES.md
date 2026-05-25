# IaC prerequisites — what you need

Use this before running [`iac/terraform/deploy.sh`](../iac/terraform/deploy.sh).

## Already configured (from your setup)

| Item | Value |
|------|--------|
| Subscription ID | `c09dd6ef-0111-4bf0-a0d4-3600979a0c7d` |
| Subscription name | Azure subscription 1 |
| Resource group | `rg-migration-assessement` |
| Region | `southeastasia` |
| Local tools | `az`, `terraform` — see `reports/local-toolchain-evidence.txt` |

## Required from you

### 1. Azure CLI login (same subscription)

```bash
az login
az account set --subscription "c09dd6ef-0111-4bf0-a0d4-3600979a0c7d"
az account show -o table
```

### 2. Permissions on the subscription or resource group

Your user (or the service connection identity) needs at least:

- **Contributor** on `rg-migration-assessement` (or subscription), to run Terraform
- **User Access Administrator** or Owner — only if role assignments in `main.tf` fail (managed identity → ACR / Key Vault RBAC)

### 3. Azure DevOps service connection (Phase 0.4)

- Name: `azure-migration-sc`
- Type: Workload Identity Federation (OIDC) or service principal
- Scope: **Subscription** `c09dd6ef-0111-4bf0-a0d4-3600979a0c7d` **or** resource group `rg-migration-assessement`
- **Verify** must succeed before pipeline deploy tasks run

### 4. Quota in Southeast Asia

Confirm in Portal → Subscriptions → Usage + quotas (or):

```bash
az provider show --namespace Microsoft.Web --query resourceTypes
```

Basic App Service plan (B1) and Basic ACR must be allowed in `southeastasia`.

### 5. After Terraform apply — ADO variable group

Create variable group `petclinic-kv-secrets` (Library) with:

| Variable | Source |
|----------|--------|
| `ACR_LOGIN_SERVER` | `terraform output acr_login_server` |
| `APP_SERVICE_DEV_NAME` | `terraform output app_service_name` |
| `acrServiceConnection` | Name of ACR Docker service connection (after ACR exists) |

Link secrets from Key Vault when ready (Phase 0.6b).

### 6. Optional: second environment in same RG

Copy `terraform.tfvars`, set `environment = "prod"`, and apply again (new random suffix → separate ACR/App Service stack).

## Not required in Terraform files

- No passwords in templates
- Subscription ID in `terraform.tfvars` is for convenience; override with `-var` or a private `.tfvars` file

## OIDC bootstrap identity

Script [`scripts/setup-ado-oidc-identity.sh`](../scripts/setup-ado-oidc-identity.sh) defaults to the **same** resource group:

```bash
export SUBSCRIPTION_ID="c09dd6ef-0111-4bf0-a0d4-3600979a0c7d"
export RG_NAME="rg-migration-assessement"
export LOCATION="southeastasia"
./scripts/setup-ado-oidc-identity.sh
```

## Evidence files (after deploy)

| File | Content |
|------|---------|
| `reports/terraform-plan.txt` | `terraform plan` |
| `reports/terraform-outputs.json` | `terraform output -json` |
| `reports/azure-setup-evidence.txt` | Subscription + connection notes |

## Replacing a prior Bicep-only RG

If you only created the RG with Bicep (validate did not deploy workloads):

```bash
cd iac/terraform
./destroy-and-recreate.sh
```

Or import the existing RG:

```bash
terraform import azurerm_resource_group.main /subscriptions/c09dd6ef-0111-4bf0-a0d4-3600979a0c7d/resourceGroups/rg-migration-assessement
./deploy.sh
```

## Checklist

- [ ] `az account show` shows correct subscription
- [ ] `terraform init` succeeds in `iac/terraform`
- [ ] `./deploy.sh` or `./destroy-and-recreate.sh` completes apply
- [ ] Outputs recorded in ADO variable group
- [ ] Service connection scoped and verified
