# Implements: REQ-017, REQ-CN-002, REQ-027, SYS-004, SYS-012, ARCH-007, ARCH-016, MOD-010, MOD-021, UTP-010-A, UTP-010-B, ATP-017-A, SCN-017-A1, HAZ-009, HAZ-010
#
# RED suite for the pre-implementation gate coordinator
# (`scripts/bash/run-v-model-gate.sh`). The script does not yet exist; every
# test below is expected to FAIL or ERROR until Phase 3 / T008 lands.

load "test_helper"

GATE_SCRIPT="${SCRIPTS_DIR}/run-v-model-gate.sh"

# Inner-script set per ARCH-007 §Inner-script set (REUSE — D-003).
# Order matches run-v-model-gate.sh INNERS array (status + domain + matrix + 5 coverage).
INNER_SCRIPTS="validate-artifact-status.sh validate-domain-profile.sh build-matrix.sh validate-requirement-coverage.sh validate-system-coverage.sh validate-architecture-coverage.sh validate-module-coverage.sh validate-hazard-coverage.sh"

setup() {
    # RED guard: every test in this file requires the script to exist. Until
    # Phase 3 / T008 lands this raises a clear, single-line ERROR so no test
    # can pass accidentally via exit-127 satisfying assert_failure.
    [ -x "$GATE_SCRIPT" ] || { echo "RED: $GATE_SCRIPT not yet implemented (T008 pending)" >&2; return 1; }
    setup_temp_dir
    SHIM_DIR="$TEST_TEMP_DIR/scripts"
    TRACE_LOG="$TEST_TEMP_DIR/trace.log"
    mkdir -p "$SHIM_DIR"
    : > "$TRACE_LOG"
    export TRACE_LOG
    # Stage a complete V-Model fixture as the feature dir argument.
    FEATURE_DIR="$TEST_TEMP_DIR/feature"
    mkdir -p "$FEATURE_DIR/v-model"
    cp "$FIXTURES_DIR/v-model/complete/"*.md "$FEATURE_DIR/v-model/"
}

teardown() {
    teardown_temp_dir
}

# Build a recording shim for one inner script. $1 is the basename, $2 is the
# desired exit code. The shim records "$0 $*" to $TRACE_LOG so we can assert
# composition trace + argv per UTP-010-A / UTP-010-B / SCN-017-A1.
make_shim() {
    name="$1"
    rc="$2"
    {
        echo '#!/bin/sh'
        echo "echo \"$name \$*\" >> \"$TRACE_LOG\""
        echo "exit $rc"
    } > "$SHIM_DIR/$name"
    chmod +x "$SHIM_DIR/$name"
}

# Stage the gate alongside shims so sibling-relative resolution works.
stage_gate() {
    cp "$GATE_SCRIPT" "$SHIM_DIR/run-v-model-gate.sh"
    chmod +x "$SHIM_DIR/run-v-model-gate.sh"
}

@test "composition: gate invokes exactly the six inner scripts (ARCH-007, SCN-017-A1)" {
    for s in $INNER_SCRIPTS; do make_shim "$s" 0; done
    stage_gate
    run bash "$SHIM_DIR/run-v-model-gate.sh" "$FEATURE_DIR"
    assert_success
    for s in $INNER_SCRIPTS; do
        run grep -F "$s" "$TRACE_LOG"
        assert_success
    done
}

@test "composition: status validator runs BEFORE build-matrix (MF-6 fail-fast ordering)" {
    for s in $INNER_SCRIPTS; do make_shim "$s" 0; done
    stage_gate
    run bash "$SHIM_DIR/run-v-model-gate.sh" "$FEATURE_DIR"
    assert_success
    # Trace lines are appended in invocation order.
    status_line="$(grep -nF 'validate-artifact-status.sh' "$TRACE_LOG" | head -n1 | cut -d: -f1)"
    matrix_line="$(grep -nF 'build-matrix.sh' "$TRACE_LOG" | head -n1 | cut -d: -f1)"
    [ -n "$status_line" ] && [ -n "$matrix_line" ]
    [ "$status_line" -lt "$matrix_line" ]
}

