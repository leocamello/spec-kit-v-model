#!/usr/bin/env bash
# Implements: REQ-001, REQ-027, ARCH-014, MOD-021, D-001, D-010
# Bridge wrapper around .specify/scripts/bash/setup-plan.sh that augments
# the upstream JSON with a top-level VMODEL_DIR field. In non-JSON mode the
# wrapper appends a single `VMODEL_DIR: <path|(none)>` trailer line.
# Repo root is overridable via SPECIFY_REPO_ROOT for test isolation.
set -euo pipefail
IFS=$'\n\t'

REPO_ROOT="${SPECIFY_REPO_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || (cd "$(dirname "$0")/../.." && pwd))}"
UPSTREAM="$REPO_ROOT/.specify/scripts/bash/setup-plan.sh"

if [ ! -x "$UPSTREAM" ]; then
    echo "ERROR: upstream script not found or not executable: $UPSTREAM" >&2
    exit 2
fi

JSON_MODE=false
for arg in "$@"; do
    [ "$arg" = "--json" ] && JSON_MODE=true
done

set +e
upstream_out="$("$UPSTREAM" "$@")"
rc=$?
set -e
[ "$rc" -ne 0 ] && { printf '%s\n' "$upstream_out"; exit "$rc"; }

extract_field() {
    # $1 = JSON line, $2 = field name. Emits raw value, or empty if absent.
    printf '%s' "$1" | sed -n 's/.*"'"$2"'"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p'
}

if $JSON_MODE; then
    feature_dir="$(extract_field "$upstream_out" "SPECS_DIR")"
    vmodel_path=""
    if [ -n "$feature_dir" ] && [ -d "$feature_dir/v-model" ]; then
        vmodel_path="$feature_dir/v-model"
    fi
    if [ -n "$vmodel_path" ]; then
        injection=",\"VMODEL_DIR\":\"$vmodel_path\"}"
    else
        injection=',"VMODEL_DIR":null}'
    fi
    # Replace the final closing brace (last char of the trimmed line) with our augmented tail.
    trimmed="$(printf '%s' "$upstream_out" | sed -e 's/[[:space:]]*$//')"
    base="${trimmed%\}}"
    printf '%s%s\n' "$base" "$injection"
else
    printf '%s\n' "$upstream_out"
    feature_dir="$(printf '%s\n' "$upstream_out" | sed -n 's/^SPECS_DIR:[[:space:]]*//p' | head -n1)"
    if [ -n "$feature_dir" ] && [ -d "$feature_dir/v-model" ]; then
        echo "VMODEL_DIR: $feature_dir/v-model"
    else
        echo "VMODEL_DIR: (none)"
    fi
fi
