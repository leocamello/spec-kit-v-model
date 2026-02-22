#!/usr/bin/env bash

# Deterministic coverage validation for module-level V-Model artifacts
#
# Parses architecture-design.md, module-design.md, and unit-test.md
# using regex to extract ARCH-NNN, MOD-NNN, UTP-NNN-X, and UTS-NNN-X# IDs.
# Cross-references them to verify:
#   - Forward coverage: every ARCH has at least one MOD
#   - Backward coverage: every non-[EXTERNAL] MOD has at least one UTP
#   - UTP→UTS coverage: every UTP has at least one UTS
#   - No orphaned MOD (MOD referencing non-existent ARCH)
#   - No orphaned UTP (UTP referencing non-existent MOD)
#   - [EXTERNAL] modules are bypassed for UTP requirement
#   - [CROSS-CUTTING] parent ARCHs are tested normally
#
# Usage: ./validate-module-coverage.sh [OPTIONS] <vmodel-dir>
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
            echo "Usage: validate-module-coverage.sh [--json] <vmodel-dir>"
            exit 0
            ;;
        *) VMODEL_DIR="$arg" ;;
    esac
done

if [[ -z "$VMODEL_DIR" ]]; then
    echo "ERROR: vmodel-dir argument required" >&2
    exit 1
fi

ARCH_DESIGN="$VMODEL_DIR/architecture-design.md"
MODULE_DESIGN="$VMODEL_DIR/module-design.md"
UNIT_TEST="$VMODEL_DIR/unit-test.md"

if [[ ! -f "$ARCH_DESIGN" ]]; then
    echo "ERROR: architecture-design.md not found in $VMODEL_DIR" >&2
    exit 1
fi

if [[ ! -f "$MODULE_DESIGN" ]]; then
    echo "ERROR: module-design.md not found in $VMODEL_DIR" >&2
    exit 1
fi

PARTIAL_MODE=false
if [[ ! -f "$UNIT_TEST" ]]; then
    PARTIAL_MODE=true
fi

# ---- Pass 1: Extract IDs ----

# ARCH IDs from architecture-design.md Logical View (section-scoped)
arch_ids=()
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
        arch_ids+=("${BASH_REMATCH[1]}")
    fi
done < "$ARCH_DESIGN"
arch_ids=($(printf '%s\n' "${arch_ids[@]}" | sort -u))

