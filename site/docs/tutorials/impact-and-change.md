---
title: "Tutorial: Managing Changes with Impact Analysis"
description: A focused tutorial on using impact analysis to manage requirement changes, trace downstream and upstream effects, calculate blast radius, and integrate change management into CI/CD pipelines.
---

# Tutorial: Managing Changes with Impact Analysis

## What You'll Learn

Requirements change. In regulated software, a single requirement change can ripple through dozens of downstream artifacts — system designs, test plans, hazard analyses, and module designs. Missing even one creates a **traceability gap** that auditors will flag.

In this tutorial you will learn to:

- Run **downward** impact analysis to find all artifacts affected by a requirement change
- Run **upward** impact analysis to trace a test procedure back to its originating requirement
- Run **full** impact analysis to see the complete blast radius
- Use **`--json`** output for CI pipeline integration
- Systematically update affected artifacts and re-validate consistency
- Add impact analysis **threshold checks** to GitHub Actions

By the end, "what did I break?" becomes a **deterministic, auditable process** instead of an anxiety-driven manual review.

---

## Prerequisites

!!! info "Before you begin"

    1. **Spec Kit** and the **V-Model Extension Pack** are installed.
    2. You have an **existing project with at least Level 1 + Level 2 artifacts** already generated (requirements, acceptance tests, system design, and system tests).

    If you don't have a project yet, complete one of these tutorials first:

    - [Blood Glucose Monitor (IEC 62304)](medical-device.md) — medical device walkthrough
    - [Emergency Braking System (ISO 26262)](automotive-adas.md) — automotive walkthrough

    This tutorial uses the **Blood Glucose Monitor** artifacts as its running example, but the workflow is identical for any domain.

---

## Scenario

Your blood glucose monitor project has a full set of V-Model artifacts. A clinical study now shows that the **glucose measurement accuracy** requirement must be tightened:

> **REQ-003** originally stated: alert within **30 seconds** when glucose falls below the hypoglycemia threshold (default **70 mg/dL**)
>
> The new requirement: alert within **30 seconds** when glucose falls below the hypoglycemia threshold (default **55 mg/dL**) — the threshold default has changed from 70 mg/dL to 55 mg/dL based on updated clinical guidelines.

Before making any edits, you need to understand **exactly which artifacts are affected**.

---

## Step 1 — Downward Impact Analysis

Run impact analysis in the **downward** direction to find every artifact that traces from REQ-003:

=== "Bash"

    ```bash
    /speckit.v-model.impact-analysis --downward REQ-003
    ```

=== "PowerShell"

    ```powershell
    /speckit.v-model.impact-analysis --downward REQ-003
    ```

This produces:

```
══════════════════════════════════════════════
  IMPACT ANALYSIS — DOWNSTREAM OF REQ-003
══════════════════════════════════════════════

  Changed Artifact: REQ-003
  Direction: DOWNWARD (requirement → tests → design → modules)

  Suspect Artifacts (Downstream):
  ────────────────────────────────────────────
  ATP  │ ATP-003-A, ATP-003-B, ATP-003-C
  SCN  │ SCN-003-A1, SCN-003-B1, SCN-003-C1
  SYS  │ SYS-002
  STP  │ STP-002-A, STP-002-B
  STS  │ STS-002-A1, STS-002-A2, STS-002-B1
  HAZ  │ HAZ-001
  ARCH │ ARCH-002, ARCH-003
  ITP  │ ITP-002-A
  ITS  │ ITS-002-A1
  MOD  │ MOD-002
  UTP  │ UTP-002-A
  UTS  │ UTS-002-A1, UTS-002-A2

  Blast Radius:
  ────────────────────────────────────────────
  | Level     | Count |
  |-----------|-------|
  | ATP       | 3     |
  | SCN       | 3     |
  | SYS       | 1     |
  | STP       | 2     |
  | STS       | 3     |
  | HAZ       | 1     |
  | ARCH      | 2     |
  | ITP       | 1     |
  | ITS       | 1     |
  | MOD       | 1     |
  | UTP       | 1     |
  | UTS       | 2     |
  | **Total** | **21**|
══════════════════════════════════════════════
```

!!! note "Reading the output"

    - **Suspect Artifacts** are artifacts that **may need updating** because they trace (directly or transitively) from REQ-003.
    - **Blast Radius** summarizes the count by artifact level — useful for estimating the effort of a change.
    - A blast radius of 21 means 21 individual artifact sections need human review. This doesn't mean all 21 will change — some may still be valid — but all 21 must be **verified**.

---

## Step 2 — Upward Impact Analysis

Sometimes you start from a failing test and need to trace **upward** to understand which requirement it validates. For example, if `STP-002-A` fails after a code change:

=== "Bash"

    ```bash
    /speckit.v-model.impact-analysis --upward STP-002-A
    ```

