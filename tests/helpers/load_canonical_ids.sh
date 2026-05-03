#!/bin/sh
# Implements: REQ-NF-002, SYS-006, ARCH-009, MOD-025, D-008
#
# load_canonical_ids.sh — print the canonical V-Model ID set for a feature.
#
# Usage:
#   . tests/helpers/load_canonical_ids.sh
#   load_canonical_ids <vmodel-dir>      # prints sorted, unique IDs to stdout
#
# POSIX-only (no bash 4 features). Used by every test family to anchor the
# hallucination guard contract (D-008): if an ID is cited anywhere outside
# the canonical set, the citing artefact is by definition fabricated.

load_canonical_ids() {
    vmodel_dir="$1"
    if [ -z "$vmodel_dir" ] || [ ! -d "$vmodel_dir" ]; then
        echo "load_canonical_ids: not a directory: $vmodel_dir" >&2
        return 2
    fi
    # Categories enumerated per data-model.md §Canonical ID grammar.
    grep -hoE '\b(REQ|REQ-NF|REQ-CN|REQ-IF|SYS|ARCH|MOD|ITP|ITS|UTP|UTS|STP|STS|ATP|SCN|HAZ)-[0-9]+(-[A-Z][0-9]*)?\b' \
        "$vmodel_dir"/*.md 2>/dev/null \
        | sort -u
}

# When sourced, do nothing else. When executed, treat $1 as the dir.
case "${0##*/}" in
    load_canonical_ids.sh)
        load_canonical_ids "$@"
        ;;
esac
