#!/usr/bin/env bash

# Deterministic traceability matrix builder for V-Model artifacts
#
# Parses requirements.md and acceptance-plan.md using regex to build
# a complete traceability matrix in markdown format.
#
# Usage: ./build-matrix.sh <vmodel-dir> [--output <file>]
#
# If --output is not specified, prints to stdout.

set -e

VMODEL_DIR=""
OUTPUT=""

for arg in "$@"; do
    case "$arg" in
        --output) shift_next=true ;;
        --help|-h)
            echo "Usage: build-matrix.sh <vmodel-dir> [--output <file>]"
            exit 0
            ;;
        *)
            if [[ "${shift_next:-}" == "true" ]]; then
                OUTPUT="$arg"
                shift_next=false
            else
                VMODEL_DIR="$arg"
            fi
            ;;
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

# Extract REQ IDs and their descriptions from the requirements table
# Matches lines like: | REQ-001 | Description text | ...
declare -A req_descriptions
while IFS= read -r line; do
    if [[ "$line" =~ \|[[:space:]]*(REQ-([A-Z]+-)?[0-9]{3})[[:space:]]*\|[[:space:]]*([^|]+) ]]; then
        req_id="${BASH_REMATCH[1]}"
        req_desc=$(echo "${BASH_REMATCH[3]}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        req_descriptions["$req_id"]="$req_desc"
    fi
done < "$REQUIREMENTS"

# Extract ATP sections: "#### Test Case: ATP-{CAT?-}NNN-X (Description)"
declare -A atp_descriptions
atp_regex='Test Case: (ATP-([A-Z]+-)?[0-9]{3}-[A-Z])[[:space:]]*\(([^)]+)\)'
while IFS= read -r line; do
    if [[ "$line" =~ $atp_regex ]]; then
        atp_id="${BASH_REMATCH[1]}"
        atp_desc="${BASH_REMATCH[3]}"
        atp_descriptions["$atp_id"]="$atp_desc"
    fi
done < "$ACCEPTANCE"

# Extract SCN IDs (with optional category prefix)
scn_ids=($(grep -oE 'SCN-([A-Z]+-)?[0-9]{3}-[A-Z][0-9]+' "$ACCEPTANCE" | sort -u))

# Get sorted unique REQ IDs
req_ids=($(echo "${!req_descriptions[@]}" | tr ' ' '\n' | sort))
atp_ids=($(echo "${!atp_descriptions[@]}" | tr ' ' '\n' | sort))

total_reqs=${#req_ids[@]}
total_atps=${#atp_ids[@]}
total_scns=${#scn_ids[@]}

# Helper: extract base key for matching
# REQ-001 -> 001, REQ-NF-001 -> NF-001
req_base_key() { echo "$1" | sed 's/^REQ-//'; }
# ATP-001-A -> 001, ATP-NF-001-A -> NF-001
atp_base_key() { echo "$1" | sed 's/^ATP-//' | sed 's/-[A-Z]$//'; }
# ATP-001-A -> 001-A, ATP-NF-001-A -> NF-001-A
atp_full_key() { echo "$1" | sed 's/^ATP-//'; }
# SCN-001-A1 -> 001-A1, SCN-NF-001-A1 -> NF-001-A1
scn_full_key() { echo "$1" | sed 's/^SCN-//'; }

# Count coverage
reqs_with_atp=0
atps_with_scn=0

# Build the matrix output
{
    echo "| Requirement ID | Requirement Description | Test Case ID (ATP) | Validation Condition | Scenario ID (SCN) | Status |"
    echo "|----------------|------------------------|--------------------|----------------------|--------------------|--------|"

    for req in "${req_ids[@]}"; do
        req_key=$(req_base_key "$req")
        req_desc="${req_descriptions[$req]}"
        first_row=true
        has_atp=false

        for atp in "${atp_ids[@]}"; do
            atp_key=$(atp_base_key "$atp")
            if [[ "$atp_key" == "$req_key" ]]; then
                has_atp=true
                atp_desc="${atp_descriptions[$atp]}"
                atp_fkey=$(atp_full_key "$atp")
                atp_has_scn=false

                for scn in "${scn_ids[@]}"; do
                    scn_fkey=$(scn_full_key "$scn")
                    if [[ "$scn_fkey" == "$atp_fkey"* ]]; then
                        atp_has_scn=true
                        if $first_row; then
                            echo "| **$req** | $req_desc | $atp | $atp_desc | $scn | ⬜ Untested |"
                            first_row=false
                        else
                            echo "| | | $atp | $atp_desc | $scn | ⬜ Untested |"
                        fi
                    fi
                done

                if ! $atp_has_scn; then
                    if $first_row; then
                        echo "| **$req** | $req_desc | $atp | $atp_desc | ❌ MISSING | ⬜ Untested |"
                        first_row=false
                    else
                        echo "| | | $atp | $atp_desc | ❌ MISSING | ⬜ Untested |"
                    fi
                else
                    atps_with_scn=$((atps_with_scn + 1))
                fi
            fi
        done

        if $has_atp; then
            reqs_with_atp=$((reqs_with_atp + 1))
        else
            if $first_row; then
                echo "| **$req** | $req_desc | ❌ MISSING | — | — | ⬜ Untested |"
            fi
        fi
    done
} > /tmp/vmodel-matrix-body.md

# Calculate coverage percentages
if [[ $total_reqs -gt 0 ]]; then
    req_pct=$((reqs_with_atp * 100 / total_reqs))
else
    req_pct=0
fi
if [[ $total_atps -gt 0 ]]; then
    atp_pct=$((atps_with_scn * 100 / total_atps))
else
    atp_pct=0
fi

# Find gaps
reqs_without_atp=()
for req in "${req_ids[@]}"; do
    req_key=$(req_base_key "$req")
    has_atp=false
    for atp in "${atp_ids[@]}"; do
        atp_key=$(atp_base_key "$atp")
        [[ "$atp_key" == "$req_key" ]] && has_atp=true && break
    done
    $has_atp || reqs_without_atp+=("$req")
done

orphaned_atps=()
for atp in "${atp_ids[@]}"; do
    atp_key=$(atp_base_key "$atp")
    has_req=false
    for req in "${req_ids[@]}"; do
        req_key=$(req_base_key "$req")
        [[ "$atp_key" == "$req_key" ]] && has_req=true && break
    done
    $has_req || orphaned_atps+=("$atp")
done

# Compose full output
DATE=$(date -u +"%Y-%m-%d")
{
    echo "# Traceability Matrix"
    echo ""
    echo "**Generated**: $DATE"
    echo "**Source**: \`$VMODEL_DIR/\`"
    echo ""
    echo "## Matrix"
    echo ""
    cat /tmp/vmodel-matrix-body.md
    echo ""
    echo "## Coverage Metrics"
    echo ""
    echo "| Metric | Value |"
    echo "|--------|-------|"
    echo "| **Total Requirements** | $total_reqs |"
    echo "| **Total Test Cases** | $total_atps |"
    echo "| **Total Scenarios** | $total_scns |"
    echo "| **REQ → ATP Coverage** | $reqs_with_atp/$total_reqs ($req_pct%) |"
    echo "| **ATP → SCN Coverage** | $atps_with_scn/$total_atps ($atp_pct%) |"
    echo ""
    echo "## Gap Analysis"
    echo ""
    echo "### Uncovered Requirements"
    echo ""
    if [[ ${#reqs_without_atp[@]} -eq 0 ]]; then
        echo "None — full coverage."
    else
        for req in "${reqs_without_atp[@]}"; do echo "- $req"; done
    fi
    echo ""
    echo "### Orphaned Test Cases"
    echo ""
    if [[ ${#orphaned_atps[@]} -eq 0 ]]; then
        echo "None — all tests trace to requirements."
    else
        for atp in "${orphaned_atps[@]}"; do echo "- $atp"; done
    fi
    echo ""
    echo "## Audit Notes"
    echo ""
    echo "- **Matrix generated by**: \`build-matrix.sh\` (deterministic regex parser)"
    echo "- **Source documents**: \`requirements.md\`, \`acceptance-plan.md\`"
    echo "- **Last validated**: $DATE"
} > /tmp/vmodel-matrix-full.md

rm -f /tmp/vmodel-matrix-body.md

if [[ -n "$OUTPUT" ]]; then
    cp /tmp/vmodel-matrix-full.md "$OUTPUT"
    echo "Traceability matrix written to $OUTPUT"
else
    cat /tmp/vmodel-matrix-full.md
fi

rm -f /tmp/vmodel-matrix-full.md
