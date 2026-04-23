load "test_helper"

INGEST_SCRIPT="$SCRIPTS_DIR/ingest-test-results.sh"
TR_FIXTURES="$FIXTURES_DIR/commands/test-results"
PYTHON_HELPER="$PROJECT_ROOT/scripts/python/parse_test_results.py"

# ============================================================
# Setup / Teardown
# ============================================================

setup() {
    setup_temp_dir
    # Copy matrix fixture for tests that need it
    cp "$TR_FIXTURES/inputs/matrix/traceability-matrix.md" "$TEST_TEMP_DIR/matrix.md"
}

teardown() {
    teardown_temp_dir
}

# ============================================================
# Python helper — golden JSON output validation
# ============================================================

@test "python-helper: all-pass matches golden JSON" {
    run python3 "$PYTHON_HELPER" --junit "$TR_FIXTURES/inputs/junit/all-pass.xml"
    assert_success
    local expected
    expected=$(cat "$TR_FIXTURES/expected/all-pass.json")
    [ "$output" = "$expected" ]
}

@test "python-helper: mixed-results matches golden JSON" {
    run python3 "$PYTHON_HELPER" --junit "$TR_FIXTURES/inputs/junit/mixed-results.xml"
    assert_failure 1
    local expected
    expected=$(cat "$TR_FIXTURES/expected/mixed-results.json")
    [ "$output" = "$expected" ]
}

@test "python-helper: all-fail matches golden JSON" {
    run python3 "$PYTHON_HELPER" --junit "$TR_FIXTURES/inputs/junit/all-fail.xml"
    assert_failure 1
    local expected
    expected=$(cat "$TR_FIXTURES/expected/all-fail.json")
    [ "$output" = "$expected" ]
}

@test "python-helper: all-skipped matches golden JSON" {
    run python3 "$PYTHON_HELPER" --junit "$TR_FIXTURES/inputs/junit/all-skipped.xml"
    assert_success
    local expected
    expected=$(cat "$TR_FIXTURES/expected/all-skipped.json")
    [ "$output" = "$expected" ]
}

@test "python-helper: no-matches exits 2" {
    run python3 "$PYTHON_HELPER" --junit "$TR_FIXTURES/inputs/junit/no-matches.xml"
    assert_failure 2
}

@test "python-helper: no-matches matches golden JSON" {
    run python3 "$PYTHON_HELPER" --junit "$TR_FIXTURES/inputs/junit/no-matches.xml"
    local expected
    expected=$(cat "$TR_FIXTURES/expected/no-matches.json")
    [ "$output" = "$expected" ]
}

@test "python-helper: with-retries matches golden JSON" {
    run python3 "$PYTHON_HELPER" --junit "$TR_FIXTURES/inputs/junit/with-retries.xml"
    assert_success
    local expected
    expected=$(cat "$TR_FIXTURES/expected/with-retries.json")
    [ "$output" = "$expected" ]
}

@test "python-helper: multi-suite matches golden JSON" {
    run python3 "$PYTHON_HELPER" --junit "$TR_FIXTURES/inputs/junit/multi-suite.xml"
    assert_success
    local expected
    expected=$(cat "$TR_FIXTURES/expected/multi-suite.json")
    [ "$output" = "$expected" ]
}

@test "python-helper: extra-ids matches golden JSON" {
    run python3 "$PYTHON_HELPER" --junit "$TR_FIXTURES/inputs/junit/extra-ids.xml"
    assert_success
    local expected
    expected=$(cat "$TR_FIXTURES/expected/extra-ids.json")
    [ "$output" = "$expected" ]
}

@test "python-helper: full-coverage matches golden JSON" {
    run python3 "$PYTHON_HELPER" --junit "$TR_FIXTURES/inputs/junit/all-pass.xml" \
        --cobertura "$TR_FIXTURES/inputs/cobertura/full-coverage.xml" \
        --coverage-map "$TR_FIXTURES/inputs/matrix/coverage-map.yml" \
        --coverage-threshold 100
    assert_success
    local expected
    expected=$(cat "$TR_FIXTURES/expected/with-full-coverage.json")
    [ "$output" = "$expected" ]
}

