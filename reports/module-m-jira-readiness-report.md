# Jira Cloud Migration Readiness Report

## Executive summary

- **Projects:** 4
- **Total issues (approx):** 2600
- **Inactive users:** 2 (remediate before cutover)
- **Attachment storage:** 18.1 GB
- **Incompatible/migration-risk apps:** 2

## Project inventory

| Key | Name | Issues |
|-----|------|--------|
| PET | PetClinic Application | 1240 |
| DEVOPS | DevOps Platform | 890 |
| REL | Release Management | 320 |
| INFRA | Infrastructure | 150 |

## Issue volumes by type/status

| Project | Type | Status | Count |
|---------|------|--------|-------|
| PET | Story | Done | 450 |
| PET | Bug | Open | 85 |
| PET | Task | In Progress | 120 |
| DEVOPS | Story | Done | 300 |
| DEVOPS | Bug | Open | 45 |
| REL | Change Request | Approved | 80 |
| REL | Change Request | In Review | 40 |
| INFRA | Incident | Resolved | 150 |

## Users and groups

- Active users: 5
- Inactive accounts to exclude: inactive1, inactive2
- Groups: 5 (review `inactive-contractors` membership)

## Workflows and customizations

- **PET** — Pet Development Workflow: 8 statuses, approval=true
- **DEVOPS** — Platform Workflow: 6 statuses, approval=false
- **REL** — Change Approval Workflow: 5 statuses, approval=true
- **INFRA** — Service Desk Workflow: 4 statuses, approval=false

## App compatibility (JCMA pre-check)

| App | Cloud compatible | Notes |
|-----|------------------|-------|
| ScriptRunner | false | Requires cloud alternative or retirement |
| Insight Assets | partial | Plan Assets cloud migration |
| Xray Test Management | true | Cloud version available |
| Automation for Jira | true | Native in Jira Cloud |
| Custom Field Suite | false | Rebuild fields in cloud |

## Migration waves

| Wave | Scope | Duration | Rollback boundary |
|------|-------|----------|-------------------|
| 0 | Pre-migration: user cleanup, app assessment, test JCMA | 2 weeks | N/A |
| 1 | INFRA + REL (low complexity) | 1 week | Restore DC backup snapshot |
| 2 | DEVOPS project | 2 weeks | Wave 1 unchanged |
| 3 | PET (PetClinic) — highest volume | 3 weeks | Per-project export rollback |
| 4 | Hypercare | 2 weeks | Forward-only fixes |

## JCMA-style cutover plan

1. **Pre-checks:** User/group sync, app compatibility, attachment size limits
2. **Test migration:** Clone PET project to sandbox cloud site
3. **UAT:** Product owners validate workflows and dashboards
4. **Production cutover:** Maintenance window, freeze writes, run JCMA, DNS/URL switch
5. **Rollback boundary:** If critical workflow failure within 24h, revert DNS to DC; data delta manual
6. **Hypercare:** Dedicated channel, Sev1 < 1h response for 14 days

## Integrations after migration

- **Azure DevOps:** bi-directional work item linking (AB# keys)
- **GitHub:** Jira development panel via GitHub for Jira app
- **ServiceNow:** Change requests reference Jira Cloud change keys
- **Azure Pipelines:** Deployment gates publish build evidence to Jira release tickets

## Risks

- ScriptRunner customizations require rebuild
- Large PET attachments may extend migration window
- Service accounts (`svc-jenkins`, `svc-bamboo`) need cloud API tokens
