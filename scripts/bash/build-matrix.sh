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

        # Extract SYS IDs and descriptions from Decomposition View only
        # (other views also have SYS-NNN in tables — must not overwrite parent reqs)
        declare -A sys_descriptions
        declare -A sys_names
        declare -A sys_parent_reqs
        in_decomposition=false
        while IFS= read -r line; do
            if [[ "$line" =~ ^##[[:space:]]+Decomposition ]]; then
                in_decomposition=true
                continue
            fi
            if $in_decomposition && [[ "$line" =~ ^##[[:space:]] ]]; then
                break
            fi
            if $in_decomposition && [[ "$line" =~ \|[[:space:]]*(SYS-[0-9]{3})[[:space:]]*\|[[:space:]]*([^|]+)\|[[:space:]]*([^|]+)\|[[:space:]]*([^|]+) ]]; then
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

    # ---- Matrix C: Integration Verification (if architecture-level artifacts exist) ----
    ARCH_DESIGN="$VMODEL_DIR/architecture-design.md"
    INTEGRATION_TEST="$VMODEL_DIR/integration-test.md"
    HAS_ARCH_LEVEL=false
    if [[ -f "$ARCH_DESIGN" ]] && [[ -f "$INTEGRATION_TEST" ]]; then
        HAS_ARCH_LEVEL=true

        # Extract ARCH IDs from Logical View only (section-scoped)
        declare -A arch_names
        declare -A arch_parent_sys
        declare -A arch_cross_cutting
        in_logical=false
        while IFS= read -r line; do
            if [[ "$line" =~ ^##[[:space:]]+Logical ]]; then
                in_logical=true
                continue
            fi
            if $in_logical && [[ "$line" =~ ^##[[:space:]] ]]; then
                break
            fi
            if $in_logical && [[ "$line" =~ \|[[:space:]]*(ARCH-[0-9]{3})[[:space:]]*\|[[:space:]]*([^|]+)\|[[:space:]]*([^|]+)\|[[:space:]]*([^|]+) ]]; then
                arch_id="${BASH_REMATCH[1]}"
                aname=$(echo "${BASH_REMATCH[2]}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                # skip description (col 3), parent sys is col 4
                aparents=$(echo "${BASH_REMATCH[4]}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                arch_names["$arch_id"]="$aname"
                arch_parent_sys["$arch_id"]="$aparents"
                if echo "$aparents" | grep -q '\[CROSS-CUTTING\]'; then
                    arch_cross_cutting["$arch_id"]=1
                fi
            fi
        done < "$ARCH_DESIGN"

        # Extract ITP sections: "#### Test Case: ITP-NNN-X (Description)"
        declare -A itp_descriptions
        itp_regex='Test Case: (ITP-[0-9]{3}-[A-Z])[[:space:]]*\(([^)]+)\)'
        while IFS= read -r line; do
            if [[ "$line" =~ $itp_regex ]]; then
                itp_id="${BASH_REMATCH[1]}"
                itp_desc="${BASH_REMATCH[2]}"
                itp_descriptions["$itp_id"]="$itp_desc"
            fi
        done < "$INTEGRATION_TEST"

        # Extract ITP technique
        declare -A itp_techniques
        current_itp=""
        while IFS= read -r line; do
            if [[ "$line" =~ Test\ Case:\ (ITP-[0-9]{3}-[A-Z]) ]]; then
                current_itp="${BASH_REMATCH[1]}"
            elif [[ -n "$current_itp" && "$line" =~ ^\*\*Technique\*\*:[[:space:]]*(.+) ]]; then
                itp_techniques["$current_itp"]=$(echo "${BASH_REMATCH[1]}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                current_itp=""
            fi
        done < "$INTEGRATION_TEST"

        # Extract ITS IDs
        arch_its_ids=($(grep -oE 'ITS-[0-9]{3}-[A-Z][0-9]+' "$INTEGRATION_TEST" | sort -u))

        sorted_arch=($(echo "${!arch_names[@]}" | tr ' ' '\n' | sort))
        sorted_itp=($(echo "${!itp_descriptions[@]}" | tr ' ' '\n' | sort))
        total_arch_count=${#sorted_arch[@]}
        total_itp_count=${#sorted_itp[@]}
        total_its_count=${#arch_its_ids[@]}

        arch_base_key_fn() { echo "$1" | sed 's/^ARCH-//'; }
        itp_base_key_fn() { echo "$1" | sed 's/^ITP-//' | sed 's/-[A-Z]$//'; }
        itp_full_key_fn() { echo "$1" | sed 's/^ITP-//'; }
        its_full_key_fn() { echo "$1" | sed 's/^ITS-//'; }

        cross_cutting_count=0
        for arch in "${sorted_arch[@]}"; do
            [[ -n "${arch_cross_cutting[$arch]}" ]] && cross_cutting_count=$((cross_cutting_count + 1))
        done

        echo ""
        echo "## Matrix C — Integration Verification (Module Boundary View)"
        echo ""
        echo "| System Component (SYS) | Parent REQs | Architecture Module (ARCH) | Module Name | Test Case ID (ITP) | Technique | Scenario ID (ITS) | Status |"
        echo "|------------------------|-------------|---------------------------|-------------|--------------------|-----------|--------------------|--------|"

        # Build Matrix C rows grouped by SYS
        # First: rows for ARCH modules with SYS parents
        if $HAS_SYSTEM_LEVEL; then
            sys_with_arch=0
            for sys in "${sorted_sys[@]}"; do
                sys_key=$(sys_base_key_fn "$sys")
                has_arch=false
                parent_reqs="${sys_parent_reqs[$sys]:-—}"

                for arch in "${sorted_arch[@]}"; do
                    [[ -n "${arch_cross_cutting[$arch]}" ]] && continue
                    parents="${arch_parent_sys[$arch]}"
                    if echo "$parents" | grep -qE "(^|,)[[:space:]]*${sys}[[:space:]]*(,|$)"; then
                        has_arch=true
                        aname="${arch_names[$arch]}"
                        arch_key=$(arch_base_key_fn "$arch")
                        first_arch_itp=true

                        for itp in "${sorted_itp[@]}"; do
                            itp_key=$(itp_base_key_fn "$itp")
                            if [[ "$itp_key" == "$arch_key" ]]; then
                                technique="${itp_techniques[$itp]:-—}"
                                itp_fkey=$(itp_full_key_fn "$itp")

                                for its in "${arch_its_ids[@]}"; do
                                    its_fkey=$(its_full_key_fn "$its")
                                    if [[ "$its_fkey" == "$itp_fkey"* ]]; then
                                        echo "| $sys ($parent_reqs) | $parent_reqs | $arch | $aname | $itp | $technique | $its | ⬜ Untested |"
                                        first_arch_itp=false
                                    fi
                                done

                                if $first_arch_itp; then
                                    echo "| $sys ($parent_reqs) | $parent_reqs | $arch | $aname | $itp | $technique | ❌ MISSING | ⬜ Untested |"
                                    first_arch_itp=false
                                fi
                            fi
                        done

                        if $first_arch_itp; then
                            echo "| $sys ($parent_reqs) | $parent_reqs | $arch | $aname | ❌ MISSING | — | — | ⬜ Untested |"
                        fi
                    fi
                done

                if $has_arch; then
                    sys_with_arch=$((sys_with_arch + 1))
                else
                    echo "| $sys ($parent_reqs) | $parent_reqs | ❌ MISSING | — | — | — | — | ⬜ Untested |"
                fi
            done
        fi

        # Cross-cutting modules (pseudo-rows)
        for arch in "${sorted_arch[@]}"; do
            [[ -z "${arch_cross_cutting[$arch]}" ]] && continue
            aname="${arch_names[$arch]}"
            arch_key=$(arch_base_key_fn "$arch")
            first_cc_itp=true

            for itp in "${sorted_itp[@]}"; do
                itp_key=$(itp_base_key_fn "$itp")
                if [[ "$itp_key" == "$arch_key" ]]; then
                    technique="${itp_techniques[$itp]:-—}"
                    itp_fkey=$(itp_full_key_fn "$itp")

                    for its in "${arch_its_ids[@]}"; do
                        its_fkey=$(its_full_key_fn "$its")
                        if [[ "$its_fkey" == "$itp_fkey"* ]]; then
                            echo "| N/A (Cross-Cutting) | — | $arch | $aname | $itp | $technique | $its | ⬜ Untested |"
                            first_cc_itp=false
                        fi
                    done

                    if $first_cc_itp; then
                        echo "| N/A (Cross-Cutting) | — | $arch | $aname | $itp | $technique | ❌ MISSING | ⬜ Untested |"
                        first_cc_itp=false
                    fi
                fi
            done

            if $first_cc_itp; then
                echo "| N/A (Cross-Cutting) | — | $arch | $aname | ❌ MISSING | — | — | ⬜ Untested |"
            fi
        done

        echo ""
        echo "### Matrix C Coverage"
        echo ""

        # Count SYS with ARCH (excluding cross-cutting)
        if $HAS_SYSTEM_LEVEL; then
            if [[ $total_sys_count -gt 0 ]]; then
                sys_arch_pct=$((sys_with_arch * 100 / total_sys_count))
            else
                sys_arch_pct=0
            fi
        else
            sys_with_arch=0
            sys_arch_pct=0
        fi

        # Count ARCH with ITP
        arch_covered=0
        for arch in "${sorted_arch[@]}"; do
            arch_key=$(arch_base_key_fn "$arch")
            for itp in "${sorted_itp[@]}"; do
                itp_key=$(itp_base_key_fn "$itp")
                if [[ "$itp_key" == "$arch_key" ]]; then
                    arch_covered=$((arch_covered + 1))
                    break
                fi
            done
        done

        if [[ $total_arch_count -gt 0 ]]; then
            arch_itp_pct=$((arch_covered * 100 / total_arch_count))
        else
            arch_itp_pct=0
        fi

        echo "| Metric | Value |"
        echo "|--------|-------|"
        echo "| **Total Architecture Modules (ARCH)** | $total_arch_count |"
        echo "| **Total Cross-Cutting Modules** | $cross_cutting_count |"
        echo "| **Total Integration Test Cases (ITP)** | $total_itp_count |"
        echo "| **Total Integration Scenarios (ITS)** | $total_its_count |"
        if $HAS_SYSTEM_LEVEL; then
            echo "| **SYS → ARCH Coverage** | $sys_with_arch/$total_sys_count ($sys_arch_pct%) |"
        fi
        echo "| **ARCH → ITP Coverage** | $arch_covered/$total_arch_count ($arch_itp_pct%) |"
    fi
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

    if $HAS_ARCH_LEVEL; then
        # Architecture-level gaps
        arch_sys_without_arch=()
        if $HAS_SYSTEM_LEVEL; then
            for sys in "${sorted_sys[@]}"; do
                found=false
                for arch in "${sorted_arch[@]}"; do
                    [[ -n "${arch_cross_cutting[$arch]}" ]] && continue
                    parents="${arch_parent_sys[$arch]}"
                    if echo "$parents" | grep -qE "(^|,)[[:space:]]*${sys}[[:space:]]*(,|$)"; then
                        found=true
                        break
                    fi
                done
                $found || arch_sys_without_arch+=("$sys")
            done
        fi

        orphaned_itps=()
        for itp in "${sorted_itp[@]}"; do
            itp_key=$(itp_base_key_fn "$itp")
            has_arch=false
            for arch in "${sorted_arch[@]}"; do
                arch_key=$(arch_base_key_fn "$arch")
                [[ "$itp_key" == "$arch_key" ]] && has_arch=true && break
            done
            $has_arch || orphaned_itps+=("$itp")
        done

        echo ""
        echo "### Uncovered System Components — Architecture Level (SYS without ARCH)"
        echo ""
        if [[ ${#arch_sys_without_arch[@]} -eq 0 ]]; then
            echo "None — full coverage."
        else
            for sys in "${arch_sys_without_arch[@]}"; do echo "- $sys"; done
        fi
        echo ""
        echo "### Orphaned Integration Test Cases (ITP without valid ARCH)"
        echo ""
        if [[ ${#orphaned_itps[@]} -eq 0 ]]; then
            echo "None — all integration tests trace to modules."
        else
            for itp in "${orphaned_itps[@]}"; do echo "- $itp"; done
        fi
    fi

    # ---- Matrix D: Implementation Verification (if module-level artifacts exist) ----
    MODULE_DESIGN="$VMODEL_DIR/module-design.md"
    UNIT_TEST="$VMODEL_DIR/unit-test.md"
    HAS_MODULE_LEVEL=false
    if [[ -f "$MODULE_DESIGN" ]] && [[ -f "$ARCH_DESIGN" ]]; then
        HAS_MODULE_LEVEL=true

        # Parse architecture-design.md for ARCH→SYS lineage if not already parsed by Matrix C
        if ! $HAS_ARCH_LEVEL; then
            declare -A arch_names
            declare -A arch_parent_sys
            declare -A arch_cross_cutting
            in_logical_d=false
            while IFS= read -r line; do
                if [[ "$line" =~ ^##[[:space:]]+Logical ]]; then
                    in_logical_d=true
                    continue
                fi
                if $in_logical_d && [[ "$line" =~ ^##[[:space:]] ]]; then
                    break
                fi
                if $in_logical_d && [[ "$line" =~ \|[[:space:]]*(ARCH-[0-9]{3})[[:space:]]*\|[[:space:]]*([^|]+)\|[[:space:]]*([^|]+)\|[[:space:]]*([^|]+) ]]; then
                    arch_id="${BASH_REMATCH[1]}"
                    aname=$(echo "${BASH_REMATCH[2]}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                    aparents=$(echo "${BASH_REMATCH[4]}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                    arch_names["$arch_id"]="$aname"
                    arch_parent_sys["$arch_id"]="$aparents"
                    if echo "$aparents" | grep -q '\[CROSS-CUTTING\]'; then
                        arch_cross_cutting["$arch_id"]=1
                    fi
                fi
            done < "$ARCH_DESIGN"
            sorted_arch=($(echo "${!arch_names[@]}" | tr ' ' '\n' | sort))
            total_arch_count=${#sorted_arch[@]}
            arch_base_key_fn() { echo "$1" | sed 's/^ARCH-//'; }
        fi

        # Extract MOD IDs from module-design.md (heading lines + metadata)
        declare -A mod_names
        declare -A mod_parent_arch
        declare -A mod_external_flag
        local_current_mod=""
        local_in_meta=true
        mod_heading_regex='^###[[:space:]]+Module:[[:space:]]*(MOD-[0-9]{3})'
        while IFS= read -r line; do
            if [[ "$line" =~ $mod_heading_regex ]]; then
                local_current_mod="${BASH_REMATCH[1]}"
                # Extract name from parentheses
                local_name=$(echo "$line" | sed -n 's/.*(\([^)]*\)).*/\1/p')
                mod_names["$local_current_mod"]="$local_name"
                local_in_meta=true
                if echo "$line" | grep -q '\[EXTERNAL\]'; then
                    mod_external_flag["$local_current_mod"]=1
                fi
                continue
            fi
            if [[ "$line" =~ ^#### ]] || [[ "$line" =~ ^---$ ]]; then
                local_in_meta=false
            fi
            if [[ "$line" =~ ^###[[:space:]] ]] && ! [[ "$line" =~ Module: ]]; then
                local_current_mod=""
                local_in_meta=false
            fi
            if [[ -n "$local_current_mod" ]] && $local_in_meta; then
                if [[ "$line" =~ ^\*\*Parent\ Architecture\ Modules\*\*: ]]; then
                    parents=$(echo "$line" | grep -oE 'ARCH-[0-9]{3}' || true)
                    mod_parent_arch["$local_current_mod"]="$parents"
                fi
                if echo "$line" | grep -q '\[EXTERNAL\]'; then
                    mod_external_flag["$local_current_mod"]=1
                fi
            fi
        done < "$MODULE_DESIGN"

        sorted_mod=($(echo "${!mod_names[@]}" | tr ' ' '\n' | sort))
        total_mod_count=${#sorted_mod[@]}

        mod_base_key_fn() { echo "$1" | sed 's/^MOD-//'; }

        # Extract UTP/UTS from unit-test.md (if exists)
        declare -A utp_descriptions
        declare -A utp_techniques
        mod_utp_ids=()
        mod_uts_ids=()
        HAS_UNIT_TEST=false
        if [[ -f "$UNIT_TEST" ]]; then
            HAS_UNIT_TEST=true
            utp_regex='Test Case: (UTP-[0-9]{3}-[A-Z])[[:space:]]*\(([^)]+)\)'
            while IFS= read -r line; do
                if [[ "$line" =~ $utp_regex ]]; then
                    utp_id="${BASH_REMATCH[1]}"
                    utp_descriptions["$utp_id"]="${BASH_REMATCH[2]}"
                fi
            done < "$UNIT_TEST"

            current_utp=""
            while IFS= read -r line; do
                if [[ "$line" =~ Test\ Case:\ (UTP-[0-9]{3}-[A-Z]) ]]; then
                    current_utp="${BASH_REMATCH[1]}"
                elif [[ -n "$current_utp" && "$line" =~ ^\*\*Technique\*\*:[[:space:]]*(.+) ]]; then
                    utp_techniques["$current_utp"]=$(echo "${BASH_REMATCH[1]}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                    current_utp=""
                fi
            done < "$UNIT_TEST"

            mod_utp_ids=($(grep -oE 'UTP-[0-9]{3}-[A-Z]' "$UNIT_TEST" | sort -u))
            mod_uts_ids=($(grep -oE 'UTS-[0-9]{3}-[A-Z][0-9]+' "$UNIT_TEST" | sort -u))
        fi

        sorted_utp=($(echo "${!utp_descriptions[@]}" | tr ' ' '\n' | sort))
        total_utp_count=${#sorted_utp[@]}
        total_uts_count=${#mod_uts_ids[@]}

        utp_base_key_d() { echo "$1" | sed 's/^UTP-//' | sed 's/-[A-Z]$//'; }
        utp_full_key_d() { echo "$1" | sed 's/^UTP-//'; }
        uts_full_key_d() { echo "$1" | sed 's/^UTS-//'; }

        # Count external modules
        external_count=0
        for mod in "${sorted_mod[@]}"; do
            [[ -n "${mod_external_flag[$mod]}" ]] && external_count=$((external_count + 1))
        done

        echo ""
        echo "## Matrix D — Implementation Verification (Module View)"
        echo ""
        echo "| Architecture Module (ARCH) | Parent System | Module Design (MOD) | Module Name | Test Case ID (UTP) | Technique | Scenario ID (UTS) | Status |"
        echo "|---------------------------|---------------|---------------------|-------------|--------------------|-----------|--------------------|--------|"

        # Build Matrix D rows grouped by ARCH
        for arch in "${sorted_arch[@]}"; do
                arch_key=$(arch_base_key_fn "$arch")
                aname="${arch_names[$arch]}"

                # Determine parent SYS for display
                if [[ -n "${arch_cross_cutting[$arch]}" ]]; then
                    parent_sys_display="[CROSS-CUTTING]"
                else
                    parent_sys_display="${arch_parent_sys[$arch]:-—}"
                fi

                has_mod=false
                for mod in "${sorted_mod[@]}"; do
                    parents="${mod_parent_arch[$mod]}"
                    if echo "$parents" | grep -qw "$arch"; then
                        has_mod=true
                        mname="${mod_names[$mod]}"
                        mod_key=$(mod_base_key_fn "$mod")

                        # Check if external
                        if [[ -n "${mod_external_flag[$mod]}" ]]; then
                            echo "| $arch ($parent_sys_display) | $parent_sys_display | $mod | $mname [EXTERNAL] | — (integration level) | — | — | ⬜ Bypassed |"
                            continue
                        fi

                        if $HAS_UNIT_TEST; then
                            first_mod_utp=true
                            for utp in "${sorted_utp[@]}"; do
                                utp_key=$(utp_base_key_d "$utp")
                                if [[ "$utp_key" == "$mod_key" ]]; then
                                    technique="${utp_techniques[$utp]:-—}"
                                    utp_fkey=$(utp_full_key_d "$utp")

                                    for uts in "${mod_uts_ids[@]}"; do
                                        uts_fkey=$(uts_full_key_d "$uts")
                                        if [[ "$uts_fkey" == "$utp_fkey"* ]]; then
                                            echo "| $arch ($parent_sys_display) | $parent_sys_display | $mod | $mname | $utp | $technique | $uts | ⬜ Untested |"
                                            first_mod_utp=false
                                        fi
                                    done

                                    if $first_mod_utp; then
                                        echo "| $arch ($parent_sys_display) | $parent_sys_display | $mod | $mname | $utp | $technique | ❌ MISSING | ⬜ Untested |"
                                        first_mod_utp=false
                                    fi
                                fi
                            done

                            if $first_mod_utp; then
                                echo "| $arch ($parent_sys_display) | $parent_sys_display | $mod | $mname | ❌ MISSING | — | — | ⬜ Untested |"
                            fi
                        else
                            echo "| $arch ($parent_sys_display) | $parent_sys_display | $mod | $mname | ⏳ Pending | — | — | ⬜ Untested |"
                        fi
                    fi
                done

                if ! $has_mod; then
                    echo "| $arch ($parent_sys_display) | $parent_sys_display | ❌ MISSING | — | — | — | — | ⬜ Untested |"
                fi
            done

        echo ""
        echo "### Matrix D Coverage"
        echo ""

        # Count ARCH with MOD
        arch_with_mod=0
        for arch in "${sorted_arch[@]}"; do
            for mod in "${sorted_mod[@]}"; do
                parents="${mod_parent_arch[$mod]}"
                if echo "$parents" | grep -qw "$arch"; then
                    arch_with_mod=$((arch_with_mod + 1))
                    break
                fi
            done
        done

        if [[ $total_arch_count -gt 0 ]]; then
            arch_mod_pct=$((arch_with_mod * 100 / total_arch_count))
        else
            arch_mod_pct=0
        fi

        # Count MOD with UTP (excluding external)
        mod_with_utp=0
        testable_mod=$((total_mod_count - external_count))
        if $HAS_UNIT_TEST; then
            for mod in "${sorted_mod[@]}"; do
                [[ -n "${mod_external_flag[$mod]}" ]] && continue
                mod_key=$(mod_base_key_fn "$mod")
                for utp in "${sorted_utp[@]}"; do
                    utp_key=$(utp_base_key_d "$utp")
                    if [[ "$utp_key" == "$mod_key" ]]; then
                        mod_with_utp=$((mod_with_utp + 1))
                        break
                    fi
                done
            done
        fi

        if [[ $testable_mod -gt 0 ]] && $HAS_UNIT_TEST; then
            mod_utp_pct=$((mod_with_utp * 100 / testable_mod))
        else
            mod_utp_pct=0
        fi

        echo "| Metric | Value |"
        echo "|--------|-------|"
        echo "| **Total Module Designs (MOD)** | $total_mod_count |"
        echo "| **External Modules** | $external_count |"
        echo "| **Testable Modules** | $testable_mod |"
        if $HAS_UNIT_TEST; then
            echo "| **Total Unit Test Cases (UTP)** | $total_utp_count |"
            echo "| **Total Unit Scenarios (UTS)** | $total_uts_count |"
        fi
        echo "| **ARCH → MOD Coverage** | $arch_with_mod/$total_arch_count ($arch_mod_pct%) |"
        if $HAS_UNIT_TEST; then
            echo "| **MOD → UTP Coverage** | $mod_with_utp/$testable_mod ($mod_utp_pct%) |"
        else
            echo "| **MOD → UTP Coverage** | ⏳ Pending (unit-test.md not found) |"
        fi
    fi

    echo ""
    echo "## Audit Notes"
    echo ""
    echo "- **Matrix generated by**: \`build-matrix.sh\` (deterministic regex parser)"
    echo "- **Source documents**: \`requirements.md\`, \`acceptance-plan.md\`$(if $HAS_SYSTEM_LEVEL; then echo ', `system-design.md`, `system-test.md`'; fi)$(if $HAS_ARCH_LEVEL; then echo ', `architecture-design.md`, `integration-test.md`'; fi)$(if $HAS_MODULE_LEVEL; then echo ', `module-design.md`'; fi)$(if $HAS_UNIT_TEST; then echo ', `unit-test.md`'; fi)"
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
