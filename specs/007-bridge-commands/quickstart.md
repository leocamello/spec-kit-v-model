# Quickstart: Bridge Commands (V-Model ↔ Spec-Kit Core)

**Feature**: 007-bridge-commands
**Branch**: `feature/007-bridge-commands` @ `8a2dc5d`
**Audience**: contributors validating end-to-end behaviour against
the acceptance plan; CI authors wiring the three new commands;
adopters trying the v0.7.0 surface for the first time.

This file is the human-facing replay of the three top user
stories. Each walkthrough is a faithful narration of one or more
SCN scenarios from
`specs/007-bridge-commands/v-model/acceptance-plan.md`. Every
command shown is real — none is invented; the sequencing and
artefact paths trace back to the listed SCN IDs.

> **Prerequisites for every walkthrough**:
> - `bats-core ≥ 1.10`, `Pester ≥ 5.5`, `pytest ≥ 8`,
>   `DeepEval` configured for `gemini-2.5-flash`
>   (constitution §Testing Stack).
> - Spec-kit core installed and `extension.yml` present at the
>   repository root.
> - A V-Model artifact set under
>   `specs/<feature>/v-model/`. Fixtures used below live under
>   `tests/fixtures/v-model/<scenario>/`.

---

## Walkthrough 1 — User Story 2: `v-model.plan` happy path

> Replays **SCN-001-A1** (full artifact set discovered) and
> **SCN-002-A1** (`plan.md` round-trips through unmodified
> `speckit.tasks`).

**Goal**: from a feature directory containing the complete
ten-artifact V-Model set plus the project constitution, produce
a `plan.md` that satisfies spec-kit-core's schema AND carries
V-Model enrichment.

**Steps**:

1. Create or check out the feature directory:

   ```bash
   ls specs/<feature>/v-model/
   # requirements.md acceptance-plan.md system-design.md
   # system-test.md architecture-design.md integration-test.md
   # module-design.md unit-test.md hazard-analysis.md
   # traceability-matrix.md
   ls .specify/memory/constitution.md
   ```

2. Invoke the bridge command:

   ```bash
   /speckit.v-model.plan
   ```

3. Inspect the structured stdout summary (Entity 10 of
   `data-model.md`; SYS-012):

   ```text
   --- v-model run summary ---
   inputs_read:
     - specs/<feature>/v-model/requirements.md
     - specs/<feature>/v-model/acceptance-plan.md
     - specs/<feature>/v-model/system-design.md
     - specs/<feature>/v-model/system-test.md
     - specs/<feature>/v-model/architecture-design.md
     - specs/<feature>/v-model/integration-test.md
     - specs/<feature>/v-model/module-design.md
     - specs/<feature>/v-model/unit-test.md
     - specs/<feature>/v-model/hazard-analysis.md
     - specs/<feature>/v-model/traceability-matrix.md
     - .specify/memory/constitution.md
   outputs_written:
     - specs/<feature>/plan.md
   exit_code: 0
   ---
   ```

   **Acceptance** (SCN-001-A1): `inputs_read` lists exactly those
   eleven file paths. (No phantom paths — that exclusion is
   verified by the SCN-001-B1 sibling scenario in the BATS
   suite.)

4. Round-trip the produced `plan.md` through unmodified
   `speckit.tasks`:

   ```bash
   /speckit.tasks         # spec-kit core's existing command
   echo $?                 # → 0
   test -s specs/<feature>/tasks.md
   ```

   **Acceptance** (SCN-002-A1): `speckit.tasks` exits 0 and
   `tasks.md` is non-empty.

5. Confirm the V-Model enrichment is additive (Entity 5 of
   `data-model.md`):

   ```bash
   grep -E '^<!-- v-model:' specs/<feature>/plan.md | head
   ```

**Cited V-Model IDs**: REQ-001, REQ-002, REQ-NF-005; SYS-001,
SYS-005, SYS-010, SYS-012; ARCH-001, ARCH-008, ARCH-013,
ARCH-016; MOD-001, MOD-002, MOD-011, MOD-021; ATP-001-A,
ATP-002-A; SCN-001-A1, SCN-002-A1.

**Failure modes worth knowing**:
- A missing optional artefact (e.g. `hazard-analysis.md`) does
  NOT abort; the artefact appears in `optional_artifacts_skipped`
  per SCN-001-B1.
- A schema-conformance failure aborts the run with exit 1 and a
  diff against the canonical template (ARCH-013, MOD-017).

---

## Walkthrough 2 — User Story 3: `v-model.tasks` with TDD ordering and hazard prioritisation

> Replays **SCN-011-A1** (TDD ordering enforced) and
> **SCN-014-B1** (per-HAZ verification task emitted).

**Goal**: from a `plan.md` and the V-Model artifact set
(including a hazard analysis with a Catastrophic-severity
`HAZ-001`), produce a `tasks.md` that (a) honours TDD ordering,
(b) raises the priority of mitigation tasks, (c) emits one
verification task per hazard.

