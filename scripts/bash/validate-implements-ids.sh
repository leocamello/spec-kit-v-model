#!/usr/bin/env bash
# Implements: REQ-023, REQ-NF-002, REQ-NF-004, SYS-006, ARCH-009, MOD-013, MOD-025, UTP-013-A, UTP-025-A, ITP-013-A, ATP-019-A, SCN-019-A1, HAZ-007, HAZ-012, HAZ-023, D-004, D-008
#
# validate-implements-ids.sh — deterministic hallucination guard.
# Extracts the canonical V-Model ID set from <canonical>/*.md (per-category
# source-of-truth doc; default <feature-dir>/v-model) and verifies that every
# `Implements <ID>` comment under the scan root cites a canonical ID.
# Exits 0 with `GUARD: PASS` on success; 1 with `<file>:<line>: unknown id <X>`
# diagnostics + `GUARD: FAIL` on any unknown citation.
#
# Legacy: validate-implements-ids.sh <feature-dir>
# New:    validate-implements-ids.sh [<feature-dir>] [--canonical <path>]
#                                    [--scan <path>] [--changed-only]

set -euo pipefail
IFS=$'\n\t'

usage() {
    cat <<'EOF'
Usage: validate-implements-ids.sh [<feature-dir>] [--canonical <path>] [--scan <path>] [--changed-only]

Legacy positional <feature-dir> implies --canonical=<feature-dir>/v-model and
--scan=<feature-dir>. Flags override defaults; both --canonical and --scan
must resolve to existing directories.
--changed-only restricts the scan to files reported by `git diff` (HEAD ∪
staged) plus untracked-new, intersected with --scan, excluding paths under
--canonical. Falls back to a full --scan when not in a git working tree.
EOF
}

FEATURE_DIR=""
CANONICAL=""
SCAN=""
CHANGED_ONLY=false

while [ $# -gt 0 ]; do
    case "$1" in
        --help|-h) usage; exit 0 ;;
        --canonical)
            [ $# -ge 2 ] || { echo "ERROR: --canonical requires a path argument" >&2; exit 1; }
            CANONICAL="$2"; shift 2 ;;
        --scan)
            [ $# -ge 2 ] || { echo "ERROR: --scan requires a path argument" >&2; exit 1; }
            SCAN="$2"; shift 2 ;;
        --changed-only)
            CHANGED_ONLY=true; shift ;;
        --) shift; break ;;
        -*)
            echo "ERROR: unknown flag: $1" >&2; usage >&2; exit 1 ;;
        *)
            if [ -z "$FEATURE_DIR" ]; then
                FEATURE_DIR="$1"; shift
            else
                echo "ERROR: unexpected positional argument: $1" >&2; usage >&2; exit 1
            fi ;;
    esac
done

# Resolution rules:
#  1. Positional <feature-dir> alone → defaults derived from it.
#  2. Explicit flags override defaults.
#  3. Both CANONICAL and SCAN must end up resolved to existing directories.
if [ -n "$FEATURE_DIR" ]; then
    [ -d "$FEATURE_DIR" ] || { echo "ERROR: feature dir not found: $FEATURE_DIR" >&2; exit 1; }
    [ -n "$CANONICAL" ] || CANONICAL="$FEATURE_DIR/v-model"
    [ -n "$SCAN" ]      || SCAN="$FEATURE_DIR"
else
    if [ -z "$CANONICAL" ] && [ -z "$SCAN" ]; then
        echo "ERROR: feature-dir argument required (or pass --canonical and --scan)" >&2
        usage >&2; exit 1
    fi
    [ -n "$CANONICAL" ] || { echo "ERROR: --canonical is required when --scan is used without a feature-dir" >&2; exit 1; }
    [ -n "$SCAN" ]      || { echo "ERROR: --scan is required when --canonical is used without a feature-dir" >&2; exit 1; }
fi

[ -d "$CANONICAL" ] || { echo "ERROR: canonical dir not found: $CANONICAL" >&2; exit 1; }
[ -d "$SCAN" ]      || { echo "ERROR: scan dir not found: $SCAN" >&2; exit 1; }

