#!/usr/bin/env bash

# Deterministic coverage validation for system-level V-Model artifacts
#
# Parses requirements.md, system-design.md, and system-test.md using regex
# to extract REQ-NNN, SYS-NNN, STP-NNN-X, and STS-NNN-X# IDs.
# Cross-references them to verify:
#   - Forward coverage: every REQ has at least one SYS
#   - Backward coverage: every SYS has at least one STP
#   - STP→STS coverage: every STP has at least one STS
#   - No orphaned SYS (SYS referencing non-existent REQ)
#   - No orphaned STP (STP referencing non-existent SYS)
#
# Supports partial validation: when system-test.md is absent, validates
# forward coverage (REQ→SYS) only and gracefully skips SYS→STP→STS checks.
#
# Usage: ./validate-system-coverage.sh [OPTIONS] <vmodel-dir>
#
# OPTIONS:
#   --json    Output in JSON format (for AI consumption)
#
# EXIT CODES:
#   0 = full coverage (or forward-only coverage in partial mode)
#   1 = gaps found

set -e

JSON_MODE=false
VMODEL_DIR=""

for arg in "$@"; do
    case "$arg" in
        --json) JSON_MODE=true ;;
        --help|-h)
            echo "Usage: validate-system-coverage.sh [--json] <vmodel-dir>"
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
SYSTEM_DESIGN="$VMODEL_DIR/system-design.md"
SYSTEM_TEST="$VMODEL_DIR/system-test.md"

if [[ ! -f "$REQUIREMENTS" ]]; then
    echo "ERROR: requirements.md not found in $VMODEL_DIR" >&2
    exit 1
fi

if [[ ! -f "$SYSTEM_DESIGN" ]]; then
    echo "ERROR: system-design.md not found in $VMODEL_DIR" >&2
    exit 1
fi

PARTIAL_MODE=false
if [[ ! -f "$SYSTEM_TEST" ]]; then
    PARTIAL_MODE=true
fi

# ---- Pass 1: Extract IDs ----

# REQ IDs from requirements.md
req_ids=($(grep -oE 'REQ-([A-Z]+-)?[0-9]{3}' "$REQUIREMENTS" | sort -u))

# SYS IDs from system-design.md
sys_ids=($(grep -oE 'SYS-[0-9]{3}' "$SYSTEM_DESIGN" | sort -u))

# STP and STS IDs from system-test.md (only if not in partial mode)
stp_ids=()
sts_ids=()
if ! $PARTIAL_MODE; then
    stp_ids=($(grep -oE 'STP-[0-9]{3}-[A-Z]' "$SYSTEM_TEST" | sort -u))
    sts_ids=($(grep -oE 'STS-[0-9]{3}-[A-Z][0-9]+' "$SYSTEM_TEST" | sort -u))
fi

