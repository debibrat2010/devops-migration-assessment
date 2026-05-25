# Release Governance (Module N)

## Branch policies

| Branch | Policy |
|--------|--------|
| `main` | PR required, 1 reviewer, build validation (ADO pipeline) |
| `develop` | PR required, optional reviewer |

## Work item traceability

- Commit message: `AB#12345` or `PET-123` for Jira
- ADO: link work items to builds and releases
- Deployment stage publishes release notes to Jira change ticket

## Environment gates

| Environment | Approvals | Smoke test |
|-------------|-----------|------------|
| dev | None | Required |
| prod | 1+ Release Manager | Required + 15 min monitor |

## Audit evidence

- ADO audit log: who approved prod deploy
- ACR: immutable digest per `Build.BuildId`
- Application Insights: deployment correlation ID
- Change ticket: CHG-YYYYMMDD in cutover record

See `cutover-plan.md` for RACI.
