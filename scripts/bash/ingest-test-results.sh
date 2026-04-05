#!/usr/bin/env bash

# Ingest JUnit XML test results (and optional Cobertura XML code coverage)
# into an existing traceability-matrix.md file.
#
# Calls parse_test_results.py to parse XML → JSON, then updates the matrix
# in-place: replaces Status column, adds Date + Commit columns, and
# optionally adds a Coverage column to Matrix D.
#
# Usage: ./ingest-test-results.sh --input <junit.xml> [OPTIONS] [vmodel-dir]
#
# OPTIONS:
#   --input <path>         Path to JUnit XML file (required)
#   --coverage <path>      Path to Cobertura XML coverage file
#   --matrix <path>        Path to traceability-matrix.md (default: auto-detect)
#   --coverage-map <path>  Path to coverage-map.yml override
#   --commit-sha <sha>     Explicit commit SHA (default: git rev-parse --short=7 HEAD)
#   --json                 Output JSON to stdout instead of human-readable summary
#   --help                 Show usage information
#
# EXIT CODES:
#   0 = all matched tests passed
#   1 = at least one failure detected
#   2 = no V-Model scenario IDs matched

set -e

# ---- Locate scripts directory ----
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PYTHON_HELPER="$REPO_ROOT/scripts/python/parse_test_results.py"

# ---- CLI parsing ----
INPUT_FILE=""
COVERAGE_FILE=""
MATRIX_FILE=""
COVERAGE_MAP=""
COMMIT_SHA=""
JSON_MODE=false
VMODEL_DIR=""

show_help() {
    cat << 'EOF'
Usage: ingest-test-results.sh --input <junit.xml> [OPTIONS] [vmodel-dir]

Ingest JUnit XML test results into the traceability matrix.

REQUIRED:
  --input <path>         Path to JUnit XML file

OPTIONS:
  --coverage <path>      Path to Cobertura XML coverage file
  --matrix <path>        Path to traceability-matrix.md
  --coverage-map <path>  Path to coverage-map.yml override
  --commit-sha <sha>     Explicit commit SHA (default: auto-detect from HEAD)
  --json                 Output JSON to stdout
  --help                 Show this help message

POSITIONAL:
  [vmodel-dir]           V-Model directory (default: auto-detect via setup-v-model.sh)

EXIT CODES:
  0 = all matched tests passed
  1 = at least one failure detected
  2 = no V-Model scenario IDs matched
EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --input)
            INPUT_FILE="$2"
            shift 2
            ;;
        --coverage)
            COVERAGE_FILE="$2"
            shift 2
            ;;
        --matrix)
            MATRIX_FILE="$2"
            shift 2
            ;;
        --coverage-map)
            COVERAGE_MAP="$2"
            shift 2
            ;;
        --commit-sha)
            COMMIT_SHA="$2"
            shift 2
            ;;
        --json)
            JSON_MODE=true
            shift
            ;;
        --help|-h)
            show_help
            ;;
        -*)
            echo "ERROR: Unknown option: $1" >&2
            exit 1
            ;;
        *)
            VMODEL_DIR="$1"
            shift
            ;;
    esac
done

# ---- Validate required arguments ----
if [[ -z "$INPUT_FILE" ]]; then
    echo "ERROR: --input argument is required" >&2
    echo "Usage: ingest-test-results.sh --input <junit.xml> [OPTIONS] [vmodel-dir]" >&2
    exit 1
fi

if [[ ! -f "$INPUT_FILE" ]]; then
    echo "ERROR: JUnit XML file not found: $INPUT_FILE" >&2
    exit 1
fi

if [[ -n "$COVERAGE_FILE" && ! -f "$COVERAGE_FILE" ]]; then
    echo "ERROR: Cobertura XML file not found: $COVERAGE_FILE" >&2
    exit 1
fi

if [[ -n "$COVERAGE_MAP" && ! -f "$COVERAGE_MAP" ]]; then
    echo "ERROR: Coverage map file not found: $COVERAGE_MAP" >&2
    exit 1
fi

