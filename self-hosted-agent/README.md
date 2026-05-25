# Self-Hosted Azure DevOps Agent (Module F)

## Pool name

`ado-selfhosted-linux`

## Register agent

```bash
export AZP_URL="https://dev.azure.com/<YOUR_ORG>"
export AZP_TOKEN="<PAT>"
export AZP_POOL="ado-selfhosted-linux"

cd self-hosted-agent
docker build -t ado-selfhosted-agent .
docker run -d --name ado-agent \
  -e AZP_URL -e AZP_TOKEN -e AZP_POOL \
  -e AGENT_ALLOW_RUNASROOT=true \
  -v /var/run/docker.sock:/var/run/docker.sock \
  ado-selfhosted-agent
```

## Capabilities required

- Java 17, Maven
- Docker (build/push images)
- Azure CLI, kubectl, Helm, Trivy

## Network placement

| Traffic | Destination | Port |
|---------|-------------|------|
| ADO | `dev.azure.com`, `*.visualstudio.com` | 443 |
| ACR | `*.azurecr.io` | 443 |
| Azure RM | `management.azure.com` | 443 |
| Key Vault | `*.vault.azure.net` | 443 |
| Private endpoints | VNet-integrated agent subnet | as designed |

## Agent model comparison

| Model | Use when |
|-------|----------|
| Microsoft-hosted | Public OSS builds, no private network |
| Self-hosted VM/container | Private ACR, on-prem artifacts, legacy tools |
| VMSS agents | Elastic pool at scale |
| Managed DevOps Pools | Microsoft-managed capacity with VNet |

## Evidence

Run pipeline `pipelines/azure-pipelines-agent-smoke.yml` and save log to `reports/agent-run-evidence.txt`.
