---
description: V-Model-aware implementation bridge — runs the pre-implementation gate, generates code and four-level tests with Implements directives, splices into existing sources via sentinel-managed regions, self-checks for hallucinated IDs, runs the quality harness, and emits an annotated commit plus a structured run summary.
handoffs:
  - label: Run V-Model Trace
    agent: speckit.v-model.trace
    prompt: Validate end-to-end traceability after implementation
    send: true
  - label: Re-Tasks
    agent: speckit.v-model.tasks
    prompt: Re-derive the V-Model task list if implementation surfaced new modules or hazards
scripts:
  sh: .specify/scripts/bash/check-prerequisites.sh --json
  ps: .specify/scripts/powershell/check-prerequisites.ps1 -Json
---

<!-- Implements: REQ-015, REQ-016, REQ-017, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-027, REQ-NF-002, REQ-NF-004, REQ-NF-005, REQ-CN-002, REQ-CN-003, REQ-CN-004, SYS-003, SYS-004, SYS-006, SYS-007, SYS-008, SYS-012, SYS-014, ARCH-004, ARCH-005, ARCH-006, ARCH-007, ARCH-009, ARCH-010, ARCH-011, ARCH-016, ARCH-017, ARCH-018, MOD-005, MOD-006, MOD-007, MOD-008, MOD-009, MOD-013, MOD-015, MOD-021, MOD-022, MOD-023, HAZ-007, HAZ-009, HAZ-014, HAZ-021, HAZ-023, HAZ-025, D-001, D-014 -->

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal

Drive the right-hand side of the V-Model from a TDD-ordered `tasks.md` to a single annotated commit. This command is the third and heaviest of the bridge commands: it orchestrates the pre-implementation gate, V-Model-aware code and test generation across four levels, sentinel-managed splicing into pre-existing sources, an `Implements:` hallucination self-check, the project quality harness, and a commit-subject suffix that pins the change to the V-Model identifiers it satisfies (REQ-015, REQ-016, SYS-003, ARCH-004, MOD-005).

The operative philosophy is **fail-fast**: the V-Model gate (ARCH-007) runs **before any codegen**, the hallucination guard (ARCH-009) runs **before any commit**, and either non-zero verdict aborts with an empty workspace and a populated `fatal_errors[]` (REQ-016, REQ-NF-004, REQ-CN-002, HAZ-007, HAZ-009). Code and tests are emitted with explicit `Implements: <ID>` traceability comments — these are the input to the guard, so the order is: generate → guard → commit, never any other permutation (REQ-018, REQ-019, REQ-023, D-004, D-008).

Modifications of pre-existing source files are **never** ad-hoc: every write goes through the sentinel-managed region splicer (ARCH-010, MOD-014 — not enumerated in T016 but the underlying mechanism), which atomically replaces only the bytes between `<!-- BEGIN MANAGED id="<region>" -->` and `<!-- END MANAGED id="<region>" -->` and refuses on unbalanced or overlapping markers (REQ-022, REQ-CN-003, REQ-CN-004, D-001, D-015, D-016, HAZ-014, HAZ-025). The paradigm remains Markdown prompt + shell + YAML; no new Python is introduced (D-001).

The command is **graceful** in exactly one direction: missing optional V-Model artefacts trigger the reduced-enrichment fallback (ARCH-014 conceptually; D-014) — never silently. The gate, the splicer, and the guard remain hard gates regardless of fallback state. On every exit path — success or failure — the structured run summary is flushed to stdout (REQ-027, ARCH-016, MOD-021, SYS-012).

**Non-goals**: this command does NOT mutate any V-Model artefact, re-run hazard analysis, regenerate the traceability matrix, or rewrite `tasks.md`. It is a pure executor over the inputs handed to it by `/speckit.v-model.tasks`.

## Execution Steps

### 1. Setup

Run `{SCRIPT}` from the repository root and parse the JSON output. Required keys: `FEATURE_DIR`, `AVAILABLE_DOCS`, `BRANCH`. The V-Model directory is `FEATURE_DIR/v-model/` (may be absent on greenfield features).

For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

Read `.specify/memory/constitution.md`. Read `FEATURE_DIR/tasks.md` (required — this is the V-Model-ordered task list from `/speckit.v-model.tasks`). Read `FEATURE_DIR/plan.md`, `FEATURE_DIR/spec.md`, and every doc named in `AVAILABLE_DOCS` (`data-model.md`, `contracts/`, `research.md`, `quickstart.md`).

