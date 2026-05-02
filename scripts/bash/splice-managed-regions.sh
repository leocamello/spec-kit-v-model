#!/usr/bin/env bash
# Implements: REQ-022, REQ-NF-005, SYS-007, SYS-015, ARCH-010, MOD-014, UTP-014-A, UTP-014-B, ITP-014-A, ATP-018-A, SCN-018-A1, HAZ-008, HAZ-014, HAZ-023, HAZ-025, D-005, D-015, D-016
#
# splice-managed-regions.sh — replace `# BEGIN MANAGED id="…"` / `# END MANAGED`
# regions in <target-file> with content from <generated-content>. Per ARCH-010
# this script writes the spliced output to STDOUT; the caller is responsible
# for the atomic `mktemp + mv` write idiom (D-016, SYS-015).
#
# CLI:
#   splice-managed-regions.sh <target-file> <generated-content> <language>
#
# Exits 0 on clean splice (or sentinel-free no-op pass-through).
# Exits 1 on unbalanced / overlapping markers; original target untouched
# (this script never writes to the target).

set -euo pipefail
IFS=$'\n\t'

usage() {
    cat <<'EOF'
Usage: splice-managed-regions.sh <target-file> <generated-content> <language>

Replaces sentinel-bounded MANAGED region(s) in <target-file> with the contents
of <generated-content>. Output goes to stdout. <language> selects comment-
marker syntax (`bash`/`python`/`pwsh` use `#`; `js`/`ts` use `//`; HTML uses
`<!-- … -->`). Sentinels themselves are preserved verbatim (D-015).
EOF
}

case "${1:-}" in
    --help|-h) usage; exit 0 ;;
esac

if [ "$#" -lt 3 ]; then
    echo "ERROR: usage: splice-managed-regions.sh <target> <generated> <language>" >&2
    exit 1
fi

TARGET="$1"
GENERATED="$2"
LANG="$3"

[ -f "$TARGET" ] || { echo "ERROR: target file not found: $TARGET" >&2; exit 1; }
[ -f "$GENERATED" ] || { echo "ERROR: generated file not found: $GENERATED" >&2; exit 1; }

# Marker prefix per language (D-015). All shell-family + python use `#`.
case "$LANG" in
    bash|sh|python|py|pwsh|powershell|ps1|yaml|yml|ruby|rb) prefix='#' ;;
    js|ts|javascript|typescript|c|cpp|java|go|rust)         prefix='//' ;;
    html|md|markdown|xml)                                   prefix='<!--' ;;
    *) echo "ERROR: unsupported language: $LANG" >&2; exit 1 ;;
esac

# Scan + emit via awk. Tracks depth to detect nesting; verifies balance at EOF.
# Behaviour:
#   - Outside a region: pass line through verbatim.
#   - On BEGIN: print sentinel, set depth=1, emit generated content, then
#     swallow lines until matching END (which is also printed verbatim).
#   - On nested BEGIN inside region: error.
#   - On END outside region: error.
#   - On EOF still inside region: error.
awk -v prefix="$prefix" -v gen="$GENERATED" '
    BEGIN {
        depth = 0
        # Build regex-safe prefix (escape /).
        bp = prefix
        gsub(/[][\\.^$*+?(){}|]/, "\\\\&", bp)
    }
    {
        is_begin = ($0 ~ ("^[[:space:]]*" bp "[[:space:]]*BEGIN MANAGED id=\"[^\"]+\""))
        is_end   = ($0 ~ ("^[[:space:]]*" bp "[[:space:]]*END MANAGED id=\"[^\"]+\""))

        if (is_begin) {
            if (depth > 0) {
                print "ERROR: nested BEGIN MANAGED at line " NR ": " $0 > "/dev/stderr"
                exit_code = 1
                exit 1
            }
            depth = 1
            print
            while ((getline gline < gen) > 0) print gline
            close(gen)
            next
        }
        if (is_end) {
            if (depth == 0) {
                print "ERROR: END MANAGED without matching BEGIN at line " NR ": " $0 > "/dev/stderr"
                exit_code = 1
                exit 1
            }
            depth = 0
            print
            next
        }
        if (depth == 0) print
    }
    END {
        if (depth != 0) {
            print "ERROR: unclosed BEGIN MANAGED region at EOF" > "/dev/stderr"
            exit 1
        }
    }
' "$TARGET"
