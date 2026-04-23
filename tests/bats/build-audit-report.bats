load "test_helper"

AUDIT_SCRIPT="$SCRIPTS_DIR/build-audit-report.sh"
AR_FIXTURES="$FIXTURES_DIR/commands/audit-report"

# ============================================================
# Setup / Teardown
# ============================================================

setup() {
    setup_temp_dir
}

teardown() {
    teardown_temp_dir
}

# Helper: copy fixture into a git-initialised temp dir so git log works
setup_fixture() {
    local fixture_name="$1"
    local dest="$TEST_TEMP_DIR/v-model"
    # Init git repo first (commits only .gitkeep)
    init_git_repo "$TEST_TEMP_DIR"
    # Then copy fixture files and commit them separately
    mkdir -p "$dest"
    cp "$AR_FIXTURES/inputs/$fixture_name/"* "$dest/"
    git -C "$TEST_TEMP_DIR" add v-model
    git -C "$TEST_TEMP_DIR" commit --quiet -m "Add fixture"
}

# ============================================================
# Help flag
# ============================================================

@test "audit-report: --help exits 0" {
    run bash "$AUDIT_SCRIPT" --help
    assert_success
}

@test "audit-report: --help shows usage" {
    run bash "$AUDIT_SCRIPT" --help
    assert_success
    assert_output --partial "Usage:"
    assert_output --partial "--system-name"
    assert_output --partial "--json"
}

# ============================================================
# Argument validation
# ============================================================

@test "audit-report: missing directory argument exits 2" {
    run bash "$AUDIT_SCRIPT"
    assert_failure 2
    assert_output --partial "ERROR"
}

@test "audit-report: nonexistent directory exits 2" {
    run bash "$AUDIT_SCRIPT" /nonexistent/path
    assert_failure 2
    assert_output --partial "Directory not found"
}

@test "audit-report: missing requirements.md exits 2" {
    setup_fixture "missing-required"
    run bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model"
    assert_failure 2
    assert_output --partial "Required artifact missing"
    assert_output --partial "requirements.md"
}

@test "audit-report: unknown option exits 2" {
    run bash "$AUDIT_SCRIPT" --bogus-flag
    assert_failure 2
    assert_output --partial "Unknown option"
}

# ============================================================
# Clean scenario — RELEASE READY
# ============================================================

@test "audit-report: clean fixture exits 0" {
    setup_fixture "clean"
    run bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md"
    assert_success
}

@test "audit-report: clean fixture status is RELEASE READY" {
    setup_fixture "clean"
    run bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md"
    assert_success
    assert_output --partial "RELEASE READY"
}

@test "audit-report: clean fixture counts 12 tests all passed" {
    setup_fixture "clean"
    run bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md"
    assert_success
    assert_output --partial "Tests: 12"
    assert_output --partial "✅ 12"
}

@test "audit-report: clean fixture reports 0 anomalies" {
    setup_fixture "clean"
    run bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md"
    assert_success
    assert_output --partial "Anomalies: 0"
}

@test "audit-report: clean fixture reports 3 hazards" {
    setup_fixture "clean"
    run bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md"
    assert_success
    assert_output --partial "Hazards: 3"
}

@test "audit-report: clean fixture writes report file" {
    setup_fixture "clean"
    run bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md"
    assert_success
    [ -f "$TEST_TEMP_DIR/report.md" ]
}

# ============================================================
# Waived scenario — RELEASE CANDIDATE
# ============================================================

@test "audit-report: waived fixture exits 0" {
    setup_fixture "waived"
    run bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md"
    assert_success
}

@test "audit-report: waived fixture status is RELEASE CANDIDATE" {
    setup_fixture "waived"
    run bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md"
    assert_success
    assert_output --partial "RELEASE CANDIDATE"
}

@test "audit-report: waived fixture counts 2 skipped" {
    setup_fixture "waived"
    run bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md"
    assert_success
    assert_output --partial "⏭️ 2"
}

@test "audit-report: waived fixture reports 2 anomalies all waived" {
    setup_fixture "waived"
    run bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md"
    assert_success
    assert_output --partial "Anomalies: 2 (waived: 2, blocking: 0)"
}

# ============================================================
# Blocking scenario — NOT READY
# ============================================================