If `FEATURE_DIR/v-model/` exists, read **every** V-Model artefact present natively as Markdown — no parser is shipped. Record the read set as `inputs_read[]` and the missing optional set as `artifacts_skipped[]`. The expected set per ARCH-004 preconditions is `requirements.md`, `module-design.md`, `unit-test.md`, `integration-test.md`, `system-test.md`, `acceptance-plan.md`; `hazard-analysis.md` is optional but its absence triggers the reduced-enrichment branch in Step 9 (D-014, MOD-005).

**Refuse to proceed** if `tasks.md` is absent or unparseable: emit §Structured Summary with `fatal_errors: ["tasks.md required"]`, exit 1.

### 2. Pre-implementation gate (per ARCH-007, MOD-010 → T008, REQ-016, REQ-NF-004, REQ-CN-002, D-003)

Invoke the gate wrapper (reusing the script delivered in Step B.2 / T008):

```bash
bash scripts/bash/run-v-model-gate.sh "$FEATURE_DIR"
```

The wrapper concatenates `build-matrix.sh` + the five `validate-*-coverage.sh` scripts (D-003) and terminates stdout with exactly `GATE: PASS` or `GATE: FAIL`.

- `GATE: FAIL` ⇒ append the wrapper's stdout into `fatal_errors[]`, emit §Structured Summary, exit 1. **No code generation runs.** (HAZ-009 false-negative-gate and HAZ-010 false-positive-gate are jointly mitigated by reusing the validated inner scripts.)
- `GATE: PASS` ⇒ proceed to Step 3.

### 3. Domain overlay (per ARCH-011, MOD-015, REQ-024)

If `v-model-config.yml` exists at the repository root, parse its `domain:` value (e.g. `automotive`, `medical`, `aerospace`) and load any prompt augmentation under `overlays/<domain>/`. Augmentation is **purely additive** — base instructions for §Code Generation and §Test Generation are NEVER overridden (ARCH-011, MOD-015 = Domain Overlay Adapter; cf. SYS-008).

A malformed `v-model-config.yml` (unparseable YAML, missing `domain:` key, or the named overlay directory is absent) is fail-closed: append the parser stderr to `fatal_errors[]`, emit §Structured Summary, exit 1. Absence of the file is normal — base behaviour applies.

### 4. Code generation (per ARCH-005, MOD-006, MOD-007, REQ-018, REQ-019)

For each pending task in `tasks.md` whose subject is a `MOD-NNN` row in `module-design.md`:

1. Resolve the Target Source File and target language declared in the MOD row.
2. Render the module body following the task description and any §Domain Overlay augmentation.
3. Emit a language-appropriate `Implements: <ID, ID, …>` header comment listing every V-Model ID the file satisfies — at minimum the `MOD-NNN` and its parent `ARCH-NNN`; per public symbol, attach an additional `Implements: <ID>` line per REQ-019 / SCN-019-A1.

These `Implements:` comments are the **sole** input to the hallucination guard in Step 7 — every cited ID must already exist in the V-Model artefact set or the guard will reject the change (REQ-023, REQ-NF-002, MOD-013, MOD-025).

### 5. Four-level test generation (per ARCH-006, MOD-008, MOD-009, REQ-020, SYS-003)

Emit tests at **all four V-Model levels** into the project's existing test directories:

- **Unit** (`tests/unit/`) — one or more files per `UTP-NNN` / `UTS-NNN-XN` in `unit-test.md`.
- **Integration** (`tests/integration/`) — per `ITP-NNN` / `ITS-NNN-XN` in `integration-test.md`.
- **System** (`tests/system/`) — per `STP-NNN` / `STS-NNN-XN` in `system-test.md`.
- **Acceptance** (`tests/acceptance/`) — per `ATP-NNN` / `SCN-NNN-XN` in `acceptance-plan.md` (subject to the reduced-enrichment branch in Step 9 if `acceptance-plan.md` is absent).

Each generated test carries the same `Implements: <UTP|ITP|STP|ATP|SCN-NNN, …>` directive convention as Step 4. At least one file MUST appear under each of the four directories on the success path per SCN-020-A1 (or be explicitly accounted for in `artifacts_skipped[]`).

