# Final Presentation Outline (30–45 minutes)

Export to PDF/PPTX for submission as `docs/final-presentation.pdf` or `.pptx`.

## 1. Current-state toolchain (5 min)

- VMware VMs, Jenkins/Bamboo/GitLab, Jira Server/DC
- Diagram: `docs/architecture.md` current vs target

## 2. Pipeline inventory and complexity (5 min)

- Demo: `tools/pipeline_inventory_analyzer.py` output
- Show `reports/module-b-pipeline-inventory.json` — 3 high-risk pipelines
- Migration mapping highlights from `module-b-migration-mapping-matrix.csv`

## 3. Dockerized monolith + ingress/egress (5 min)

- Live or recorded: `docker compose -f container/docker-compose.local.yml up`
- curl ingress `http://localhost:8080/actuator/health`
- Failure test: stop postgres — show unhealthy state

## 4. Azure DevOps agent + pipeline (7 min)

- Pool `ado-selfhosted-linux` screenshot
- Pipeline run: build → scan → deploy dev
- Reusable templates walkthrough

## 5. Build, scan, push, deploy (5 min)

- ACR image tags: BuildId + SHA
- Trivy report artifact
- App Service URL smoke test

## 6. Jenkins, Bamboo, GitLab mapping (5 min)

- `jenkins-cloud-option.md` decision
- `bamboo-to-ado.yml` / `gitlab-to-ado.yml` snippets
- Migration factory scale: 100+ pipelines via templates

## 7. Jira Cloud readiness (5 min)

- `reports/module-m-jira-readiness-report.md` waves
- App compatibility risks
- Integration with ADO work items

## 8. Security model (3 min)

- Key Vault, no secrets in YAML
- Egress allowlist / NetworkPolicy
- Prod approvals and segregation of duties

## 9. Rollback, monitoring, hypercare (3 min)

- `rollback-plan.md` image tag revert
- Application Insights
- Hypercare checklist

## 10. Lessons learned and scale (2 min)

- Assumptions: Azure subscription, ADO org
- Risks: Bamboo shared credentials, GitLab DinD
- Factory pattern for enterprise rollout

## Appendix slides

- Scoring matrix self-assessment
- Reference links from assessment doc Section 14
