# System Design: Bridge Commands

**Feature Branch**: `feature/007-bridge-commands`
**Created**: 2026-04-26
**Status**: Draft
**Source**: `specs/007-bridge-commands/v-model/requirements.md`

## Overview

The bridge-commands feature is decomposed into three top-level command
subsystems (`v-model.plan`, `v-model.tasks`, `v-model.implement`) plus a set
of cross-cutting components that the three commands share. Each command is
realised, in line with the project's existing 13 commands, as a **Markdown
prompt file** under `commands/<name>.md` (with YAML frontmatter declaring
description, handoffs, and a single `scripts:` entry pointing at one Bash
script and its PowerShell mirror) backed by **Bash scripts** under
`scripts/bash/<name>.sh` for the deterministic pre-processing and
verification steps. No Python implementation code is introduced by this
feature: orchestration logic lives in the LLM prompt, deterministic logic
lives in shell, and registration is declarative YAML consumed by spec-kit
core.

The cross-cutting components implement the additive-enrichment pattern, the
spec-kit-core compatibility layer, the pre-implementation gate (which
delegates entirely to existing `validate-*-coverage.sh` and
`build-matrix.sh` scripts), and the safety-net checks (hallucination guard
via grep, source-region preservation via awk + atomic `mktemp`/`mv`). This
decomposition isolates the "what each command does" responsibility (LLM
prompt sections in `commands/*.md`) from the "how the contract with
spec-kit core is preserved" responsibility (shell verifiers and the pinned
schema fixtures they consult), so the compatibility layer can be tested
and evolved independently of the command business logic.

No domain overlay is loaded for this feature (`v-model-config.yml` is
absent at the repository root); only the base IEEE 1016 design views are
populated, and no safety-integrity sections (FFI, restricted complexity,
ASIL allocation) are required.

## ID Schema

- **System Component**: `SYS-NNN` — sequential identifier, never renumbered.
- **Parent Requirements**: Comma-separated `REQ-NNN` list per component
  (many-to-many). Coverage is computed against the active requirement set in
  `requirements.md`.
- Example: `SYS-001` with Parent Requirements `REQ-001, REQ-002, REQ-003, ...`
  — the component satisfies every listed requirement.

## Decomposition View (IEEE 1016 §5.1)

| SYS ID | Name | Description | Parent Requirements | Type |
|--------|------|-------------|---------------------|------|
| SYS-001 | Plan Synthesizer | Implements `/speckit.v-model.plan` as a Markdown prompt file. Reads every V-Model artifact present in the feature directory plus the project constitution, then emits a spec-kit-core-compatible `plan.md`, a `data-model.md` extracted from the Data Design view, a `contracts/` directory extracted from the Architecture Interface view, a `quickstart.md` derived from top acceptance scenarios, and a `research.md` aggregating derivation flags. Gracefully degrades with a warning summary when optional inputs are absent. | REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-008, REQ-026, REQ-027, REQ-NF-005, REQ-IF-001 | Subsystem |
| SYS-002 | Tasks Synthesizer | Implements `/speckit.v-model.tasks` as a Markdown prompt file. Reads every V-Model artifact present plus `plan.md` (whether produced by `v-model.plan` or `speckit.plan`) and emits a spec-kit-core-compatible `tasks.md`. Orders tasks TDD-style across unit / integration / system / acceptance levels and applies the `[P]` parallel-execution marker for independent modules within the same architecture. | REQ-009, REQ-010, REQ-011, REQ-013, REQ-014, REQ-026, REQ-027, REQ-NF-005, REQ-IF-002 | Subsystem |
| SYS-003 | Implementation Engine | Implements `/speckit.v-model.implement` as a Markdown prompt file. Reads V-Model artifacts directly from the feature directory (no intermediate `plan.md` / `tasks.md` required), generates source code into the Target Source File path declared by each `MOD-NNN`, generates tests at all four levels (unit / integration / system / acceptance), embeds `// Implements <ID>` traceability comments, honours the configured domain overlay, and is idempotent across re-runs (≥95% structural identity). | REQ-015, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-005 | Subsystem |
| SYS-004 | Pre-Implementation Gate | Composite quality gate executed by SYS-003 before any code generation, realised as the thin Bash wrapper `scripts/bash/run-v-model-gate.sh` (~30 lines). The wrapper invokes the existing scripts `build-matrix.sh`, `validate-requirement-coverage.sh`, `validate-system-coverage.sh`, `validate-architecture-coverage.sh`, `validate-module-coverage.sh`, and `validate-hazard-coverage.sh` in sequence, refuses to proceed (non-zero exit + gap report to stdout) when Matrix A, B, C, D, or H is incomplete, and aggregates exit codes; introduces no parallel gating logic, only orchestration. | REQ-016, REQ-017, REQ-NF-004, REQ-CN-002 | Module |
| SYS-005 | Additive-Enrichment Encoder | Cross-cutting prompt-section used by SYS-001 and SYS-002 to layer V-Model traceability metadata onto canonical spec-kit-core outputs as HTML comments and optional Markdown sections. Realised as the "## Requirement Linkage" / "## Enrichment" sections inside `commands/plan.md` and the "## Traceability" section inside `commands/tasks.md`, instructing the LLM to inject `<!-- vmodel:traces ... -->` and `<!-- traces-to: ... -->` markers. Guarantees that an unmodified spec-kit-core release pinned at v0.7.0 parses every emitted artifact without error, warning, or unrecognised-token diagnostic. | REQ-007, REQ-012, REQ-NF-003, REQ-IF-001, REQ-IF-002 | Service |
| SYS-006 | Hallucination Guard | Pre-commit self-verification realised as the Bash script `scripts/bash/validate-implements-ids.sh` (~80 lines). Greps every generated source file for `// Implements <ID>` (and language-equivalent) comments, cross-references each cited identifier against the canonical ID set extracted by `grep -oE '(REQ\|SYS\|ARCH\|MOD\|HAZ\|ATP\|ITP\|UTP)-[A-Z0-9-]+' specs/<feature>/v-model/*.md`, and aborts the run (non-zero exit, no commit) on any mismatch. Provides the structural-eval ID-validation evidence required for 100% pass rate. Deterministic, no LLM. | REQ-023, REQ-NF-002 | Service |
| SYS-007 | Source Region Manager | Realised as the Bash/awk script `scripts/bash/splice-managed-regions.sh` (~80 lines), invoked by `commands/implement.md` on every re-run. Locates the `<!-- BEGIN MANAGED id="..." -->` / `<!-- END MANAGED id="..." -->` sentinel pairs (or language-equivalent comment markers) inside target source files, replaces only the interior content, and preserves any user-authored content located outside the sentinels. Atomic write is guaranteed by the standard `tmp=$(mktemp -p "$(dirname "$f")"); ... ; mv "$tmp" "$f"` pattern; idempotent — running twice produces the same on-disk result. Enables the Hybrid user path. | REQ-022 | Module |
| SYS-008 | Domain Overlay Adapter | Cross-cutting prompt-section in `commands/implement.md` ("## Domain Overlay") that instructs the LLM to read `v-model-config.yml` (when present) and apply overlay-specific output requirements to code and test generation, including MC/DC unit-test coverage for DO-178C Level A and ASIL-driven test depth for ISO 26262. The same prompt section also instructs the LLM to consult `commands/overlays/{domain}/_domain.yml` for the authoritative overlay manifest. No runtime adapter code is required. | REQ-024 | Module |
| SYS-009 | Hazard-Driven Task Emitter | Prompt-section in `commands/tasks.md` ("## Hazard Enrichment") that activates when `hazard-analysis.md` is present in the feature directory: instructs the LLM to raise mitigation-task priority and to emit dedicated verification tasks that explicitly reference each `HAZ-NNN` identifier. | REQ-014 | Module |
| SYS-010 | Spec-Kit Core Compatibility Layer | Realised in two parts: (a) prompt-side, an "## Output Format" section in `commands/plan.md` and `commands/tasks.md` instructing the LLM to render the canonical spec-kit-core schema for the v0.7.0-pinned `plan-template.md` / `tasks-template.md`; and (b) shell-side, the verifier `scripts/bash/validate-core-schema.sh` (~50 lines) which greps for the required section headings per the pinned schema and exits non-zero on any missing section. Owns the round-trip property (`v-model.plan` → `speckit.tasks`, `v-model.tasks` → `speckit.implement`) and implements the reduced-enrichment fallback (the prompt instructs the LLM, when an upstream `plan.md` lacks `<!-- vmodel:` markers, to populate traceability directly from V-Model artifacts). Holds the `MUST NOT modify spec-kit core` invariant. | REQ-028, REQ-029, REQ-IF-001, REQ-IF-002, REQ-CN-001 | Library |
| SYS-011 | Hook Registrar | Realised by three declarative YAML entries appended to `extension.yml` at the repository root (no runtime code in this extension). Spec-kit core's `CommandRegistrar` class in `src/specify_cli/extensions.py` reads `extension.yml` at install time and wires the three new commands (`plan`, `tasks`, `implement`) and their hooks (`after_specify` → `v-model.requirements`; `before_implement` and `after_implement` → `v-model.trace`) into the spec-kit CLI namespace. The existing hook infrastructure is untouched. | REQ-IF-003, REQ-IF-005, REQ-NF-006 | Module |
| SYS-012 | Structured Summary Reporter | Cross-cutting prompt-section ("## Observability" / "## Structured Summary") appended to each of `commands/plan.md`, `commands/tasks.md`, and `commands/implement.md`. Instructs the LLM to emit a machine-readable stdout summary (timestamp, command, phase, outcome, every input artifact read, every output artifact produced, every optional artifact skipped, every warning encountered) in the same `--- v-model run summary ---` conventions used by `v-model.test-results` and `v-model.audit-report`. Shell wrappers capture the summary via stdout/stderr redirection. | REQ-027, REQ-IF-004 | Module |
| SYS-013 | Concurrent Write Safety (Deferred Risk Note) | The Markdown+shell paradigm is sequential by nature: each bridge command is a single LLM turn followed by one or more shell-script invocations, and concurrent invocations of the same command against the same feature directory are out of scope for the v0.7.0 release. SYS-013 therefore retains its identifier as a documented deferred-risk note rather than an active runtime component. The sole concurrency safeguard in v0.7.0 is the `mktemp`-into-same-directory + `mv` atomic-rename pattern used by SYS-007 (and by any other shell script that mutates a tracked file), which prevents partial-write corruption of a single target by a single process. Full concurrent-write safety (e.g., a process-wide `flock` advisory lock around the gate / splice / commit sequence) is deferred to a future shell-locking mechanism and is explicitly NOT delivered under this feature. | (deferred — no active REQ-NNN binding under v0.7.0) | Deferred Risk Note |
| SYS-014 | Commit Annotator | Prompt-section in `commands/implement.md` ("## Commit Annotation") that instructs the LLM, when issuing `git commit -m "..."` after successful generation, to suffix the commit message with the comma-separated list of V-Model identifiers fulfilled by the change (e.g., `feat(<scope>): <subject> — MOD-NNN, REQ-NNN`). Enables git-history-based traceability. | REQ-021 | Module |

