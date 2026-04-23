load "test_helper"

PEER_REVIEW_FIXTURES="$FIXTURES_DIR/commands/peer-review/inputs"

# === Clean report (0 findings) ===

@test "peer-review-check: clean report exits 0" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" "$PEER_REVIEW_FIXTURES/clean-requirements.md"
    assert_success
}

@test "peer-review-check: clean report shows PASS" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" "$PEER_REVIEW_FIXTURES/clean-requirements.md"
    assert_success
    assert_output --partial "PASS"
}

@test "peer-review-check: clean report JSON exit_code=0" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" --json "$PEER_REVIEW_FIXTURES/clean-requirements.md"
    assert_success
    local ec
    ec=$(json_field "$output" "exit_code")
    [ "$ec" = "0" ]
}

@test "peer-review-check: clean report JSON total=0" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" --json "$PEER_REVIEW_FIXTURES/clean-requirements.md"
    assert_success
    local total
    total=$(json_field "$output" "total")
    [ "$total" = "0" ]
}

@test "peer-review-check: clean report JSON summary_match=true" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" --json "$PEER_REVIEW_FIXTURES/clean-requirements.md"
    assert_success
    local match
    match=$(json_field "$output" "summary_match")
    [ "$match" = "True" ]
}

@test "peer-review-check: clean report extracts artifact" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" --json "$PEER_REVIEW_FIXTURES/clean-requirements.md"
    assert_success
    local artifact
    artifact=$(json_field "$output" "artifact")
    [[ "$artifact" == *"requirements.md"* ]]
}

@test "peer-review-check: clean report extracts standard" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" --json "$PEER_REVIEW_FIXTURES/clean-requirements.md"
    assert_success
    local standard
    standard=$(json_field "$output" "standard")
    [[ "$standard" == *"INCOSE"* ]]
}

# === Critical + Major findings (exit 1) ===

@test "peer-review-check: critical-major exits 1" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" "$PEER_REVIEW_FIXTURES/critical-major-requirements.md"
    assert_failure 1
}

@test "peer-review-check: critical-major shows FAIL" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" "$PEER_REVIEW_FIXTURES/critical-major-requirements.md"
    assert_failure
    assert_output --partial "FAIL"
}

@test "peer-review-check: critical-major JSON exit_code=1" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" --json "$PEER_REVIEW_FIXTURES/critical-major-requirements.md"
    assert_failure 1
    local ec
    ec=$(json_field "$output" "exit_code")
    [ "$ec" = "1" ]
}

@test "peer-review-check: critical-major counts 1 Critical" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" --json "$PEER_REVIEW_FIXTURES/critical-major-requirements.md"
    assert_failure
    local c
    c=$(json_field "$output" "critical")
    [ "$c" = "1" ]
}

@test "peer-review-check: critical-major counts 2 Major" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" --json "$PEER_REVIEW_FIXTURES/critical-major-requirements.md"
    assert_failure
    local m
    m=$(json_field "$output" "major")
    [ "$m" = "2" ]
}

@test "peer-review-check: critical-major total=3" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" --json "$PEER_REVIEW_FIXTURES/critical-major-requirements.md"
    assert_failure
    local total
    total=$(json_field "$output" "total")
    [ "$total" = "3" ]
}

@test "peer-review-check: critical-major PRF headings match total" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" --json "$PEER_REVIEW_FIXTURES/critical-major-requirements.md"
    assert_failure
    local headings total
    headings=$(json_field "$output" "prf_headings")
    total=$(json_field "$output" "total")
    [ "$headings" = "$total" ]
}

@test "peer-review-check: critical-major summary_match=true" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" --json "$PEER_REVIEW_FIXTURES/critical-major-requirements.md"
    assert_failure
    local match
    match=$(json_field "$output" "summary_match")
    [ "$match" = "True" ]
}

# === Minor-only findings (exit 2) ===

@test "peer-review-check: minor-only exits 2" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" "$PEER_REVIEW_FIXTURES/minor-only-system-design.md"
    assert_failure 2
}

@test "peer-review-check: minor-only shows WARNING" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" "$PEER_REVIEW_FIXTURES/minor-only-system-design.md"
    assert_failure
    assert_output --partial "WARNING"
}

@test "peer-review-check: minor-only JSON exit_code=2" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" --json "$PEER_REVIEW_FIXTURES/minor-only-system-design.md"
    assert_failure 2
    local ec
    ec=$(json_field "$output" "exit_code")
    [ "$ec" = "2" ]
}

@test "peer-review-check: minor-only counts 0 Critical 0 Major" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" --json "$PEER_REVIEW_FIXTURES/minor-only-system-design.md"
    assert_failure
    local c m
    c=$(json_field "$output" "critical")
    m=$(json_field "$output" "major")
    [ "$c" = "0" ]
    [ "$m" = "0" ]
}

@test "peer-review-check: minor-only counts 2 Minor" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" --json "$PEER_REVIEW_FIXTURES/minor-only-system-design.md"
    assert_failure
    local mi
    mi=$(json_field "$output" "minor")
    [ "$mi" = "2" ]
}