**Steps**:

1. Confirm the inputs:

   ```bash
   ls specs/<feature>/plan.md
   grep -nE '^- HAZ-001' specs/<feature>/v-model/hazard-analysis.md
   # one row, severity Catastrophic, mitigation linked to MOD-002
   ```

2. Invoke the bridge command:

   ```bash
   /speckit.v-model.tasks
   ```

3. Inspect the emitted ordering. The structural-eval order
   check in
   `tests/evals/test_tasks_order.py` (UTP-011-A) replays this
   exact assertion:

   ```bash
   awk '/^## /{print NR": "$0}' specs/<feature>/tasks.md
   ```

   The expected sequence (SCN-011-A1) is:
   ```
   write-unit-tests → implement → run-unit-tests
   → write-integration-tests → run-integration-tests
   → write-system-tests → run-system-tests
   → write-acceptance-tests
   ```

4. Locate the MOD-002 implementation task and confirm the
   hazard-driven priority bump:

   ```bash
   grep -A1 'implement MOD-002' specs/<feature>/tasks.md
   # priority: high  ← elevated per REQ-014, SCN-014-A1
   # <!-- traces-to: MOD-002, HAZ-001 -->
   ```

5. Locate the dedicated hazard-verification task (SCN-014-B1):

   ```bash
   grep -nE '^- Verify mitigation for HAZ-001' specs/<feature>/tasks.md
   # exactly one match
   grep -nE '<!-- traces-to:.*HAZ-001 -->' specs/<feature>/tasks.md
   # appears on the same task
   ```

**Cited V-Model IDs**: REQ-011, REQ-012, REQ-013, REQ-014; SYS-002,
SYS-005, SYS-009; ARCH-003, ARCH-008, ARCH-012; MOD-003, MOD-004,
MOD-012, MOD-016; HAZ-016; ATP-011-A, ATP-012-A, ATP-013-A,
ATP-014-A, ATP-014-B; SCN-011-A1, SCN-012-A1, SCN-014-A1,
SCN-014-B1.

**Failure modes worth knowing**:
- A malformed `hazard-analysis.md` aborts the run fail-closed
  (REQ-014, HAZ-016) — no `tasks.md` is written.
- A task with no upstream V-Model ID is rejected by the
  hallucination guard before commit (REQ-023, ARCH-009).

---

## Walkthrough 3 — User Story 1: `v-model.implement` end-to-end

> Replays **SCN-015-A1** (self-sufficient direct path),
> **SCN-016-A1** + **SCN-016-B1** (gate refusal),
> **SCN-017-A1** (gate composition),
> **SCN-018-A1** (target-source-file mapping),
> **SCN-019-A1** (every public symbol carries an `Implements`
> comment), **SCN-020-A1** (tests at all four levels), and
> **SCN-021-A1** (commit subject suffix).

**Goal**: from a complete V-Model artifact set with a complete
trace matrix — and crucially **without** a `plan.md` or
`tasks.md` — produce source code, tests, and commits that all
satisfy the V-Model invariants.

**Steps**:

1. Confirm the inputs:

   ```bash
   ls specs/<feature>/v-model/traceability-matrix.md
   ! test -e specs/<feature>/plan.md
   ! test -e specs/<feature>/tasks.md
   ```

2. *(Pre-flight)* Run the gate **manually** to demonstrate
   refusal on a contrived gap (SCN-016-A1 / SCN-016-B1). Inject a
   missing SCN field in Matrix A, then:

   ```bash
   bash scripts/bash/run-v-model-gate.sh
   echo $?                # → 1
   # stdout: '... Matrix A: missing SCN for REQ-NNN ...'
   # final line: 'GATE: FAIL'
   # zero source files have been created
   ```

   Repair the matrix and retry; the run should now end in
   `GATE: PASS`.

3. Invoke the bridge command:

   ```bash
   /speckit.v-model.implement
   ```

4. Confirm the gate composition — the process trace must show
   exactly the existing scripts and no new wrapper (SCN-017-A1):

   ```bash
   strace -fe execve -o /tmp-not-allowed.trace … # use --output-file under .session-tmp/
   ```

   In practice this assertion is replayed by the BATS test in
   `tests/bats/run-v-model-gate.bats` (UTP-010-A), which records
   each `exec*` of `build-matrix.sh`,
   `validate-requirement-coverage.sh`,
   `validate-system-coverage.sh`,
   `validate-architecture-coverage.sh`,
   `validate-module-coverage.sh`,
   `validate-hazard-coverage.sh` and asserts no other wrapper
   script appears. (REQ-017, REQ-CN-002.)

