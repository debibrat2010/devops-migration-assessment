# Phase 0 — Azure, Azure DevOps, and GitHub Setup

Complete these steps before running cloud pipelines (Modules E–H). Work through **0.1 → 0.8** in order.

**Helper scripts:** `scripts/install-local-tools-macos.sh`, `scripts/check-prerequisites.sh`, `scripts/setup-ado-oidc-identity.sh`  
**macOS tips:** [PHASE0_PERSONAL_MAC_ADMIN.md](PHASE0_PERSONAL_MAC_ADMIN.md) (Homebrew PATH, Docker, no-admin fallbacks)

---

## Progress checklist

| Step | Description | Done? |
|------|-------------|-------|
| 0.1 | GitHub candidate repository | ☑ |
| 0.2 | Azure subscription + `az login` | ☑ |
| 0.3 | Azure DevOps org + project | ☑ |
| 0.4 | Service connection `azure-migration-sc` (OIDC) | ☑ |
| 0.5 | Link GitHub → ADO pipeline | ☑ |
| 0.6 | Local toolchain + evidence | ☑ |
| 0.6b | Key Vault variable group (after Module E) | ☑ |
| 0.7 | Self-hosted agent pool | ☑ |
| 0.8 | Environments `dev` / `prod` | ☑ |

---

## 0.1 GitHub candidate repository

1. Create a **private** repo: `devops-migration-assessment` (or your name).
2. Add remote and push this workspace:

```bash
cd /Users/debi/migration-assessment
git remote add origin git@github.com:<YOUR_ORG>/devops-migration-assessment.git
git add -A && git commit -m "Initial assessment submission"
git push -u origin main
```

**Record:** GitHub repo URL in `reports/phase0-azure-setup-evidence.txt`

---

## 0.2 Azure subscription

1. Create a subscription: https://azure.microsoft.com/free/
2. Record **Subscription ID**, **Tenant ID**, assessment **region** `southeastasia`.

```bash
eval "$(/opt/homebrew/bin/brew shellenv)"   # macOS Homebrew
az login
az account set --subscription "<SUBSCRIPTION_ID>"
az account show -o table
```

**Your subscription:** Azure subscription 1 — `c09dd6ef-0111-4bf0-a0d4-3600979a0c7d`  
**Assessment resource group (IaC):** `rg-migration-assessement` in `southeastasia` — see [IAC_PREREQUISITES.md](IAC_PREREQUISITES.md)

---

## 0.3 Azure DevOps organization

1. https://dev.azure.com — create org (e.g. `yourname-migration`).
2. Create project: `migration-assessment`.
3. Record **Organization URL** and **Project name** in `reports/phase0-azure-setup-evidence.txt`.

---

## 0.4 Service connection (Azure Resource Manager)

**Goal:** A service connection named `azure-migration-sc` that pipelines use instead of stored passwords (OIDC / workload identity federation).

