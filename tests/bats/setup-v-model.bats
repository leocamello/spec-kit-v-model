load "test_helper"

setup() {
    setup_temp_dir
}

teardown() {
    teardown_temp_dir
}

@test "creates v-model directory" {
    init_git_repo "$TEST_TEMP_DIR"
    cd "$TEST_TEMP_DIR"
    git checkout -b 001-test --quiet
    run bash "$SCRIPTS_DIR/setup-v-model.sh"
    assert_success
    [ -d "$TEST_TEMP_DIR/specs/001-test/v-model" ]
}

@test "detects existing requirements.md" {
    init_git_repo "$TEST_TEMP_DIR"
    cd "$TEST_TEMP_DIR"
    git checkout -b 001-test --quiet
    mkdir -p "$TEST_TEMP_DIR/specs/001-test/v-model"
    touch "$TEST_TEMP_DIR/specs/001-test/v-model/requirements.md"
    run bash "$SCRIPTS_DIR/setup-v-model.sh" --json
    assert_success
    assert_output --partial '"requirements.md"'
}

@test "--require-reqs fails when missing" {
    init_git_repo "$TEST_TEMP_DIR"
    cd "$TEST_TEMP_DIR"
    git checkout -b 001-test --quiet
    mkdir -p "$TEST_TEMP_DIR/specs/001-test/v-model"
    run bash "$SCRIPTS_DIR/setup-v-model.sh" --require-reqs
    assert_failure
}

@test "--require-acceptance fails when missing" {
    init_git_repo "$TEST_TEMP_DIR"
    cd "$TEST_TEMP_DIR"
    git checkout -b 001-test --quiet
    mkdir -p "$TEST_TEMP_DIR/specs/001-test/v-model"
    touch "$TEST_TEMP_DIR/specs/001-test/v-model/requirements.md"
    run bash "$SCRIPTS_DIR/setup-v-model.sh" --require-acceptance
    assert_failure
}

@test "--require-system-test fails when missing" {
    init_git_repo "$TEST_TEMP_DIR"
    cd "$TEST_TEMP_DIR"
    git checkout -b 001-test --quiet
    mkdir -p "$TEST_TEMP_DIR/specs/001-test/v-model"
    run bash "$SCRIPTS_DIR/setup-v-model.sh" --require-system-test
    assert_failure
}

@test "--require-architecture-design fails when missing" {
    init_git_repo "$TEST_TEMP_DIR"
    cd "$TEST_TEMP_DIR"
    git checkout -b 001-test --quiet
    mkdir -p "$TEST_TEMP_DIR/specs/001-test/v-model"
    run bash "$SCRIPTS_DIR/setup-v-model.sh" --require-architecture-design
    assert_failure
}

@test "--require-integration-test fails when missing" {
    init_git_repo "$TEST_TEMP_DIR"
    cd "$TEST_TEMP_DIR"
    git checkout -b 001-test --quiet
    mkdir -p "$TEST_TEMP_DIR/specs/001-test/v-model"
    run bash "$SCRIPTS_DIR/setup-v-model.sh" --require-integration-test
    assert_failure
}

@test "--require-module-design fails when missing" {
    init_git_repo "$TEST_TEMP_DIR"
    cd "$TEST_TEMP_DIR"
    git checkout -b 001-test --quiet
    mkdir -p "$TEST_TEMP_DIR/specs/001-test/v-model"
    run bash "$SCRIPTS_DIR/setup-v-model.sh" --require-module-design
    assert_failure
}

@test "--require-unit-test fails when missing" {
    init_git_repo "$TEST_TEMP_DIR"
    cd "$TEST_TEMP_DIR"
    git checkout -b 001-test --quiet
    mkdir -p "$TEST_TEMP_DIR/specs/001-test/v-model"
    run bash "$SCRIPTS_DIR/setup-v-model.sh" --require-unit-test
    assert_failure
}

@test "detects existing module-design.md" {
    init_git_repo "$TEST_TEMP_DIR"
    cd "$TEST_TEMP_DIR"
    git checkout -b 001-test --quiet
    mkdir -p "$TEST_TEMP_DIR/specs/001-test/v-model"
    touch "$TEST_TEMP_DIR/specs/001-test/v-model/module-design.md"
    run bash "$SCRIPTS_DIR/setup-v-model.sh" --json
    assert_success
    assert_output --partial '"module-design.md"'
}

@test "detects existing unit-test.md" {
    init_git_repo "$TEST_TEMP_DIR"
    cd "$TEST_TEMP_DIR"
    git checkout -b 001-test --quiet
    mkdir -p "$TEST_TEMP_DIR/specs/001-test/v-model"
    touch "$TEST_TEMP_DIR/specs/001-test/v-model/unit-test.md"
    run bash "$SCRIPTS_DIR/setup-v-model.sh" --json
    assert_success
    assert_output --partial '"unit-test.md"'
}

@test "--json outputs valid JSON" {
    init_git_repo "$TEST_TEMP_DIR"
    cd "$TEST_TEMP_DIR"
    git checkout -b 001-test --quiet
    run bash "$SCRIPTS_DIR/setup-v-model.sh" --json
    assert_success
    echo "$output" | python3 -m json.tool > /dev/null
}

@test "works outside git repo" {
    cd "$TEST_TEMP_DIR"
    run bash "$SCRIPTS_DIR/setup-v-model.sh"
    assert_success
}

@test "--help shows usage" {
    run bash "$SCRIPTS_DIR/setup-v-model.sh" --help
    assert_success
    assert_output --partial "Usage"
}
