#!/usr/bin/env bash
# <SPUX_MANIFEST>
# ID: init
# Title: SPUX Initializer
# Author: rarnado
# Description: First-time SPUX setup — installs VSCode, Cline, and the local ~/.spux config.
# Platform: macOS | Linux
# </SPUX_MANIFEST>
#
# spux-init.sh — Idempotent SPUX bootstrapper.
# Run via:  curl -sL get.agentspux.ai/init | bash
#       or: ./spux-init.sh

set -euo pipefail

# -----------------------------------------------------------------------------
# Load shared UI helpers — supports both local and remote (curl|bash) execution
# -----------------------------------------------------------------------------
SPUX_VERSION="0.1.0"
SPUX_HOME="${SPUX_HOME:-$HOME/.spux}"
SPUX_REPO_RAW="${SPUX_REPO_RAW:-https://raw.githubusercontent.com/agentspux/agentspux.github.io/main}"

_load_ui() {
  local local_ui
  local_ui="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)/.spux-utils/ui.sh"
  if [ -f "$local_ui" ]; then
    # shellcheck source=/dev/null
    source "$local_ui"
  else
    local tmp; tmp="$(mktemp -t spux-ui.XXXXXX)"
    curl -fsSL "$SPUX_REPO_RAW/.spux-utils/ui.sh" -o "$tmp" || {
      echo "Failed to fetch SPUX UI helpers" >&2; exit 1;
    }
    # shellcheck source=/dev/null
    source "$tmp"
  fi
}
_load_ui

# -----------------------------------------------------------------------------
# Steps
# -----------------------------------------------------------------------------
TOTAL_STEPS=6
STEP=0

next_step() {
  STEP=$((STEP + 1))
  spux::section "Step $STEP/$TOTAL_STEPS · $1"
}

ensure_spux_home() {
  next_step "Preparing ~/.spux"
  mkdir -p "$SPUX_HOME"/{bin,scripts,cache,logs,config}
  if [ ! -f "$SPUX_HOME/config/spux.json" ]; then
    cat > "$SPUX_HOME/config/spux.json" <<EOF
{
  "version": "$SPUX_VERSION",
  "installed_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "os": "$(spux::os)",
  "registry": "$SPUX_REPO_RAW/registry/registry.json",
  "providers": {}
}
EOF
    spux::success "Created $SPUX_HOME with default config"
  else
    spux::info "$SPUX_HOME already initialized — skipping"
  fi
}

detect_environment() {
  next_step "Detecting environment"
  local os; os="$(spux::os)"
  spux::info "OS:        $os"
  spux::info "Shell:     ${SHELL:-unknown}"
  spux::info "Arch:      $(uname -m)"
  spux::has curl  && spux::success "curl  present" || spux::warn "curl missing"
  spux::has git   && spux::success "git   present" || spux::warn "git missing"
  spux::has node  && spux::success "node  present ($(node --version 2>/dev/null))" || spux::muted "node  not found (optional)"
  spux::has code  && spux::success "code  present" || spux::muted "code  not yet installed"
}

install_vscode() {
  next_step "Installing VSCode (if needed)"
  if spux::has code; then
    spux::success "VSCode already installed"
    return 0
  fi

  local os; os="$(spux::os)"
  case "$os" in
    macOS)
      if spux::has brew; then
        spux::confirm "Install VSCode via Homebrew?" || { spux::warn "Skipped VSCode"; return 0; }
        spux::spin "brew install --cask visual-studio-code" -- brew install --cask visual-studio-code
      else
        spux::warn "Homebrew not found. Install from https://code.visualstudio.com/"
      fi
      ;;
    Linux)
      if spux::has apt-get; then
        spux::confirm "Install VSCode via apt? (requires sudo)" || { spux::warn "Skipped VSCode"; return 0; }
        spux::sudo apt-get update -y
        spux::sudo apt-get install -y wget gpg
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
        spux::sudo install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
        echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | spux::sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
        spux::sudo apt-get update -y
        spux::sudo apt-get install -y code
      else
        spux::warn "No supported package manager. Install VSCode manually: https://code.visualstudio.com/"
      fi
      ;;
    *)
      spux::warn "Automatic install not supported on $os. Install VSCode manually."
      ;;
  esac
}

install_cline() {
  next_step "Installing Cline extension"
  if ! spux::has code; then
    spux::warn "Skipping Cline — VSCode CLI ('code') not on PATH."
    spux::muted "  Open VSCode → Cmd/Ctrl+Shift+P → 'Shell Command: Install code in PATH'"
    return 0
  fi
  if code --list-extensions 2>/dev/null | grep -qi "saoudrizwan.claude-dev"; then
    spux::success "Cline already installed"
  else
    spux::spin "Installing saoudrizwan.claude-dev" -- code --install-extension saoudrizwan.claude-dev --force
  fi
}