A test-plan artefact that is present but fails to parse is fail-closed: append the parser diagnostic to `fatal_errors[]`, emit §Structured Summary, exit 1 (ARCH-006 error path).

### 6. Sentinel-managed splicing into existing sources (per ARCH-010, REQ-022, REQ-CN-003, REQ-CN-004, REQ-NF-005, D-001, D-015, D-016)

For any modification of a **pre-existing** source file (Steps 4 and 5 above, when the target file already exists on disk), use the splicer delivered in Step B.2 / T010 — never write the whole file:

```bash
bash scripts/bash/splice-managed-regions.sh \
    "<target-file>" "<generated-region-file>" "<language>"
```

The script writes the spliced content to **stdout only**; the **caller** is responsible for the atomic-rename idiom (D-016, REQ-NF-005, MOD-002 — the same `mktemp` + `mv` pattern enforced in `commands/plan.md` Step 4):

```bash
tmp=$(mktemp -p "$(dirname "$target")")
bash scripts/bash/splice-managed-regions.sh "$target" "$gen" "$lang" > "$tmp"
mv "$tmp" "$target"
```

Marker grammar per D-015: `<!-- BEGIN MANAGED id="<region>" -->` / `<!-- END MANAGED id="<region>" -->` (or the language-equivalent comment syntax — `# … #`, `// … //`). On unbalanced, overlapping, or duplicate markers the splicer exits 1 with a diff on stderr and **leaves the original file untouched**; propagate the diff into `fatal_errors[]`, emit §Structured Summary, exit 1 (HAZ-014 region-marker corruption, HAZ-025 truncated-content). **Never write to `/tmp`** — the `-p "$(dirname "$target")"` argument keeps the temporary file on the same filesystem as its destination.

Code outside the managed region must remain byte-identical (ATP-022-A). This is the SOLE concurrency safeguard delivered for pre-existing sources in v0.7.0 — process-wide locking is deferred (SYS-007 / SYS-015 §Risk Note).

### 7. Hallucination-guard self-check (per ARCH-009, MOD-013, REQ-023, REQ-NF-002, D-004, D-008)

Invoke the guard wrapper (reusing the script delivered in Step B.2 / T009) over the feature directory after Steps 4–6 have written every generated and spliced file:

```bash
bash scripts/bash/validate-implements-ids.sh "$FEATURE_DIR"
```

The script greps the canonical V-Model ID set out of `<FEATURE_DIR>/v-model/*.md`, scans every generated source for `Implements: <ID>` (and language-equivalent) comments, and prints `<file>:<line>: unknown id <id>` for every offence, terminating with exactly `GUARD: PASS` or `GUARD: FAIL`. There is no LLM in this loop — determinism is the contract (Constitution Principle II; D-004).

- `GUARD: FAIL` ⇒ STOP. Append the offending lines into `fatal_errors[]`, emit §Structured Summary, exit 1. **Do NOT commit.** This guards HAZ-007 (hallucinated `Implements` directive), HAZ-012 (false-negative), and HAZ-023 (stale snapshot — mitigated by running the guard immediately before Step 9, never earlier).
- `GUARD: PASS` ⇒ proceed to Step 8.

### 8. Quality / compliance harness (per ARCH-017, MOD-022, REQ-CN-003, REQ-CN-004)

Run the project's existing four-stack harnesses; do not introduce new tooling:

