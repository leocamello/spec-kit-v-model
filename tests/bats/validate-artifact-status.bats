# Implements: REQ-016, SYS-004, ARCH-007, ARCH-016, MOD-010, MOD-021, HAZ-009, HAZ-010, D-003
#
# BATS suite for `scripts/bash/validate-artifact-status.sh` (MF-6 — approval-status gate).

load "test_helper"

SCRIPT="${SCRIPTS_DIR}/validate-artifact-status.sh"

ARTIFACTS=(requirements.md system-design.md architecture-design.md module-design.md \
           hazard-analysis.md unit-test.md integration-test.md system-test.md acceptance-plan.md)

setup() {
    setup_temp_dir
    VMODEL_DIR="$TEST_TEMP_DIR/v-model"
    mkdir -p "$VMODEL_DIR"
}

teardown() {
    teardown_temp_dir
}

stage_artifact() {
    # $1 = filename, $2 = status header value (use literal "<NONE>" to skip header)
    local f="$VMODEL_DIR/$1"
    local status="$2"
    {
        echo "# $1"
        echo
        if [ "$status" != "<NONE>" ]; then echo "**Status**: $status"; fi
        echo
        echo "Body content."
    } > "$f"
}

stage_all() {
    local status="$1"
    for a in "${ARTIFACTS[@]}"; do stage_artifact "$a" "$status"; done
}

@test "all-Approved fixture → exit 0 with 'STATUS: PASS' (REQ-016)" {
    stage_all "Approved"
    run "$SCRIPT" "$VMODEL_DIR"
    assert_success
    [ "$output" = "STATUS: PASS" ]
}

@test "one-Draft artifact → exit 1 + stderr names file with value Draft (HAZ-009)" {
    stage_all "Approved"
    stage_artifact "module-design.md" "Draft"
    run "$SCRIPT" "$VMODEL_DIR"
    assert_failure
    assert_output --partial "STATUS: module-design.md: Draft"
}

@test "missing **Status** header → exit 1 with value <missing> (HAZ-010)" {
    stage_all "Approved"
    stage_artifact "hazard-analysis.md" "<NONE>"
    run "$SCRIPT" "$VMODEL_DIR"
    assert_failure
    assert_output --partial "STATUS: hazard-analysis.md: <missing>"
}

@test "unknown status value Frobbed → exit 1 + stderr names value (ARCH-007)" {
    stage_all "Approved"
    stage_artifact "system-design.md" "Frobbed"
    run "$SCRIPT" "$VMODEL_DIR"
    assert_failure
    assert_output --partial "STATUS: system-design.md: Frobbed"
}

@test "--required-status override admits all-Draft fixture (MOD-010)" {
    stage_all "Draft"
    run "$SCRIPT" "$VMODEL_DIR" --required-status Draft --required-status Approved
    assert_success
    [ "$output" = "STATUS: PASS" ]
}

@test "body-occurrence of **Status** ignored — only first match consulted (HAZ-010)" {
    stage_all "Approved"
    {
        echo "# integration-test.md"
        echo
        echo "**Status**: Approved"
        echo
        echo "Body talks about a deferred row:"
        echo "**Status**: DROP per drift-diff-plan.md."
    } > "$VMODEL_DIR/integration-test.md"
    run "$SCRIPT" "$VMODEL_DIR"
    assert_success
    [ "$output" = "STATUS: PASS" ]
}

@test "missing files are silently skipped (no output, no failure) (ARCH-016)" {
    stage_artifact "requirements.md" "Approved"
    stage_artifact "system-design.md" "Approved"
    run "$SCRIPT" "$VMODEL_DIR"
    assert_success
    [ "$output" = "STATUS: PASS" ]
}

@test "missing vmodel-dir argument → exit 1 (ARCH-007 §Error paths)" {
    run "$SCRIPT"
    assert_failure
}

@test "non-existent vmodel-dir → exit 1 (ARCH-007 §Error paths)" {
    run "$SCRIPT" "$TEST_TEMP_DIR/does-not-exist"
    assert_failure
}

@test "--help → exit 0" {
    run "$SCRIPT" --help
    assert_success
}