=== "PowerShell"

    ```powershell
    /speckit.v-model.impact-analysis --upward STP-002-A
    ```

```
══════════════════════════════════════════════
  IMPACT ANALYSIS — UPSTREAM OF STP-002-A
══════════════════════════════════════════════

  Changed Artifact: STP-002-A
  Direction: UPWARD (test → design → requirement)

  Trace Chain:
  ────────────────────────────────────────────
  STP-002-A
    └── SYS-002 (AlertEngine)
        └── REQ-003 (Hypoglycemia alert within 30 seconds)
        └── REQ-004 (Hyperglycemia alert within 30 seconds)

  Upstream Requirements Affected:
  ────────────────────────────────────────────
  REQ-003 │ Hypoglycemia alert — default threshold 70 mg/dL
  REQ-004 │ Hyperglycemia alert — default threshold 250 mg/dL
══════════════════════════════════════════════
```

!!! tip "When to use upward analysis"

    - A test fails in CI and you need to know **which requirement is at risk**
    - A module is being refactored and you need to identify **which requirements are covered by the affected tests**
    - An auditor asks "which requirement does this test validate?" and you need a quick answer

---

## Step 3 — Full Impact Analysis

For a complete picture — both upstream and downstream from a single artifact — use the `--full` flag:

=== "Bash"

    ```bash
    /speckit.v-model.impact-analysis --full REQ-003
    ```

=== "PowerShell"

    ```powershell
    /speckit.v-model.impact-analysis --full REQ-003
    ```

```
══════════════════════════════════════════════
  IMPACT ANALYSIS — FULL BLAST RADIUS OF REQ-003
══════════════════════════════════════════════

  Artifact: REQ-003
  Direction: FULL (upstream + downstream)

  ┌─────────────────────────────────────────────────────────┐
  │                    UPSTREAM                              │
  │  spec.md (Feature Specification)                        │
  │    └── REQ-003 (Hypoglycemia alert)                     │
  ├─────────────────────────────────────────────────────────┤
  │                    DOWNSTREAM                            │
  │  REQ-003                                                │
  │    ├── ATP-003-A, ATP-003-B, ATP-003-C                  │
  │    │     └── SCN-003-A1, SCN-003-B1, SCN-003-C1         │
  │    ├── SYS-002 (AlertEngine)                            │
  │    │     ├── STP-002-A, STP-002-B                       │
  │    │     │     └── STS-002-A1, STS-002-A2, STS-002-B1   │
  │    │     └── ARCH-002 (ThresholdEvaluator)              │
  │    │           ├── ITP-002-A                             │
  │    │           │     └── ITS-002-A1                      │
  │    │           └── MOD-002                               │
  │    │                 └── UTP-002-A                       │
  │    │                       └── UTS-002-A1, UTS-002-A2   │
  │    └── HAZ-001 (Missed hypoglycemia alert)              │
  └─────────────────────────────────────────────────────────┘

  Total Blast Radius: 21 artifacts
══════════════════════════════════════════════
```

The tree view makes it easy to see **exactly how the change propagates** through the V-Model hierarchy.

---

## Step 4 — JSON Output for CI Integration

For automated pipelines, use `--json` to get machine-readable output:

=== "Bash"

    ```bash
    /speckit.v-model.impact-analysis --downward REQ-003 --json
    ```

=== "PowerShell"

    ```powershell
    /speckit.v-model.impact-analysis --downward REQ-003 --json
    ```

```json
{
  "changed_artifact": "REQ-003",
  "direction": "downward",
  "suspect_artifacts": {
    "ATP": ["ATP-003-A", "ATP-003-B", "ATP-003-C"],
    "SCN": ["SCN-003-A1", "SCN-003-B1", "SCN-003-C1"],
    "SYS": ["SYS-002"],
    "STP": ["STP-002-A", "STP-002-B"],
    "STS": ["STS-002-A1", "STS-002-A2", "STS-002-B1"],
    "HAZ": ["HAZ-001"],
    "ARCH": ["ARCH-002", "ARCH-003"],
    "ITP": ["ITP-002-A"],
    "ITS": ["ITS-002-A1"],
    "MOD": ["MOD-002"],
    "UTP": ["UTP-002-A"],
    "UTS": ["UTS-002-A1", "UTS-002-A2"]
  },
  "blast_radius": {
    "ATP": 3,
    "SCN": 3,
    "SYS": 1,
    "STP": 2,
    "STS": 3,
    "HAZ": 1,
    "ARCH": 2,
    "ITP": 1,
    "ITS": 1,
    "MOD": 1,
    "UTP": 1,
    "UTS": 2,
    "total": 21
  }
}
```

---

## Step 5 — Systematically Update Affected Artifacts

Now that you know the blast radius, update the artifacts **level by level**, starting from the changed requirement.