@test "peer-review-check: minor-only extracts IEEE 1016 standard" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" --json "$PEER_REVIEW_FIXTURES/minor-only-system-design.md"
    assert_failure
    local standard
    standard=$(json_field "$output" "standard")
    [[ "$standard" == *"IEEE 1016"* ]]
}

# === Mixed severity (all 4 levels, exit 1) ===

@test "peer-review-check: mixed severity exits 1" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" "$PEER_REVIEW_FIXTURES/mixed-severity-hazard-analysis.md"
    assert_failure 1
}

@test "peer-review-check: mixed severity JSON total=7" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" --json "$PEER_REVIEW_FIXTURES/mixed-severity-hazard-analysis.md"
    assert_failure
    local total
    total=$(json_field "$output" "total")
    [ "$total" = "7" ]
}

@test "peer-review-check: mixed severity counts all severities" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" --json "$PEER_REVIEW_FIXTURES/mixed-severity-hazard-analysis.md"
    assert_failure
    local c m mi o
    c=$(json_field "$output" "critical")
    m=$(json_field "$output" "major")
    mi=$(json_field "$output" "minor")
    o=$(json_field "$output" "observation")
    [ "$c" = "1" ]
    [ "$m" = "2" ]
    [ "$mi" = "3" ]
    [ "$o" = "1" ]
}

@test "peer-review-check: mixed severity PRF severity tags match" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" --json "$PEER_REVIEW_FIXTURES/mixed-severity-hazard-analysis.md"
    assert_failure
    local pc pm pmi po
    pc=$(json_field "$output" "prf_critical")
    pm=$(json_field "$output" "prf_major")
    pmi=$(json_field "$output" "prf_minor")
    po=$(json_field "$output" "prf_observation")
    [ "$pc" = "1" ]
    [ "$pm" = "2" ]
    [ "$pmi" = "3" ]
    [ "$po" = "1" ]
}

@test "peer-review-check: mixed severity summary_match=true" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" --json "$PEER_REVIEW_FIXTURES/mixed-severity-hazard-analysis.md"
    assert_failure
    local match
    match=$(json_field "$output" "summary_match")
    [ "$match" = "True" ]
}

@test "peer-review-check: mixed severity extracts ISO standard" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" --json "$PEER_REVIEW_FIXTURES/mixed-severity-hazard-analysis.md"
    assert_failure
    local standard
    standard=$(json_field "$output" "standard")
    [[ "$standard" == *"ISO 14971"* ]]
}

# === Observations only (exit 0) ===

@test "peer-review-check: observations-only exits 0" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" "$PEER_REVIEW_FIXTURES/observations-only-module-design.md"
    assert_success
}

@test "peer-review-check: observations-only shows PASS" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" "$PEER_REVIEW_FIXTURES/observations-only-module-design.md"
    assert_success
    assert_output --partial "PASS"
}

@test "peer-review-check: observations-only JSON exit_code=0" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" --json "$PEER_REVIEW_FIXTURES/observations-only-module-design.md"
    assert_success
    local ec
    ec=$(json_field "$output" "exit_code")
    [ "$ec" = "0" ]
}

@test "peer-review-check: observations-only counts 2 Observations" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" --json "$PEER_REVIEW_FIXTURES/observations-only-module-design.md"
    assert_success
    local o
    o=$(json_field "$output" "observation")
    [ "$o" = "2" ]
}

@test "peer-review-check: observations-only total=2 but exit 0" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" --json "$PEER_REVIEW_FIXTURES/observations-only-module-design.md"
    assert_success
    local total
    total=$(json_field "$output" "total")
    [ "$total" = "2" ]
}

@test "peer-review-check: observations-only extracts DO-178C standard" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" --json "$PEER_REVIEW_FIXTURES/observations-only-module-design.md"
    assert_success
    local standard
    standard=$(json_field "$output" "standard")
    [[ "$standard" == *"DO-178C"* ]]
}

# === Error handling ===

@test "peer-review-check: missing argument exits 1" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh"
    assert_failure 1
    assert_output --partial "ERROR"
}

@test "peer-review-check: nonexistent file exits 1" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" "/tmp/nonexistent-peer-review.md"
    assert_failure 1
    assert_output --partial "not found"
}

@test "peer-review-check: --help exits 0" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" --help
    assert_success
    assert_output --partial "Usage"
}

# === JSON output structure ===

@test "peer-review-check: JSON output is valid JSON" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" --json "$PEER_REVIEW_FIXTURES/mixed-severity-hazard-analysis.md"
    assert_valid_json "$output"
}

@test "peer-review-check: JSON has all required fields" {
    run bash "$SCRIPTS_DIR/peer-review-check.sh" --json "$PEER_REVIEW_FIXTURES/clean-requirements.md"
    assert_success
    local rf art std
    rf=$(json_field "$output" "review_file")
    art=$(json_field "$output" "artifact")
    std=$(json_field "$output" "standard")
    [ -n "$rf" ]
    [ -n "$art" ]
    [ -n "$std" ]
}
