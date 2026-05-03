#!/usr/bin/env bash
# Implements: REQ-024, SYS-008, ARCH-011, MOD-015, HAZ-015, HAZ-024, D-003
#
# validate-domain-profile.sh — domain-overlay configuration sub-validator (MF-7).
#
# Per blueprint: non-fatal warning when v-model-config.yml is absent; fatal
# when the file is present-and-invalid (unsupported `domain:` value, missing
# `domain:` key, or overlay directory not found). Pure-shell YAML extraction
# (POSIX grep+sed) — no yq, no Python (D-001).
#
# Usage:
#   validate-domain-profile.sh [<repo-root>]
#
# EXIT CODES:
#   0 = config absent (SKIP) OR present and valid (PASS)
#   1 = config present and invalid

set -euo pipefail
IFS=$'\n\t'

case "${1:-}" in
    --help|-h) echo "Usage: validate-domain-profile.sh [<repo-root>]"; exit 0 ;;
esac

REPO_ROOT="${1:-}"
if [ -z "$REPO_ROOT" ]; then
    if command -v git >/dev/null 2>&1 && REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then :; else
        REPO_ROOT="."
    fi
fi
[ -d "$REPO_ROOT" ] || { echo "ERROR: repo-root not found: $REPO_ROOT" >&2; exit 1; }

CFG="$REPO_ROOT/v-model-config.yml"
if [ ! -f "$CFG" ]; then
    echo "DOMAIN: SKIP (no v-model-config.yml)"
    exit 0
fi

# Extract first `domain:` value (top-level scalar). Strip inline comments and
# surrounding whitespace. `|| true` keeps `set -e -o pipefail` happy when
# grep finds nothing (then the missing-key branch handles the empty value).
DOMAIN_VALUE="$( { grep -E '^domain:' "$CFG" || true; } | head -n1 | sed -E 's/^domain:[[:space:]]*//; s/[[:space:]]+#.*$//; s/^["'\'']//; s/["'\'']$//; s/[[:space:]]*$//')"

if [ -z "$DOMAIN_VALUE" ]; then
    echo "DOMAIN: missing key 'domain:' in v-model-config.yml" >&2
    exit 1
fi

case "$DOMAIN_VALUE" in
    iso_26262|do_178c|iec_62304) ;;
    *)
        echo "DOMAIN: invalid domain \"$DOMAIN_VALUE\"" >&2
        exit 1 ;;
esac

OVERLAY_DIR="$REPO_ROOT/commands/overlays/$DOMAIN_VALUE"
if [ ! -d "$OVERLAY_DIR" ]; then
    echo "DOMAIN: overlay directory not found: commands/overlays/$DOMAIN_VALUE" >&2
    exit 1
fi

echo "DOMAIN: PASS (domain=$DOMAIN_VALUE)"
