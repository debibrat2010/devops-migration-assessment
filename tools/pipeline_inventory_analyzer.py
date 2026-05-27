#!/usr/bin/env python3
"""
Module B — Legacy pipeline discovery and migration inventory.
Parses simulated Jenkins, Bamboo, and GitLab CI files; emits JSON + CSV.
"""
from __future__ import annotations

import csv
import json
import re
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
LEGACY = ROOT / "legacy-ci"
REPORTS = ROOT / "reports"


@dataclass
class PipelineRecord:
    id: str
    tool: str
    name: str
    source_control: str
    runner_agent: str
    build_tool: str
    artifact_store: str
    deployment_method: str
    approvals: str
    risk_level: str
    file_path: str
    secrets_refs: list[str] = field(default_factory=list)
    target_environments: list[str] = field(default_factory=list)
    risk_notes: list[str] = field(default_factory=list)


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8") if path.exists() else ""


def analyze_jenkins(content: str, path: str) -> PipelineRecord:
    secrets = re.findall(r"credentials\(['\"]([^'\"]+)['\"]\)", content)
    envs = re.findall(r"params\.(\w+)|TARGET_ENV", content)
    targets = list({m for m in re.findall(r"'(dev|staging|prod)'", content)})
    risks = []
    if "ssh" in content.lower():
        risks.append("SSH deploy to VM — migrate to container platform")
    if "input message" in content:
        risks.append("Manual input gate — map to ADO environment approval")
    if secrets:
        risks.append(f"Credential bindings: {', '.join(secrets)}")
    return PipelineRecord(
        id="jenkins-petclinic-001",
        tool="Jenkins",
        name="PetClinic Monolith Pipeline",
        source_control="Git (multibranch/SCM)",
        runner_agent="linux-build-farm-01 (static label)",
        build_tool="Maven (mvnw)",
        secrets_refs=secrets,
        artifact_store="Nexus (corp) + local archiveArtifacts",
        deployment_method="Docker push + SSH docker run on VM",
        target_environments=targets or ["dev", "staging", "prod"],
        approvals="Manual input for prod stage",
        risk_level="High" if "prod" in targets else "Medium",
        risk_notes=risks,
        file_path=path,
    )


def analyze_bamboo(content: str, path: str) -> PipelineRecord:
    secrets = re.findall(r"bamboo\.secret\.(\S+)|\$\{bamboo\.secret[^}]+\}", content)
    manual = "manual: true" in content
    risks = ["Bamboo deployment project linked to SSH VM deploy"]
    if "registry-password" in content:
        risks.append("Shared registry credentials in plan variables")
    return PipelineRecord(
        id="bamboo-petclinic-001",
        tool="Bamboo",
        name="PetClinic Monolith Build and Deploy",
        source_control="Linked repository spring-petclinic-git",
        runner_agent="Maven agents + deploy-agent-pool-prod",
        build_tool="Maven 3 / JDK 17",
        secrets_refs=list(set(secrets)),
        artifact_store="Bamboo artifacts + corporate Docker registry",
        deployment_method="Docker publish + SSH docker compose on prod VM",
        target_environments=["production"],
        approvals="Manual Deploy stage" if manual else "Stage gate on Deploy",
        risk_level="High",
        risk_notes=risks,
        file_path=path,
    )


def analyze_gitlab(content: str, path: str) -> PipelineRecord:
    secrets = re.findall(r"\$CI_REGISTRY_PASSWORD|\$CI_REGISTRY_USER", content)
    envs = re.findall(r"environment:\s*\n\s*name:\s*(\w+)", content)
    risks = ["Self-managed runner tags: onprem-linux-runner"]
    if "when: manual" in content:
        risks.append("Manual deploy jobs — ADO environment approvals")
    if "docker:24-dind" in content:
        risks.append("DinD required — ensure self-hosted agent supports privileged mode")
    return PipelineRecord(
        id="gitlab-petclinic-001",
        tool="GitLab",
        name="PetClinic GitLab CI",
        source_control="GitLab project registry",
        runner_agent="onprem-linux-runner (self-managed)",
        build_tool="Maven + Docker",
        secrets_refs=["CI_REGISTRY_USER", "CI_REGISTRY_PASSWORD"],
        artifact_store="GitLab Container Registry",
        deployment_method="SSH docker run per environment",
        target_environments=envs or ["development", "production"],
        approvals="when: manual on deploy jobs",
        risk_level="High",
        risk_notes=risks,
        file_path=path,
    )


