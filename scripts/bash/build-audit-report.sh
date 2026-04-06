#!/usr/bin/env bash

# build-audit-report.sh — Build release audit report from V-Model artifacts.
# 100% deterministic, no AI. Discovers artifacts, extracts matrices,
# cross-references anomalies with waivers, computes compliance status.
#
# Usage: build-audit-report.sh <vmodel-dir> [OPTIONS]
#
# OPTIONS:
#   --system-name <name>         System name for executive summary
#   --version <ver>              Release version
#   --git-tag <tag>              Git release tag
#   --regulatory-context <ctx>   Applicable regulatory standards
#   --output <path>              Output file path (default: <vmodel-dir>/release-audit-report.md)
#   --json                       Output JSON to stdout
#   --help                       Show usage information
#
# EXIT CODES:
#   0 = RELEASE READY or RELEASE CANDIDATE (all anomalies waived)
#   1 = NOT READY (unwaived anomalies)
#   2 = Error (missing required artifacts or invalid arguments)

set -e

# ---- Constants ----
EXPECTED_FILES=(
    "requirements.md"
    "acceptance-plan.md"
    "system-design.md"
    "system-test.md"
    "architecture-design.md"
    "integration-test.md"
    "module-design.md"
    "unit-test.md"
    "hazard-analysis.md"
    "traceability-matrix.md"
    "waivers.md"
)

HUMAN_NAMES=(
    "Requirements"
    "Acceptance Plan"
    "System Design"
    "System Test"
    "Architecture Design"
    "Integration Test"
    "Module Design"
    "Unit Test"
    "Hazard Analysis"
    "Traceability Matrix"
    "Waivers"
)

REQUIRED_FILES=("requirements.md" "traceability-matrix.md")

# ---- Helpers ----
strip_bold() {
    # Remove **bold** markers and leading/trailing whitespace
    local val="$1"
    val="${val#"${val%%[![:space:]]*}"}"
    val="${val%"${val##*[![:space:]]}"}"
    val="${val#\*\*}"
    val="${val%\*\*}"
    echo "$val"
}

parse_columns() {
    # Parse a pipe-delimited table row into an array stored in COLUMNS
    local line="$1"
    line="${line#|}"
    line="${line%|}"
    COLUMNS=()
    local IFS='|'
    local parts
    read -ra parts <<< "$line"
    for part in "${parts[@]}"; do
        local trimmed
        trimmed="$(echo "$part" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
        COLUMNS+=("$trimmed")
    done
}

json_escape() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\t'/\\t}"
    echo "$s"
}

# ---- CLI Parsing (MOD-001) ----
show_help() {
    cat << 'EOF'
Usage: build-audit-report.sh <vmodel-dir> [OPTIONS]

Build a release audit report from V-Model artifacts.

POSITIONAL:
  <vmodel-dir>                V-Model directory path (required)

OPTIONS:
  --system-name <name>        System name for executive summary
  --version <ver>             Release version
  --git-tag <tag>             Git release tag
  --regulatory-context <ctx>  Applicable regulatory standards
  --output <path>             Output file (default: <vmodel-dir>/release-audit-report.md)
  --json                      Output JSON to stdout
  --help                      Show this help message

EXIT CODES:
  0 = RELEASE READY or RELEASE CANDIDATE
  1 = NOT READY (unwaived anomalies)
  2 = Error (missing required artifacts)
EOF
    exit 0
}

VMODEL_DIR=""
SYSTEM_NAME="(not specified)"
VERSION="(not specified)"
GIT_TAG="(not specified)"
REGULATORY_CONTEXT="(not specified)"
OUTPUT_PATH=""
JSON_MODE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --system-name)      SYSTEM_NAME="$2"; shift 2 ;;
        --version)          VERSION="$2"; shift 2 ;;
        --git-tag)          GIT_TAG="$2"; shift 2 ;;
        --regulatory-context) REGULATORY_CONTEXT="$2"; shift 2 ;;
        --output)           OUTPUT_PATH="$2"; shift 2 ;;
        --json)             JSON_MODE=true; shift ;;
        --help|-h)          show_help ;;
        -*)                 echo "ERROR: Unknown option: $1" >&2; exit 2 ;;
        *)                  VMODEL_DIR="$1"; shift ;;
    esac
