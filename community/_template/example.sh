#!/usr/bin/env bash
# <SPUX_MANIFEST>
# ID: example-template
# Title: Example Community Script
# Author: your-github-handle
# Description: A starter template — copy and modify for your own SPUX script.
# Platform: macOS | Linux
# </SPUX_MANIFEST>
set -euo pipefail

# Always source the SPUX UI helpers so your output looks like a premium app.
SPUX_REPO_RAW="${SPUX_REPO_RAW:-https://raw.githubusercontent.com/agentspux/agentspux.github.io/main}"
_ui_local="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)/../../.spux-utils/ui.sh"
if [ -f "$_ui_local" ]; then source "$_ui_local"
else _t="$(mktemp -t spux-ui.XXXXXX)"; curl -fsSL "$SPUX_REPO_RAW/.spux-utils/ui.sh" -o "$_t"; source "$_t"; fi

spux::header "Example Community Script" "Replace this with your own logic."

spux::step  "Doing the first thing..."
spux::info  "Heads up: this is informational."
spux::success "Looks good!"

# Confirm before doing anything destructive.
spux::confirm "About to do something destructive — continue?" || { spux::warn "Aborted."; exit 0; }

# Use spux::sudo (not raw sudo) for privileged actions.
# spux::sudo apt-get install -y cowsay

spux::footer "Your community script ran successfully."