## Realisation View

The following 14 subsections enumerate each system component's realisation
in the Markdown+shell paradigm. Every subsection states (1) the
classification per the paradigm-drift audit
(`REUSE-CORE` / `REUSE-OURS` / `NEW-PROMPT-SECTION` / `NEW-SHELL` /
`DEFERRED`), (2) the concrete file(s) and section(s) that realise the
component, and (3) the runtime responsibilities. ARCH-NNN and MOD-NNN
references in this file are deliberately preserved as forward references
to the architecture-design and module-design artifacts, which will be
reworked separately under the same paradigm.

### SYS-001 — Plan Synthesizer

- **Classification**: NEW-PROMPT-SECTION
- **Realised by**: `commands/plan.md` (to be created), specifically the
  "## Command: plan" section in its body.
- **Responsibilities**:
  - Route user intent via the Markdown prompt.
  - Parse `--phase`, `--scope`, and `--output-format` flags from
    `$ARGUMENTS`.
  - Emit structured artefact metadata (paths and identifiers of every
    output file).
  - Delegate heavy lifting (gate evaluation, schema verification, ID
    validation, region splicing) to subordinate SYS components via the
    Markdown prompt's `scripts:` frontmatter and inline `run_command`
    invocations.

### SYS-002 — Phase-Aware Context Assembly (Tasks Synthesizer)

- **Classification**: NEW-PROMPT-SECTION
- **Realised by**: `commands/plan.md` "## Context Assembly" section (and
  the equivalent "## Context Assembly" section inside `commands/tasks.md`
  for the tasks side).
- **Responsibilities**:
  - Collect the active phase (plan / tasks / implement) from workspace
    state.
  - Load the linked V-Model requirements set from the feature directory.
  - Emit a phase-scoped context block consumed by every subsequent prompt
    step in the same command.

### SYS-003 — Artefact Generation Pipeline (Implementation Engine)

- **Classification**: NEW-PROMPT-SECTION
- **Realised by**: `commands/tasks.md` "## Artefact Generation" section
  and the corresponding "## Artefact Generation" section in
  `commands/implement.md`.
- **Responsibilities**:
  - Produce work-package Markdown with explicit V-model phase tags
    (Verification / Validation / Implementation).
  - Stamp every emitted file with the upstream V-Model identifiers it
    realises.
  - Hand off to SYS-007 (region splicer) for any file that already exists.

### SYS-004 — Pre-Implementation Gate

- **Classification**: REUSE-OURS + NEW-SHELL
- **Realised by**:
  - **Existing scripts (REUSE-OURS)**:
    `scripts/bash/validate-requirement-coverage.sh`,
    `scripts/bash/validate-system-coverage.sh`,
    `scripts/bash/validate-architecture-coverage.sh`,
    `scripts/bash/validate-module-coverage.sh`,
    `scripts/bash/validate-hazard-coverage.sh`, and
    `scripts/bash/build-matrix.sh`.
  - **Net-new wrapper (NEW-SHELL)**:
    `scripts/bash/run-v-model-gate.sh` (~30 lines) — a thin orchestrator
    invoking each `validate-*` script in sequence and aggregating exit
    codes; exits non-zero on the first failure so SYS-003's prompt can
    fail closed.
- **Responsibilities**: enforce that all V-Model gate conditions pass
  before allowing the implement phase; each `validate-*` script checks
  one coverage dimension; the wrapper aggregates results and prints a
  consolidated gap report on stdout.

### SYS-005 — Requirement Linkage Tracker (Additive-Enrichment Encoder)

