# Module J — Jenkins Cloud Migration Path

## Option A: Retain Jenkins (cloud controller + ephemeral agents)

| On-prem | Jenkins cloud |
|---------|----------------|
| Static `linux-build-farm-01` | Kubernetes pod templates / cloud agents |
| Nexus artifacts | ACR + Artifactory cloud |
| SSH VM deploy | **Retire** — use Azure App Service/ACA deploy stage |
| `credentials()` plugin | K8s secrets + Azure Key Vault plugin |

### Plugin inventory (simulated estate)

- workflow-aggregator, docker-workflow, credentials-binding
- junit, nexus-artifact-uploader
- ssh-agent (migrate away)

### Stage mapping Jenkins → Azure DevOps

| Jenkins | Azure DevOps |
|---------|----------------|
| `stage('X')` | `stage:` / `job:` |
| `when { }` | `condition:` |
| `post { failure }` | `condition: failed()` job |
| `input` | Environment approval |
| `archiveArtifacts` | `PublishPipelineArtifact` |

## Option B: Full migration to Azure DevOps (recommended)

Use `pipelines/azure-pipelines.yml` with reusable templates.

## Coexistence strategy

1. **Wave 1:** New builds on ADO; Jenkins read-only for 30 days.
2. **Wave 2:** Disable Jenkins job triggers; redirect webhooks to ADO.
3. **Wave 3:** Decommission Jenkins controllers after hypercare.

## Rollback

- Keep last Jenkins job export (`legacy-ci/jenkins/Jenkinsfile`) in Git.
- Redeploy previous ACR image tag via `rollback-plan.md`.

## Decision

**Migrate to ADO** for PetClinic; retain Jenkins cloud only for teams with heavy Groovy shared libraries until Wave 2.
