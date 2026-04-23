load "test_helper"

# Helper: run impact-analysis and extract JSON field
impact_json_field() {
    local field="$1"
    echo "$output" | python3 -c "import json,sys; print(json.load(sys.stdin).get('$field',''))"
}

# Helper: extract blast_radius.total from JSON output
impact_blast_total() {
    echo "$output" | python3 -c "import json,sys; print(json.load(sys.stdin)['blast_radius']['total'])"
}

# Helper: extract suspect level count
impact_level_count() {
    local level="$1"
    echo "$output" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['blast_radius']['by_level'].get('$level',0))"
}

# Helper: compare JSON output with golden file
assert_matches_golden() {
    local golden_file="$1"
    python3 -c "
import json, sys
actual = json.loads(sys.stdin.read())
golden = json.load(open('$golden_file'))
# Compare structure (sorted keys, sorted ID lists)
def normalize(d):
    if isinstance(d, dict):
        return {k: normalize(v) for k, v in sorted(d.items())}
    if isinstance(d, list):
        return sorted(d) if all(isinstance(x, str) for x in d) else d
    return d
assert normalize(actual) == normalize(golden), (
    f'Mismatch with golden {\"$golden_file\"}'
)
" <<< "$output"
}

IMPACT_DIR="$FIXTURES_DIR/commands/impact-analysis/inputs"
GOLDEN_IMPACT="$FIXTURES_DIR/commands/impact-analysis/expected"

# ============================================================
# Minimal fixture: downward, upward, full
# ============================================================

@test "impact-analysis: minimal downward REQ-001 exits 0" {
    run bash "$SCRIPTS_DIR/impact-analysis.sh" --json --downward REQ-001 "$FIXTURES_DIR/minimal"
    assert_success
}

@test "impact-analysis: minimal downward REQ-001 matches golden" {
    run bash "$SCRIPTS_DIR/impact-analysis.sh" --json --downward REQ-001 "$FIXTURES_DIR/minimal"
    assert_success
    assert_matches_golden "$GOLDEN_IMPACT/minimal/downward-REQ-001.json"
}

@test "impact-analysis: minimal upward MOD-001 matches golden" {
    run bash "$SCRIPTS_DIR/impact-analysis.sh" --json --upward MOD-001 "$FIXTURES_DIR/minimal"
    assert_success
    assert_matches_golden "$GOLDEN_IMPACT/minimal/upward-MOD-001.json"
}

@test "impact-analysis: minimal full SYS-001 matches golden" {
    run bash "$SCRIPTS_DIR/impact-analysis.sh" --json --full SYS-001 "$FIXTURES_DIR/minimal"
    assert_success
    assert_matches_golden "$GOLDEN_IMPACT/minimal/full-SYS-001.json"
}

@test "impact-analysis: minimal downward has SYS suspects" {
    run bash "$SCRIPTS_DIR/impact-analysis.sh" --json --downward REQ-001 "$FIXTURES_DIR/minimal"
    assert_success
    local count
    count=$(impact_level_count "SYS")
    [ "$count" -gt 0 ]
}

@test "impact-analysis: minimal full has upstream/downstream keys" {
    run bash "$SCRIPTS_DIR/impact-analysis.sh" --json --full SYS-001 "$FIXTURES_DIR/minimal"
    assert_success
    local direction
    direction=$(impact_json_field "direction")
    [ "$direction" = "full" ]
    # Check for upstream/downstream in suspect_artifacts
    echo "$output" | python3 -c "import json,sys; d=json.load(sys.stdin); assert 'downstream' in d['suspect_artifacts']"
    echo "$output" | python3 -c "import json,sys; d=json.load(sys.stdin); assert 'upstream' in d['suspect_artifacts']"
}

# ============================================================
# Complex fixture
# ============================================================

@test "impact-analysis: complex downward REQ-001 matches golden" {
    run bash "$SCRIPTS_DIR/impact-analysis.sh" --json --downward REQ-001 "$FIXTURES_DIR/complex"
    assert_success
    assert_matches_golden "$GOLDEN_IMPACT/complex/downward-REQ-001.json"
}

@test "impact-analysis: complex upward MOD-006 matches golden" {
    run bash "$SCRIPTS_DIR/impact-analysis.sh" --json --upward MOD-006 "$FIXTURES_DIR/complex"
    assert_success
    assert_matches_golden "$GOLDEN_IMPACT/complex/upward-MOD-006.json"
}

@test "impact-analysis: complex full SYS-003 matches golden" {
    run bash "$SCRIPTS_DIR/impact-analysis.sh" --json --full SYS-003 "$FIXTURES_DIR/complex"
    assert_success
    assert_matches_golden "$GOLDEN_IMPACT/complex/full-SYS-003.json"
}

# ============================================================
# Gaps fixture
# ============================================================