MAPPING_ROWS = [
    {
        "legacy_tool": "Jenkins",
        "legacy_concept": "pipeline { agent { label } }",
        "azure_devops": "pool: name / demands",
        "github_actions": "runs-on: self-hosted",
        "jenkins_cloud": "kubernetes agent pod template",
        "decision": "Migrate to ADO",
    },
    {
        "legacy_tool": "Jenkins",
        "legacy_concept": "credentials('id')",
        "azure_devops": "Variable group linked to Key Vault",
        "github_actions": "secrets / OIDC",
        "jenkins_cloud": "Credentials plugin + K8s secrets",
        "decision": "Migrate to ADO",
    },
    {
        "legacy_tool": "Jenkins",
        "legacy_concept": "input message approval",
        "azure_devops": "Environment approval checks",
        "github_actions": "environment protection rules",
        "jenkins_cloud": "input step (retain temporarily)",
        "decision": "Migrate to ADO",
    },
    {
        "legacy_tool": "Bamboo",
        "legacy_concept": "plan > stage > job > task",
        "azure_devops": "stage > job > step",
        "github_actions": "job > step",
        "jenkins_cloud": "declarative stages",
        "decision": "Migrate to ADO",
    },
    {
        "legacy_tool": "Bamboo",
        "legacy_concept": "deployment project / environment",
        "azure_devops": "YAML deployment job + environment",
        "github_actions": "environment: production",
        "jenkins_cloud": "Deploy plugin",
        "decision": "Migrate to ADO",
    },
    {
        "legacy_tool": "GitLab",
        "legacy_concept": "tags: onprem-linux-runner",
        "azure_devops": "pool: ado-selfhosted-linux",
        "github_actions": "runs-on: [self-hosted, linux]",
        "jenkins_cloud": "Static agent or K8s",
        "decision": "Migrate to ADO",
    },
    {
        "legacy_tool": "GitLab",
        "legacy_concept": "only/needs/rules",
        "azure_devops": "conditions / dependsOn",
        "github_actions": "if / needs",
        "jenkins_cloud": "when { } blocks",
        "decision": "Migrate to ADO",
    },
    {
        "legacy_tool": "All",
        "legacy_concept": "SSH VM deploy",
        "azure_devops": "AzureWebAppContainer@1 / ACA deploy",
        "github_actions": "azure/webapps-deploy or az containerapp",
        "jenkins_cloud": "Retire SSH — container platform",
        "decision": "Retire pattern",
    },
]


def write_csv(records: list[PipelineRecord], mapping: list[dict[str, str]]) -> None:
    REPORTS.mkdir(parents=True, exist_ok=True)
    inv_csv = REPORTS / "module-b-pipeline-inventory.csv"
    with inv_csv.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(
            f,
            fieldnames=[
                "id", "tool", "name", "source_control", "runner_agent", "build_tool",
                "secrets_refs", "artifact_store", "deployment_method", "target_environments",
                "approvals", "risk_level", "risk_notes", "file_path",
            ],
        )
        w.writeheader()
        for r in records:
            row = asdict(r)
            row["secrets_refs"] = "; ".join(row["secrets_refs"])
            row["target_environments"] = "; ".join(row["target_environments"])
            row["risk_notes"] = "; ".join(row["risk_notes"])
            w.writerow(row)

    map_csv = REPORTS / "module-b-migration-mapping-matrix.csv"
    with map_csv.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(
            f,
            fieldnames=[
                "legacy_tool", "legacy_concept", "azure_devops",
                "github_actions", "jenkins_cloud", "decision",
            ],
        )
        w.writeheader()
        w.writerows(mapping)


def main() -> None:
    records = [
        analyze_jenkins(_read(LEGACY / "jenkins" / "Jenkinsfile"), "legacy-ci/jenkins/Jenkinsfile"),
        analyze_bamboo(_read(LEGACY / "bamboo" / "bamboo-specs.yaml"), "legacy-ci/bamboo/bamboo-specs.yaml"),
        analyze_gitlab(_read(LEGACY / "gitlab" / ".gitlab-ci.yml"), "legacy-ci/gitlab/.gitlab-ci.yml"),
    ]
    payload: dict[str, Any] = {
        "summary": {
            "total_pipelines": len(records),
            "high_risk_count": sum(1 for r in records if r.risk_level == "High"),
            "tools": list({r.tool for r in records}),
        },
        "pipelines": [asdict(r) for r in records],
        "migration_mapping": MAPPING_ROWS,
    }
    REPORTS.mkdir(parents=True, exist_ok=True)
    out_json = REPORTS / "module-b-pipeline-inventory.json"
    out_json.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    write_csv(records, MAPPING_ROWS)
    print(f"Wrote {out_json}")
    print(f"Wrote {REPORTS / 'module-b-pipeline-inventory.csv'}")
    print(f"Wrote {REPORTS / 'module-b-migration-mapping-matrix.csv'}")


if __name__ == "__main__":
    main()
