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
    assert_output --partial "REQ-003"
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
    assert_output --partial "Matrix A Coverage"
}

@test "orphaned ATPs section populated" {
    run bash "$SCRIPTS_DIR/build-matrix.sh" "$FIXTURES_DIR/complex"
    assert_success
    assert_output --partial "ATP-999-A"
}

# ---- Matrix B: System-level tests ----

@test "includes Matrix B when system artifacts exist" {
    run bash "$SCRIPTS_DIR/build-matrix.sh" "$FIXTURES_DIR/minimal"
    assert_success
    assert_output --partial "Matrix B — Verification"
}

@test "Matrix B contains SYS components" {
    run bash "$SCRIPTS_DIR/build-matrix.sh" "$FIXTURES_DIR/minimal"
    assert_success
    assert_output --partial "SYS-001"
    assert_output --partial "STP-001-A"
    assert_output --partial "STS-001-A1"
}

@test "Matrix B shows coverage metrics" {
    run bash "$SCRIPTS_DIR/build-matrix.sh" "$FIXTURES_DIR/minimal"
    assert_success
    assert_output --partial "REQ → SYS Coverage"
    assert_output --partial "SYS → STP Coverage"
}

@test "no Matrix B when system artifacts absent" {
    mkdir -p "$TEST_TEMP_DIR/vmodel"
    cp "$FIXTURES_DIR/minimal/requirements.md" "$TEST_TEMP_DIR/vmodel/"
    cp "$FIXTURES_DIR/minimal/acceptance-plan.md" "$TEST_TEMP_DIR/vmodel/"
    run bash "$SCRIPTS_DIR/build-matrix.sh" "$TEST_TEMP_DIR/vmodel"
    assert_success
    refute_output --partial "Matrix B"
}

@test "Matrix A present regardless of system artifacts" {
    run bash "$SCRIPTS_DIR/build-matrix.sh" "$FIXTURES_DIR/minimal"
    assert_success
    assert_output --partial "Matrix A — Validation"
}

@test "system gap analysis present when system artifacts exist" {
    run bash "$SCRIPTS_DIR/build-matrix.sh" "$FIXTURES_DIR/minimal"
    assert_success
    assert_output --partial "Uncovered Requirements — System Level"
    assert_output --partial "Orphaned System Test Cases"
}

# ---- Matrix C: Architecture → Integration (already covered by Matrix B context above) ----

# ---- Matrix D: Module-level tests ----

@test "includes Matrix D when module artifacts exist" {
    run bash "$SCRIPTS_DIR/build-matrix.sh" "$FIXTURES_DIR/minimal"
    assert_success
    assert_output --partial "Matrix D"
}

@test "Matrix D contains MOD and UTP identifiers" {
    run bash "$SCRIPTS_DIR/build-matrix.sh" "$FIXTURES_DIR/minimal"
    assert_success
    assert_output --partial "MOD-001"
    assert_output --partial "UTP-001-A"
    assert_output --partial "UTS-001-A1"
}

@test "Matrix D shows module coverage metrics" {
    run bash "$SCRIPTS_DIR/build-matrix.sh" "$FIXTURES_DIR/minimal"
    assert_success
    assert_output --partial "ARCH"
    assert_output --partial "MOD"
    assert_output --partial "UTP"
}

@test "no Matrix D when module artifacts absent" {
    mkdir -p "$TEST_TEMP_DIR/vmodel"
    cp "$FIXTURES_DIR/minimal/requirements.md" "$TEST_TEMP_DIR/vmodel/"
    cp "$FIXTURES_DIR/minimal/acceptance-plan.md" "$TEST_TEMP_DIR/vmodel/"
    run bash "$SCRIPTS_DIR/build-matrix.sh" "$TEST_TEMP_DIR/vmodel"
    assert_success
    refute_output --partial "Matrix D"
}
