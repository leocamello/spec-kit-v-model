load "test_helper"

setup() {
    setup_temp_dir
}

teardown() {
    teardown_temp_dir
}

@test "all new when no git history" {
    mkdir -p "$TEST_TEMP_DIR/vmodel"
    cp "$FIXTURES_DIR/minimal/requirements.md" "$TEST_TEMP_DIR/vmodel/"
    cd "$TEST_TEMP_DIR"
    run bash "$SCRIPTS_DIR/diff-requirements.sh" "$TEST_TEMP_DIR/vmodel" --json
    assert_success
    echo "$output" | python3 -c "
import json, sys
data = json.load(sys.stdin)
added = data['added']
assert 'REQ-001' in added, 'REQ-001 not in added'
assert 'REQ-002' in added, 'REQ-002 not in added'
assert 'REQ-003' in added, 'REQ-003 not in added'
"
}

@test "detects added REQ" {
    init_git_repo "$TEST_TEMP_DIR"
    mkdir -p "$TEST_TEMP_DIR/vmodel"
    cp "$FIXTURES_DIR/minimal/requirements.md" "$TEST_TEMP_DIR/vmodel/"
    cd "$TEST_TEMP_DIR"
    git add .
    git commit --quiet -m "Add requirements"
    echo "| REQ-004 | New requirement | P1 |" >> "$TEST_TEMP_DIR/vmodel/requirements.md"
    run bash "$SCRIPTS_DIR/diff-requirements.sh" "$TEST_TEMP_DIR/vmodel" --json
    assert_success
    echo "$output" | python3 -c "
import json, sys
data = json.load(sys.stdin)
assert 'REQ-004' in data['added'], 'REQ-004 not in added'
"
}

@test "detects removed REQ" {
    init_git_repo "$TEST_TEMP_DIR"
    mkdir -p "$TEST_TEMP_DIR/vmodel"
    cp "$FIXTURES_DIR/minimal/requirements.md" "$TEST_TEMP_DIR/vmodel/"
    cd "$TEST_TEMP_DIR"
    git add .
    git commit --quiet -m "Add requirements"
    sed -i '/REQ-002/d' "$TEST_TEMP_DIR/vmodel/requirements.md"
    run bash "$SCRIPTS_DIR/diff-requirements.sh" "$TEST_TEMP_DIR/vmodel" --json
    assert_success
    echo "$output" | python3 -c "
import json, sys
data = json.load(sys.stdin)
assert 'REQ-002' in data['removed'], 'REQ-002 not in removed'
"
}

@test "detects modified REQ" {
    init_git_repo "$TEST_TEMP_DIR"
    mkdir -p "$TEST_TEMP_DIR/vmodel"
    cp "$FIXTURES_DIR/minimal/requirements.md" "$TEST_TEMP_DIR/vmodel/"
    cd "$TEST_TEMP_DIR"
    git add .
    git commit --quiet -m "Add requirements"
    sed -i 's/| REQ-001 | The system SHALL process sensor data |/| REQ-001 | The system SHALL process MODIFIED sensor data |/' "$TEST_TEMP_DIR/vmodel/requirements.md"
    run bash "$SCRIPTS_DIR/diff-requirements.sh" "$TEST_TEMP_DIR/vmodel" --json
    assert_success
    echo "$output" | python3 -c "
import json, sys
data = json.load(sys.stdin)
assert 'REQ-001' in data['modified'], 'REQ-001 not in modified'
"
}

@test "--json outputs valid JSON" {
    mkdir -p "$TEST_TEMP_DIR/vmodel"
    cp "$FIXTURES_DIR/minimal/requirements.md" "$TEST_TEMP_DIR/vmodel/"
    cd "$TEST_TEMP_DIR"
    run bash "$SCRIPTS_DIR/diff-requirements.sh" "$TEST_TEMP_DIR/vmodel" --json
    assert_success
    echo "$output" | python3 -m json.tool > /dev/null
}

@test "no changes detected" {
    init_git_repo "$TEST_TEMP_DIR"
    mkdir -p "$TEST_TEMP_DIR/vmodel"
    cp "$FIXTURES_DIR/minimal/requirements.md" "$TEST_TEMP_DIR/vmodel/"
    cd "$TEST_TEMP_DIR"
    git add .
    git commit --quiet -m "Add requirements"
    run bash "$SCRIPTS_DIR/diff-requirements.sh" "$TEST_TEMP_DIR/vmodel" --json
    assert_success
    local val
    val=$(echo "$output" | python3 -c "import json,sys; print(json.load(sys.stdin)['total_changed'])")
    [ "$val" = "0" ]
}
