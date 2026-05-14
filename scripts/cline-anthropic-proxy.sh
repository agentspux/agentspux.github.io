#!/usr/bin/env bash
# <SPUX_MANIFEST>
# ID: cline-anthropic-proxy
# Title: Cline + Anthropic via Salesforce Bedrock Proxy
# Author: rarnado
# Description: One-shot installer for VSCode + Cline configured to talk to Claude through a local SF Bedrock proxy on :9999.
# Platform: macOS
# </SPUX_MANIFEST>
# =============================================================================
#  cline-anthropic-proxy.sh  (formerly install-cline.sh)
#
#  One-shot installer that sets up Cline in VS Code on macOS, configured to
#  talk to Claude through a local Salesforce Bedrock proxy on port 9999.
#
#  Usage (from a public GitHub raw URL):
#     curl -fsSL https://raw.githubusercontent.com/<user>/<repo>/main/install-cline.sh | bash
#
#  Or run interactively:
#     bash install-cline.sh
#
#  What it does:
#    1. Verifies you're on macOS
#    2. Installs Homebrew (if missing)
#    3. Installs Node.js (if missing)
#    4. Installs VS Code (if missing) via Homebrew Cask
#    5. Installs the Cline extension
#    6. Verifies ~/sf-bedrock-proxy/proxy.js exists
#    7. Prompts for your Anthropic key
#    8. Adds the auto-start proxy block to ~/.zshrc
#    9. Starts the proxy and verifies it
#   10. Prints next steps for connecting Cline in VS Code
#
#  This script is idempotent — safe to run multiple times.
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Pretty logging helpers
# -----------------------------------------------------------------------------
if [[ -t 1 ]]; then
  C_RESET=$'\033[0m'; C_BOLD=$'\033[1m'
  C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'; C_RED=$'\033[31m'; C_BLUE=$'\033[34m'
else
  C_RESET=""; C_BOLD=""; C_GREEN=""; C_YELLOW=""; C_RED=""; C_BLUE=""
fi

info()    { printf "%s[i]%s %s\n" "$C_BLUE"   "$C_RESET" "$*"; }
ok()      { printf "%s[✓]%s %s\n" "$C_GREEN"  "$C_RESET" "$*"; }
warn()    { printf "%s[!]%s %s\n" "$C_YELLOW" "$C_RESET" "$*"; }
err()     { printf "%s[✗]%s %s\n" "$C_RED"    "$C_RESET" "$*" >&2; }
heading() { printf "\n%s%s== %s ==%s\n" "$C_BOLD" "$C_BLUE" "$*" "$C_RESET"; }

trap 'err "Installation failed on line $LINENO. Check the output above."' ERR

# -----------------------------------------------------------------------------
# 0. Pre-flight: macOS check
# -----------------------------------------------------------------------------
heading "Pre-flight checks"

if [[ "$(uname -s)" != "Darwin" ]]; then
  err "This installer currently supports macOS only."
  exit 1
fi
ok "Running on macOS."

# Detect Apple Silicon vs Intel for Homebrew path
if [[ "$(uname -m)" == "arm64" ]]; then
  BREW_PREFIX="/opt/homebrew"
else
  BREW_PREFIX="/usr/local"
fi

# -----------------------------------------------------------------------------
# 1. Homebrew
# -----------------------------------------------------------------------------
heading "Step 1/8 — Homebrew"

if ! command -v brew >/dev/null 2>&1; then
  info "Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$("$BREW_PREFIX/bin/brew" shellenv)"
  ok "Homebrew installed."
else
  ok "Homebrew already installed."
fi

# -----------------------------------------------------------------------------
# 2. Node.js
# -----------------------------------------------------------------------------
heading "Step 2/8 — Node.js"

if ! command -v node >/dev/null 2>&1; then
  info "Node.js not found. Installing via Homebrew..."
  brew install node
  ok "Node.js installed: $(node --version)"
else
  ok "Node.js already installed: $(node --version)"
fi

# -----------------------------------------------------------------------------
# 3. Visual Studio Code
# -----------------------------------------------------------------------------
heading "Step 3/8 — Visual Studio Code"

if ! command -v code >/dev/null 2>&1; then
  if [[ -d "/Applications/Visual Studio Code.app" ]]; then
    warn "VS Code is installed but the 'code' CLI isn't on your PATH."
    info "Open VS Code → Cmd+Shift+P → 'Shell Command: Install 'code' command in PATH'."
  else
    info "VS Code not found. Installing via Homebrew Cask..."
    brew install --cask visual-studio-code
    ok "VS Code installed."
  fi
else
  ok "VS Code already installed."
fi

# -----------------------------------------------------------------------------
# 4. Cline extension
# -----------------------------------------------------------------------------
heading "Step 4/8 — Cline extension"

if command -v code >/dev/null 2>&1; then
  if code --list-extensions 2>/dev/null | grep -qi "saoudrizwan.claude-dev"; then
    ok "Cline extension already installed."
  else
    info "Installing Cline extension..."
    code --install-extension saoudrizwan.claude-dev --force
    ok "Cline extension installed."
  fi
else
  warn "Skipping Cline extension install — 'code' CLI not available."
  warn "After installing the 'code' CLI, run: code --install-extension saoudrizwan.claude-dev"
fi

# -----------------------------------------------------------------------------
# 5. Verify proxy file
# -----------------------------------------------------------------------------
heading "Step 5/8 — Salesforce proxy file"

PROXY_PATH="$HOME/sf-bedrock-proxy/proxy.js"
if [[ ! -f "$PROXY_PATH" ]]; then
  err "Proxy file not found at: $PROXY_PATH"
  err "Please obtain the 'sf-bedrock-proxy' folder from your team and place it at:"
  err "    $HOME/sf-bedrock-proxy/"
  err "Then re-run this installer."
  exit 1
fi
ok "Proxy file found at: $PROXY_PATH"

# -----------------------------------------------------------------------------
# 6. Anthropic key
# -----------------------------------------------------------------------------
heading "Step 6/8 — Anthropic key"

# Allow the key to be provided non-interactively via env var
ANTHROPIC_KEY="${ANTHROPIC_AUTH_TOKEN:-}"

if [[ -z "$ANTHROPIC_KEY" ]]; then
  # Need a TTY to prompt; if piped (curl | bash), fall back to /dev/tty.
  if [[ -t 0 ]]; then
    INPUT_FD=0
  elif [[ -r /dev/tty ]]; then
    INPUT_FD=3
    exec 3</dev/tty
  else
    err "No interactive terminal available."
    err "Re-run with: ANTHROPIC_AUTH_TOKEN=sk-ant-... bash install-cline.sh"
    exit 1
  fi

  printf "%sPaste your Anthropic key%s (input hidden): " "$C_BOLD" "$C_RESET"
  IFS= read -rs -u "$INPUT_FD" ANTHROPIC_KEY
  printf "\n"
fi

if [[ -z "$ANTHROPIC_KEY" ]]; then
  err "No Anthropic key provided. Aborting."
  exit 1
fi
ok "Anthropic key captured (length: ${#ANTHROPIC_KEY})."

# -----------------------------------------------------------------------------
# 7. Update ~/.zshrc with auto-start proxy block
# -----------------------------------------------------------------------------
heading "Step 7/8 — Configure ~/.zshrc"

ZSHRC="$HOME/.zshrc"
MARK_BEGIN="# >>> sf-bedrock-proxy (cline) >>>"
MARK_END="# <<< sf-bedrock-proxy (cline) <<<"

touch "$ZSHRC"

# Back up before editing
BACKUP="$ZSHRC.cline.bak.$(date +%Y%m%d-%H%M%S)"
cp "$ZSHRC" "$BACKUP"
info "Backed up existing ~/.zshrc to: $BACKUP"

# Remove any previous block we wrote
if grep -q "$MARK_BEGIN" "$ZSHRC"; then
  info "Removing previous sf-bedrock-proxy block from ~/.zshrc..."
  # Use awk to strip the block between markers (inclusive)
  awk -v b="$MARK_BEGIN" -v e="$MARK_END" '
    $0 == b { skip=1; next }
    $0 == e { skip=0; next }
    !skip   { print }
  ' "$ZSHRC" > "$ZSHRC.tmp" && mv "$ZSHRC.tmp" "$ZSHRC"
fi

# Append a fresh block. Use a heredoc with a quoted delimiter so $HOME etc.
# remain literal in the file (they'll expand at shell-load time).
{
  printf "\n%s\n" "$MARK_BEGIN"
  cat <<'ZSHRC_BLOCK'
# Managed by install-cline.sh — edits inside this block may be overwritten.

# Start the proxy ONLY if it isn't already running on :9999.
sf_bedrock_proxy_start() {
  if lsof -nP -iTCP:9999 -sTCP:LISTEN >/dev/null 2>&1; then
    return 0  # already running
  fi
  if [[ ! -f "$HOME/sf-bedrock-proxy/proxy.js" ]]; then
    return 0  # nothing to start
  fi
  ANTHROPIC_AUTH_TOKEN="__ANTHROPIC_KEY__" \
    nohup node "$HOME/sf-bedrock-proxy/proxy.js" \
      >/tmp/sf-bedrock-proxy.log 2>&1 &
  disown 2>/dev/null
}

# Auto-start the proxy on shell load (silent, idempotent).
sf_bedrock_proxy_start

# Manual command to open VS Code with the Cline profile.
cline-vscode() {
  sf_bedrock_proxy_start
  AWS_REGION="us-east-1" code --profile "Cline" "$@"
}

# Convenience: stop the proxy
sf_bedrock_proxy_stop() {
  pkill -f "$HOME/sf-bedrock-proxy/proxy.js" \
    && echo "Proxy stopped." \
    || echo "Proxy not running."
}
ZSHRC_BLOCK
  printf "%s\n" "$MARK_END"
} >> "$ZSHRC"

# Substitute the placeholder with the real key (in-place, macOS sed)
# Use a non-/ delimiter to avoid clashes with key characters
sed -i '' "s|__ANTHROPIC_KEY__|${ANTHROPIC_KEY//|/\\|}|g" "$ZSHRC"

# Lock down permissions since the file now contains a secret
chmod 600 "$ZSHRC"
ok "Wrote sf-bedrock-proxy block to ~/.zshrc (permissions set to 600)."

# -----------------------------------------------------------------------------
# 8. Start & verify the proxy
# -----------------------------------------------------------------------------
heading "Step 8/8 — Start & verify the proxy"

# Stop any old instance so the new key takes effect
pkill -f "$HOME/sf-bedrock-proxy/proxy.js" >/dev/null 2>&1 || true
sleep 1

info "Starting proxy in the background..."
ANTHROPIC_AUTH_TOKEN="$ANTHROPIC_KEY" \
  nohup node "$PROXY_PATH" \
    >/tmp/sf-bedrock-proxy.log 2>&1 &
disown 2>/dev/null || true

# Poll for up to ~10 seconds for port 9999 to come up
for i in {1..10}; do
  if lsof -nP -iTCP:9999 -sTCP:LISTEN >/dev/null 2>&1; then
    ok "Proxy is listening on http://127.0.0.1:9999"
    break
  fi
  sleep 1
  if [[ "$i" == "10" ]]; then
    err "Proxy did not start within 10 seconds."
    err "Check the log: cat /tmp/sf-bedrock-proxy.log"
    exit 1
  fi
done

# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------
heading "🎉 All set!"

cat <<EOF

${C_BOLD}Next steps — connect Cline in VS Code:${C_RESET}

  1. Open VS Code:
        ${C_GREEN}code${C_RESET}
     (or, with the proxy auto-started, run:  ${C_GREEN}cline-vscode${C_RESET})

  2. Click the ${C_BOLD}Cline icon${C_RESET} in the left sidebar (robot/chat bubble).

  3. Click the ⚙️ gear icon at the top of the Cline panel and set:

        API Provider           : Anthropic
        Anthropic API Key      : sk-key        ${C_YELLOW}(any non-empty value)${C_RESET}
        Use custom base URL    : ✅ enabled
        Base URL               : http://127.0.0.1:9999
        Model                  : (latest Claude Sonnet, e.g. claude-sonnet-4)

  4. Save, then send a test message like "Hello!" in the Cline chat.

${C_BOLD}Helpful commands you now have:${C_RESET}
  • ${C_GREEN}sf_bedrock_proxy_start${C_RESET}  — start the proxy (no-op if running)
  • ${C_GREEN}sf_bedrock_proxy_stop${C_RESET}   — stop the proxy
  • ${C_GREEN}cline-vscode${C_RESET}            — open VS Code with the proxy guaranteed up
  • Logs: ${C_GREEN}/tmp/sf-bedrock-proxy.log${C_RESET}

${C_BOLD}To rotate your Anthropic key later:${C_RESET}
  Re-run this installer (it will replace the old block safely), or edit
  the value of ANTHROPIC_AUTH_TOKEN inside the marked block in ~/.zshrc,
  then run:  ${C_GREEN}sf_bedrock_proxy_stop && source ~/.zshrc${C_RESET}

Happy building! 🚀

EOF







