#!/usr/bin/env bash
# Implements: REQ-016, SYS-004, ARCH-007, ARCH-016, MOD-010, MOD-021, HAZ-009, HAZ-010, D-003
#
# validate-artifact-status.sh — approval-status gate sub-validator (MF-6).
#
# Greps `^**Status**:` from each canonical V-Model artifact in <vmodel-dir>
# and fails fast if any value is not in the allowed set (default: {Approved}).
# Only the FIRST `**Status**:` line per file is consulted — body occurrences
# (e.g. `**Status**: DROP per drift-diff-plan.md` inside integration-test.md)
# are deliberately ignored. Files that don't exist are skipped silently
# (mirrors the existing 5-coverage-validator missing-artifact pattern).
#
# Usage:
#   validate-artifact-status.sh <vmodel-dir> [--required-status <status>]...
#
# EXIT CODES:
#   0 = every present artifact's first **Status** is in the allowed set
#   1 = at least one artifact has missing/unknown/disallowed status
#
# STDOUT (success): exactly `STATUS: PASS`
# STDERR (failure): one `STATUS: <file>: <value>` diagnostic per offender,
#                   then nothing to stdout; exits 1.

set -euo pipefail
IFS=$'\n\t'

usage() {
    cat <<'EOF'
Usage: validate-artifact-status.sh <vmodel-dir> [--required-status <status>]...
  Default required set is {Approved}. Repeat --required-status to broaden.
EOF
}

REQUIRED=()
VMODEL_DIR=""

while [ $# -gt 0 ]; do
    case "$1" in
        --help|-h) usage; exit 0 ;;
        --required-status)
            [ $# -ge 2 ] || { echo "ERROR: --required-status needs a value" >&2; exit 1; }
            REQUIRED+=("$2"); shift 2 ;;
        --required-status=*)
            REQUIRED+=("${1#*=}"); shift ;;
        --) shift; break ;;
        -*)
            echo "ERROR: unknown flag: $1" >&2; usage >&2; exit 1 ;;
        *)
            if [ -z "$VMODEL_DIR" ]; then VMODEL_DIR="$1"; shift
            else echo "ERROR: unexpected positional arg: $1" >&2; exit 1; fi ;;
    esac
done

[ -n "$VMODEL_DIR" ] || { echo "ERROR: vmodel-dir argument required" >&2; usage >&2; exit 1; }
[ -d "$VMODEL_DIR" ] || { echo "ERROR: vmodel-dir not found: $VMODEL_DIR" >&2; exit 1; }
[ "${#REQUIRED[@]}" -gt 0 ] || REQUIRED=("Approved")

# Canonical artifact set: the six files run-v-model-gate.sh inner validators
# already consume + the four test plans. Order matches v-model run order.
ARTIFACTS=(
    requirements.md
    system-design.md
    architecture-design.md
    module-design.md
    hazard-analysis.md
    unit-test.md
    integration-test.md
    system-test.md
    acceptance-plan.md
)

fail=0
for art in "${ARTIFACTS[@]}"; do
    f="$VMODEL_DIR/$art"
    [ -f "$f" ] || continue
    # First match only; body-occurrences are ignored by design.
    line="$(grep -m1 -E '^\*\*Status\*\*:' "$f" 2>/dev/null || true)"
    if [ -z "$line" ]; then
        echo "STATUS: $art: <missing>" >&2
        fail=1; continue
    fi
    # Strip prefix, leading/trailing whitespace.
    value="${line#\*\*Status\*\*:}"
    # Trim leading whitespace.
    value="${value#"${value%%[![:space:]]*}"}"
    # Trim trailing whitespace.
    value="${value%"${value##*[![:space:]]}"}"
    if [ -z "$value" ]; then
        echo "STATUS: $art: <missing>" >&2
        fail=1; continue
    fi
    ok=0
    for allow in "${REQUIRED[@]}"; do
        if [ "$value" = "$allow" ]; then ok=1; break; fi
    done
    if [ "$ok" -eq 0 ]; then
        echo "STATUS: $art: $value" >&2
        fail=1
    fi
done

if [ "$fail" -ne 0 ]; then exit 1; fi
echo "STATUS: PASS"