@test "audit-report: blocking fixture exits 1" {
    setup_fixture "blocking"
    run bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md"
    assert_failure 1
}

@test "audit-report: blocking fixture status is NOT READY" {
    setup_fixture "blocking"
    run bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md"
    assert_output --partial "NOT READY"
}

@test "audit-report: blocking fixture counts 1 failed" {
    setup_fixture "blocking"
    run bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md"
    assert_output --partial "❌ 1"
}

@test "audit-report: blocking fixture reports 1 blocking anomaly" {
    setup_fixture "blocking"
    run bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md"
    assert_output --partial "Anomalies: 1 (waived: 0, blocking: 1)"
}

@test "audit-report: blocking fixture still writes report file" {
    setup_fixture "blocking"
    run bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md"
    [ -f "$TEST_TEMP_DIR/report.md" ]
}

# ============================================================
# Orphaned waivers
# ============================================================

@test "audit-report: orphaned waiver exits 0 (no anomalies)" {
    setup_fixture "orphaned-waiver"
    run bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md"
    assert_success
}

@test "audit-report: orphaned waiver detected in summary" {
    setup_fixture "orphaned-waiver"
    run bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md"
    assert_success
    assert_output --partial "Orphaned waivers: 1"
}

@test "audit-report: orphaned waiver status still RELEASE READY" {
    setup_fixture "orphaned-waiver"
    run bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md"
    assert_success
    assert_output --partial "RELEASE READY"
}

# ============================================================
# CLI options — metadata
# ============================================================

@test "audit-report: --system-name appears in report" {
    setup_fixture "clean"
    bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --system-name "TestSystem" --output "$TEST_TEMP_DIR/report.md" 2>/dev/null
    run grep "TestSystem" "$TEST_TEMP_DIR/report.md"
    assert_success
}

@test "audit-report: --version appears in report" {
    setup_fixture "clean"
    bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --version "1.2.3" --output "$TEST_TEMP_DIR/report.md" 2>/dev/null
    run grep "1.2.3" "$TEST_TEMP_DIR/report.md"
    assert_success
}

@test "audit-report: --git-tag appears in report" {
    setup_fixture "clean"
    bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --git-tag "v1.2.3" --output "$TEST_TEMP_DIR/report.md" 2>/dev/null
    run grep "v1.2.3" "$TEST_TEMP_DIR/report.md"
    assert_success
}

@test "audit-report: --regulatory-context appears in report" {
    setup_fixture "clean"
    bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --regulatory-context "IEC 62304" --output "$TEST_TEMP_DIR/report.md" 2>/dev/null
    run grep "IEC 62304" "$TEST_TEMP_DIR/report.md"
    assert_success
}

@test "audit-report: default output path is release-audit-report.md" {
    setup_fixture "clean"
    bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" 2>/dev/null
    [ -f "$TEST_TEMP_DIR/v-model/release-audit-report.md" ]
}

# ============================================================
# Report structure — 7 sections
# ============================================================

@test "audit-report: report contains Section 1 Executive Summary" {
    setup_fixture "clean"
    bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md" 2>/dev/null
    run grep "## 1. Executive Summary" "$TEST_TEMP_DIR/report.md"
    assert_success
}

@test "audit-report: report contains Section 2 Artifact Inventory" {
    setup_fixture "clean"
    bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md" 2>/dev/null
    run grep "## 2. Artifact Inventory" "$TEST_TEMP_DIR/report.md"
    assert_success
}

@test "audit-report: report contains Section 3 Traceability Matrices" {
    setup_fixture "clean"
    bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md" 2>/dev/null
    run grep "## 3. Traceability Matrices" "$TEST_TEMP_DIR/report.md"
    assert_success
}

@test "audit-report: report contains Section 4 Coverage Analysis" {
    setup_fixture "clean"
    bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md" 2>/dev/null
    run grep "## 4. Coverage Analysis" "$TEST_TEMP_DIR/report.md"
    assert_success
}

@test "audit-report: report contains Section 5 Hazard Management Summary" {
    setup_fixture "clean"
    bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md" 2>/dev/null
    run grep "## 5. Hazard Management Summary" "$TEST_TEMP_DIR/report.md"
    assert_success
}

@test "audit-report: report contains Section 6 Known Anomalies" {
    setup_fixture "clean"
    bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md" 2>/dev/null
    run grep "## 6. Known Anomalies" "$TEST_TEMP_DIR/report.md"
    assert_success
}

