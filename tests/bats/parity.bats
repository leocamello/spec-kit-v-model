load "test_helper"

# Cross-script parity: runs each fixture combo through both Bash and PowerShell,
# asserts identical JSON output. Requires pwsh to be available.

PARITY_VALIDATOR="${PROJECT_ROOT}/tests/validators/parity_validator.py"

# Skip all tests if pwsh is not installed
setup() {
    if ! command -v pwsh &>/dev/null; then
        skip "pwsh not available — parity tests require PowerShell"
    fi
}

# ============================================================
# Minimal fixture
# ============================================================

@test "parity: minimal downward REQ-001" {
    run python3 "$PARITY_VALIDATOR" "$PROJECT_ROOT" --combo minimal downward REQ-001 "tests/fixtures/minimal"
    assert_success
}

@test "parity: minimal upward MOD-001" {
    run python3 "$PARITY_VALIDATOR" "$PROJECT_ROOT" --combo minimal upward MOD-001 "tests/fixtures/minimal"
    assert_success
}

@test "parity: minimal full SYS-001" {
    run python3 "$PARITY_VALIDATOR" "$PROJECT_ROOT" --combo minimal full SYS-001 "tests/fixtures/minimal"
    assert_success
}

# ============================================================
# Complex fixture
# ============================================================

@test "parity: complex downward REQ-001" {
    run python3 "$PARITY_VALIDATOR" "$PROJECT_ROOT" --combo complex downward REQ-001 "tests/fixtures/complex"
    assert_success
}

@test "parity: complex upward MOD-006" {
    run python3 "$PARITY_VALIDATOR" "$PROJECT_ROOT" --combo complex upward MOD-006 "tests/fixtures/complex"
    assert_success
}

@test "parity: complex full SYS-003" {
    run python3 "$PARITY_VALIDATOR" "$PROJECT_ROOT" --combo complex full SYS-003 "tests/fixtures/complex"
    assert_success
}

# ============================================================
# Linear fixture
# ============================================================

@test "parity: linear downward REQ-001" {
    run python3 "$PARITY_VALIDATOR" "$PROJECT_ROOT" --combo linear downward REQ-001 "tests/fixtures/commands/impact-analysis/inputs/linear"
    assert_success
}

@test "parity: linear upward MOD-001" {
    run python3 "$PARITY_VALIDATOR" "$PROJECT_ROOT" --combo linear upward MOD-001 "tests/fixtures/commands/impact-analysis/inputs/linear"
    assert_success
}

@test "parity: linear full SYS-001" {
    run python3 "$PARITY_VALIDATOR" "$PROJECT_ROOT" --combo linear full SYS-001 "tests/fixtures/commands/impact-analysis/inputs/linear"
    assert_success
}

# ============================================================
# Diamond fixture
# ============================================================

@test "parity: diamond downward REQ-001" {
    run python3 "$PARITY_VALIDATOR" "$PROJECT_ROOT" --combo diamond downward REQ-001 "tests/fixtures/commands/impact-analysis/inputs/diamond"
    assert_success
}

@test "parity: diamond upward MOD-002" {
    run python3 "$PARITY_VALIDATOR" "$PROJECT_ROOT" --combo diamond upward MOD-002 "tests/fixtures/commands/impact-analysis/inputs/diamond"
    assert_success
}

@test "parity: diamond full ARCH-004" {
    run python3 "$PARITY_VALIDATOR" "$PROJECT_ROOT" --combo diamond full ARCH-004 "tests/fixtures/commands/impact-analysis/inputs/diamond"
    assert_success
}

# ============================================================
# Disconnected fixture
# ============================================================

@test "parity: disconnected downward REQ-001" {
    run python3 "$PARITY_VALIDATOR" "$PROJECT_ROOT" --combo disconnected downward REQ-001 "tests/fixtures/commands/impact-analysis/inputs/disconnected"
    assert_success
}

@test "parity: disconnected downward REQ-002" {
    run python3 "$PARITY_VALIDATOR" "$PROJECT_ROOT" --combo disconnected downward REQ-002 "tests/fixtures/commands/impact-analysis/inputs/disconnected"
    assert_success
}

@test "parity: disconnected upward MOD-001" {
    run python3 "$PARITY_VALIDATOR" "$PROJECT_ROOT" --combo disconnected upward MOD-001 "tests/fixtures/commands/impact-analysis/inputs/disconnected"
    assert_success
}

# ============================================================
# Gaps fixture
# ============================================================

@test "parity: gaps downward REQ-001" {
    run python3 "$PARITY_VALIDATOR" "$PROJECT_ROOT" --combo gaps downward REQ-001 "tests/fixtures/gaps"
    assert_success
}

@test "parity: gaps upward MOD-001" {
    run python3 "$PARITY_VALIDATOR" "$PROJECT_ROOT" --combo gaps upward MOD-001 "tests/fixtures/gaps"
    assert_success
}
