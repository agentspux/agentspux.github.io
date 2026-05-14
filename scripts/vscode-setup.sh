#!/usr/bin/env bash
# <SPUX_MANIFEST>
# ID: vscode-setup
# Title: VSCode Power-User Setup
# Author: rarnado
# Description: Installs a curated bundle of VSCode extensions for AI / agentic work.
# Platform: macOS | Linux | Windows
# </SPUX_MANIFEST>
set -euo pipefail

SPUX_REPO_RAW="${SPUX_REPO_RAW:-https://raw.githubusercontent.com/agentspux/agentspux.github.io/main}"
_ui_local="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)/../.spux-utils/ui.sh"
if [ -f "$_ui_local" ]; then source "$_ui_local"
else _t="$(mktemp -t spux-ui.XXXXXX)"; curl -fsSL "$SPUX_REPO_RAW/.spux-utils/ui.sh" -o "$_t"; source "$_t"; fi

spux::header "VSCode Power-User Setup" "Curated extensions for AI + agent work."

if ! spux::has code; then
  spux::error "VSCode CLI ('code') not found on PATH."
  spux::muted "  Open VSCode → Cmd/Ctrl+Shift+P → 'Shell Command: Install code in PATH'"
  exit 1
fi

EXTENSIONS=(
  "saoudrizwan.claude-dev"          # Cline
  "GitHub.copilot"                   # Copilot (optional, no-op if not licensed)
  "ms-python.python"                 # Python
  "ms-toolsai.jupyter"               # Jupyter
  "esbenp.prettier-vscode"           # Prettier
  "dbaeumer.vscode-eslint"           # ESLint
  "redhat.vscode-yaml"               # YAML
  "tamasfe.even-better-toml"         # TOML
  "GitHub.vscode-pull-request-github"
  "eamodio.gitlens"                  # GitLens
  "PKief.material-icon-theme"        # File icons
)

total=${#EXTENSIONS[@]}
i=0
for ext in "${EXTENSIONS[@]}"; do
  i=$((i+1))
  spux::progress "$i" "$total" "$ext"
  if code --list-extensions 2>/dev/null | grep -qi "^$ext$"; then
    continue
  fi
  code --install-extension "$ext" --force >/dev/null 2>&1 || spux::warn "Failed to install $ext"
done

spux::success "Installed/verified $total extensions."
spux::footer "VSCode is ready for agentic work."
