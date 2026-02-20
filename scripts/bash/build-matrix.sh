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
SYSTEM_DESIGN="$VMODEL_DIR/system-design.md"
SYSTEM_TEST="$VMODEL_DIR/system-test.md"

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
    echo "## Matrix A — Validation (User View)"
    echo ""
    cat /tmp/vmodel-matrix-body.md
    echo ""
    echo "### Matrix A Coverage"
    echo ""
    echo "| Metric | Value |"
    echo "|--------|-------|"
    echo "| **Total Requirements** | $total_reqs |"
    echo "| **Total Test Cases (ATP)** | $total_atps |"
    echo "| **Total Scenarios (SCN)** | $total_scns |"
    echo "| **REQ → ATP Coverage** | $reqs_with_atp/$total_reqs ($req_pct%) |"
    echo "| **ATP → SCN Coverage** | $atps_with_scn/$total_atps ($atp_pct%) |"
    echo ""

    # ---- Matrix B: Verification (if system-level artifacts exist) ----
    HAS_SYSTEM_LEVEL=false
    if [[ -f "$SYSTEM_DESIGN" ]] && [[ -f "$SYSTEM_TEST" ]]; then
        HAS_SYSTEM_LEVEL=true

        # Extract SYS IDs and descriptions from Decomposition View
        declare -A sys_descriptions
        declare -A sys_names
        declare -A sys_parent_reqs
        while IFS= read -r line; do
            if [[ "$line" =~ \|[[:space:]]*(SYS-[0-9]{3})[[:space:]]*\|[[:space:]]*([^|]+)\|[[:space:]]*([^|]+)\|[[:space:]]*([^|]+) ]]; then
                sid="${BASH_REMATCH[1]}"
                sname=$(echo "${BASH_REMATCH[2]}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                sdesc=$(echo "${BASH_REMATCH[3]}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                sparents=$(echo "${BASH_REMATCH[4]}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                sys_descriptions["$sid"]="$sdesc"
                sys_names["$sid"]="$sname"
                sys_parent_reqs["$sid"]="$sparents"
            fi
        done < "$SYSTEM_DESIGN"

        # Extract STP sections: "#### Test Case: STP-NNN-X (Description)"
        declare -A stp_descriptions
        stp_regex='Test Case: (STP-[0-9]{3}-[A-Z])[[:space:]]*\(([^)]+)\)'
        while IFS= read -r line; do
            if [[ "$line" =~ $stp_regex ]]; then
                stp_id="${BASH_REMATCH[1]}"
                stp_desc="${BASH_REMATCH[2]}"
                stp_descriptions["$stp_id"]="$stp_desc"
            fi
        done < "$SYSTEM_TEST"

        # Extract STP technique from "**Technique**: ..." lines
        declare -A stp_techniques
        current_stp=""
        while IFS= read -r line; do
            if [[ "$line" =~ Test\ Case:\ (STP-[0-9]{3}-[A-Z]) ]]; then
                current_stp="${BASH_REMATCH[1]}"
            elif [[ -n "$current_stp" && "$line" =~ ^\*\*Technique\*\*:[[:space:]]*(.+) ]]; then
                stp_techniques["$current_stp"]=$(echo "${BASH_REMATCH[1]}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                current_stp=""
            fi
        done < "$SYSTEM_TEST"

        # Extract STS IDs
        sys_sts_ids=($(grep -oE 'STS-[0-9]{3}-[A-Z][0-9]+' "$SYSTEM_TEST" | sort -u))

        sorted_sys=($(echo "${!sys_descriptions[@]}" | tr ' ' '\n' | sort))
        sorted_stp=($(echo "${!stp_descriptions[@]}" | tr ' ' '\n' | sort))
        total_sys_count=${#sorted_sys[@]}
        total_stp_count=${#sorted_stp[@]}
        total_sts_count=${#sys_sts_ids[@]}

        # Build Matrix B body
        sys_base_key_fn() { echo "$1" | sed 's/^SYS-//'; }
        stp_base_key_fn() { echo "$1" | sed 's/^STP-//' | sed 's/-[A-Z]$//'; }
        stp_full_key_fn() { echo "$1" | sed 's/^STP-//'; }
        sts_full_key_fn() { echo "$1" | sed 's/^STS-//'; }

        reqs_with_sys=0
        sys_with_stp=0

        echo "## Matrix B — Verification (Architectural View)"
        echo ""
        echo "| Requirement ID | System Component (SYS) | Component Name | Test Case ID (STP) | Technique | Scenario ID (STS) | Status |"
        echo "|----------------|------------------------|----------------|--------------------|-----------|--------------------|--------|"

        for req in "${req_ids[@]}"; do
            first_req_row=true
            has_sys=false

            for sys in "${sorted_sys[@]}"; do
                parents="${sys_parent_reqs[$sys]}"
                if echo "$parents" | grep -qE "(^|,)[[:space:]]*${req}[[:space:]]*(,|$)"; then
                    has_sys=true
                    sys_key=$(sys_base_key_fn "$sys")
                    sname="${sys_names[$sys]}"
                    first_sys_row=true
                    has_stp=false

                    for stp in "${sorted_stp[@]}"; do
                        stp_key=$(stp_base_key_fn "$stp")
                        if [[ "$stp_key" == "$sys_key" ]]; then
                            has_stp=true
                            technique="${stp_techniques[$stp]:-—}"
                            stp_fkey=$(stp_full_key_fn "$stp")
                            first_stp_sts=true

                            for sts in "${sys_sts_ids[@]}"; do
                                sts_fkey=$(sts_full_key_fn "$sts")
                                if [[ "$sts_fkey" == "$stp_fkey"* ]]; then
                                    if $first_req_row; then
                                        echo "| **$req** | $sys | $sname | $stp | $technique | $sts | ⬜ Untested |"
                                        first_req_row=false
                                    else
                                        echo "| | $sys | $sname | $stp | $technique | $sts | ⬜ Untested |"
                                    fi
                                    first_stp_sts=false
                                fi
                            done

                            if $first_stp_sts; then
                                if $first_req_row; then
                                    echo "| **$req** | $sys | $sname | $stp | $technique | ❌ MISSING | ⬜ Untested |"
                                    first_req_row=false
                                else
                                    echo "| | $sys | $sname | $stp | $technique | ❌ MISSING | ⬜ Untested |"
                                fi
                            fi
                        fi
                    done

                    if $has_stp && [[ "$first_sys_row" == "true" ]]; then
                        sys_with_stp=$((sys_with_stp + 1))
                    fi
                fi
            done

            if $has_sys; then
                reqs_with_sys=$((reqs_with_sys + 1))
            else
                if $first_req_row; then
                    echo "| **$req** | ❌ MISSING | — | — | — | — | ⬜ Untested |"
                fi
            fi
        done

        echo ""
        echo "### Matrix B Coverage"
        echo ""

        if [[ $total_reqs -gt 0 ]]; then
            req_sys_pct=$((reqs_with_sys * 100 / total_reqs))
        else
            req_sys_pct=0
        fi

        # Count SYS with STP
        sys_covered=0
        for sys in "${sorted_sys[@]}"; do
            sys_key=$(sys_base_key_fn "$sys")
            for stp in "${sorted_stp[@]}"; do
                stp_key=$(stp_base_key_fn "$stp")
                if [[ "$stp_key" == "$sys_key" ]]; then
                    sys_covered=$((sys_covered + 1))
                    break
                fi
            done
        done

        if [[ $total_sys_count -gt 0 ]]; then
            sys_stp_pct=$((sys_covered * 100 / total_sys_count))
        else
            sys_stp_pct=0
        fi

        echo "| Metric | Value |"
        echo "|--------|-------|"
        echo "| **Total System Components (SYS)** | $total_sys_count |"
        echo "| **Total System Test Cases (STP)** | $total_stp_count |"
        echo "| **Total System Scenarios (STS)** | $total_sts_count |"
        echo "| **REQ → SYS Coverage** | $reqs_with_sys/$total_reqs ($req_sys_pct%) |"
        echo "| **SYS → STP Coverage** | $sys_covered/$total_sys_count ($sys_stp_pct%) |"
    fi

    echo ""
    echo "## Gap Analysis"
    echo ""
    echo "### Uncovered Requirements (REQ without ATP)"
    echo ""
    if [[ ${#reqs_without_atp[@]} -eq 0 ]]; then
        echo "None — full coverage."
    else
        for req in "${reqs_without_atp[@]}"; do echo "- $req"; done
    fi
    echo ""
    echo "### Orphaned Test Cases (ATP without valid REQ)"
    echo ""
    if [[ ${#orphaned_atps[@]} -eq 0 ]]; then
        echo "None — all tests trace to requirements."
    else
        for atp in "${orphaned_atps[@]}"; do echo "- $atp"; done
    fi

    if $HAS_SYSTEM_LEVEL; then
        # System-level gaps
        sys_reqs_without_sys=()
        for req in "${req_ids[@]}"; do
            found=false
            for sys in "${sorted_sys[@]}"; do
                parents="${sys_parent_reqs[$sys]}"
                if echo "$parents" | grep -qE "(^|,)[[:space:]]*${req}[[:space:]]*(,|$)"; then
                    found=true
                    break
                fi
            done
            $found || sys_reqs_without_sys+=("$req")
        done

        orphaned_stps=()
        for stp in "${sorted_stp[@]}"; do
            stp_key=$(stp_base_key_fn "$stp")
            has_sys=false
            for sys in "${sorted_sys[@]}"; do
                sys_key=$(sys_base_key_fn "$sys")
                [[ "$stp_key" == "$sys_key" ]] && has_sys=true && break
            done
            $has_sys || orphaned_stps+=("$stp")
        done

        echo ""
        echo "### Uncovered Requirements — System Level (REQ without SYS)"
        echo ""
        if [[ ${#sys_reqs_without_sys[@]} -eq 0 ]]; then
            echo "None — full coverage."
        else
            for req in "${sys_reqs_without_sys[@]}"; do echo "- $req"; done
        fi
        echo ""
        echo "### Orphaned System Test Cases (STP without valid SYS)"
        echo ""
        if [[ ${#orphaned_stps[@]} -eq 0 ]]; then
            echo "None — all system tests trace to components."
        else
            for stp in "${orphaned_stps[@]}"; do echo "- $stp"; done
        fi
    fi

    echo ""
    echo "## Audit Notes"
    echo ""
    echo "- **Matrix generated by**: \`build-matrix.sh\` (deterministic regex parser)"
    echo "- **Source documents**: \`requirements.md\`, \`acceptance-plan.md\`$(if $HAS_SYSTEM_LEVEL; then echo ', `system-design.md`, `system-test.md`'; fi)"
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
