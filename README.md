# DevOps On-Prem to Cloud — Hands-On Assessment

Enterprise DevOps toolchain migration assessment: Jenkins/Bamboo/GitLab → Azure DevOps, Jira Cloud readiness, containerized Spring PetClinic + Python Flask + Node/Mongo workloads.

## Repository layout

| Path | Purpose |
|------|---------|
| `apps/spring-petclinic/` | Primary Java/Spring Boot monolith |
| `apps/python-flask/` | Secondary Python workload |
| `apps/todo-nodejs-mongo/` | Secondary Node/React + Mongo (ACA pattern) |
| `container/` | Dockerfile, docker-compose, nginx ingress |
| `legacy-ci/` | Simulated on-prem Jenkins, Bamboo, GitLab |
| `pipelines/` | Azure DevOps YAML, templates, GitHub Actions |
| `iac/terraform/` | Azure infrastructure (Module E) |
| `self-hosted-agent/` | Linux ADO agent container |
| `tools/` | Pipeline inventory + Jira readiness analyzers |
| `jira-export/` | Mock Jira Server/DC CSV exports |
| `reports/` | Generated inventories and readiness reports |
| `docs/` | Architecture, runbook, cutover, rollback, presentation outline |
| `k8s/` | AKS manifests (ingress, egress NetworkPolicy) |

## Quick start (local)

```bash
# Prerequisites
./scripts/check-prerequisites.sh

# Module A — run PetClinic tests in Docker
cd container && docker compose -f docker-compose.local.yml build app
docker compose -f docker-compose.local.yml up -d
curl -s http://localhost:8080/actuator/health

# Module B — pipeline inventory
python3 tools/pipeline_inventory_analyzer.py

# Module M — Jira readiness
python3 tools/jira_migration_readiness_analyzer.py
```

## Azure setup

See [docs/PHASE0_SETUP.md](docs/PHASE0_SETUP.md) before Modules E–H.

**IaC:** Terraform in [`iac/terraform/`](iac/terraform/) — single resource group `rg-migration-assessement` (`southeastasia`).  
Prerequisites: [docs/IAC_PREREQUISITES.md](docs/IAC_PREREQUISITES.md)

## Assessment modules

Modules A–O are implemented per `docs/PHASE0_SETUP.md` and module deliverables under `docs/`, `reports/`, and `pipelines/`.

## Upstream references

Clone reference repos into `upstream/` (gitignored):

- spring-projects/spring-petclinic
- Azure-Samples/msdocs-python-flask-webapp-quickstart
- Azure-Samples/todo-nodejs-mongo-aca
- jenkinsci/pipeline-examples
- Azure-Samples/azure-devops-terraform-oidc-ci-cd
- Azure/azure-devops-templates-iac
