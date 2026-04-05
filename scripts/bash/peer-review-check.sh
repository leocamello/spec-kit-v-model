#!/usr/bin/env bash

# Deterministic CI gate for peer-review reports
#
# Parses a peer-review-{artifact}.md file and returns exit codes based on
# the severity of findings detected:
#
#   Exit 0 = clean (zero findings, or observations only)
#   Exit 1 = Critical or Major findings detected (blocks PR)
#   Exit 2 = Minor findings only, no Critical/Major (warning)
#
# Usage: ./peer-review-check.sh [OPTIONS] <review-file>
#
# OPTIONS:
#   --json      Output in JSON format (for AI consumption)
#
# EXIT CODES:
#   0 = clean (no findings or observations only)
#   1 = Critical or Major findings (blocks PR)
#   2 = Minor findings only (warning)

set -e

JSON_MODE=false
REVIEW_FILE=""

for arg in "$@"; do
    case "$arg" in
        --json) JSON_MODE=true ;;
        --help|-h)
            echo "Usage: peer-review-check.sh [--json] <review-file>"
            echo ""
            echo "Parse a peer-review report and return CI exit codes."
            echo ""
            echo "EXIT CODES:"
            echo "  0 = clean (no findings or observations only)"
            echo "  1 = Critical or Major findings (blocks PR)"
            echo "  2 = Minor findings only (warning)"
            exit 0
            ;;
        *) REVIEW_FILE="$arg" ;;
    esac
done

if [[ -z "$REVIEW_FILE" ]]; then
    echo "ERROR: review-file argument required" >&2
    echo "Usage: peer-review-check.sh [--json] <review-file>" >&2
    exit 1
fi

if [[ ! -f "$REVIEW_FILE" ]]; then
    echo "ERROR: file not found: $REVIEW_FILE" >&2
    exit 1
fi

# ---- Parse Summary Table ----

# Extract counts from the summary table: | Severity | Count |
critical=0
major=0
minor=0
observation=0

while IFS= read -r line; do
    # Match table rows: | Critical | 3 |
    if [[ "$line" =~ ^\|[[:space:]]*Critical[[:space:]]*\|[[:space:]]*([0-9]+)[[:space:]]*\| ]]; then
        critical=${BASH_REMATCH[1]}
    elif [[ "$line" =~ ^\|[[:space:]]*Major[[:space:]]*\|[[:space:]]*([0-9]+)[[:space:]]*\| ]]; then
        major=${BASH_REMATCH[1]}
    elif [[ "$line" =~ ^\|[[:space:]]*Minor[[:space:]]*\|[[:space:]]*([0-9]+)[[:space:]]*\| ]]; then
        minor=${BASH_REMATCH[1]}
    elif [[ "$line" =~ ^\|[[:space:]]*Observation[[:space:]]*\|[[:space:]]*([0-9]+)[[:space:]]*\| ]]; then
        observation=${BASH_REMATCH[1]}
    fi
done < "$REVIEW_FILE"

total=$((critical + major + minor + observation))

# ---- Cross-Validate Against Actual Findings ----

# Count PRF-*-NNN headings as a sanity check
prf_count=$(grep -cE '^###[[:space:]]+PRF-[A-Z]+-[0-9]{3}' "$REVIEW_FILE" 2>/dev/null || true)

# Count severity occurrences in finding tables
prf_critical=$(grep -cE '^\|[[:space:]]*\*\*Severity\*\*[[:space:]]*\|[[:space:]]*Critical[[:space:]]*\|' "$REVIEW_FILE" 2>/dev/null || true)
prf_major=$(grep -cE '^\|[[:space:]]*\*\*Severity\*\*[[:space:]]*\|[[:space:]]*Major[[:space:]]*\|' "$REVIEW_FILE" 2>/dev/null || true)
prf_minor=$(grep -cE '^\|[[:space:]]*\*\*Severity\*\*[[:space:]]*\|[[:space:]]*Minor[[:space:]]*\|' "$REVIEW_FILE" 2>/dev/null || true)
prf_observation=$(grep -cE '^\|[[:space:]]*\*\*Severity\*\*[[:space:]]*\|[[:space:]]*Observation[[:space:]]*\|' "$REVIEW_FILE" 2>/dev/null || true)

prf_total=$((prf_critical + prf_major + prf_minor + prf_observation))

# Check for mismatch between summary and findings
summary_match=true
if [[ $total -ne $prf_count ]] || [[ $total -ne $prf_total ]]; then
    summary_match=false
fi

# ---- Extract Metadata ----

artifact=""
standard=""
item_count=""

while IFS= read -r line; do
    if [[ "$line" =~ ^\*\*Artifact\*\*:[[:space:]]*(.*) ]]; then
        artifact="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^\*\*Standard\*\*:[[:space:]]*(.*) ]]; then
        standard="${BASH_REMATCH[1]}"
    fi
done < "$REVIEW_FILE"

# ---- Determine Exit Code ----

if [[ $critical -gt 0 ]] || [[ $major -gt 0 ]]; then
    exit_code=1
elif [[ $minor -gt 0 ]]; then
    exit_code=2
else
    exit_code=0
fi

# ---- Output ----

if $JSON_MODE; then
    cat << EOF
{
  "review_file": "$REVIEW_FILE",
  "artifact": "$artifact",
  "standard": "$standard",
  "critical": $critical,
  "major": $major,
  "minor": $minor,
  "observation": $observation,
  "total": $total,
  "prf_headings": $prf_count,
  "prf_critical": $prf_critical,
  "prf_major": $prf_major,
  "prf_minor": $prf_minor,
  "prf_observation": $prf_observation,
  "summary_match": $summary_match,
  "exit_code": $exit_code
}
EOF
else
    echo "=== Peer Review Check ==="
    echo ""
    echo "File: $REVIEW_FILE"
    if [[ -n "$artifact" ]]; then
        echo "Artifact: $artifact"
    fi
    if [[ -n "$standard" ]]; then
        echo "Standard: $standard"
    fi
    echo ""

    echo "── Summary Table ──"
    echo "  Critical:    $critical"
    echo "  Major:       $major"
    echo "  Minor:       $minor"
    echo "  Observation: $observation"
    echo "  Total:       $total"
    echo ""

    echo "── Finding Validation ──"
    echo "  PRF headings found: $prf_count"
    echo "  Severity tags found: $prf_total"
    if $summary_match; then
        echo "  ✅ Summary table matches findings"
    else
        echo "  ⚠️  Summary table ($total) does not match findings ($prf_count headings, $prf_total severity tags)"
    fi
    echo ""

    echo "── CI Gate ──"
    if [[ $exit_code -eq 0 ]]; then
        echo "  ✅ PASS — no blocking findings"
    elif [[ $exit_code -eq 1 ]]; then
        echo "  ❌ FAIL — $critical Critical + $major Major findings (blocks PR)"
    elif [[ $exit_code -eq 2 ]]; then
        echo "  ⚠️  WARNING — $minor Minor findings only (non-blocking)"
    fi
fi

exit $exit_code
