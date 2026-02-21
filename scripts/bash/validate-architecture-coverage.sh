#!/usr/bin/env bash

# Deterministic coverage validation for architecture-level V-Model artifacts
#
# Parses system-design.md, architecture-design.md, and integration-test.md
# using regex to extract SYS-NNN, ARCH-NNN, ITP-NNN-X, and ITS-NNN-X# IDs.
# Cross-references them to verify:
#   - Forward coverage: every SYS has at least one ARCH
#   - Backward coverage: every ARCH has at least one ITP
#   - ITP→ITS coverage: every ITP has at least one ITS
#   - No orphaned ARCH (ARCH referencing non-existent SYS)
#   - No orphaned ITP (ITP referencing non-existent ARCH)
#   - CROSS-CUTTING modules are valid without SYS parent
#
# Usage: ./validate-architecture-coverage.sh [OPTIONS] <vmodel-dir>
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
            echo "Usage: validate-architecture-coverage.sh [--json] <vmodel-dir>"
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
ARCH_DESIGN="$VMODEL_DIR/architecture-design.md"
INTEGRATION_TEST="$VMODEL_DIR/integration-test.md"

if [[ ! -f "$SYSTEM_DESIGN" ]]; then
    echo "ERROR: system-design.md not found in $VMODEL_DIR" >&2
    exit 1
fi

if [[ ! -f "$ARCH_DESIGN" ]]; then
    echo "ERROR: architecture-design.md not found in $VMODEL_DIR" >&2
    exit 1
fi

PARTIAL_MODE=false
if [[ ! -f "$INTEGRATION_TEST" ]]; then
    PARTIAL_MODE=true
fi

# ---- Pass 1: Extract IDs ----

