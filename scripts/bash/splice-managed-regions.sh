#!/usr/bin/env bash
# Implements: REQ-022, REQ-NF-005, SYS-007, SYS-015, ARCH-010, MOD-014, UTP-014-A, UTP-014-B, ITP-014-A, ATP-018-A, SCN-018-A1, HAZ-007, HAZ-008, HAZ-014, HAZ-023, HAZ-025, D-005, D-015, D-016
#
# splice-managed-regions.sh — replace `# BEGIN MANAGED id="…"` / `# END MANAGED id="…"`
# regions in <target-file> with caller-supplied content. Per ARCH-010 the
# script writes the spliced output to STDOUT; the caller is responsible for
# the atomic `mktemp + mv` write idiom (D-016, SYS-015).
#
# Two invocation modes:
#
#   1. Legacy single-payload (back-compat — byte-identical stdout vs. v0.7.0):
#        splice-managed-regions.sh <target-file> <generated-content> <language>
#      Every BEGIN/END region in the target is replaced with the entire
#      contents of <generated-content>.
#
#   2. Per-region payload (--region-from, MF-5, recommended for multi-region
#      targets):
#        splice-managed-regions.sh --region-from <regions-file> <target-file> <language>
#      <regions-file> uses sentinels DISTINCT from MANAGED to avoid ambiguity:
#          <<<REGION id="X">>>
#          ...content for region X...
#          <<<END>>>
#          <<<REGION id="Y">>>
#          ...content for region Y...
#          <<<END>>>
#      Each MANAGED region in <target-file> is replaced with the matching
#      <<<REGION id="…">>> block by id.
#
# Exit codes (HAZ-025 grammar):
#   0 — clean splice (or sentinel-free no-op pass-through).
#   1 — file-not-found, unbalanced/orphan/nested MANAGED markers, bad CLI.
#   2 — hardening violations (MF-5): id-mismatch, duplicate-id, missing payload,
#       malformed regions file. Distinguishes "the splicer caught corruption"
#       (HAZ-007 / HAZ-014) from "could not even parse the inputs" (exit 1).
#
# On any error, the original target file is untouched (this script never
# writes to the target — the caller's mv idiom does).
#
# On every successful run that produces a non-empty diff against the target,
# `diff -u "$TARGET" <spliced>` is emitted on STDERR for audit-trail purposes
# (recommended: tee to tests/.splicer-diffs.log). No-op runs (diff empty)
# emit nothing on stderr — the pass-through path stays clean for callers.

set -euo pipefail
IFS=$'\n\t'

usage() {
    cat <<'EOF'
Usage:
  splice-managed-regions.sh <target-file> <generated-content> <language>
  splice-managed-regions.sh --region-from <regions-file> <target-file> <language>

Replaces sentinel-bounded MANAGED region(s) in <target-file>. Output goes to
stdout; a unified diff against the target is emitted on stderr for non-empty
splices. <language> selects comment-marker syntax (`bash`/`python`/`pwsh` use
`#`; `js`/`ts` use `//`; HTML uses `<!-- … -->`). Sentinels themselves are
preserved verbatim (D-015).
EOF
}

case "${1:-}" in
    --help|-h) usage; exit 0 ;;
esac

REGION_MODE=false
REGIONS_FILE=""

if [ "${1:-}" = "--region-from" ]; then
    REGION_MODE=true
    [ "$#" -ge 4 ] || { echo "ERROR: usage: splice-managed-regions.sh --region-from <regions> <target> <language>" >&2; exit 1; }
    REGIONS_FILE="$2"
    TARGET="$3"
    LANG="$4"
else
    if [ "$#" -lt 3 ]; then
        echo "ERROR: usage: splice-managed-regions.sh <target> <generated> <language>" >&2
        exit 1
    fi
    TARGET="$1"
    GENERATED="$2"
    LANG="$3"
fi

[ -f "$TARGET" ] || { echo "ERROR: target file not found: $TARGET" >&2; exit 1; }
if $REGION_MODE; then
    [ -f "$REGIONS_FILE" ] || { echo "ERROR: regions file not found: $REGIONS_FILE" >&2; exit 1; }
