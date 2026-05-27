# Submission Checklist (Section 9 Deliverables)

| Deliverable | Path | Status |
|-------------|------|--------|
| Containerized PetClinic | `container/Dockerfile` | Done |
| Python + Node apps | `apps/python-flask/`, `apps/todo-nodejs-mongo/` | Done |
| docker-compose + nginx + mock egress | `container/docker-compose.local.yml` | Done |
| Pipeline inventory | `reports/module-b-pipeline-inventory.json` | Generated |
| Migration mapping matrix | `reports/module-b-migration-mapping-matrix.csv` | Generated |
| Jira readiness report | `reports/module-m-jira-readiness-report.md` | Generated |
| ADO pipelines + templates | `pipelines/` | Done |
| Self-hosted agent | `self-hosted-agent/` | Done |
| GHA alternate | `pipelines/github-actions/` | Done |
| Jenkins cloud design | `pipelines/legacy-migration/jenkins-cloud-option.md` | Done |
| IaC Terraform (Module E) | `iac/terraform/` | Done |
| K8s manifests | `k8s/` | Done |
| Architecture | `docs/architecture.md` | Done |
| Runbook / cutover / rollback | `docs/migration-runbook.md`, etc. | Done |
| Presentation | `docs/final-presentation-outline.md` → export PDF/PPTX | **You** export |

## Your action items (requires Azure account)

1. Complete `docs/PHASE0_SETUP.md`
2. Run `iac/terraform/deploy.sh` (or `destroy-and-recreate.sh` after Bicep trial) after `az login`
3. Register self-hosted agent; run `azure-pipelines-agent-smoke.yml`
4. Run `azure-pipelines.yml` with variable group + service connection
5. Run local Docker demo; add screenshots to presentation
6. Push to GitHub private repo
