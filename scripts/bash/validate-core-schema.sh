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
#
# SCHEMA CHECKS (3 passes):
#   1. Existence — every canonical H2 from the pinned template is present
#      somewhere in the target (exact-match line). Missing → "<H2>: MISSING".
#   2. Order     — canonical H2s in the target appear in the same relative
#      order as in the template. Mismatch → "ORDER: FAIL" + unified diff.
#   3. Wedge     — between the first and last canonical H2 in the target,
#      every H2 must itself be canonical. Non-canonical H2s wedged between
#      canonical ones are rejected with "WEDGE: FAIL — non-canonical H2
#      between canonical H2s: <heading>". Extra H2s before the first or
#      after the last canonical H2 are tolerated (preamble / trailing).
# Any failed pass → final "SCHEMA: FAIL" line + exit 1.

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
fail=0
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
    fail=1
fi

# Pass 2: ordering — canonical H2s in target must follow template order.
# Pass 3: wedge   — no non-canonical H2 may appear between the first and
# last canonical H2 in the target.
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

grep -E '^## ' "$template" > "$tmpdir/expected.txt" || true
grep -E '^## ' "$target"   > "$tmpdir/target-h2-all.txt" || true
grep -Fxf "$tmpdir/expected.txt" "$tmpdir/target-h2-all.txt" \
    > "$tmpdir/target-canonical-in-order.txt" || true

if ! diff -q "$tmpdir/expected.txt" "$tmpdir/target-canonical-in-order.txt" >/dev/null 2>&1; then
    echo "ORDER: FAIL" >&2
    diff -u "$tmpdir/expected.txt" "$tmpdir/target-canonical-in-order.txt" >&2 || true
    fail=1
fi

first_canonical_line="$(grep -nFxf "$tmpdir/expected.txt" "$target" | head -n1 | cut -d: -f1 || true)"
last_canonical_line="$(grep -nFxf "$tmpdir/expected.txt" "$target" | tail -n1 | cut -d: -f1 || true)"
if [ -n "$first_canonical_line" ] && [ -n "$last_canonical_line" ] && [ "$first_canonical_line" -lt "$last_canonical_line" ]; then
    sed -n "${first_canonical_line},${last_canonical_line}p" "$target" \
        | grep -E '^## ' \
        | grep -vFxf "$tmpdir/expected.txt" > "$tmpdir/wedged.txt" || true
    if [ -s "$tmpdir/wedged.txt" ]; then
        while IFS= read -r h; do
            echo "WEDGE: FAIL — non-canonical H2 between canonical H2s: $h" >&2
        done < "$tmpdir/wedged.txt"
        fail=1
    fi
fi

if [ "$fail" -gt 0 ]; then
    echo "SCHEMA: FAIL"
    exit 1
fi
echo "SCHEMA: PASS (pinned_version=${PINNED_VERSION})"
