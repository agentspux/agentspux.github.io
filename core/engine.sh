#!/usr/bin/env bash
# core/engine.sh — SPUX-Engine
# Lightweight environment-detection + capability probe used by SPUX scripts and
# by the dashboard's status monitor (called via `core/engine.sh status --json`).
set -euo pipefail

_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
# shellcheck source=/dev/null
source "$_dir/../.spux-utils/ui.sh"

cmd="${1:-status}"
fmt="text"
[[ "${2:-}" == "--json" ]] && fmt="json"

probe() {
  local name="$1" check="$2"
  if eval "$check" >/dev/null 2>&1; then echo "ok"; else echo "missing"; fi
}

collect() {
  os="$(spux::os)"
  vscode=$(probe "vscode" "command -v code")
  cline="missing"
  if [ "$vscode" = "ok" ]; then
    code --list-extensions 2>/dev/null | grep -qi "saoudrizwan.claude-dev" && cline="ok"
  fi
  proxy="missing"
  [ -f "$HOME/.spux/config/proxy.env" ] && proxy="ok"
  providers="missing"
  [ -f "$HOME/.spux/config/providers.json" ] && [ "$(wc -c < "$HOME/.spux/config/providers.json")" -gt 5 ] && providers="ok"
  spux_cli=$(probe "spux" "command -v spux")
}

case "$cmd" in
  status)
    collect
    if [ "$fmt" = "json" ]; then
      cat <<EOF
{
  "os": "$os",
  "vscode": "$vscode",
  "cline": "$cline",
  "spux_cli": "$spux_cli",
  "proxy": "$proxy",
  "providers": "$providers"
}
EOF
    else
      spux::header "SPUX Status"
      printf "  OS:        %s\n" "$os"
      printf "  VSCode:    %s\n" "$vscode"
      printf "  Cline:     %s\n" "$cline"
      printf "  spux CLI:  %s\n" "$spux_cli"
      printf "  Proxy:     %s\n" "$proxy"
      printf "  Providers: %s\n" "$providers"
      echo
    fi
    ;;
  manifest)
    # Extract SPUX_MANIFEST block from a script file.
    file="${2:-}"
    [ -z "$file" ] && { echo "Usage: engine.sh manifest <file>" >&2; exit 1; }
    sed -n '/<SPUX_MANIFEST>/,/<\/SPUX_MANIFEST>/p' "$file" | sed -E 's/^# ?//' | grep -v "SPUX_MANIFEST"
    ;;
  *)
    echo "Usage: engine.sh {status [--json] | manifest <file>}" >&2
    exit 1 ;;
esac