install_spux_cli() {
  next_step "Installing the spux CLI"
  local cli="$SPUX_HOME/bin/spux"
  cat > "$cli" <<'CLI_EOF'
#!/usr/bin/env bash
# spux — minimal CLI dispatcher for the SPUX registry.
set -euo pipefail
SPUX_HOME="${SPUX_HOME:-$HOME/.spux}"
SPUX_REPO_RAW="${SPUX_REPO_RAW:-https://raw.githubusercontent.com/agentspux/agentspux.github.io/main}"

usage() {
  cat <<USAGE
SPUX — The Agentic Toolbox for the rest of us.

Usage:
  spux run <alias>     Run a script from the registry
  spux list            List available aliases
  spux info <alias>    Show manifest for a script
  spux update          Refresh the local registry cache
  spux version         Print SPUX version

Examples:
  spux run proxy
  spux run llm-connect
USAGE
}

_fetch_registry() {
  local cache="$SPUX_HOME/cache/registry.json"
  mkdir -p "$(dirname "$cache")"
  if [ ! -f "$cache" ] || [ "${1:-}" = "--force" ]; then
    curl -fsSL "$SPUX_REPO_RAW/registry/registry.json" -o "$cache"
  fi
  echo "$cache"
}

_resolve() {
  local alias="$1"
  local reg; reg="$(_fetch_registry)"
  # naive JSON extraction — avoids jq dep
  local path
  path="$(grep -E "\"$alias\"[[:space:]]*:" "$reg" | head -1 | sed -E 's/.*:[[:space:]]*"([^"]+)".*/\1/')"
  [ -z "$path" ] && { echo "Unknown alias: $alias" >&2; exit 1; }
  echo "$SPUX_REPO_RAW/$path"
}

cmd="${1:-}"; shift || true
case "$cmd" in
  run)     [ $# -lt 1 ] && { usage; exit 1; }
           url="$(_resolve "$1")"
           curl -fsSL "$url" | bash ;;
  list)    reg="$(_fetch_registry)"
           grep -E '"[a-z0-9_-]+"[[:space:]]*:' "$reg" | sed -E 's/.*"([a-z0-9_-]+)".*/  • \1/' ;;
  info)    [ $# -lt 1 ] && { usage; exit 1; }
           url="$(_resolve "$1")"
           curl -fsSL "$url" | sed -n '/<SPUX_MANIFEST>/,/<\/SPUX_MANIFEST>/p' ;;
  update)  _fetch_registry --force >/dev/null && echo "Registry refreshed." ;;
  version) echo "spux 0.1.0" ;;
  ""|-h|--help|help) usage ;;
  *) echo "Unknown command: $cmd" >&2; usage; exit 1 ;;
esac
CLI_EOF
  chmod +x "$cli"
  spux::success "Installed $cli"

  # PATH wiring
  local rc=""
  case "${SHELL:-}" in
    *zsh)  rc="$HOME/.zshrc" ;;
    *bash) rc="$HOME/.bashrc" ;;
  esac
  if [ -n "$rc" ] && ! grep -q 'SPUX_HOME' "$rc" 2>/dev/null; then
    {
      echo ""
      echo "# >>> SPUX >>>"
      echo "export SPUX_HOME=\"\$HOME/.spux\""
      echo "export PATH=\"\$SPUX_HOME/bin:\$PATH\""
      echo "# <<< SPUX <<<"
    } >> "$rc"
    spux::info "Added SPUX to PATH in $rc"
    spux::muted "  Restart your shell or run:  source $rc"
  fi
}

finish() {
  spux::footer "SPUX is ready."
  cat <<EOF
  Try it out:
    ${SPUX_BOLD}spux list${SPUX_RESET}            see available tools
    ${SPUX_BOLD}spux run proxy${SPUX_RESET}       run an example script
    ${SPUX_BOLD}spux --help${SPUX_RESET}          full CLI help

  Dashboard:  https://agentspux.ai
  Repo:       https://github.com/agentspux/agentspux.github.io

EOF
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
spux::header "SPUX Initializer · v$SPUX_VERSION" "Setting up your agentic toolbox…"
ensure_spux_home
detect_environment
install_vscode
install_cline
install_spux_cli
next_step "Wrapping up"
spux::success "All steps completed."
finish