done

if [[ -z "$VMODEL_DIR" ]]; then
    echo "ERROR: V-Model directory argument required" >&2
    echo "Usage: build-audit-report.sh <vmodel-dir> [OPTIONS]" >&2
    exit 2
fi

if [[ ! -d "$VMODEL_DIR" ]]; then
    echo "ERROR: Directory not found: $VMODEL_DIR" >&2
    exit 2
fi

for req_file in "${REQUIRED_FILES[@]}"; do
    if [[ ! -f "$VMODEL_DIR/$req_file" ]]; then
        echo "ERROR: Required artifact missing: $req_file" >&2
        exit 2
    fi
done

if [[ -z "$OUTPUT_PATH" ]]; then
    OUTPUT_PATH="$VMODEL_DIR/release-audit-report.md"
fi

GENERATION_DATE=$(date -u +%Y-%m-%d)

# ---- Temp directory ----
WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

# ============================================================
# MOD-002: Discover Artifacts
# ============================================================
artifact_found=0

for i in "${!EXPECTED_FILES[@]}"; do
    file="${EXPECTED_FILES[$i]}"
    name="${HUMAN_NAMES[$i]}"
    filepath="$VMODEL_DIR/$file"
    if [[ -f "$filepath" ]]; then
        sha=$(git -C "$VMODEL_DIR" log -1 --format='%h' -- "$file" 2>/dev/null || echo "N/A")
        gdate=$(git -C "$VMODEL_DIR" log -1 --format='%aI' -- "$file" 2>/dev/null | cut -d'T' -f1)
        [[ -z "$gdate" ]] && gdate="N/A"
        printf '%s\t%s\t%s\t%s\t%s\n' "$name" "$file" "$sha" "$gdate" "Present" >> "$WORK_DIR/artifacts.tsv"
        ((artifact_found++)) || true
    else
        printf '%s\t%s\t%s\t%s\t%s\n' "$name" "$file" "—" "—" "Missing" >> "$WORK_DIR/artifacts.tsv"
    fi
done

# Resolve git SHA for report metadata
GIT_SHA=$(git -C "$VMODEL_DIR" log -1 --format='%h' 2>/dev/null || echo "N/A")

# ============================================================
# MOD-003 + MOD-004: Parse Matrix File & Compute Coverage
# ============================================================
MATRIX_PATH="$VMODEL_DIR/traceability-matrix.md"
total_passed=0
total_failed=0
total_skipped=0
total_untested=0
matrix_count=0

current_matrix_id=""
current_matrix_title=""
current_header=""
status_col_idx=-1
test_id_col_idx=-1
first_id_col_idx=0

declare -A source_ids_all       # matrix_id:source_id → 1
declare -A source_has_target    # matrix_id:source_id → 1
declare -A target_ids_all       # matrix_id:target_id → 1

finish_matrix() {
    if [[ -z "$current_matrix_id" ]]; then
        return
    fi

    # Compute coverage for current matrix
    local fwd_total=0 fwd_covered=0 bwd_total=0
    local gaps="" orphans=""

    for key in "${!source_ids_all[@]}"; do
        if [[ "$key" == "${current_matrix_id}:"* ]]; then
            ((fwd_total++)) || true
            local src_id="${key#*:}"
            if [[ -n "${source_has_target[${current_matrix_id}:${src_id}]+x}" ]]; then
                ((fwd_covered++)) || true
            else
                gaps="${gaps}${gaps:+, }${src_id}"
            fi
        fi
    done

    for key in "${!target_ids_all[@]}"; do
        if [[ "$key" == "${current_matrix_id}:"* ]]; then
            ((bwd_total++)) || true
        fi
    done

    local fwd_pct="0"
    [[ $fwd_total -gt 0 ]] && fwd_pct=$(( fwd_covered * 100 / fwd_total ))
    local bwd_pct="100"
    [[ $bwd_total -eq 0 ]] && bwd_pct="0"

    local gap_count=0
    if [[ -n "$gaps" ]]; then
        gap_count=$(echo "$gaps" | tr ',' '\n' | wc -l | tr -d ' ')
    fi

    printf '%s\t%s\t%s/%s (%s%%)\t%s/%s (%s%%)\t%s\t%s\n' \
        "$current_matrix_id" "$current_matrix_title" \
        "$fwd_covered" "$fwd_total" "$fwd_pct" \
        "$bwd_total" "$bwd_total" "$bwd_pct" \
        "$gap_count" "0" >> "$WORK_DIR/coverage.tsv"

    ((matrix_count++)) || true
}

