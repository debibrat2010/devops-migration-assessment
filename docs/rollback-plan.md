# Rollback Plan

## Application rollback (PetClinic on App Service)

1. Identify last known good image tag from ACR: `petclinic:<BuildId>`.
2. In Azure Portal or CLI:

```bash
az webapp config container set \
  --name <APP_NAME> \
  --resource-group rg-migration-assessement \
  --docker-custom-image-name <ACR>.azurecr.io/petclinic:<PREVIOUS_TAG>
```

3. Restart app; run smoke test on `/actuator/health`.
4. ADO: run `Rollback` stage in `pipelines/azure-pipelines.yml` or manual redeploy job.

## App Service deployment slot rollback

If using slots:

```bash
az webapp deployment slot swap \
  --name <APP_NAME> \
  --resource-group rg-migration-assessement \
  --slot staging \
  --action preview
# If staging is good, swap back to restore previous production
```

## AKS rollback

```bash
kubectl rollout undo deployment/petclinic -n petclinic
kubectl rollout status deployment/petclinic -n petclinic
```

## Azure Container Apps rollback

```bash
az containerapp revision list --name <APP> --resource-group <RG>
az containerapp ingress update --name <APP> --resource-group <RG> --revision <PREVIOUS_REVISION>
```

## CI/CD toolchain rollback

| Component | Rollback action |
|-----------|-----------------|
| Azure DevOps | Disable new pipeline; re-enable Jenkins job from `legacy-ci/jenkins/Jenkinsfile` |
| GitHub Actions | Disable workflow; use ADO as primary |
| Jira | DNS revert to Data Center within 24h rollback boundary |

## Validation after rollback

- [ ] Health endpoint 200
- [ ] No error spike in Application Insights (15 min window)
- [ ] Change ticket updated with rollback reason
- [ ] Post-incident review scheduled

## Data rollback boundary

- **Containers:** Stateless — redeploy previous image only
- **Database:** Forward-only unless DBA restore from pre-cutover snapshot
- **Jira:** JCMA rollback window 24h per wave plan