# MOD IDs from module-design.md (heading lines + metadata)
mod_ids=()
declare -A mod_parents     # MOD-NNN -> "ARCH-001 ARCH-002 ..."
declare -A mod_external    # MOD-NNN -> 1 if [EXTERNAL]
current_mod=""
in_metadata=true
while IFS= read -r line; do
    # Match module heading: ### Module: MOD-NNN (...)
    if [[ "$line" =~ ^###[[:space:]]+Module:[[:space:]]*(MOD-[0-9]{3}) ]]; then
        current_mod="${BASH_REMATCH[1]}"
        mod_ids+=("$current_mod")
        in_metadata=true
        if echo "$line" | grep -q '\[EXTERNAL\]'; then
            mod_external["$current_mod"]=1
        fi
        continue
    fi
    # Stop metadata scanning at first sub-heading or section break
    if [[ "$line" =~ ^#### ]] || [[ "$line" =~ ^---$ ]]; then
        in_metadata=false
    fi
    # Reset at next top-level heading (non-module)
    if [[ "$line" =~ ^###[[:space:]] && ! "$line" =~ Module: ]]; then
        current_mod=""
        in_metadata=false
    fi
    if [[ -n "$current_mod" ]] && $in_metadata; then
        if [[ "$line" =~ ^\*\*Parent\ Architecture\ Modules\*\*: ]]; then
            parents=$(echo "$line" | grep -oE 'ARCH-[0-9]{3}' || true)
            mod_parents["$current_mod"]="$parents"
        fi
        if echo "$line" | grep -q '\[EXTERNAL\]'; then
            mod_external["$current_mod"]=1
        fi
    fi
done < "$MODULE_DESIGN"
mod_ids=($(printf '%s\n' "${mod_ids[@]}" | sort -u))

# External module list
external_modules=()
for mod in "${mod_ids[@]}"; do
    if [[ -n "${mod_external[$mod]}" ]]; then
        external_modules+=("$mod")
    fi
done

# Mark ARCH covered by MOD parents
declare -A arch_covered
for mod in "${mod_ids[@]}"; do
    for p in ${mod_parents[$mod]}; do
        arch_covered["$p"]=1
    done
done

# UTP/UTS IDs from unit-test.md (if exists)
utp_ids=()
uts_ids=()
if ! $PARTIAL_MODE; then
    utp_ids=($(grep -oE 'UTP-[0-9]{3}-[A-Z]' "$UNIT_TEST" | sort -u))
    uts_ids=($(grep -oE 'UTS-[0-9]{3}-[A-Z][0-9]+' "$UNIT_TEST" | sort -u))
fi

total_arch=${#arch_ids[@]}
total_mod=${#mod_ids[@]}
total_external=${#external_modules[@]}
total_testable=$((total_mod - total_external))
total_utps=${#utp_ids[@]}
total_utss=${#uts_ids[@]}

# ---- Pass 2: Cross-reference ----

mod_base_key() { echo "$1" | sed 's/^MOD-//'; }
utp_base_key() { echo "$1" | sed 's/^UTP-//' | sed 's/-[A-Z]$//'; }
utp_full_key() { echo "$1" | sed 's/^UTP-//'; }
uts_full_key() { echo "$1" | sed 's/^UTS-//'; }

# Forward coverage: every ARCH has at least one MOD
arch_without_mod=()
for arch in "${arch_ids[@]}"; do
    if [[ -z "${arch_covered[$arch]}" ]]; then
        arch_without_mod+=("$arch")
    fi
done

# Backward coverage: every non-[EXTERNAL] MOD has at least one UTP (skip if partial)
mod_without_utp=()
if ! $PARTIAL_MODE; then
    for mod in "${mod_ids[@]}"; do
        [[ -n "${mod_external[$mod]}" ]] && continue
        mod_key=$(mod_base_key "$mod")
        has_utp=false
        for utp in "${utp_ids[@]}"; do
            utp_key=$(utp_base_key "$utp")
            if [[ "$mod_key" == "$utp_key" ]]; then
                has_utp=true
                break
            fi
        done
        if ! $has_utp; then
            mod_without_utp+=("$mod")
        fi
    done
fi

# UTP→UTS coverage (skip if partial)
utps_without_uts=()
if ! $PARTIAL_MODE; then
    for utp in "${utp_ids[@]}"; do
        utp_key=$(utp_full_key "$utp")
        has_uts=false
        for uts in "${uts_ids[@]}"; do
            uts_key=$(uts_full_key "$uts")
            if [[ "$uts_key" == "$utp_key"* ]]; then
                has_uts=true
                break
            fi
        done
        if ! $has_uts; then
            utps_without_uts+=("$utp")
        fi
    done
fi

# Orphaned MOD: referencing non-existent ARCH
orphaned_mods=()
for mod in "${mod_ids[@]}"; do
    for parent in ${mod_parents[$mod]}; do
        found=false
        for arch in "${arch_ids[@]}"; do
            if [[ "$parent" == "$arch" ]]; then
                found=true
                break
            fi
        done
        if ! $found; then
            orphaned_mods+=("$mod references unknown $parent")
            break
        fi
    done
done

# Orphaned UTP: referencing non-existent MOD (skip if partial)
orphaned_utps=()
if ! $PARTIAL_MODE; then
    for utp in "${utp_ids[@]}"; do
        utp_key=$(utp_base_key "$utp")
        has_mod=false
        for mod in "${mod_ids[@]}"; do
            mod_key=$(mod_base_key "$mod")
            if [[ "$utp_key" == "$mod_key" ]]; then
                has_mod=true
                break
            fi
        done
        if ! $has_mod; then
            orphaned_utps+=("$utp")
        fi
    done
fi

# ---- Calculate coverage ----

arch_covered_count=$((total_arch - ${#arch_without_mod[@]}))
mod_covered_count=$((total_testable - ${#mod_without_utp[@]}))
utps_covered_count=$((total_utps - ${#utps_without_uts[@]}))

if [[ $total_arch -gt 0 ]]; then
    arch_to_mod_coverage=$((arch_covered_count * 100 / total_arch))
else
    arch_to_mod_coverage=0
fi

if ! $PARTIAL_MODE && [[ $total_testable -gt 0 ]]; then
    mod_to_utp_coverage=$((mod_covered_count * 100 / total_testable))
else
    mod_to_utp_coverage=0
fi

if ! $PARTIAL_MODE && [[ $total_utps -gt 0 ]]; then
    utp_to_uts_coverage=$((utps_covered_count * 100 / total_utps))
else
    utp_to_uts_coverage=0
fi

has_gaps=false
if [[ ${#arch_without_mod[@]} -gt 0 ]] || [[ ${#mod_without_utp[@]} -gt 0 ]] || \
   [[ ${#utps_without_uts[@]} -gt 0 ]] || [[ ${#orphaned_mods[@]} -gt 0 ]] || \
   [[ ${#orphaned_utps[@]} -gt 0 ]]; then
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
  "total_arch": $total_arch,
  "total_mod": $total_mod,
  "total_external": $total_external,
  "total_testable": $total_testable,
  "total_utps": $total_utps,
  "total_utss": $total_utss,
  "arch_covered": $arch_covered_count,
  "mod_covered": $mod_covered_count,
  "utps_covered": $utps_covered_count,
  "arch_to_mod_coverage_pct": $arch_to_mod_coverage,
  "mod_to_utp_coverage_pct": $mod_to_utp_coverage,
  "utp_to_uts_coverage_pct": $utp_to_uts_coverage,
  "has_gaps": $has_gaps,
  "partial_mode": $PARTIAL_MODE,
  "arch_without_mod": $(fmt_array "${arch_without_mod[@]}"),
  "mod_without_utp": $(fmt_array "${mod_without_utp[@]}"),
  "utps_without_uts": $(fmt_array "${utps_without_uts[@]}"),
  "orphaned_mods": $(fmt_array "${orphaned_mods[@]}"),
  "orphaned_utps": $(fmt_array "${orphaned_utps[@]}"),
  "external_modules": $(fmt_array "${external_modules[@]}")
}
EOF
else
    echo "=== Module-Level Coverage Validation ==="
    echo ""
    echo "Totals: $total_arch ARCH | $total_mod MOD ($total_external external) | $total_utps UTPs | $total_utss UTSs"
    echo "ARCH → MOD coverage: $arch_covered_count/$total_arch ($arch_to_mod_coverage%)"
    if $PARTIAL_MODE; then
        echo "MOD → UTP coverage: SKIPPED (unit-test.md not found)"
        echo "UTP → UTS coverage: SKIPPED"
    else
        echo "MOD → UTP coverage: $mod_covered_count/$total_testable ($mod_to_utp_coverage%) [excluding $total_external external]"
        echo "UTP → UTS coverage: $utps_covered_count/$total_utps ($utp_to_uts_coverage%)"
    fi
    echo ""

    if [[ ${#arch_without_mod[@]} -gt 0 ]]; then
        echo "❌ Architecture modules WITHOUT module designs:"
        for arch in "${arch_without_mod[@]}"; do
            echo "   - $arch"
        done
        echo ""
    fi

    if [[ ${#mod_without_utp[@]} -gt 0 ]]; then
        echo "❌ Module designs WITHOUT unit tests:"
        for mod in "${mod_without_utp[@]}"; do
            echo "   - $mod"
        done
        echo ""
    fi

    if [[ ${#utps_without_uts[@]} -gt 0 ]]; then
        echo "❌ Unit test cases WITHOUT scenarios:"
        for utp in "${utps_without_uts[@]}"; do
            echo "   - $utp"
        done
        echo ""
    fi

    if [[ ${#orphaned_mods[@]} -gt 0 ]]; then
        echo "⚠️  Orphaned module designs (referencing non-existent ARCH):"
        for msg in "${orphaned_mods[@]}"; do
            echo "   - $msg"
        done
        echo ""
    fi

    if [[ ${#orphaned_utps[@]} -gt 0 ]]; then
        echo "⚠️  Orphaned unit test cases (referencing non-existent MOD):"
        for utp in "${orphaned_utps[@]}"; do
            echo "   - $utp"
        done
        echo ""
    fi

    if [[ ${#external_modules[@]} -gt 0 ]]; then
        echo "ℹ️  External modules (UTP requirement bypassed):"
        for mod in "${external_modules[@]}"; do
            echo "   - $mod [EXTERNAL]"
        done
        echo ""
    fi

    if ! $has_gaps; then
        echo "✅ Full module-level coverage — all architecture modules decomposed, all testable modules have unit tests."
    fi
fi

$has_gaps && exit 1 || exit 0
