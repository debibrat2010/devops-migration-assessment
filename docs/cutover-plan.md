# Cutover Plan — DevOps Toolchain Migration

## Scope

Wave 1: PetClinic monolith + CI/CD to Azure DevOps + App Service for Containers.

## Timeline (example)

| Phase | Window | Activities |
|-------|--------|------------|
| T-14 | Planning freeze | Final inventory, approvals |
| T-7 | Rehearsal | Full pipeline dry-run to dev |
| T-1 | Communication | Stakeholder notice, change ticket |
| T0 | Cutover | Disable legacy Jenkins job; enable ADO; deploy prod image |
| T+1 | Validation | Smoke, metrics, hypercare standup |

## Production deployment checklist

| Step | Owner | Evidence |
|------|-------|----------|
| Change ticket approved | Release Manager | CHG number in ADO |
| Image scanned (no CRITICAL) | DevOps | Trivy artifact |
| Prod approval in ADO environment | Approver | ADO audit log |
| Deploy executed | DevOps executor | Release pipeline ID |
| Smoke test passed | QA validator | HTTP 200 health |
| Jira release ticket updated | Release Manager | Jira link |

## Segregation of duties

| Role | Persona | Cannot |
|------|---------|--------|
| Approver | Release Manager | Execute deploy |
| Executor | DevOps Engineer | Approve own change |
| Validator | QA Lead | Modify pipeline |

## Jira Cloud cutover (parallel track)

See `reports/jira_readiness_report.md` waves 1–3.

## Rollback trigger

- Smoke test fails 3 consecutive attempts
- CRITICAL vulnerability in deployed image
- P1 application outage > 15 minutes

Execute `docs/rollback-plan.md`.

## Communication

- Status page update at T0
- Slack/Teams channel `#migration-hypercare`
