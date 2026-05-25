#!/usr/bin/env bash
# Step 0.6 — Install tools to ~/.local without sudo / Homebrew
set -euo pipefail

LOCAL_BIN="${HOME}/.local/bin"
LOCAL_DIR="${HOME}/.local"
mkdir -p "$LOCAL_BIN"

export PATH="${LOCAL_BIN}:${PATH}"

add_path_snippet() {
  local profile="${HOME}/.zprofile"
  [ -f "${HOME}/.bash_profile" ] && profile="${HOME}/.bash_profile"
  touch "$profile"
  if ! grep -q '.local/bin' "$profile" 2>/dev/null; then
    echo 'export PATH="${HOME}/.local/bin:${PATH}"' >> "$profile"
    echo "Added ~/.local/bin to $profile"
  fi
  if ! grep -q 'Library/Python/3.9/bin' "$profile" 2>/dev/null; then
    echo 'export PATH="${HOME}/Library/Python/3.9/bin:${PATH}"' >> "$profile"
    echo "Added Python user scripts (az) to $profile"
  fi
}

install_azure_cli() {
  if command -v az &>/dev/null; then
    echo "OK  az already installed"
    return
  fi
  echo "=== Azure CLI (pip --user) ==="
  python3 -m pip install --user --upgrade pip
  python3 -m pip install --user azure-cli
}

install_terraform() {
  if command -v terraform &>/dev/null; then
    echo "OK  terraform already installed"
    return
  fi
  echo "=== Terraform binary ==="
  ARCH="$(uname -m)"
  [ "$ARCH" = "arm64" ] && TF_ARCH="arm64" || TF_ARCH="amd64"
  TF_VER="1.9.8"
  ZIP="terraform_${TF_VER}_darwin_${TF_ARCH}.zip"
  TMP=$(mktemp -d)
  curl -fsSL "https://releases.hashicorp.com/terraform/${TF_VER}/${ZIP}" -o "${TMP}/${ZIP}"
  unzip -q "${TMP}/${ZIP}" -d "$TMP"
  mv "${TMP}/terraform" "${LOCAL_BIN}/terraform"
  chmod +x "${LOCAL_BIN}/terraform"
  rm -rf "$TMP"
}

install_kubectl() {
  if command -v kubectl &>/dev/null; then
    echo "OK  kubectl already installed"
    return
  fi
  echo "=== kubectl binary ==="
  ARCH="$(uname -m)"
  [ "$ARCH" = "arm64" ] && K_ARCH="arm64" || K_ARCH="amd64"
  curl -fsSL "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/darwin/${K_ARCH}/kubectl" \
    -o "${LOCAL_BIN}/kubectl"
  chmod +x "${LOCAL_BIN}/kubectl"
}

install_helm() {
  if command -v helm &>/dev/null; then
    echo "OK  helm already installed"
    return
  fi
  echo "=== Helm binary ==="
  ARCH="$(uname -m)"
  [ "$ARCH" = "arm64" ] && H_ARCH="arm64" || H_ARCH="amd64"
  HELM_VER="v3.16.3"
  TMP=$(mktemp -d)
  curl -fsSL "https://get.helm.sh/helm-${HELM_VER}-darwin-${H_ARCH}.tar.gz" | tar xz -C "$TMP"
  mv "${TMP}/darwin-${H_ARCH}/helm" "${LOCAL_BIN}/helm"
  chmod +x "${LOCAL_BIN}/helm"
  rm -rf "$TMP"
}

install_trivy() {
  if command -v trivy &>/dev/null; then
    echo "OK  trivy already installed"
    return
  fi
  echo "=== Trivy binary ==="
  # v0.54.1 only publishes macOS-64bit (runs on Apple Silicon via Rosetta or native binary inside)
  TRIVY_VER="0.54.1"
  TMP=$(mktemp -d)
  local url="https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VER}/trivy_${TRIVY_VER}_macOS-64bit.tar.gz"
  if ! curl -fsSL "$url" | tar xz -C "$TMP" trivy 2>/dev/null; then
    # Newer releases use macOS-ARM64
    url="https://github.com/aquasecurity/trivy/releases/download/v0.57.1/trivy_0.57.1_macOS-ARM64.tar.gz"
    curl -fsSL "$url" | tar xz -C "$TMP" trivy
  fi
  mv "${TMP}/trivy" "${LOCAL_BIN}/trivy"
  chmod +x "${LOCAL_BIN}/trivy"
  rm -rf "$TMP"
}

install_sdkman_java_maven() {
  if [ -d "${HOME}/.sdkman" ] && command -v sdk &>/dev/null; then
    echo "OK  SDKMAN present"
  else
    echo "=== SDKMAN (Java + Maven, user install) ==="
    curl -s "https://get.sdkman.io" | bash
  fi
  # shellcheck source=/dev/null
  source "${HOME}/.sdkman/bin/sdkman-init.sh"
  sdk install java 17.0.13-tem 2>/dev/null || sdk use java 17.0.13-tem 2>/dev/null || true
  sdk install maven 3.9.9 2>/dev/null || true
}

echo "=== No-admin toolchain install → ${LOCAL_BIN} ==="
add_path_snippet
install_azure_cli
install_terraform
install_kubectl
install_helm
install_trivy || echo "WARN: Trivy install failed — optional; use: brew install trivy"
install_sdkman_java_maven || echo "WARN: SDKMAN/Java optional step failed"

export PATH="${HOME}/.local/bin:${PATH}"
[ -f "${HOME}/.sdkman/bin/sdkman-init.sh" ] && source "${HOME}/.sdkman/bin/sdkman-init.sh"

cat <<EOF

=== Done (user-local installs) ===

Restart terminal or run:
  export PATH="\${HOME}/.local/bin:\${PATH}"
  [ -f "\${HOME}/.sdkman/bin/sdkman-init.sh" ] && source "\${HOME}/.sdkman/bin/sdkman-init.sh"

  az login
  cd $(pwd) && ./scripts/check-prerequisites.sh

=== Docker (requires Administrator on macOS) ===
Docker Desktop cannot install without admin. Options:
  1. Ask IT to install Docker Desktop or grant admin for one install
  2. Skip local Docker — use Azure DevOps Microsoft-hosted agents for builds
  3. Use GitHub Actions (cloud runners) in pipelines/github-actions/

Phase 0.4 service connection: use ADO portal wizard only (no az required).

EOF