current_source=""

while IFS= read -r line; do
    # Detect matrix section heading
    if [[ "$line" =~ ^##[[:space:]]+(Matrix[[:space:]]+[A-Z]) ]]; then
        finish_matrix
        current_matrix_id="${BASH_REMATCH[1]}"
        current_matrix_title="$line"
        current_matrix_title="${current_matrix_title#\#\# }"
        current_header=""
        status_col_idx=-1
        test_id_col_idx=-1
        current_source=""

        # Store raw matrix text
        echo "$line" >> "$WORK_DIR/matrices_raw.md"
        echo "" >> "$WORK_DIR/matrices_raw.md"
        continue
    fi

    # Skip non-matrix content
    if [[ -z "$current_matrix_id" ]]; then
        continue
    fi

    # Detect section exit (next heading that's not a sub-heading of current matrix)
    if [[ "$line" =~ ^##[[:space:]] && ! "$line" =~ ^###[[:space:]] && ! "$line" =~ ^##[[:space:]]+Matrix ]]; then
        finish_matrix
        current_matrix_id=""
        continue
    fi

    # Store raw text for embedding
    echo "$line" >> "$WORK_DIR/matrices_raw.md"

    # Skip non-table lines
    if [[ ! "$line" =~ ^\| ]]; then
        continue
    fi

    # Skip separator rows
    if [[ "$line" =~ ^\|[[:space:]]*[-:]+ ]]; then
        continue
    fi

    parse_columns "$line"

    # Parse header row
    if [[ -z "$current_header" ]]; then
        current_header="$line"
        for ci in "${!COLUMNS[@]}"; do
            col_lower=$(echo "${COLUMNS[$ci]}" | tr '[:upper:]' '[:lower:]')
            if [[ "$col_lower" == *"status"* ]]; then
                status_col_idx=$ci
            fi
            if [[ "$col_lower" == *"scenario id"* || "$col_lower" == *"(scn)"* || "$col_lower" == *"(sts)"* || "$col_lower" == *"(its)"* || "$col_lower" == *"(uts)"* ]]; then
                test_id_col_idx=$ci
            fi
        done
        # Fallback: test ID is one before Status
        if [[ $test_id_col_idx -eq -1 && $status_col_idx -gt 0 ]]; then
            test_id_col_idx=$((status_col_idx - 1))
        fi
        continue
    fi

    # Parse data row
    if [[ $status_col_idx -lt 0 ]]; then
        continue
    fi

    local_status="${COLUMNS[$status_col_idx]:-}"
    local_test_id="${COLUMNS[$test_id_col_idx]:-}"
    local_source_raw="${COLUMNS[$first_id_col_idx]:-}"
    local_source=$(strip_bold "$local_source_raw")

    # Inherit source from previous row if empty
    if [[ -n "$local_source" ]]; then
        current_source="$local_source"
    fi

    # Track source/target IDs for coverage
    if [[ -n "$current_source" ]]; then
        source_ids_all["${current_matrix_id}:${current_source}"]=1
        if [[ -n "$local_test_id" ]]; then
            source_has_target["${current_matrix_id}:${current_source}"]=1
        fi
    fi
    if [[ -n "$local_test_id" ]]; then
        target_ids_all["${current_matrix_id}:${local_test_id}"]=1
    fi

    # Count test statuses
    if [[ "$local_status" == *"✅"* || "$local_status" == *"Passed"* ]]; then
        ((total_passed++)) || true
    elif [[ "$local_status" == *"❌"* || "$local_status" == *"Failed"* ]]; then
        ((total_failed++)) || true
        # Record anomaly (MOD-006)
        if [[ -n "$local_test_id" ]]; then
            printf '%s\t%s\t%s\n' "$local_test_id" "Failed Test" "$current_matrix_id" >> "$WORK_DIR/anomalies.tsv"
        fi
    elif [[ "$local_status" == *"⏭️"* || "$local_status" == *"Skipped"* ]]; then
        ((total_skipped++)) || true
        if [[ -n "$local_test_id" ]]; then
            printf '%s\t%s\t%s\n' "$local_test_id" "Skipped Test" "$current_matrix_id" >> "$WORK_DIR/anomalies.tsv"
        fi
    elif [[ "$local_status" == *"⬜"* || "$local_status" == *"Untested"* || "$local_status" == *"Pending"* ]]; then
        ((total_untested++)) || true
    fi

done < "$MATRIX_PATH"

finish_matrix

total_tests=$((total_passed + total_failed + total_skipped + total_untested))

# Count unique requirements from Matrix A source IDs
total_reqs=0
for key in "${!source_ids_all[@]}"; do
    if [[ "$key" == "Matrix A:"* ]]; then
        ((total_reqs++)) || true
    fi
done

# ============================================================
# MOD-005: Parse Hazards
# ============================================================
HAZARD_PATH="$VMODEL_DIR/hazard-analysis.md"
total_hazards=0
total_mitigated=0

if [[ -f "$HAZARD_PATH" ]]; then
    while IFS= read -r line; do
        if [[ "$line" =~ ^\|[[:space:]]*\*?\*?(HAZ-[0-9]{3})\*?\*? ]]; then
            parse_columns "$line"
            haz_id=$(strip_bold "${COLUMNS[0]}")
            # Write full row for report rendering
            echo "$line" >> "$WORK_DIR/hazards_raw.tsv"
            ((total_hazards++)) || true
            ((total_mitigated++)) || true
        fi
    done < "$HAZARD_PATH"
fi

# ============================================================
# MOD-007: Parse Waivers
# ============================================================
WAIVER_PATH="$VMODEL_DIR/waivers.md"
declare -A waiver_wav_id
declare -A waiver_type
declare -A waiver_justification
declare -A waiver_approved_by
waiver_artifact_ids=()

if [[ -f "$WAIVER_PATH" ]]; then
    current_wav=""
    current_artifact=""
    current_type=""
    current_justification=""
    current_approved=""

    save_waiver() {
        if [[ -n "$current_wav" && -n "$current_artifact" ]]; then
            waiver_wav_id["$current_artifact"]="$current_wav"
            waiver_type["$current_artifact"]="${current_type:-Unknown}"
            waiver_justification["$current_artifact"]="${current_justification:-}"
            waiver_approved_by["$current_artifact"]="${current_approved:-}"
            waiver_artifact_ids+=("$current_artifact")
        fi
    }

    while IFS= read -r line; do
        if [[ "$line" =~ ^###[[:space:]]+(WAV-[0-9]{3}) ]]; then
            save_waiver
            current_wav="${BASH_REMATCH[1]}"
            current_artifact=""
            current_type=""
            current_justification=""
            current_approved=""
        elif [[ "$line" =~ ^\*\*Artifact\*\*:[[:space:]]*(.*) ]]; then
            current_artifact="${BASH_REMATCH[1]}"
            current_artifact="${current_artifact%$'\r'}"
            current_artifact="${current_artifact#"${current_artifact%%[![:space:]]*}"}"
            current_artifact="${current_artifact%"${current_artifact##*[![:space:]]}"}"
        elif [[ "$line" =~ ^\*\*Type\*\*:[[:space:]]*(.*) ]]; then
            current_type="${BASH_REMATCH[1]}"
            current_type="${current_type%$'\r'}"
        elif [[ "$line" =~ ^\*\*Justification\*\*:[[:space:]]*(.*) ]]; then
            current_justification="${BASH_REMATCH[1]}"
            current_justification="${current_justification%$'\r'}"
        elif [[ "$line" =~ ^\*\*Approved\ By\*\*:[[:space:]]*(.*) ]]; then
            current_approved="${BASH_REMATCH[1]}"
            current_approved="${current_approved%$'\r'}"
        fi
    done < "$WAIVER_PATH"
    save_waiver
fi

# ============================================================
# MOD-008: Cross-Reference Anomalies with Waivers
# ============================================================
blocking_count=0
waived_count=0
anomaly_count=0
declare -A used_waiver_ids

if [[ -f "$WORK_DIR/anomalies.tsv" ]]; then
    while IFS=$'\t' read -r artifact_id anom_type matrix_id; do
        ((anomaly_count++)) || true
        if [[ -n "${waiver_wav_id[$artifact_id]+x}" ]]; then
            wav="${waiver_wav_id[$artifact_id]}"
            printf '%s\t%s\t%s\t%s\t%s\n' "$artifact_id" "$anom_type" "$matrix_id" "Waived" "$wav" >> "$WORK_DIR/classified.tsv"
            used_waiver_ids["$wav"]=1
            ((waived_count++)) || true
        else
            printf '%s\t%s\t%s\t%s\t%s\n' "$artifact_id" "$anom_type" "$matrix_id" "BLOCKING" "—" >> "$WORK_DIR/classified.tsv"
            ((blocking_count++)) || true
        fi
    done < "$WORK_DIR/anomalies.tsv"
fi

# Find orphaned waivers
orphaned_count=0
for artifact_id in "${waiver_artifact_ids[@]}"; do
    wav="${waiver_wav_id[$artifact_id]}"
    if [[ -z "${used_waiver_ids[$wav]+x}" ]]; then
        printf '%s\t%s\n' "$wav" "$artifact_id" >> "$WORK_DIR/orphaned.tsv"
        ((orphaned_count++)) || true
    fi
done

# Compute compliance status
if [[ $blocking_count -gt 0 ]]; then
    COMPLIANCE_STATUS="❌ NOT READY — Unwaived anomalies detected"
    EXIT_CODE=1
elif [[ $anomaly_count -gt 0 ]]; then
    COMPLIANCE_STATUS="✅ RELEASE CANDIDATE — All anomalies waived"
    EXIT_CODE=0
else
    COMPLIANCE_STATUS="✅ RELEASE READY — No anomalies"
    EXIT_CODE=0
fi

# ============================================================
# MOD-010: Render JSON (if --json)
# ============================================================
if $JSON_MODE; then
    # Build JSON using python3 for proper formatting
    json_artifacts="["
    first=true
    while IFS=$'\t' read -r name file sha gdate status; do
        $first || json_artifacts+=","
        first=false
        json_artifacts+="{\"name\":\"$(json_escape "$name")\",\"file\":\"$(json_escape "$file")\",\"sha\":\"$(json_escape "$sha")\",\"date\":\"$(json_escape "$gdate")\",\"status\":\"$(json_escape "$status")\"}"
    done < "$WORK_DIR/artifacts.tsv"
    json_artifacts+="]"

    json_coverage="["
    first=true
    if [[ -f "$WORK_DIR/coverage.tsv" ]]; then
        while IFS=$'\t' read -r mid mtitle fwd bwd gaps orphans; do
            $first || json_coverage+=","
            first=false
            json_coverage+="{\"matrix\":\"$(json_escape "$mid")\",\"title\":\"$(json_escape "$mtitle")\",\"forward_coverage\":\"$(json_escape "$fwd")\",\"backward_coverage\":\"$(json_escape "$bwd")\",\"gaps\":$gaps,\"orphans\":$orphans}"
        done < "$WORK_DIR/coverage.tsv"
    fi
    json_coverage+="]"

    json_classified="["
    first=true
    if [[ -f "$WORK_DIR/classified.tsv" ]]; then
        while IFS=$'\t' read -r aid atype mid disp wav; do
            $first || json_classified+=","
            first=false
            json_classified+="{\"artifact_id\":\"$(json_escape "$aid")\",\"type\":\"$(json_escape "$atype")\",\"matrix\":\"$(json_escape "$mid")\",\"disposition\":\"$(json_escape "$disp")\",\"waiver\":\"$(json_escape "$wav")\"}"
        done < "$WORK_DIR/classified.tsv"
    fi
    json_classified+="]"

    json_orphaned="["
    first=true
    if [[ -f "$WORK_DIR/orphaned.tsv" ]]; then
        while IFS=$'\t' read -r wav aid; do
            $first || json_orphaned+=","
            first=false
            json_orphaned+="{\"waiver_id\":\"$(json_escape "$wav")\",\"artifact_id\":\"$(json_escape "$aid")\"}"
        done < "$WORK_DIR/orphaned.tsv"
    fi
    json_orphaned+="]"

    json_hazards="["
    first=true
    if [[ -f "$WORK_DIR/hazards_raw.tsv" ]]; then
        while IFS= read -r line; do
            parse_columns "$line"
            haz_id=$(strip_bold "${COLUMNS[0]}")
            $first || json_hazards+=","
            first=false
            json_hazards+="{\"id\":\"$(json_escape "$haz_id")\"}"
        done < "$WORK_DIR/hazards_raw.tsv"
    fi
    json_hazards+="]"

    cat << ENDJSON
{
  "metadata": {
    "system_name": "$(json_escape "$SYSTEM_NAME")",
    "version": "$(json_escape "$VERSION")",
    "git_tag": "$(json_escape "$GIT_TAG")",
    "git_sha": "$(json_escape "$GIT_SHA")",
    "date": "$(json_escape "$GENERATION_DATE")",
    "regulatory_context": "$(json_escape "$REGULATORY_CONTEXT")"
  },
  "compliance_status": "$(json_escape "$COMPLIANCE_STATUS")",
  "exit_code": $EXIT_CODE,
  "artifact_inventory": $json_artifacts,
  "coverage_analysis": $json_coverage,
  "hazard_summary": $json_hazards,
  "anomalies": {
    "classified": $json_classified,
    "orphaned_waivers": $json_orphaned
  },
  "summary": {
    "total_requirements": $total_reqs,
    "total_tests": $total_tests,
    "passed": $total_passed,
    "failed": $total_failed,
    "skipped": $total_skipped,
    "untested": $total_untested,
    "total_hazards": $total_hazards,
    "anomaly_count": $anomaly_count,
    "waived": $waived_count,
    "blocking": $blocking_count,
    "orphaned_waivers": $orphaned_count
  }
}
ENDJSON

    # Print summary to stderr
    echo "=== Audit Report Summary ===" >&2
    echo "Artifacts: $artifact_found/${#EXPECTED_FILES[@]}" >&2
    echo "Matrices: $matrix_count" >&2
    echo "Tests: $total_tests (✅ $total_passed | ❌ $total_failed | ⏭️ $total_skipped | ⬜ $total_untested)" >&2
    echo "Hazards: $total_hazards" >&2
    echo "Anomalies: $anomaly_count (waived: $waived_count, blocking: $blocking_count)" >&2
    [[ $orphaned_count -gt 0 ]] && echo "Orphaned waivers: $orphaned_count" >&2
    echo "Status: $COMPLIANCE_STATUS" >&2
    exit "$EXIT_CODE"
fi

# ============================================================
# MOD-009: Render Markdown Report
# ============================================================
{
    # Section 1: Executive Summary
    cat << EOF
# Release Audit Report

## 1. Executive Summary

**System**: $SYSTEM_NAME
**Version**: $VERSION
**Git Tag**: $GIT_TAG (commit $GIT_SHA)
**Date**: $GENERATION_DATE
**Regulatory Context**: $REGULATORY_CONTEXT

$total_reqs requirements traced across $matrix_count traceability matrices.
$total_tests test scenarios: $total_passed passed, $total_failed failed, $total_skipped skipped, $total_untested untested.
$total_hazards hazards identified; $total_mitigated mitigated.
$anomaly_count anomalies detected: $waived_count waived, $blocking_count blocking.

**Compliance Status**: $COMPLIANCE_STATUS

## 2. Artifact Inventory

| Artifact | File | Git SHA | Last Modified | Status |
|----------|------|---------|---------------|--------|
EOF

    # Artifact rows
    while IFS=$'\t' read -r name file sha gdate status; do
        echo "| $name | $file | $sha | $gdate | $status |"
    done < "$WORK_DIR/artifacts.tsv"

    echo ""
    echo "## 3. Traceability Matrices"
    echo ""

    # Embed raw matrix sections
    if [[ -f "$WORK_DIR/matrices_raw.md" ]]; then
        cat "$WORK_DIR/matrices_raw.md"
    else
        echo "No traceability matrices found."
    fi

    echo ""
    echo "## 4. Coverage Analysis"
    echo ""
    echo "| Matrix | Forward Coverage | Backward Coverage | Gaps | Orphans |"
    echo "|--------|-----------------|-------------------|------|---------|"

    if [[ -f "$WORK_DIR/coverage.tsv" ]]; then
        while IFS=$'\t' read -r mid mtitle fwd bwd gaps orphans; do
            echo "| $mid | $fwd | $bwd | $gaps | $orphans |"
        done < "$WORK_DIR/coverage.tsv"
    fi

    echo ""
    echo "## 5. Hazard Management Summary"
    echo ""

    if [[ $total_hazards -gt 0 && -f "$WORK_DIR/hazards_raw.tsv" ]]; then
        echo "| HAZ | Details |"
        echo "|-----|---------|"
        while IFS= read -r line; do
            parse_columns "$line"
            haz_id=$(strip_bold "${COLUMNS[0]}")
            # Join remaining columns as detail
            detail=""
            for ci in $(seq 1 $((${#COLUMNS[@]} - 1))); do
                detail="${detail}${detail:+ | }${COLUMNS[$ci]}"
            done
            echo "| $haz_id | $detail |"
        done < "$WORK_DIR/hazards_raw.tsv"
        echo ""
        echo "All $total_hazards hazards mitigated."
    else
        echo "No hazard analysis was performed."
    fi

    echo ""
    echo "## 6. Known Anomalies"
    echo ""

    if [[ -f "$WORK_DIR/classified.tsv" ]]; then
        echo "| ID | Type | Matrix | Disposition | Waiver |"
        echo "|----|------|--------|-------------|--------|"
        while IFS=$'\t' read -r aid atype mid disp wav; do
            echo "| $aid | $atype | $mid | $disp | $wav |"
        done < "$WORK_DIR/classified.tsv"
    else
        echo "No anomalies detected."
    fi

    if [[ -f "$WORK_DIR/orphaned.tsv" ]]; then
        echo ""
        echo "### Orphaned Waivers"
        echo ""
        echo "The following waivers reference artifact IDs that are not anomalies:"
        echo ""
        echo "| Waiver | Artifact ID |"
        echo "|--------|-------------|"
        while IFS=$'\t' read -r wav aid; do
            echo "| $wav | $aid |"
        done < "$WORK_DIR/orphaned.tsv"
    fi

    echo ""
    echo "## 7. Signature Block"
    echo ""
    echo "| Role | Name | Signature | Date |"
    echo "|------|------|-----------|------|"
    echo "| QA Manager | _________________ | _________________ | __________ |"
    echo "| Lead Engineer | _________________ | _________________ | __________ |"
    echo "| Release Tag | $GIT_TAG | Git SHA: $GIT_SHA | $GENERATION_DATE |"

} > "$OUTPUT_PATH"

# Print summary to stderr
echo "=== Audit Report Summary ===" >&2
echo "Artifacts: $artifact_found/${#EXPECTED_FILES[@]}" >&2
echo "Matrices: $matrix_count" >&2
echo "Tests: $total_tests (✅ $total_passed | ❌ $total_failed | ⏭️ $total_skipped | ⬜ $total_untested)" >&2
echo "Hazards: $total_hazards" >&2
echo "Anomalies: $anomaly_count (waived: $waived_count, blocking: $blocking_count)" >&2
[[ $orphaned_count -gt 0 ]] && echo "Orphaned waivers: $orphaned_count" >&2
echo "Status: $COMPLIANCE_STATUS" >&2
echo "Report written to: $OUTPUT_PATH" >&2
exit "$EXIT_CODE"
