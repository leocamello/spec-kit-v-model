# Research: Bridge Commands (V-Model ↔ Spec-Kit Core)

<!-- v-model-enrichment: feature=007-bridge-commands -->

**Branch**: `feature/007-bridge-commands` | **Date**: 2026-04-30  
**Input**: V-Model artifact set under `specs/007-bridge-commands/v-model/`  
**Purpose**: Resolve all NEEDS CLARIFICATION items and document every design
decision with the V-Model artifact ID(s) that justify it. Zero items are left
unresolved; every choice below cites the authoritative source artifact.

---

## NEEDS CLARIFICATION Inventory

**Total items found during synthesis**: 0  
**Resolved by citation**: 0 / 0  
**Flagged for human review**: 0 / 0

All design decisions in this feature are fully specified by the 8 approved
V-Model artifacts. No ambiguity arose that could not be resolved by reading
the artifacts directly. The table below documents the resolved choices.

---

## Design Decisions

### D-001: Implementation Language — Python

**Decision**: All 27 `MOD-NNN` modules are implemented as Python 3.11
functions / entry points.

**Justification**: module-design.md §Module Map lists every Target Source
File as `src/v_model_extension/**/*.py`. This is not a design choice open
to the implementation team — it is specified verbatim in the approved
artifact. Deviation would violate Principle III (Specification as Source of
Truth).

**Authoritative Source**: module-design.md §Module Map (all 27 rows,
Target Source File column).

---

### D-002: Concurrency Model — Single-Threaded Sequential

**Decision**: All bridge commands run as single-threaded sequential CLI
subprocesses. No internal concurrency is introduced.

**Justification**: architecture-design.md §Overview states: "The runtime
model is **single-threaded sequential** per command invocation — the bridge
commands run as one-shot CLI processes with no internal concurrency.
Synchronization is filesystem-level only (atomic-write semantics provided
by ARCH-021). This choice trades performance for determinism and simplicity,
anchored to the idempotency requirement (REQ-025)."

**Authoritative Source**: architecture-design.md §Overview;
system-design.md §Quality Attribute Coverage (Performance Efficiency row).

---

### D-003: Hallucination Guard Algorithm — Deterministic Regex+Set, Zero LLM

**Decision**: SYS-006 (MOD-013 `verify_ids`) is implemented as a pure
deterministic function: compile the regex
`(?i)\bImplements\s+([A-Z]+(?:-[A-Z]+)?-[0-9]+(?:[A-Z][0-9]?)?)`,
scan every comment line of every generated file, and do a set-membership
lookup against `vmodel_id_set`. No LLM call inside SYS-006 at any point.

**Justification**: system-design.md §SYS-006 Algorithm Specification states
explicitly: "**No LLM invocation inside SYS-006 itself.** This is a
non-negotiable design constraint." The section provides the exact regex
pattern and the complete pseudocode for `verify_ids`. The properties table
confirms Determinism = "Total" and False-negative rate = "0 by
construction." HAZ-007 (Occasional likelihood for LLM-generated hallucinated
IDs) is the design driver behind this choice.

**Authoritative Source**: system-design.md §SYS-006 Algorithm Specification;
hazard-analysis.md HAZ-007, HAZ-012, HAZ-013.

---

### D-004: Pre-Implementation Gate — Reuse Existing Scripts, No New Wrapper

**Decision**: `v-model.implement` invokes exactly these six existing scripts
via ARCH-020 (subprocess): `build-matrix.sh`, `validate-requirement-coverage.sh`,
`validate-system-coverage.sh`, `validate-architecture-coverage.sh`,
`validate-integration-coverage.sh`, `validate-module-coverage.sh`. MOD-010
(`evaluate_gate`) is a thin composition layer, not a replacement gate.

**Justification**: REQ-017 states "The `v-model.implement` command SHALL
invoke the existing [scripts] as its pre-implementation gate; no new wrapper
script may be introduced." REQ-CN-002 reinforces this as a constraint.
system-design.md SYS-004 description: "Reuses existing scripts; introduces
no new wrapper." Rationale: avoiding drift between the new gate and what CI
already enforces.

**Authoritative Source**: requirements.md REQ-017, REQ-CN-002;
system-design.md SYS-004; architecture-design.md ARCH-007.

---