@test "python-helper: partial-coverage matches golden JSON" {
    run python3 "$PYTHON_HELPER" --junit "$TR_FIXTURES/inputs/junit/all-pass.xml" \
        --cobertura "$TR_FIXTURES/inputs/cobertura/partial-coverage.xml" \
        --coverage-map "$TR_FIXTURES/inputs/matrix/coverage-map.yml" \
        --coverage-threshold 100
    assert_success
    local expected
    expected=$(cat "$TR_FIXTURES/expected/with-partial-coverage.json")
    [ "$output" = "$expected" ]
}

# ============================================================
# Python helper — exit codes
# ============================================================

@test "python-helper: exit 0 when all tests pass" {
    run python3 "$PYTHON_HELPER" --junit "$TR_FIXTURES/inputs/junit/all-pass.xml"
    assert_success
}

@test "python-helper: exit 1 when failures detected" {
    run python3 "$PYTHON_HELPER" --junit "$TR_FIXTURES/inputs/junit/all-fail.xml"
    assert_failure 1
}

@test "python-helper: exit 2 when no ID matches" {
    run python3 "$PYTHON_HELPER" --junit "$TR_FIXTURES/inputs/junit/no-matches.xml"
    assert_failure 2
}

@test "python-helper: exit 0 for all-skipped (no failures)" {
    run python3 "$PYTHON_HELPER" --junit "$TR_FIXTURES/inputs/junit/all-skipped.xml"
    assert_success
}

# ============================================================
# Python helper — ID matching
# ============================================================

@test "python-helper: matches SCN IDs to matrix A" {
    run python3 "$PYTHON_HELPER" --junit "$TR_FIXTURES/inputs/junit/all-pass.xml"
    assert_success
    local matrix
    matrix=$(echo "$output" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['test_results'][0]['matrix'])")
    [ "$matrix" = "A" ]
}

@test "python-helper: matches STS IDs to matrix B" {
    run python3 "$PYTHON_HELPER" --junit "$TR_FIXTURES/inputs/junit/all-pass.xml"
    assert_success
    local matrix
    matrix=$(echo "$output" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['test_results'][2]['matrix'])")
    [ "$matrix" = "B" ]
}

@test "python-helper: matches UTS IDs to matrix D" {
    run python3 "$PYTHON_HELPER" --junit "$TR_FIXTURES/inputs/junit/all-pass.xml"
    assert_success
    local matrix
    matrix=$(echo "$output" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['test_results'][3]['matrix'])")
    [ "$matrix" = "D" ]
}

@test "python-helper: matches ITS IDs to matrix C" {
    run python3 "$PYTHON_HELPER" --junit "$TR_FIXTURES/inputs/junit/multi-suite.xml"
    assert_success
    local matrix
    matrix=$(echo "$output" | python3 -c "import json,sys; d=json.load(sys.stdin); [print(r['matrix']) for r in d['test_results'] if r['id'].startswith('ITS')]" | head -1)
    [ "$matrix" = "C" ]
}

@test "python-helper: unmatched tests reported" {
    run python3 "$PYTHON_HELPER" --junit "$TR_FIXTURES/inputs/junit/mixed-results.xml"
    local count
    count=$(echo "$output" | python3 -c "import json,sys; print(json.load(sys.stdin)['summary']['unmatched_count'])")
    [ "$count" = "0" ]
}

@test "python-helper: no-matches has all tests unmatched" {
    run python3 "$PYTHON_HELPER" --junit "$TR_FIXTURES/inputs/junit/no-matches.xml"
    local count
    count=$(echo "$output" | python3 -c "import json,sys; print(json.load(sys.stdin)['summary']['unmatched_count'])")
    [ "$count" = "3" ]
}