Reference: [azure-devops-terraform-oidc-ci-cd](https://github.com/Azure-Samples/azure-devops-terraform-oidc-ci-cd)

### Recommended: ADO wizard (Automatic)

1. Open: `https://dev.azure.com/<YOUR_ORG>/<YOUR_PROJECT>`
2. **Project settings** (bottom left) → **Service connections** → **New connection**
3. **Azure Resource Manager** → **Next**
4. **Workload Identity federation** → **Automatic** (if you are Subscription Owner/Contributor)
5. **Scope level:** Subscription **or** resource group **`rg-migration-assessement`** (recommended after IaC)
6. Select your **subscription** (and optional resource group)
7. **Service connection name:** `azure-migration-sc`
8. Check **Grant access permission to all pipelines**
9. **Save** → **Verify** (must show success)

### If Automatic fails — Manual OIDC

**Part A — Azure**

```bash
cd /Users/debi/migration-assessment
export SUBSCRIPTION_ID="<your-subscription-id>"
export LOCATION="southeastasia"
export RG_NAME="rg-migration-assessement"
./scripts/setup-ado-oidc-identity.sh
```

Creates/uses `rg-migration-assessement` and managed identity `id-ado-migration-assessment`. Note the **Client ID** printed.

**Part B — Azure DevOps**

1. **New connection** → **Azure Resource Manager** → **Workload Identity federation (manual)**
2. **Service connection name:** `azure-migration-sc`
3. **Subscription ID** and name from `az account show`
4. **Management identity client ID:** from script output
5. Copy **Issuer** and **Subject** from ADO into federated credential:

```bash
export ADO_ISSUER='<from ADO service connection page>'
export ADO_SUBJECT='<from ADO service connection page>'
./scripts/setup-ado-oidc-federated-credential.sh
```

6. Back in ADO → **Verify**

**Part C — Portal check (optional)**  
Azure Portal → Managed identities → `id-ado-migration-assessment` → Federated credentials → audience `api://AzureADTokenExchange`

### Service principal (legacy alternative)

```bash
az ad sp create-for-rbac --name "ado-migration-sp" --role contributor \
  --scopes /subscriptions/<SUBSCRIPTION_ID> --sdk-auth
```

ADO: **New** → **Azure Resource Manager** → **Service principal (manual)** → name `azure-migration-sc`.

### ACR connection (after Module E deploys ACR)

1. **New connection** → **Docker Registry** → **Azure Container Registry**
2. Select your ACR → name: `acr-migration-sc`
3. Grant access to all pipelines

Until ACR exists, skip this; builds can run without push to ACR.

### Record evidence

Update `reports/phase0-azure-setup-evidence.txt`:

```text
Service connection name: azure-migration-sc
Connection type: Workload Identity Federation (OIDC)
Verify status: Succeeded
```

---

## 0.5 Link GitHub to Azure DevOps

**Goal:** ADO pipelines build from your GitHub assessment repo.

### Option B (recommended) — Pipeline from GitHub

1. Confirm code is on GitHub:

```bash
cd /Users/debi/migration-assessment
git remote add origin git@github.com:<YOUR_ORG>/devops-migration-assessment.git   # once
git add -A && git commit -m "Initial assessment submission"   # skip if already committed
git push -u origin main
```

`src refspec main does not match any` means **no commit yet** — run `git commit` before `git push`.

2. Azure DevOps → **Pipelines** → **Create pipeline** (or **New pipeline**)
3. **GitHub**
4. **Authorize** (install **Azure Pipelines** GitHub App if prompted)
5. Select your account/org → repository (e.g. `devops-migration-assessment`)
6. **Existing Azure Pipelines YAML file**
7. Path: `/pipelines/azure-pipelines.yml`
8. **Save** — do **not** run yet (variable group / ACR needed after Module E)

### GitHub App permissions (if authorize fails)

GitHub → **Settings → Applications → Azure Pipelines** → grant access to your repo.

### Optional: GitHub service connection

**Project settings** → **Service connections** → **New** → **GitHub** → authorize → name `github-migration-sc`

### Option A — Azure Repos mirror (skip if GitHub-only)

**Repos** → **Import repository** → paste GitHub clone URL.

### Record evidence

```text
GitHub repo URL: https://github.com/<ORG>/<REPO>
ADO pipeline linked: Yes — pipelines/azure-pipelines.yml
```

---

## 0.6 Local toolchain

**Goal:** Tools for local Modules A–D and `az`/Terraform for Module E.

### macOS + Homebrew (recommended)

```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
source ~/.zprofile

cd /Users/debi/migration-assessment
./scripts/install-local-tools-macos.sh
```

Terraform installs via `brew tap hashicorp/tap` (not in default Homebrew core).

### Java 17 PATH (required after openjdk install)

```bash
brew install openjdk@17
echo 'export PATH="$(brew --prefix openjdk@17)/bin:$PATH"' >> ~/.zprofile
echo 'export JAVA_HOME="$(brew --prefix openjdk@17)"' >> ~/.zprofile
source ~/.zprofile
java -version
```

### Docker Desktop

```bash
brew install --cask docker
open -a Docker
# Wait until daemon is running
docker version   # must show Client and Server
```

### Verify all tools

```bash
./scripts/check-prerequisites.sh | tee reports/phase0-local-toolchain-evidence.txt
```

Expect all **OK** and `docker daemon: running`. See [reports/phase0-local-toolchain-evidence.txt](../reports/phase0-local-toolchain-evidence.txt) for a completed example.

### Local PetClinic smoke test (optional)

```bash
cd container
docker compose -f docker-compose.local.yml up --build
curl -s http://localhost:8080/actuator/health
```


## 0.6b Key Vault and variable groups (after Module E)

After `iac/terraform/deploy.sh` creates Key Vault:

1. ADO → **Pipelines → Library → + Variable group**
2. Name: `petclinic-kv-secrets` (must match `pipelines/azure-pipelines.yml`)
3. Link to Key Vault from Terraform output, e.g. `kvmigdevaa87c040`
4. Link KV secrets — **ADO variable names match the secret names in Key Vault** (hyphens, not underscores):

| Key Vault secret (ADO variable name) | Example value |
|--------------------------------------|-----------------|
| `acr-login-server` | `acrmigdevaa87c040.azurecr.io` |
| `app-service-dev-name` | `mig-dev-aa87c040-petclinic` |

Pipeline YAML aliases these as `acrLoginServer` and `appServiceDev` via `$(acr-login-server)` and `$(app-service-dev-name)`. Do **not** use `ACR_LOGIN_SERVER` unless you add a separate plain variable with that exact name.

`acrServiceConnection` is set in `azure-pipelines.yml` as `acr-migration-sc` (Docker Registry SC — not a KV secret).

Also create **Docker Registry** service connection `acr-migration-sc` → ACR `acrmigdevaa87c040` (see ACR connection below).

Optional KV secret refs later: `SPRING_DATASOURCE_PASSWORD` — never plain secrets in YAML

---

## 0.7 Self-hosted agent pool

1. ADO → **Organization Settings → Agent pools → Add pool**: `ado-selfhosted-linux`
2. Register agent — see [self-hosted-agent/README.md](../self-hosted-agent/README.md):

```bash
export AZP_URL="https://dev.azure.com/<YOUR_ORG>"
export AZP_TOKEN="<PAT with Agent Pools Read & manage>"
export AZP_POOL="ado-selfhosted-linux"
cd self-hosted-agent && docker build -t ado-selfhosted-agent . && docker run -d --name ado-agent \
  -e AZP_URL -e AZP_TOKEN -e AZP_POOL \
  -e AGENT_ALLOW_RUNASROOT=true \
  -v /var/run/docker.sock:/var/run/docker.sock ado-selfhosted-agent
```

3. Run smoke pipeline: `pipelines/azure-pipelines-agent-smoke.yml`
4. Save log to `reports/module-f-agent-run-evidence.txt`

---

## 0.8 Environments and approvals

1. ADO → **Pipelines → Environments**
2. Create **dev** (no approval)
3. Create **prod** → **Approvals and checks** → add 1+ approvers
4. Pipelines reference these in `pipelines/azure-pipelines.yml`

### Prod App Service (after dev test)

The prod **pipeline stage** uses `$(appServiceProd)` → `$(app-service-prod-name)` from variable group `petclinic-kv-secrets` (same hyphen naming as dev).

**For the first pipeline run (recommended):**

- Prod KV secret **`app-service-prod-name`** must match a real App Service in Azure (second Terraform apply with `environment=prod`, or demo value = dev app name).
- Do **not** use `APP_SERVICE_PROD_NAME` unless you add a plain Library variable with that exact name.

**What the assessment actually requires:**

| Requirement | Required for submission? |
|-------------|-------------------------|
| ADO environment **prod** with **approval** gate | **Yes** — Module N / release governance |
| Separate Azure App Service for prod | **Recommended** for a realistic story, not blocking for first green dev deploy |
| Second Terraform apply (`environment=prod` in `terraform.tfvars`) | **Optional now** — creates a second ACR + App Service in the same RG; do this after dev pipeline succeeds |

When ready for a dedicated prod App Service:

```bash
cd iac/terraform
cp terraform.tfvars terraform.tfvars.prod
# Edit: environment = "prod"
terraform apply -var-file=terraform.tfvars.prod
# Add Key Vault secret app-service-prod-name from terraform output; link in petclinic-kv-secrets
```

---

## Evidence checklist

| Item | File |
|------|------|
| Subscription ID, ADO org URL | `reports/phase0-azure-setup-evidence.txt` |
| Service connection + verify | `reports/phase0-azure-setup-evidence.txt` |
| Local toolchain check | `reports/phase0-local-toolchain-evidence.txt` |
| Agent pool smoke run | `reports/module-f-agent-run-evidence.txt` |

---

## What’s next

| Action | Details |
|--------|---------|
| Run main pipeline | [`pipelines/azure-pipelines.yml`](../pipelines/azure-pipelines.yml) — Build → Scan → DeployDev |
| Optional prod stack | Second `terraform apply` with `environment=prod`; KV secret `app-service-prod-name` |
| Modules A–D local | Docker compose, pipeline inventory, Jira analyzer (can run anytime) |
| Presentation | Screenshots from pipeline runs → `docs/final-presentation-outline.md` |

See [SUBMISSION_CHECKLIST.md](SUBMISSION_CHECKLIST.md) for full assessment deliverables.
