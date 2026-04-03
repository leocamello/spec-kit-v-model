#!/usr/bin/env bash

# Deterministic impact analysis for V-Model artifacts
#
# Scans all markdown files in a V-Model directory, builds an ID dependency
# graph, and traverses it from one or more changed IDs to identify all
# suspect (potentially affected) artifacts.
#
# Supports three traversal modes:
#   --downward  (default) Traces downstream: what depends on the changed IDs?
#   --upward    Traces upstream: what do the changed IDs depend on?
#   --full      Both directions combined
#
# Usage: ./impact-analysis.sh [OPTIONS] <ID...> <vmodel-dir>
#
# OPTIONS:
#   --downward   Trace downstream dependents (default)
#   --upward     Trace upstream parents
#   --full       Trace both directions
#   --json       Output JSON to stdout instead of markdown file
#   --output F   Write markdown report to F instead of <vmodel-dir>/impact-report.md
#
# EXIT CODES:
#   0 = analysis completed successfully
#   1 = error (invalid args, no artifacts, etc.)

set -e

# ---------- globals populated by build_graph ----------
declare -A REFERENCES        # REFERENCES[id] = "id1 id2 id3" (ids this artifact references)
declare -A REFERENCED_BY     # REFERENCED_BY[id] = "id1 id2 id3" (ids that reference this artifact)
declare -A ALL_IDS           # ALL_IDS[id] = 1 (set of all known ids)

# ---------- globals populated by traversal ----------
declare -A SUSPECTS_DOWN     # SUSPECTS_DOWN[level] = "id1 id2"
declare -A BLAST_DOWN        # BLAST_DOWN[level] = count
declare -a ORDER_DOWN        # re-validation order (bottom-up)

declare -A SUSPECTS_UP       # SUSPECTS_UP[level] = "id1 id2"
declare -A BLAST_UP          # BLAST_UP[level] = count
declare -a ORDER_UP          # re-validation order (top-down)

# ---------- CLI state ----------
DIRECTION="downward"
JSON_MODE=false
OUTPUT_PATH=""
CHANGED_IDS=()
VMODEL_DIR=""

# V-Model level ordering (top to bottom)
LEVELS_TOP_DOWN=(REQ ATP SCN HAZ SYS STP STS ARCH ITP ITS MOD UTP UTS)
LEVELS_BOTTOM_UP=(UTS UTP MOD ITS ITP ARCH STS STP SYS HAZ SCN ATP REQ)

# ID regex pattern matching all known V-Model prefixes
ID_PATTERN='(REQ|ATP|SCN|SYS|STP|STS|ARCH|ITP|ITS|MOD|UTP|UTS|HAZ)(-[A-Z]+)?-[0-9]{3}(-[A-Z][0-9]?)?'

# ================================================================
# MOD-001: scan_files
# ================================================================
scan_files() {
    local dir="$1"
    find "$dir" -name '*.md' -type f 2>/dev/null | sort
}

# ================================================================
# MOD-003: classify_id
# ================================================================
classify_id() {
    local id="$1"
    # Extract prefix: everything before the first hyphen-followed-by-digits
    # REQ-001 → REQ, REQ-NF-001 → REQ-NF, ATP-001-A → ATP, SCN-001-A1 → SCN
    local prefix
    prefix=$(echo "$id" | grep -oE '^(REQ|ATP|SCN|SYS|STP|STS|ARCH|ITP|ITS|MOD|UTP|UTS|HAZ)(-[A-Z]+)?' | head -1)
    # Map compound prefixes to base level
    # Map any compound prefix (e.g., SYS-DR, REQ-NF) to its base level
    case "$prefix" in
        REQ|REQ-*) echo "REQ" ;;
        ATP|ATP-*) echo "ATP" ;;
        SCN|SCN-*) echo "SCN" ;;
        SYS|SYS-*) echo "SYS" ;;
        STP|STP-*) echo "STP" ;;
        STS|STS-*) echo "STS" ;;
        ARCH|ARCH-*) echo "ARCH" ;;
        ITP|ITP-*) echo "ITP" ;;
        ITS|ITS-*) echo "ITS" ;;
        MOD|MOD-*) echo "MOD" ;;
        UTP|UTP-*) echo "UTP" ;;
        UTS|UTS-*) echo "UTS" ;;
        HAZ|HAZ-*) echo "HAZ" ;;
        *) echo "$prefix" ;;
    esac
}

