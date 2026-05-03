# Implements: REQ-IF-001, REQ-IF-002, REQ-029, SYS-010, ARCH-013, MOD-017, MOD-018, UTP-017-A, UTP-018-A, ATP-002-A, SCN-002-A1
#
# RED suite for the schema validator
# (`scripts/bash/validate-core-schema.sh`). Script does not yet exist;
# every test below is expected to FAIL or ERROR until Phase 3 / T011 lands.

load "test_helper"

SCHEMA_SCRIPT="${SCRIPTS_DIR}/validate-core-schema.sh"
PLAN_TEMPLATE="${PROJECT_ROOT}/.specify/templates/plan-template.md"
TASKS_TEMPLATE="${PROJECT_ROOT}/.specify/templates/tasks-template.md"

setup() {
    [ -x "$SCHEMA_SCRIPT" ] || { echo "RED: $SCHEMA_SCRIPT not yet implemented (T011 pending)" >&2; return 1; }
    setup_temp_dir
}

teardown() {
    teardown_temp_dir
}

@test "--plan: pristine spec-kit-core plan template passes (UTP-017-A, REQ-IF-001)" {
    run bash "$SCHEMA_SCRIPT" "$PLAN_TEMPLATE" --plan
    assert_success
    last_line=$(printf '%s\n' "$output" | tail -n 1)
    [[ "$last_line" == SCHEMA:\ PASS* ]]
}

@test "--tasks: pristine spec-kit-core tasks template passes (UTP-018-A, REQ-IF-002)" {
    run bash "$SCHEMA_SCRIPT" "$TASKS_TEMPLATE" --tasks
    assert_success
    last_line=$(printf '%s\n' "$output" | tail -n 1)
    [[ "$last_line" == SCHEMA:\ PASS* ]]
}

@test "--plan PASS line carries pinned schema version (ARCH-013 §stdout schema)" {
    run bash "$SCHEMA_SCRIPT" "$PLAN_TEMPLATE" --plan
    assert_success
    assert_output --partial "pinned_version=v0.7.0"
}

@test "--plan: missing required section fails closed with MISSING diagnostic (REQ-029, SYS-010)" {
    cp "$PLAN_TEMPLATE" "$TEST_TEMP_DIR/plan.md"
    # Strip the Summary section heading — REQ-IF-001 requires its presence.
    sed -i '/^## Summary$/d' "$TEST_TEMP_DIR/plan.md"
    run bash "$SCHEMA_SCRIPT" "$TEST_TEMP_DIR/plan.md" --plan
    assert_failure
    assert_output --partial "MISSING"
    last_line=$(printf '%s\n' "$output" | tail -n 1)
    [ "$last_line" = "SCHEMA: FAIL" ]
}

@test "--tasks: missing required section fails closed (REQ-029, MOD-018)" {
    cp "$TASKS_TEMPLATE" "$TEST_TEMP_DIR/tasks.md"
    # Empty out the file — every required section absent.
    : > "$TEST_TEMP_DIR/tasks.md"
    run bash "$SCHEMA_SCRIPT" "$TEST_TEMP_DIR/tasks.md" --tasks
    assert_failure
    assert_output --partial "MISSING"
}

@test "--plan: tolerates additive HTML-comment enrichment <!-- v-model: … --> (ATP-002-A, SCN-002-A1)" {
    cp "$PLAN_TEMPLATE" "$TEST_TEMP_DIR/plan.md"
    # Inject a v-model enrichment comment after every heading.
    awk '
        /^## / { print; print "<!-- v-model: source=specs/007-bridge-commands/v-model/requirements.md -->"; next }
        { print }
    ' "$PLAN_TEMPLATE" > "$TEST_TEMP_DIR/plan.md"
    run bash "$SCHEMA_SCRIPT" "$TEST_TEMP_DIR/plan.md" --plan
    assert_success
}

