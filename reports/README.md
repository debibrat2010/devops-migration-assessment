# Assessment evidence reports

Naming: `phase0-*` = setup before modules; `module-{letter}-*` = hands-on modules A–O.

| File | Module |
|------|--------|
| `phase0-azure-setup-evidence.txt` | Phase 0 — Azure, ADO, KV, pipelines |
| `phase0-local-toolchain-evidence.txt` | Phase 0 — local tools (`check-prerequisites.sh`) |
| `module-a-maven-test.log` | A — `./mvnw test` baseline |
| `module-b-pipeline-inventory.json` | B — pipeline inventory (JSON) |
| `module-b-pipeline-inventory.csv` | B — pipeline inventory (CSV) |
| `module-b-migration-mapping-matrix.csv` | B — Jenkins/Bamboo/GitLab → ADO mapping |
| `module-c-d-local-build-evidence.md` | C & D — Docker compose / ingress notes |
| `module-d-baseline-up.json` | D — health UP (ingress) |
| `module-d-failure-db-down.txt` | D — failure-mode (DB down) |
| `module-e-terraform-plan.txt` | E — `terraform plan` |
| `module-e-terraform-outputs.json` | E — `terraform output -json` |
| `module-e-bicep-validate-dev.json` | E — historical Bicep validate (optional) |
| `module-e-bicep-rg-deploy-output.json` | E — historical Bicep deploy (optional) |
| `module-f-agent-run-evidence.txt` | F — self-hosted agent pool runs |
| `module-k-bamboo-migration-decision-table.csv` | K — Bamboo migration decisions |
| `module-m-jira-readiness-report.md` | M — Jira Cloud readiness |

Regenerate:

```bash
python3 tools/pipeline_inventory_analyzer.py
python3 tools/jira_migration_readiness_analyzer.py
```

Screenshots for presentation: `reports/screenshots/` (create as needed).
