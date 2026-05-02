#!/usr/bin/env bash
# Implements: REQ-023, REQ-NF-002, REQ-NF-004, SYS-006, ARCH-009, MOD-013, MOD-025, UTP-013-A, UTP-025-A, ITP-013-A, ATP-019-A, SCN-019-A1, HAZ-007, HAZ-012, HAZ-023, D-004, D-008
#
# validate-implements-ids.sh — deterministic hallucination guard.
# Extracts the canonical V-Model ID set from <feature-dir>/v-model/*.md
# (per-category source-of-truth doc) and verifies that every `Implements <ID>`
# comment under <feature-dir> (excluding v-model/) cites a canonical ID.
# Exits 0 with `GUARD: PASS` on success; 1 with `<file>:<line>: unknown id <X>`
# diagnostics + `GUARD: FAIL` on any unknown citation.

set -euo pipefail
IFS=$'\n\t'

usage() {
    cat <<'EOF'
Usage: validate-implements-ids.sh <feature-dir>

Scans <feature-dir> for `Implements <ID>` comments and verifies every cited
ID exists in the canonical V-Model artifact set under <feature-dir>/v-model.
EOF
}

case "${1:-}" in
    --help|-h) usage; exit 0 ;;
    "") echo "ERROR: feature-dir argument required" >&2; usage >&2; exit 1 ;;
esac

FEATURE_DIR="$1"
[ -d "$FEATURE_DIR" ] || { echo "ERROR: feature dir not found: $FEATURE_DIR" >&2; exit 1; }
VMODEL_DIR="$FEATURE_DIR/v-model"
[ -d "$VMODEL_DIR" ] || { echo "ERROR: v-model dir not found: $VMODEL_DIR" >&2; exit 1; }

# Per-category source-of-truth extraction (D-008): each ID family is canonical
# only if it appears in its owning artifact. This makes the guard sensitive to
# fixture mutation per HAZ-023 (stale snapshot mitigation).
extract_from() {
    # $1 = filename glob, $2 = ID prefix regex
    local file="$VMODEL_DIR/$1"
    local pattern="$2"
    [ -f "$file" ] || return 0
    grep -hoE "\\b(${pattern})-[0-9]+(-[A-Z][0-9]*)?\\b" "$file" 2>/dev/null || true
}

canonical="$(
    {
        extract_from requirements.md       'REQ|REQ-NF|REQ-CN|REQ-IF'
        extract_from system-design.md      'SYS'
        extract_from architecture-design.md 'ARCH'
        extract_from module-design.md      'MOD'
        extract_from hazard-analysis.md    'HAZ'
        extract_from acceptance-plan.md    'ATP|SCN'
        extract_from integration-test.md   'ITP|ITS'
        extract_from unit-test.md          'UTP|UTS'
        extract_from system-test.md        'STP|STS'
    } | sort -u
)"

# Scan target tree for `Implements <ID>` comments. Use grep -rn for
# <file>:<line>:<content> output. Exclude vendor/git/v-model dirs.
matches="$(
    grep -rniE '[Ii]mplements[: ]' "$FEATURE_DIR" \
        --exclude-dir=v-model \
        --exclude-dir=.git \
        --exclude-dir=node_modules \
        --exclude-dir=.session-tmp \
        2>/dev/null || true
)"

unknown=0
# Candidate-token regex: uppercase prefix (≥2 letters) + dash + run of
# uppercase/digit/dash containing at least one digit. Loose on purpose so that
# fabricated multi-token glued IDs (e.g. `REQ-9REQ-9REQ-9`) are caught by the
# canonical-set membership check that follows (HAZ-007).
TOKEN_RE='[A-Z]{2,}-[A-Z0-9-]*[0-9][A-Z0-9-]*'

if [ -n "$matches" ]; then
    while IFS= read -r match; do
        [ -z "$match" ] && continue
        file="${match%%:*}"
        rest="${match#*:}"
        lineno="${rest%%:*}"
        content="${rest#*:}"
        echo "$content" | grep -qiE '\bimplements\b' || continue
        # Strip the keyword prefix so we don't accidentally classify text
        # before "Implements" as an ID candidate.
        tail_text="$(echo "$content" | sed -E 's/^.*[Ii]mplements[: ]+//')"
        ids="$(echo "$tail_text" | grep -oE "$TOKEN_RE" || true)"
        for id in $ids; do
            if ! printf '%s\n' "$canonical" | grep -qx "$id"; then
                echo "$file:$lineno: unknown id $id"
                unknown=$((unknown + 1))
            fi
        done
    done <<EOF
$matches
EOF
fi

if [ "$unknown" -gt 0 ]; then
    echo "GUARD: FAIL"
    exit 1
fi
echo "GUARD: PASS"
