# Changelog

All notable changes to the V-Model Extension Pack are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.7.2] — Extension Packaging Hygiene & Handoff Documentation — 2026-05-17

> **Release theme**: address two drift hazards surfaced during the v0.7.1 release and subsequent dogfood-refresh investigation — (1) the README's hardcoded install-URL drift, (2) the `specify extension add` install vendoring the entire repo because no `.extensionignore` existed — plus two Epic 3 stabilization tasks land: handoff-graph documentation and template-overlay mismatch cleanup. No new commands. No new features. No new functionality.

### Fixed

- **README install URL drift.** The Quick Start snippet in `README.md` hardcoded `v0.7.0.zip`, so end users following the README after v0.7.1 were still installing v0.7.0. Updated to `v0.7.1.zip` mid-cycle (during this release's preparation) and to `v0.7.2.zip` as part of the v0.7.2 ceremony. Going forward, the release ceremony bumps this URL alongside `pyproject.toml` / `extension.yml` / `catalog-entry.json`.

### Changed — Extension packaging hygiene

- **New `.extensionignore` at repo root.** Tells `specify extension add` to skip development sources (`tests/`, `specs/`, `docs/`, `site/`, `.specify/`, `.github/`, `examples/`, `media/`, `presentations/`, `refactoring_plan/`, plus build/IDE/OS cruft) when vendoring the extension into a user's project. Without this file, an install via the GitHub archive zip vendored the entire repo (~700 files at v0.7.1), including the recursive-vendor hazard `.specify/extensions/v-model/.specify/...`. With this file, the install footprint drops to ~165 files — commands, scripts, templates, and extension metadata. Takes effect when consumers use a `specify-cli` recent enough to honour `.extensionignore`.

### Changed — Epic 3 stabilization

- **Handoff graph documented (Epic 3 Task 5).** New `AGENTS.md` §11 inventories every handoff declared in `commands/*.md` frontmatter: the forward V-Model lifecycle (L1–L4 design→test→trace), cross-cutting handoffs (hazard-analysis, impact-analysis, peer-review, test-results, audit-report), bridge handoffs (plan→tasks→implement), and the nine backward "Back to X" user buttons. Documents the **three intentional cycles** (peer-review self-loop; trace↔acceptance gap-fix loop; plan↔tasks↔implement bridge refinement) with their termination conditions. Documents the **one historically-removed handoff** (`plan` → `implement` direct, removed in v0.7.0 per MF-10) so it doesn't get re-introduced. States the invariants the graph enforces (every auto-dispatch converges on `trace`; backward handoffs are user-button only; every handoff has all four fields). Renumbers existing §11/§12/§13 → §12/§13/§14.

- **Template overlay mismatch resolved (Epic 3 Task 7).** `commands/requirements.md` and `commands/acceptance.md` instructed the LLM to read domain-specific template overlays (`templates/overlays/{domain}/*-template.md`), but those files never existed — only empty `.gitkeep` placeholders in the three domain directories. Per the audit's Definition of Done ("either implement OR remove the instructions"), the instructions are removed. The empty directories are kept as placeholders for future intent. The `commands/overlays/{domain}/<command>.md` mechanism (which IS populated and DOES work) is unchanged.

### Test infrastructure

- `tests/structural/test_extension_yml.py::test_no_spec_kit_core_file_modified_outside_extension_yml` allow-list now permits `.extensionignore` at the repo root.

### Deferred to a later v0.7.x or v0.8.0

- **Epic 3 Tasks 2, 3, 4** (extract shared prompt policies; reduce each command to single responsibility; refactor bridge prompts especially `implement`). The audit's Definition of Done for these tasks presupposes either a build-time generator or an install-time include mechanism — tooling we don't have. Lightweight versions (standardize-and-CI-test rather than extract-and-include) were considered but defer the bigger architectural decision (build the tooling, redesign the prompts, or adapt the DoDs) to a later release.

### Known Limitations

(unchanged from v0.7.1 — see [0.7.1] entry below for the two LLM-eval variance flakes and the PowerShell mirror gap for `update-agent-context.sh`.)

---

## [0.7.1] — Bridge Command Reconciliation & Governance — 2026-05-17

> **Release theme**: reconcile the v0.7.0 bridge commands with their user-facing intent — that `/speckit.v-model.implement` produces *a fully working and validated implementation* from the V-Model artefact set — and adopt a real contributor operating manual + an additive constitution amendment that codifies the discipline the v0.7.0 design did not yet capture. No new commands, no new features, no new functionality. Surgical reconciliation.

### Changed — `/speckit.v-model.implement` aligned with north-star intent

- **Direct Path now works.** Per REQ-015 the command reads the V-Model artefact set directly and produces a fully working and validated implementation without needing `/speckit.v-model.plan` or `/speckit.v-model.tasks` to have run first. The `--require-tasks` flag was removed from the frontmatter `scripts.sh` invocation; `tasks.md`, when present, is consumed as supplemental ordering context only.
- **Iteration source restored to `module-design.md`.** Per MOD-006 pseudocode, `§Code Generation` iterates `module-design.md` `MOD-NNN` rows directly rather than filtering through `tasks.md` rows. Per-MOD rendering explicitly consults `unit-test.md` (test-first behaviour the code must exhibit), `architecture-design.md` (interface contracts to honour), `system-design.md` (system context to fit within), `requirements.md` (REQ intent to satisfy), and the higher-level test plans as compatibility inputs alongside `module-design.md`.
- **All 8 V-Model artefacts mandatory.** The four dev-side (`requirements.md`, `system-design.md`, `architecture-design.md`, `module-design.md`) AND the four test-side (`acceptance-plan.md`, `system-test.md`, `integration-test.md`, `unit-test.md`) are equally load-bearing for code generation. Missing any of the 8 is fatal — partial implementation contradicts the "fully working and validated software" contract. `hazard-analysis.md` remains the sole auxiliary input (its absence is a warning). The `§Reduced-enrichment fallback` step (formerly Step 9) was removed; remaining Steps 10–12 renumbered to 9–11. (REQ-NF-005B)

### Changed — `/speckit.v-model.plan` and `/speckit.v-model.tasks` marked OPTIONAL

- Both Goal sections now open with "**This is an OPTIONAL bridge command.**" and explain when to use them (handoff to spec-kit-core tooling, human review of canonical artefacts) versus the Direct Path via `/speckit.v-model.implement`.
- REQ-NF-005 was split: **REQ-NF-005A** governs plan/tasks (graceful degradation when optional artefacts are absent — schema-compatibility is their contract, not working software); **REQ-NF-005B** governs implement (refuses on any missing V-Model artefact).

### Changed — Constitution v1.0.0 → v1.1.0 (MINOR, additive)

Five core principles unchanged. Per the constitution's own amendment procedure (PR + rationale + Sync Impact Report + version bump). Adds:

- **§V-Model Artifact Map** — the 8 paired artefacts (L1–L4 dev-side and test-side) that form the single source of truth for everything downstream.
- **§Bridge Command Discipline** — strict mode (all 8 artefacts `[Approved]` before any bridge runs), V-Model artefacts as single source of truth, sibling-file projections, **substance over shape**, read-only access to compliance-critical artefacts, versioned Report Completion JSON.
- **Expanded §ID Schema** — full identifier set across REQ/ATP/SCN, SYS/STP/STS, ARCH/ITP/ITS, MOD/UTP/UTS, HAZ, PRF, WAV + lifecycle invariants (never-renumber, `[DEPRECATED]` / `[SUSPECT]` markers, scope markers `[EXTERNAL]` / `[CROSS-CUTTING]`).
- **Audience preamble** — the constitution governs the development of the V-Model Extension Pack itself. Teams using the extension on their own project have their own constitution; this one is ours.

### Added — `AGENTS.md` as the contributor operating manual

- New `AGENTS.md` replaces the auto-generated `CLAUDE.md` boilerplate. Vendor-neutral (matches upstream `spec-kit`'s convention), hand-curated, scoped explicitly to contributors evolving the extension — **not** to end users running the extension on their own safety-critical project (who maintain their own `AGENTS.md` and constitution).
- Sections: audience boundary, the mantra ("AI drafts, human decides, scripts verify, Git remembers"), trust separation table (AI / scripts / humans / Git roles), the 8 V-Model artefacts as single source of truth, bridge command discipline, substance over shape, ID schema, repo map of canonical sources, command naming convention, working conventions (Bash `set -euo pipefail`; PowerShell `[CmdletBinding()]`; atomic `mktemp`+`mv`), the cleanup-vs-sprawl rule, and common pitfalls.
- Auto-managed footer (`## Active Technologies` / `## Recent Changes`) so `.specify/scripts/bash/update-agent-context.sh` can continue to update those two sections in place without disturbing the hand-curated body.

### Changed — Canonical-ID grammar generalised

- The canonical regex in `commands/implement.md` Step 9, `tests/conftest.py::_CANONICAL_PATTERN`, and `tests/evals/test_commit_suffix.py::_ID` now accepts any 2–3-letter uppercase sub-prefix on any root: `(?:REQ|SYS|ARCH|MOD|…)(?:-[A-Z]{2,3})?-\d+(?:-[A-Z]\d*)?`. This generalises the prior REQ-NF/REQ-CN/REQ-IF enumeration to cover every derived-category convention the project actually uses (REQ-DR, REQ-LC, REQ-SEC, SYS-DR, ATP-NF/CN/IF/LC, SCN-NF/CN/IF/LC, STP-NF). Previously-silent non-compliers (e.g. `SYS-DR-NNN` in fixtures and v0.6.0 specs) now validate cleanly.
- Uppercase fixup for the new split: `REQ-NF-005A` and `REQ-NF-005B` (lowercase `a`/`b` introduced during reconciliation didn't match the canonical suffix grammar `-[A-Z]\d*`).

### Documentation

- Consolidate release narratives to `CHANGELOG.md` as the single source of truth. The parallel `docs/releases/vX.Y.Z.md` pattern (introduced in v0.7.0) is removed along with its sole occupant `docs/releases/v0.7.0.md`. README's EPIC-1 cross-reference retargeted to `CHANGELOG.md#known-limitations-deferred-to-v080`.
- Bridge command Goal sections rewritten to lead with user-facing capability rather than schema-compatibility framing.

### Fixed

- `tests/structural/test_extension_yml.py::test_no_spec_kit_core_file_modified_outside_extension_yml` allow-list now permits `AGENTS.md` (the test previously listed only `CLAUDE.md`).
- `tests/evals/test_commit_suffix.py::_extract_commit_subject` now honours the §Structured Summary contract — the implement command's prompt documents `commit_subject:` as "the machine-extractable mirror of the prepared commit subject," but the extractor previously only looked for a literal `git commit -m "..."` invocation and fell through to a too-permissive line-based fallback that grabbed JSON-formatting characters from the Structured Summary line. Added JSON (`"commit_subject": "..."`) and YAML (`commit_subject: ...`) extraction strategies between the literal-command lookup and the line-based fallback.

### Known Limitations

- **LLM-eval variance over strict thresholds.** Two `llm_judge`-marked tests fail intermittently on the `complete` fixture due to LLM emission non-determinism over strict thresholds. Both pass on targeted re-runs:
  - `tests/evals/test_implements_per_symbol.py::test_every_public_symbol_has_implements_comment` — checks that `Implements:` directive count ≥ detected public-symbol count. Symbol count swings widely between runs (137–182 observed). A later patch may tighten the implement command's per-symbol `Implements` wording or restrict `_PUBLIC_SYMBOL_RE` to V-Model-mappable symbols.
  - `tests/evals/test_tasks_order.py::test_complete_fixture_emits_tdd_ordering` — checks that ≥ 4 of the 8 `**Write unit tests**`-style bold phase markers appear in the synthesised `tasks.md`. Some runs emit the tasks.md without the bold phase headers; re-running produces them. A later patch may tighten the tasks command's §TDD Ordering instructions.
- **PowerShell mirror gap for `update-agent-context.sh`** — the upstream `.specify/scripts/bash/update-agent-context.sh` has no PowerShell counterpart anywhere in the repo. This is an upstream spec-kit-core parity gap that the v-model extension does not own. On Windows / pwsh-only environments the agent-context auto-update workflow has no equivalent.

---

## [0.7.0] — Bridge Commands & Pre-v0.8.0 Stabilization — 2026-05-03

### Added — Bridge Commands

- **`/speckit.v-model.plan`** — wraps `/speckit.plan`; synthesises a V-Model-enriched `plan.md` (5 H2 sections in fixed order: Summary, Technical Context, Constitution Check, Project Structure, Complexity Tracking) with additive HTML-comment annotations from the V-Model artifact set; output validated against pinned `plan-schema-v0.7.0.json`.
- **`/speckit.v-model.tasks`** — wraps `/speckit.tasks`; produces a TDD-ordered `tasks.md` (12 H2s preserved verbatim) with hazard-driven priority elevation and per-`HAZ` verification tasks. Each task carries an `Implements`-directive header bound to a V-Model module / integration / system test ID.
- **`/speckit.v-model.implement`** — wraps `/speckit.implement`; runs the deterministic 12-step pipeline (setup → 8-stage gate → domain overlay → codegen → 4-level test gen → splice → hallucination guard → quality harness → reduced-enrichment fallback → commit annotation → structured summary → handoffs).

### Added — Lifecycle Hooks

- **`after_specify`** — wires the V-Model directory layout under each new feature folder.
- **`after_tasks`** — re-runs `/speckit.v-model.trace` to refresh the trace matrix after `/speckit.v-model.tasks`.
- **`before_implement`** — re-runs the 8-stage `run-v-model-gate.sh` as a fail-fast pre-implementation check.
- **`after_implement`** — re-runs `/speckit.v-model.trace` to refresh the trace matrix.

All four hooks are `optional: true` in v0.7.0 and become mandatory under the upcoming `compliance_mode: strict` profile (EPIC-1, v0.8.0).

### Added — Validators & Orchestrator

- **`run-v-model-gate.sh` / `.ps1`** — 8-stage orchestrator: `status → domain → matrix → requirement-coverage → system-coverage → architecture-coverage → module-coverage → hazard-coverage`.
- **`validate-artifact-status.sh` / `.ps1`** (MF-6) — approval-status gate; default required = `**Status**: Approved` per artifact, configurable via `--required-status`.
- **`validate-domain-profile.sh` / `.ps1`** (MF-7) — domain config validator; absent `v-model-config.yml` = SKIP, present-and-invalid = fatal. Accepts only `iso_26262`, `do_178c`, `iec_62304`. Companion file: **`v-model-config.yml.example`** at repo root.
- **`validate-core-schema.sh` / `.ps1`** (MF-4) — three-pass validator (existence → ordering → wedge rejection) for `plan.md` (5 H2s) and `tasks.md` (12 H2s); enforced via `diff -u` against pinned heading sequences.
- **`validate-implements-ids.sh` / `.ps1`** (MF-2) — adds `--canonical / --scan / --changed-only`. The hallucination guard now scans the **repo root** (not just the V-Model dir) and intersects with `git diff` so that `src/` and `tests/{unit,integration,system,acceptance}/` are in scope.
- **`setup-{plan,tasks,implement}.sh` / `.ps1`** (MF-1) — V-Model-aware wrappers around the upstream `setup-*` scripts; surface `VMODEL_DIR` to the bridge prompts.

### Changed — Splicer Hardening (MF-5)

- **`splice-managed-regions.sh` / `.ps1`** — BEGIN/END `id` mismatch and duplicate-`id` detection (exit 2); new `--region-from <regions-file>` per-region payload mode using `<<<REGION id="X">>>...<<<END>>>` syntax; `diff -u original spliced` emitted on **stderr** on every successful run for audit-trail capture. Single-payload invocations remain byte-identical on stdout.

### Changed — Build-Matrix Hardening (MF-3)

- **`build-matrix.sh`** — same-dir `mktemp` plus `EXIT/INT/TERM` trap. No more `/tmp` writes; concurrent matrix builds are now safe.

### Changed — Prompt + Docs Alignment (MF-9 + MF-10)

- `commands/plan.md` no longer advertises a direct `Implement Plan` handoff; the V-Model lifecycle is now `plan → tasks → implement` (no shortcut around `tasks`).
- `README.md` adds the **Compliance & Hybrid Modes** section distinguishing the **compliant** end-to-end V-Model bridge from the **hybrid** mode (feeding a V-Model `tasks.md` to core `/speckit.implement`). Hybrid mode is documented as a prototyping-only escape hatch.
- New release notes: `docs/releases/v0.7.0.md`.

### Changed — Domain Set Narrowed (semantic break from v0.6.0)

- The valid `domain:` value set is now strictly `{iso_26262, do_178c, iec_62304}`. The pre-v0.7.0 industry-vernacular synonyms `automotive`, `medical`, `aerospace` are rejected by `validate-domain-profile`. The **`general` overlay has been removed** with no replacement; non-regulated repositories should omit the `domain:` key (or the entire `v-model-config.yml`).
- **Migration:** rename `domain: automotive` → `domain: iso_26262`, `domain: medical` → `domain: iec_62304`, `domain: aerospace` → `domain: do_178c`. If you used `domain: general`, delete the key. See [Configuration — Migration](https://leocamello.github.io/spec-kit-v-model/reference/configuration/#domain).

### Documentation

- New guide: **[Bridge Commands](https://leocamello.github.io/spec-kit-v-model/guide/bridge-commands/)** — end-to-end bridge workflow, the 8-stage gate, the splicer, the compliant-vs-hybrid distinction.
- MkDocs site refreshed for v0.7.0 (`reference/commands.md`, `reference/scripts.md`, `reference/configuration.md`, `community/changelog.md`, `community/roadmap.md`, `getting-started/*`).
- Root docs updated: `README.md` (17 commands, refreshed test counts, Compliance & Hybrid Modes), `tests/README.md`, `CONTRIBUTING.md` (V-Model gate subsection), `SECURITY.md` (0.6.x / 0.7.x supported), `CLAUDE.md` (template tokens resolved).

### Stats

| Metric | v0.6.0 | v0.7.0 |
|--------|-------:|-------:|
| Commands | 14 | **17** |
| Lifecycle hooks | 1 | **4** |
| Gate stages | 6 | **8** |
| BATS tests | 364 | **455** |
| Pester tests | 347 | **431** |
| Structural pytest | 89 | 89 |
| LLM-as-judge evals | 53 | 53 |
| End-to-end (E2E) tests | — | 32 (newly disclosed) |

### Known Limitations (deferred to v0.8.0)

- **EPIC-1** `compliance_mode: strict` profile — flips the 4 lifecycle hooks from `optional: true` to mandatory.
- **EPIC-2** Sealed baseline — cryptographic seal of the canonical V-Model artifact set per release tag.
- **EPIC-3** Immutable-artifact protection — pre-receive hook rejecting post-freeze edits to canonical artifacts.
- **EPIC-4** Semantic `Implements`-directive validation — beyond ID-existence to ID-relevance.
- **EPIC-5** `v-model verify` aggregator — single-command SARIF/JSON summary across all 8 gate stages.
- **EPIC-6** Authorized managed regions — splicer ACL by region `id`.
- **EPIC-7** Hybrid-mode telemetry — count and report bypassed gates.
- **EPIC-8** Per-domain trace-matrix presets — narrower validators per regulatory regime.
- **EPIC-9** Plan/Tasks schema migration tooling — versioned schema upgrade path beyond v0.7.0.
- **EPIC-10** Multi-domain projects — per-feature `domain:` overlays in monorepos.
- **`specs/007-bridge-commands/` cross-cutting modules** ARCH-008 / ARCH-014 / ARCH-016 lack dedicated ITP coverage; the V-Model artifact set is frozen at `618d706` per the Phase B paradigm lock and remediation is deferred to v0.8.0.

---

## [0.6.0] — 2026-04-25

### Added — Domain Overlay Architecture

- **Domain overlay system** — all 11 V-Model commands are now domain-agnostic; a `domain:` field in `config-template.yml` activates the correct domain overlay (automotive, medical, aerospace, general)
- **9 domain overlay manifests** — one per command (`requirements`, `acceptance`, `system-design`, `system-test`, `architecture-design`, `integration-test`, `module-design`, `unit-test`, `hazard-analysis`), each declaring domain-specific standards, terminology substitutions, and output conventions
- **`domain-overlay/` directory structure** — `automotive/`, `medical/`, `aerospace/`, `general/` with per-command YAML manifests; enables brownfield adoption without changing core command logic
- **Feature specs dogfooded** — `specs/006a-domain-overlay/` full V-Model cycle (33 REQs, 42 ATPs, 9 SYS, 18 ARCH, 30 MODs, 62 UTPs, 207 UTSs, 4-matrix traceability)

### Added — ID Lifecycle Model

- **Explicit state machine** for all V-Model IDs: `Proposed → Active → Deprecated → Removed` with mandatory `## Lifecycle History` section in every artifact
- **Lifecycle history templates** added to all 9 V-Model command output templates and all agent prompts — append-only history preserves regulatory audit trail
- **Feature spec dogfooded** — `specs/006b-id-lifecycle/` full V-Model cycle (25 REQs, 9 SYS, 17 ARCH, 21 MODs, 33 UTPs, 107 UTSs, 4-matrix traceability)

### Added — Standards Enrichment

- **Governing Standards sections** added to all 11 commands — each command now declares the standards it applies and maps them to specific execution steps (e.g., `### Step 3. Quality Criteria (IEEE 1012:2016 / ISO 25010:2023)`)
- **Standards applied per command**: IEEE 1012:2016 (V&V), ISO 25010:2023 (quality attributes), ISO 42030:2019 (architecture evaluation), ISO 12207:2017 (software lifecycle), INCOSE SE Handbook, IEEE 1016, IEEE 29148, ISO 29119-4, ISO 14971, DO-178C, ARP4761A
- **`docs/standards-reference.md`** reconciled — §1.2 (Commands) and §2.3 (Standards) now in full agreement; missing domain overlays (automotive, medical, aerospace) added
- **All 11 agent definition files** synced with enriched command content in `.github/agents/`
- **V&V Coverage Gate** added to system-test, integration-test, unit-test, and audit-report commands (IEEE 1012:2016 §7 completeness criteria)
- **Architecture Evaluation step** added to architecture-design command (ISO 42030:2019 / ISO 25010:2023 quality attributes)
- **Quality attribute cross-check** added to system-design command (ISO 25010:2023 — Reliability, Safety, Maintainability, Portability)

### Added — Aerospace (DO-178C) Support

- **Flight Warning Computer (FWC) golden fixture** — DO-178C DAL-A avionics benchmark: 10 artifact files covering a 5-function FWC system (overspeed, stall, altitude alerting, GPWS, attitude limit) with ARP4761A hazard analysis, 9 SYS components, 9 ARCH modules
- **11 new LLM-as-judge eval tests** for the FWC domain (BDD quality, architecture completeness, FMEA completeness, operational state coverage, traceability, requirements quality, system design, system test, integration quality, module completeness, unit test quality)
- **[Brownfield Evolution Guide](https://leocamello.github.io/spec-kit-v-model/guide/brownfield-evolution/)** (`site/docs/guide/brownfield-evolution.md`) — step-by-step guide for adopting V-Model on existing projects

### Added — Test Infrastructure

- **`tests/fixtures/commands/`** namespace — `audit-report/` and `test-results/` command fixtures now live under `commands/` alongside `input/` and `expected/` sub-directories for clean separation from scenario fixtures
- **Audit-report expected outputs** — `expected/clean.md`, `expected/waived.md`, `expected/blocking.md` golden outputs for deterministic output comparison
- **DO-178C/DAL-A LLM eval benchmark** — `tests/fixtures/golden/flight-warning-computer/` with 10 expected artifact files; 11 `@pytest.mark.eval` tests across all eval files
- **Traceability eval timeout fix** — `_strip_non_traceability_sections()` helper strips `## Governing Standards` and `## Coverage Summary` from acceptance plan before LLM-judge payload, reducing medical device combined payload from 13.5 KB to 12.2 KB (within `gemini-2.5-flash` latency budget)
- **Minimal interface contract fixture** enriched — explicit types (`uint8`, `uint32`, `float32`, `uint16`, `enum`) and `Protocol:` fields added to all 3 ARCH modules; fixes `test_minimal_interface_contract_quality`

### Changed

- Extension version bumped from 0.5.0 to 0.6.0
- All 11 commands genericized — domain-specific terminology (ISO 26262 ASIL, IEC 62304 Class, DO-178C DAL) replaced with overlay-injected terminology controlled by the `domain:` config field
- `extension.yml` command descriptions rewritten to be domain-agnostic
- `specs/002` through `specs/005e` evolved with Standards Enrichment content (lifecycle history, governing standards, V&V coverage gates, quality attribute cross-checks)
- `specs/001-v-model-mvp` fully dogfooded — all 9 V-Model artifacts generated for the MVP spec
- `.gitignore` updated with `.env` and `.env.local` to prevent accidental credential commits

### Stats

- Commands: 14 (unchanged)
- Domain overlays: 0 → 9
- BATS tests: 364 (unchanged)
- Pester tests: 347 (unchanged)
- Structural evals: 89 (unchanged)
- LLM-as-judge evals: 42 → 53 (+11 DO-178C/DAL-A aerospace golden benchmark)
- Dogfooded feature specs: 5 → 7 (+006a domain overlay, +006b ID lifecycle)

## [0.5.0] — 2026-04-06

### Added — New Commands

- **`hazard-analysis`** — ISO 14971/26262 Failure Mode and Effects Analysis (FMEA) with `HAZ-NNN` hazard identifiers, operational state awareness, severity × likelihood risk matrix, mitigation traceability to REQ/SYS IDs, and progressive deepening (append-only at architecture level)
  - `hazard-analysis-template.md` — FMEA table template with 10 columns
  - `validate-hazard-coverage.sh` / `validate-hazard-coverage.ps1` — Three-dimensional deterministic validator: forward (SYS→HAZ), backward (HAZ→REQ/SYS), and operational state consistency checks with `--partial` and `--json` flags
  - Matrix H (Hazard Traceability) in traceability matrix — HAZ → Mitigation → Verification linkage
  - HAZ-NNN ID pattern in `id_validator.py`
- **`impact-analysis`** — Deterministic change impact analysis that builds a dependency graph from all V-Model markdown artifacts and traverses it to identify suspect artifacts affected by a change
  - `--downward` (default), `--upward`, and `--full` bidirectional traversal modes
  - `--json` flag for CI integration (structured JSON with blast radius, suspect artifacts by level, re-validation order)
  - Multi-ID support, <2s for 500+ IDs across 10+ artifact files
  - `impact-analysis.sh` / `impact-analysis.ps1` — Bash and PowerShell scripts with awk-based graph parser and BFS traversal
- **`peer-review`** — AI-powered stateless linter for any V-Model artifact, evaluating against standards-based criteria (INCOSE, IEEE 1016/42010, ISO 29119, ISO 14971, DO-178C) and producing `PRF-{ARTIFACT}-NNN` findings with severity classifications (Critical, Major, Minor, Observation)
  - Stateless linting model: findings regenerated from scratch each run, like ESLint
  - `peer-review-check.sh` / `Peer-Review-Check.ps1` — CI parser scripts with exit codes: 0 (clean), 1 (Critical/Major — blocks PR), 2 (Minor — warning)
- **`test-results`** — 100% deterministic JUnit XML + Cobertura XML ingestor that updates the traceability matrix in-place, flipping `⬜ Untested` to `✅ Passed` / `❌ Failed` / `⏭️ Skipped` with Date, Commit SHA, and optional Coverage columns
  - `parse_test_results.py` — stdlib-only Python helper (xml.etree.ElementTree) with 5 modules
  - `ingest-test-results.sh` / `Ingest-Test-Results.ps1` — Bash and PowerShell wrappers (1:1 parity)
  - Coverage mapping via `coverage-map.yml` or convention-based matching from `module-design.md`
- **`audit-report`** — 100% deterministic release audit report builder that produces a point-in-time `release-audit-report.md` for regulatory submission
  - Artifact inventory, traceability matrix embedding, coverage analysis, hazard management summary
  - Anomaly detection with waiver cross-referencing via `waivers.md` (WAV-NNN entries)
  - Compliance gating: ✅ RELEASE READY / ⚠️ RELEASE CANDIDATE / ❌ NOT READY
  - `build-audit-report.sh` / `Build-Audit-Report.ps1` — Bash and PowerShell scripts (1:1 parity)

### Added — Release Enhancements

- `validate-level.sh` / `Validate-Level.ps1` — Dispatch wrapper that invokes the correct validator for any V-Model level (acceptance → requirement-coverage, system-test → system-coverage, integration-test → architecture-coverage, unit-test → module-coverage, hazard-analysis → hazard-coverage) with `--json` and `--partial` flag support
- Agent definitions (`.github/agents/`) for all 14 commands — previously only 3 existed (requirements, acceptance, trace); now all commands have full agent prompts
- Sample CI workflow template (`examples/github-actions/v-model-validation.yml`) — configurable GitHub Actions workflow with conditional validators, GITHUB_STEP_SUMMARY, peer review check, and audit report generation
- 56 V-Model specification documents promoted from Draft to Approved across specs/002–005e

### Added — Test Infrastructure

- Hazard analysis fixtures: minimal (5 HAZ), complex (12 HAZ), gaps, golden/automotive-adas (15 HAZ, ISO 26262), golden/medical-device (12 HAZ, ISO 14971)
- Impact analysis fixtures: linear, diamond, disconnected — with 17 golden JSON outputs
- Peer review fixtures: clean, critical-major, minor-only, mixed-severity, observations-only
- Test results fixtures: 8 JUnit XML scenarios, 2 Cobertura XML, 3 matrix fixtures, 10 golden JSON outputs
- Audit report fixtures: clean, waived, blocking, orphaned-waiver, missing-required — with golden `.md` + `.json` outputs
- Validate-level fixtures reusing existing minimal/gaps directories
- Python structural validators: `hazard_validators.py`, `impact_validators.py`
- DeepEval metric wrappers: `StructuralHazardAnalysisMetric`, `StructuralImpactAnalysisMetric`

### Added — Dogfooded V-Model Artifacts

- `specs/005a-hazard-analysis/` — full V-Model cycle for hazard-analysis command
- `specs/005b-impact-analysis/` — full V-Model cycle for impact-analysis command
- `specs/005c-peer-review/` — full V-Model cycle for peer-review command (37 REQs, 74 ATPs)
- `specs/005d-test-results/` — full V-Model cycle for test-results command (30 REQs, 53 UTSs)
- `specs/005e-audit-report/` — full V-Model cycle for audit-report command

### Changed

- `build-matrix.sh` / `build-matrix.ps1` extended with Matrix H generation block (auto-detected when hazard-analysis.md exists)
- `trace` command updated for five-matrix output (A + B + C + D + H)
- `classify_id()` in both Bash and PowerShell now maps ALL compound prefixes (e.g., `SYS-DR`, `REQ-DR`) to their base V-Model level
- `extension.yml` updated with all 5 new commands (14 total) and `peer_review_findings: "PRF"` ID prefix
- Documentation updated: README, compliance-guide, id-schema-guide, usage-examples, product-vision, v-model-overview, CONTRIBUTING

### Stats

- Commands: 9 → 14
- Bash scripts: 7 → 13 (+ validate-hazard-coverage, validate-level, impact-analysis, peer-review-check, ingest-test-results, build-audit-report)
- PowerShell scripts: 7 → 13 (+ Validate-Hazard-Coverage, Validate-Level, Impact-Analysis, Peer-Review-Check, Ingest-Test-Results, Build-Audit-Report)
- BATS tests: 91 → 364
- Pester tests: 91 → 347
- Structural evals: 51 → 89
- LLM-as-judge evals: 36 → 42
- Agent definitions: 3 → 14

## [0.4.0] — 2026-02-22

### Added
- `module-design` command — DO-178C/ISO 26262-compliant low-level module designs with four mandatory views (Algorithmic/Logic, State Machine, Internal Data Structures, Error Handling & Return Codes)
- `unit-test` command — ISO 29119-4 white-box unit test plans with five named techniques (Statement & Branch Coverage, Boundary Value Analysis, Equivalence Partitioning, State Transition Testing, Strict Isolation) and Dependency & Mock Registries
- `validate-module-coverage.sh` / `validate-module-coverage.ps1` — Deterministic ARCH→MOD→UTP→UTS bidirectional coverage validation with EXTERNAL and CROSS-CUTTING module support
- Matrix D (Unit Verification) in traceability matrix — ARCH → MOD → UTP → UTS with parent ARCH annotations
- `--require-module-design`, `--require-unit-test` flags for setup-v-model (bash + PowerShell)
- Module design and unit test fixtures across all scenario directories (minimal, complex, gaps, empty, golden)
- Module-level validators (`validate_module_design()`, `validate_unit_test()` in template_validator.py; `module_validators.py`)
- MOD-NNN, UTP-NNN-X, UTS-NNN-X# ID patterns in id_validator.py
- EXTERNAL and DERIVED MODULE tags for third-party and emergent module designs
- Pester test suite: `Validate-Module-Coverage.Tests.ps1` (16 tests)
- Module design and unit test LLM-as-judge quality metrics (completeness, logic quality, data structure precision, coverage quality, technique appropriateness, isolation strictness)
- E2E evaluation tests for module-design and unit-test commands (4 tests each)
- `docs/id-schema-guide.md` — Comprehensive guide to the four-tier ID schema, intra-level vs inter-level linking, lifecycle, and end-to-end traceability examples

### Changed
- Extension version bumped from 0.3.0 to 0.4.0
- setup-v-model.sh/ps1 now detects module-design.md and unit-test.md in AVAILABLE_DOCS; 8 symmetric require flags
- build-matrix.sh/ps1 extended with Matrix D generation
- trace.md updated from triple-matrix to quadruple-matrix output (A + B + C + D)
- Test fixture directories expanded from 6 to 8 V-Model files each (+module-design.md, +unit-test.md)
- Renamed `validate-coverage` → `validate-requirement-coverage` across all scripts, tests, docs, and specs for consistent `validate-{design-level}-coverage` naming convention
- Documentation updated for v0.4.0: README (12-step workflow, 9 commands, 4-tier ID schema), CONTRIBUTING, SECURITY, compliance-guide, usage-examples, v-model-config, v-model-overview, product-vision
- Total commands: 7 → 9; BATS tests: 67 → 91; Pester tests: 67 → 91; Structural evals: 37 → 51; LLM-as-judge evals: 26 → 36; E2E evals: 24 → 32

### Fixed
- BATS test for validate-system-coverage partial mode now correctly expects exit 0 (script was updated in v0.2.0 but test was not)
- PowerShell `validate-system-coverage.ps1` now supports partial mode when `system-test.md` is absent (parity with bash script)
- PowerShell `validate-system-coverage.ps1` handles empty files via null-coalescing (`Get-Content -Raw` returns `$null` for 0-byte files)
- Minimal module-design fixture now includes typed function signatures and complete type definitions for all pseudocode references

## [0.3.0] — 2026-02-21

### Added
- `architecture-design` command — IEEE 42010/Kruchten 4+1 architecture decomposition with Logical, Process, Interface, and Data Flow views
- `integration-test` command — ISO 29119-4 integration testing with Interface Contract, Data Flow, Fault Injection, and Concurrency techniques
- `validate-architecture-coverage.sh` / `validate-architecture-coverage.ps1` — Deterministic ARCH→ITP→ITS bidirectional coverage validation with CROSS-CUTTING module support
- Matrix C (Integration Verification) in traceability matrix — SYS → ARCH → ITP → ITS with parent REQ annotations
- `--require-system-design`, `--require-system-test`, `--require-architecture-design`, `--require-integration-test` flags for setup-v-model (bash + PowerShell)
- Architecture and integration test fixtures across all scenario directories (minimal, complex, gaps, empty, golden)
- Architecture-level validators (`architecture_validators.py`) and structural/E2E evaluations
- ARCH-NNN, ITP-NNN-X, ITS-NNN-X# ID patterns in id_validator.py
- CROSS-CUTTING module tag for infrastructure/utility architecture modules
- Pester test suite: `Validate-Architecture-Coverage.Tests.ps1` (15 tests)
- Architecture and integration LLM-as-judge quality metrics

### Changed
- Extension version bumped from 0.2.0 to 0.3.0
- setup-v-model.sh/ps1 now detects architecture-design.md and integration-test.md in AVAILABLE_DOCS; 6 symmetric require flags
- build-matrix.sh/ps1 extended with Matrix C generation
- trace.md updated from dual-matrix to triple-matrix output (A + B + C)
- Test fixture directories consolidated to shared scenario pattern (minimal, complex, gaps, empty) with 6 V-Model files each
- All Pester test fixture paths updated for consolidated directory structure
- Documentation updated for v0.3.0: README (9-step workflow, 7 commands, 3-tier ID schema), CONTRIBUTING, SECURITY, product-vision, v-model-config
- Total commands: 5 → 7; BATS tests: 48 → 67; Pester tests: 48 → 67; Structural evals: 21 → 37; LLM-as-judge evals: 16 → 26

## [0.2.0] — 2026-02-20

### Added

- `/speckit.v-model.system-design` command — Decomposes requirements into IEEE 1016-compliant system components
  - Four mandatory design views: Decomposition, Dependency, Interface, Data Design
  - Many-to-many REQ↔SYS traceability with derived requirements support
  - SYS-NNN ID schema with parent requirement references
- `/speckit.v-model.system-test` command — Generates ISO 29119-compliant system test plans
  - Named testing techniques: Interface Contract Testing, Boundary Value Analysis, Fault Injection, Equivalence Partitioning, State Transition Testing
  - Technical BDD scenarios (no user-journey language) with STP-NNN-X / STS-NNN-X# IDs
  - Anti-pattern guard: rejects user-journey phrasing in system-level tests
- Extended `/speckit.v-model.trace` command — Dual-matrix traceability output
  - Matrix A: REQ → ATP → SCN (acceptance-level, existing)
  - Matrix B: REQ → SYS → STP → STS (system-level, new)
  - Combined coverage metrics across both matrices
- System-level golden examples for evaluation:
  - Medical device (CBGMS): IEC 62304 Class C, 5 SYS components, 10 STP test cases
  - Automotive ADAS (AEB): ISO 26262 ASIL-D, 5 SYS components, 11 STP test cases
- E2E evaluation harness (`tests/evals/harness.py`) — faithfully simulates spec-kit command invocation via LLM
- 16 E2E evaluation tests (4 per command: structural + quality for each domain)
- Structural evaluations in PR CI (26 deterministic tests, no API keys required)
- Templates for system design and system test output documents
- Helper scripts for system-level coverage validation (Bash + PowerShell)

### Changed

- Template validators now accept both template-style ("Overview") and golden-fixture-style ("Document Control", "Test Strategy") sections
- `validate-requirement-coverage` and `build-matrix` scripts extended for dual-matrix support
- Evals workflow updated with E2E job for command invocation testing

## [0.1.0] — 2026-02-19

### Added

- Extension scaffold with `extension.yml` manifest (schema v1.0)
- `/speckit.v-model.requirements` command — Generates V-Model Requirements Specification
  - IEEE 29148 / INCOSE 8-criteria quality validation (Unambiguous, Testable, Atomic, Complete, Consistent, Traceable, Feasible, Necessary)
  - Banned words table enforcing measurable, testable language
  - Four requirement categories: Functional (REQ-), Non-Functional (REQ-NF-), Interface (REQ-IF-), Constraint (REQ-CN-)
  - Strict translator constraint for `spec.md` → `REQ-NNN` extraction
- `/speckit.v-model.acceptance` command — Generates three-tier Acceptance Test Plan
  - Test Cases (ATP-NNN-X) with 4 quality criteria (Traceable, Independent, Repeatable, Clear Expected Result)
  - BDD Scenarios (SCN-NNN-X#) with 4 quality criteria (Declarative, Single Action, Strict Preconditions, Observable Outcomes)
  - Batched generation (5 requirements per batch) to prevent token bloat
  - Deterministic 100% coverage validation gate via helper script
  - Append-only incremental updates with git diff change detection
- `/speckit.v-model.trace` command — Builds regulatory-grade Bidirectional Traceability Matrix
  - 4 pillars: Strict Bidirectionality, Orphan & Gap Analysis, Versioning & Baselines, Granular Execution State
  - 3-section output: Coverage Audit, Exception Report, 3D Matrix
  - Deterministic script-based matrix generation (not AI-generated)
- Output templates for requirements, acceptance plan, and traceability matrix
- Helper scripts (Bash + PowerShell):
  - `setup-v-model` — Directory setup and prerequisite checking
  - `validate-requirement-coverage` — Deterministic REQ→ATP→SCN coverage validation
  - `build-matrix` — Deterministic traceability matrix builder
  - `diff-requirements` — Detects changed/added requirements for incremental updates
- Extension configuration template (`config-template.yml`)
- Documentation:
  - `v-model-overview.md` — V-Model methodology context
  - `usage-examples.md` — Medical device (IEC 62304) and automotive (ISO 26262) examples
  - `compliance-guide.md` — Artifact mapping to IEC 62304, ISO 26262, DO-178C, FDA 21 CFR Part 820, IEC 61508
- `after_tasks` hook to automatically run traceability matrix after task generation
- Self-documenting three-tier ID schema: `REQ-NNN` → `ATP-NNN-X` → `SCN-NNN-X#`
