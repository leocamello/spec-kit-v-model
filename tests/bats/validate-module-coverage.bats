load "test_helper"

# --- Minimal fixture: 100% coverage ---

@test "module coverage: full coverage exits 0" {
    run bash "$SCRIPTS_DIR/validate-module-coverage.sh" "$FIXTURES_DIR/minimal"
    assert_success
}

@test "module coverage: full coverage shows success message" {
    run bash "$SCRIPTS_DIR/validate-module-coverage.sh" "$FIXTURES_DIR/minimal"
    assert_success
    assert_output --partial "coverage"
}

@test "module coverage: full coverage JSON has_gaps=false" {
    run bash "$SCRIPTS_DIR/validate-module-coverage.sh" --json "$FIXTURES_DIR/minimal"
    assert_success
    local gaps
    gaps=$(json_field "$output" "has_gaps")
    [ "$gaps" = "False" ]
}

@test "module coverage: minimal fixture counts are correct" {
    run bash "$SCRIPTS_DIR/validate-module-coverage.sh" --json "$FIXTURES_DIR/minimal"
    assert_success
    local arch mod utps utss
    arch=$(json_field "$output" "total_arch")
    mod=$(json_field "$output" "total_mod")
    utps=$(json_field "$output" "total_utps")
    utss=$(json_field "$output" "total_utss")
    [ "$arch" = "4" ]
    [ "$mod" = "4" ]
    [ "$utps" = "6" ]
    [ "$utss" = "13" ]
}

@test "module coverage: minimal has zero external modules" {
    run bash "$SCRIPTS_DIR/validate-module-coverage.sh" --json "$FIXTURES_DIR/minimal"
    assert_success
    local ext
    ext=$(json_field "$output" "total_external")
    [ "$ext" = "0" ]
}

# --- Complex fixture: [EXTERNAL] + [CROSS-CUTTING] + stateful ---

@test "module coverage: complex fixture exits 0" {
    run bash "$SCRIPTS_DIR/validate-module-coverage.sh" "$FIXTURES_DIR/complex"
    assert_success
}

@test "module coverage: complex fixture JSON has_gaps=false" {
    run bash "$SCRIPTS_DIR/validate-module-coverage.sh" --json "$FIXTURES_DIR/complex"
    assert_success
    local gaps
    gaps=$(json_field "$output" "has_gaps")
    [ "$gaps" = "False" ]
}

@test "module coverage: complex fixture detects external modules" {
    run bash "$SCRIPTS_DIR/validate-module-coverage.sh" --json "$FIXTURES_DIR/complex"
    assert_success
    local ext
    ext=$(json_field "$output" "total_external")
    [ "$ext" -ge 1 ]
}

# --- Gaps fixture: coverage failures ---

@test "module coverage: gaps fixture exits 1" {
    run bash "$SCRIPTS_DIR/validate-module-coverage.sh" "$FIXTURES_DIR/gaps"
    assert_failure
}

@test "module coverage: gaps fixture JSON has_gaps=true" {
    run bash "$SCRIPTS_DIR/validate-module-coverage.sh" --json "$FIXTURES_DIR/gaps"
    assert_failure
    local gaps
    gaps=$(json_field "$output" "has_gaps")
    [ "$gaps" = "True" ]
}

@test "module coverage: gaps fixture reports MOD-002 uncovered" {
    run bash "$SCRIPTS_DIR/validate-module-coverage.sh" --json "$FIXTURES_DIR/gaps"
    assert_failure
    assert_output --partial "MOD-002"
}

@test "module coverage: gaps fixture reports orphaned MOD-099" {
    run bash "$SCRIPTS_DIR/validate-module-coverage.sh" --json "$FIXTURES_DIR/gaps"
    assert_failure
    assert_output --partial "MOD-099"
}

# --- Empty fixture: no items ---

@test "module coverage: empty fixture exits 0" {
    run bash "$SCRIPTS_DIR/validate-module-coverage.sh" "$FIXTURES_DIR/empty"
    assert_success
}

@test "module coverage: empty fixture has zero counts" {
    run bash "$SCRIPTS_DIR/validate-module-coverage.sh" --json "$FIXTURES_DIR/empty"
    assert_success
    local arch mod
    arch=$(json_field "$output" "total_arch")
    mod=$(json_field "$output" "total_mod")
    [ "$arch" = "0" ]
    [ "$mod" = "0" ]
}

# --- Error handling ---

@test "module coverage: missing vmodel-dir argument exits 1" {
    run bash "$SCRIPTS_DIR/validate-module-coverage.sh"
    assert_failure
}

@test "module coverage: --help exits 0" {
    run bash "$SCRIPTS_DIR/validate-module-coverage.sh" --help
    assert_success
    assert_output --partial "Usage"
}