### 5a. Update the Requirement

Edit `requirements.md` and change REQ-003's default threshold from 70 mg/dL to 55 mg/dL:

```diff
- | REQ-003 | The system SHALL trigger an audible and haptic alert within
-   30 seconds when glucose falls below the configurable hypoglycemia
-   threshold (default 70 mg/dL) | P1 | ...
+ | REQ-003 | The system SHALL trigger an audible and haptic alert within
+   30 seconds when glucose falls below the configurable hypoglycemia
+   threshold (default 55 mg/dL) | P1 | ...
```

### 5b. Regenerate Acceptance Tests

```
/speckit.v-model.acceptance
```

The extension detects that REQ-003 was modified and regenerates **only** the affected sections:

- ✅ `ATP-003-A`, `ATP-003-B`, `ATP-003-C` — regenerated with new threshold values
- ✅ `SCN-003-A1`, `SCN-003-B1`, `SCN-003-C1` — updated: "70 mg/dL" → "55 mg/dL"
- ⏭️ All other ATPs/SCNs — untouched

??? example "Updated scenario (SCN-003-A1)"

    ```markdown
    * **User Scenario: SCN-003-A1**
      * **Given** the hypoglycemia threshold is configured to 55 mg/dL
      * **And** the system is receiving normal glucose readings of 100 mg/dL
      * **When** the sensor reports a glucose value of 50 mg/dL
      * **Then** the system activates an audible alert within 30 seconds
      * **And** the system activates a haptic alert within 30 seconds
      * **And** the companion app displays the value in red with a warning icon
    ```

### 5c. Regenerate Downstream Artifacts

Continue down the V-Model, regenerating each level:

```
/speckit.v-model.system-test
/speckit.v-model.integration-test
/speckit.v-model.unit-test
/speckit.v-model.hazard-analysis
```

!!! warning "Order matters"

    Regenerate artifacts **top-down** (acceptance → system-test → integration-test → unit-test) because each level reads from the level above. Running out of order may produce inconsistent artifacts.

---

## Step 6 — Re-validate Consistency

### 6a. Re-run Trace

```
/speckit.v-model.trace
```

Confirm that all matrices are still compliant after the change:

```
══════════════════════════════════════════════
  TRACEABILITY MATRIX — COVERAGE AUDIT
══════════════════════════════════════════════

  MATRIX A: Requirements → Acceptance Testing
  ────────────────────────────────────────────
  Total Requirements:                   9
  Requirements with Test Coverage:      9 (100%)
  Untested Requirements:               0  ✅ Pass
  Orphaned Test Cases:                 0  ✅ Pass
  MATRIX A STATUS: ✅ COMPLIANT

  MATRIX B: System Design → System Testing
  ────────────────────────────────────────────
  MATRIX B STATUS: ✅ COMPLIANT

  MATRIX C: Architecture → Integration Testing
  ────────────────────────────────────────────
  MATRIX C STATUS: ✅ COMPLIANT

  MATRIX D: Module Design → Unit Testing
  ────────────────────────────────────────────
  MATRIX D STATUS: ✅ COMPLIANT

  OVERALL STATUS: ✅ COMPLIANT (all matrices)
══════════════════════════════════════════════
```

### 6b. Peer Review Changed Artifacts

```
/speckit.v-model.peer-review
```

Focus the review on the changed artifacts to confirm the update is complete and consistent:

```
══════════════════════════════════════════════
  PEER REVIEW — SUMMARY (Post-Change)
══════════════════════════════════════════════
  Artifacts reviewed:           12
  Changed artifacts reviewed:    7
  Findings (Critical):          0   ✅
  Findings (Major):             0   ✅
  Findings (Minor):             0   ✅
  REVIEW STATUS: APPROVED
══════════════════════════════════════════════
```

### 6c. Run Audit Report

```
/speckit.v-model.audit-report
```

```
══════════════════════════════════════════════
  AUDIT REPORT — CGM-3000 Blood Glucose Monitor
  IEC 62304 Class C | Post-Change Validation
══════════════════════════════════════════════

  TRACEABILITY:                ✅ COMPLIANT (all matrices)
  HAZARD ANALYSIS:             ✅ 4/4 mitigated
  PEER REVIEW:                 ✅ APPROVED
  CHANGE HISTORY:              REQ-003 threshold updated (70→55 mg/dL)
  AFFECTED ARTIFACTS:          21 reviewed, 0 gaps

  OVERALL AUDIT STATUS: ✅ PASS
══════════════════════════════════════════════
```

!!! success "Change is complete"

    The requirement change has been propagated through all V-Model levels, all traceability links are intact, and the audit report confirms compliance. The full change history is captured in Git.

---

## Step 7 — CI Integration with GitHub Actions

