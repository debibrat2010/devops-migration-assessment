# Infrastructure as Code (IaC) — Module E

## Tooling choice

**Terraform only** for Module E (assessment platform). Bicep was removed to keep one IaC story for demos and documentation.

| Path | Purpose |
|------|---------|
| [`terraform/`](terraform/) | **Module E** — resource group + ACR, Key Vault, App Insights, Log Analytics, App Service |
| [`apps/python-flask/infra/`](../../apps/python-flask/infra/) | Optional sample app IaC — deploy into shared RG with `resourceGroupName=rg-migration-assessement` |
| [`apps/todo-nodejs-mongo/infra/`](../../apps/todo-nodejs-mongo/infra/) | Optional ACA sample — same RG parameter |

## Standard Azure settings

| Setting | Value |
|---------|--------|
| Resource group | `rg-migration-assessement` |
| Region | `southeastasia` |
| Subscription | `c09dd6ef-0111-4bf0-a0d4-3600979a0c7d` (Azure subscription 1) |

## Quick start

### Fresh deploy (RG already exists from Bicep — import or recreate)

**Option A — Recreate cleanly (recommended after Bicep trial):**

```bash
cd iac/terraform
chmod +x destroy-and-recreate.sh deploy.sh
./destroy-and-recreate.sh
```

**Option B — Keep existing RG, Terraform adopts it:**

```bash
cd iac/terraform
terraform init
terraform import azurerm_resource_group.main /subscriptions/c09dd6ef-0111-4bf0-a0d4-3600979a0c7d/resourceGroups/rg-migration-assessement
./deploy.sh
```

### Normal deploy

```bash
cd iac/terraform
./deploy.sh
```

## Terraform files

| File | Purpose |
|------|---------|
| `versions.tf` | Provider pins |
| `variables.tf` | Inputs |
| `main.tf` | Resources |
| `outputs.tf` | ACR, Key Vault, App Service names for pipelines |
| `terraform.tfvars` | Your subscription / RG / region |
| `deploy.sh` | plan + optional apply |
| `destroy-and-recreate.sh` | Delete RG and apply fresh |

## Prerequisites

[docs/IAC_PREREQUISITES.md](../docs/IAC_PREREQUISITES.md)

## Evidence

| File | When |
|------|------|
| `reports/terraform-plan.txt` | After `terraform plan` |
| `reports/terraform-outputs.json` | After `terraform apply` |
