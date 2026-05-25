# Module L — GitLab on-prem migration risks

| Risk | Mitigation |
|------|------------|
| Monorepo `include:` templates | Inventory includes; convert to ADO template repository |
| Child pipelines | Map to ADO multi-stage with `trigger` or separate pipelines |
| Protected variables | Key Vault-backed variable groups |
| Self-managed runners | `ado-selfhosted-linux` pool with same tags |
| DinD in docker_build job | Enable privileged mode on self-hosted agent only |
| Environment-specific variables | ADO variable groups per environment scope |
| Deployment tokens | Replace with Azure managed identity + ACR AcrPull |

Converted pipeline: `gitlab-to-ado.yml`