Add impact analysis as a **merge gate** to prevent changes with an unexpectedly large blast radius from merging without review.

### Example Workflow

```yaml
# .github/workflows/v-model-impact-check.yml
name: V-Model Impact Analysis Gate

on:
  pull_request:
    paths:
      - 'specs/**/v-model/requirements.md'

jobs:
  impact-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Install Spec Kit + V-Model Extension
        run: |
          npm install -g @speckit/cli
          specify extension add v-model

      - name: Detect changed requirements
        id: detect
        run: |
          # Find requirement IDs that changed in this PR
          changed_reqs=$(git diff origin/main -- 'specs/**/requirements.md' \
            | grep -oP 'REQ-\w+' | sort -u | tr '\n' ' ')
          echo "changed_reqs=$changed_reqs" >> "$GITHUB_OUTPUT"

      - name: Run impact analysis
        if: steps.detect.outputs.changed_reqs != ''
        run: |
          total_blast=0
          for req in ${{ steps.detect.outputs.changed_reqs }}; do
            blast=$(specify v-model impact-analysis --downward "$req" --json \
              | python3 -c "import json,sys; print(json.load(sys.stdin)['blast_radius']['total'])")
            echo "::notice::$req blast radius: $blast"
            total_blast=$((total_blast + blast))
          done

          echo "Total blast radius: $total_blast"

          # Gate: fail if blast radius exceeds threshold
          if [ "$total_blast" -gt 50 ]; then
            echo "::error::Blast radius ($total_blast) exceeds threshold (50)."
            echo "::error::Split this change into smaller PRs or request review exemption."
            exit 1
          fi

      - name: Run traceability validation
        run: |
          specify v-model trace --strict
          if [ $? -ne 0 ]; then
            echo "::error::Traceability gaps detected after requirement change."
            exit 1
          fi
```

### What This Does

| Step | Purpose |
|---|---|
| **Detect changed requirements** | Diffs `requirements.md` against `main` to find modified REQ IDs |
| **Run impact analysis** | Computes blast radius for each changed requirement |
| **Threshold gate** | Fails the PR if total blast radius exceeds 50 — forces the change to be split or reviewed |
| **Traceability validation** | Runs `trace --strict` to ensure no gaps were introduced |

!!! tip "Tuning the threshold"

    A threshold of **50** is a reasonable starting point. Adjust based on your team's workflow:

    - **Small team, rapid iteration**: Raise to 100
    - **Large safety-critical project**: Lower to 25
    - **Per-requirement limit**: Add a per-REQ gate (e.g., no single REQ change > 30)

---

## The Change Management Workflow — Summary

Here is the complete workflow at a glance:

```
┌─────────────────────────────────────────────────────────┐
│  1. IDENTIFY  │  Which requirement changed?              │
│               │  /speckit.v-model.impact-analysis         │
│               │    --downward REQ-003                     │
├───────────────┼──────────────────────────────────────────┤
│  2. ASSESS    │  How big is the blast radius?             │
│               │  Review suspect artifact list             │
│               │  Decide: single PR or split?              │
├───────────────┼──────────────────────────────────────────┤
│  3. UPDATE    │  Edit the requirement                     │
│               │  Regenerate: acceptance → system-test      │
│               │    → integration-test → unit-test          │
│               │    → hazard-analysis                       │
├───────────────┼──────────────────────────────────────────┤
│  4. VALIDATE  │  /speckit.v-model.trace                   │
│               │  /speckit.v-model.peer-review              │
│               │  /speckit.v-model.audit-report             │
├───────────────┼──────────────────────────────────────────┤
│  5. COMMIT    │  git add . && git commit                  │
│               │  All changes are versioned and diffable   │
└─────────────────────────────────────────────────────────┘
```

---

## Key Takeaways

!!! abstract "What you've learned"

    1. **Impact analysis replaces guesswork** — instead of manually searching for affected artifacts, the tool gives you a deterministic list.
    2. **Three directions** serve different needs: `--downward` (requirement changed), `--upward` (test failed), `--full` (complete picture).
    3. **JSON output** enables CI integration — enforce blast-radius thresholds and traceability validation as merge gates.
    4. **Top-down regeneration** ensures consistency — always update artifacts from the changed level downward.
    5. **Every change is auditable** — the trace matrix, peer review, and audit report create a complete evidence trail that satisfies IEC 62304 and ISO 26262 change management requirements.

    **Impact analysis turns "what did I break?" anxiety into a deterministic, auditable process.**

---

## Next Steps

- **Start a full project**: Try the [Blood Glucose Monitor tutorial (IEC 62304)](medical-device.md) or [Automotive ADAS tutorial (ISO 26262)](automotive-adas.md) to build a complete artifact set from scratch.
- **Go deeper**: Read the [Installation guide](../getting-started/installation.md) for advanced configuration options.
