#!/usr/bin/env bash
# Install Homebrew on macOS (Apple Silicon or Intel)
set -euo pipefail

if command -v brew &>/dev/null; then
  echo "Homebrew already installed: $(brew --version | head -1)"
  exit 0
fi

if [ -x /opt/homebrew/bin/brew ]; then
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile 2>/dev/null || true
  eval "$(/opt/homebrew/bin/brew shellenv)"
  echo "Homebrew found at /opt/homebrew — added to current shell."
  exit 0
fi

echo "=== Homebrew installer ==="
echo "This will prompt for your Mac password."
echo ""
read -r -p "Continue? [y/N] " ans
if [[ ! "$ans" =~ ^[Yy]$ ]]; then
  echo "Cancelled. Install manually: https://brew.sh"
  exit 1
fi

# Interactive install (allows password prompt; requires Administrator account)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Apple Silicon default path
if [ -x /opt/homebrew/bin/brew ]; then
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/usr/local/bin/brew shellenv)"
fi

echo ""
echo "Homebrew installed. Restart terminal or run:"
echo '  eval "$(/opt/homebrew/bin/brew shellenv)"'
echo "Then: ./scripts/install-local-tools-macos.sh"