# ================================================================
# MOD-002: build_graph
# ================================================================
build_graph() {
    local file_list="$1"

    # Use awk to extract all edges in a single process per file batch.
    # Output format: "EDGE owner_id ref_id" and "NODE id" lines.
    local edges
    edges=$(echo "$file_list" | xargs awk '
    BEGIN {
        id_pat = "(REQ|ATP|SCN|SYS|STP|STS|ARCH|ITP|ITS|MOD|UTP|UTS|HAZ)(-[A-Z]+)?-[0-9]{3}(-[A-Z][0-9]?)?"
        owner = ""
    }
    # Reset owner at the start of each new file
    FNR == 1 { owner = "" }
    {
        # Extract all IDs on this line
        line = $0
        n = 0
        delete ids
        while (match(line, id_pat)) {
            n++
            ids[n] = substr(line, RSTART, RLENGTH)
            print "NODE " ids[n]
            line = substr(line, RSTART + RLENGTH)
        }
        if (n == 0) next

        # Heading or table row → first ID is the owner
        if ($0 ~ /^#/ || $0 ~ /^[[:space:]]*\|/) {
            owner = ids[1]
        }

        # If we have an owner, record cross-references
        if (owner != "") {
            for (i = 1; i <= n; i++) {
                if (ids[i] != owner) {
                    print "EDGE " owner " " ids[i]
                }
            }
        } else if (n >= 2) {
            # No owner yet: first ID becomes owner
            owner = ids[1]
            for (i = 2; i <= n; i++) {
                print "EDGE " owner " " ids[i]
            }
        }

        # Reset owner on section boundaries
        if ($0 ~ /^---$/ || $0 ~ /^$/) owner = ""
    }
    ' 2>/dev/null)

    # Parse awk output into Bash associative arrays
    while IFS=' ' read -r tag arg1 arg2; do
        case "$tag" in
            NODE)
                ALL_IDS["$arg1"]=1
                ;;
            EDGE)
                # arg1 references arg2
                if [[ -z "${REFERENCES[$arg1]}" ]]; then
                    REFERENCES["$arg1"]="$arg2"
                else
                    case " ${REFERENCES[$arg1]} " in
                        *" $arg2 "*) ;;  # already present
                        *) REFERENCES["$arg1"]="${REFERENCES[$arg1]} $arg2" ;;
                    esac
                fi
                # arg2 is referenced by arg1
                if [[ -z "${REFERENCED_BY[$arg2]}" ]]; then
                    REFERENCED_BY["$arg2"]="$arg1"
                else
                    case " ${REFERENCED_BY[$arg2]} " in
                        *" $arg1 "*) ;;  # already present
                        *) REFERENCED_BY["$arg2"]="${REFERENCED_BY[$arg2]} $arg1" ;;
                    esac
                fi
                ;;
        esac
    done <<< "$edges"
}

# ================================================================
# MOD-012: warn_unknown_id
# ================================================================
warn_unknown_id() {
    local valid_ids=()
    for id in "${CHANGED_IDS[@]}"; do
        if [[ -z "${ALL_IDS[$id]}" ]] && [[ -z "${REFERENCES[$id]}" ]] && [[ -z "${REFERENCED_BY[$id]}" ]]; then
            echo "Warning: ID '$id' not found in any V-Model artifact" >&2
        else
            valid_ids+=("$id")
        fi
    done
    CHANGED_IDS=("${valid_ids[@]}")
}

