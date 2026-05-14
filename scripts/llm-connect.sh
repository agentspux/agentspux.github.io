#!/usr/bin/env bash
# <SPUX_MANIFEST>
# ID: llm-connect
# Title: LLM Provider Connector
# Author: rarnado
# Description: Stores API keys for Claude, OpenAI, and Gemini in ~/.spux/config/providers.json.
# Platform: macOS | Linux
# </SPUX_MANIFEST>
set -euo pipefail

SPUX_HOME="${SPUX_HOME:-$HOME/.spux}"
SPUX_REPO_RAW="${SPUX_REPO_RAW:-https://raw.githubusercontent.com/agentspux/agentspux.github.io/main}"
_ui_local="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)/../.spux-utils/ui.sh"
if [ -f "$_ui_local" ]; then source "$_ui_local"
else _t="$(mktemp -t spux-ui.XXXXXX)"; curl -fsSL "$SPUX_REPO_RAW/.spux-utils/ui.sh" -o "$_t"; source "$_t"; fi

spux::header "LLM Provider Connector" "Store API keys for your favorite models."

mkdir -p "$SPUX_HOME/config"
PROVIDERS_FILE="$SPUX_HOME/config/providers.json"
[ -f "$PROVIDERS_FILE" ] || echo "{}" > "$PROVIDERS_FILE"
chmod 600 "$PROVIDERS_FILE"

prompt_key() {
  local provider="$1" env_var="$2" url="$3"
  spux::section "$provider"
  spux::muted "  Get a key: $url"
  printf "${SPUX_BOLD}? %s API key${SPUX_RESET} ${SPUX_DIM}(blank to skip)${SPUX_RESET}: " "$provider"
  # silent input
  stty -echo 2>/dev/null || true
  read -r key
  stty echo 2>/dev/null || true
  echo
  if [ -n "$key" ]; then
    # Update JSON without jq dep — write a minimal json file each time.
    local tmp="$PROVIDERS_FILE.tmp"
    python3 - "$PROVIDERS_FILE" "$provider" "$key" "$env_var" <<'PY' > "$tmp"
import json, sys
path, provider, key, env_var = sys.argv[1:]
data = json.load(open(path))
data[provider] = {"api_key": key, "env": env_var}
json.dump(data, sys.stdout, indent=2)
PY
    mv "$tmp" "$PROVIDERS_FILE"
    chmod 600 "$PROVIDERS_FILE"
    spux::success "$provider key saved."
  else
    spux::muted "  Skipped."
  fi
}

prompt_key "anthropic" "ANTHROPIC_API_KEY" "https://console.anthropic.com/settings/keys"
prompt_key "openai"    "OPENAI_API_KEY"    "https://platform.openai.com/api-keys"
prompt_key "google"    "GEMINI_API_KEY"    "https://aistudio.google.com/apikey"

# Generate a sourceable env file
ENV_FILE="$SPUX_HOME/config/providers.env"
python3 - "$PROVIDERS_FILE" <<'PY' > "$ENV_FILE"
import json, sys
data = json.load(open(sys.argv[1]))
for name, cfg in data.items():
    print(f'export {cfg["env"]}="{cfg["api_key"]}"')
PY
chmod 600 "$ENV_FILE"

# Wire into shell rc
rc=""
case "${SHELL:-}" in
  *zsh)  rc="$HOME/.zshrc" ;;
  *bash) rc="$HOME/.bashrc" ;;
esac
if [ -n "$rc" ] && ! grep -q 'spux/config/providers.env' "$rc" 2>/dev/null; then
  echo "[ -f \"\$HOME/.spux/config/providers.env\" ] && source \"\$HOME/.spux/config/providers.env\"" >> "$rc"
  spux::info "Patched $rc to export keys on shell start"
fi

spux::footer "Providers configured. Open a new shell or run: source $ENV_FILE"
