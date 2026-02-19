#!/usr/bin/env bash
# Shared test helper for BATS tests

# Load bats libraries
BATS_LIB_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../bats/lib" && pwd)"
load "${BATS_LIB_DIR}/bats-support/load"
load "${BATS_LIB_DIR}/bats-assert/load"

# Project root (repo root)
PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/../.." && pwd)"

# Scripts under test
SCRIPTS_DIR="${PROJECT_ROOT}/scripts/bash"

# Fixtures directory
FIXTURES_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../fixtures" && pwd)"

# Create a temporary working directory for each test
setup_temp_dir() {
    TEST_TEMP_DIR="$(mktemp -d)"
    export TEST_TEMP_DIR
}

# Clean up the temporary directory
teardown_temp_dir() {
    if [[ -n "${TEST_TEMP_DIR:-}" && -d "$TEST_TEMP_DIR" ]]; then
        rm -rf "$TEST_TEMP_DIR"
    fi
}

# Initialize a git repo in the temp directory
init_git_repo() {
    local dir="${1:-$TEST_TEMP_DIR}"
    git -C "$dir" init --quiet
    git -C "$dir" config user.email "test@example.com"
    git -C "$dir" config user.name "Test"
    # Create initial commit so git diff works
    touch "$dir/.gitkeep"
    git -C "$dir" add .
    git -C "$dir" commit --quiet -m "Initial commit"
}

# Copy a fixture set into the temp directory
# Usage: copy_fixture "minimal" "$TEST_TEMP_DIR/specs/feature/v-model"
copy_fixture() {
    local fixture_name="$1"
    local dest_dir="$2"
    mkdir -p "$dest_dir"
    cp -r "${FIXTURES_DIR}/${fixture_name}/"* "$dest_dir/" 2>/dev/null || true
}

# Validate that output is valid JSON
assert_valid_json() {
    local output="$1"
    echo "$output" | python3 -m json.tool > /dev/null 2>&1
}

# Extract a JSON field value (simple top-level string/bool/number)
json_field() {
    local json="$1"
    local field="$2"
    echo "$json" | python3 -c "import json,sys; print(json.load(sys.stdin).get('$field',''))"
}
