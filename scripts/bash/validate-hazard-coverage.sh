#!/usr/bin/env bash

# Deterministic coverage validation for hazard analysis V-Model artifacts
#
# Parses system-design.md and hazard-analysis.md using regex to validate
# three independent coverage dimensions:
#   1. Forward coverage: every SYS-NNN has at least one HAZ-NNN entry
#   2. Backward coverage: every HAZ mitigation references a valid REQ/SYS
#   3. State consistency: every operational state in HAZ exists in system-design
#
# Supports partial validation when not all artifacts exist.
#
# Usage: ./validate-hazard-coverage.sh [OPTIONS] <vmodel-dir>
#
# OPTIONS:
#   --json      Output in JSON format (for AI consumption)
#   --partial   Skip backward checks if requirements.md is absent
#
# EXIT CODES:
#   0 = all applicable checks pass
#   1 = gaps found

set -e

JSON_MODE=false
PARTIAL_MODE=false
VMODEL_DIR=""

for arg in "$@"; do
    case "$arg" in
        --json) JSON_MODE=true ;;
        --partial) PARTIAL_MODE=true ;;
        --help|-h)
            echo "Usage: validate-hazard-coverage.sh [--json] [--partial] <vmodel-dir>"
            exit 0
            ;;
        *) VMODEL_DIR="$arg" ;;
    esac
done

if [[ -z "$VMODEL_DIR" ]]; then
    echo "ERROR: vmodel-dir argument required" >&2
    exit 1
fi

SYSTEM_DESIGN="$VMODEL_DIR/system-design.md"
HAZARD_ANALYSIS="$VMODEL_DIR/hazard-analysis.md"
REQUIREMENTS="$VMODEL_DIR/requirements.md"

if [[ ! -f "$SYSTEM_DESIGN" ]]; then
    echo "ERROR: system-design.md not found in $VMODEL_DIR" >&2
    exit 1
fi

if [[ ! -f "$HAZARD_ANALYSIS" ]]; then
    echo "ERROR: hazard-analysis.md not found in $VMODEL_DIR" >&2
    exit 1
fi

# ---- Pass 1: Extract IDs ----

# SYS IDs from system-design.md (Decomposition View only)
sys_ids=($(grep -oE 'SYS-[0-9]{3}' "$SYSTEM_DESIGN" | sort -u))

# HAZ IDs and their table rows from hazard-analysis.md
haz_ids=($(grep -oE 'HAZ-[0-9]{3}' "$HAZARD_ANALYSIS" | sort -u))