@test "--tasks: tolerates additive HTML-comment enrichment (ARCH-013, MOD-017)" {
    awk '
        /^## / { print; print "<!-- v-model: tdd_phase=red -->"; next }
        { print }
    ' "$TASKS_TEMPLATE" > "$TEST_TEMP_DIR/tasks.md"
    run bash "$SCHEMA_SCRIPT" "$TEST_TEMP_DIR/tasks.md" --tasks
    assert_success
}

@test "missing mode flag: exits non-zero (ARCH-013 §CLI invocation)" {
    run bash "$SCHEMA_SCRIPT" "$PLAN_TEMPLATE"
    assert_failure
}

@test "unknown mode flag: exits non-zero (REQ-029)" {
    run bash "$SCHEMA_SCRIPT" "$PLAN_TEMPLATE" --bogus
    assert_failure
}

@test "missing target file: exits non-zero with stderr diagnostic" {
    run bash "$SCHEMA_SCRIPT" "$TEST_TEMP_DIR/no-such.md" --plan
    assert_failure
}

# ---- MF-4: H2 ordering + wedge rejection ----

# Helper: build a fixture plan.md from the canonical H2 sequence in the
# pinned plan-template, so tests don't hard-code the canonical headings.
# Args: <output-file> <H2 lines, one per arg, in desired order>
build_plan_fixture() {
    local out="$1"; shift
    : > "$out"
    local h
    for h in "$@"; do
        printf '%s\n\nFiller body for %s.\n\n' "$h" "$h" >> "$out"
    done
}

@test "validate-core-schema rejects wrong H2 order in plan.md (MF-4 ORDER)" {
    # Canonical order is: Summary, Technical Context, Constitution Check,
    # Project Structure, Complexity Tracking. Swap CC and PS.
    build_plan_fixture "$TEST_TEMP_DIR/plan.md" \
        "## Summary" \
        "## Technical Context" \
        "## Project Structure" \
        "## Constitution Check" \
        "## Complexity Tracking"
    run bash -c "bash '$SCHEMA_SCRIPT' '$TEST_TEMP_DIR/plan.md' --plan 2>&1"
    assert_failure
    assert_output --partial "ORDER: FAIL"
    assert_output --partial "SCHEMA: FAIL"
}

@test "validate-core-schema rejects wedged non-canonical H2 in plan.md (MF-4 WEDGE)" {
    build_plan_fixture "$TEST_TEMP_DIR/plan.md" \
        "## Summary" \
        "## Technical Context" \
        "## Random Wedged Heading" \
        "## Constitution Check" \
        "## Project Structure" \
        "## Complexity Tracking"
    run bash -c "bash '$SCHEMA_SCRIPT' '$TEST_TEMP_DIR/plan.md' --plan 2>&1"
    assert_failure
    assert_output --partial "WEDGE: FAIL"
    assert_output --partial "Random Wedged Heading"
    assert_output --partial "SCHEMA: FAIL"
}

@test "validate-core-schema accepts trailing extra H2 after last canonical (MF-4)" {
    build_plan_fixture "$TEST_TEMP_DIR/plan.md" \
        "## Summary" \
        "## Technical Context" \
        "## Constitution Check" \
        "## Project Structure" \
        "## Complexity Tracking" \
        "## Appendix Notes"
    run bash "$SCHEMA_SCRIPT" "$TEST_TEMP_DIR/plan.md" --plan
    assert_success
    assert_output --partial "SCHEMA: PASS"
}

@test "validate-core-schema accepts preamble H2 before first canonical (MF-4)" {
    build_plan_fixture "$TEST_TEMP_DIR/plan.md" \
        "## Preamble Notes" \
        "## Summary" \
        "## Technical Context" \
        "## Constitution Check" \
        "## Project Structure" \
        "## Complexity Tracking"
    run bash "$SCHEMA_SCRIPT" "$TEST_TEMP_DIR/plan.md" --plan
    assert_success
    assert_output --partial "SCHEMA: PASS"
}
