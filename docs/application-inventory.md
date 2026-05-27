# Application Inventory — Assessment Workloads

Generated for Module A baseline. Evidence: Maven/Docker build in `container/Dockerfile` (tests run in build stage).

## Primary: Spring PetClinic (`apps/spring-petclinic`)

| Attribute | Value |
|-----------|-------|
| Language | Java 17 |
| Framework | Spring Boot 4.0.x |
| Build tool | Maven (`./mvnw`) |
| Test command | `./mvnw test` |
| Package artifact | `target/spring-petclinic-*.jar` |
| Default port | 8080 |
| Health endpoint | `/actuator/health` (actuator exposed in dev) |
| Default database | H2 in-memory (`database=h2` in `application.properties`) |
| Alternate DB profiles | `mysql`, `postgres` via `application-*.properties` |
| Key env vars | `SPRING_PROFILES_ACTIVE`, `SPRING_DATASOURCE_URL`, `SPRING_DATASOURCE_USERNAME`, `SPRING_DATASOURCE_PASSWORD`, `PETCLINIC_EXTERNAL_API_URL` |
| External dependencies | H2/MySQL/PostgreSQL, optional external HTTP API (mock in compose) |
| Deployment assumption | Container on Azure App Service for Containers or AKS; ingress TLS at edge |

### Build steps

```bash
cd apps/spring-petclinic
./mvnw -q -DskipTests package    # or with tests: ./mvnw test package
```

### Runtime configuration

- Profile `default`: embedded H2, schema/data from `classpath:db/h2/`.
- For Docker compose: `SPRING_PROFILES_ACTIVE=postgres` with JDBC URL to `postgres` service.

---

## Secondary: Python Flask (`apps/python-flask`)

| Attribute | Value |
|-----------|-------|
| Language | Python 3 |
| Framework | Flask |
| Entry | `app.py` |
| Default port | 5000 (Flask dev server) / 8000 in container |
| Health | `GET /` returns 200 |
| Dependencies | `requirements.txt` |
| Azure target | App Service for Containers or ACA |

### Pipeline evidence

- Azure DevOps pipeline: `pipelines/azure-pipelines-python.yml`
- Run URL: https://dev.azure.com/debibrat2021/migration-assessment/_build/results?buildId=20&view=results
- Result: Succeeded on `ado-selfhosted-linux`

---

## Secondary: Node.js Todo (`apps/todo-nodejs-mongo`)

| Attribute | Value |
|-----------|-------|
| Components | `src/web` (frontend), `src/api` (API), MongoDB |
| Pattern | Azure Container Apps + Mongo (see upstream ACA sample) |
| Build | `npm install` / `npm run build` per package |
| Dependencies | MongoDB connection string via env |

---

## Deployment assumptions (all apps)

- Images stored in Azure Container Registry with immutable tags (`BuildId` + git SHA).
- Secrets from Azure Key Vault via ADO variable groups.
- Ingress: HTTPS at App Service / Application Gateway / NGINX Ingress / ACA ingress.
- Egress: database, ACR, Key Vault, package registries — documented in `docs/architecture.md`.
