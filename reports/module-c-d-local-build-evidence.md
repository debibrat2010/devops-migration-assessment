# Local Build Evidence (Modules C & D)

Run on a machine with Docker Desktop:

```bash
cd /Users/debi/migration-assessment/container
docker compose -f docker-compose.local.yml up --build -d
curl -s http://localhost:8080/actuator/health
curl -s http://localhost:18080/actuator/health
```

## Failure-mode tests (Module D)

```bash
# Block egress — stop mock API
docker compose -f docker-compose.local.yml stop mock-egress
# Observe app logs if external API client is wired; PetClinic runs without hard dependency on mock.

# Database unavailable
docker compose -f docker-compose.local.yml stop postgres
curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/actuator/health
# Expected: 503 or connection errors until postgres restarts
docker compose -f docker-compose.local.yml start postgres
```

Evidence files (Module D):

- `reports/module-d-baseline-up.json` — health UP via ingress
- `reports/module-d-failure-db-down.txt` — postgres stopped (failure-mode)

Capture screenshots of health 200 and failure responses for final presentation.