# ============================================================
# Python helper — duplicate/retry handling
# ============================================================

@test "python-helper: retries use last occurrence (pass after fail)" {
    run python3 "$PYTHON_HELPER" --junit "$TR_FIXTURES/inputs/junit/with-retries.xml"
    assert_success
    local status
    status=$(echo "$output" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['test_results'][0]['status'])")
    [ "$status" = "passed" ]
}

@test "python-helper: retries deduplicate IDs" {
    run python3 "$PYTHON_HELPER" --junit "$TR_FIXTURES/inputs/junit/with-retries.xml"
    assert_success
    local total
    total=$(echo "$output" | python3 -c "import json,sys; print(json.load(sys.stdin)['summary']['total'])")
    [ "$total" = "2" ]
}

# ============================================================
# Python helper — summary counts
# ============================================================

@test "python-helper: all-pass summary total=4" {
    run python3 "$PYTHON_HELPER" --junit "$TR_FIXTURES/inputs/junit/all-pass.xml"
    assert_success
    local total
    total=$(echo "$output" | python3 -c "import json,sys; print(json.load(sys.stdin)['summary']['total'])")
    [ "$total" = "4" ]
}

@test "python-helper: mixed summary passed=3 failed=1 skipped=1" {
    run python3 "$PYTHON_HELPER" --junit "$TR_FIXTURES/inputs/junit/mixed-results.xml"
    local passed failed skipped
    passed=$(echo "$output" | python3 -c "import json,sys; print(json.load(sys.stdin)['summary']['passed'])")
    failed=$(echo "$output" | python3 -c "import json,sys; print(json.load(sys.stdin)['summary']['failed'])")
    skipped=$(echo "$output" | python3 -c "import json,sys; print(json.load(sys.stdin)['summary']['skipped'])")
    [ "$passed" = "3" ]
    [ "$failed" = "1" ]
    [ "$skipped" = "1" ]
}

@test "python-helper: per-matrix counts correct for multi-suite" {
    run python3 "$PYTHON_HELPER" --junit "$TR_FIXTURES/inputs/junit/multi-suite.xml"
    assert_success
    local a_total b_total c_total d_total
    a_total=$(echo "$output" | python3 -c "import json,sys; print(json.load(sys.stdin)['summary']['per_matrix']['A']['total'])")
    b_total=$(echo "$output" | python3 -c "import json,sys; print(json.load(sys.stdin)['summary']['per_matrix']['B']['total'])")
    c_total=$(echo "$output" | python3 -c "import json,sys; print(json.load(sys.stdin)['summary']['per_matrix']['C']['total'])")
    d_total=$(echo "$output" | python3 -c "import json,sys; print(json.load(sys.stdin)['summary']['per_matrix']['D']['total'])")
    [ "$a_total" = "2" ]
    [ "$b_total" = "1" ]
    [ "$c_total" = "1" ]
    [ "$d_total" = "2" ]
}

# ============================================================
# Python helper — coverage mapping
# ============================================================

@test "python-helper: full-coverage below_threshold=false" {
    run python3 "$PYTHON_HELPER" --junit "$TR_FIXTURES/inputs/junit/all-pass.xml" \
        --cobertura "$TR_FIXTURES/inputs/cobertura/full-coverage.xml" \
        --coverage-map "$TR_FIXTURES/inputs/matrix/coverage-map.yml" \
        --coverage-threshold 100
    assert_success
    local below
    below=$(echo "$output" | python3 -c "import json,sys; print(json.load(sys.stdin)['coverage']['MOD-001']['below_threshold'])")
    [ "$below" = "False" ]
}