@test "impact-analysis: gaps downward REQ-001 matches golden" {
    run bash "$SCRIPTS_DIR/impact-analysis.sh" --json --downward REQ-001 "$FIXTURES_DIR/gaps"
    assert_success
    assert_matches_golden "$GOLDEN_IMPACT/gaps/downward-REQ-001.json"
}

@test "impact-analysis: gaps upward MOD-001 matches golden" {
    run bash "$SCRIPTS_DIR/impact-analysis.sh" --json --upward MOD-001 "$FIXTURES_DIR/gaps"
    assert_success
    assert_matches_golden "$GOLDEN_IMPACT/gaps/upward-MOD-001.json"
}

# ============================================================
# Linear fixture: simple chain traversal
# ============================================================

@test "impact-analysis: linear downward REQ-001 matches golden" {
    run bash "$SCRIPTS_DIR/impact-analysis.sh" --json --downward REQ-001 "$IMPACT_DIR/linear"
    assert_success
    assert_matches_golden "$GOLDEN_IMPACT/linear/downward-REQ-001.json"
}

@test "impact-analysis: linear upward MOD-001 matches golden" {
    run bash "$SCRIPTS_DIR/impact-analysis.sh" --json --upward MOD-001 "$IMPACT_DIR/linear"
    assert_success
    assert_matches_golden "$GOLDEN_IMPACT/linear/upward-MOD-001.json"
}

@test "impact-analysis: linear full SYS-001 matches golden" {
    run bash "$SCRIPTS_DIR/impact-analysis.sh" --json --full SYS-001 "$IMPACT_DIR/linear"
    assert_success
    assert_matches_golden "$GOLDEN_IMPACT/linear/full-SYS-001.json"
}

# ============================================================
# Diamond fixture: fan-out/fan-in + cross-cutting
# ============================================================

@test "impact-analysis: diamond downward REQ-001 matches golden" {
    run bash "$SCRIPTS_DIR/impact-analysis.sh" --json --downward REQ-001 "$IMPACT_DIR/diamond"
    assert_success
    assert_matches_golden "$GOLDEN_IMPACT/diamond/downward-REQ-001.json"
}

@test "impact-analysis: diamond upward MOD-002 matches golden" {
    run bash "$SCRIPTS_DIR/impact-analysis.sh" --json --upward MOD-002 "$IMPACT_DIR/diamond"
    assert_success
    assert_matches_golden "$GOLDEN_IMPACT/diamond/upward-MOD-002.json"
}

@test "impact-analysis: diamond full ARCH-004 matches golden" {
    run bash "$SCRIPTS_DIR/impact-analysis.sh" --json --full ARCH-004 "$IMPACT_DIR/diamond"
    assert_success
    assert_matches_golden "$GOLDEN_IMPACT/diamond/full-ARCH-004.json"
}

# ============================================================
# Disconnected fixture: isolated subgraphs
# ============================================================

@test "impact-analysis: disconnected REQ-001 only finds subgraph A" {
    run bash "$SCRIPTS_DIR/impact-analysis.sh" --json --downward REQ-001 "$IMPACT_DIR/disconnected"
    assert_success
    assert_matches_golden "$GOLDEN_IMPACT/disconnected/downward-REQ-001.json"
}

@test "impact-analysis: disconnected REQ-002 only finds subgraph B" {
    run bash "$SCRIPTS_DIR/impact-analysis.sh" --json --downward REQ-002 "$IMPACT_DIR/disconnected"
    assert_success
    assert_matches_golden "$GOLDEN_IMPACT/disconnected/downward-REQ-002.json"
}

@test "impact-analysis: disconnected subgraphs have no overlap" {
    run bash "$SCRIPTS_DIR/impact-analysis.sh" --json --downward REQ-001 "$IMPACT_DIR/disconnected"
    assert_success
    local out1="$output"
    run bash "$SCRIPTS_DIR/impact-analysis.sh" --json --downward REQ-002 "$IMPACT_DIR/disconnected"
    assert_success
    python3 -c "
import json
d1 = json.loads('''$out1''')
d2 = json.loads('''$output''')
ids1 = set()
for lst in d1['suspect_artifacts'].values(): ids1.update(lst)
ids2 = set()
for lst in d2['suspect_artifacts'].values(): ids2.update(lst)
assert len(ids1 & ids2) == 0, f'Overlap detected: {ids1 & ids2}'
"
}

@test "impact-analysis: disconnected upward MOD-001 matches golden" {
    run bash "$SCRIPTS_DIR/impact-analysis.sh" --json --upward MOD-001 "$IMPACT_DIR/disconnected"
    assert_success
    assert_matches_golden "$GOLDEN_IMPACT/disconnected/upward-MOD-001.json"
}

# ============================================================
# Markdown output mode
# ============================================================

