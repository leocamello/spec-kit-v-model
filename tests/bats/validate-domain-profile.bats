# Implements: REQ-024, SYS-008, ARCH-011, MOD-015, HAZ-015, HAZ-024, D-003
#
# BATS suite for `scripts/bash/validate-domain-profile.sh` (MF-7 — domain-overlay gate).

load "test_helper"

SCRIPT="${SCRIPTS_DIR}/validate-domain-profile.sh"

setup() {
    setup_temp_dir
    REPO_ROOT="$TEST_TEMP_DIR/repo"
    mkdir -p "$REPO_ROOT/commands/overlays/iso_26262"
    mkdir -p "$REPO_ROOT/commands/overlays/do_178c"
    mkdir -p "$REPO_ROOT/commands/overlays/iec_62304"
}

teardown() {
    teardown_temp_dir
}

@test "absent v-model-config.yml → exit 0 with 'DOMAIN: SKIP' (MOD-015)" {
    run "$SCRIPT" "$REPO_ROOT"
    assert_success
    assert_output --partial "DOMAIN: SKIP"
}

@test "valid domain iso_26262 → exit 0 with PASS line (REQ-024, ARCH-011)" {
    echo "domain: iso_26262" > "$REPO_ROOT/v-model-config.yml"
    run "$SCRIPT" "$REPO_ROOT"
    assert_success
    [ "$output" = "DOMAIN: PASS (domain=iso_26262)" ]
}

@test "valid domain do_178c with comment → exit 0" {
    printf 'domain: do_178c   # trailing inline comment\n' > "$REPO_ROOT/v-model-config.yml"
    run "$SCRIPT" "$REPO_ROOT"
    assert_success
    [ "$output" = "DOMAIN: PASS (domain=do_178c)" ]
}

@test "invalid domain foo → exit 1 + stderr names invalid value (SYS-008)" {
    echo "domain: foo" > "$REPO_ROOT/v-model-config.yml"
    run "$SCRIPT" "$REPO_ROOT"
    assert_failure
    assert_output --partial "invalid domain"
    assert_output --partial "foo"
}

@test "missing 'domain:' key → exit 1 (HAZ-024)" {
    printf '# some comment\nother_key: value\n' > "$REPO_ROOT/v-model-config.yml"
    run "$SCRIPT" "$REPO_ROOT"
    assert_failure
    assert_output --partial "missing key 'domain:'"
}

@test "valid domain but overlay dir missing → exit 1 (HAZ-015)" {
    rm -rf "$REPO_ROOT/commands/overlays/iec_62304"
    echo "domain: iec_62304" > "$REPO_ROOT/v-model-config.yml"
    run "$SCRIPT" "$REPO_ROOT"
    assert_failure
    assert_output --partial "overlay directory not found"
}

@test "--help → exit 0" {
    run "$SCRIPT" --help
    assert_success
}