### D-005: Additive Enrichment — HTML Comments + Optional Sections Only

**Decision**: V-Model traceability metadata is embedded exclusively as
HTML `<!-- ... -->` comments and optional (non-required) Markdown sections.
The core schema structure (required headings, ordering, table format) is
never mutated by the enrichment encoder.

**Justification**: requirements.md REQ-007: "V-Model traceability metadata
MUST be embedded as HTML comments and optional Markdown sections such that
spec-kit core tooling parses the documents without error." HAZ-011 documents
the failure mode of shifting heading levels as Serious/Remote/Tolerable,
mitigated by the additive-only encoder API surface. architecture-design.md
ARCH-008 interface contract: "Output `enriched_doc` MUST still validate
against the spec-kit-core schema after enrichment."

**Authoritative Source**: requirements.md REQ-007, REQ-NF-003;
system-design.md SYS-005; architecture-design.md ARCH-008; hazard-analysis.md
HAZ-011.

---

### D-006: Source Region Manager — Language-Appropriate Marker Comments

**Decision**: SYS-007 (MOD-014 `splice_managed_regions`) demarcates
V-Model-managed regions using language-appropriate marker comments (e.g.,
`# [V-MODEL REGION: MOD-NNN]` for Python, `// [V-MODEL REGION: MOD-NNN]`
for TypeScript/JS, `-- [V-MODEL REGION: MOD-NNN]` for SQL). Content outside
marked regions is never touched; overlapping markers abort with a diff
report.

**Justification**: requirements.md REQ-022: "The `v-model.implement` command
SHALL NOT overwrite source-file content that lies outside the regions managed
by the V-Model." system-design.md SYS-007: "Demarcates V-Model-managed
regions inside generated source files (using language-appropriate marker
comments) and preserves any user-authored content located between those
regions across re-runs." architecture-design.md ARCH-010 interface: "Detects
overlapping markers and aborts with a diff report." HAZ-014 (Critical:
user-authored content overwritten) is the design driver.

**Authoritative Source**: requirements.md REQ-022; system-design.md SYS-007;
architecture-design.md ARCH-010; hazard-analysis.md HAZ-014.

---

### D-007: TDD Task Ordering — Unit → Impl → Integration → System → Acceptance

**Decision**: MOD-004 (`build_tdd_task_list`) emits tasks in the strict
sequence: write unit tests → implement modules → run unit tests → write
integration tests → run integration tests → write system tests → run system
tests → write acceptance tests.

**Justification**: requirements.md REQ-011: "The `v-model.tasks` command
SHALL order the emitted tasks TDD-style in the following sequence: write unit
tests, implement modules, run unit tests, write integration tests, run
integration tests, write system tests, run system tests, write acceptance
tests." module-design.md MOD-004 §Algorithmic/Logic View provides the exact
pseudocode that produces this ordering.

**Authoritative Source**: requirements.md REQ-011; module-design.md MOD-004.

---

### D-008: Atomic File Write — Write-to-Tmp + Rename

**Decision**: MOD-027 (`atomic_write`) implements the write-to-temp-path +
`os.rename()` pattern. This is the sole synchronization primitive used
across all file-emitting modules.

**Justification**: architecture-design.md ARCH-021 §Overview: "Atomic
file-write primitive (write-to-tmp + rename) used by ARCH-002, ARCH-005,
ARCH-006, ARCH-010, ARCH-015. **Rationale:** atomicity is what makes failed
runs leave the filesystem in a consistent state; without it a partial write
could corrupt a target source file (REQ-022 violation)." HAZ-025 (summary
truncated on exit) is mitigated by this same contract.

**Authoritative Source**: architecture-design.md ARCH-021;
hazard-analysis.md HAZ-025.

---

### D-009: Schema Validation — Pinned at v0.7.0, Strict Conformance

**Decision**: MOD-017 (`validate_plan_schema`) and MOD-018
(`validate_tasks_schema`) validate against spec-kit-core's `plan-template.md`
and `tasks-template.md` schemas pinned at v0.7.0. Schema fixtures are
versioned alongside the project. ARCH-013 reports the pinned version in
every run summary.