- **Classification**: NEW-PROMPT-SECTION
- **Realised by**: "## Requirement Linkage" section inside
  `commands/plan.md` and the equivalent "## Traceability" section inside
  `commands/tasks.md`.
- **Responsibilities**: prompt instructs the model to emit `REQ-NNN`
  anchors (and `<!-- vmodel:traces ... -->` HTML-comment blocks) in every
  output artefact, so that downstream tooling can rebuild the traceability
  matrix without reading any auxiliary index.

### SYS-006 — Hallucination Guard / Implements-ID Validator

- **Classification**: NEW-SHELL
- **Realised by**: `scripts/bash/validate-implements-ids.sh` (~80 lines).
- **Responsibilities**:
  - Grep every `commands/*.md`, every newly generated source file passed
    on the command line, and (for the optional self-check) every
    `scripts/bash/*.sh` for `<!-- implements: REQ-NNN -->` and
    `// Implements <ID>` (language-equivalent) comments.
  - Cross-reference the cited identifiers against the canonical ID set
    extracted by an inline `grep -oE` pipeline over
    `specs/<feature>/v-model/*.md`.
  - Report any cited identifier that does not exist; exit non-zero if
    mismatches are found.
- **Core**: a 5-line `grep | sort -u` pipeline followed by a reporting
  loop; no LLM, no Python, no external dependencies beyond `grep`, `awk`,
  and `sort`.

### SYS-007 — Source Region Splicing

- **Classification**: NEW-SHELL
- **Realised by**: `scripts/bash/splice-managed-regions.sh` (~80 lines,
  awk-based).
- **Responsibilities**:
  - Locate `<!-- BEGIN MANAGED id="..." -->` / `<!-- END MANAGED id="..." -->`
    sentinel pairs (and language-equivalent `# VMODEL-MANAGED-BEGIN` /
    `# VMODEL-MANAGED-END` markers) in target Markdown / source files.
  - Replace the interior content atomically: write the full new file body
    to a sibling temporary file via `mktemp -p "$(dirname "$target")"`,
    then `mv` over the original — guaranteeing no partial writes.
  - Idempotent: running the script twice with the same generated content
    produces an identical on-disk result.
  - Exits non-zero on overlapping or unbalanced sentinels.

### SYS-008 — Output Formatter (Domain Overlay Adapter)

- **Classification**: NEW-PROMPT-SECTION
- **Realised by**: "## Output Format" section shared (by inclusion) across
  `commands/plan.md`, `commands/tasks.md`, and `commands/implement.md`,
  and the "## Domain Overlay" section in `commands/implement.md`.
- **Responsibilities**:
  - Instruct the model to render output in the requested format (Markdown
    tables, JSON, or plain text), controlled by the `--output-format`
    flag parsed in SYS-001.
  - When `v-model-config.yml` declares a domain, instruct the model to
    consult `commands/overlays/{domain}/_domain.yml` and apply the
    overlay-specific output requirements (e.g., MC/DC test coverage for
    DO-178C Level A, ASIL-driven test depth for ISO 26262).

### SYS-009 — State Persistence (Hazard-Driven Task Emitter)

- **Classification**: NEW-PROMPT-SECTION
- **Realised by**: "## State & Workspace" section inside
  `commands/implement.md` (to be created) and the existing "## Hazard
  Enrichment" prompt section inside `commands/tasks.md`.
- **Responsibilities**:
  - Prompt instructs the model to emit file-path + content blocks that
    the shell integration (SYS-007 splice) can apply atomically; no
    runtime database — state is Markdown on disk, the way every other
    `v-model.*` command works today.
  - When `hazard-analysis.md` is present, raise the priority of mitigation
    tasks and emit one verification task per `HAZ-NNN` identifier.

### SYS-010 — Validation & Error Reporting (Spec-Kit Core Compatibility Layer)

- **Classification**: NEW-PROMPT-SECTION + NEW-SHELL
- **Realised by**:
  - Validation logic spread across SYS-004's gate scripts and a "##
    Validation" section in each of `commands/plan.md`,
    `commands/tasks.md`, and `commands/implement.md`.
  - Net-new shell verifier: `scripts/bash/validate-core-schema.sh`
    (~50 lines), accepting `--plan` or `--tasks` and grepping for the
    spec-kit-core v0.7.0-pinned required section headings.
- **Responsibilities**: errors are surfaced both as prose in the model's
  output (the prompt instructs the model to summarise failures) and as
  non-zero exit codes from the shell scripts. The pinned schema fixture
  list lives inside `validate-core-schema.sh` so the contract is
  self-documenting.

### SYS-011 — Hook Registration

- **Classification**: REUSE-CORE
- **Realised by**: an `extension.yml` entry in the spec-kit-v-model
  repository root (3 lines, declarative YAML). Spec-kit core's
  `CommandRegistrar` class in `src/specify_cli/extensions.py`
  (line 579 of the v0.7.0 release) reads `extension.yml` at install
  time and wires the three new commands (`plan`, `tasks`, `implement`)
  into the spec-kit CLI namespace. Hook entries:
  ```yaml
  hooks:
    after_specify:
      - v-model.requirements
    before_implement:
      - v-model.trace
    after_implement:
      - v-model.trace
  ```
- **Responsibilities**: zero runtime code in the v-model extension;
  registration is declarative YAML consumed by core. The existing hook
  infrastructure is untouched (REQ-NF-006).

### SYS-012 — Telemetry / Observability (Structured Summary Reporter)

- **Classification**: NEW-PROMPT-SECTION
- **Realised by**: "## Observability" section appended to each of
  `commands/plan.md`, `commands/tasks.md`, and `commands/implement.md`.
- **Responsibilities**: the prompt instructs the model to emit
  structured log lines (timestamp, command, phase, outcome, inputs read,
  outputs produced, artifacts skipped, warnings) in the existing
  `--- v-model run summary ---` convention, so the shell wrapper can
  capture them via straightforward stdout/stderr redirection. No
  telemetry SDK and no runtime daemon are introduced.

### SYS-013 — Concurrent Write Safety (Deferred Risk Note)

- **Classification**: DROP-RECHARACTERIZED (deferred risk)
- **Realised by**: nothing at runtime under v0.7.0; SYS-013 is retained
  solely as a documentation anchor for the concurrency-safety position
  taken by this release.
- **Position**:
  - The Markdown+shell paradigm is sequential by construction: each
    command is one LLM turn plus a small fixed sequence of shell
    invocations, and the project does not support concurrent invocations
    of the same command against the same feature directory in v0.7.0.
  - The sole concurrency safeguard in v0.7.0 is the `mktemp`-into-same-
    directory + `mv` atomic-rename pattern used by SYS-007 and by any
    other shell script that mutates a tracked file. This guarantees that
    a reader observing the target file sees either the previous content
    or the new content, never a partially-written interleaving.
  - Full concurrent-write safety — for example, a process-wide `flock`
    advisory lock around the gate / splice / commit sequence — is
    explicitly **deferred** to a future shell-locking mechanism and is
    NOT delivered under this feature. There is no Python threading or
    locking proposed; the deferred design space is shell-only.

### SYS-014 — Extension Packaging (Commit Annotator)

