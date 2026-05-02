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

# ---------------------------------------------------------------------------
# Step C.4 (MF-2): scope-aware flags --canonical / --scan / --changed-only.
# ---------------------------------------------------------------------------

@test "C.4 --scan flag scans the supplied directory tree (canonical IDs accepted)" {
    REPO_ROOT="$TEST_TEMP_DIR/repo"
    mkdir -p "$REPO_ROOT/specs/feat/v-model" "$REPO_ROOT/src"
    cp "$FIXTURES_DIR/v-model/complete/"*.md "$REPO_ROOT/specs/feat/v-model/"
    cat > "$REPO_ROOT/src/foo.py" <<'PY'
# Implements: REQ-001
print("ok")
PY
    run bash "$GUARD_SCRIPT" --canonical "$REPO_ROOT/specs/feat/v-model" --scan "$REPO_ROOT"
    assert_success
    last_line=$(printf '%s\n' "$output" | tail -n 1)
    [ "$last_line" = "GUARD: PASS" ]
}

@test "C.4 --scan rejects an unknown ID injected into src/" {
    REPO_ROOT="$TEST_TEMP_DIR/repo"
    mkdir -p "$REPO_ROOT/specs/feat/v-model" "$REPO_ROOT/src"
    cp "$FIXTURES_DIR/v-model/complete/"*.md "$REPO_ROOT/specs/feat/v-model/"
    fab="$(printf 'REQ-%s' 9 9 9 | tr -d ' ')"
    cat > "$REPO_ROOT/src/foo.py" <<EOF2
# Implements: ${fab}
print("nope")
EOF2
    run bash "$GUARD_SCRIPT" --canonical "$REPO_ROOT/specs/feat/v-model" --scan "$REPO_ROOT"
    assert_failure
    assert_output --partial "unknown id ${fab}"
    last_line=$(printf '%s\n' "$output" | tail -n 1)
    [ "$last_line" = "GUARD: FAIL" ]
}

@test "C.4 --changed-only restricts to git diff + untracked (committed clean baseline ignored)" {
    REPO_ROOT="$TEST_TEMP_DIR/repo"
    mkdir -p "$REPO_ROOT/specs/feat/v-model" "$REPO_ROOT/src"
    cp "$FIXTURES_DIR/v-model/complete/"*.md "$REPO_ROOT/specs/feat/v-model/"
    git -C "$REPO_ROOT" init --quiet
    git -C "$REPO_ROOT" config user.email t@t
    git -C "$REPO_ROOT" config user.name t
    fab="$(printf 'REQ-%s' 9 8 7 6 5 | tr -d ' ')"
    # Pre-existing committed file with a fabricated ID — must be IGNORED by
    # --changed-only since it's part of the clean baseline.
    cat > "$REPO_ROOT/src/old.py" <<EOF2
# Implements: ${fab}
print("old")
EOF2
    cat > "$REPO_ROOT/src/changed.py" <<'PY'
# Implements: REQ-001
print("changed-baseline")
PY
    git -C "$REPO_ROOT" add . >/dev/null
    git -C "$REPO_ROOT" commit --quiet -m baseline
    # Now modify changed.py and add an untracked new.py — both with valid IDs.
    cat > "$REPO_ROOT/src/changed.py" <<'PY'
# Implements: REQ-001
# Implements: SYS-001
print("changed-modified")
PY
    cat > "$REPO_ROOT/src/new.py" <<'PY'
# Implements: REQ-001
print("new")
PY
    run bash "$GUARD_SCRIPT" --canonical "$REPO_ROOT/specs/feat/v-model" --scan "$REPO_ROOT" --changed-only
    assert_success
    last_line=$(printf '%s\n' "$output" | tail -n 1)
    [ "$last_line" = "GUARD: PASS" ]
    # Without --changed-only, the bad committed file IS scanned and fails.
    run bash "$GUARD_SCRIPT" --canonical "$REPO_ROOT/specs/feat/v-model" --scan "$REPO_ROOT"
    assert_failure
    assert_output --partial "unknown id ${fab}"
}

@test "C.4 --changed-only outside git falls back gracefully" {
    REPO_ROOT="$TEST_TEMP_DIR/nogit"
    mkdir -p "$REPO_ROOT/specs/feat/v-model" "$REPO_ROOT/src"
    cp "$FIXTURES_DIR/v-model/complete/"*.md "$REPO_ROOT/specs/feat/v-model/"
    cat > "$REPO_ROOT/src/foo.py" <<'PY'
# Implements: REQ-001
print("ok")
PY
    run bash "$GUARD_SCRIPT" --canonical "$REPO_ROOT/specs/feat/v-model" --scan "$REPO_ROOT" --changed-only
    assert_success
    assert_output --partial "not a git working tree"
    last_line=$(printf '%s\n' "$output" | tail -n 1)
    [ "$last_line" = "GUARD: PASS" ]
}

@test "C.4 legacy positional invocation matches --canonical/--scan equivalents byte-for-byte" {
    # Reuse the standard fixture from setup() (FEATURE_DIR populated there).
    cat > "$SRC_DIR/widget.sh" <<'EOF2'
#!/bin/sh
# Implements REQ-001
# Implements SYS-001
echo ok
EOF2
    legacy_out="$(bash "$GUARD_SCRIPT" "$FEATURE_DIR" 2>&1)"
    legacy_rc=$?
    flag_out="$(bash "$GUARD_SCRIPT" --canonical "$FEATURE_DIR/v-model" --scan "$FEATURE_DIR" 2>&1)"
    flag_rc=$?
    [ "$legacy_rc" -eq "$flag_rc" ]
    [ "$legacy_out" = "$flag_out" ]
}

@test "C.4 --canonical without --scan or feature-dir fails with clear error" {
    run bash "$GUARD_SCRIPT" --canonical "$FEATURE_DIR/v-model"
    assert_failure
    assert_output --partial "--scan is required"
}