@test "python-helper: partial-coverage below_threshold=true" {
    run python3 "$PYTHON_HELPER" --junit "$TR_FIXTURES/inputs/junit/all-pass.xml" \
        --cobertura "$TR_FIXTURES/inputs/cobertura/partial-coverage.xml" \
        --coverage-map "$TR_FIXTURES/inputs/matrix/coverage-map.yml" \
        --coverage-threshold 100
    assert_success
    local below
    below=$(echo "$output" | python3 -c "import json,sys; print(json.load(sys.stdin)['coverage']['MOD-001']['below_threshold'])")
    [ "$below" = "True" ]
}

@test "python-helper: partial-coverage MOD-001 stmt=95.0" {
    run python3 "$PYTHON_HELPER" --junit "$TR_FIXTURES/inputs/junit/all-pass.xml" \
        --cobertura "$TR_FIXTURES/inputs/cobertura/partial-coverage.xml" \
        --coverage-map "$TR_FIXTURES/inputs/matrix/coverage-map.yml" \
        --coverage-threshold 100
    assert_success
    local stmt
    stmt=$(echo "$output" | python3 -c "import json,sys; print(json.load(sys.stdin)['coverage']['MOD-001']['stmt'])")
    [ "$stmt" = "95.0" ]
}

@test "python-helper: coverage formatted string correct" {
    run python3 "$PYTHON_HELPER" --junit "$TR_FIXTURES/inputs/junit/all-pass.xml" \
        --cobertura "$TR_FIXTURES/inputs/cobertura/partial-coverage.xml" \
        --coverage-map "$TR_FIXTURES/inputs/matrix/coverage-map.yml" \
        --coverage-threshold 100
    assert_success
    local fmt
    fmt=$(echo "$output" | python3 -c "import json,sys; print(json.load(sys.stdin)['coverage']['MOD-001']['formatted'])")
    [ "$fmt" = "95.0% stmt / 88.0% branch" ]
}

@test "python-helper: convention-based mapping from module-design.md" {
    run python3 "$PYTHON_HELPER" --junit "$TR_FIXTURES/inputs/junit/all-pass.xml" \
        --cobertura "$TR_FIXTURES/inputs/cobertura/full-coverage.xml" \
        --module-design "$TR_FIXTURES/inputs/matrix/module-design.md" \
        --coverage-threshold 100
    assert_success
    local mod1
    mod1=$(echo "$output" | python3 -c "import json,sys; d=json.load(sys.stdin); print('MOD-001' in d['coverage'])")
    [ "$mod1" = "True" ]
}

# ============================================================
# Bash wrapper — help flag
# ============================================================

@test "ingest-test-results: --help exits 0" {
    run bash "$INGEST_SCRIPT" --help
    assert_success
}

@test "ingest-test-results: --help shows usage" {
    run bash "$INGEST_SCRIPT" --help
    assert_success
    assert_output --partial "Usage:"
    assert_output --partial "--input"
}

# ============================================================
# Bash wrapper — argument validation
# ============================================================

@test "ingest-test-results: missing --input exits 1" {
    run bash "$INGEST_SCRIPT"
    assert_failure 1
    assert_output --partial "ERROR"
}

@test "ingest-test-results: nonexistent JUnit file exits 1" {
    run bash "$INGEST_SCRIPT" --input /nonexistent/file.xml --matrix "$TEST_TEMP_DIR/matrix.md"
    assert_failure 1
    assert_output --partial "not found"
}

@test "ingest-test-results: nonexistent matrix file exits 1" {
    run bash "$INGEST_SCRIPT" --input "$TR_FIXTURES/inputs/junit/all-pass.xml" --matrix /nonexistent/matrix.md
    assert_failure 1
    assert_output --partial "not found"
}

@test "ingest-test-results: nonexistent coverage file exits 1" {
    run bash "$INGEST_SCRIPT" --input "$TR_FIXTURES/inputs/junit/all-pass.xml" --coverage /nonexistent/cov.xml --matrix "$TEST_TEMP_DIR/matrix.md"
    assert_failure 1
    assert_output --partial "not found"
}

# ============================================================
# Bash wrapper — exit codes
# ============================================================

