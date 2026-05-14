#!/usr/bin/env bash
# <SPUX_MANIFEST>
# ID: proxy
# Title: Local Proxy Setup
# Author: rarnado
# Description: Configures a local HTTP/HTTPS proxy for development.
# Platform: macOS | Linux
# </SPUX_MANIFEST>
set -euo pipefail

SPUX_HOME="${SPUX_HOME:-$HOME/.spux}"
SPUX_REPO_RAW="${SPUX_REPO_RAW:-https://raw.githubusercontent.com/agentspux/agentspux.github.io/main}"

# Source UI helpers (local or remote)
_ui_local="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)/../.spux-utils/ui.sh"
if [ -f "$_ui_local" ]; then source "$_ui_local"
else _t="$(mktemp -t spux-ui.XXXXXX)"; curl -fsSL "$SPUX_REPO_RAW/.spux-utils/ui.sh" -o "$_t"; source "$_t"; fi

spux::header "Local Proxy Setup" "Wire your shell + git to a development proxy."

DEFAULT_PROXY="http://127.0.0.1:8080"
read -r -p "$(printf '? Proxy URL [%s]: ' "$DEFAULT_PROXY")" proxy
proxy="${proxy:-$DEFAULT_PROXY}"

spux::section "Applying proxy: $proxy"

# 1. Persist to ~/.spux/config/proxy.env
mkdir -p "$SPUX_HOME/config"
cat > "$SPUX_HOME/config/proxy.env" <<EOF
export HTTP_PROXY="$proxy"
export HTTPS_PROXY="$proxy"
export http_proxy="$proxy"
export https_proxy="$proxy"
export NO_PROXY="localhost,127.0.0.1,::1"
EOF
spux::success "Wrote $SPUX_HOME/config/proxy.env"

# 2. Configure git
if spux::has git; then
  git config --global http.proxy  "$proxy"
  git config --global https.proxy "$proxy"
  spux::success "Configured git proxy"
fi

# 3. Configure npm
if spux::has npm; then
  npm config set proxy "$proxy"     >/dev/null
  npm config set https-proxy "$proxy" >/dev/null
  spux::success "Configured npm proxy"
fi

# 4. Shell hint
rc=""
case "${SHELL:-}" in
  *zsh)  rc="$HOME/.zshrc" ;;
  *bash) rc="$HOME/.bashrc" ;;
esac
if [ -n "$rc" ] && ! grep -q 'spux/config/proxy.env' "$rc" 2>/dev/null; then
  echo "[ -f \"\$HOME/.spux/config/proxy.env\" ] && source \"\$HOME/.spux/config/proxy.env\"" >> "$rc"
  spux::info "Patched $rc to load proxy.env on shell start"
fi

spux::footer "Proxy configured. Open a new shell to apply."
