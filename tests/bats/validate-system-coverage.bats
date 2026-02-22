load "test_helper"

# --- Minimal fixture: 100% coverage ---

@test "system coverage: full coverage exits 0" {
    run bash "$SCRIPTS_DIR/validate-system-coverage.sh" "$FIXTURES_DIR/minimal"
    assert_success
}

@test "system coverage: full coverage shows success message" {
    run bash "$SCRIPTS_DIR/validate-system-coverage.sh" "$FIXTURES_DIR/minimal"
    assert_success
    assert_output --partial "Full system-level coverage"
}

@test "system coverage: full coverage JSON has_gaps=false" {
    run bash "$SCRIPTS_DIR/validate-system-coverage.sh" --json "$FIXTURES_DIR/minimal"
    assert_success
    local gaps
    gaps=$(json_field "$output" "has_gaps")
    [ "$gaps" = "False" ]
}

@test "system coverage: minimal fixture counts are correct" {
    run bash "$SCRIPTS_DIR/validate-system-coverage.sh" --json "$FIXTURES_DIR/minimal"
    assert_success
    local reqs sys stps stss
    reqs=$(json_field "$output" "total_reqs")
    sys=$(json_field "$output" "total_sys")
    stps=$(json_field "$output" "total_stps")
    stss=$(json_field "$output" "total_stss")
    [ "$reqs" = "3" ]
    [ "$sys" = "3" ]
    [ "$stps" = "5" ]
    [ "$stss" = "5" ]
}

# --- Complex fixture: many-to-many, 100% coverage ---

@test "system coverage: complex fixture exits 0" {
    run bash "$SCRIPTS_DIR/validate-system-coverage.sh" "$FIXTURES_DIR/complex"
    assert_success
}

@test "system coverage: complex fixture REQ→SYS coverage is 100%" {
    run bash "$SCRIPTS_DIR/validate-system-coverage.sh" --json "$FIXTURES_DIR/complex"
    assert_success
    local pct
    pct=$(json_field "$output" "req_to_sys_coverage_pct")
    [ "$pct" = "100" ]
}

@test "system coverage: complex fixture has 10 REQs and 6 SYS" {
    run bash "$SCRIPTS_DIR/validate-system-coverage.sh" --json "$FIXTURES_DIR/complex"
    assert_success
    local reqs sys
    reqs=$(json_field "$output" "total_reqs")
    sys=$(json_field "$output" "total_sys")
    [ "$reqs" = "10" ]
    [ "$sys" = "6" ]
}

# --- Gaps fixture: coverage failures ---

@test "system coverage: gaps fixture exits 1" {
    run bash "$SCRIPTS_DIR/validate-system-coverage.sh" "$FIXTURES_DIR/gaps"
    assert_failure
}

@test "system coverage: gaps fixture detects uncovered REQ" {
    run bash "$SCRIPTS_DIR/validate-system-coverage.sh" "$FIXTURES_DIR/gaps"
    assert_failure
    assert_output --partial "REQ-003"
}

@test "system coverage: gaps fixture detects SYS without STP" {
    run bash "$SCRIPTS_DIR/validate-system-coverage.sh" "$FIXTURES_DIR/gaps"
    assert_failure
    assert_output --partial "SYS-002"
}

@test "system coverage: gaps fixture detects orphaned STP" {
    run bash "$SCRIPTS_DIR/validate-system-coverage.sh" "$FIXTURES_DIR/gaps"
    assert_failure
    assert_output --partial "STP-099-A"
}

@test "system coverage: gaps fixture JSON has_gaps=true" {
    run bash "$SCRIPTS_DIR/validate-system-coverage.sh" --json "$FIXTURES_DIR/gaps"
    assert_failure
    local gaps
    gaps=$(json_field "$output" "has_gaps")
    [ "$gaps" = "True" ]
}

# --- Empty fixture: no items ---

@test "system coverage: empty fixture exits 0" {
    run bash "$SCRIPTS_DIR/validate-system-coverage.sh" "$FIXTURES_DIR/empty"
    assert_success
}

@test "system coverage: empty fixture has zero counts" {
    run bash "$SCRIPTS_DIR/validate-system-coverage.sh" --json "$FIXTURES_DIR/empty"
    assert_success
    local reqs sys
    reqs=$(json_field "$output" "total_reqs")
    sys=$(json_field "$output" "total_sys")
    [ "$reqs" = "0" ]
    [ "$sys" = "0" ]
}

# --- Error handling ---

@test "system coverage: missing vmodel-dir argument exits 1" {
    run bash "$SCRIPTS_DIR/validate-system-coverage.sh"
    assert_failure
    assert_output --partial "ERROR"
}

@test "system coverage: missing requirements.md exits 1" {
    setup_temp_dir
    mkdir -p "$TEST_TEMP_DIR/vmodel"
    touch "$TEST_TEMP_DIR/vmodel/system-design.md"
    touch "$TEST_TEMP_DIR/vmodel/system-test.md"
    run bash "$SCRIPTS_DIR/validate-system-coverage.sh" "$TEST_TEMP_DIR/vmodel"
    assert_failure
    assert_output --partial "requirements.md not found"
    teardown_temp_dir
}

@test "system coverage: missing system-design.md exits 1" {
    setup_temp_dir
    mkdir -p "$TEST_TEMP_DIR/vmodel"
    touch "$TEST_TEMP_DIR/vmodel/requirements.md"
    touch "$TEST_TEMP_DIR/vmodel/system-test.md"
    run bash "$SCRIPTS_DIR/validate-system-coverage.sh" "$TEST_TEMP_DIR/vmodel"
    assert_failure
    assert_output --partial "system-design.md not found"
    teardown_temp_dir
}

@test "system coverage: missing system-test.md runs partial mode" {
    setup_temp_dir
    mkdir -p "$TEST_TEMP_DIR/vmodel"
    touch "$TEST_TEMP_DIR/vmodel/requirements.md"
    touch "$TEST_TEMP_DIR/vmodel/system-design.md"
    run bash "$SCRIPTS_DIR/validate-system-coverage.sh" "$TEST_TEMP_DIR/vmodel"
    assert_success
    assert_output --partial "system-test.md not found"
    assert_output --partial "Partial mode"
    teardown_temp_dir
}

@test "system coverage: --help exits 0" {
    run bash "$SCRIPTS_DIR/validate-system-coverage.sh" --help
    assert_success
    assert_output --partial "Usage"
}
