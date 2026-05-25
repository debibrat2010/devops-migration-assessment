#!/usr/bin/env bash
# Install Azure CLI without Homebrew (macOS pkg)
set -euo pipefail

PKG="/tmp/AzureCLI.pkg"
echo "Downloading Azure CLI..."
curl -fsSL -o "$PKG" "https://aka.ms/installazureclimacos"

echo "Installing (may prompt for password)..."
sudo installer -pkg "$PKG" -target /
rm -f "$PKG"

echo "Installed. Run: az login"
