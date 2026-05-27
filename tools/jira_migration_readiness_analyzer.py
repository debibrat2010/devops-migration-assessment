#!/usr/bin/env python3
"""Module M — Jira Server/DC to Jira Cloud migration readiness report."""
from __future__ import annotations

import csv
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EXPORT = ROOT / "jira-export"
REPORT = ROOT / "reports" / "module-m-jira-readiness-report.md"


def read_csv(name: str) -> list[dict[str, str]]:
    path = EXPORT / name
    if not path.exists():
        return []
    with path.open(encoding="utf-8") as f:
        return list(csv.DictReader(f))


def main() -> None:
    projects = read_csv("projects.csv")
    issues = read_csv("issues_summary.csv")
    users = read_csv("users.csv")
    groups = read_csv("groups.csv")
    attachments = read_csv("attachments.csv")
    workflows = read_csv("workflows.csv")
    apps = read_csv("apps.csv")

    total_issues = sum(int(r.get("issue_count", 0) or 0) for r in projects)
    inactive_users = [u for u in users if u.get("active", "").lower() == "false"]
    incompatible_apps = [a for a in apps if a.get("cloud_compatible", "").lower() == "false"]
    attachment_gb = sum(float(r.get("total_size_gb", 0) or 0) for r in attachments)

    lines = [
        "# Jira Cloud Migration Readiness Report",
        "",
        "## Executive summary",
        "",
        f"- **Projects:** {len(projects)}",
        f"- **Total issues (approx):** {total_issues}",
        f"- **Inactive users:** {len(inactive_users)} (remediate before cutover)",
        f"- **Attachment storage:** {attachment_gb:.1f} GB",
        f"- **Incompatible/migration-risk apps:** {len(incompatible_apps)}",
        "",
        "## Project inventory",
        "",
        "| Key | Name | Issues |",
        "|-----|------|--------|",
    ]
    for p in projects:
        lines.append(f"| {p['project_key']} | {p['project_name']} | {p['issue_count']} |")

    lines.extend([
        "",
        "## Issue volumes by type/status",
        "",
        "| Project | Type | Status | Count |",
        "|---------|------|--------|-------|",
    ])
    for i in issues:
        lines.append(f"| {i['project_key']} | {i['issue_type']} | {i['status']} | {i['count']} |")

    lines.extend([
        "",
        "## Users and groups",
        "",
        f"- Active users: {sum(1 for u in users if u.get('active') == 'true')}",
        f"- Inactive accounts to exclude: {', '.join(u['username'] for u in inactive_users)}",
        f"- Groups: {len(groups)} (review `inactive-contractors` membership)",
        "",
        "## Workflows and customizations",
        "",
    ])
    for w in workflows:
        lines.append(f"- **{w['project_key']}** — {w['workflow_name']}: {w['custom_status_count']} statuses, approval={w['has_approval_step']}")

    lines.extend([
        "",
        "## App compatibility (JCMA pre-check)",
        "",
        "| App | Cloud compatible | Notes |",
        "|-----|------------------|-------|",
    ])
    for a in apps:
        lines.append(f"| {a['app_name']} | {a['cloud_compatible']} | {a['notes']} |")

    lines.extend([
        "",
        "## Migration waves",
        "",
        "| Wave | Scope | Duration | Rollback boundary |",
        "|------|-------|----------|-------------------|",
        "| 0 | Pre-migration: user cleanup, app assessment, test JCMA | 2 weeks | N/A |",
        "| 1 | INFRA + REL (low complexity) | 1 week | Restore DC backup snapshot |",
        "| 2 | DEVOPS project | 2 weeks | Wave 1 unchanged |",
        "| 3 | PET (PetClinic) — highest volume | 3 weeks | Per-project export rollback |",
        "| 4 | Hypercare | 2 weeks | Forward-only fixes |",
        "",
        "## JCMA-style cutover plan",
        "",
        "1. **Pre-checks:** User/group sync, app compatibility, attachment size limits",
        "2. **Test migration:** Clone PET project to sandbox cloud site",
        "3. **UAT:** Product owners validate workflows and dashboards",
        "4. **Production cutover:** Maintenance window, freeze writes, run JCMA, DNS/URL switch",
        "5. **Rollback boundary:** If critical workflow failure within 24h, revert DNS to DC; data delta manual",
        "6. **Hypercare:** Dedicated channel, Sev1 < 1h response for 14 days",
        "",
        "## Integrations after migration",
        "",
        "- **Azure DevOps:** bi-directional work item linking (AB# keys)",
        "- **GitHub:** Jira development panel via GitHub for Jira app",
        "- **ServiceNow:** Change requests reference Jira Cloud change keys",
        "- **Azure Pipelines:** Deployment gates publish build evidence to Jira release tickets",
        "",
        "## Risks",
        "",
        "- ScriptRunner customizations require rebuild",
        "- Large PET attachments may extend migration window",
        "- Service accounts (`svc-jenkins`, `svc-bamboo`) need cloud API tokens",
        "",
    ])

    REPORT.parent.mkdir(parents=True, exist_ok=True)
    REPORT.write_text("\n".join(lines), encoding="utf-8")
    print(f"Wrote {REPORT}")


if __name__ == "__main__":
    main()
