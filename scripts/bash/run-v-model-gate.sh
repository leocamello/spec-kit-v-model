#!/usr/bin/env bash
# Implements: REQ-016, REQ-017, REQ-024, REQ-CN-002, REQ-027, SYS-004, SYS-008, SYS-012, ARCH-007, ARCH-011, ARCH-016, MOD-010, MOD-015, MOD-021, UTP-010-A, UTP-010-B, ITP-010-A, ATP-017-A, SCN-017-A1, HAZ-009, HAZ-010, HAZ-015, HAZ-024, D-003
# Pre-implementation gate: status + domain + build-matrix + 5 coverage validators on <feature-dir>/v-model.
set -euo pipefail
IFS=$'\n\t'

case "${1:-}" in
    --help|-h) echo "Usage: run-v-model-gate.sh <feature-dir>"; exit 0 ;;
    "") echo "ERROR: feature-dir argument required" >&2; exit 1 ;;
esac
FEATURE_DIR="$1"
[ -d "$FEATURE_DIR" ] || { echo "ERROR: feature dir not found: $FEATURE_DIR" >&2; exit 1; }
VMODEL_DIR="$FEATURE_DIR/v-model"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# Repo root: parent of feature dir's parent (specs/<feat>/.. = specs, ../.. = root).
# Fallback: git rev-parse if available; otherwise FEATURE_DIR/../..
if REPO_ROOT="$(cd "$FEATURE_DIR/../.." 2>/dev/null && pwd)"; then :; else
    REPO_ROOT="$(git -C "$FEATURE_DIR" rev-parse --show-toplevel 2>/dev/null || echo "$FEATURE_DIR")"
fi
INNERS=(validate-artifact-status.sh validate-domain-profile.sh build-matrix.sh \
        validate-requirement-coverage.sh validate-system-coverage.sh \
        validate-architecture-coverage.sh validate-module-coverage.sh validate-hazard-coverage.sh)

NAMES=(); RCS=(); overall=0
matrix_out="$(mktemp "$FEATURE_DIR/matrix.XXXXXX")"
trap 'rm -f "$matrix_out"' EXIT

for inner in "${INNERS[@]}"; do
    path="$SCRIPT_DIR/$inner"; NAMES+=("$inner")
    if [ ! -x "$path" ]; then
        echo "ERROR: missing inner script: $path" >&2
        RCS+=("missing"); overall=1; continue
    fi
    echo "=== $inner ==="; rc=0
    if [ "$inner" = "build-matrix.sh" ]; then
        "$path" "$VMODEL_DIR" --output "$matrix_out" || rc=$?
    elif [ "$inner" = "validate-domain-profile.sh" ]; then
        "$path" "$REPO_ROOT" || rc=$?
    else
        "$path" "$VMODEL_DIR" || rc=$?
    fi
    RCS+=("$rc"); [ "$rc" -ne 0 ] && overall=1
done

echo "--- v-model run summary ---"
for i in "${!NAMES[@]}"; do
    rc="${RCS[$i]}"
    case "$rc" in
        0)       echo "  ${NAMES[$i]}: PASS (rc=0)" ;;
        missing) echo "  ${NAMES[$i]}: FAIL (missing executable)" ;;
        *)       echo "  ${NAMES[$i]}: FAIL (rc=$rc)" ;;
    esac
done
echo "---"

if [ "$overall" -eq 0 ]; then echo "GATE: PASS"; else echo "GATE: FAIL"; exit 1; fi