@test "ingest-test-results: exit 0 when all pass" {
    run bash "$INGEST_SCRIPT" --input "$TR_FIXTURES/inputs/junit/all-pass.xml" \
        --matrix "$TEST_TEMP_DIR/matrix.md" --commit-sha abc1234
    assert_success
}

@test "ingest-test-results: exit 1 when failures detected" {
    run bash "$INGEST_SCRIPT" --input "$TR_FIXTURES/inputs/junit/all-fail.xml" \
        --matrix "$TEST_TEMP_DIR/matrix.md" --commit-sha abc1234
    assert_failure 1
}

@test "ingest-test-results: exit 2 when no matches" {
    run bash "$INGEST_SCRIPT" --input "$TR_FIXTURES/inputs/junit/no-matches.xml" \
        --matrix "$TEST_TEMP_DIR/matrix.md" --commit-sha abc1234
    assert_failure 2
}

# ============================================================
# Bash wrapper — matrix update
# ============================================================

@test "ingest-test-results: updates SCN-001-A1 to Passed" {
    run bash "$INGEST_SCRIPT" --input "$TR_FIXTURES/inputs/junit/all-pass.xml" \
        --matrix "$TEST_TEMP_DIR/matrix.md" --commit-sha abc1234
    assert_success
    grep "SCN-001-A1" "$TEST_TEMP_DIR/matrix.md" | grep -q "✅ Passed"
}

@test "ingest-test-results: updates SCN-001-A2 to Failed" {
    run bash "$INGEST_SCRIPT" --input "$TR_FIXTURES/inputs/junit/mixed-results.xml" \
        --matrix "$TEST_TEMP_DIR/matrix.md" --commit-sha abc1234
    grep "SCN-001-A2" "$TEST_TEMP_DIR/matrix.md" | grep -q "❌ Failed"
}

@test "ingest-test-results: updates UTS-001-A1 to Skipped" {
    run bash "$INGEST_SCRIPT" --input "$TR_FIXTURES/inputs/junit/mixed-results.xml" \
        --matrix "$TEST_TEMP_DIR/matrix.md" --commit-sha abc1234
    grep "UTS-001-A1" "$TEST_TEMP_DIR/matrix.md" | grep -q "⏭️ Skipped"
}

@test "ingest-test-results: preserves unmatched rows as Untested" {
    run bash "$INGEST_SCRIPT" --input "$TR_FIXTURES/inputs/junit/all-pass.xml" \
        --matrix "$TEST_TEMP_DIR/matrix.md" --commit-sha abc1234
    assert_success
    grep "SCN-002-A1" "$TEST_TEMP_DIR/matrix.md" | grep -q "⬜ Untested"
}

@test "ingest-test-results: adds Date column" {
    run bash "$INGEST_SCRIPT" --input "$TR_FIXTURES/inputs/junit/all-pass.xml" \
        --matrix "$TEST_TEMP_DIR/matrix.md" --commit-sha abc1234
    assert_success
    grep "SCN-001-A1" "$TEST_TEMP_DIR/matrix.md" | grep -qE '[0-9]{4}-[0-9]{2}-[0-9]{2}'
}

@test "ingest-test-results: adds Commit column with specified SHA" {
    run bash "$INGEST_SCRIPT" --input "$TR_FIXTURES/inputs/junit/all-pass.xml" \
        --matrix "$TEST_TEMP_DIR/matrix.md" --commit-sha abc1234
    assert_success
    grep "SCN-001-A1" "$TEST_TEMP_DIR/matrix.md" | grep -q "abc1234"
}

@test "ingest-test-results: adds Date header to table" {
    run bash "$INGEST_SCRIPT" --input "$TR_FIXTURES/inputs/junit/all-pass.xml" \
        --matrix "$TEST_TEMP_DIR/matrix.md" --commit-sha abc1234
    assert_success
    grep "| Date |" "$TEST_TEMP_DIR/matrix.md"
}