# ---- Resolve matrix path ----
if [[ -z "$MATRIX_FILE" ]]; then
    if [[ -n "$VMODEL_DIR" ]]; then
        MATRIX_FILE="$VMODEL_DIR/traceability-matrix.md"
    else
        # Auto-detect via setup-v-model.sh
        SETUP_JSON=$("$REPO_ROOT/scripts/bash/setup-v-model.sh" --json 2>/dev/null) || {
            echo "ERROR: Could not auto-detect V-Model directory. Use --matrix or provide vmodel-dir." >&2
            exit 1
        }
        VMODEL_DIR=$(echo "$SETUP_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['VMODEL_DIR'])")
        MATRIX_FILE="$VMODEL_DIR/traceability-matrix.md"
    fi
fi

if [[ ! -f "$MATRIX_FILE" ]]; then
    echo "ERROR: Traceability matrix not found: $MATRIX_FILE" >&2
    exit 1
fi

# ---- Resolve module-design.md path ----
MODULE_DESIGN=""
if [[ -n "$COVERAGE_FILE" ]]; then
    if [[ -n "$VMODEL_DIR" && -f "$VMODEL_DIR/module-design.md" ]]; then
        MODULE_DESIGN="$VMODEL_DIR/module-design.md"
    else
        # Try to find it relative to the matrix file
        local_dir="$(dirname "$MATRIX_FILE")"
        if [[ -f "$local_dir/module-design.md" ]]; then
            MODULE_DESIGN="$local_dir/module-design.md"
        fi
    fi
fi

# ---- Resolve commit SHA ----
if [[ -z "$COMMIT_SHA" ]]; then
    COMMIT_SHA=$(git rev-parse --short=7 HEAD 2>/dev/null || echo "unknown")
fi

# ---- Resolve date ----
INGEST_DATE=$(date -u +%Y-%m-%d)

# ---- Read coverage threshold from extension.yml ----
COVERAGE_THRESHOLD=100
if [[ -f "$REPO_ROOT/extension.yml" ]]; then
    threshold_line=$(grep 'coverage_threshold:' "$REPO_ROOT/extension.yml" || true)
    if [[ -n "$threshold_line" ]]; then
        COVERAGE_THRESHOLD=$(echo "$threshold_line" | grep -oE '[0-9]+' | head -1)
    fi
fi

# ---- Call Python helper ----
PYTHON_ARGS=("--junit" "$INPUT_FILE")
if [[ -n "$COVERAGE_FILE" ]]; then
    PYTHON_ARGS+=("--cobertura" "$COVERAGE_FILE")
fi
if [[ -n "$COVERAGE_MAP" ]]; then
    PYTHON_ARGS+=("--coverage-map" "$COVERAGE_MAP")
fi
if [[ -n "$MODULE_DESIGN" ]]; then
    PYTHON_ARGS+=("--module-design" "$MODULE_DESIGN")
fi
PYTHON_ARGS+=("--coverage-threshold" "$COVERAGE_THRESHOLD")

PYTHON_OUTPUT=$(python3 "$PYTHON_HELPER" "${PYTHON_ARGS[@]}" 2>/dev/null) || true
PYTHON_EXIT=$?

# Check for error in output
if echo "$PYTHON_OUTPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); sys.exit(0 if 'error' not in d else 1)" 2>/dev/null; then
    : # no error
else
    error_msg=$(echo "$PYTHON_OUTPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('error','Unknown error'))" 2>/dev/null || echo "Failed to parse Python helper output")
    echo "ERROR: $error_msg" >&2
    exit 1
fi

# ---- Parse Python JSON output ----
# Extract test results and update matrix in-place using Python for JSON parsing
# and awk for the actual matrix line replacement