total_reqs=${#req_ids[@]}
total_sys=${#sys_ids[@]}
total_stps=${#stp_ids[@]}
total_stss=${#sts_ids[@]}

# ---- Pass 2: Build parent REQ mapping from Decomposition View ----

# For each SYS, extract parent REQ-NNN from its table row
declare -A sys_parents  # SYS-NNN -> "REQ-001 REQ-002 ..."
declare -A req_covered  # REQ-NNN -> 1 if covered by any SYS

for sys in "${sys_ids[@]}"; do
    sys_escaped=$(echo "$sys" | sed 's/[.[\*^$()+?{|]/\\&/g')
    # Extract the table row containing this SYS ID and get the Parent Requirements column
    row=$(grep -E "^\|[[:space:]]*${sys_escaped}[[:space:]]*\|" "$SYSTEM_DESIGN" 2>/dev/null || true)
    if [[ -n "$row" ]]; then
        # Parent Requirements is the 4th column (index 3)
        parent_cell=$(echo "$row" | awk -F'|' '{print $5}')
        parents=$(echo "$parent_cell" | grep -oE 'REQ-([A-Z]+-)?[0-9]{3}' || true)
        sys_parents["$sys"]="$parents"
        for p in $parents; do
            req_covered["$p"]=1
        done
    fi
done

# ---- Pass 3: Cross-reference ----

# Check forward coverage: every REQ has at least one SYS
reqs_without_sys=()
for req in "${req_ids[@]}"; do
    if [[ -z "${req_covered[$req]}" ]]; then
        reqs_without_sys+=("$req")
    fi
done

# Check backward coverage: every SYS has at least one STP (skip in partial mode)
sys_base_key() { echo "$1" | sed 's/^SYS-//'; }
stp_base_key() { echo "$1" | sed 's/^STP-//' | sed 's/-[A-Z]$//'; }
stp_full_key() { echo "$1" | sed 's/^STP-//'; }
sts_full_key() { echo "$1" | sed 's/^STS-//'; }

sys_without_stp=()
stps_without_sts=()
orphaned_stps=()

if ! $PARTIAL_MODE; then
    for sys in "${sys_ids[@]}"; do
        sys_key=$(sys_base_key "$sys")
        has_stp=false
        for stp in "${stp_ids[@]}"; do
            stp_key=$(stp_base_key "$stp")
            if [[ "$sys_key" == "$stp_key" ]]; then
                has_stp=true
                break
            fi
        done
        if ! $has_stp; then
            sys_without_stp+=("$sys")
        fi
    done

    # Check STP→STS coverage
    for stp in "${stp_ids[@]}"; do
        stp_key=$(stp_full_key "$stp")
        has_sts=false
        for sts in "${sts_ids[@]}"; do
            sts_key=$(sts_full_key "$sts")
            if [[ "$sts_key" == "$stp_key"* ]]; then
                has_sts=true
                break
            fi
        done
        if ! $has_sts; then
            stps_without_sts+=("$stp")
        fi
    done

    # Check for orphaned STP (STP referencing non-existent SYS)
    for stp in "${stp_ids[@]}"; do
        stp_key=$(stp_base_key "$stp")
        has_sys=false
        for sys in "${sys_ids[@]}"; do
            sys_key=$(sys_base_key "$sys")
            if [[ "$stp_key" == "$sys_key" ]]; then
                has_sys=true
                break
            fi
        done
        if ! $has_sys; then
            orphaned_stps+=("$stp")
        fi
    done
fi

# Check for orphaned SYS (SYS with parent REQ not in requirements.md)
orphaned_sys=()
for sys in "${sys_ids[@]}"; do
    for parent in ${sys_parents[$sys]}; do
        found=false
        for req in "${req_ids[@]}"; do
            if [[ "$parent" == "$req" ]]; then
                found=true
                break
            fi
        done
        if ! $found; then
            orphaned_sys+=("$sys references unknown $parent")
            break
        fi
    done
done

# ---- Calculate coverage ----

reqs_covered_count=$((total_reqs - ${#reqs_without_sys[@]}))
sys_covered_count=$((total_sys - ${#sys_without_stp[@]}))
stps_covered_count=$((total_stps - ${#stps_without_sts[@]}))

if [[ $total_reqs -gt 0 ]]; then
    req_coverage=$((reqs_covered_count * 100 / total_reqs))
else
    req_coverage=0
fi

if [[ $total_sys -gt 0 ]]; then
    sys_coverage=$((sys_covered_count * 100 / total_sys))
else
    sys_coverage=0
fi

if [[ $total_stps -gt 0 ]]; then
    stp_coverage=$((stps_covered_count * 100 / total_stps))
else
    stp_coverage=0
fi

has_gaps=false
if [[ ${#reqs_without_sys[@]} -gt 0 ]] || [[ ${#orphaned_sys[@]} -gt 0 ]]; then
    has_gaps=true
fi
if ! $PARTIAL_MODE; then
    if [[ ${#sys_without_stp[@]} -gt 0 ]] || [[ ${#stps_without_sts[@]} -gt 0 ]] || \
       [[ ${#orphaned_stps[@]} -gt 0 ]]; then
        has_gaps=true
    fi
fi

# ---- Output ----

fmt_array() {
    local arr=("$@")
    if [[ ${#arr[@]} -eq 0 ]]; then echo "[]"; return; fi
    local result=$(printf '"%s",' "${arr[@]}")
    echo "[${result%,}]"
}

if $JSON_MODE; then
    cat << EOF
{
  "partial_mode": $PARTIAL_MODE,
  "total_reqs": $total_reqs,
  "total_sys": $total_sys,
  "total_stps": $total_stps,
  "total_stss": $total_stss,
  "reqs_covered": $reqs_covered_count,
  "sys_covered": $sys_covered_count,
  "stps_covered": $stps_covered_count,
  "req_to_sys_coverage_pct": $req_coverage,
  "sys_to_stp_coverage_pct": $sys_coverage,
  "stp_to_sts_coverage_pct": $stp_coverage,
  "has_gaps": $has_gaps,
  "reqs_without_sys": $(fmt_array "${reqs_without_sys[@]}"),
  "sys_without_stp": $(fmt_array "${sys_without_stp[@]}"),
  "stps_without_sts": $(fmt_array "${stps_without_sts[@]}"),
  "orphaned_sys": $(fmt_array "${orphaned_sys[@]}"),
  "orphaned_stps": $(fmt_array "${orphaned_stps[@]}")
}
EOF
else
    echo "=== System-Level Coverage Validation ==="
    if $PARTIAL_MODE; then
        echo "(Partial mode — system-test.md not found, validating forward coverage only)"
    fi
    echo ""
    echo "Totals: $total_reqs REQs | $total_sys SYS | $total_stps STPs | $total_stss STSs"
    echo "REQ → SYS coverage: $reqs_covered_count/$total_reqs ($req_coverage%)"
    if ! $PARTIAL_MODE; then
        echo "SYS → STP coverage: $sys_covered_count/$total_sys ($sys_coverage%)"
        echo "STP → STS coverage: $stps_covered_count/$total_stps ($stp_coverage%)"
    fi
    echo ""

    if [[ ${#reqs_without_sys[@]} -gt 0 ]]; then
        echo "❌ Requirements WITHOUT system components:"
        for req in "${reqs_without_sys[@]}"; do
            echo "   - $req"
        done
    fi

    if ! $PARTIAL_MODE; then
        if [[ ${#sys_without_stp[@]} -gt 0 ]]; then
            echo "❌ System components WITHOUT test cases:"
            for sys in "${sys_without_stp[@]}"; do
                echo "   - $sys"
            done
        fi

        if [[ ${#stps_without_sts[@]} -gt 0 ]]; then
            echo "❌ Test cases WITHOUT scenarios:"
            for stp in "${stps_without_sts[@]}"; do
                echo "   - $stp"
            done
        fi

        if [[ ${#orphaned_stps[@]} -gt 0 ]]; then
            echo "⚠️  Orphaned test cases (referencing non-existent SYS):"
            for stp in "${orphaned_stps[@]}"; do
                echo "   - $stp"
            done
        fi
    fi

    if [[ ${#orphaned_sys[@]} -gt 0 ]]; then
        echo "⚠️  Orphaned system components (referencing non-existent REQ):"
        for msg in "${orphaned_sys[@]}"; do
            echo "   - $msg"
        done
    fi

    if ! $has_gaps; then
        if $PARTIAL_MODE; then
            echo "✅ Forward coverage complete — all requirements decomposed into system components."
            echo "   (SYS→STP→STS validation skipped — generate system-test.md for full validation)"
        else
            echo "✅ Full system-level coverage — all requirements decomposed, all components tested."
        fi
    fi
fi

$has_gaps && exit 1 || exit 0