@test "audit-report: report contains Section 7 Signature Block" {
    setup_fixture "clean"
    bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md" 2>/dev/null
    run grep "## 7. Signature" "$TEST_TEMP_DIR/report.md"
    assert_success
}

# ============================================================
# Artifact inventory
# ============================================================

@test "audit-report: inventory shows Present for requirements.md" {
    setup_fixture "clean"
    bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md" 2>/dev/null
    run grep -E "Requirements.*Present" "$TEST_TEMP_DIR/report.md"
    assert_success
}

@test "audit-report: inventory shows Missing for waivers.md" {
    setup_fixture "clean"
    bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md" 2>/dev/null
    run grep -E "Waivers.*Missing" "$TEST_TEMP_DIR/report.md"
    assert_success
}

@test "audit-report: inventory includes git SHA" {
    setup_fixture "clean"
    bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md" 2>/dev/null
    # SHA should be a 7+ char hex string in the Requirements row
    run grep -E "Requirements.+[0-9a-f]{7}" "$TEST_TEMP_DIR/report.md"
    assert_success
}

# ============================================================
# Hazard section
# ============================================================

@test "audit-report: clean report shows HAZ-001 in hazard section" {
    setup_fixture "clean"
    bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md" 2>/dev/null
    run grep "HAZ-001" "$TEST_TEMP_DIR/report.md"
    assert_success
}

@test "audit-report: clean report shows all 3 hazards mitigated" {
    setup_fixture "clean"
    bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md" 2>/dev/null
    run grep "All 3 hazards mitigated" "$TEST_TEMP_DIR/report.md"
    assert_success
}

@test "audit-report: blocking report shows no hazard analysis when absent" {
    # Use orphaned-waiver fixture (no hazard-analysis.md) in a custom path
    init_git_repo "$TEST_TEMP_DIR"
    mkdir -p "$TEST_TEMP_DIR/nohaz"
    cp "$AR_FIXTURES/inputs/orphaned-waiver/requirements.md" "$TEST_TEMP_DIR/nohaz/"
    cp "$AR_FIXTURES/inputs/orphaned-waiver/traceability-matrix.md" "$TEST_TEMP_DIR/nohaz/"
    git -C "$TEST_TEMP_DIR" add nohaz
    git -C "$TEST_TEMP_DIR" commit --quiet -m "Add fixture"
    bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/nohaz" --output "$TEST_TEMP_DIR/report.md" 2>/dev/null
    run grep "No hazard analysis was performed" "$TEST_TEMP_DIR/report.md"
    assert_success
}

# ============================================================
# Coverage analysis
# ============================================================

@test "audit-report: coverage table has 4 matrix rows for clean" {
    setup_fixture "clean"
    bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md" 2>/dev/null
    local count
    count=$(grep -cE "^\| Matrix [A-D]" "$TEST_TEMP_DIR/report.md" || true)
    [ "$count" -eq 4 ]
}

@test "audit-report: clean fixture shows 100% forward coverage" {
    setup_fixture "clean"
    bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md" 2>/dev/null
    # All matrices should show 100%
    run grep -E "Matrix A.*100%" "$TEST_TEMP_DIR/report.md"
    assert_success
}

# ============================================================
# Anomalies in report
# ============================================================

@test "audit-report: clean report says No anomalies detected" {
    setup_fixture "clean"
    bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md" 2>/dev/null
    run grep "No anomalies detected" "$TEST_TEMP_DIR/report.md"
    assert_success
}

@test "audit-report: waived report lists UTS-001-B1 as Waived" {
    setup_fixture "waived"
    bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md" 2>/dev/null
    run grep -E "UTS-001-B1.*Waived" "$TEST_TEMP_DIR/report.md"
    assert_success
}

@test "audit-report: waived report lists WAV-001 for UTS-001-B1" {
    setup_fixture "waived"
    bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md" 2>/dev/null
    run grep -E "UTS-001-B1.*WAV-001" "$TEST_TEMP_DIR/report.md"
    assert_success
}

@test "audit-report: blocking report lists SCN-002-A1 as BLOCKING" {
    setup_fixture "blocking"
    bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md" 2>/dev/null || true
    run grep -E "SCN-002-A1.*BLOCKING" "$TEST_TEMP_DIR/report.md"
    assert_success
}