- **Classification**: REUSE-CORE (packaging) + NEW-PROMPT-SECTION (commit annotation)
- **Realised by**:
  - **Packaging (REUSE-CORE)**: spec-kit-core's install protocol — the
    extension is distributed as a directory containing `extension.yml`,
    `commands/*.md`, and `scripts/bash/*.sh`. There is no Python
    package, no `pyproject.toml` for runtime distribution, and no
    additional build step. Installation is a single
    `spec-kit extension install <path>` invocation that core executes
    against the directory.
  - **Commit annotation (NEW-PROMPT-SECTION)**: "## Commit Annotation"
    section inside `commands/implement.md` instructs the LLM to suffix
    every `git commit -m "..."` it issues with the comma-separated list
    of V-Model identifiers fulfilled by the change.

## Dependency View (IEEE 1016 §5.2)

> **Note on relationship vocabulary.** In the Markdown+shell paradigm,
> "Calls" denotes one of: (a) one prompt section invoking another by
> textual reference within the same `commands/*.md` file; (b) a
> `commands/*.md` `scripts:` frontmatter entry causing core to invoke a
> Bash script before / after the LLM turn; (c) a Bash script invoking
> another Bash script via `bash other-script.sh`. There are no
> in-process function calls; every "call" crosses either an LLM-prompt
> boundary or a process boundary.

| Source | Target | Relationship | Failure Impact |
|--------|--------|-------------|----------------|
| SYS-001 | SYS-005 | Prompt-section reference | Plan Synthesizer cannot embed V-Model traceability metadata; emitted `plan.md` would be either non-compliant (REQ-007 violated) or core-incompatible (REQ-NF-003 violated). The prompt's "## Validation" section instructs the LLM to abort with non-zero exit. |
| SYS-001 | SYS-010 | Script invocation (`validate-core-schema.sh --plan`) | Plan Synthesizer cannot guarantee schema conformance (REQ-IF-001) or the round-trip property (REQ-029); emitted `plan.md` is unsafe to consume by `speckit.tasks`. The script's non-zero exit propagates to the command's exit code. |
| SYS-001 | SYS-012 | Prompt-section reference | Plan Synthesizer cannot emit its structured stdout summary; CI tooling and human reviewers lose machine-readable visibility. The command continues but flags a warning in its return code. |
| SYS-002 | SYS-005 | Prompt-section reference | Tasks Synthesizer cannot embed `<!-- traces-to: ... -->` comments (REQ-012) and emitted `tasks.md` would either fail core compatibility or lack traceability. The prompt aborts with non-zero exit. |
| SYS-002 | SYS-009 | Prompt-section reference | Tasks Synthesizer cannot raise hazard-mitigation priority or emit `HAZ-NNN` verification tasks (REQ-014); silent regression on safety-critical features. The prompt aborts with non-zero exit when `hazard-analysis.md` is present. |
| SYS-002 | SYS-010 | Script invocation (`validate-core-schema.sh --tasks`) | Tasks Synthesizer cannot guarantee schema conformance (REQ-IF-002) or the round-trip property (REQ-029). The script's non-zero exit propagates. |
| SYS-002 | SYS-012 | Prompt-section reference | Same as SYS-001→SYS-012: warning, run continues. |
| SYS-003 | SYS-004 | Script invocation (`run-v-model-gate.sh`) | Implementation Engine cannot evaluate the pre-implementation gate; the safety net REQ-016 / REQ-NF-004 require is bypassed. The wrapper's non-zero exit causes the prompt to fail closed before any code is written. |
| SYS-003 | SYS-006 | Script invocation (`validate-implements-ids.sh`) | Implementation Engine cannot self-verify generated `// Implements <ID>` comments; hallucinated identifiers may reach the commit (REQ-023, REQ-NF-002 violated). The script exits non-zero before the commit step. |
| SYS-003 | SYS-007 | Script invocation (`splice-managed-regions.sh`) | Implementation Engine cannot preserve user-authored regions across re-runs (REQ-022). The prompt instructs the LLM to refuse to overwrite any existing target source file (degrade to dry-run with diff report). |
| SYS-003 | SYS-008 | Prompt-section reference | Implementation Engine cannot apply domain-specific code/test requirements; under DO-178C / ISO 26262 this is a regulatory failure. The prompt aborts with non-zero exit when a domain is configured but the overlay is unreadable. |
| SYS-003 | SYS-012 | Prompt-section reference | Same as SYS-001→SYS-012: warning, run continues. |
| SYS-003 | SYS-014 | Prompt-section reference | Implementation Engine cannot append V-Model identifiers to commit messages (REQ-021); git-history traceability degraded. The prompt continues, flags a warning in its summary. |
| SYS-004 | (External: `build-matrix.sh`, `validate-*-coverage.sh` scripts) | Script invocation | Pre-Implementation Gate cannot evaluate matrix completeness; SYS-003 receives an indeterminate gate result. Per fail-closed policy SYS-004 MUST report failure to SYS-003. |
| SYS-006 | (External: V-Model artifact files under `specs/<feature>/v-model/`) | File read (grep) | Hallucination Guard cannot read the canonical ID set; cannot certify generated comments. Returns non-zero exit to SYS-003. |
| SYS-008 | (External: `v-model-config.yml`, `commands/overlays/{domain}/_domain.yml`) | File read (LLM) | Domain Overlay Adapter cannot determine the configured domain. Treated as "no domain configured" (base behaviour); SYS-003 continues without overlay-specific requirements. |
| SYS-011 | (External: `extension.yml`, `src/specify_cli/extensions.py:579 CommandRegistrar`) | YAML read by core at install time | Hook Registrar cannot register the bridge-command hooks; the commands remain invocable manually but are not wired into the automation graph (REQ-IF-003 / REQ-IF-005 partial failure). Surfaced as installation-time error by core's `CommandRegistrar`. |
| SYS-013 | (n/a — deferred) | n/a | Documented limitation: concurrent invocations against the same feature directory are not supported in v0.7.0; the only safeguard is the per-file `mktemp`+`mv` atomic-rename used by SYS-007. |

### Dependency Diagram

```text
                    ┌──────────────────────────────────────┐
                    │    Existing project infrastructure   │
                    │  build-matrix.sh, validate-*-coverage,│
                    │  extension.yml, v-model-config.yml    │
                    │  BATS / Pester / eval harnesses      │
                    └───┬───────────┬──────────┬───────────┘
                        │ invokes   │ reads    │ reads
                        ▼           ▼          ▼
        ┌──────────┐  ┌────────┐  ┌────────┐
        │ SYS-004  │  │SYS-008 │  │SYS-011 │
        │  Gate    │  │Overlay │  │Hooks   │
        │ (shell)  │  │(prompt)│  │(YAML)  │
        └────▲─────┘  └────▲───┘  └────────┘
             │             │
             │             │
   ┌─────────┴─────────────┴─────────┐
   │   SYS-003 Implementation Engine │──invokes──► SYS-006 Hallucination Guard (shell)
   │   (commands/implement.md)       │──invokes──► SYS-007 Source Region Manager (shell)
   └──┬──────────┬─────────┬─────────┘──refers──► SYS-014 Commit Annotator (prompt)
      │          │         │
      │          │         └──refers──► SYS-012 Structured Summary Reporter ◄──┐
      │          │                                                              │
      │          └──refers──► SYS-005 Additive-Enrichment Encoder ◄──┐          │
      │                                                              │          │
   ┌──┴──────────────────────────────┐                               │          │
   │ SYS-001 Plan Synthesizer        │──invokes──► SYS-010 ──────────┘          │
   │ SYS-002 Tasks Synthesizer       │   (validate-core-schema.sh)              │
   │   (SYS-002 also refers SYS-009) │──refers────► SYS-012 ─────────────────────┘
   └─────────────────────────────────┘

   SYS-013 (deferred risk note): no runtime arrows; documents the
   sequential-only execution model and the per-file mktemp+mv safeguard.
```

