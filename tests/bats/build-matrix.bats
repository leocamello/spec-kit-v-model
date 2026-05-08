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

# ---- MF-3: same-directory temp files + cleanup ----

@test "build-matrix concurrent runs do not corrupt each other's output" {
    local dir_a="$TEST_TEMP_DIR/vmodel-a"
    local dir_b="$TEST_TEMP_DIR/vmodel-b"
    mkdir -p "$dir_a" "$dir_b"
    cp "$FIXTURES_DIR/minimal/requirements.md" "$dir_a/"
    cp "$FIXTURES_DIR/minimal/acceptance-plan.md" "$dir_a/"
    cp "$FIXTURES_DIR/complex/requirements.md" "$dir_b/"
    cp "$FIXTURES_DIR/complex/acceptance-plan.md" "$dir_b/"

    local out_a="$TEST_TEMP_DIR/matrix-a.md"
    local out_b="$TEST_TEMP_DIR/matrix-b.md"

    bash "$SCRIPTS_DIR/build-matrix.sh" "$dir_a" --output "$out_a" >/dev/null &
    local pid_a=$!
    bash "$SCRIPTS_DIR/build-matrix.sh" "$dir_b" --output "$out_b" >/dev/null &
    local pid_b=$!
    wait "$pid_a"
    wait "$pid_b"

    [ -s "$out_a" ]
    [ -s "$out_b" ]
    [ "$(head -n 1 "$out_a")" = "# Traceability Matrix" ]
    [ "$(head -n 1 "$out_b")" = "# Traceability Matrix" ]
    ! diff -q "$out_a" "$out_b" >/dev/null

    run find "$TEST_TEMP_DIR" "$dir_a" "$dir_b" -name '.vmodel-matrix-*'
    assert_success
    [ -z "$output" ]
}

@test "build-matrix cleans up its temp files after success" {
    local vmdir="$TEST_TEMP_DIR/vmodel"
    mkdir -p "$vmdir"
    cp "$FIXTURES_DIR/minimal/requirements.md" "$vmdir/"
    cp "$FIXTURES_DIR/minimal/acceptance-plan.md" "$vmdir/"
    run bash "$SCRIPTS_DIR/build-matrix.sh" "$vmdir"
    assert_success
    run find "$vmdir" -name '.vmodel-matrix-*'
    assert_success
    [ -z "$output" ]
}

@test "build-matrix cleans up its temp files after failure" {
    local vmdir="$TEST_TEMP_DIR/vmodel-bad"
    mkdir -p "$vmdir"
    cp "$FIXTURES_DIR/minimal/requirements.md" "$vmdir/"
    # acceptance-plan.md missing → script should fail before/after temp creation
    run bash "$SCRIPTS_DIR/build-matrix.sh" "$vmdir"
    assert_failure
    run find "$vmdir" -name '.vmodel-matrix-*'
    assert_success
    [ -z "$output" ]
}

# ---- Path B (Combined): software-architecture-design replaces system-design + architecture-design ----

@test "Path B: no Matrix B (no system-design.md)" {
    run bash "$SCRIPTS_DIR/build-matrix.sh" "$FIXTURES_DIR/path-b-combined"
    assert_success
    refute_output --partial "Matrix B"
}

@test "Path B: no Matrix C (no architecture-design.md)" {
    run bash "$SCRIPTS_DIR/build-matrix.sh" "$FIXTURES_DIR/path-b-combined"
    assert_success
    refute_output --partial "Matrix C"
}

@test "Path B: no Matrix D (no architecture-design.md)" {
    run bash "$SCRIPTS_DIR/build-matrix.sh" "$FIXTURES_DIR/path-b-combined"
    assert_success
    refute_output --partial "Matrix D"
}

@test "Path B: Matrix A still present" {
    run bash "$SCRIPTS_DIR/build-matrix.sh" "$FIXTURES_DIR/path-b-combined"
    assert_success
    assert_output --partial "Matrix A — Validation"
}

@test "Path B: correct REQ→ATP coverage metrics" {
    run bash "$SCRIPTS_DIR/build-matrix.sh" "$FIXTURES_DIR/path-b-combined"
    assert_success
    assert_output --partial "Matrix A Coverage"
    assert_output --partial "REQ → ATP Coverage"
}

@test "Path B: no system-level gap analysis" {
    run bash "$SCRIPTS_DIR/build-matrix.sh" "$FIXTURES_DIR/path-b-combined"
    assert_success
    refute_output --partial "Uncovered Requirements — System Level"
}
