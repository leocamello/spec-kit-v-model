load "test_helper"

# --- Minimal fixture: 100% coverage ---

@test "architecture coverage: full coverage exits 0" {
    run bash "$SCRIPTS_DIR/validate-architecture-coverage.sh" "$FIXTURES_DIR/minimal"
    assert_success
}

@test "architecture coverage: full coverage shows success message" {
    run bash "$SCRIPTS_DIR/validate-architecture-coverage.sh" "$FIXTURES_DIR/minimal"
    assert_success
    assert_output --partial "coverage"
}

@test "architecture coverage: full coverage JSON has_gaps=false" {
    run bash "$SCRIPTS_DIR/validate-architecture-coverage.sh" --json "$FIXTURES_DIR/minimal"
    assert_success
    local gaps
    gaps=$(json_field "$output" "has_gaps")
    [ "$gaps" = "False" ]
}

@test "architecture coverage: minimal fixture counts are correct" {
    run bash "$SCRIPTS_DIR/validate-architecture-coverage.sh" --json "$FIXTURES_DIR/minimal"
    assert_success
    local sys arch itps itss
    sys=$(json_field "$output" "total_sys")
    arch=$(json_field "$output" "total_arch")
    itps=$(json_field "$output" "total_itps")
    itss=$(json_field "$output" "total_itss")
    [ "$sys" = "3" ]
    [ "$arch" = "4" ]
    [ "$itps" = "6" ]
    [ "$itss" = "6" ]
}

# --- Complex fixture: many-to-many + CROSS-CUTTING ---

@test "architecture coverage: complex fixture exits 0" {
    run bash "$SCRIPTS_DIR/validate-architecture-coverage.sh" "$FIXTURES_DIR/complex"
    assert_success
}

@test "architecture coverage: complex fixture JSON has_gaps=false" {
    run bash "$SCRIPTS_DIR/validate-architecture-coverage.sh" --json "$FIXTURES_DIR/complex"
    assert_success
    local gaps
    gaps=$(json_field "$output" "has_gaps")
    [ "$gaps" = "False" ]
}

# --- Gaps fixture: coverage failures ---

@test "architecture coverage: gaps fixture exits 1" {
    run bash "$SCRIPTS_DIR/validate-architecture-coverage.sh" "$FIXTURES_DIR/gaps"
    assert_failure
}

@test "architecture coverage: gaps fixture JSON has_gaps=true" {
    run bash "$SCRIPTS_DIR/validate-architecture-coverage.sh" --json "$FIXTURES_DIR/gaps"
    assert_failure
    local gaps
    gaps=$(json_field "$output" "has_gaps")
    [ "$gaps" = "True" ]
}

# --- Empty fixture: no items ---

@test "architecture coverage: empty fixture exits 0" {
    run bash "$SCRIPTS_DIR/validate-architecture-coverage.sh" "$FIXTURES_DIR/empty"
    assert_success
}

@test "architecture coverage: empty fixture has zero counts" {
    run bash "$SCRIPTS_DIR/validate-architecture-coverage.sh" --json "$FIXTURES_DIR/empty"
    assert_success
    local sys arch
    sys=$(json_field "$output" "total_sys")
    arch=$(json_field "$output" "total_arch")
    [ "$sys" = "0" ]
    [ "$arch" = "0" ]
}

# --- Error handling ---

@test "architecture coverage: missing vmodel-dir argument exits 1" {
    run bash "$SCRIPTS_DIR/validate-architecture-coverage.sh"
    assert_failure
}

@test "architecture coverage: --help exits 0" {
    run bash "$SCRIPTS_DIR/validate-architecture-coverage.sh" --help
    assert_success
    assert_output --partial "Usage"
}
