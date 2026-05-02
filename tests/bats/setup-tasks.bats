#!/usr/bin/env bats
# Implements: REQ-011, REQ-027, ARCH-014, MOD-021, D-001, D-011
#
# BATS suite for the setup-tasks.sh bridge wrapper. Forwards to upstream
# .specify/scripts/bash/check-prerequisites.sh and augments with VMODEL_DIR.

load "test_helper"

WRAPPER="${SCRIPTS_DIR}/setup-tasks.sh"

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

write_stub() {
    local rc="${1:-0}"
    cat > "$STUB_REPO/.specify/scripts/bash/check-prerequisites.sh" <<EOF
#!/usr/bin/env bash
echo '{"FEATURE_DIR":"$FEATURE_DIR","AVAILABLE_DOCS":["research.md"]}'
exit $rc
EOF
    chmod +x "$STUB_REPO/.specify/scripts/bash/check-prerequisites.sh"
}

@test "JSON output is well-formed and contains VMODEL_DIR key" {
    write_stub 0
    mkdir -p "$FEATURE_DIR/v-model"
    run "$WRAPPER" --json --require-tasks --include-tasks
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
    run "$WRAPPER" --json
    assert_failure 2
    assert_output --partial 'upstream'
}

@test "Non-zero upstream exit code is propagated" {
    write_stub 7
    run "$WRAPPER" --json
    assert_failure 7
}