# SYS IDs from system-design.md Decomposition View (section-scoped)
sys_ids=()
in_decomposition=false
while IFS= read -r line; do
    if [[ "$line" =~ ^##[[:space:]]+Decomposition ]]; then
        in_decomposition=true
        continue
    fi
    if $in_decomposition && [[ "$line" =~ ^##[[:space:]] ]]; then
        break
    fi
    if $in_decomposition; then
        while [[ "$line" =~ (SYS-[0-9]{3}) ]]; do
            sys_ids+=("${BASH_REMATCH[1]}")
            line="${line#*${BASH_REMATCH[1]}}"
        done
    fi
done < "$SYSTEM_DESIGN"
sys_ids=($(printf '%s\n' "${sys_ids[@]}" | sort -u))

# ARCH IDs from architecture-design.md Logical View (section-scoped)
arch_ids=()
declare -A arch_parents       # ARCH-NNN -> "SYS-001 SYS-002 ..."
declare -A arch_cross_cutting # ARCH-NNN -> 1 if cross-cutting
in_logical=false
while IFS= read -r line; do
    if [[ "$line" =~ ^##[[:space:]]+Logical ]]; then
        in_logical=true
        continue
    fi
    if $in_logical && [[ "$line" =~ ^##[[:space:]] ]]; then
        break
    fi
    if $in_logical && [[ "$line" =~ \|[[:space:]]*(ARCH-[0-9]{3})[[:space:]]*\| ]]; then
        arch_id="${BASH_REMATCH[1]}"
        arch_ids+=("$arch_id")
        # Parent System Components is column 4 (0-indexed)
        parent_cell=$(echo "$line" | awk -F'|' '{print $5}')
        if echo "$parent_cell" | grep -q '\[CROSS-CUTTING\]'; then
            arch_cross_cutting["$arch_id"]=1
        fi
        parents=$(echo "$parent_cell" | grep -oE 'SYS-[0-9]{3}' || true)
        arch_parents["$arch_id"]="$parents"
    fi
done < "$ARCH_DESIGN"
arch_ids=($(printf '%s\n' "${arch_ids[@]}" | sort -u))

# Cross-cutting module list
cross_cutting_modules=()
for arch in "${arch_ids[@]}"; do
    if [[ -n "${arch_cross_cutting[$arch]}" ]]; then
        cross_cutting_modules+=("$arch")
    fi
done

# Mark SYS covered by ARCH parents
declare -A sys_covered
for arch in "${arch_ids[@]}"; do
    for p in ${arch_parents[$arch]}; do
        sys_covered["$p"]=1
    done
done

# ITP/ITS IDs from integration-test.md (if exists)
itp_ids=()
its_ids=()
if ! $PARTIAL_MODE; then
    itp_ids=($(grep -oE 'ITP-[0-9]{3}-[A-Z]' "$INTEGRATION_TEST" | sort -u))
    its_ids=($(grep -oE 'ITS-[0-9]{3}-[A-Z][0-9]+' "$INTEGRATION_TEST" | sort -u))
fi

total_sys=${#sys_ids[@]}
total_arch=${#arch_ids[@]}
total_cross_cutting=${#cross_cutting_modules[@]}
total_itps=${#itp_ids[@]}
total_itss=${#its_ids[@]}

# ---- Pass 2: Cross-reference ----

# Key extraction helpers
arch_base_key() { echo "$1" | sed 's/^ARCH-//'; }
itp_base_key() { echo "$1" | sed 's/^ITP-//' | sed 's/-[A-Z]$//'; }
itp_full_key() { echo "$1" | sed 's/^ITP-//'; }
its_full_key() { echo "$1" | sed 's/^ITS-//'; }

# Forward coverage: every SYS has at least one ARCH
sys_without_arch=()
for sys in "${sys_ids[@]}"; do
    if [[ -z "${sys_covered[$sys]}" ]]; then
        sys_without_arch+=("$sys")
    fi
done

# Backward coverage: every ARCH has at least one ITP (skip if partial)
arch_without_itp=()
if ! $PARTIAL_MODE; then
    for arch in "${arch_ids[@]}"; do
        arch_key=$(arch_base_key "$arch")
        has_itp=false
        for itp in "${itp_ids[@]}"; do
            itp_key=$(itp_base_key "$itp")
            if [[ "$arch_key" == "$itp_key" ]]; then
                has_itp=true
                break
            fi
        done
        if ! $has_itp; then
            arch_without_itp+=("$arch")
        fi
    done
fi

# ITP→ITS coverage (skip if partial)
itps_without_its=()
if ! $PARTIAL_MODE; then
    for itp in "${itp_ids[@]}"; do
        itp_key=$(itp_full_key "$itp")
        has_its=false
        for its in "${its_ids[@]}"; do
            its_key=$(its_full_key "$its")
            if [[ "$its_key" == "$itp_key"* ]]; then
                has_its=true
                break
            fi
        done
        if ! $has_its; then
            itps_without_its+=("$itp")
        fi
    done
fi

# Orphaned ARCH: referencing non-existent SYS (skip cross-cutting)
orphaned_arch=()
for arch in "${arch_ids[@]}"; do
    [[ -n "${arch_cross_cutting[$arch]}" ]] && continue
    for parent in ${arch_parents[$arch]}; do
        found=false
        for sys in "${sys_ids[@]}"; do
            if [[ "$parent" == "$sys" ]]; then
                found=true
                break
            fi
        done
        if ! $found; then
            orphaned_arch+=("$arch references unknown $parent")
            break
        fi
    done
done

# Orphaned ITP: referencing non-existent ARCH (skip if partial)
orphaned_itps=()
if ! $PARTIAL_MODE; then
    for itp in "${itp_ids[@]}"; do
        itp_key=$(itp_base_key "$itp")
        has_arch=false
        for arch in "${arch_ids[@]}"; do
            arch_key=$(arch_base_key "$arch")
            if [[ "$itp_key" == "$arch_key" ]]; then
                has_arch=true
                break
            fi
        done
        if ! $has_arch; then
            orphaned_itps+=("$itp")
        fi
    done
fi

# ---- Calculate coverage ----

sys_covered_count=$((total_sys - ${#sys_without_arch[@]}))
arch_covered_count=$((total_arch - ${#arch_without_itp[@]}))
itps_covered_count=$((total_itps - ${#itps_without_its[@]}))

if [[ $total_sys -gt 0 ]]; then
    sys_to_arch_coverage=$((sys_covered_count * 100 / total_sys))
else
    sys_to_arch_coverage=0
fi

if ! $PARTIAL_MODE && [[ $total_arch -gt 0 ]]; then
    arch_to_itp_coverage=$((arch_covered_count * 100 / total_arch))
else
    arch_to_itp_coverage=0
fi

if ! $PARTIAL_MODE && [[ $total_itps -gt 0 ]]; then
    itp_to_its_coverage=$((itps_covered_count * 100 / total_itps))
else
    itp_to_its_coverage=0
fi

has_gaps=false
if [[ ${#sys_without_arch[@]} -gt 0 ]] || [[ ${#arch_without_itp[@]} -gt 0 ]] || \
   [[ ${#itps_without_its[@]} -gt 0 ]] || [[ ${#orphaned_arch[@]} -gt 0 ]] || \
   [[ ${#orphaned_itps[@]} -gt 0 ]]; then
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
    cat << EOF
{
  "total_sys": $total_sys,
  "total_arch": $total_arch,
  "total_cross_cutting": $total_cross_cutting,
  "total_itps": $total_itps,
  "total_itss": $total_itss,
  "sys_covered": $sys_covered_count,
  "arch_covered": $arch_covered_count,
  "itps_covered": $itps_covered_count,
  "sys_to_arch_coverage_pct": $sys_to_arch_coverage,
  "arch_to_itp_coverage_pct": $arch_to_itp_coverage,
  "itp_to_its_coverage_pct": $itp_to_its_coverage,
  "has_gaps": $has_gaps,
  "partial_mode": $PARTIAL_MODE,
  "sys_without_arch": $(fmt_array "${sys_without_arch[@]}"),
  "arch_without_itp": $(fmt_array "${arch_without_itp[@]}"),
  "itps_without_its": $(fmt_array "${itps_without_its[@]}"),
  "orphaned_arch": $(fmt_array "${orphaned_arch[@]}"),
  "orphaned_itps": $(fmt_array "${orphaned_itps[@]}"),
  "cross_cutting_modules": $(fmt_array "${cross_cutting_modules[@]}")
}
EOF
else
    echo "=== Architecture-Level Coverage Validation ==="
    echo ""
    echo "Totals: $total_sys SYS | $total_arch ARCH ($total_cross_cutting cross-cutting) | $total_itps ITPs | $total_itss ITSs"
    echo "SYS → ARCH coverage: $sys_covered_count/$total_sys ($sys_to_arch_coverage%)"
    if $PARTIAL_MODE; then
        echo "ARCH → ITP coverage: SKIPPED (integration-test.md not found)"
        echo "ITP → ITS coverage: SKIPPED"
    else
        echo "ARCH → ITP coverage: $arch_covered_count/$total_arch ($arch_to_itp_coverage%)"
        echo "ITP → ITS coverage: $itps_covered_count/$total_itps ($itp_to_its_coverage%)"
    fi
    echo ""

    if [[ ${#sys_without_arch[@]} -gt 0 ]]; then
        echo "❌ System components WITHOUT architecture modules:"
        for sys in "${sys_without_arch[@]}"; do
            echo "   - $sys"
        done
        echo ""
    fi

    if [[ ${#arch_without_itp[@]} -gt 0 ]]; then
        echo "❌ Architecture modules WITHOUT integration tests:"
        for arch in "${arch_without_itp[@]}"; do
            echo "   - $arch"
        done
        echo ""
    fi

    if [[ ${#itps_without_its[@]} -gt 0 ]]; then
        echo "❌ Integration test procedures WITHOUT scenarios:"
        for itp in "${itps_without_its[@]}"; do
            echo "   - $itp"
        done
        echo ""
    fi

    if [[ ${#orphaned_arch[@]} -gt 0 ]]; then
        echo "⚠️  Orphaned architecture modules (referencing non-existent SYS):"
        for msg in "${orphaned_arch[@]}"; do
            echo "   - $msg"
        done
        echo ""
    fi

    if [[ ${#orphaned_itps[@]} -gt 0 ]]; then
        echo "⚠️  Orphaned integration tests (referencing non-existent ARCH):"
        for itp in "${orphaned_itps[@]}"; do
            echo "   - $itp"
        done
        echo ""
    fi

    if [[ ${#cross_cutting_modules[@]} -gt 0 ]]; then
        echo "ℹ️  Cross-cutting modules (no SYS parent required):"
        for arch in "${cross_cutting_modules[@]}"; do
            echo "   - $arch [CROSS-CUTTING]"
        done
        echo ""
    fi

    if ! $has_gaps; then
        echo "✅ Full architecture-level coverage — all system components decomposed, all modules tested."
    fi
fi

$has_gaps && exit 1 || exit 0
