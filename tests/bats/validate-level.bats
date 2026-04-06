load "test_helper"

# ── Dispatches to correct validator ──

@test "validate-level: acceptance dispatches to validate-requirement-coverage" {
    run bash "$SCRIPTS_DIR/validate-level.sh" "$FIXTURES_DIR/minimal" acceptance
    assert_success
    assert_output --partial "REQ → ATP coverage"
}

@test "validate-level: system-test dispatches to validate-system-coverage" {
    run bash "$SCRIPTS_DIR/validate-level.sh" "$FIXTURES_DIR/minimal" system-test
    assert_success
    assert_output --partial "REQ → SYS coverage"
}

@test "validate-level: integration-test dispatches to validate-architecture-coverage" {
    run bash "$SCRIPTS_DIR/validate-level.sh" "$FIXTURES_DIR/minimal" integration-test
    assert_success
    assert_output --partial "SYS → ARCH coverage"
}

@test "validate-level: unit-test dispatches to validate-module-coverage" {
    run bash "$SCRIPTS_DIR/validate-level.sh" "$FIXTURES_DIR/minimal" unit-test
    assert_success
    assert_output --partial "ARCH → MOD coverage"
}

@test "validate-level: hazard-analysis dispatches to validate-hazard-coverage" {
    run bash "$SCRIPTS_DIR/validate-level.sh" "$FIXTURES_DIR/minimal" hazard-analysis
    assert_success
    assert_output --partial "hazard coverage"
}

# ── All levels exit 0 on full coverage ──

@test "validate-level: acceptance exits 0 on full coverage" {
    run bash "$SCRIPTS_DIR/validate-level.sh" "$FIXTURES_DIR/minimal" acceptance
    assert_success
}

@test "validate-level: system-test exits 0 on full coverage" {
    run bash "$SCRIPTS_DIR/validate-level.sh" "$FIXTURES_DIR/minimal" system-test
    assert_success
}

@test "validate-level: integration-test exits 0 on full coverage" {
    run bash "$SCRIPTS_DIR/validate-level.sh" "$FIXTURES_DIR/minimal" integration-test
    assert_success
}

@test "validate-level: unit-test exits 0 on full coverage" {
    run bash "$SCRIPTS_DIR/validate-level.sh" "$FIXTURES_DIR/minimal" unit-test
    assert_success
}

@test "validate-level: hazard-analysis exits 0 on full coverage" {
    run bash "$SCRIPTS_DIR/validate-level.sh" "$FIXTURES_DIR/minimal" hazard-analysis
    assert_success
}

# ── --json flag is forwarded ──

@test "validate-level: --json acceptance produces JSON output" {
    run bash -c "bash '$SCRIPTS_DIR/validate-level.sh' --json '$FIXTURES_DIR/minimal' acceptance 2>/dev/null"
    assert_success
    local has_gaps
    has_gaps=$(json_field "$output" "has_gaps")
    [ "$has_gaps" = "False" ]
}

@test "validate-level: --json system-test produces JSON output" {
    run bash -c "bash '$SCRIPTS_DIR/validate-level.sh' --json '$FIXTURES_DIR/minimal' system-test 2>/dev/null"
    assert_success
    local has_gaps
    has_gaps=$(json_field "$output" "has_gaps")
    [ "$has_gaps" = "False" ]
}

@test "validate-level: --json integration-test produces JSON output" {
    run bash -c "bash '$SCRIPTS_DIR/validate-level.sh' --json '$FIXTURES_DIR/minimal' integration-test 2>/dev/null"
    assert_success
    local has_gaps
    has_gaps=$(json_field "$output" "has_gaps")
    [ "$has_gaps" = "False" ]
}

@test "validate-level: --json unit-test produces JSON output" {
    run bash -c "bash '$SCRIPTS_DIR/validate-level.sh' --json '$FIXTURES_DIR/minimal' unit-test 2>/dev/null"
    assert_success
    local has_gaps
    has_gaps=$(json_field "$output" "has_gaps")
    [ "$has_gaps" = "False" ]
}

@test "validate-level: --json hazard-analysis produces JSON output" {
    run bash -c "bash '$SCRIPTS_DIR/validate-level.sh' --json '$FIXTURES_DIR/minimal' hazard-analysis 2>/dev/null"
    assert_success
    local has_gaps
    has_gaps=$(json_field "$output" "has_gaps")
    [ "$has_gaps" = "False" ]
}

# ── Gaps fixture exits 1 ──

@test "validate-level: acceptance exits 1 when gaps exist" {
    run bash "$SCRIPTS_DIR/validate-level.sh" "$FIXTURES_DIR/gaps" acceptance
    assert_failure
}

@test "validate-level: system-test exits 1 when gaps exist" {
    run bash "$SCRIPTS_DIR/validate-level.sh" "$FIXTURES_DIR/gaps" system-test
    assert_failure
}

@test "validate-level: integration-test exits 1 when gaps exist" {
    run bash "$SCRIPTS_DIR/validate-level.sh" "$FIXTURES_DIR/gaps" integration-test
    assert_failure
}

@test "validate-level: unit-test exits 1 when gaps exist" {
    run bash "$SCRIPTS_DIR/validate-level.sh" "$FIXTURES_DIR/gaps" unit-test
    assert_failure
}

# ── Error handling ──

@test "validate-level: unknown level exits 2" {
    run bash "$SCRIPTS_DIR/validate-level.sh" "$FIXTURES_DIR/minimal" bogus
    assert_failure
    [[ "$status" -eq 2 ]]
    assert_output --partial "unknown level"
}

@test "validate-level: missing arguments exits 2" {
    run bash "$SCRIPTS_DIR/validate-level.sh"
    assert_failure
    [[ "$status" -eq 2 ]]
    assert_output --partial "required"
}

@test "validate-level: missing level argument exits 2" {
    run bash "$SCRIPTS_DIR/validate-level.sh" "$FIXTURES_DIR/minimal"
    assert_failure
    [[ "$status" -eq 2 ]]
    assert_output --partial "required"
}

@test "validate-level: nonexistent directory exits 2" {
    run bash "$SCRIPTS_DIR/validate-level.sh" /nonexistent/path acceptance
    assert_failure
    [[ "$status" -eq 2 ]]
    assert_output --partial "does not exist"
}

@test "validate-level: extra argument exits 2" {
    run bash "$SCRIPTS_DIR/validate-level.sh" "$FIXTURES_DIR/minimal" acceptance extra
    assert_failure
    [[ "$status" -eq 2 ]]
    assert_output --partial "unexpected"
}

@test "validate-level: --help exits 0" {
    run bash "$SCRIPTS_DIR/validate-level.sh" --help
    assert_success
    assert_output --partial "Usage"
    assert_output --partial "acceptance"
    assert_output --partial "system-test"
    assert_output --partial "integration-test"
    assert_output --partial "unit-test"
    assert_output --partial "hazard-analysis"
}
