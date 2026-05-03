#!/usr/bin/env bats
# Implements: REQ-001, REQ-027, ARCH-014, MOD-021, D-001, D-010
#
# BATS suite for the setup-plan.sh bridge wrapper. The wrapper forwards to
# the upstream .specify/scripts/bash/setup-plan.sh (provided by spec-kit-core)
# and augments its JSON with a top-level VMODEL_DIR field.
#
# Tests inject a stub upstream via SPECIFY_REPO_ROOT to remain isolated from
# whatever .specify state happens to exist on the host.

load "test_helper"

WRAPPER="${SCRIPTS_DIR}/setup-plan.sh"

setup() {
    [ -x "$WRAPPER" ] || { echo "missing wrapper: $WRAPPER" >&2; return 1; }
    setup_temp_dir
    STUB_REPO="$TEST_TEMP_DIR/repo"
    FEATURE_DIR="$STUB_REPO/specs/007-feature"
    mkdir -p "$STUB_REPO/.specify/scripts/bash"
    mkdir -p "$FEATURE_DIR"
    export SPECIFY_REPO_ROOT="$STUB_REPO"
}

teardown() {
    unset SPECIFY_REPO_ROOT || true
    teardown_temp_dir
}

# Write a stub upstream that emits canonical JSON and optionally exits with rc.
write_stub() {
    local rc="${1:-0}"
    cat > "$STUB_REPO/.specify/scripts/bash/setup-plan.sh" <<EOF
#!/usr/bin/env bash
echo '{"FEATURE_SPEC":"$FEATURE_DIR/spec.md","IMPL_PLAN":"$FEATURE_DIR/plan.md","SPECS_DIR":"$FEATURE_DIR","BRANCH":"007","HAS_GIT":"true"}'
exit $rc
EOF
    chmod +x "$STUB_REPO/.specify/scripts/bash/setup-plan.sh"
}

@test "JSON output is well-formed and contains VMODEL_DIR key" {
    write_stub 0
    mkdir -p "$FEATURE_DIR/v-model"
    run "$WRAPPER" --json
    assert_success
    assert_output --partial '"VMODEL_DIR"'
    echo "$output" | python3 -c 'import json,sys; json.loads(sys.stdin.read())'
}

@test "VMODEL_DIR is null when v-model directory absent" {
    write_stub 0
    run "$WRAPPER" --json
    assert_success
    assert_output --partial '"VMODEL_DIR":null'
}

@test "VMODEL_DIR points at <feature>/v-model when present" {
    write_stub 0
    mkdir -p "$FEATURE_DIR/v-model"
    run "$WRAPPER" --json
    assert_success
    assert_output --partial "\"VMODEL_DIR\":\"$FEATURE_DIR/v-model\""
}

@test "Wrapper exits 2 with stderr message when upstream missing" {
    # No stub written → upstream absent.
    run "$WRAPPER" --json
    assert_failure 2
    assert_output --partial 'upstream'
}

@test "Non-zero upstream exit code is propagated" {
    write_stub 7
    run "$WRAPPER" --json
    assert_failure 7
}
