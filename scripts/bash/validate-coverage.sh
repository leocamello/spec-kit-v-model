#!/usr/bin/env bash

# Deterministic coverage validation for V-Model artifacts
#
# Parses requirements.md and acceptance-plan.md using regex to extract
# REQ-NNN, ATP-NNN-X, and SCN-NNN-X# IDs. Cross-references them to
# verify 100% coverage at each tier.
#
# Usage: ./validate-coverage.sh [OPTIONS] <vmodel-dir>
#
# OPTIONS:
#   --json    Output in JSON format (for AI consumption)
#
# EXIT CODES:
#   0 = full coverage
#   1 = gaps found

set -e

JSON_MODE=false
VMODEL_DIR=""

for arg in "$@"; do
    case "$arg" in
        --json) JSON_MODE=true ;;
        --help|-h)
            echo "Usage: validate-coverage.sh [--json] <vmodel-dir>"
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
ACCEPTANCE="$VMODEL_DIR/acceptance-plan.md"

if [[ ! -f "$REQUIREMENTS" ]]; then
    echo "ERROR: requirements.md not found in $VMODEL_DIR" >&2
    exit 1
fi

if [[ ! -f "$ACCEPTANCE" ]]; then
    echo "ERROR: acceptance-plan.md not found in $VMODEL_DIR" >&2
    exit 1
fi

# Extract all IDs using regex
# REQ IDs: REQ-NNN, REQ-NF-NNN, REQ-IF-NNN, REQ-CN-NNN
req_ids=($(grep -oE 'REQ-([A-Z]+-)?[0-9]{3}' "$REQUIREMENTS" | sort -u))

# ATP IDs: ATP-NNN-X (letter suffix)
atp_ids=($(grep -oE 'ATP-[0-9]{3}-[A-Z]' "$ACCEPTANCE" | sort -u))

# SCN IDs: SCN-NNN-X# (letter + number suffix)
scn_ids=($(grep -oE 'SCN-[0-9]{3}-[A-Z][0-9]+' "$ACCEPTANCE" | sort -u))

total_reqs=${#req_ids[@]}
total_atps=${#atp_ids[@]}
total_scns=${#scn_ids[@]}

# Check Tier 1: Every REQ has at least one ATP
reqs_without_atp=()
for req in "${req_ids[@]}"; do
    # Extract the numeric part (handles REQ-001, REQ-NF-001, etc.)
    req_num=$(echo "$req" | grep -oE '[0-9]{3}$')
    has_atp=false
    for atp in "${atp_ids[@]}"; do
        atp_num=$(echo "$atp" | grep -oE '[0-9]{3}')
        if [[ "$req_num" == "$atp_num" ]]; then
            has_atp=true
            break
        fi
    done
    if ! $has_atp; then
        reqs_without_atp+=("$req")
    fi
done

# Check Tier 2: Every ATP has at least one SCN
atps_without_scn=()
for atp in "${atp_ids[@]}"; do
    # ATP-001-A -> look for SCN-001-A*
    atp_suffix=$(echo "$atp" | sed 's/ATP-//')  # 001-A
    has_scn=false
    for scn in "${scn_ids[@]}"; do
        scn_suffix=$(echo "$scn" | sed 's/SCN-//')  # 001-A1
        if [[ "$scn_suffix" == "$atp_suffix"* ]]; then
            has_scn=true
            break
        fi
    done
    if ! $has_scn; then
        atps_without_scn+=("$atp")
    fi
done

# Check for orphaned ATPs (ATP referencing non-existent REQ)
orphaned_atps=()
for atp in "${atp_ids[@]}"; do
    atp_num=$(echo "$atp" | grep -oE '[0-9]{3}')
    has_req=false
    for req in "${req_ids[@]}"; do
        req_num=$(echo "$req" | grep -oE '[0-9]{3}$')
        if [[ "$atp_num" == "$req_num" ]]; then
            has_req=true
            break
        fi
    done
    if ! $has_req; then
        orphaned_atps+=("$atp")
    fi
done

# Calculate coverage
reqs_covered=$((total_reqs - ${#reqs_without_atp[@]}))
atps_covered=$((total_atps - ${#atps_without_scn[@]}))

if [[ $total_reqs -gt 0 ]]; then
    req_coverage=$((reqs_covered * 100 / total_reqs))
else
    req_coverage=0
fi

if [[ $total_atps -gt 0 ]]; then
    atp_coverage=$((atps_covered * 100 / total_atps))
else
    atp_coverage=0
fi

has_gaps=false
if [[ ${#reqs_without_atp[@]} -gt 0 ]] || [[ ${#atps_without_scn[@]} -gt 0 ]]; then
    has_gaps=true
fi

# Output results
if $JSON_MODE; then
    # Build JSON arrays
    fmt_array() {
        local arr=("$@")
        if [[ ${#arr[@]} -eq 0 ]]; then echo "[]"; return; fi
        local result=$(printf '"%s",' "${arr[@]}")
        echo "[${result%,}]"
    }

    cat << EOF
{
  "total_reqs": $total_reqs,
  "total_atps": $total_atps,
  "total_scns": $total_scns,
  "reqs_covered": $reqs_covered,
  "atps_covered": $atps_covered,
  "req_coverage_pct": $req_coverage,
  "atp_coverage_pct": $atp_coverage,
  "has_gaps": $has_gaps,
  "reqs_without_atp": $(fmt_array "${reqs_without_atp[@]}"),
  "atps_without_scn": $(fmt_array "${atps_without_scn[@]}"),
  "orphaned_atps": $(fmt_array "${orphaned_atps[@]}")
}
EOF
else
    echo "=== V-Model Coverage Validation ==="
    echo ""
    echo "Totals: $total_reqs REQs | $total_atps ATPs | $total_scns SCNs"
    echo "REQ → ATP coverage: $reqs_covered/$total_reqs ($req_coverage%)"
    echo "ATP → SCN coverage: $atps_covered/$total_atps ($atp_coverage%)"
    echo ""

    if [[ ${#reqs_without_atp[@]} -gt 0 ]]; then
        echo "❌ Requirements WITHOUT test cases:"
        for req in "${reqs_without_atp[@]}"; do
            echo "   - $req"
        done
    fi

    if [[ ${#atps_without_scn[@]} -gt 0 ]]; then
        echo "❌ Test cases WITHOUT scenarios:"
        for atp in "${atps_without_scn[@]}"; do
            echo "   - $atp"
        done
    fi

    if [[ ${#orphaned_atps[@]} -gt 0 ]]; then
        echo "⚠️  Orphaned test cases (no matching requirement):"
        for atp in "${orphaned_atps[@]}"; do
            echo "   - $atp"
        done
    fi

    if ! $has_gaps; then
        echo "✅ Full coverage — all requirements have test cases and scenarios."
    fi
fi

# Exit with non-zero if gaps exist
$has_gaps && exit 1 || exit 0
