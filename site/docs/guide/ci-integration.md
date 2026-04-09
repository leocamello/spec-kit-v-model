---
title: GitHub Actions Integration
description: Run V-Model validators, peer review gates, impact analysis checks, and audit reports in CI — sample workflow included.
---

# GitHub Actions Integration

The V-Model Extension Pack includes a complete sample GitHub Actions workflow and individual scripts designed for CI/CD pipelines. All validators produce deterministic results with CI-compatible exit codes.

---

## Sample Workflow

Copy the sample workflow from `examples/github-actions/v-model-validation.yml` into your repository:

```bash
mkdir -p .github/workflows
cp examples/github-actions/v-model-validation.yml .github/workflows/
```

The workflow runs on pull requests and pushes to `main`. Configure the environment variables at the top:

```yaml
env:
  # Path to your V-Model artifacts directory
  VMODEL_DIR: specs/v-model

  # spec-kit-v-model release tag to install
  SPECKIT_VMODEL_VERSION: v0.5.0
```

---

## Pipeline Steps

The sample workflow includes these steps, each designed to handle partial V-Models gracefully:

### 1. Install Extension

Downloads the spec-kit-v-model extension from a GitHub release and makes scripts executable:

```yaml
- name: Install spec-kit-v-model extension
  run: |
    INSTALL_DIR="$HOME/.spec-kit/extensions/v-model"
    mkdir -p "$INSTALL_DIR"
    curl -fsSL \
      "https://github.com/leocamello/spec-kit-v-model/archive/refs/tags/${SPECKIT_VMODEL_VERSION}.tar.gz" \
      -o v-model-extension.tar.gz
    tar -xzf v-model-extension.tar.gz --strip-components=1 -C "$INSTALL_DIR"
    rm v-model-extension.tar.gz
    chmod +x "$INSTALL_DIR"/scripts/bash/*.sh
    echo "VMODEL_SCRIPTS=$INSTALL_DIR/scripts/bash" >> "$GITHUB_ENV"
```

### 2. Detect Artifacts

Scans the V-Model directory to determine which artifacts exist, enabling conditional execution of later steps:

```yaml
- name: Detect V-Model artifacts
  id: detect
  run: |
    check_file() {
      local name="$1" file="$2"
      if [[ -f "$VMODEL_DIR/$file" ]]; then
        echo "${name}=true" >> "$GITHUB_OUTPUT"
      else
        echo "${name}=false" >> "$GITHUB_OUTPUT"
      fi
    }
    check_file has_requirements       requirements.md
    check_file has_acceptance_plan     acceptance-plan.md
    check_file has_system_design       system-design.md
    # ... (all artifact types)
```

### 3. Run Validators

Each validator runs conditionally based on which artifacts exist:

```yaml
- name: Validate requirement coverage
  if: >-
    steps.detect.outputs.has_requirements == 'true' &&
    steps.detect.outputs.has_acceptance_plan == 'true'
  run: |
    "$VMODEL_SCRIPTS/validate-requirement-coverage.sh" "$VMODEL_DIR"
```

---

## Running Validators in CI

Each validator is a standalone script with consistent exit codes:

| Validator | Required Artifacts | Exit 0 | Exit 1 |
|---|---|---|---|
| `validate-requirement-coverage.sh` | requirements.md, acceptance-plan.md | Full coverage | Gaps found |
| `validate-system-coverage.sh` | requirements.md, system-design.md | Full coverage | Gaps found |
| `validate-architecture-coverage.sh` | system-design.md, architecture-design.md | Full coverage | Gaps found |
| `validate-module-coverage.sh` | architecture-design.md, module-design.md | Full coverage | Gaps found |
| `validate-hazard-coverage.sh` | system-design.md, hazard-analysis.md | All checks pass | Gaps found |

!!! tip "Partial V-Models"

    System, architecture, and module validators support **partial mode** — if the test artifact doesn't exist yet (e.g., no `system-test.md`), they run forward-only coverage checks and skip test mapping validation.

