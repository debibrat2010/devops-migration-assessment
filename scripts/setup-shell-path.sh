#!/usr/bin/env bash
# Ensure az, terraform, and local bins are on PATH (run after install scripts)
set -euo pipefail

PROFILE="${HOME}/.zprofile"
touch "$PROFILE"

add_line() {
  local line="$1"
  grep -qF "$line" "$PROFILE" 2>/dev/null || echo "$line" >> "$PROFILE"
}

add_line 'export PATH="${HOME}/.local/bin:${PATH}"'
add_line 'export PATH="${HOME}/Library/Python/3.9/bin:${PATH}"'

if [ -x /opt/homebrew/bin/brew ]; then
  add_line 'eval "$(/opt/homebrew/bin/brew shellenv)"'
fi

if [ -f "${HOME}/.sdkman/bin/sdkman-init.sh" ]; then
  add_line 'source "${HOME}/.sdkman/bin/sdkman-init.sh"'
fi

# Apply now
export PATH="${HOME}/.local/bin:${HOME}/Library/Python/3.9/bin:${PATH}"
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
[ -f "${HOME}/.sdkman/bin/sdkman-init.sh" ] && source "${HOME}/.sdkman/bin/sdkman-init.sh"

echo "PATH updated. Verify:"
command -v az && az version | head -3 || echo "az not found — reopen terminal or: source ~/.zprofile"
command -v terraform && terraform version | head -1 || true
command -v kubectl && kubectl version --client 2>/dev/null | head -1 || true