else
    [ -f "$GENERATED" ] || { echo "ERROR: generated file not found: $GENERATED" >&2; exit 1; }
fi

# Marker prefix per language (D-015). All shell-family + python use `#`.
case "$LANG" in
    bash|sh|python|py|pwsh|powershell|ps1|yaml|yml|ruby|rb) prefix='#' ;;
    js|ts|javascript|typescript|c|cpp|java|go|rust)         prefix='//' ;;
    html|md|markdown|xml)                                   prefix='<!--' ;;
    *) echo "ERROR: unsupported language: $LANG" >&2; exit 1 ;;
esac

TARGET_DIR="$(dirname "$TARGET")"
TMP_OUT="$(mktemp "$TARGET_DIR/.splice-out.XXXXXX")"
TMP_REGION_DIR=""
TMP_MANIFEST=""
if $REGION_MODE; then
    TMP_REGION_DIR="$(mktemp -d "$TARGET_DIR/.splice-regions.XXXXXX")"
    TMP_MANIFEST="$(mktemp "$TARGET_DIR/.splice-manifest.XXXXXX")"
fi

cleanup() {
    [ -n "$TMP_OUT" ] && rm -f -- "$TMP_OUT"
    [ -n "$TMP_MANIFEST" ] && rm -f -- "$TMP_MANIFEST"
    if [ -n "$TMP_REGION_DIR" ] && [ -d "$TMP_REGION_DIR" ]; then
        rm -f -- "$TMP_REGION_DIR"/* 2>/dev/null || true
        rmdir -- "$TMP_REGION_DIR" 2>/dev/null || true
    fi
}
trap cleanup EXIT INT TERM

# ---------------------------------------------------------------------------
# Step 1 (region mode only): pre-parse regions file. Fail-fast BEFORE touching
# the target so HAZ-014 "original target untouched on error" invariant holds.
# Emits one file per id into TMP_REGION_DIR plus an id manifest.
# ---------------------------------------------------------------------------
if $REGION_MODE; then
    awk -v outdir="$TMP_REGION_DIR" -v manifest="$TMP_MANIFEST" '
        BEGIN { in_region = 0 }
        {
            if (match($0, /^<<<REGION id="[^"]+">>>[[:space:]]*$/)) {
                if (in_region) {
                    print "ERROR: regions file: unbalanced REGION/END at line " NR > "/dev/stderr"
                    exit 2
                }
                id = $0
                sub(/^<<<REGION id="/, "", id)
                sub(/">>>[[:space:]]*$/, "", id)
                if (id ~ /[\/\\]/ || id ~ /^\./) {
                    print "ERROR: regions file: unsafe id \"" id "\" at line " NR " (must not contain '/' or '\\\\' or start with '.')" > "/dev/stderr"
                    exit 2
                }
                if (id in seen) {
                    print "ERROR: regions file: duplicate id \"" id "\" at line " NR > "/dev/stderr"
                    exit 2
                }
                seen[id] = NR
                in_region = 1
                out = outdir "/" id
                # Truncate per-region payload file.
                printf "" > out
                print id >> manifest
                next
            }
            if ($0 ~ /^<<<END>>>[[:space:]]*$/) {
                if (!in_region) {
                    print "ERROR: regions file: unbalanced REGION/END at line " NR > "/dev/stderr"
                    exit 2
                }
                close(out)
                in_region = 0
                next
            }
            if (in_region) print >> out
        }
        END {
            if (in_region) {
                print "ERROR: regions file: unbalanced REGION/END at line " NR > "/dev/stderr"
                exit 2
            }
        }
    ' "$REGIONS_FILE"
fi

# ---------------------------------------------------------------------------
# Step 2: splice. Single awk pass that:
#   - validates id-match (BEGIN id="X" must close with END id="X") — exit 2;
#   - validates duplicate-ID per target — exit 2;
#   - validates nested BEGIN / orphan END / unclosed region — exit 1;
#   - in region mode, validates payload-availability per id — exit 2;
#   - emits the spliced output to TMP_OUT (stdout of awk).
# ---------------------------------------------------------------------------
awk -v prefix="$prefix" \
    -v gen="${GENERATED:-}" \
    -v region_mode="$($REGION_MODE && echo 1 || echo 0)" \
    -v regiondir="${TMP_REGION_DIR:-}" '
    BEGIN {
        depth = 0
        exit_code = 0
        bp = prefix
        gsub(/[][\\.^$*+?(){}|]/, "\\\\&", bp)
        begin_re = "^[[:space:]]*" bp "[[:space:]]*BEGIN MANAGED id=\"[^\"]+\""
        end_re   = "^[[:space:]]*" bp "[[:space:]]*END MANAGED id=\"[^\"]+\""
        # Pattern to extract the quoted id. Captured via match()+substr.
        id_re = "id=\"[^\"]+\""
    }
    function extract_id(line,    m, s) {
        if (match(line, /id="[^"]+"/)) {
            s = substr(line, RSTART + 4, RLENGTH - 5)
            return s
        }
        return ""
    }
    {
        is_begin = ($0 ~ begin_re)
        is_end   = ($0 ~ end_re)

        if (is_begin) {
            bid = extract_id($0)
            if (bid ~ /[\/\\]/ || bid ~ /^\./) {
                print "ERROR: unsafe region id \"" bid "\" at line " NR " (must not contain '/' or '\\\\' or start with '.')" > "/dev/stderr"
                exit_code = 2; exit exit_code
            }
            if (depth > 0) {
                print "ERROR: nested BEGIN MANAGED at line " NR ": " $0 > "/dev/stderr"
                exit_code = 1; exit exit_code
            }
            if (bid in seen_begin) {
                print "ERROR: duplicate region id \"" bid "\" at line " NR " (first seen at line " seen_begin[bid] ")" > "/dev/stderr"
                exit_code = 2; exit exit_code
            }
            seen_begin[bid] = NR
            depth = 1
            current_id = bid
            print
            if (region_mode == 1) {
                payload = regiondir "/" bid
                ret = (getline pline < payload)
                if (ret < 0) {
                    print "ERROR: no payload provided for region id \"" bid "\"" > "/dev/stderr"
                    exit_code = 2; exit exit_code
                }
                while (ret > 0) {
                    print pline
                    ret = (getline pline < payload)
                }
                close(payload)
            } else {
                while ((getline gline < gen) > 0) print gline
                close(gen)
            }
            next
        }
        if (is_end) {
            eid = extract_id($0)
            if (depth == 0) {
                print "ERROR: END MANAGED without matching BEGIN at line " NR ": " $0 > "/dev/stderr"
                exit_code = 1; exit exit_code
            }
            if (eid != current_id) {
                print "ERROR: id mismatch at line " NR ": BEGIN id=\"" current_id "\" closed by END id=\"" eid "\"" > "/dev/stderr"
                exit_code = 2; exit exit_code
            }
            depth = 0
            current_id = ""
            print
            next
        }
        if (depth == 0) print
    }
    END {
        if (exit_code != 0) exit exit_code
        if (depth != 0) {
            print "ERROR: unclosed BEGIN MANAGED region at EOF" > "/dev/stderr"
            exit 1
        }
    }
' "$TARGET" > "$TMP_OUT"

# ---------------------------------------------------------------------------
# Step 3: emit diff -u on stderr (audit trail) when non-empty; cat to stdout.
# diff exit codes: 0 = identical (silent), 1 = differences (emit), 2+ = error.
# ---------------------------------------------------------------------------
set +e
diff_out="$(diff -u "$TARGET" "$TMP_OUT")"
diff_rc=$?
set -e
if [ "$diff_rc" -eq 1 ]; then
    printf '%s\n' "$diff_out" >&2
elif [ "$diff_rc" -gt 1 ]; then
    echo "ERROR: diff failed with exit $diff_rc" >&2
    exit 1
fi

cat "$TMP_OUT"