**Justification**: requirements.md REQ-IF-001: "The `v-model.plan` command
output `plan.md` SHALL conform exactly to spec-kit core's canonical
`plan-template.md` schema as published at v0.7.0 release time."
requirements.md REQ-CN-001: bridge commands MUST NOT require modification to
spec-kit core. architecture-design.md §Overview sensitivity point: "The
pinned spec-kit-core schema version (v0.7.0) — any drift in the upstream
`plan-template.md` or `tasks-template.md` immediately breaks ARCH-013."
architecture-design.md ARCH-013 error-recovery: "ARCH-013 NEVER attempts to
mutate, repair, or downgrade `doc`."

**Authoritative Source**: requirements.md REQ-IF-001, REQ-IF-002, REQ-CN-001;
architecture-design.md ARCH-013; hazard-analysis.md HAZ-017, HAZ-018.

---

### D-010: Hazard-Driven Task Elevation — Activation on hazard-analysis.md Presence

**Decision**: MOD-016 (`enrich_with_hazards`) activates only when
`hazard-analysis.md` is present in the artifact set. When active, it raises
the priority of mitigation-linked tasks and emits one dedicated verification
task per `HAZ-NNN`. When absent, it is a no-op (identity transform).

**Justification**: requirements.md REQ-014: "When `hazard-analysis.md` is
present in the feature directory, the `v-model.tasks` command SHALL flag
mitigation tasks as higher priority and SHALL emit dedicated verification
tasks that explicitly reference each `HAZ-NNN` identifier." system-design.md
SYS-009: "Activates when `hazard-analysis.md` is present." HAZ-016
(Critical: hazard-driven tasks not emitted when they should be) is mitigated
by the SYS-002 fail-closed policy on malformed `hazard-analysis.md`.

**Authoritative Source**: requirements.md REQ-014; system-design.md SYS-009;
architecture-design.md ARCH-012; hazard-analysis.md HAZ-016.

---

### D-011: Hook Registration — Extend extensions.yml, Never Modify Infrastructure

**Decision**: MOD-020 (`register_hooks`) writes entries into
`.specify/extensions.yml` only. The hook infrastructure itself (the YAML
schema, the invocation engine) is never modified. The specific entries are:
`before_implement` → `v-model.trace`, `after_implement` → `v-model.trace`,
`after_specify` → `v-model.requirements`.

**Justification**: requirements.md REQ-IF-003: "The `v-model.implement`
command SHALL register the `before_implement` and `after_implement` extension
hooks." REQ-IF-005: "`/speckit.v-model.requirements` command SHALL be
reachable via the `after_specify` hook." REQ-NF-006: "bridge commands SHALL
NOT introduce any change to the existing extension hook infrastructure; only
the registered hooks themselves are subject to modification."

**Authoritative Source**: requirements.md REQ-IF-003, REQ-IF-005, REQ-NF-006;
system-design.md SYS-011; architecture-design.md ARCH-015.

---

### D-012: Reduced-Enrichment Fallback — Hybrid Path Support

**Decision**: When MOD-019 (`detect_enrichment`) finds that `plan.md` was
produced by `speckit.plan` (no V-Model enrichment metadata), downstream
commands (MOD-003, MOD-005) proceed with traceability derived directly from
the V-Model artifact set. No failure, no partial abort. The
`EnrichmentReport{enriched: false}` is diagnostic only.

**Justification**: requirements.md REQ-028: "When V-Model enrichment is
absent in upstream artifacts…bridge commands…SHALL proceed with reduced
enrichment rather than failing." requirements.md REQ-029 (round-trip
property): `v-model.plan` → `speckit.tasks` must always work.
architecture-design.md ARCH-014: "Detects upstream artifacts that lack V-Model
enrichment metadata and falls back to populating downstream traceability from
the V-Model artifact set directly."

**Authoritative Source**: requirements.md REQ-028, REQ-029;
system-design.md SYS-010; architecture-design.md ARCH-014; hazard-analysis.md
HAZ-018.

---

### D-013: Commit Message Format — `feat(<scope>): <subject> — ID, ID`

**Decision**: MOD-023 (`annotate_commit`) suffixes every commit message with
` — ` followed by a comma-separated list of V-Model identifiers (MOD-NNN,
REQ-NNN). Empty ID list → suffix omitted with a warning (non-fatal).