@test "ingest-test-results: adds Commit header to table" {
    run bash "$INGEST_SCRIPT" --input "$TR_FIXTURES/inputs/junit/all-pass.xml" \
        --matrix "$TEST_TEMP_DIR/matrix.md" --commit-sha abc1234
    assert_success
    grep "| Commit |" "$TEST_TEMP_DIR/matrix.md"
}

@test "ingest-test-results: preserves non-table content" {
    run bash "$INGEST_SCRIPT" --input "$TR_FIXTURES/inputs/junit/all-pass.xml" \
        --matrix "$TEST_TEMP_DIR/matrix.md" --commit-sha abc1234
    assert_success
    grep -q "Coverage Summary" "$TEST_TEMP_DIR/matrix.md"
}

# ============================================================
# Bash wrapper — re-run overwrites previous status
# ============================================================

@test "ingest-test-results: re-run overwrites Failed with Passed" {
    bash "$INGEST_SCRIPT" --input "$TR_FIXTURES/inputs/junit/all-fail.xml" \
        --matrix "$TEST_TEMP_DIR/matrix.md" --commit-sha run1111 || true
    grep "SCN-001-A1" "$TEST_TEMP_DIR/matrix.md" | grep -q "❌ Failed"
    bash "$INGEST_SCRIPT" --input "$TR_FIXTURES/inputs/junit/all-pass.xml" \
        --matrix "$TEST_TEMP_DIR/matrix.md" --commit-sha run2222 || true
    grep "SCN-001-A1" "$TEST_TEMP_DIR/matrix.md" | grep -q "✅ Passed"
    grep "SCN-001-A1" "$TEST_TEMP_DIR/matrix.md" | grep -q "run2222"
}

# ============================================================
# Bash wrapper — summary output
# ============================================================

@test "ingest-test-results: summary shows matrix counts" {
    run bash "$INGEST_SCRIPT" --input "$TR_FIXTURES/inputs/junit/all-pass.xml" \
        --matrix "$TEST_TEMP_DIR/matrix.md" --commit-sha abc1234
    assert_success
    assert_output --partial "Test Results Ingestion"
    assert_output --partial "matched"
    assert_output --partial "passed"
}

@test "ingest-test-results: summary shows Matrix A" {
    run bash "$INGEST_SCRIPT" --input "$TR_FIXTURES/inputs/junit/all-pass.xml" \
        --matrix "$TEST_TEMP_DIR/matrix.md" --commit-sha abc1234
    assert_success
    assert_output --partial "Matrix A"
}

@test "ingest-test-results: summary shows unmatched count" {
    run bash "$INGEST_SCRIPT" --input "$TR_FIXTURES/inputs/junit/extra-ids.xml" \
        --matrix "$TEST_TEMP_DIR/matrix.md" --commit-sha abc1234
    assert_success
    assert_output --partial "Matrix updated"
}

# ============================================================
# Bash wrapper — JSON output
# ============================================================

@test "ingest-test-results: --json outputs valid JSON" {
    run bash "$INGEST_SCRIPT" --input "$TR_FIXTURES/inputs/junit/all-pass.xml" \
        --matrix "$TEST_TEMP_DIR/matrix.md" --commit-sha abc1234 --json
    assert_success
    assert_valid_json "$output"
}

@test "ingest-test-results: --json includes matrix_path" {
    run bash "$INGEST_SCRIPT" --input "$TR_FIXTURES/inputs/junit/all-pass.xml" \
        --matrix "$TEST_TEMP_DIR/matrix.md" --commit-sha abc1234 --json
    assert_success
    local path
    path=$(json_field "$output" "matrix_path")
    [[ "$path" == *"matrix.md" ]]
}