## Interface View (IEEE 1016 §5.3)

### External Interfaces

| Component | Interface Name | Protocol | Input | Output | Error Handling |
|-----------|---------------|----------|-------|--------|----------------|
| SYS-001 | `/speckit.v-model.plan` CLI command | spec-kit slash-command (Markdown prompt with YAML frontmatter; stdin args, working directory = repo root) | Optional `$ARGUMENTS` text; reads V-Model artifacts from `specs/<feature>/v-model/` | Writes `plan.md`, `data-model.md`, `contracts/`, `quickstart.md`, `research.md` to `specs/<feature>/`; structured summary on stdout (via SYS-012) | Non-zero exit on schema-bridge failure (SYS-010 script returns non-zero); warning indicator (non-fatal) when optional artifacts missing (REQ-008) |
| SYS-002 | `/speckit.v-model.tasks` CLI command | spec-kit slash-command | Optional `$ARGUMENTS`; reads V-Model artifacts and `plan.md` (if present) | Writes `tasks.md` to `specs/<feature>/`; structured summary on stdout | Non-zero exit on schema-bridge failure; warning when optional artifacts missing |
| SYS-003 | `/speckit.v-model.implement` CLI command | spec-kit slash-command | Optional `$ARGUMENTS`; reads V-Model artifacts | Writes generated source code to paths declared by each `MOD-NNN` Target Source File; emits commits via SYS-014; structured summary on stdout | Non-zero exit on gate failure (SYS-004), hallucination detection (SYS-006), region-preservation conflict (SYS-007), or domain-overlay failure (SYS-008); no partial commit on failure |
| SYS-004 | Pre-implementation gate result | `bash scripts/bash/run-v-model-gate.sh <feature-dir>` | Feature directory path | Pass/fail exit code + gap report (stdout) | Non-zero exit code propagated to SYS-003 with the gap report appended verbatim |
| SYS-006 | Implements-ID validator | `bash scripts/bash/validate-implements-ids.sh <feature-dir> <generated-files...>` | Feature directory + list of generated files | Pass/fail exit code + per-file hallucination report (stdout) | Non-zero exit code propagated to SYS-003 before commit |
| SYS-007 | Managed-region splicer | `bash scripts/bash/splice-managed-regions.sh <target-file> <generated-content-file>` | Target file path + generated content file path | Atomic in-place replacement of the managed region; new file content written via `mktemp`+`mv` | Non-zero exit on overlapping or unbalanced sentinels; original target left untouched |
| SYS-010 | Core schema validator | `bash scripts/bash/validate-core-schema.sh --plan|--tasks <file>` | Plan or tasks file path | Pass/fail exit code + per-section missing-heading report | Non-zero exit propagated to SYS-001 / SYS-002 |
| SYS-011 | Extension hook registration | `extension.yml` declarative entries (read by core at install time) | Feature install / extension load | `before_implement`, `after_implement` → `v-model.trace`; `after_specify` → `v-model.requirements` | Installation-time error if registration cannot be applied; the existing hook infrastructure is unchanged (REQ-NF-006) |
| SYS-012 | Structured stdout summary | Plain-text (UTF-8) following the existing `v-model.test-results` / `v-model.audit-report` summary conventions | Run results from SYS-001 / SYS-002 / SYS-003 | Inputs-read / outputs-produced / artifacts-skipped / warnings sections; consumed by CI tooling and human reviewers | Output is always emitted, even on failure paths, so that reviewers see the partial result |
| SYS-014 | Git commit suffix | LLM-issued `git commit -m "<subject> — <ID>, <ID>"` | Set of V-Model identifiers fulfilled by the change | Commit message with `… — <ID>, <ID>, <ID>` suffix | Warning (non-fatal) if commit cannot be annotated; commit is still produced |

### Internal Interfaces

> **Note.** "Internal" interfaces in this paradigm are either (a) prompt
> sections referenced by other prompt sections within the same
> `commands/*.md` file, or (b) Bash scripts invoked by other Bash scripts
> or by a `commands/*.md` `scripts:` frontmatter entry. Inputs and
> outputs are described below in those terms; there are no in-process
> function signatures.

| Source | Target | Interface | Protocol | Data Format | Error Handling |
|--------|--------|-----------|----------|-------------|----------------|
| SYS-001 | SYS-005 | "## Requirement Linkage" prompt section invoked from "## Command: plan" | Prompt-section reference within `commands/plan.md` | Canonical Markdown body + structured V-Model metadata (assembled by SYS-002) → enriched Markdown with HTML-comment + optional sections | Prompt instructs the LLM to abort with non-zero exit on enrichment failure (REQ-007, REQ-NF-003) |
| SYS-001 | SYS-010 | `scripts: { sh: scripts/bash/validate-core-schema.sh }` frontmatter | Script invocation (Bash) | Markdown file path → exit code + missing-section report | Non-zero exit propagates to the command's exit code (REQ-IF-001) |
| SYS-002 | SYS-005 | "## Traceability" prompt section invoked from "## Command: tasks" | Prompt-section reference within `commands/tasks.md` | Tasks document body + ordered list of `MOD→ARCH→SYS→REQ` chains → tasks document with `<!-- traces-to: ... -->` per task | Prompt instructs the LLM to abort on missing trace (REQ-012) |
| SYS-002 | SYS-009 | "## Hazard Enrichment" prompt section invoked from "## Command: tasks" | Prompt-section reference within `commands/tasks.md` | Tasks list + parsed `hazard-analysis.md` → tasks list with raised priorities + verification tasks per `HAZ-NNN` | Prompt instructs the LLM to abort on malformed `hazard-analysis.md` (REQ-014) |
| SYS-002 | SYS-010 | `scripts: { sh: scripts/bash/validate-core-schema.sh --tasks }` frontmatter | Script invocation (Bash) | Tasks file path → exit code + missing-section report | Same as SYS-001→SYS-010 (REQ-IF-002) |
| SYS-003 | SYS-004 | `scripts: { sh: scripts/bash/run-v-model-gate.sh }` frontmatter | Script invocation (Bash wrapper around existing `validate-*` scripts) | Feature directory path → `{passed: bool, gap_report: text}` (exit code + stdout) | SYS-003 fails closed: any non-zero exit aborts implementation (REQ-016) |
| SYS-003 | SYS-006 | Inline `bash scripts/bash/validate-implements-ids.sh ...` invocation from "## Validation" | Script invocation (Bash) | Set of `(file, line, id)` tuples grepped from generated files + canonical ID set grepped from `specs/<feature>/v-model/*.md` → exit code + hallucination report | Any non-zero exit aborts the run before commit (REQ-023, REQ-NF-002) |
| SYS-003 | SYS-007 | Inline `bash scripts/bash/splice-managed-regions.sh ...` invocation from "## Artefact Generation" | Script invocation (Bash/awk) | Existing target file content (parsed for region sentinels) + freshly-generated content → merged content preserving user regions, written atomically | Conflict (overlapping or unbalanced sentinels) aborts the run with a diff report; original file untouched (REQ-022) |
| SYS-003 | SYS-008 | "## Domain Overlay" prompt section invoked from "## Command: implement" | Prompt-section reference within `commands/implement.md` | Generation plan + parsed `v-model-config.yml` + `commands/overlays/{domain}/_domain.yml` → augmented plan (e.g., MC/DC test obligations) | Prompt instructs the LLM to abort when a configured domain cannot be applied (REQ-024) |
| SYS-003 | SYS-014 | "## Commit Annotation" prompt section invoked from "## Command: implement" | Prompt-section reference within `commands/implement.md` | Commit message string + list of IDs → suffixed message issued via `git commit -m` | Warning on failure; commit proceeds without annotation (REQ-021 verification by Inspection) |
| SYS-001 / SYS-002 / SYS-003 | SYS-012 | "## Observability" prompt section appended to each command file | Prompt-section reference; output written to stdout | Run-result struct → plain-text summary in `--- v-model run summary ---` convention | Best-effort; never blocks the parent command from completing |

