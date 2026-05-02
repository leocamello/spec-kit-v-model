#!/usr/bin/env bash
# Implements: REQ-IF-001, REQ-IF-002, REQ-029, SYS-010, ARCH-013, MOD-017, MOD-018, UTP-017-A, UTP-018-A, ITP-017-A, ATP-002-A, SCN-002-A1
#
# validate-core-schema.sh — pinned-schema validator for plan.md / tasks.md.
# Extracts the H2 heading set from the spec-kit-core template (pinned at
# v0.7.0) and verifies the target file contains every required heading.
# Tolerates additive content (extra headings, prose, HTML-comment enrichment).
#
# CLI: validate-core-schema.sh <target> --plan|--tasks
#  (mode flag may also precede target; both orderings accepted)

set -euo pipefail
IFS=$'\n\t'

PINNED_VERSION="v0.7.0"

usage() {
    cat <<EOF
Usage: validate-core-schema.sh <target-file> --plan|--tasks

Verifies that <target-file> contains every required H2 heading from the pinned
(${PINNED_VERSION}) spec-kit-core plan-template.md or tasks-template.md.
EOF
}

mode=""
target=""
for arg in "$@"; do
    case "$arg" in
        --help|-h) usage; exit 0 ;;
        --plan)    mode="plan" ;;
        --tasks)   mode="tasks" ;;
        --*)       echo "ERROR: unknown flag: $arg" >&2; exit 1 ;;
        *)         target="$arg" ;;
    esac
done

if [ -z "$mode" ]; then
    echo "ERROR: mode flag required (--plan or --tasks)" >&2
    exit 1
fi
if [ -z "$target" ]; then
    echo "ERROR: target file required" >&2
    exit 1
fi
if [ ! -f "$target" ]; then
    echo "ERROR: target file not found: $target" >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
case "$mode" in
    plan)  template="$PROJECT_ROOT/.specify/templates/plan-template.md"  ;;
    tasks) template="$PROJECT_ROOT/.specify/templates/tasks-template.md" ;;
esac

if [ ! -f "$template" ]; then
    echo "ERROR: pinned template not found: $template" >&2
    exit 1
fi

required="$(grep -E '^## ' "$template" || true)"
missing=0
while IFS= read -r heading; do
    [ -z "$heading" ] && continue
    if ! grep -Fxq "$heading" "$target"; then
        echo "${heading}: MISSING"
        missing=$((missing + 1))
    fi
done <<EOF
$required
EOF

if [ "$missing" -gt 0 ]; then
    echo "SCHEMA: FAIL"
    exit 1
fi
echo "SCHEMA: PASS (pinned_version=${PINNED_VERSION})"
