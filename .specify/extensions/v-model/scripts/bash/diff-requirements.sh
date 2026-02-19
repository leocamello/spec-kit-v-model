#!/usr/bin/env bash

# Detect changed/added requirements for incremental acceptance plan updates
#
# Compares current requirements.md against its last committed version
# and outputs a list of changed/added REQ IDs.
#
# Usage: ./diff-requirements.sh <vmodel-dir> [--json]
#
# Requires git. Falls back to "all requirements changed" if no git history.

set -e

JSON_MODE=false
VMODEL_DIR=""

for arg in "$@"; do
    case "$arg" in
        --json) JSON_MODE=true ;;
        --help|-h)
            echo "Usage: diff-requirements.sh <vmodel-dir> [--json]"
            exit 0
            ;;
        *) VMODEL_DIR="$arg" ;;
    esac
done

if [[ -z "$VMODEL_DIR" ]]; then
    echo "ERROR: vmodel-dir argument required" >&2
    exit 1
fi

REQUIREMENTS="$VMODEL_DIR/requirements.md"

if [[ ! -f "$REQUIREMENTS" ]]; then
    echo "ERROR: requirements.md not found in $VMODEL_DIR" >&2
    exit 1
fi

# Extract REQ IDs from a file/string
extract_req_ids() {
    grep -oE 'REQ-([A-Z]+-)?[0-9]{3}' "$1" 2>/dev/null | sort -u
}

# Extract requirement lines (ID + description) for content comparison
extract_req_lines() {
    grep -E '\|[[:space:]]*REQ-([A-Z]+-)?[0-9]{3}' "$1" 2>/dev/null | \
        sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sort
}

# Try to get the committed version of the file
committed_version=""
if git rev-parse --show-toplevel >/dev/null 2>&1; then
    # Get the repo-relative path
    repo_root=$(git rev-parse --show-toplevel)
    rel_path=$(realpath --relative-to="$repo_root" "$REQUIREMENTS" 2>/dev/null || echo "$REQUIREMENTS")

    if git show "HEAD:$rel_path" >/dev/null 2>&1; then
        committed_version=$(mktemp)
        git show "HEAD:$rel_path" > "$committed_version"
    fi
fi

if [[ -z "$committed_version" ]]; then
    # No git history — treat all requirements as new
    all_reqs=($(extract_req_ids "$REQUIREMENTS"))
    changed_reqs=("${all_reqs[@]}")
    added_reqs=("${all_reqs[@]}")
    removed_reqs=()
    modified_reqs=()
else
    # Compare current vs committed
    current_reqs=($(extract_req_ids "$REQUIREMENTS"))
    old_reqs=($(extract_req_ids "$committed_version"))

    # Find added REQs (in current but not in old)
    added_reqs=()
    for req in "${current_reqs[@]}"; do
        found=false
        for old in "${old_reqs[@]}"; do
            [[ "$req" == "$old" ]] && found=true && break
        done
        $found || added_reqs+=("$req")
    done

    # Find removed REQs (in old but not in current)
    removed_reqs=()
    for old in "${old_reqs[@]}"; do
        found=false
        for req in "${current_reqs[@]}"; do
            [[ "$old" == "$req" ]] && found=true && break
        done
        $found || removed_reqs+=("$old")
    done

    # Find modified REQs (same ID but different content)
    modified_reqs=()
    current_lines=$(extract_req_lines "$REQUIREMENTS")
    old_lines=$(extract_req_lines "$committed_version")

    for req in "${current_reqs[@]}"; do
        # Skip if it's a new req
        is_new=false
        for added in "${added_reqs[@]}"; do
            [[ "$req" == "$added" ]] && is_new=true && break
        done
        $is_new && continue

        current_line=$(echo "$current_lines" | grep "$req" || true)
        old_line=$(echo "$old_lines" | grep "$req" || true)
        if [[ "$current_line" != "$old_line" ]]; then
            modified_reqs+=("$req")
        fi
    done

    # Changed = added + modified
    changed_reqs=("${added_reqs[@]}" "${modified_reqs[@]}")

    rm -f "$committed_version"
fi

# Output
fmt_array() {
    local arr=("$@")
    if [[ ${#arr[@]} -eq 0 ]]; then echo "[]"; return; fi
    local result=$(printf '"%s",' "${arr[@]}")
    echo "[${result%,}]"
}

if $JSON_MODE; then
    cat << EOF
{
  "changed": $(fmt_array "${changed_reqs[@]}"),
  "added": $(fmt_array "${added_reqs[@]}"),
  "modified": $(fmt_array "${modified_reqs[@]}"),
  "removed": $(fmt_array "${removed_reqs[@]}"),
  "total_changed": ${#changed_reqs[@]}
}
EOF
else
    echo "=== Requirements Diff ==="
    echo "Added: ${#added_reqs[@]}"
    echo "Modified: ${#modified_reqs[@]}"
    echo "Removed: ${#removed_reqs[@]}"
    echo ""
    if [[ ${#changed_reqs[@]} -eq 0 ]]; then
        echo "No changes detected."
    else
        echo "Changed REQs (need acceptance plan update):"
        for req in "${changed_reqs[@]}"; do
            echo "  - $req"
        done
    fi
    if [[ ${#removed_reqs[@]} -gt 0 ]]; then
        echo ""
        echo "Removed REQs (orphaned ATPs may exist):"
        for req in "${removed_reqs[@]}"; do
            echo "  - $req"
        done
    fi
fi
