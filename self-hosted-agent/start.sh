#!/bin/bash
set -euo pipefail

: "${AZP_URL:?Set AZP_URL}"
: "${AZP_TOKEN:?Set AZP_TOKEN (PAT with Agent Pools read/manage)}"
: "${AZP_POOL:=ado-selfhosted-linux}"
: "${AZP_AGENT_NAME:=docker-agent-$(hostname)}"

cd /azp/agent

# Agent binaries are pre-installed in the image; only register once per container volume
if [ ! -f .agent ]; then
  ./config.sh --unattended \
    --url "$AZP_URL" \
    --auth pat \
    --token "$AZP_TOKEN" \
    --pool "$AZP_POOL" \
    --agent "$AZP_AGENT_NAME" \
    --acceptTeeEula \
    --replace
fi

exec ./run.sh