@test "ingest-test-results: --json includes date" {
    run bash "$INGEST_SCRIPT" --input "$TR_FIXTURES/inputs/junit/all-pass.xml" \
        --matrix "$TEST_TEMP_DIR/matrix.md" --commit-sha abc1234 --json
    assert_success
    local date
    date=$(json_field "$output" "date")
    [[ "$date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]
}

@test "ingest-test-results: --json includes commit" {
    run bash "$INGEST_SCRIPT" --input "$TR_FIXTURES/inputs/junit/all-pass.xml" \
        --matrix "$TEST_TEMP_DIR/matrix.md" --commit-sha abc1234 --json
    assert_success
    local commit
    commit=$(json_field "$output" "commit")
    [ "$commit" = "abc1234" ]
}

# ============================================================
# Bash wrapper — coverage column
# ============================================================

@test "ingest-test-results: coverage adds Coverage header to Matrix D" {
    cp "$TR_FIXTURES/inputs/matrix/module-design.md" "$TEST_TEMP_DIR/module-design.md"
    run bash "$INGEST_SCRIPT" --input "$TR_FIXTURES/inputs/junit/all-pass.xml" \
        --coverage "$TR_FIXTURES/inputs/cobertura/full-coverage.xml" \
        --coverage-map "$TR_FIXTURES/inputs/matrix/coverage-map.yml" \
        --matrix "$TEST_TEMP_DIR/matrix.md" --commit-sha abc1234 \
        "$TEST_TEMP_DIR"
    assert_success
    grep "## Matrix D" -A2 "$TEST_TEMP_DIR/matrix.md" | grep -q "| Coverage |"
}

@test "ingest-test-results: coverage shows percentage in Matrix D rows" {
    cp "$TR_FIXTURES/inputs/matrix/module-design.md" "$TEST_TEMP_DIR/module-design.md"
    run bash "$INGEST_SCRIPT" --input "$TR_FIXTURES/inputs/junit/all-pass.xml" \
        --coverage "$TR_FIXTURES/inputs/cobertura/partial-coverage.xml" \
        --coverage-map "$TR_FIXTURES/inputs/matrix/coverage-map.yml" \
        --matrix "$TEST_TEMP_DIR/matrix.md" --commit-sha abc1234 \
        "$TEST_TEMP_DIR"
    assert_success
    grep "UTS-001-A1" "$TEST_TEMP_DIR/matrix.md" | grep -q "95.0% stmt"
}

@test "ingest-test-results: coverage below threshold shows warning" {
    cp "$TR_FIXTURES/inputs/matrix/module-design.md" "$TEST_TEMP_DIR/module-design.md"
    run bash "$INGEST_SCRIPT" --input "$TR_FIXTURES/inputs/junit/all-pass.xml" \
        --coverage "$TR_FIXTURES/inputs/cobertura/partial-coverage.xml" \
        --coverage-map "$TR_FIXTURES/inputs/matrix/coverage-map.yml" \
        --matrix "$TEST_TEMP_DIR/matrix.md" --commit-sha abc1234 \
        "$TEST_TEMP_DIR"
    assert_success
    grep "UTS-001-A1" "$TEST_TEMP_DIR/matrix.md" | grep -q "⚠"
}

@test "ingest-test-results: no Coverage header on Matrix A" {
    cp "$TR_FIXTURES/inputs/matrix/module-design.md" "$TEST_TEMP_DIR/module-design.md"
    run bash "$INGEST_SCRIPT" --input "$TR_FIXTURES/inputs/junit/all-pass.xml" \
        --coverage "$TR_FIXTURES/inputs/cobertura/full-coverage.xml" \
        --coverage-map "$TR_FIXTURES/inputs/matrix/coverage-map.yml" \
        --matrix "$TEST_TEMP_DIR/matrix.md" --commit-sha abc1234 \
        "$TEST_TEMP_DIR"
    assert_success
    # Matrix A header should NOT have Coverage
    local header
    header=$(grep "## Matrix A" -A2 "$TEST_TEMP_DIR/matrix.md" | grep "^|" | head -1)
    [[ "$header" != *"Coverage"* ]]
}