# Generate the update script from JSON output
UPDATE_SCRIPT=$(echo "$PYTHON_OUTPUT" | python3 -c "
import sys, json

data = json.load(sys.stdin)
results = data.get('test_results', [])
coverage = data.get('coverage', {})

# Build ID→status mapping
for r in results:
    vid = r['id']
    status = r['status']
    matrix = r['matrix']
    # Map status strings to emoji
    if status == 'passed':
        emoji = '✅ Passed'
    elif status == 'failed':
        emoji = '❌ Failed'
    elif status == 'skipped':
        emoji = '⏭️ Skipped'
    else:
        emoji = '⬜ Untested'
    print(f'{vid}\t{emoji}\t{matrix}')
")

# Build ID→coverage mapping for Matrix D
COVERAGE_SCRIPT=""
if [[ -n "$COVERAGE_FILE" ]]; then
    COVERAGE_SCRIPT=$(echo "$PYTHON_OUTPUT" | python3 -c "
import sys, json

data = json.load(sys.stdin)
coverage = data.get('coverage', {})

for mod_id, cov in coverage.items():
    formatted = cov['formatted']
    below = '1' if cov['below_threshold'] else '0'
    print(f'{mod_id}\t{formatted}\t{below}')
" 2>/dev/null || true)
fi

# ---- Update matrix in-place ----
# Strategy: For each matched ID, find its row in the matrix and update the status.
# Then handle Date/Commit/Coverage column addition.

TEMP_MATRIX=$(mktemp)
trap 'rm -f "$TEMP_MATRIX"' EXIT

# Read all matched IDs into arrays
declare -A ID_STATUS
declare -A ID_MATRIX
while IFS=$'\t' read -r vid emoji matrix; do
    [[ -z "$vid" ]] && continue
    ID_STATUS["$vid"]="$emoji"
    ID_MATRIX["$vid"]="$matrix"
done <<< "$UPDATE_SCRIPT"

# Read coverage data
declare -A MOD_COVERAGE
declare -A MOD_BELOW
while IFS=$'\t' read -r mod_id formatted below; do
    [[ -z "$mod_id" ]] && continue
    MOD_COVERAGE["$mod_id"]="$formatted"
    MOD_BELOW["$mod_id"]="$below"
done <<< "$COVERAGE_SCRIPT"

# Process the matrix file
HAS_COVERAGE=$([[ -n "$COVERAGE_FILE" ]] && echo "true" || echo "false")
current_matrix=""
in_table=false
header_processed=false
separator_processed=false

while IFS= read -r line; do
    # Detect which matrix we're in
    if [[ "$line" =~ ^##[[:space:]]+Matrix[[:space:]]+([A-Z]) ]]; then
        current_matrix="${BASH_REMATCH[1]}"
        in_table=false
        header_processed=false
        separator_processed=false
        echo "$line" >> "$TEMP_MATRIX"
        continue
    fi

    # Detect table header row (starts with |)
    if [[ "$in_table" == false && "$line" =~ ^\| && "$header_processed" == false ]]; then
        in_table=true
        header_processed=true
        # Strip trailing whitespace and pipe
        trimmed=$(echo "$line" | sed 's/[[:space:]]*|[[:space:]]*$//')
        if [[ "$current_matrix" == "D" && "$HAS_COVERAGE" == "true" ]]; then
            echo "$trimmed | Date | Commit | Coverage |" >> "$TEMP_MATRIX"
        else
            echo "$trimmed | Date | Commit |" >> "$TEMP_MATRIX"
        fi
        continue
    fi

    # Detect separator row (|---|---|...)
    if [[ "$in_table" == true && "$separator_processed" == false && "$line" =~ ^\|[[:space:]]*-+ ]]; then
        separator_processed=true
        # Strip trailing whitespace and pipe
        trimmed=$(echo "$line" | sed 's/[[:space:]]*|[[:space:]]*$//')
        if [[ "$current_matrix" == "D" && "$HAS_COVERAGE" == "true" ]]; then
            echo "$trimmed | --- | --- | --- |" >> "$TEMP_MATRIX"
        else
            echo "$trimmed | --- | --- |" >> "$TEMP_MATRIX"
        fi
        continue
    fi

    # Process data rows
    if [[ "$in_table" == true && "$line" =~ ^\| ]]; then
        # Check if this row contains a matched scenario ID
        matched_id=""
        matched_status=""
        for vid in "${!ID_STATUS[@]}"; do
            if echo "$line" | grep -qF "$vid"; then
                matched_id="$vid"
                matched_status="${ID_STATUS[$vid]}"
                break
            fi
        done

        if [[ -n "$matched_id" ]]; then
            # Replace status in the row
            # The Status column contains: ⬜ Untested, ✅ Passed, ❌ Failed, or ⏭️ Skipped
            updated_line=$(echo "$line" | sed \
                -e 's/⬜ Untested/'"$matched_status"'/g' \
                -e 's/✅ Passed/'"$matched_status"'/g' \
                -e 's/❌ Failed/'"$matched_status"'/g' \
                -e 's/⏭️ Skipped/'"$matched_status"'/g')

            # Determine coverage value for Matrix D
            coverage_val=""
            if [[ "$current_matrix" == "D" && "$HAS_COVERAGE" == "true" ]]; then
                # Find the MOD-NNN for this row by scanning the line
                mod_id=$(echo "$line" | grep -oE 'MOD-[0-9]{3}' | head -1 || true)
                if [[ -n "$mod_id" && -n "${MOD_COVERAGE[$mod_id]+x}" ]]; then
                    coverage_val="${MOD_COVERAGE[$mod_id]}"
                    if [[ "${MOD_BELOW[$mod_id]}" == "1" ]]; then
                        coverage_val="⚠ $coverage_val"
                    fi
                else
                    coverage_val="—"
                fi
            fi

            # Strip trailing pipe and whitespace, add new columns
            base_line=$(echo "$updated_line" | sed 's/[[:space:]]*|[[:space:]]*$//')
            if [[ "$current_matrix" == "D" && "$HAS_COVERAGE" == "true" ]]; then
                echo "$base_line | $INGEST_DATE | $COMMIT_SHA | $coverage_val |" >> "$TEMP_MATRIX"
            else
                echo "$base_line | $INGEST_DATE | $COMMIT_SHA |" >> "$TEMP_MATRIX"
            fi
        else
            # No match — preserve row but add empty Date/Commit/Coverage columns
            base_line=$(echo "$line" | sed 's/[[:space:]]*|[[:space:]]*$//')
            if [[ "$current_matrix" == "D" && "$HAS_COVERAGE" == "true" ]]; then
                echo "$base_line | | | |" >> "$TEMP_MATRIX"
            else
                echo "$base_line | | |" >> "$TEMP_MATRIX"
            fi
        fi
        continue
    fi

    # Non-table lines or blank lines reset table state
    if [[ "$in_table" == true && ! "$line" =~ ^\| ]]; then
        in_table=false
    fi

    echo "$line" >> "$TEMP_MATRIX"
done < "$MATRIX_FILE"

# Replace original matrix
cp "$TEMP_MATRIX" "$MATRIX_FILE"

# ---- Output ----
if $JSON_MODE; then
    # Add matrix_path, date, commit to the Python output
    echo "$PYTHON_OUTPUT" | python3 -c "
import sys, json

data = json.load(sys.stdin)
data['matrix_path'] = '$MATRIX_FILE'
data['date'] = '$INGEST_DATE'
data['commit'] = '$COMMIT_SHA'
print(json.dumps(data, indent=2))
"
else
    # Human-readable summary
    echo ""
    echo "=== Test Results Ingestion ==="
    echo ""

    echo "$PYTHON_OUTPUT" | python3 -c "
import sys, json

data = json.load(sys.stdin)
summary = data['summary']
pm = summary['per_matrix']

matrix_names = {'A': 'Acceptance', 'B': 'System', 'C': 'Integration', 'D': 'Unit'}
for label in ('A', 'B', 'C', 'D'):
    m = pm[label]
    if m['total'] > 0:
        print(f\"Matrix {label} ({matrix_names[label]}): {m['total']} matched | {m['passed']} passed | {m['failed']} failed | {m['skipped']} skipped\")

print()
print(f\"Total: {summary['total']} matched | {summary['passed']} passed | {summary['failed']} failed | {summary['skipped']} skipped\")

if summary['unmatched_count'] > 0:
    print(f\"Unmatched JUnit tests: {summary['unmatched_count']}\")

coverage = data.get('coverage', {})
if coverage:
    print()
    print('Coverage (Matrix D):')
    for mod_id in sorted(coverage.keys()):
        c = coverage[mod_id]
        flag = ' ⚠ BELOW THRESHOLD' if c['below_threshold'] else ''
        print(f\"  {mod_id}: {c['formatted']}{flag}\")
"

    echo ""
    echo "Matrix updated: $MATRIX_FILE"
fi

# ---- Exit code ----
# Re-derive from the parsed data
FINAL_EXIT=$(echo "$PYTHON_OUTPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
s = data['summary']
if s['total'] == 0:
    print(2)
elif s['failed'] > 0:
    print(1)
else:
    print(0)
")

exit "$FINAL_EXIT"