@test "audit-report: orphaned waiver report shows orphaned section" {
    setup_fixture "orphaned-waiver"
    bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md" 2>/dev/null
    run grep "Orphaned Waivers" "$TEST_TEMP_DIR/report.md"
    assert_success
}

@test "audit-report: orphaned waiver report lists WAV-001 as orphaned" {
    setup_fixture "orphaned-waiver"
    bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md" 2>/dev/null
    run grep -E "WAV-001.*UTS-999-Z1" "$TEST_TEMP_DIR/report.md"
    assert_success
}

# ============================================================
# JSON output — structure
# ============================================================

@test "audit-report: --json outputs valid JSON" {
    setup_fixture "clean"
    run bash -c "bash \"$AUDIT_SCRIPT\" \"$TEST_TEMP_DIR/v-model\" --json 2>/dev/null"
    assert_success
    echo "$output" | python3 -m json.tool > /dev/null 2>&1
}

@test "audit-report: --json contains metadata" {
    setup_fixture "clean"
    run bash -c "bash \"$AUDIT_SCRIPT\" \"$TEST_TEMP_DIR/v-model\" --json --system-name \"TestSys\" 2>/dev/null"
    assert_success
    local sname
    sname=$(echo "$output" | python3 -c "import json,sys; print(json.load(sys.stdin)['metadata']['system_name'])")
    [ "$sname" = "TestSys" ]
}

@test "audit-report: --json contains compliance_status" {
    setup_fixture "clean"
    run bash -c "bash \"$AUDIT_SCRIPT\" \"$TEST_TEMP_DIR/v-model\" --json 2>/dev/null"
    assert_success
    local status
    status=$(echo "$output" | python3 -c "import json,sys; print(json.load(sys.stdin)['compliance_status'])")
    [[ "$status" == *"RELEASE READY"* ]]
}

@test "audit-report: --json contains exit_code" {
    setup_fixture "clean"
    run bash -c "bash \"$AUDIT_SCRIPT\" \"$TEST_TEMP_DIR/v-model\" --json 2>/dev/null"
    assert_success
    local code
    code=$(echo "$output" | python3 -c "import json,sys; print(json.load(sys.stdin)['exit_code'])")
    [ "$code" = "0" ]
}

@test "audit-report: --json contains artifact_inventory array" {
    setup_fixture "clean"
    run bash -c "bash \"$AUDIT_SCRIPT\" \"$TEST_TEMP_DIR/v-model\" --json 2>/dev/null"
    assert_success
    local count
    count=$(echo "$output" | python3 -c "import json,sys; print(len(json.load(sys.stdin)['artifact_inventory']))")
    [ "$count" = "11" ]
}

@test "audit-report: --json contains coverage_analysis array" {
    setup_fixture "clean"
    run bash -c "bash \"$AUDIT_SCRIPT\" \"$TEST_TEMP_DIR/v-model\" --json 2>/dev/null"
    assert_success
    local count
    count=$(echo "$output" | python3 -c "import json,sys; print(len(json.load(sys.stdin)['coverage_analysis']))")
    [ "$count" = "4" ]
}

@test "audit-report: --json contains summary totals" {
    setup_fixture "clean"
    run bash -c "bash \"$AUDIT_SCRIPT\" \"$TEST_TEMP_DIR/v-model\" --json 2>/dev/null"
    assert_success
    local total passed
    total=$(echo "$output" | python3 -c "import json,sys; print(json.load(sys.stdin)['summary']['total_tests'])")
    passed=$(echo "$output" | python3 -c "import json,sys; print(json.load(sys.stdin)['summary']['passed'])")
    [ "$total" = "12" ]
    [ "$passed" = "12" ]
}

# ============================================================
# JSON output — scenarios
# ============================================================

@test "audit-report: --json waived has 2 classified anomalies" {
    setup_fixture "waived"
    run bash -c "bash \"$AUDIT_SCRIPT\" \"$TEST_TEMP_DIR/v-model\" --json 2>/dev/null"
    assert_success
    local count
    count=$(echo "$output" | python3 -c "import json,sys; print(len(json.load(sys.stdin)['anomalies']['classified']))")
    [ "$count" = "2" ]
}