# ================================================================
# MOD-004: traverse_downward
# ================================================================
traverse_downward() {
    local -A visited
    local queue=("${CHANGED_IDS[@]}")
    local head=0

    # Mark changed IDs as visited (they are not suspects themselves)
    for id in "${CHANGED_IDS[@]}"; do
        visited["$id"]=1
    done

    while [[ $head -lt ${#queue[@]} ]]; do
        local current="${queue[$head]}"
        head=$((head + 1))

        # Get all IDs that reference the current ID (downstream dependents)
        local refs="${REFERENCED_BY[$current]}"
        [[ -z "$refs" ]] && continue

        for dep in $refs; do
            if [[ -n "${visited[$dep]}" ]]; then
                continue
            fi
            visited["$dep"]=1

            local level
            level=$(classify_id "$dep")
            [[ -z "$level" ]] && continue

            if [[ -z "${SUSPECTS_DOWN[$level]}" ]]; then
                SUSPECTS_DOWN["$level"]="$dep"
                BLAST_DOWN["$level"]=1
            else
                SUSPECTS_DOWN["$level"]="${SUSPECTS_DOWN[$level]} $dep"
                BLAST_DOWN["$level"]=$(( ${BLAST_DOWN[$level]} + 1 ))
            fi

            queue+=("$dep")
        done
    done

    # Build re-validation order (bottom-up)
    ORDER_DOWN=()
    for level in "${LEVELS_BOTTOM_UP[@]}"; do
        if [[ -n "${SUSPECTS_DOWN[$level]}" ]]; then
            for id in $(echo "${SUSPECTS_DOWN[$level]}" | tr ' ' '\n' | sort); do
                ORDER_DOWN+=("$id")
            done
        fi
    done
}

# ================================================================
# MOD-005: traverse_upward
# ================================================================
traverse_upward() {
    local -A visited
    local queue=("${CHANGED_IDS[@]}")
    local head=0

    for id in "${CHANGED_IDS[@]}"; do
        visited["$id"]=1
    done

    while [[ $head -lt ${#queue[@]} ]]; do
        local current="${queue[$head]}"
        head=$((head + 1))

        # Get all IDs that this artifact references (upstream parents)
        local refs="${REFERENCES[$current]}"
        [[ -z "$refs" ]] && continue

        for parent in $refs; do
            if [[ -n "${visited[$parent]}" ]]; then
                continue
            fi
            visited["$parent"]=1

            local level
            level=$(classify_id "$parent")
            [[ -z "$level" ]] && continue

            if [[ -z "${SUSPECTS_UP[$level]}" ]]; then
                SUSPECTS_UP["$level"]="$parent"
                BLAST_UP["$level"]=1
            else
                SUSPECTS_UP["$level"]="${SUSPECTS_UP[$level]} $parent"
                BLAST_UP["$level"]=$(( ${BLAST_UP[$level]} + 1 ))
            fi

            queue+=("$parent")
        done
    done

    # Build re-validation order (top-down)
    ORDER_UP=()
    for level in "${LEVELS_TOP_DOWN[@]}"; do
        if [[ -n "${SUSPECTS_UP[$level]}" ]]; then
            for id in $(echo "${SUSPECTS_UP[$level]}" | tr ' ' '\n' | sort); do
                ORDER_UP+=("$id")
            done
        fi
    done
}

# ================================================================
# MOD-006: traverse_full
# ================================================================
traverse_full() {
    traverse_downward
    traverse_upward
}

# ================================================================
# MOD-007: build_revalidation_order (used internally by traversals)
# ================================================================
# (Integrated into traverse_downward and traverse_upward above)

# ================================================================
# Helper: compute total blast radius
# ================================================================
compute_blast_total() {
    local -n blast_map=$1
    local total=0
    for level in "${!blast_map[@]}"; do
        total=$(( total + ${blast_map[$level]} ))
    done
    echo "$total"
}

# ================================================================
# MOD-008: format_markdown
# ================================================================
format_markdown() {
    local output_file="$1"
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    {
        echo "# Impact Analysis Report"
        echo ""
        echo "**Generated**: $timestamp"
        echo "**Direction**: $DIRECTION"
        echo "**Source**: \`$VMODEL_DIR\`"
        echo ""

        # Changed IDs
        echo "## Changed IDs"
        echo ""
        echo "| ID | Type |"
        echo "|----|------|"
        for id in "${CHANGED_IDS[@]}"; do
            local level
            level=$(classify_id "$id")
            echo "| $id | $level |"
        done
        echo ""

        if [[ "$DIRECTION" == "full" ]]; then
            # Downstream suspects
            local down_total
            down_total=$(compute_blast_total BLAST_DOWN)
            echo "## Downstream Suspects"
            echo ""
            if [[ $down_total -eq 0 ]]; then
                echo "No downstream suspects found."
                echo ""
            else
                for level in "${LEVELS_TOP_DOWN[@]}"; do
                    if [[ -n "${SUSPECTS_DOWN[$level]}" ]]; then
                        echo "### $level"
                        echo ""
                        for id in $(echo "${SUSPECTS_DOWN[$level]}" | tr ' ' '\n' | sort); do
                            echo "- $id"
                        done
                        echo ""
                    fi
                done
            fi

            # Upstream suspects
            local up_total
            up_total=$(compute_blast_total BLAST_UP)
            echo "## Upstream Suspects"
            echo ""
            if [[ $up_total -eq 0 ]]; then
                echo "No upstream suspects found."
                echo ""
            else
                for level in "${LEVELS_TOP_DOWN[@]}"; do
                    if [[ -n "${SUSPECTS_UP[$level]}" ]]; then
                        echo "### $level"
                        echo ""
                        for id in $(echo "${SUSPECTS_UP[$level]}" | tr ' ' '\n' | sort); do
                            echo "- $id"
                        done
                        echo ""
                    fi
                done
            fi

            # Blast radius
            local total=$(( down_total + up_total ))
            echo "## Blast Radius"
            echo ""
            echo "| Direction | Level | Count |"
            echo "|-----------|-------|-------|"
            for level in "${LEVELS_TOP_DOWN[@]}"; do
                [[ -n "${BLAST_DOWN[$level]}" ]] && echo "| Downstream | $level | ${BLAST_DOWN[$level]} |"
            done
            for level in "${LEVELS_TOP_DOWN[@]}"; do
                [[ -n "${BLAST_UP[$level]}" ]] && echo "| Upstream | $level | ${BLAST_UP[$level]} |"
            done
            echo "| **Total** | | **$total** |"
            echo ""

            # Re-validation order
            echo "## Re-validation Order"
            echo ""
            echo "### Downstream (bottom-up)"
            echo ""
            local idx=1
            for id in "${ORDER_DOWN[@]}"; do
                echo "$idx. $id"
                idx=$((idx + 1))
            done
            echo ""
            echo "### Upstream (top-down)"
            echo ""
            idx=1
            for id in "${ORDER_UP[@]}"; do
                echo "$idx. $id"
                idx=$((idx + 1))
            done

        else
            # Single direction
            local -n suspects_ref
            local -n blast_ref
            local -n order_ref
            local level_order

            if [[ "$DIRECTION" == "downward" ]]; then
                # Use nameref to the downward arrays
                local total
                total=$(compute_blast_total BLAST_DOWN)

                echo "## Suspect Artifacts"
                echo ""
                if [[ $total -eq 0 ]]; then
                    echo "No suspect artifacts found."
                    echo ""
                else
                    for level in "${LEVELS_TOP_DOWN[@]}"; do
                        if [[ -n "${SUSPECTS_DOWN[$level]}" ]]; then
                            echo "### $level"
                            echo ""
                            for id in $(echo "${SUSPECTS_DOWN[$level]}" | tr ' ' '\n' | sort); do
                                echo "- $id"
                            done
                            echo ""
                        fi
                    done
                fi

                echo "## Blast Radius"
                echo ""
                echo "| Level | Count |"
                echo "|-------|-------|"
                for level in "${LEVELS_TOP_DOWN[@]}"; do
                    [[ -n "${BLAST_DOWN[$level]}" ]] && echo "| $level | ${BLAST_DOWN[$level]} |"
                done
                echo "| **Total** | **$total** |"
                echo ""

                echo "## Re-validation Order"
                echo ""
                local idx=1
                for id in "${ORDER_DOWN[@]}"; do
                    echo "$idx. $id"
                    idx=$((idx + 1))
                done
            else
                # upward
                local total
                total=$(compute_blast_total BLAST_UP)

                echo "## Suspect Artifacts"
                echo ""
                if [[ $total -eq 0 ]]; then
                    echo "No suspect artifacts found."
                    echo ""
                else
                    for level in "${LEVELS_TOP_DOWN[@]}"; do
                        if [[ -n "${SUSPECTS_UP[$level]}" ]]; then
                            echo "### $level"
                            echo ""
                            for id in $(echo "${SUSPECTS_UP[$level]}" | tr ' ' '\n' | sort); do
                                echo "- $id"
                            done
                            echo ""
                        fi
                    done
                fi

                echo "## Blast Radius"
                echo ""
                echo "| Level | Count |"
                echo "|-------|-------|"
                for level in "${LEVELS_TOP_DOWN[@]}"; do
                    [[ -n "${BLAST_UP[$level]}" ]] && echo "| $level | ${BLAST_UP[$level]} |"
                done
                echo "| **Total** | **$total** |"
                echo ""

                echo "## Re-validation Order"
                echo ""
                local idx=1
                for id in "${ORDER_UP[@]}"; do
                    echo "$idx. $id"
                    idx=$((idx + 1))
                done
            fi
        fi
    } > "$output_file"
}

# ================================================================
# MOD-009: format_json
# ================================================================
format_json() {
    # Build JSON using printf (no external tools)
    local json=""

    # changed_ids array
    local ids_json=""
    for id in "${CHANGED_IDS[@]}"; do
        [[ -n "$ids_json" ]] && ids_json="$ids_json,"
        ids_json="$ids_json\"$id\""
    done

    if [[ "$DIRECTION" == "full" ]]; then
        # suspect_artifacts with upstream/downstream
        local down_json=""
        for level in "${LEVELS_TOP_DOWN[@]}"; do
            if [[ -n "${SUSPECTS_DOWN[$level]}" ]]; then
                [[ -n "$down_json" ]] && down_json="$down_json,"
                local items=""
                for id in $(echo "${SUSPECTS_DOWN[$level]}" | tr ' ' '\n' | sort); do
                    [[ -n "$items" ]] && items="$items,"
                    items="$items\"$id\""
                done
                down_json="$down_json\"$level\":[$items]"
            fi
        done

        local up_json=""
        for level in "${LEVELS_TOP_DOWN[@]}"; do
            if [[ -n "${SUSPECTS_UP[$level]}" ]]; then
                [[ -n "$up_json" ]] && up_json="$up_json,"
                local items=""
                for id in $(echo "${SUSPECTS_UP[$level]}" | tr ' ' '\n' | sort); do
                    [[ -n "$items" ]] && items="$items,"
                    items="$items\"$id\""
                done
                up_json="$up_json\"$level\":[$items]"
            fi
        done

        local suspects_json="\"downstream\":{${down_json}},\"upstream\":{${up_json}}"

        # revalidation_order (combine both, deduplicate) — build first to compute unique blast radius
        local order_json=""
        local -A order_seen
        local -A unique_blast
        local unique_total=0
        for id in "${ORDER_DOWN[@]}"; do
            [[ -n "${order_seen[$id]}" ]] && continue
            order_seen["$id"]=1
            local lvl
            lvl=$(classify_id "$id")
            unique_blast["$lvl"]=$(( ${unique_blast[$lvl]:-0} + 1 ))
            unique_total=$(( unique_total + 1 ))
            [[ -n "$order_json" ]] && order_json="$order_json,"
            order_json="$order_json\"$id\""
        done
        for id in "${ORDER_UP[@]}"; do
            [[ -n "${order_seen[$id]}" ]] && continue
            order_seen["$id"]=1
            local lvl
            lvl=$(classify_id "$id")
            unique_blast["$lvl"]=$(( ${unique_blast[$lvl]:-0} + 1 ))
            unique_total=$(( unique_total + 1 ))
            [[ -n "$order_json" ]] && order_json="$order_json,"
            order_json="$order_json\"$id\""
        done

        # blast_radius (from deduplicated suspects)
        local by_level_json=""
        local total=$unique_total

        for level in "${LEVELS_TOP_DOWN[@]}"; do
            local count=${unique_blast[$level]:-0}
            if [[ $count -gt 0 ]]; then
                [[ -n "$by_level_json" ]] && by_level_json="$by_level_json,"
                by_level_json="$by_level_json\"$level\":$count"
            fi
        done

        printf '{"changed_ids":[%s],"direction":"%s","suspect_artifacts":{%s},"blast_radius":{"total":%d,"by_level":{%s}},"revalidation_order":[%s]}\n' \
            "$ids_json" "$DIRECTION" "$suspects_json" "$total" "$by_level_json" "$order_json"
    else
        # Single direction
        local suspect_json=""
        local total=0
        local by_level_json=""
        local order_json=""

        if [[ "$DIRECTION" == "downward" ]]; then
            for level in "${LEVELS_TOP_DOWN[@]}"; do
                if [[ -n "${SUSPECTS_DOWN[$level]}" ]]; then
                    [[ -n "$suspect_json" ]] && suspect_json="$suspect_json,"
                    local items=""
                    for id in $(echo "${SUSPECTS_DOWN[$level]}" | tr ' ' '\n' | sort); do
                        [[ -n "$items" ]] && items="$items,"
                        items="$items\"$id\""
                    done
                    suspect_json="$suspect_json\"$level\":[$items]"
                fi
            done

            total=$(compute_blast_total BLAST_DOWN)
            for level in "${LEVELS_TOP_DOWN[@]}"; do
                if [[ -n "${BLAST_DOWN[$level]}" ]]; then
                    [[ -n "$by_level_json" ]] && by_level_json="$by_level_json,"
                    by_level_json="$by_level_json\"$level\":${BLAST_DOWN[$level]}"
                fi
            done

            for id in "${ORDER_DOWN[@]}"; do
                [[ -n "$order_json" ]] && order_json="$order_json,"
                order_json="$order_json\"$id\""
            done
        else
            # upward
            for level in "${LEVELS_TOP_DOWN[@]}"; do
                if [[ -n "${SUSPECTS_UP[$level]}" ]]; then
                    [[ -n "$suspect_json" ]] && suspect_json="$suspect_json,"
                    local items=""
                    for id in $(echo "${SUSPECTS_UP[$level]}" | tr ' ' '\n' | sort); do
                        [[ -n "$items" ]] && items="$items,"
                        items="$items\"$id\""
                    done
                    suspect_json="$suspect_json\"$level\":[$items]"
                fi
            done

            total=$(compute_blast_total BLAST_UP)
            for level in "${LEVELS_TOP_DOWN[@]}"; do
                if [[ -n "${BLAST_UP[$level]}" ]]; then
                    [[ -n "$by_level_json" ]] && by_level_json="$by_level_json,"
                    by_level_json="$by_level_json\"$level\":${BLAST_UP[$level]}"
                fi
            done

            for id in "${ORDER_UP[@]}"; do
                [[ -n "$order_json" ]] && order_json="$order_json,"
                order_json="$order_json\"$id\""
            done
        fi

        printf '{"changed_ids":[%s],"direction":"%s","suspect_artifacts":{%s},"blast_radius":{"total":%d,"by_level":{%s}},"revalidation_order":[%s]}\n' \
            "$ids_json" "$DIRECTION" "$suspect_json" "$total" "$by_level_json" "$order_json"
    fi
}

# ================================================================
# MOD-010: parse_args
# ================================================================
parse_args() {
    local direction_set=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --downward)
                if $direction_set && [[ "$DIRECTION" != "downward" ]]; then
                    echo "ERROR: --downward, --upward, and --full are mutually exclusive" >&2
                    exit 1
                fi
                DIRECTION="downward"
                direction_set=true
                shift
                ;;
            --upward)
                if $direction_set && [[ "$DIRECTION" != "upward" ]]; then
                    echo "ERROR: --downward, --upward, and --full are mutually exclusive" >&2
                    exit 1
                fi
                DIRECTION="upward"
                direction_set=true
                shift
                ;;
            --full)
                if $direction_set && [[ "$DIRECTION" != "full" ]]; then
                    echo "ERROR: --downward, --upward, and --full are mutually exclusive" >&2
                    exit 1
                fi
                DIRECTION="full"
                direction_set=true
                shift
                ;;
            --json)
                JSON_MODE=true
                shift
                ;;
            --output)
                if [[ -z "$2" ]]; then
                    echo "ERROR: --output requires a file path argument" >&2
                    exit 1
                fi
                OUTPUT_PATH="$2"
                shift 2
                ;;
            --help|-h)
                echo "Usage: impact-analysis.sh [--downward|--upward|--full] [--json] [--output FILE] <ID...> <vmodel-dir>"
                exit 0
                ;;
            -*)
                echo "ERROR: Unknown option: $1" >&2
                exit 1
                ;;
            *)
                # Positional argument: collect all, last one is vmodel-dir
                CHANGED_IDS+=("$1")
                shift
                ;;
        esac
    done

    # Last positional arg is the V-Model directory
    if [[ ${#CHANGED_IDS[@]} -lt 2 ]]; then
        echo "ERROR: At least one ID and a V-Model directory path are required" >&2
        echo "Usage: impact-analysis.sh [--downward|--upward|--full] [--json] [--output FILE] <ID...> <vmodel-dir>" >&2
        exit 1
    fi

    # Pop last element as vmodel-dir
    VMODEL_DIR="${CHANGED_IDS[-1]}"
    unset 'CHANGED_IDS[-1]'

    # Validate directory
    if [[ ! -d "$VMODEL_DIR" ]]; then
        echo "ERROR: Directory not found: $VMODEL_DIR" >&2
        exit 1
    fi

    # Check for markdown files
    local md_count
    md_count=$(find "$VMODEL_DIR" -name '*.md' -type f 2>/dev/null | head -1 | wc -l)
    if [[ "$md_count" -eq 0 ]]; then
        echo "ERROR: No V-Model artifacts found in $VMODEL_DIR" >&2
        exit 1
    fi

    # Default output path
    if [[ -z "$OUTPUT_PATH" ]]; then
        OUTPUT_PATH="$VMODEL_DIR/impact-report.md"
    fi
}

# ================================================================
# MOD-011: main
# ================================================================
main() {
    parse_args "$@"

    # Scan files
    local file_list
    file_list=$(scan_files "$VMODEL_DIR")

    if [[ -z "$file_list" ]]; then
        echo "ERROR: No V-Model artifacts found in $VMODEL_DIR" >&2
        exit 1
    fi

    # Build graph
    build_graph "$file_list"

    # Warn about unknown IDs
    warn_unknown_id

    if [[ ${#CHANGED_IDS[@]} -eq 0 ]]; then
        echo "ERROR: None of the specified IDs were found in V-Model artifacts" >&2
        exit 1
    fi

    # Traverse
    case "$DIRECTION" in
        downward) traverse_downward ;;
        upward)   traverse_upward ;;
        full)     traverse_full ;;
    esac

    # Output
    if $JSON_MODE; then
        format_json
    else
        format_markdown "$OUTPUT_PATH"
        echo "Impact report written to $OUTPUT_PATH"
    fi
}

main "$@"
