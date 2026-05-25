#!/bin/bash
set -euo pipefail

: "${AZP_URL:?Set AZP_URL}"
: "${AZP_TOKEN:?Set AZP_TOKEN (PAT with Agent Pools read/manage)}"
: "${AZP_POOL:=ado-selfhosted-linux}"
: "${AZP_AGENT_NAME:=docker-agent-$(hostname)}"

if [ ! -f /azp/agent/config.sh ]; then
  mkdir -p /azp/agent
  cd /azp/agent
  curl -sSL -o agent.tar.gz "https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION:-3.232.0}/vsts-agent-linux-x64-${AGENT_VERSION:-3.232.0}.tar.gz"
  tar -xzf agent.tar.gz && rm agent.tar.gz
  ./config.sh --unattended \
    --url "$AZP_URL" \
    --auth pat \
    --token "$AZP_TOKEN" \
    --pool "$AZP_POOL" \
    --agent "$AZP_AGENT_NAME" \
    --acceptTeeEula \
    --replace
fi

cd /azp/agent
exec ./run.sh
