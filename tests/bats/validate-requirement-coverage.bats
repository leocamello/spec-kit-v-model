load "test_helper"

@test "full coverage exits 0" {
    run bash "$SCRIPTS_DIR/validate-requirement-coverage.sh" "$FIXTURES_DIR/minimal"
    assert_success
}

@test "full coverage JSON shows has_gaps false" {
    run bash "$SCRIPTS_DIR/validate-requirement-coverage.sh" --json "$FIXTURES_DIR/minimal"
    assert_success
    local val
    val=$(echo "$output" | python3 -c "import json,sys; print(json.load(sys.stdin)['has_gaps'])")
    [ "$val" = "False" ]
}

@test "missing ATP exits 1" {
    run bash "$SCRIPTS_DIR/validate-requirement-coverage.sh" "$FIXTURES_DIR/gaps"
    assert_failure
}

@test "missing ATP identifies REQ-NF-001" {
    run bash "$SCRIPTS_DIR/validate-requirement-coverage.sh" --json "$FIXTURES_DIR/gaps"
    assert_failure
    echo "$output" | python3 -c "
import json, sys
data = json.load(sys.stdin)
assert 'REQ-NF-001' in data['reqs_without_atp'], 'REQ-NF-001 not in reqs_without_atp'
"
}

@test "category-prefixed IDs matched correctly" {
    run bash "$SCRIPTS_DIR/validate-requirement-coverage.sh" --json "$FIXTURES_DIR/complex"
    local val
    val=$(echo "$output" | python3 -c "import json,sys; print(json.load(sys.stdin)['total_reqs'])")
    [ "$val" = "10" ]
}

@test "orphaned ATPs detected" {
    run bash "$SCRIPTS_DIR/validate-requirement-coverage.sh" --json "$FIXTURES_DIR/complex"
    echo "$output" | python3 -c "
import json, sys
data = json.load(sys.stdin)
assert 'ATP-999-A' in data['orphaned_atps'], 'ATP-999-A not in orphaned_atps'
"
}

@test "empty files handled" {
    run bash "$SCRIPTS_DIR/validate-requirement-coverage.sh" --json "$FIXTURES_DIR/empty"
    assert_success
    local val
    val=$(echo "$output" | python3 -c "import json,sys; print(json.load(sys.stdin)['total_reqs'])")
    [ "$val" = "0" ]
}

@test "--json outputs valid JSON" {
    run bash "$SCRIPTS_DIR/validate-requirement-coverage.sh" --json "$FIXTURES_DIR/minimal"
    assert_success
    echo "$output" | python3 -m json.tool > /dev/null
}
