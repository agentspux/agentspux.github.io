#!/usr/bin/env bash
# core/validate.sh — SPUX security & manifest validator.
# Used by CI to gate community scripts. Exit code 0 = pass, 1 = fail.
#
# Checks performed:
#   1. SPUX_MANIFEST block is present and well-formed.
#   2. shebang is bash (or env bash).
#   3. Regex scan for known-malicious / dangerous patterns.
#   4. Warn (not fail) on `sudo` usage without spux::sudo wrapper.
#
# Usage:
#   core/validate.sh path/to/script.sh [more.sh ...]
set -uo pipefail

_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
# shellcheck source=/dev/null
source "$_dir/../.spux-utils/ui.sh" 2>/dev/null || true

# Patterns that should NEVER appear in a SPUX script.
DANGEROUS_PATTERNS=(
  'rm[[:space:]]+-rf[[:space:]]+/[[:space:]]*$'         # rm -rf /
  'rm[[:space:]]+-rf[[:space:]]+/\*'                     # rm -rf /*
  ':\(\)\{[[:space:]]*:\|:&[[:space:]]*\};:'              # fork bomb
  'mkfs\.'                                                # filesystem format
  'dd[[:space:]]+if=/dev/(zero|random|urandom)[[:space:]]+of=/dev/[hs]d'  # disk wipe
  '>\s*/dev/sd[a-z]'                                      # raw disk write
  'curl[^|]*\|[[:space:]]*sudo[[:space:]]+bash'           # remote-piped sudo
  'wget[^|]*\|[[:space:]]*sudo[[:space:]]+bash'
  'eval[[:space:]]*"?\$\([[:space:]]*curl'                # eval $(curl ...)
  'chmod[[:space:]]+777[[:space:]]+/'                     # chmod 777 root
  '/etc/(passwd|shadow|sudoers)[[:space:]]*[<>]'          # writes to system auth files
)

# Patterns that warrant a WARNING but not failure.
SUSPICIOUS_PATTERNS=(
  '^[[:space:]]*sudo[[:space:]]'                          # raw sudo (use spux::sudo)
  'base64[[:space:]]+-d'                                  # base64-decoded payloads
  'history[[:space:]]+-c'                                 # clearing history
)

REQUIRED_MANIFEST_FIELDS=( ID Title Author Description Platform )

fail=0
warn=0

check_file() {
  local f="$1"
  local errors=() warnings=()

  [ -f "$f" ] || { errors+=("File not found"); return 1; }

  # 1. Shebang
  local first; first="$(head -1 "$f")"
  if ! echo "$first" | grep -Eq '^#!.*(bash|sh)'; then
    errors+=("Missing or non-bash shebang")
  fi

  # 2. Manifest
  if ! grep -q "<SPUX_MANIFEST>" "$f" || ! grep -q "</SPUX_MANIFEST>" "$f"; then
    errors+=("Missing SPUX_MANIFEST block")
  else
    local manifest
    manifest="$(sed -n '/<SPUX_MANIFEST>/,/<\/SPUX_MANIFEST>/p' "$f")"
    for field in "${REQUIRED_MANIFEST_FIELDS[@]}"; do
      echo "$manifest" | grep -Eq "^#[[:space:]]*$field:" || errors+=("Manifest missing field: $field")
    done
  fi

  # 3. Dangerous patterns
  for pat in "${DANGEROUS_PATTERNS[@]}"; do
    if grep -Eq "$pat" "$f"; then
      errors+=("DANGEROUS pattern matched: $pat")
    fi
  done

  # 4. Suspicious patterns
  for pat in "${SUSPICIOUS_PATTERNS[@]}"; do
    if grep -Eq "$pat" "$f"; then
      warnings+=("Suspicious pattern: $pat")
    fi
  done

  # Report
  if [ ${#errors[@]} -eq 0 ] && [ ${#warnings[@]} -eq 0 ]; then
    spux::success "PASS  $f"
    return 0
  fi
  if [ ${#errors[@]} -gt 0 ]; then
    spux::error "FAIL  $f"
    for e in "${errors[@]}"; do printf "       %s\n" "$e" >&2; done
    fail=$((fail+1))
  fi
  if [ ${#warnings[@]} -gt 0 ]; then
    spux::warn "WARN  $f"
    for w in "${warnings[@]}"; do printf "       %s\n" "$w" >&2; done
    warn=$((warn+1))
  fi
}

if [ $# -eq 0 ]; then
  echo "Usage: validate.sh <script.sh> [more.sh ...]" >&2
  exit 1
fi

spux::header "SPUX Script Validator"
for arg in "$@"; do check_file "$arg"; done

echo
if [ "$fail" -gt 0 ]; then
  spux::error "$fail file(s) failed validation."
  exit 1
fi
spux::success "All scripts passed (warnings: $warn)."
exit 0
