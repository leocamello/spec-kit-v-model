#!/usr/bin/env bash

# Deterministic coverage validation for software-architecture-design V-Model artifacts
#
# Parses requirements.md, software-architecture-design.md, and integration-test.md
# using regex to extract REQ-NNN, ARCH-NNN, ITP-NNN-X, and ITS-NNN-X IDs.
# Cross-references them to verify:
#   - Forward coverage: every REQ has at least one ARCH
#   - Backward coverage: every ARCH has at least one ITP
#   - ITP→ITS coverage: every ITP has at least one ITS
#   - No orphaned ITP (ITP referencing non-existent ARCH)
#
# Usage: ./validate-software-architecture-coverage.sh [OPTIONS] <vmodel-dir>
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
            echo "Usage: validate-software-architecture-coverage.sh [--json] <vmodel-dir>"
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
SOFTWARE_ARCHITECTURE_DESIGN="$VMODEL_DIR/software-architecture-design.md"
INTEGRATION_TEST="$VMODEL_DIR/integration-test.md"

if [[ ! -f "$REQUIREMENTS" ]]; then
    echo "ERROR: requirements.md not found in $VMODEL_DIR" >&2
    exit 1
fi

if [[ ! -f "$SOFTWARE_ARCHITECTURE_DESIGN" ]]; then
    echo "ERROR: software-architecture-design.md not found in $VMODEL_DIR" >&2
    exit 1
fi

PARTIAL_MODE=false
if [[ ! -f "$INTEGRATION_TEST" ]]; then
    PARTIAL_MODE=true
fi

# ---- Pass 1: Extract IDs ----
req_ids=($(grep -oE 'REQ-[0-9]{3}' "$REQUIREMENTS" | sort -u))
arch_ids=($(grep -oE 'ARCH-[0-9]{3}' "$SOFTWARE_ARCHITECTURE_DESIGN" | sort -u))

arch_req_refs=()
while IFS= read -r line; do
    if [[ "$line" =~ REQ-[0-9]{3} ]]; then
        while [[ "$line" =~ (REQ-[0-9]{3}) ]]; do
            arch_req_refs+=("${BASH_REMATCH[1]}")
            line="${line#*${BASH_REMATCH[1]}}"
        done
    fi
done < "$SOFTWARE_ARCHITECTURE_DESIGN"
arch_req_refs=($(printf '%s\n' "${arch_req_refs[@]}" | sort -u))

itp_ids=()
its_ids=()
if ! $PARTIAL_MODE; then
    itp_ids=($(grep -oE 'ITP-[0-9]{3}-[A-Z]' "$INTEGRATION_TEST" | sort -u))
    its_ids=($(grep -oE 'ITS-[0-9]{3}-[A-Z][0-9]+' "$INTEGRATION_TEST" | sort -u))
fi

# ---- Pass 2: Cross-reference ----
req_without_arch=()
for req in "${req_ids[@]}"; do
    if [[ ! " ${arch_req_refs[*]} " =~ " $req " ]]; then
        req_without_arch+=("$req")
    fi
done

arch_without_itp=()
if ! $PARTIAL_MODE; then
    arch_base_key() { echo "$1" | sed 's/^ARCH-//'; }
    itp_base_key() { echo "$1" | sed 's/^ITP-//' | sed 's/-[A-Z]$//'; }
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

orphaned_itps=()
if ! $PARTIAL_MODE; then
    arch_base_key() { echo "$1" | sed 's/^ARCH-//'; }
    itp_base_key() { echo "$1" | sed 's/^ITP-//' | sed 's/-[A-Z]$//'; }
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
req_covered_count=$(( ${#req_ids[@]} - ${#req_without_arch[@]} ))
arch_covered_count=$(( ${#arch_ids[@]} - ${#arch_without_itp[@]} ))
itps_covered_count=$(( ${#itp_ids[@]} - ${#its_ids[@]} ))

if [[ ${#req_ids[@]} -gt 0 ]]; then
    req_to_arch_coverage=$(( req_covered_count * 100 / ${#req_ids[@]} ))
else
    req_to_arch_coverage=0
fi

if ! $PARTIAL_MODE && [[ ${#arch_ids[@]} -gt 0 ]]; then
    arch_to_itp_coverage=$(( arch_covered_count * 100 / ${#arch_ids[@]} ))
else
    arch_to_itp_coverage=0
fi

has_gaps=false
if [[ ${#req_without_arch[@]} -gt 0 ]] || [[ ${#arch_without_itp[@]} -gt 0 ]] || [[ ${#orphaned_itps[@]} -gt 0 ]]; then
    has_gaps=true
fi

fmt_array() {
    local arr=("$@")
    if [[ ${#arr[@]} -eq 0 ]]; then echo "[]"; return; fi
    local result=$(printf '"%s",' "${arr[@]}")
    echo "[${result%,}]"
}

if $JSON_MODE; then
    cat << EOF
{
  "total_req": ${#req_ids[@]},
  "total_arch": ${#arch_ids[@]},
  "total_itps": ${#itp_ids[@]},
  "total_itss": ${#its_ids[@]},
  "req_covered": $req_covered_count,
  "arch_covered": $arch_covered_count,
  "itps_covered": $itps_covered_count,
  "req_to_arch_coverage_pct": $req_to_arch_coverage,
  "arch_to_itp_coverage_pct": $arch_to_itp_coverage,
  "has_gaps": $has_gaps,
  "partial_mode": $PARTIAL_MODE,
  "req_without_arch": $(fmt_array "${req_without_arch[@]}"),
  "arch_without_itp": $(fmt_array "${arch_without_itp[@]}"),
  "orphaned_itps": $(fmt_array "${orphaned_itps[@]}")
}
EOF
else
    echo "=== Software Architecture Coverage Validation ==="
    echo ""
    echo "Totals: ${#req_ids[@]} REQ | ${#arch_ids[@]} ARCH | ${#itp_ids[@]} ITPs | ${#its_ids[@]} ITSs"
    echo "REQ → ARCH coverage: $req_covered_count/${#req_ids[@]} ($req_to_arch_coverage%)"
    if $PARTIAL_MODE; then
        echo "ARCH → ITP coverage: SKIPPED (integration-test.md not found)"
        echo "ITP → ITS coverage: SKIPPED"
    else
        itp_to_its_coverage=0
        if [[ ${#itp_ids[@]} -gt 0 ]]; then
            itp_to_its_coverage=$(( itps_covered_count * 100 / ${#itp_ids[@]} ))
        fi
        echo "ARCH → ITP coverage: $arch_covered_count/${#arch_ids[@]} ($arch_to_itp_coverage%)"
        echo "ITP → ITS coverage: $itps_covered_count/${#itp_ids[@]} ($itp_to_its_coverage%)"
    fi
    echo ""

    if [[ ${#req_without_arch[@]} -gt 0 ]]; then
        echo "❌ Requirements WITHOUT architecture traceability:"
        for req in "${req_without_arch[@]}"; do
            echo "   - $req"
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

    if [[ ${#orphaned_itps[@]} -gt 0 ]]; then
        echo "⚠️  Orphaned integration tests (referencing non-existent ARCH):"
        for itp in "${orphaned_itps[@]}"; do
            echo "   - $itp"
        done
        echo ""
    fi

    if ! $has_gaps; then
        echo "✅ Full software architecture coverage — all requirements linked and all architecture modules tested."
    fi
fi

$has_gaps && exit 1 || exit 0