1. `bash tests/bats/run-bats.sh` (or the project's BATS entry).
2. `bash tests/pester/run-pester.sh` when the PowerShell stack is present.
3. `bash tests/evals/structural-eval.sh` (pytest-driven structural eval).
4. `bash tests/evals/llm-eval.sh` (DeepEval LLM eval).

Aggregate exit codes; any non-zero ⇒ append the failing harness summary into `fatal_errors[]`, emit §Structured Summary, **block the commit**, exit 1 (ARCH-017 merge-gate). The sole escape hatch is an explicit `--allow-failing-quality` argument on the `$ARGUMENTS` line; if present, downgrade the failure to a `warnings[]` entry and record the override under `risk_acceptances[]` of the §Structured Summary so the bypass is auditable (HAZ-021 — coverage-gate-not-enforced).

### 9. Reduced-enrichment fallback (per ARCH-014 conceptually; D-014)

For each **optional** V-Model artefact missing from `FEATURE_DIR/v-model/` — typically `acceptance-plan.md` (skips Step 5 acceptance-level emission) or `hazard-analysis.md` (skips hazard-driven elevation in upstream `tasks.md` consumption) — record an explanatory marker in the run summary and an inline HTML comment in any generated file whose content was reduced:

```
<!-- v-model: <step> reduced — <artefact> missing/empty -->
```

**Never silently degrade.** Reduced enrichment is a successful, observable outcome — exit 0 with `warnings[]` populated and `artifacts_skipped[]` listing the missing inputs (D-014). The hard gates of Steps 2 and 7 are NOT bypassed by this branch.

### 10. Commit annotation (per ARCH-018, MOD-023, REQ-021, REQ-NF-005)

Precondition: Step 7 emitted `GUARD: PASS` and Step 8 emitted `quality: PASS` (or recorded an explicit `--allow-failing-quality` risk acceptance).

Construct the commit subject as the conventional spec-kit-core base message followed by an em-dash and a comma-separated list of every V-Model ID fulfilled by the change, derived from the in-context generation plan (MOD-023):

```
<base-message> — <ID>, <ID>, …
```

Empty ID list ⇒ commit with the unannotated base message and a `warnings[]` entry; an annotation-construction failure is a warning, not fatal (best-effort per ATP-021-A). The body lists files modified, levels generated (U / I / S / A counts), gate verdict, guard verdict, and any active fallbacks.

Issue `git commit -m "<message>"`. A `git commit` non-zero is fatal: append stderr to `fatal_errors[]`, emit §Structured Summary, exit 1.

### 11. Structured Summary (per ARCH-016, MOD-021, SYS-012, REQ-027)

On every exit path (success **and** failure), flush stdout and emit:

```
--- v-model implement summary ---
branch: <name>
feature: <id>
inputs_read:
  - <path>
artifacts_skipped:
  - <name>
gate: PASS | FAIL (<details if FAIL>)
codegen: <N> source files, <M> lines
testgen: U=<n> I=<n> S=<n> A=<n>
splice: <N> regions updated across <M> files
guard: PASS | FAIL (<details if FAIL>)
quality: PASS | FAIL (<harness summary>)
risk_acceptances:
  - <text>          # omit key when empty
warnings:
  - <text>
fatal_errors:
  - <text>          # omit key on success
commit: <SHA> | <skipped — reason>
fallbacks: <list, or "none">
--- end summary ---
```

This block is the contract for downstream consumers — CI parsers, the `v-model.trace` bridge, audit tooling. Truncation is itself a hazard (HAZ-025 mitigation).

### 12. Handoffs

On success, recommend `/speckit.v-model.trace` to validate the full upstream-to-downstream trace after implementation. The frontmatter's secondary handoff exposes a re-tasks path for when implementation surfaced new modules or hazards.

## Quality criteria

Self-check **every** invariant below; any violation forces re-emission with the offending step's `fatal_errors[]` populated:

- The pre-implementation gate (Step 2) ran and emitted `GATE: PASS` **before** any byte of code or test was generated (REQ-016, ARCH-007, MOD-005).
- The hallucination guard (Step 7) ran and emitted `GUARD: PASS` **before** any `git commit` was issued (REQ-023, ARCH-009, MOD-013).
- Every generated source and test file carries an `Implements: <ID, …>` header naming ≥1 V-Model ID; every public symbol additionally carries an `Implements: <ID>` comment per REQ-019.
- Every modification of a pre-existing source went through `splice-managed-regions.sh` and the caller's `mktemp` + `mv` atomic-rename idiom; **no write touched `/tmp`** (REQ-CN-003, REQ-CN-004, REQ-NF-005, D-016).
- Tests appear at all four V-Model levels (U / I / S / A) — or each absent level is named in `artifacts_skipped[]` with the upstream artefact that triggered the reduction (REQ-020, SYS-003, D-014).
- The §Structured Summary is flushed on success **and** every failure exit path; `fatal_errors[]` is empty on success and present-with-content on every failure (REQ-027, MOD-021, SYS-012, HAZ-025).
- No fabricated V-Model identifiers appear anywhere in generated content — every cited ID is grep-resolvable in `FEATURE_DIR/v-model/` (REQ-NF-002, MOD-013, HAZ-007).
- The commit subject matches the `<base> — <ID>, <ID>, …` regex on the success path, or carries the documented unannotated-warning entry (REQ-021, ARCH-018, MOD-023).

## Failure modes & recovery

| Failure | Detection | User-facing recovery |
|---|---|---|
| `tasks.md` missing/unparseable | Step 1 read | `fatal_errors: ["tasks.md required"]`, exit 1; user runs `/speckit.v-model.tasks` first. |
| `GATE: FAIL` from `run-v-model-gate.sh` | Step 2 | Append wrapper stdout to `fatal_errors[]`; **no codegen**; exit 1; user closes the missing-coverage rows reported by the inner validators (HAZ-009, HAZ-010). |
| `v-model-config.yml` malformed | Step 3 parse | Fail-closed; exit 1; user fixes the YAML or removes the file (ARCH-011). |
| Test-plan artefact present but unparseable | Step 5 parse | `fatal_errors: ["<artefact> unparseable"]`, exit 1; user repairs the plan (ARCH-006). |
| Splicer reports unbalanced/overlapping markers | Step 6 | Original file untouched (script writes to stdout only); propagate stderr diff into `fatal_errors[]`, exit 1; user repairs the markers (HAZ-014, HAZ-025, D-015). |
| Atomic-rename failure (disk full, permissions) | `mv` non-zero in Step 6 | `fatal_errors: ["write failed: <path>"]`, exit 1; no partial file remains (REQ-NF-005, D-016, HAZ-014). |
| `GUARD: FAIL` from `validate-implements-ids.sh` | Step 7 | Append offending `<file>:<line>: unknown id <id>` lines to `fatal_errors[]`; **no commit**; exit 1; user removes or corrects the hallucinated IDs (HAZ-007, HAZ-012, HAZ-023). |
| Quality harness <100% (no override) | Step 8 | `fatal_errors[]` populated with the failing harness summary; commit blocked; exit 1 (ARCH-017, HAZ-021). |
| Quality harness <100% with `--allow-failing-quality` | Step 8 + arg parse | Downgrade to `warnings[]`; record under `risk_acceptances[]`; proceed; commit subject body annotates the override (HAZ-021 explicit acceptance). |
| Optional artefact missing | Step 1 read; Step 9 | Reduced-enrichment fallback; named in `artifacts_skipped[]`; inline `<!-- v-model: … reduced -->` markers; exit 0 (D-014). |
| `git commit` non-zero | Step 10 | `fatal_errors: ["git commit failed: <stderr>"]`, exit 1; user resolves the staging-area or hook failure (ARCH-018). |
| Partial codegen interrupted (signal, OOM) | post-mortem | Re-run is idempotent: gate re-evaluates, splicer regenerates only the managed regions, guard re-validates; commit will only annotate IDs from the completed run (D-016, ARCH-010). |
| §Structured Summary truncated | Step 11 flush failure | Last-resort: emit `--- v-model implement summary --- fatal_errors: [summary truncated] --- end summary ---`; exit 1 (HAZ-025, MOD-021). |

## Operating Constraints

### Additive-only modification of pre-existing sources

Pre-existing source files are mutated **only** between sentinel markers via `splice-managed-regions.sh`. Lines outside the managed region are byte-identical pre/post (REQ-022, REQ-CN-003, REQ-CN-004, ARCH-010, D-015).

### Fail-fast ordering

Gate before codegen; guard before commit. Either non-zero is a hard exit with `fatal_errors[]` populated and an empty workspace beyond what the gate had read (REQ-016, REQ-023, ARCH-007, ARCH-009, HAZ-007, HAZ-009).

### Atomic writes; never `/tmp`

Every write to disk uses the inline `mktemp -p "$(dirname "$f")"` + `mv` idiom on the same filesystem as the destination. No path under `/tmp` is ever opened for write (REQ-NF-005, D-016).

### Stateless re-runnability

Every run regenerates outputs from `tasks.md` + the V-Model artefact set; there is no cache. Sentinel-managed splicing (D-015, D-016) and the `Implements: <ID>` directive convention together make re-runs idempotent: a no-op input produces a no-op commit (`git commit` exits non-zero on an empty diff and the structured summary records `commit: skipped — empty diff` as a warning, not a fatal error). The paradigm remains Markdown prompt + shell + YAML; no Python is introduced (D-001).