@test "impact-analysis: markdown output has expected sections" {
    setup_temp_dir
    run bash "$SCRIPTS_DIR/impact-analysis.sh" --output "$TEST_TEMP_DIR/report.md" --downward REQ-001 "$FIXTURES_DIR/minimal"
    assert_success
    assert_output --partial "Impact report written to"
    run grep "# Impact Analysis Report" "$TEST_TEMP_DIR/report.md"
    assert_success
    run grep "## Changed IDs" "$TEST_TEMP_DIR/report.md"
    assert_success
    run grep "## Suspect Artifacts" "$TEST_TEMP_DIR/report.md"
    assert_success
    run grep "## Blast Radius" "$TEST_TEMP_DIR/report.md"
    assert_success
    run grep "## Re-validation Order" "$TEST_TEMP_DIR/report.md"
    assert_success
    teardown_temp_dir
}

@test "impact-analysis: default output writes to vmodel-dir/impact-report.md" {
    setup_temp_dir
    copy_fixture "minimal" "$TEST_TEMP_DIR/vmodel"
    run bash "$SCRIPTS_DIR/impact-analysis.sh" --downward REQ-001 "$TEST_TEMP_DIR/vmodel"
    assert_success
    [ -f "$TEST_TEMP_DIR/vmodel/impact-report.md" ]
    teardown_temp_dir
}

# ============================================================
# Multi-ID input
# ============================================================

@test "impact-analysis: multiple changed IDs" {
    run bash "$SCRIPTS_DIR/impact-analysis.sh" --json --downward REQ-001 REQ-002 "$FIXTURES_DIR/minimal"
    assert_success
    echo "$output" | python3 -c "
import json, sys
d = json.load(sys.stdin)
assert len(d['changed_ids']) == 2, f'Expected 2 changed IDs, got {len(d[\"changed_ids\"])}'
assert 'REQ-001' in d['changed_ids']
assert 'REQ-002' in d['changed_ids']
"
}

# ============================================================
# Error handling
# ============================================================

@test "impact-analysis: no arguments exits 1" {
    run bash "$SCRIPTS_DIR/impact-analysis.sh"
    assert_failure
    assert_output --partial "ERROR"
}

@test "impact-analysis: unknown ID warns on stderr" {
    run bash "$SCRIPTS_DIR/impact-analysis.sh" --json --downward FAKE-999 "$FIXTURES_DIR/minimal"
    assert_failure
}

@test "impact-analysis: nonexistent directory exits 1" {
    run bash "$SCRIPTS_DIR/impact-analysis.sh" --json --downward REQ-001 "/nonexistent/dir"
    assert_failure
}

@test "impact-analysis: empty fixture (no matching IDs) exits 1" {
    run bash "$SCRIPTS_DIR/impact-analysis.sh" --json --downward REQ-001 "$FIXTURES_DIR/empty"
    assert_failure
}

# ============================================================
# JSON structural validation (via Python validator)
# ============================================================

@test "impact-analysis: JSON output passes structural validation" {
    run bash "$SCRIPTS_DIR/impact-analysis.sh" --json --downward REQ-001 "$FIXTURES_DIR/minimal"
    assert_success
    python3 -c "
import sys
sys.path.insert(0, '$(cd "$PROJECT_ROOT" && pwd)')
from tests.validators.impact_validators import validate_all
result = validate_all(sys.stdin.read())
assert result['score'] == 1.0, f'Validation failed: {result[\"issues\"]}'
" <<< "$output"
}

@test "impact-analysis: upward JSON passes structural validation" {
    run bash "$SCRIPTS_DIR/impact-analysis.sh" --json --upward MOD-001 "$FIXTURES_DIR/minimal"
    assert_success
    python3 -c "
import sys
sys.path.insert(0, '$(cd "$PROJECT_ROOT" && pwd)')
from tests.validators.impact_validators import validate_all
result = validate_all(sys.stdin.read())
assert result['score'] == 1.0, f'Validation failed: {result[\"issues\"]}'
" <<< "$output"
}

@test "impact-analysis: full JSON passes structural validation" {
    run bash "$SCRIPTS_DIR/impact-analysis.sh" --json --full SYS-001 "$FIXTURES_DIR/minimal"
    assert_success
    python3 -c "
import sys
sys.path.insert(0, '$(cd "$PROJECT_ROOT" && pwd)')
from tests.validators.impact_validators import validate_all
result = validate_all(sys.stdin.read())
assert result['score'] == 1.0, f'Validation failed: {result[\"issues\"]}'
" <<< "$output"
}

# ============================================================
# Performance
# ============================================================

@test "impact-analysis: completes within 10 seconds on dogfooding data" {
    if [ ! -d "$PROJECT_ROOT/specs/005a-hazard-analysis/v-model" ]; then
        skip "005a dogfooding data not available"
    fi
    local start end elapsed
    start=$(date +%s)
    run bash "$SCRIPTS_DIR/impact-analysis.sh" --json --full REQ-001 "$PROJECT_ROOT/specs/005a-hazard-analysis/v-model"
    assert_success
    end=$(date +%s)
    elapsed=$((end - start))
    [ "$elapsed" -le 10 ]
}
