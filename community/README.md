# 🌱 SPUX Community Scripts

Welcome! This is where SPUX users contribute scripts that automate their favorite workflows.

## How to contribute

1. **Fork** the repo and create a branch.
2. **Add your script** under `community/<your-github-handle>/<script-name>.sh`.
3. Include the **`SPUX_MANIFEST`** header (see template below).
4. Open a PR. CI will run:
   - `shellcheck` for shell-script correctness
   - `core/validate.sh` for SPUX manifest + security audit
   - An optional AI-powered logic review for non-obvious patterns
5. After merge, a maintainer will register your alias in `registry/registry.json`.

## Manifest template

Every community script **must** start with:

```bash
#!/usr/bin/env bash
# <SPUX_MANIFEST>
# ID: my-cool-tool
# Title: My Cool Tool
# Author: your-github-handle
# Description: One sentence describing what the script does.
# Platform: macOS | Linux
# </SPUX_MANIFEST>
set -euo pipefail
```

## Rules

- ✅ **Source the UI helpers** (`.spux-utils/ui.sh`) so output feels consistent.
- ✅ **Wrap privileged calls** with `spux::sudo` — never call `sudo` directly.
- ✅ **Confirm destructive actions** with `spux::confirm` before running them.
- ❌ **No remote-piped sudo** (`curl ... | sudo bash`) — ever.
- ❌ **No obfuscated payloads** (base64-decoded scripts, eval-from-curl, etc).
- ❌ **No telemetry without consent.**

## Folder layout

```
community/
└── your-handle/
    ├── my-cool-tool.sh
    └── README.md      # optional — explain what it does + screenshots
```

See [`community/_template/example.sh`](_template/example.sh) for a copy-pasteable starting point.