5. Confirm target-source-file mapping (SCN-018-A1). For a
   `module-design.md` declaring `MOD-001` → `src/order/processor.py`
   and `MOD-002` → `src/order/notifier.py`:

   ```bash
   grep -n 'Implements MOD-001' src/order/processor.py
   grep -n 'Implements MOD-002' src/order/notifier.py
   ```

   Both files must contain the language-appropriate
   `Implements <MOD-NNN>` comment AND lie inside a managed
   sentinel block:

   ```bash
   grep -nE '<!-- BEGIN MANAGED id="MOD-001" -->' src/order/processor.py
   grep -nE '<!-- END MANAGED id="MOD-001" -->'   src/order/processor.py
   ```

6. Confirm public-symbol coverage (SCN-019-A1):

   ```bash
   pytest tests/evals/test_implements_per_symbol.py
   # 100% public symbols annotated
   ```

7. Confirm tests at all four levels (SCN-020-A1):

   ```bash
   ls tests/unit/        # ≥ 1
   ls tests/integration/ # ≥ 1
   ls tests/system/      # ≥ 1
   ls tests/acceptance/  # ≥ 1
   ```

8. Confirm hallucination guard ran (SYS-006 / ARCH-009 — D-004)
   and gated commit:

   ```bash
   bash scripts/bash/validate-implements-ids.sh \
        specs/<feature>/v-model src/ tests/
   echo $?                   # → 0
   # final line: 'GUARD: PASS'
   ```

9. Confirm commit-subject suffix (SCN-021-A1):

   ```bash
   git log --format='%s' -n 1
   # → '<subject> — MOD-001, MOD-002, REQ-008, HAZ-001'
   git log --format='%s' -n 5 \
     | grep -vE ' — (MOD|REQ|HAZ|SYS|ARCH)-[A-Z0-9-]+(, (MOD|REQ|HAZ|SYS|ARCH)-[A-Z0-9-]+)*$'
   # ← must produce zero output
   ```

10. Re-run idempotently (REQ-NF-005, REQ-022 — D-015 / D-016):

    ```bash
    cp src/order/processor.py /tmp-not-allowed.before
    # use a session-local scratch path under .session-tmp/ instead
    /speckit.v-model.implement   # second run
    diff src/order/processor.py .session-tmp/processor.py.before
    # zero diff outside the managed region
    ```

**Cited V-Model IDs**: REQ-015, REQ-016, REQ-017, REQ-018, REQ-019,
REQ-020, REQ-021, REQ-022, REQ-023, REQ-NF-002, REQ-NF-004,
REQ-NF-005, REQ-CN-002, REQ-CN-003, REQ-CN-004; SYS-003, SYS-004,
SYS-006, SYS-007, SYS-008, SYS-014, SYS-015; ARCH-004, ARCH-005,
ARCH-006, ARCH-007, ARCH-009, ARCH-010, ARCH-011, ARCH-017,
ARCH-018; MOD-005, MOD-006, MOD-007, MOD-008, MOD-009, MOD-010,
MOD-013, MOD-014, MOD-015, MOD-022, MOD-023, MOD-025; HAZ-007,
HAZ-009, HAZ-014, HAZ-021, HAZ-023, HAZ-025; ATP-015-A, ATP-016-A,
ATP-016-B, ATP-017-A, ATP-018-A, ATP-019-A, ATP-020-A, ATP-021-A;
SCN-015-A1, SCN-016-A1, SCN-016-B1, SCN-017-A1, SCN-018-A1,
SCN-019-A1, SCN-020-A1, SCN-021-A1.

**Failure modes worth knowing**:
- Any non-zero from the gate suppresses generation entirely; the
  command exits 1 and emits a precise gap report (REQ-016 /
  HAZ-009).
- Any unknown ID found by the hallucination guard suppresses
  commit; the offending `<file>:<line>` is reported but no
  source file is rewritten away from the mktemp staging copy
  (HAZ-007, D-016).
- A failed `git commit -m` inside §Commit Annotation issues a
  warning and proceeds without the suffix (ATP-021-A
  verification by Inspection).

---

## Replay-as-tests cross-reference

| Walkthrough | Replays | Test family | Gating script |
|-------------|---------|-------------|---------------|
| 1 | SCN-001-A1, SCN-002-A1 | `tests/evals/test_plan_inputs.py`, `tests/bats/validate-core-schema.bats` | `validate-core-schema.sh --plan` |
| 2 | SCN-011-A1, SCN-014-B1 | `tests/evals/test_tasks_order.py`, `tests/evals/test_hazard_tasks.py` | `validate-core-schema.sh --tasks` |
| 3 | SCN-015-A1 .. SCN-021-A1 | `tests/bats/run-v-model-gate.bats`, `tests/bats/validate-implements-ids.bats`, `tests/bats/splice-managed-regions.bats`, `tests/evals/test_implements_per_symbol.py` | `run-v-model-gate.sh`, `validate-implements-ids.sh`, `splice-managed-regions.sh` |

All scripts referenced above are the seven listed in `plan.md`
§Project Structure (4 new + 3 reused). All test files are
authored test-first per D-006. All SCN identifiers used in this
file resolve to existing scenarios in
`specs/007-bridge-commands/v-model/acceptance-plan.md`.
