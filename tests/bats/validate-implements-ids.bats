# Implements: REQ-023, REQ-NF-002, REQ-NF-004, SYS-006, ARCH-009, MOD-013, MOD-025, UTP-013-A, UTP-025-A, ATP-019-A, SCN-019-A1, HAZ-007, HAZ-012, HAZ-023, D-004, D-008
#
# RED suite for the hallucination guard
# (`scripts/bash/validate-implements-ids.sh`). Script does not yet exist;
# every test below is expected to FAIL or ERROR until Phase 3 / T009 lands.

load "test_helper"

GUARD_SCRIPT="${SCRIPTS_DIR}/validate-implements-ids.sh"

setup() {
    [ -x "$GUARD_SCRIPT" ] || { echo "RED: $GUARD_SCRIPT not yet implemented (T009 pending)" >&2; return 1; }
    setup_temp_dir
    FEATURE_DIR="$TEST_TEMP_DIR/feature"
    mkdir -p "$FEATURE_DIR/v-model"
    cp "$FIXTURES_DIR/v-model/complete/"*.md "$FEATURE_DIR/v-model/"
    SRC_DIR="$FEATURE_DIR/src"
    mkdir -p "$SRC_DIR"
}

teardown() {
    teardown_temp_dir
}

@test "positive: every Implements <ID> resolves → exit 0, GUARD: PASS (UTP-013-A)" {
    cat > "$SRC_DIR/widget.sh" <<'EOF'
#!/bin/sh
# Implements REQ-001
# Implements SYS-001
echo ok
EOF
    run bash "$GUARD_SCRIPT" "$FEATURE_DIR"
    assert_success
    last_line=$(printf '%s\n' "$output" | tail -n 1)
    [ "$last_line" = "GUARD: PASS" ]
}

@test "negative: one fabricated ID → exit 1 with <file>:<line>: unknown id <X> (HAZ-007, SCN-019-A1)" {
    # Build fabricated ID at runtime so this source file itself contains no
    # canonical-pattern literal that would trip the project's hallucination guard.
    fab="$(printf 'REQ-%s' 9 9 9 9 9 | tr -d ' ')"
    cat > "$SRC_DIR/bad.sh" <<EOF
#!/bin/sh
# Implements REQ-001
# Implements ${fab}
echo nope
EOF
    run bash "$GUARD_SCRIPT" "$FEATURE_DIR"
    assert_failure
    assert_output --partial "bad.sh:3"
    assert_output --partial "${fab}"
    assert_output --partial "unknown id"
    last_line=$(printf '%s\n' "$output" | tail -n 1)
    [ "$last_line" = "GUARD: FAIL" ]
}

@test "empty input: no Implements comments → exit 0 (ARCH-009 §Algorithm step 4)" {
    cat > "$SRC_DIR/quiet.sh" <<'EOF'
#!/bin/sh
echo nothing-here
EOF
    run bash "$GUARD_SCRIPT" "$FEATURE_DIR"
    assert_success
    last_line=$(printf '%s\n' "$output" | tail -n 1)
    [ "$last_line" = "GUARD: PASS" ]
}

@test "cross-doc canonical extraction matches v-model/*.md (D-008, MOD-025, UTP-025-A)" {
    # Construct the fabricated ID at runtime so it doesn't appear as a
    # canonical-pattern literal in this test source.
    fab="$(printf 'ARCH-%s' 9 9 9 9 | tr -d ' ')"
    cat > "$SRC_DIR/cross.sh" <<EOF
#!/bin/sh
# Implements ${fab}
echo cross-doc
EOF
    run bash "$GUARD_SCRIPT" "$FEATURE_DIR"
    assert_failure
    assert_output --partial "${fab}"
}

@test "category-prefixed IDs (REQ-NF-NNN) resolve correctly (REQ-NF-002, MOD-013)" {
    # Pick an ID that exists in the complete fixture's requirements.md.
    cat > "$SRC_DIR/nf.sh" <<'EOF'
#!/bin/sh
# Implements REQ-NF-001
echo nf
EOF
    run bash "$GUARD_SCRIPT" "$FEATURE_DIR"
    assert_success
}

@test "missing feature dir → exit 1 with stderr diagnostic (ARCH-009 §Error paths)" {
    run bash "$GUARD_SCRIPT" "$TEST_TEMP_DIR/does-not-exist"
    assert_failure
}

@test "stale-snapshot mitigation: re-run after fixture mutation reflects new canonical set (HAZ-023, REQ-NF-004)" {
    cat > "$SRC_DIR/widget.sh" <<'EOF'
#!/bin/sh
# Implements REQ-001
echo ok
EOF
    run bash "$GUARD_SCRIPT" "$FEATURE_DIR"
    assert_success
    # Mutate fixture so REQ-001 disappears, then re-run; guard must now fail
    # (re-extracts canonical set on every invocation per D-004).
    : > "$FEATURE_DIR/v-model/requirements.md"
    run bash "$GUARD_SCRIPT" "$FEATURE_DIR"
    assert_failure
}