**Justification**: requirements.md REQ-021: "Commits produced by
`v-model.implement` SHALL include the implementing V-Model identifiers in
the commit message, formatted as a comma-separated suffix (e.g.,
`feat(<scope>): <subject> — MOD-NNN, REQ-NNN`)." architecture-design.md
ARCH-018 interface: "best-effort — warns on failure, commit still proceeds."
HAZ-022 documents the Occasional likelihood and Tolerable residual for this
specific module.

**Authoritative Source**: requirements.md REQ-021;
system-design.md SYS-014; architecture-design.md ARCH-018;
hazard-analysis.md HAZ-022.

---

### D-014: Domain Overlay Loading — Fail-Closed on Parse Error, No-Op When Absent

**Decision**: MOD-015 (`apply_overlay`) reads `v-model-config.yml` from the
repository root. Absent file → identity transform, no error. Present but
malformed file → raise `OverlayParseError`, propagated to MOD-005
(fail-closed). Present and well-formed → apply overlay-specific obligations
(MC/DC tests for DO-178C Level A, ASIL test depth for ISO 26262).

**Justification**: requirements.md REQ-024: "SHALL honour the configured
domain overlay (read from `v-model-config.yml`) by applying overlay-specific
output requirements…if a configured domain cannot be applied the command MUST
exit non-zero." system-design.md SYS-008 dependency failure impact: "Treated
as 'no domain configured' (base behaviour)" for absent file vs.
"Implementation Engine MUST exit non-zero" for adapter failure.
HAZ-015 (Critical: configured domain not applied) and HAZ-024 (malformed
YAML silently downgraded) are mitigated by this fail-closed policy.

**Authoritative Source**: requirements.md REQ-024;
system-design.md SYS-008; architecture-design.md ARCH-011;
hazard-analysis.md HAZ-015, HAZ-024.

---

### D-015: Structured Summary Format — Reuse test-results / audit-report Grammar

**Decision**: MOD-021 (`emit_summary`) produces output conforming to the
same summary grammar already used by `v-model.test-results` and
`v-model.audit-report`. This grammar is not redefined here; it is consumed
from the existing implementation. Summary is emitted on every exit path
(success, failure, signal) before process termination.

**Justification**: requirements.md REQ-IF-004: "All three bridge commands
SHALL emit their structured stdout summary in a format machine-readable by
the project's existing summary-parsing tooling (the same conventions used by
`v-model.test-results` and `v-model.audit-report`)." system-design.md
SYS-012. HAZ-020 (summary not emitted on failure) and HAZ-025 (truncated on
exit) are mitigated by the best-effort emission contract.

**Authoritative Source**: requirements.md REQ-027, REQ-IF-004;
system-design.md SYS-012; architecture-design.md ARCH-016;
hazard-analysis.md HAZ-020, HAZ-025.

---

### D-016: Test Stack — BATS + Pester + pytest/DeepEval, 100% Four-Stack

**Decision**: Unit tests use pytest (white-box, mocked per UTP-NNN-C
patterns). Shell-facing integration tests use BATS. PowerShell-facing tests
use Pester. LLM-as-judge semantic quality evals use pytest + DeepEval GEval
with Gemini 2.5 Flash. All four stacks must reach 100% coverage before merge
(REQ-NF-001).

**Justification**: constitution.md §Testing Stack lists BATS, Pester, and
"pytest + DeepEval" with Gemini as the four-stack mandate. requirements.md
REQ-NF-001: "The bridge commands collectively SHALL achieve 100% test
coverage across BATS, Pester, structural eval, and LLM eval test suites
before merge." system-design.md SYS-013 (Quality & Process Compliance
Harness) enforces this at merge time.

**Authoritative Source**: constitution.md §Testing Stack; requirements.md
REQ-NF-001; system-design.md SYS-013; architecture-design.md ARCH-017.

---

## [DERIVED REQUIREMENT] Flags

No `[DERIVED REQUIREMENT]` or `[DERIVED MODULE]` flags were encountered
during synthesis. Every design decision above maps directly to an existing
REQ-NNN, SYS-NNN, ARCH-NNN, or MOD-NNN. No new identifiers were introduced.

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Design decisions documented | 16 |
| NEEDS CLARIFICATION items | 0 |
| DERIVED REQUIREMENT flags | 0 |
| Unresolved items flagged for human review | 0 |
| V-Model artifact IDs cited (unique) | 42 |