## Data Design View (IEEE 1016 §5.4)

| Entity | Component | Storage | Protection at Rest | Protection in Transit | Retention |
|--------|-----------|---------|-------------------|-----------------------|-----------|
| V-Model artifact set (`requirements.md`, `acceptance-plan.md`, `system-design.md`, `system-test.md`, `architecture-design.md`, `integration-test.md`, `module-design.md`, `unit-test.md`, `hazard-analysis.md`, `traceability-matrix.md`) | Read by SYS-001, SYS-002, SYS-003 (via the LLM directly) and SYS-006 (via grep) | File (Git-tracked under `specs/<feature>/v-model/`) | Repository ACLs; Git history is the audit trail | N/A (local file reads, same host) | Permanent in Git history; lifecycle-tagged (`[DEPRECATED]`, `[SUSPECT]`) per project rules — never deleted |
| Project constitution | Read by SYS-001 (via the LLM directly) | File (Git-tracked under `.specify/memory/constitution.md`) | Repository ACLs | N/A | Permanent in Git history |
| `v-model-config.yml` (domain overlay configuration) | Read by SYS-008 (via the LLM directly) | File (Git-tracked at repository root) | Repository ACLs | N/A | Permanent; absent file is a valid configuration meaning "no domain" |
| Canonical spec-kit-core outputs (`plan.md`, `data-model.md`, `contracts/`, `quickstart.md`, `research.md`, `tasks.md`) | Written by SYS-001 / SYS-002 (via the LLM, validated by SYS-010 shell verifier) | File (Git-tracked under `specs/<feature>/`) | Repository ACLs | N/A | Permanent in Git history; regenerable from V-Model inputs |
| V-Model enrichment metadata (HTML comments + optional Markdown sections) | Owned by SYS-005; embedded in canonical outputs above | Inline within the canonical files | Inherits the host file's protection | N/A | Inseparable from the host file's lifecycle |
| Generated source code | Written by SYS-003 (via the LLM, region-preserved by SYS-007) | File (Git-tracked under paths declared by each `MOD-NNN` Target Source File) | Repository ACLs | N/A | Permanent in Git history; user-authored regions outside V-Model sentinels preserved across re-runs (REQ-022) |
| Generated tests (unit / integration / system / acceptance) | Written by SYS-003 (via the LLM) | File (Git-tracked under the project's existing test directories) | Repository ACLs | N/A | Permanent in Git history; regenerable |
| Pre-implementation gate report | Produced by SYS-004 (`run-v-model-gate.sh` stdout) | Stdout stream (transient) | Process boundary | N/A | Not retained; surfaced into CI logs and the SYS-012 structured summary |
| Hallucination report | Produced by SYS-006 (`validate-implements-ids.sh` stdout) | Stdout stream (transient) | Process boundary | N/A | Not retained; on hallucination, no commit occurs so the report is the only evidence — must be captured by CI |
| Structured stdout summary | Produced by SYS-012 (LLM emission) | Stdout stream (transient) | Process boundary | N/A | Captured by CI tooling per existing `v-model.test-results` / `v-model.audit-report` conventions |
| Git commit annotations | Produced by SYS-014 (LLM-issued `git commit -m` suffix) | Git commit message metadata | Git history (signed if the contributor signs commits) | N/A | Permanent in Git history |
| Hook registrations | Owned by SYS-011 | `extension.yml` (Git-tracked at repository root) | Repository ACLs | N/A | Permanent in Git history |

> No personally-identifiable, secret, or otherwise-sensitive data flows
> through any bridge-command boundary. All data is project source under
> repository ACLs; consequently no encryption-at-rest, TLS-in-transit, or
> signing requirements arise from these requirements.

---

## Operational States (Behavioural View — IEEE 1016 §5 Design Viewpoints Framework)

> **Rationale:** ISO 14971 §5.4 and IEC 60812:2018 §6.2 require that
> hazard analysis distinguish operational states because risk controls
> and failure modes can be state-dependent. This section enumerates the
> explicit operational states of the bridge-command process;
> `hazard-analysis.md` (Operational States Reference + per-HAZ state
> column) consumes this section directly.

### State Definitions

| State | Definition | Triggering / Entry Condition | Active SYS Components |
|-------|-----------|------------------------------|----------------------|
| NORMAL | Default operating state for read-only / analysis / planning operations: spec ingestion, plan/task synthesis, gate evaluation, hook registration, configuration parsing. No mutation of source files outside the V-Model artifact directory. | Process start for any of `v-model.plan`, `v-model.tasks`, `v-model.requirements`, `v-model.trace`, `v-model.implement` (initial phase before write barrier). | SYS-001, SYS-002, SYS-003 (pre-write-barrier phase), SYS-004, SYS-005, SYS-008, SYS-009, SYS-010, SYS-011, SYS-012 (and SYS-006 in its preparation phase) |
| DRY-RUN | `v-model.implement` invoked with `--no-commit`: source generation runs end-to-end (Implementation Engine prompt, SYS-007 region splicer, SYS-006 hallucination guard) but the post-write commit barrier is suppressed. Files under the working tree may be touched only via the SYS-007 atomic-write pattern targeting a scratch path; no `git commit` is issued by the LLM. | `v-model.implement --no-commit` after gate-pass. | SYS-003 (no-commit mode), SYS-006, SYS-007, SYS-012 |
| COMMITTING | `v-model.implement` invoked without `--no-commit`: full write-and-commit barrier is active, including SYS-007 region-marker mutation, SYS-006 hallucination-guard pre-commit verification, and SYS-014 commit-message annotation. | `v-model.implement` (default) after gate-pass and after the optional `--no-commit` flag is absent. | SYS-003 (commit mode), SYS-006, SYS-007, SYS-012, SYS-014 |
| ERROR | Any command exit path with non-zero exit code: structured-summary emission must complete on this path (REQ-027) and CI gating must classify the run as failed. | Uncaught prompt failure, gate failure, hallucination-guard rejection, or signal interruption from any of the above states. | SYS-012 (must flush summary) |

### State-Transition Diagram

```
                          ┌─────────────────┐
                          │     NORMAL      │
                          └────────┬────────┘
                                   │
        ┌──────────────────────────┼──────────────────────────┐
        │                          │                          │
  v-model.implement         v-model.implement         non-implement commands
   --no-commit                (default)              (plan / tasks / requirements / trace)
        │                          │                          │
        ▼                          ▼                          │
┌───────────────┐         ┌──────────────────┐                │
│   DRY-RUN     │         │   COMMITTING     │                │
└───────┬───────┘         └────────┬─────────┘                │
        │                          │                          │
  on completion              on success                 on completion
        │                          │                          │
        └─────────────┬────────────┴──────────────────────────┘
                      ▼
               [process exit]

  Any state ──── on failure / signal ────▶ ERROR ──── after summary flush ────▶ [process exit]
```

> **Note:** Both terminal paths exit the process — ERROR exits after
> SYS-012 best-effort summary emission; successful completion exits
> cleanly after the success-path summary, regardless of whether NORMAL
> was the only state visited (non-implement commands) or transited via
> DRY-RUN/COMMITTING (implement command). A subsequent invocation
> re-enters NORMAL as a fresh process and a new state-machine instance.

### State-Dependent Mitigation Notes

- All REQ-NNN risk controls listed in `hazard-analysis.md` Mitigation
  columns are in force in *every* state in which their parent SYS
  component is active; no mitigation is gated on a state distinction in
  v0.7.0.
- The COMMITTING-only mitigations (SYS-007 region-marker preservation,
  SYS-014 commit-suffix annotation) are the only state-restricted
  controls; they are trivially inactive in DRY-RUN and NORMAL.
- ERROR-state mitigation is the structured-summary best-effort emission
  contract (REQ-027, REQ-IF-004); summary emission occurs during the
  ERROR→[process exit] transition and no failure path may exit silently.

---

## SYS-006 Algorithm Specification (Hallucination Guard)

> **Rationale:** ISO 14971 §5.3 (HARA design input) and IEC 60812 §6
> require that risk controls reference an explicit design specification.
> This section exists so that hazard-analysis (HAZ-007 / HAZ-012 /
> HAZ-013) can compute a defensible likelihood for SYS-006
> false-negative and false-positive outcomes. Surfaced by peer-review
> finding PRF-HAZ-007 and partially by PRF-SYS-001 (operational-state
> observation).

**Type:** Deterministic, grep/awk-based ID validator implemented as the
shell script `scripts/bash/validate-implements-ids.sh`. **No LLM
invocation inside SYS-006 itself.** This is a non-negotiable design
constraint: because the upstream content under inspection
(`// Implements <ID>` comments) was generated by an LLM (HAZ-007
likelihood = "Occasional"), SYS-006 MUST be deterministic to provide
independent verification. Introducing LLM evaluation inside SYS-006
would replace one non-deterministic step with another and invalidate
the false-negative likelihood claim ("Remote") in HAZ-012.

**Algorithm (shell pseudocode):**

```bash
# scripts/bash/validate-implements-ids.sh <feature-dir> <generated-files...>
# Exit codes: 0 = clean, 1 = hallucination(s) found, 2 = usage error.

set -euo pipefail
feature_dir="$1"; shift
generated_files=("$@")

# 1. Build the canonical V-Model identifier set (one-shot grep over the
#    feature's V-Model artefacts). The pattern matches every ID family
#    used by the project: REQ, SYS, ARCH, MOD, HAZ, ATP, ITP, UTP, SCN,
#    STP, STS, ITS, UTS, plus the NF/IF/CN sub-families of REQ.
canonical_ids=$(
  grep -hoE \
    '(REQ(-(NF|IF|CN))?|SYS|ARCH|MOD|HAZ|ATP|ITP|UTP|SCN|STP|STS|ITS|UTS)-[0-9]+([A-Z][0-9]?)?' \
    "$feature_dir"/*.md \
  | sort -u
)

# 2. For every generated file, grep the "Implements <ID>" comment family
#    (#, //, --, ; comment markers all accepted), then test set membership.
status=0
for f in "${generated_files[@]}"; do
  while IFS=: read -r line_no line_text; do
    cited_id=$(printf '%s' "$line_text" \
      | grep -oE '(Implements|implements:)[[:space:]]+[A-Z]+(-[A-Z]+)?-[0-9]+([A-Z][0-9]?)?' \
      | awk '{print $NF}')
    [ -z "$cited_id" ] && continue
    if ! grep -qx "$cited_id" <<<"$canonical_ids"; then
      printf 'HALLUCINATION: %s:%s cites %s (not in canonical set)\n' \
        "$f" "$line_no" "$cited_id"
      status=1
    fi
  done < <(grep -nE '(#|//|--|;)[[:space:]]*[Ii]mplements' "$f" || true)
done

exit "$status"
```

**Properties:**

| Property | Value | Justification |
|----------|-------|---------------|
| Determinism | Total | Pure function of `(generated_files, feature_dir/*.md)`; no LLM, no clock, no randomness. Same inputs ⟹ same outputs across hosts and runs (POSIX `grep`/`awk`/`sort` are deterministic). |
| False-negative rate | 0 by construction (against the regex domain) | Every `Implements <ID>` comment recognised by the regex is tested for set membership. The only residual false-negative path is a comment whose surface form does not match the regex (e.g. obfuscated whitespace) — addressed by REQ-NF-002 conformance tests at unit level (`tests/bats/`). |
| False-positive rate | 0 against authoritative ID set | An ID is reported as a hallucination only if it is absent from the canonical set. The set is built directly from the V-Model artifact files themselves (Step 1 above), so by definition it is the ground truth. |
| Time complexity | O(N · L) | N = total bytes of generated source; L = average comment-density. Linear in input size; runs comfortably within the per-run budget. The `grep` pipelines are stream-oriented and require no in-memory parser. |
| LLM-eval supplement | None at gate time | A separate LLM-based eval (`structural-eval`, REQ-NF-002) is run in CI as a *secondary* defence, but its result is NOT consulted by SYS-006 at commit time. SYS-006 alone is the merge-blocking control. |

**Authoritative ID set construction:**

The canonical set is built inline by Step 1 of the algorithm above and
covers `REQ-NNN` (incl. `REQ-NF-NNN`, `REQ-IF-NNN`, `REQ-CN-NNN`),
`ATP-NNN`, `SCN-NNN`, `SYS-NNN`, `STP-NNN`, `STS-NNN`, `ARCH-NNN`,
`ITP-NNN`, `ITS-NNN`, `MOD-NNN`, `UTP-NNN`, `UTS-NNN`, `HAZ-NNN`, plus
suffix variants such as `ATP-024-A` and `UTS-013-A2`. `[DEPRECATED]`-tagged
IDs are kept in the set (the grep matches the ID itself regardless of
adjacent lifecycle tags) so that generated comments referencing a
deprecated-but-still-traced item are NOT flagged as hallucinations.

**Failure modes covered by HAZ-012 / HAZ-013:**

| HAZ | Direction | Residual risk justification |
|-----|-----------|-----------------------------|
| HAZ-012 (false-negative) | Guard misses an invalid ID | Residual = Tolerable. The deterministic regex+set-lookup cannot miss an ID the regex recognises; the only residual likelihood is a regex-evasion bug (mitigated by BATS boundary tests including a phantom-ID fixture) plus the CI structural-eval as a second line of defence. |
| HAZ-013 (false-positive) | Guard rejects a valid ID | Residual = Acceptable. The set-membership test cannot reject an ID that is present in the canonical set; the only residual likelihood is a Step-1 grep-pattern bug (mitigated by BATS round-trip tests against every artifact in the V-Model). |

**What SYS-006 does NOT do** (out-of-scope, by design):

- Does not validate semantic correctness of the comment ("does the
  generated function actually implement REQ-008?"). That is the role of
  the LLM eval (REQ-NF-002, secondary defence) and human peer-review.
- Does not parse Markdown content or rebuild the canonical ID set with a
  custom parser — Step 1 is a single line of `grep`, not a parser.
- Does not call out to any external service or LLM. SYS-006 is a pure
  shell-script invocation with no network surface.

---

## Quality Attribute Coverage (ISO/IEC 25010:2023)

| Quality Characteristic | ISO/IEC 25010 Ref | Design Evidence |
|------------------------|-------------------|-----------------|
| Functional Suitability (completeness, correctness, appropriateness) | §4.2.1 | Every functional `REQ-NNN` is the parent of at least one `SYS-NNN`; the Decomposition View is the authoritative coverage source. Hallucination Guard (SYS-006) provides correctness evidence for generated traceability comments (REQ-NF-002). |
| Reliability (availability, fault tolerance, recoverability) | §4.2.2 | Pre-Implementation Gate (SYS-004) is fail-closed (REQ-NF-004); Hallucination Guard (SYS-006) prevents commit on inconsistency; Source Region Manager (SYS-007) makes re-runs recoverable without losing user work via its `mktemp`+`mv` atomic pattern; Dependency View documents every failure-propagation path. |
| Performance Efficiency (time behaviour, resource utilisation, capacity) | §4.2.3 | Requirements impose no quantified performance budgets on the bridge commands beyond idempotency (REQ-025, ≥95% structural identity). Performance is not currently a constrained quality; if budgets are added later, this row should be revisited. *(No gap flagged — characteristic not implied by the active requirement set.)* |
| Compatibility (co-existence, interoperability) | §4.2.4 | Spec-Kit Core Compatibility Layer (SYS-010) owns the schema contracts (verified by `validate-core-schema.sh`) and the round-trip property (REQ-029); Additive-Enrichment Encoder (SYS-005) ensures core tooling parses outputs without warning (REQ-NF-003); Hook Registrar (SYS-011) preserves the existing hook infrastructure (REQ-NF-006) by delegating to spec-kit core's `CommandRegistrar`. |
| Security (confidentiality, integrity, authenticity, accountability) | §4.2.5 | No sensitive data flows through bridge-command boundaries (see Data Design View note). Accountability is provided by Commit Annotator (SYS-014) and the Structured Summary Reporter (SYS-012) which together create an auditable record of every change. |
| Maintainability (modularity, reusability, analysability, modifiability, testability) | §4.2.7 | Decomposition separates command business logic (SYS-001/002/003 prompt files) from cross-cutting concerns (SYS-005, SYS-010, SYS-012); the Compatibility Layer can evolve independently of the synthesizers. The shell layer is testable via the project's existing BATS harness. |
| Safety (operational constraint, risk identification, fail safe, hazard warning) | §4.2.9 | Hazard-Driven Task Emitter (SYS-009) propagates `HAZ-NNN` into mitigation and verification tasks (REQ-014). Pre-Implementation Gate (SYS-004) and Hallucination Guard (SYS-006) implement fail-safe behaviour. SYS-013 documents the deferred concurrency-safety position and the per-file `mktemp`+`mv` safeguard that is in force today. Note: this feature does not itself produce hazards; it relays hazards from upstream artifacts. |

No quality gaps flagged.

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total System Components (SYS) | 14 (13 active + 1 deferred-risk note, 0 deprecated, 0 suspect) |
| Total Parent Requirements Covered | 41 / 41 active functional / NF / IF / CN requirements bound to a runtime SYS (REQ-NF-001, REQ-CN-003, REQ-CN-004 are CI/process meta-constraints not bound to a runtime SYS — see Derived Requirements note below) |
| Components per Type | Subsystem: 3 \| Module: 7 \| Service: 2 \| Library: 1 \| Deferred Risk Note: 1 |
| **Forward Coverage (REQ→SYS) for runtime requirements** | **100%** |

## Derived Requirements

None — every component traces to one or more existing `REQ-NNN`. The
decomposition introduced no architectural capability that is not already
mandated by `requirements.md`.

> **Note on REQ-NF-001, REQ-CN-003, REQ-CN-004.** These three
> requirements are CI / scope / process meta-constraints rather than
> runtime command capabilities (four-stack test coverage gating, scope
> guardrails against deferred orchestrator features, and dogfood
> discipline respectively). In the previous Python-paradigm design they
> were bound to a "Quality & Process Compliance Harness" runtime
> component (SYS-013). In the Markdown+shell paradigm they are enforced
> by GitHub Actions workflows, branch-protection rules, and the
> existing `tests/bats/` + `tests/pester/` + `tests/evals/` harnesses;
> none of them require a runtime SYS component. The SYS-013 identifier
> has therefore been recharacterised (see SYS-013 above) and the three
> meta-constraints are intentionally unbound from any runtime SYS in
> this revision. They remain enforceable and merge-blocking through CI.

## Glossary

| Term | Definition |
|------|-----------|
| Additive enrichment | The pattern (owned by SYS-005) of layering V-Model traceability metadata onto canonical spec-kit-core artifacts as HTML comments and optional Markdown sections that core tooling harmlessly ignores. |
| Bridge command | A V-Model command (SYS-001, SYS-002, or SYS-003) that produces output in spec-kit-core canonical format, enabling downstream consumption by unmodified `speckit.*` commands. |
| Direct Path | The user path in which V-Model artifacts feed directly into SYS-003 without producing intermediate `plan.md` / `tasks.md`. |
| Fail-closed | A failure-handling policy in which an indeterminate or failed precondition causes the operation to abort rather than proceed; SYS-004 and SYS-006 implement this policy as non-zero shell exit codes consumed by the prompt's "## Validation" section. |
| Full Ceremony | The user path in which every V-Model command (including SYS-001 and SYS-002) is run before SYS-003. |
| Hybrid path | Any user path that mixes `speckit.*` and `v-model.*` commands at any layer of the workflow; enabled by SYS-010's reduced-enrichment fallback (a prompt instruction in `commands/tasks.md`) and SYS-007's region preservation (the `splice-managed-regions.sh` script). |
| Markdown+shell paradigm | The implementation paradigm shared by every command in this extension: a Markdown prompt file under `commands/<name>.md` (LLM behaviour) plus zero or more Bash scripts under `scripts/bash/<name>.sh` (deterministic pre/post processing), with a PowerShell mirror under `scripts/powershell/`. No Python runtime code is shipped by this extension. |
| Managed region | A span of generated content in a Markdown or source file demarcated by language-appropriate sentinel comments (`<!-- BEGIN MANAGED id="..." -->` / `<!-- END MANAGED id="..." -->` for Markdown, `# VMODEL-MANAGED-BEGIN` / `# VMODEL-MANAGED-END` for source) and owned by SYS-007; content outside such regions is preserved across re-runs. |
| Pre-implementation gate | The composite check executed by SYS-004 on behalf of SYS-003 before code generation, comprising `build-matrix.sh` plus the five `validate-*-coverage.sh` scripts, orchestrated by the ~30-line `run-v-model-gate.sh` wrapper. |
| Round-trip property | The property (owned by SYS-010) that a `plan.md` produced by SYS-001 is valid input to `speckit.tasks`, and a `tasks.md` produced by SYS-002 is valid input to `speckit.implement`. Verified at runtime by `validate-core-schema.sh`. |
| Target Source File | The field within each `MOD-NNN` entry in `module-design.md` declaring the source-file path(s) the module implements; SYS-003 writes generated code to these paths via the `splice-managed-regions.sh` atomic-write helper. |