total_sys=${#sys_ids[@]}
total_haz=${#haz_ids[@]}

# ---- Pass 2: Forward Coverage (SYS → HAZ) ----
# Every SYS-NNN must appear as a component in at least one HAZ row

# Extract SYS refs from the FMEA table in hazard-analysis.md
haz_sys_refs=($(grep -oE 'SYS-[0-9]{3}' "$HAZARD_ANALYSIS" | sort -u))

forward_gaps=()
forward_covered=0
for sys in "${sys_ids[@]}"; do
    found=false
    for ref in "${haz_sys_refs[@]}"; do
        if [[ "$sys" == "$ref" ]]; then
            found=true
            break
        fi
    done
    if $found; then
        forward_covered=$((forward_covered + 1))
    else
        forward_gaps+=("$sys")
    fi
done

if [[ $total_sys -gt 0 ]]; then
    forward_pct=$((forward_covered * 100 / total_sys))
else
    forward_pct=0
fi

# ---- Pass 3: Backward Coverage (HAZ mitigation → REQ/SYS) ----
# Every HAZ mitigation must reference a valid REQ or SYS that exists

backward_gaps=()
backward_covered=0
backward_total=0

if [[ -f "$REQUIREMENTS" ]] || ! $PARTIAL_MODE; then
    # Collect all valid REQ and SYS IDs
    declare -A valid_ids
    for sys in "${sys_ids[@]}"; do
        valid_ids["$sys"]=1
    done
    if [[ -f "$REQUIREMENTS" ]]; then
        # Exclude deprecated requirements (lines where [DEPRECATED starts a table cell)
        req_ids=($(grep -v '| \[DEPRECATED' "$REQUIREMENTS" | grep -oE 'REQ-([A-Z]+-)?[0-9]{3}' | sort -u))
        for req in "${req_ids[@]}"; do
            valid_ids["$req"]=1
        done
    fi

    # For each HAZ, extract mitigation references from its table row
    for haz in "${haz_ids[@]}"; do
        backward_total=$((backward_total + 1))
        haz_escaped=$(echo "$haz" | sed 's/[.[\*^$()+?{|]/\\&/g')
        row=$(grep -E "^\|[[:space:]]*${haz_escaped}[[:space:]]*\|" "$HAZARD_ANALYSIS" 2>/dev/null || true)
        if [[ -n "$row" ]]; then
            # Extract REQ and SYS references from the mitigation column (column 9)
            mit_refs=$(echo "$row" | awk -F'|' '{print $10}' | grep -oE '(REQ-([A-Z]+-)?[0-9]{3}|SYS-[0-9]{3})' || true)
            if [[ -z "$mit_refs" ]]; then
                backward_gaps+=("$haz: no mitigation references found")
            else
                has_valid=false
                for ref in $mit_refs; do
                    if [[ -n "${valid_ids[$ref]}" ]]; then
                        has_valid=true
                        break
                    fi
                done
                if $has_valid; then
                    backward_covered=$((backward_covered + 1))
                else
                    backward_gaps+=("$haz: mitigation references do not exist in source documents")
                fi
            fi
        fi
    done
fi

if [[ $backward_total -gt 0 ]]; then
    backward_pct=$((backward_covered * 100 / backward_total))
else
    backward_pct=0
fi

# ---- Pass 4: State Consistency ----
# Every operational state in HAZ must exist in system-design.md

# Extract defined states from system-design.md
# Look for states in tables, lists, or state machine diagrams
defined_states=()
# Try to find an "Operational States" section or state references
state_section=$(sed -n '/[Oo]perational [Ss]tates\|[Oo]perating [Mm]odes\|[Ss]ystem [Ss]tates/,/^## /p' "$SYSTEM_DESIGN" 2>/dev/null || true)
if [[ -n "$state_section" ]]; then
    # Extract capitalized state names from table rows (| STATE_NAME | ...)
    while IFS= read -r line; do
        if [[ "$line" =~ ^\|[[:space:]]*([A-Z][A-Z_]+)[[:space:]]*\| ]]; then
            state="${BASH_REMATCH[1]}"
            # Skip table headers
            if [[ "$state" != "STATE" ]] && [[ "$state" != "STATE_NAME" ]] && [[ "$state" != "NAME" ]]; then
                defined_states+=("$state")
            fi
        fi
    done <<< "$state_section"
fi

# If no explicit states found, use implicit NORMAL
if [[ ${#defined_states[@]} -eq 0 ]]; then
    defined_states=("NORMAL")
    implicit_normal=true
else
    implicit_normal=false
fi

# Add "ALL" as always valid (used when severity is same across all states)
defined_states+=("ALL")

# Extract operational states from HAZ FMEA table (column 4)
haz_states=()
state_warnings=()
while IFS= read -r line; do
    if [[ "$line" =~ ^\|[[:space:]]*HAZ-[0-9]{3}[[:space:]]*\| ]]; then
        state=$(echo "$line" | awk -F'|' '{print $5}' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        if [[ -n "$state" ]]; then
            haz_states+=("$state")
        fi
    fi
done < "$HAZARD_ANALYSIS"

# Check each HAZ state against defined states
for hs in "${haz_states[@]}"; do
    found=false
    for ds in "${defined_states[@]}"; do
        if [[ "$hs" == "$ds" ]]; then
            found=true
            break
        fi
    done
    if ! $found; then
        # Check if already in warnings
        already=false
        for w in "${state_warnings[@]}"; do
            if [[ "$w" == "$hs" ]]; then
                already=true
                break
            fi
        done
        if ! $already; then
            state_warnings+=("$hs")
        fi
    fi
done

state_consistent=true
if [[ ${#state_warnings[@]} -gt 0 ]]; then
    state_consistent=false
fi

# ---- Determine overall result ----

has_gaps=false
if [[ ${#forward_gaps[@]} -gt 0 ]]; then
    has_gaps=true
fi
if [[ ${#backward_gaps[@]} -gt 0 ]]; then
    has_gaps=true
fi
if ! $state_consistent; then
    has_gaps=true
fi

# ---- Output ----

fmt_array() {
    local arr=("$@")
    if [[ ${#arr[@]} -eq 0 ]]; then echo "[]"; return; fi
    local result=$(printf '"%s",' "${arr[@]}")
    echo "[${result%,}]"
}

if $JSON_MODE; then
    backward_mode="full"
    if $PARTIAL_MODE && [[ ! -f "$REQUIREMENTS" ]]; then
        backward_mode="skipped"
    fi
    cat << EOF
{
  "total_sys": $total_sys,
  "total_haz": $total_haz,
  "forward_covered": $forward_covered,
  "forward_coverage_pct": $forward_pct,
  "backward_covered": $backward_covered,
  "backward_total": $backward_total,
  "backward_coverage_pct": $backward_pct,
  "backward_mode": "$backward_mode",
  "state_consistent": $state_consistent,
  "implicit_normal": ${implicit_normal},
  "has_gaps": $has_gaps,
  "partial_mode": $PARTIAL_MODE,
  "forward_gaps": $(fmt_array "${forward_gaps[@]}"),
  "backward_gaps": $(fmt_array "${backward_gaps[@]}"),
  "state_warnings": $(fmt_array "${state_warnings[@]}"),
  "defined_states": $(fmt_array "${defined_states[@]}")
}
EOF
else
    echo "=== Hazard Coverage Validation ==="
    if $PARTIAL_MODE; then
        echo "(Partial mode — some checks may be skipped)"
    fi
    echo ""
    echo "Totals: $total_sys SYS | $total_haz HAZ"
    echo ""

    echo "── Forward Coverage (SYS → HAZ) ──"
    echo "  Coverage: $forward_covered/$total_sys ($forward_pct%)"
    if [[ ${#forward_gaps[@]} -gt 0 ]]; then
        echo "  ❌ System components WITHOUT hazard analysis:"
        for gap in "${forward_gaps[@]}"; do
            echo "     - $gap: no hazard analysis mapping found"
        done
    else
        echo "  ✅ All system components have hazard entries"
    fi
    echo ""

    if $PARTIAL_MODE && [[ ! -f "$REQUIREMENTS" ]]; then
        echo "── Backward Coverage (HAZ → REQ/SYS) ──"
        echo "  ⏩ Skipped (requirements.md not found, --partial mode)"
    else
        echo "── Backward Coverage (HAZ → REQ/SYS) ──"
        echo "  Coverage: $backward_covered/$backward_total ($backward_pct%)"
        if [[ ${#backward_gaps[@]} -gt 0 ]]; then
            echo "  ❌ Hazards with broken mitigation references:"
            for gap in "${backward_gaps[@]}"; do
                echo "     - $gap"
            done
        else
            echo "  ✅ All hazard mitigations reference valid IDs"
        fi
    fi
    echo ""

    echo "── State Consistency ──"
    if $implicit_normal; then
        echo "  ⚠️  No operational states defined in system-design.md — using implicit NORMAL state"
    fi
    if $state_consistent; then
        echo "  ✅ All operational states in hazard entries are defined"
    else
        echo "  ❌ Undefined operational states found in hazard entries:"
        for w in "${state_warnings[@]}"; do
            echo "     - $w"
        done
    fi
    echo ""

    if ! $has_gaps; then
        echo "✅ All hazard coverage checks passed."
    else
        echo "❌ Hazard coverage gaps detected — see details above."
    fi
fi

$has_gaps && exit 1 || exit 0
