#!/usr/bin/env bash
# Step 0.6 — Install local toolchain on macOS (Homebrew)
set -euo pipefail

setup_brew() {
  if command -v brew &>/dev/null; then
    return 0
  fi
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    return 0
  fi
  if [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
    return 0
  fi
  return 1
}

brew_install() {
  local pkg="$1"
  if brew list "$pkg" &>/dev/null 2>&1; then
    echo "Already installed: $pkg"
    return 0
  fi
  echo "Installing: $pkg ..."
  brew install "$pkg"
}

install_terraform() {
  if command -v terraform &>/dev/null; then
    echo "Already installed: terraform ($(terraform version -json 2>/dev/null | head -1 || terraform version | head -1))"
    return 0
  fi
  echo "Installing: terraform (HashiCorp tap) ..."
  brew tap hashicorp/tap 2>/dev/null || brew tap hashicorp/tap
  brew install hashicorp/tap/terraform
}

if ! setup_brew; then
  cat <<'EOF'
Homebrew is not installed. See docs/PHASE0_PERSONAL_MAC_ADMIN.md
EOF
  exit 1
fi

echo "=== Using $(brew --version | head -1) ==="
brew update

# Core formulae (terraform is separate — removed from default Homebrew core)
for pkg in git azure-cli kubectl helm trivy openjdk@17; do
  brew_install "$pkg" || echo "WARN: failed to install $pkg"
done

install_terraform || echo "WARN: terraform install failed — use ~/.local/bin from install-local-tools-no-admin.sh"

if brew list --cask docker &>/dev/null 2>&1; then
  echo "Already installed: docker (cask)"
else
  echo "Installing Docker Desktop (cask)..."
  brew install --cask docker || echo "WARN: docker cask install failed"
fi

JAVA_PREFIX="$(brew --prefix openjdk@17 2>/dev/null || true)"
if [ -n "$JAVA_PREFIX" ]; then
  PROFILE="${HOME}/.zprofile"
  touch "$PROFILE"
  grep -q 'openjdk@17' "$PROFILE" 2>/dev/null || cat >> "$PROFILE" <<EOF

# Java 17 (assessment)
export PATH="$JAVA_PREFIX/bin:\$PATH"
export JAVA_HOME="$JAVA_PREFIX"
EOF
  echo "Java 17 PATH added to $PROFILE"
fi

echo ""
echo "=== Next steps ==="
echo "  eval \"\$(/opt/homebrew/bin/brew shellenv)\""
echo "  open -a Docker    # wait until Docker is running"
echo "  az login"
echo "  ./scripts/check-prerequisites.sh | tee reports/phase0-local-toolchain-evidence.txt"
