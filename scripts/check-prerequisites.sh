#!/usr/bin/env bash
# Phase 0 local toolchain check
set -euo pipefail

version_line() {
  local cmd="$1"
  shift
  if command -v "$cmd" &>/dev/null; then
    local out
    out=$("$cmd" "$@" 2>&1 | head -1) || out="present"
    echo "OK  $cmd: $out"
  else
    echo "MISSING  $cmd"
  fi
}

echo "=== DevOps Assessment — prerequisite check ==="
version_line git --version
version_line python3 --version
version_line az --version
version_line terraform version
version_line kubectl version --client
version_line helm version --short
version_line trivy --version

if command -v docker &>/dev/null; then
  echo "OK  docker: $(docker --version 2>&1 | head -1)"
else
  echo "MISSING  docker  (install: brew install --cask docker)"
fi

if java -version 2>&1 | grep -qiE 'version "[0-9]'; then
  echo "OK  java: $(java -version 2>&1 | head -1)"
else
  echo "MISSING  java  (install: brew install openjdk@17; export PATH=\"\$(brew --prefix openjdk@17)/bin:\$PATH\")"
fi

if command -v mvn &>/dev/null; then
  echo "OK  mvn: $(mvn -version 2>&1 | head -1)"
else
  echo "MISSING  mvn  (install: brew install maven)"
fi

if docker info &>/dev/null 2>&1; then
  echo "OK  docker daemon: running"
else
  if command -v docker &>/dev/null; then
    echo "WARN docker daemon: not running (open Docker Desktop: open -a Docker)"
  fi
fi

echo "=== Done ==="