@test "MF-6 integration: real validate-artifact-status FAIL on Draft fixture → GATE: FAIL" {
    # Force the real status validator to surface a Draft → fail flow.
    # Stage shims only for the OTHER inners so the real status validator runs.
    for s in $INNER_SCRIPTS; do
        if [ "$s" = "validate-artifact-status.sh" ]; then continue; fi
        make_shim "$s" 0
    done
    # Make sure the real status validator is reachable from $SHIM_DIR via copy
    # (sibling-relative resolution).
    cp "$SCRIPTS_DIR/validate-artifact-status.sh" "$SHIM_DIR/validate-artifact-status.sh"
    chmod +x "$SHIM_DIR/validate-artifact-status.sh"
    # Fixture: ensure at least one canonical artifact is Draft.
    cat > "$FEATURE_DIR/v-model/requirements.md" <<'EOF'
# Requirements

**Status**: Draft

| ID | Description |
|----|-------------|
| REQ-001 | Example |
EOF
    stage_gate
    run bash "$SHIM_DIR/run-v-model-gate.sh" "$FEATURE_DIR"
    assert_failure
    assert_output --partial "validate-artifact-status.sh: FAIL"
    last_line=$(printf '%s\n' "$output" | tail -n 1)
    [ "$last_line" = "GATE: FAIL" ]
}

@test "composition: gate invokes no other wrapper beyond the six (HAZ-010, SCN-017-A1)" {
    for s in $INNER_SCRIPTS; do make_shim "$s" 0; done
    # Plant a tripwire shim that no spec-conformant gate may invoke.
    make_shim "validate-implements-ids.sh" 0
    stage_gate
    run bash "$SHIM_DIR/run-v-model-gate.sh" "$FEATURE_DIR"
    assert_success
    run grep -F "validate-implements-ids.sh" "$TRACE_LOG"
    assert_failure
}

@test "exit-code aggregation: any inner failure → gate exits non-zero (HAZ-009)" {
    for s in $INNER_SCRIPTS; do make_shim "$s" 0; done
    make_shim "validate-hazard-coverage.sh" 1
    stage_gate
    run bash "$SHIM_DIR/run-v-model-gate.sh" "$FEATURE_DIR"
    assert_failure
}

@test "exit-code aggregation: all-zero inner → gate exits 0 (UTP-010-A)" {
    for s in $INNER_SCRIPTS; do make_shim "$s" 0; done
    stage_gate
    run bash "$SHIM_DIR/run-v-model-gate.sh" "$FEATURE_DIR"
    assert_success
}

@test "final line is exactly 'GATE: PASS' on success (ARCH-007 §stdout schema)" {
    for s in $INNER_SCRIPTS; do make_shim "$s" 0; done
    stage_gate
    run bash "$SHIM_DIR/run-v-model-gate.sh" "$FEATURE_DIR"
    assert_success
    last_line=$(printf '%s\n' "$output" | tail -n 1)
    [ "$last_line" = "GATE: PASS" ]
}

@test "final line is exactly 'GATE: FAIL' on any inner failure (UTP-010-B)" {
    for s in $INNER_SCRIPTS; do make_shim "$s" 0; done
    make_shim "validate-requirement-coverage.sh" 1
    stage_gate
    run bash "$SHIM_DIR/run-v-model-gate.sh" "$FEATURE_DIR"
    assert_failure
    last_line=$(printf '%s\n' "$output" | tail -n 1)
    [ "$last_line" = "GATE: FAIL" ]
}

@test "structured-summary block emitted on success (ARCH-016, REQ-027, MOD-021)" {
    for s in $INNER_SCRIPTS; do make_shim "$s" 0; done
    stage_gate
    run bash "$SHIM_DIR/run-v-model-gate.sh" "$FEATURE_DIR"
    assert_success
    assert_output --partial "--- v-model run summary ---"
}

@test "structured-summary block emitted on failure (ARCH-016, SYS-012, REQ-CN-002)" {
    for s in $INNER_SCRIPTS; do make_shim "$s" 0; done
    make_shim "build-matrix.sh" 1
    stage_gate
    run bash "$SHIM_DIR/run-v-model-gate.sh" "$FEATURE_DIR"
    assert_failure
    assert_output --partial "--- v-model run summary ---"
}

@test "missing inner script: gate exits 1 with stderr diagnostic (ARCH-007 §Error paths)" {
    # Stage gate but no inner shims at all.
    stage_gate
    run bash "$SHIM_DIR/run-v-model-gate.sh" "$FEATURE_DIR"
    assert_failure
}