VMODEL_DIR="$CANONICAL"

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

# Compute realpaths for SCAN/CANONICAL so we can determine whether the
# canonical tree lives under the scan root (and therefore whether to add a
# basename-based exclusion to keep the scan from recursing into canonical
# artifacts).
realpath_compat() {
    if command -v realpath >/dev/null 2>&1; then
        realpath "$1" 2>/dev/null || (cd "$1" 2>/dev/null && pwd)
    else
        (cd "$1" 2>/dev/null && pwd)
    fi
}
SCAN_ABS="$(realpath_compat "$SCAN")"
CANONICAL_ABS="$(realpath_compat "$CANONICAL")"
CANONICAL_BASENAME="$(basename "$CANONICAL_ABS")"

# Build the --exclude-dir argument list. Always exclude .git, node_modules,
# .session-tmp; additionally exclude the canonical-dir basename so a scan
# rooted above the canonical artifacts skips them (the legacy default of
# v-model is preserved when canonical = <feature-dir>/v-model).
EXCLUDE_DIRS=( --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=.session-tmp )
case "$SCAN_ABS/" in
    "$CANONICAL_ABS"/*) ;;  # canonical is not strictly under scan
esac
# Add canonical basename exclusion when the canonical tree is under (or equal
# to) the scan tree — otherwise it cannot be reached by the recursive scan
# anyway.
if [ -n "$CANONICAL_BASENAME" ]; then
    case "$CANONICAL_ABS/" in
        "$SCAN_ABS"/*) EXCLUDE_DIRS+=( --exclude-dir="$CANONICAL_BASENAME" ) ;;
        "$SCAN_ABS")   EXCLUDE_DIRS+=( --exclude-dir="$CANONICAL_BASENAME" ) ;;
    esac
fi

# File enumeration: full recursive scan (legacy) vs --changed-only.
matches=""
if $CHANGED_ONLY; then
    if ! git -C "$SCAN_ABS" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "WARN: --changed-only: not a git working tree; falling back to full scan of $SCAN" >&2
        CHANGED_ONLY=false
    else
        # Tracked-modified ∪ staged ∪ untracked-new, all relative to SCAN.
        changed_list="$(
            {
                git -C "$SCAN_ABS" diff --name-only HEAD -- . 2>/dev/null || true
                git -C "$SCAN_ABS" diff --name-only --cached -- . 2>/dev/null || true
                git -C "$SCAN_ABS" ls-files --others --exclude-standard -- . 2>/dev/null || true
            } | sort -u
        )"
        # Filter to existing files, exclude paths under CANONICAL, then reduce
        # to those that contain the Implements keyword (cheap pre-filter).
        candidate_files=()
        if [ -n "$changed_list" ]; then
            while IFS= read -r rel; do
                [ -z "$rel" ] && continue
                abs="$SCAN_ABS/$rel"
                [ -f "$abs" ] || continue
                # Skip files under CANONICAL.
                case "$abs" in
                    "$CANONICAL_ABS"/*) continue ;;
                    "$CANONICAL_ABS")   continue ;;
                esac
                candidate_files+=( "$abs" )
            done <<EOF
$changed_list
EOF
        fi
        if [ "${#candidate_files[@]}" -eq 0 ]; then
            echo "GUARD: PASS (no changed files)"
            exit 0
        fi
        # grep -nE over only the candidate files.
        matches="$(grep -nE '[Ii]mplements[: ]' "${candidate_files[@]}" 2>/dev/null || true)"
    fi
fi

if ! $CHANGED_ONLY; then
    # Legacy full-scan code path. Output is byte-identical to the prior
    # implementation when invoked as `validate-implements-ids.sh <feature-dir>`.
    matches="$(
        grep -rniE '[Ii]mplements[: ]' "$SCAN" \
            "${EXCLUDE_DIRS[@]}" \
            2>/dev/null || true
    )"
fi

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
