# Migration Runbook

## Pre-migration checklist

- [ ] Azure subscription and ADO org provisioned (`docs/PHASE0_SETUP.md`)
- [ ] Service connection `azure-migration-sc` validated
- [ ] Key Vault and variable group `petclinic-kv-secrets` linked
- [ ] Self-hosted pool `ado-selfhosted-linux` online
- [ ] Pipeline inventory generated (`tools/pipeline_inventory_analyzer.py`)
- [ ] Jira readiness report reviewed (`reports/jira_readiness_report.md`)

## Pipeline migration steps (per application)

1. Import legacy pipeline into `legacy-ci/` reference folder.
2. Map stages using `reports/migration_mapping_matrix.csv`.
3. Create ADO pipeline from `pipelines/azure-pipelines.yml` or app-specific YAML.
4. Run on self-hosted pool if private network or Docker socket required.
5. Validate dev deployment and smoke test.
6. Enable prod environment approval.
7. Archive legacy job (Jenkins/Bamboo/GitLab) after 30-day coexistence.

## Self-hosted agent operations

| Task | Procedure |
|------|-----------|
| Register | `self-hosted-agent/README.md` |
| Patch | Rebuild Docker image monthly; rolling replace agents |
| Rotate PAT | Update Key Vault secret; restart container |
| Network | Allow outbound 443 to ADO, ACR, Azure RM |

## Local ingress/egress demo

```bash
cd container && docker compose -f docker-compose.local.yml up --build
curl http://localhost:8080/actuator/health
```

### Failure-mode tests

| Test | Command | Expected |
|------|---------|----------|
| DB down | `docker compose stop postgres` | Health fails / 503 |
| Egress blocked | `docker compose stop mock-egress` | Logged partner API errors if called |

## Hypercare (first 14 days post-cutover)

| Severity | Response | Owner |
|----------|----------|-------|
| Pipeline down | Check agent pool, ACR auth, KV access | DevOps |
| App unhealthy | Rollback image tag; check App Insights | App team |
| Jira sync | Verify integration app credentials | Platform |

### Triage order

1. ADO pipeline logs → agent → service connection
2. App Service deployment center → container logs
3. Application Insights exceptions
4. Jira Cloud incident linked to change ticket

## Contacts (fill for presentation)

- DevOps lead: ___
- Azure subscription owner: ___
- Jira migration lead: ___