@test "audit-report: --json waived anomalies are Waived" {
    setup_fixture "waived"
    run bash -c "bash \"$AUDIT_SCRIPT\" \"$TEST_TEMP_DIR/v-model\" --json 2>/dev/null"
    assert_success
    local disp
    disp=$(echo "$output" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['anomalies']['classified'][0]['disposition'])")
    [ "$disp" = "Waived" ]
}

@test "audit-report: --json blocking exit_code is 1" {
    setup_fixture "blocking"
    run bash -c "bash \"$AUDIT_SCRIPT\" \"$TEST_TEMP_DIR/v-model\" --json 2>/dev/null"
    local code
    code=$(echo "$output" | python3 -c "import json,sys; print(json.load(sys.stdin)['exit_code'])")
    [ "$code" = "1" ]
}

@test "audit-report: --json blocking has BLOCKING disposition" {
    setup_fixture "blocking"
    run bash -c "bash \"$AUDIT_SCRIPT\" \"$TEST_TEMP_DIR/v-model\" --json 2>/dev/null"
    local disp
    disp=$(echo "$output" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['anomalies']['classified'][0]['disposition'])")
    [ "$disp" = "BLOCKING" ]
}

@test "audit-report: --json orphaned waiver listed" {
    setup_fixture "orphaned-waiver"
    run bash -c "bash \"$AUDIT_SCRIPT\" \"$TEST_TEMP_DIR/v-model\" --json 2>/dev/null"
    assert_success
    local count
    count=$(echo "$output" | python3 -c "import json,sys; print(len(json.load(sys.stdin)['anomalies']['orphaned_waivers']))")
    [ "$count" = "1" ]
}

@test "audit-report: --json orphaned waiver has correct artifact_id" {
    setup_fixture "orphaned-waiver"
    run bash -c "bash \"$AUDIT_SCRIPT\" \"$TEST_TEMP_DIR/v-model\" --json 2>/dev/null"
    assert_success
    local aid
    aid=$(echo "$output" | python3 -c "import json,sys; print(json.load(sys.stdin)['anomalies']['orphaned_waivers'][0]['artifact_id'])")
    [ "$aid" = "UTS-999-Z1" ]
}

@test "audit-report: --json hazard_summary contains 3 entries for clean" {
    setup_fixture "clean"
    run bash -c "bash \"$AUDIT_SCRIPT\" \"$TEST_TEMP_DIR/v-model\" --json 2>/dev/null"
    assert_success
    local count
    count=$(echo "$output" | python3 -c "import json,sys; print(len(json.load(sys.stdin)['hazard_summary']))")
    [ "$count" = "3" ]
}

# ============================================================
# Matrices embedded
# ============================================================

@test "audit-report: report embeds Matrix A heading" {
    setup_fixture "clean"
    bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md" 2>/dev/null
    run grep "Matrix A" "$TEST_TEMP_DIR/report.md"
    assert_success
}

@test "audit-report: report embeds Matrix D heading" {
    setup_fixture "clean"
    bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md" 2>/dev/null
    run grep "Matrix D" "$TEST_TEMP_DIR/report.md"
    assert_success
}

@test "audit-report: embedded matrix contains SCN-001-A1" {
    setup_fixture "clean"
    bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md" 2>/dev/null
    run grep "SCN-001-A1" "$TEST_TEMP_DIR/report.md"
    assert_success
}

# ============================================================
# Signature block
# ============================================================

@test "audit-report: signature block has QA Manager row" {
    setup_fixture "clean"
    bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md" 2>/dev/null
    run grep "QA Manager" "$TEST_TEMP_DIR/report.md"
    assert_success
}

@test "audit-report: signature block has Lead Engineer row" {
    setup_fixture "clean"
    bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --output "$TEST_TEMP_DIR/report.md" 2>/dev/null
    run grep "Lead Engineer" "$TEST_TEMP_DIR/report.md"
    assert_success
}

@test "audit-report: signature block has Release Tag row" {
    setup_fixture "clean"
    bash "$AUDIT_SCRIPT" "$TEST_TEMP_DIR/v-model" --git-tag "v9.9.9" --output "$TEST_TEMP_DIR/report.md" 2>/dev/null
    run grep -E "Release Tag.*v9.9.9" "$TEST_TEMP_DIR/report.md"
    assert_success
}
