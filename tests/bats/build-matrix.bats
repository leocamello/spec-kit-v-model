load "test_helper"

setup() {
    setup_temp_dir
}

teardown() {
    teardown_temp_dir
}

@test "generates markdown table" {
    run bash "$SCRIPTS_DIR/build-matrix.sh" "$FIXTURES_DIR/minimal"
    assert_success
    assert_output --partial "| Requirement ID |"
}

@test "all REQs appear in output" {
    run bash "$SCRIPTS_DIR/build-matrix.sh" "$FIXTURES_DIR/minimal"
    assert_success
    assert_output --partial "REQ-001"
    assert_output --partial "REQ-002"
    assert_output --partial "REQ-NF-001"
}

@test "--output writes to file" {
    local outfile="$TEST_TEMP_DIR/matrix.md"
    run bash "$SCRIPTS_DIR/build-matrix.sh" "$FIXTURES_DIR/minimal" --output "$outfile"
    assert_success
    [ -f "$outfile" ]
    [ -s "$outfile" ]
}

@test "missing acceptance-plan.md fails" {
    mkdir -p "$TEST_TEMP_DIR/vmodel"
    cp "$FIXTURES_DIR/minimal/requirements.md" "$TEST_TEMP_DIR/vmodel/"
    run bash "$SCRIPTS_DIR/build-matrix.sh" "$TEST_TEMP_DIR/vmodel"
    assert_failure
}

@test "coverage metrics in output" {
    run bash "$SCRIPTS_DIR/build-matrix.sh" "$FIXTURES_DIR/minimal"
    assert_success
    assert_output --partial "Coverage Metrics"
}

@test "orphaned ATPs section populated" {
    run bash "$SCRIPTS_DIR/build-matrix.sh" "$FIXTURES_DIR/complex"
    assert_success
    assert_output --partial "ATP-999-A"
}
