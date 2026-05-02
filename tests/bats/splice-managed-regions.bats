# Implements: REQ-022, REQ-NF-005, SYS-007, SYS-015, ARCH-010, MOD-014, UTP-014-A, UTP-014-B, ATP-018-A, SCN-018-A1, HAZ-008, HAZ-014, HAZ-023, HAZ-025, D-005, D-015, D-016
#
# RED suite for the source-region splicer
# (`scripts/bash/splice-managed-regions.sh`). Script does not yet exist;
# every test below is expected to FAIL or ERROR until Phase 3 / T010 lands.
#
# Per ARCH-010, the splicer writes the spliced content to STDOUT; the caller
# performs the atomic `mktemp -p $(dirname …); … ; mv` write (D-016). We
# therefore exercise both surfaces: (a) splicer stdout correctness and
# (b) the documented atomic-rename idiom from a wrapper.

load "test_helper"

SPLICER_SCRIPT="${SCRIPTS_DIR}/splice-managed-regions.sh"

setup() {
    [ -x "$SPLICER_SCRIPT" ] || { echo "RED: $SPLICER_SCRIPT not yet implemented (T010 pending)" >&2; return 1; }
    setup_temp_dir
    TARGET="$TEST_TEMP_DIR/widget.sh"
    GENERATED="$TEST_TEMP_DIR/generated.txt"
}

teardown() {
    teardown_temp_dir
}

write_target_with_envelope() {
    cat > "$TARGET" <<'EOF'
#!/bin/sh
# user header — must survive splice (ATP-018-A)
echo "user prologue"

# BEGIN MANAGED id="MOD-005"
echo "OLD GENERATED CONTENT"
# END MANAGED id="MOD-005"

echo "user epilogue"
EOF
}

write_generated() {
    cat > "$GENERATED" <<'EOF'
echo "FRESH GENERATED CONTENT"
EOF
}

@test "managed region replaced; user prologue + epilogue preserved (UTP-014-A, ATP-018-A)" {
    write_target_with_envelope
    write_generated
    run bash "$SPLICER_SCRIPT" "$TARGET" "$GENERATED" bash
    assert_success
    assert_output --partial "user prologue"
    assert_output --partial "user epilogue"
    assert_output --partial "FRESH GENERATED CONTENT"
    refute_output --partial "OLD GENERATED CONTENT"
}

@test "sentinels themselves preserved verbatim (D-015)" {
    write_target_with_envelope
    write_generated
    run bash "$SPLICER_SCRIPT" "$TARGET" "$GENERATED" bash
    assert_success
    assert_output --partial 'BEGIN MANAGED id="MOD-005"'
    assert_output --partial 'END MANAGED id="MOD-005"'
}

@test "idempotent re-run: second splice with same input is byte-identical (REQ-022, SCN-018-A1)" {
    write_target_with_envelope
    write_generated
    run bash "$SPLICER_SCRIPT" "$TARGET" "$GENERATED" bash
    assert_success
    first="$output"
    # Apply the first splice result to the target then splice again with the
    # same generated content; result must be unchanged.
    printf '%s\n' "$first" > "$TARGET"
    run bash "$SPLICER_SCRIPT" "$TARGET" "$GENERATED" bash
    assert_success
    [ "$output" = "$first" ]
}

@test "unbalanced markers (BEGIN without END) → exit non-zero, original untouched (HAZ-014, UTP-014-B)" {
    cat > "$TARGET" <<'EOF'
#!/bin/sh
# BEGIN MANAGED id="MOD-005"
echo "dangling"
EOF
    write_generated
    pre=$(cat "$TARGET")
    run bash "$SPLICER_SCRIPT" "$TARGET" "$GENERATED" bash
    assert_failure
    post=$(cat "$TARGET")
    [ "$pre" = "$post" ]
}

@test "overlapping markers (BEGIN inside BEGIN) → exit non-zero (HAZ-008, ARCH-010 §Error paths)" {
    cat > "$TARGET" <<'EOF'
#!/bin/sh
# BEGIN MANAGED id="MOD-005"
# BEGIN MANAGED id="MOD-006"
echo "nested"
# END MANAGED id="MOD-006"
# END MANAGED id="MOD-005"
EOF
    write_generated
    run bash "$SPLICER_SCRIPT" "$TARGET" "$GENERATED" bash
    assert_failure
}

@test "atomic-rename idiom (D-016): mktemp -p \$(dirname …) + mv leaves no partial-write leftovers (SYS-015, REQ-NF-005)" {
    write_target_with_envelope
    write_generated
    target_dir=$(dirname "$TARGET")
    # Caller-side idiom from ARCH-010 §Side-effects:
    tmp=$(mktemp -p "$target_dir")
    bash "$SPLICER_SCRIPT" "$TARGET" "$GENERATED" bash > "$tmp"
    mv "$tmp" "$TARGET"
    # No tmp.* leftovers in target dir.
    leftovers=$(find "$target_dir" -maxdepth 1 -name 'tmp.*' -o -name "$(basename "$TARGET").*" | wc -l)
    [ "$leftovers" -eq 0 ]
    assert_file_contains "$TARGET" "FRESH GENERATED CONTENT"
}

# Tiny local helper (no test_helper.bash bloat).
assert_file_contains() {
    grep -F -q "$2" "$1"
}

@test "sentinel-free target: splicer treats input as no-op envelope (HAZ-025, REQ-CN-003)" {
    cat > "$TARGET" <<'EOF'
#!/bin/sh
echo "no envelope here"
EOF
    write_generated
    run bash "$SPLICER_SCRIPT" "$TARGET" "$GENERATED" bash
    # Either exits 0 with original on stdout (no-op) OR exits non-zero refusing
    # to write — but MUST NOT silently overwrite user content. Per D-005 we
    # require explicit envelope.
    if [ "$status" -eq 0 ]; then
        assert_output --partial "no envelope here"
        refute_output --partial "FRESH GENERATED CONTENT"
    fi
}

@test "language=python uses '# BEGIN MANAGED' marker syntax (D-015, MOD-014)" {
    cat > "$TARGET" <<'EOF'
#!/usr/bin/env python3
# user prologue
# BEGIN MANAGED id="MOD-005"
print("old")
# END MANAGED id="MOD-005"
# user epilogue
EOF
    write_generated
    run bash "$SPLICER_SCRIPT" "$TARGET" "$GENERATED" python
    assert_success
    assert_output --partial "user prologue"
    assert_output --partial "user epilogue"
    assert_output --partial "FRESH GENERATED CONTENT"
}
