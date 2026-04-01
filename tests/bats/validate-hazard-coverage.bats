load "test_helper"

# --- Minimal fixture: 100% coverage ---

@test "hazard coverage: full coverage exits 0" {
    run bash "$SCRIPTS_DIR/validate-hazard-coverage.sh" "$FIXTURES_DIR/minimal"
    assert_success
}

@test "hazard coverage: full coverage shows success message" {
    run bash "$SCRIPTS_DIR/validate-hazard-coverage.sh" "$FIXTURES_DIR/minimal"
    assert_success
    assert_output --partial "Forward Coverage"
}

@test "hazard coverage: full coverage JSON has_gaps=false" {
    run bash "$SCRIPTS_DIR/validate-hazard-coverage.sh" --json "$FIXTURES_DIR/minimal"
    assert_success
    local gaps
    gaps=$(json_field "$output" "has_gaps")
    [ "$gaps" = "False" ]
}

@test "hazard coverage: minimal fixture counts are correct" {
    run bash "$SCRIPTS_DIR/validate-hazard-coverage.sh" --json "$FIXTURES_DIR/minimal"
    assert_success
    local sys haz
    sys=$(json_field "$output" "total_sys")
    haz=$(json_field "$output" "total_haz")
    [ "$sys" = "3" ]
    [ "$haz" = "5" ]
}

@test "hazard coverage: minimal uses implicit NORMAL state" {
    run bash "$SCRIPTS_DIR/validate-hazard-coverage.sh" --json "$FIXTURES_DIR/minimal"
    assert_success
    local implicit
    implicit=$(json_field "$output" "implicit_normal")
    [ "$implicit" = "True" ]
}

@test "hazard coverage: minimal forward coverage is 100%" {
    run bash "$SCRIPTS_DIR/validate-hazard-coverage.sh" --json "$FIXTURES_DIR/minimal"
    assert_success
    local pct
    pct=$(json_field "$output" "forward_coverage_pct")
    [ "$pct" = "100" ]
}

@test "hazard coverage: minimal backward coverage is 100%" {
    run bash "$SCRIPTS_DIR/validate-hazard-coverage.sh" --json "$FIXTURES_DIR/minimal"
    assert_success
    local pct
    pct=$(json_field "$output" "backward_coverage_pct")
    [ "$pct" = "100" ]
}

@test "hazard coverage: minimal state consistency is true" {
    run bash "$SCRIPTS_DIR/validate-hazard-coverage.sh" --json "$FIXTURES_DIR/minimal"
    assert_success
    local sc
    sc=$(json_field "$output" "state_consistent")
    [ "$sc" = "True" ]
}

# --- Complex fixture: many-to-many, 100% coverage ---

@test "hazard coverage: complex fixture exits 0" {
    run bash "$SCRIPTS_DIR/validate-hazard-coverage.sh" "$FIXTURES_DIR/complex"
    assert_success
}

@test "hazard coverage: complex fixture has 12 HAZ and 6 SYS" {
    run bash "$SCRIPTS_DIR/validate-hazard-coverage.sh" --json "$FIXTURES_DIR/complex"
    assert_success
    local sys haz
    sys=$(json_field "$output" "total_sys")
    haz=$(json_field "$output" "total_haz")
    [ "$sys" = "6" ]
    [ "$haz" = "12" ]
}

@test "hazard coverage: complex fixture detects explicit states" {
    run bash "$SCRIPTS_DIR/validate-hazard-coverage.sh" --json "$FIXTURES_DIR/complex"
    assert_success
    local implicit
    implicit=$(json_field "$output" "implicit_normal")
    [ "$implicit" = "False" ]
}

@test "hazard coverage: complex fixture state consistent" {
    run bash "$SCRIPTS_DIR/validate-hazard-coverage.sh" --json "$FIXTURES_DIR/complex"
    assert_success
    local sc
    sc=$(json_field "$output" "state_consistent")
    [ "$sc" = "True" ]
}

# --- Gaps fixture: coverage failures ---

@test "hazard coverage: gaps fixture exits 1" {
    run bash "$SCRIPTS_DIR/validate-hazard-coverage.sh" "$FIXTURES_DIR/gaps"
    assert_failure
}

@test "hazard coverage: gaps fixture detects forward gap (SYS-002)" {
    run bash "$SCRIPTS_DIR/validate-hazard-coverage.sh" "$FIXTURES_DIR/gaps"
    assert_failure
    assert_output --partial "SYS-002"
}

@test "hazard coverage: gaps fixture detects backward gap (REQ-099)" {
    run bash "$SCRIPTS_DIR/validate-hazard-coverage.sh" "$FIXTURES_DIR/gaps"
    assert_failure
    assert_output --partial "HAZ-002"
}

@test "hazard coverage: gaps fixture detects undefined states" {
    run bash "$SCRIPTS_DIR/validate-hazard-coverage.sh" "$FIXTURES_DIR/gaps"
    assert_failure
    assert_output --partial "EMERGENCY"
}

@test "hazard coverage: gaps fixture JSON has_gaps=true" {
    run bash "$SCRIPTS_DIR/validate-hazard-coverage.sh" --json "$FIXTURES_DIR/gaps"
    assert_failure
    local gaps
    gaps=$(json_field "$output" "has_gaps")
    [ "$gaps" = "True" ]
}