---

## Peer Review as PR Gate

The `peer-review-check.sh` script parses peer review reports and returns exit codes suitable for PR gating:

```yaml
- name: Peer review check
  if: steps.detect.outputs.has_peer_reviews == 'true'
  run: |
    OVERALL=0
    for review in "$VMODEL_DIR"/peer-review-*.md; do
      RC=0
      "$VMODEL_SCRIPTS/peer-review-check.sh" "$review" || RC=$?
      if [[ $RC -eq 1 ]]; then
        OVERALL=1  # Critical/Major — block merge
      elif [[ $RC -eq 2 ]] && [[ $OVERALL -eq 0 ]]; then
        OVERALL=2  # Minor findings — warning only
      fi
    done
    [[ $OVERALL -eq 1 ]] && exit 1
```

| Exit Code | Meaning | PR Action |
|---|---|---|
| `0` | Clean or observations only | ✅ Allow merge |
| `1` | Critical or Major findings | ⛔ Block merge |
| `2` | Minor findings only | ⚠️ Warning |

---

## Impact Analysis Threshold

Check blast radius in CI to catch changes with unexpectedly large impact:

```yaml
- name: Impact analysis threshold
  if: github.event_name == 'pull_request'
  run: |
    # Get changed V-Model IDs from the PR diff
    CHANGED_IDS=$(git diff --name-only origin/main... | \
      grep "specs/v-model/" | \
      xargs grep -ohE '(REQ|SYS|ARCH|MOD)-([A-Z]+-)?[0-9]{3}' | \
      sort -u)

    if [[ -n "$CHANGED_IDS" ]]; then
      RESULT=$("$VMODEL_SCRIPTS/impact-analysis.sh" \
        --json --downward $CHANGED_IDS "$VMODEL_DIR")
      TOTAL=$(echo "$RESULT" | jq '.blast_radius.total')
      echo "Blast radius: $TOTAL artifacts affected"
      if [ "$TOTAL" -gt 50 ]; then
        echo "⚠️ Large blast radius — consider splitting the change"
      fi
    fi
```

---

## Audit Report in Pipeline

Build the audit report as the final step — its exit code determines the release gate:

```yaml
- name: Build audit report
  if: >-
    steps.detect.outputs.has_requirements == 'true' &&
    steps.detect.outputs.has_traceability_matrix == 'true'
  run: |
    "$VMODEL_SCRIPTS/build-audit-report.sh" "$VMODEL_DIR" \
      --system-name "${{ github.event.repository.name }}" \
      --version "${{ github.sha }}"
    # Exit 0 = RELEASE READY/CANDIDATE
    # Exit 1 = NOT READY (unwaived anomalies)
    # Exit 2 = Missing required artifacts
```

---

## Job Summary

The sample workflow writes a markdown summary table to `$GITHUB_STEP_SUMMARY`:

```
## 🔍 V-Model Validation Summary

| Check | Result |
|-------|--------|
| Requirement coverage (REQ → ATP → SCN) | ✅ Pass |
| System coverage (REQ → SYS → STP → STS) | ✅ Pass |
| Architecture coverage (SYS → ARCH → ITP → ITS) | ⏭️ Skipped |
| Module coverage (ARCH → MOD → UTP → UTS) | ⏭️ Skipped |
| Hazard coverage (HAZ → mitigation) | ✅ Pass |
| Traceability matrix | ✅ Built |
| Peer review | ⚠️ Minor findings |
| Audit report | ✅ Release ready |
```

---

## Related Pages

- [V-Model Concepts](concepts.md) — Understanding validators and matrices
- [Peer Review](peer-review.md) — Standards-based artifact linting
- [Impact Analysis](impact-analysis.md) — Blast radius checking
- [Audit Report](audit-report.md) — Compliance gating and waivers
- [Test Results Ingestion](test-results.md) — Feed test results before auditing