@test "hazard coverage: gaps fixture forward coverage 50%" {
    run bash "$SCRIPTS_DIR/validate-hazard-coverage.sh" --json "$FIXTURES_DIR/gaps"
    assert_failure
    local pct
    pct=$(json_field "$output" "forward_coverage_pct")
    [ "$pct" = "50" ]
}

@test "hazard coverage: gaps fixture backward coverage 66%" {
    run bash "$SCRIPTS_DIR/validate-hazard-coverage.sh" --json "$FIXTURES_DIR/gaps"
    assert_failure
    local pct
    pct=$(json_field "$output" "backward_coverage_pct")
    [ "$pct" = "66" ]
}

# --- Partial mode ---

@test "hazard coverage: --partial skips backward when requirements.md absent" {
    setup_temp_dir
    mkdir -p "$TEST_TEMP_DIR/vmodel"
    cp "$FIXTURES_DIR/minimal/hazard-analysis.md" "$TEST_TEMP_DIR/vmodel/"
    cp "$FIXTURES_DIR/minimal/system-design.md" "$TEST_TEMP_DIR/vmodel/"
    run bash "$SCRIPTS_DIR/validate-hazard-coverage.sh" --partial "$TEST_TEMP_DIR/vmodel"
    assert_success
    teardown_temp_dir
}

@test "hazard coverage: --partial JSON shows partial_mode true" {
    setup_temp_dir
    mkdir -p "$TEST_TEMP_DIR/vmodel"
    cp "$FIXTURES_DIR/minimal/hazard-analysis.md" "$TEST_TEMP_DIR/vmodel/"
    cp "$FIXTURES_DIR/minimal/system-design.md" "$TEST_TEMP_DIR/vmodel/"
    run bash "$SCRIPTS_DIR/validate-hazard-coverage.sh" --partial --json "$TEST_TEMP_DIR/vmodel"
    assert_success
    local pm
    pm=$(json_field "$output" "partial_mode")
    [ "$pm" = "True" ]
    teardown_temp_dir
}

# --- Error handling ---

@test "hazard coverage: missing vmodel-dir argument exits 1" {
    run bash "$SCRIPTS_DIR/validate-hazard-coverage.sh"
    assert_failure
    assert_output --partial "ERROR"
}

@test "hazard coverage: missing system-design.md exits 1" {
    setup_temp_dir
    mkdir -p "$TEST_TEMP_DIR/vmodel"
    touch "$TEST_TEMP_DIR/vmodel/hazard-analysis.md"
    run bash "$SCRIPTS_DIR/validate-hazard-coverage.sh" "$TEST_TEMP_DIR/vmodel"
    assert_failure
    assert_output --partial "system-design.md not found"
    teardown_temp_dir
}

@test "hazard coverage: missing hazard-analysis.md exits 1" {
    setup_temp_dir
    mkdir -p "$TEST_TEMP_DIR/vmodel"
    touch "$TEST_TEMP_DIR/vmodel/system-design.md"
    run bash "$SCRIPTS_DIR/validate-hazard-coverage.sh" "$TEST_TEMP_DIR/vmodel"
    assert_failure
    assert_output --partial "hazard-analysis.md not found"
    teardown_temp_dir
}

# --- Build Matrix: Matrix H ---

@test "build-matrix: minimal fixture generates Matrix H" {
    run bash "$SCRIPTS_DIR/build-matrix.sh" "$FIXTURES_DIR/minimal"
    assert_success
    assert_output --partial "Matrix H"
    assert_output --partial "Hazard Traceability"
}

@test "build-matrix: minimal Matrix H has 5 HAZ entries" {
    setup_temp_dir
    run bash "$SCRIPTS_DIR/build-matrix.sh" "$FIXTURES_DIR/minimal" --output "$TEST_TEMP_DIR/matrix.md"
    assert_success
    local count
    count=$(grep -c "^| HAZ-" "$TEST_TEMP_DIR/matrix.md" || true)
    [ "$count" = "5" ]
    teardown_temp_dir
}

@test "build-matrix: minimal Matrix H coverage is 100%" {
    setup_temp_dir
    run bash "$SCRIPTS_DIR/build-matrix.sh" "$FIXTURES_DIR/minimal" --output "$TEST_TEMP_DIR/matrix.md"
    assert_success
    run grep "5/5 (100%)" "$TEST_TEMP_DIR/matrix.md"
    assert_success
    teardown_temp_dir
}

@test "build-matrix: complex Matrix H has 12 HAZ entries" {
    setup_temp_dir
    run bash "$SCRIPTS_DIR/build-matrix.sh" "$FIXTURES_DIR/complex" --output "$TEST_TEMP_DIR/matrix.md"
    assert_success
    local count
    count=$(grep -c "^| HAZ-" "$TEST_TEMP_DIR/matrix.md" || true)
    [ "$count" = "12" ]
    teardown_temp_dir
}

@test "build-matrix: no Matrix H without hazard-analysis.md" {
    run bash "$SCRIPTS_DIR/build-matrix.sh" "$FIXTURES_DIR/empty"
    assert_success
    refute_output --partial "Matrix H"
}

@test "build-matrix: gaps fixture still generates Matrix H" {
    run bash "$SCRIPTS_DIR/build-matrix.sh" "$FIXTURES_DIR/gaps"
    assert_success
    assert_output --partial "Matrix H"
}
