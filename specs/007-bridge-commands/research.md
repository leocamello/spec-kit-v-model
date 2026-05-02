# Research: Bridge Commands (V-Model ↔ Spec-Kit Core)

**Feature**: 007-bridge-commands
**Branch**: `feature/007-bridge-commands` @ `8a2dc5d`
**Status**: Phase 0 output of `/speckit.plan` (D-001 … D-016)

This document records every substantive design decision taken for
Step A.1 of the v0.7.0 finishing plan. Each decision cites at
least one V-Model identifier (REQ / SYS / ARCH / MOD / HAZ /
UTP / ITP / STP / ATP / SCN) drawn from the frozen V-Model artifact
set under `specs/007-bridge-commands/v-model/`. Decision
identifiers `D-NNN` are local to this file and to `plan.md`.

> Reading order: D-001 establishes the paradigm; D-002 enumerates
> the resulting deliverables; D-003 .. D-005 cover the four new
> shell scripts; D-006 fixes test ordering; D-007 covers hook
> wiring; D-008 covers the hallucination-guard invariant; D-009
> covers PowerShell parity; D-010 covers LLM eval + structural
> validator strategy; D-011 covers hazard-driven enrichment;
> D-012 covers trace-matrix regen invariant; D-013 / D-014 record
> the post-rework deviations recorded in
> `drift-diff-plan.md §Addendum`; D-015 covers sentinel
> preservation; D-016 covers the atomic-commit policy for
> region-preserving re-runs.

---

## D-001 — Paradigm: Markdown command-prompt + shell + YAML; zero new Python

**Decision**: Realise the three bridge commands as **Markdown
prompt files** under `commands/<name>.md` (each with YAML
frontmatter declaring `description`, `handoffs`, and a single
`scripts:` entry), plus **POSIX shell scripts** (and PowerShell
mirrors) for deterministic verification, plus **declarative YAML
hook entries** in `extension.yml`. Net new Python: **0 lines**.

**Rationale**: (a) The paradigm-drift audit
(`drift-diff-plan.md` §Executive Summary, §Classification Counts)
shows 0 GENUINELY-NEW-PYTHON components across SYS-001 … SYS-014,
ARCH-001 … ARCH-021, MOD-001 … MOD-027 — every one of the 62
components is realisable as `NEW-PROMPT-SECTION` (37 components),
`NEW-SHELL` (13 components), `REUSE-CORE` (3 components), or
`DROP` (9 components). (b) The project's 13 currently shipping
commands all follow this exact paradigm (one Markdown prompt per
slash-command). (c) Spec-kit core's `CommandRegistrar` in
`src/specify_cli/extensions.py` already handles slash-command
wiring at install time; introducing a Python orchestrator class
would duplicate it. (d) The system-design overview makes the
paradigm explicit: "No Python implementation code is introduced
by this feature" (`system-design.md` §Overview). The realisation
classification table (`system-design.md` §Decomposition View;
`architecture-design.md` §Logical View; `module-design.md` §Module
Map) tags every active component accordingly. **Cited V-Model IDs:
SYS-001, SYS-002, SYS-003, ARCH-001, ARCH-002, ARCH-003, ARCH-004,
MOD-001, MOD-003, MOD-005**.

**Alternatives considered**:
- *Python package* (`src/v_model_extension/`, ~50 source files,
  ~3,500 LOC) — rejected by the drift audit: 9× more components,
  ~5× more code, duplicates capabilities already provided by
  `CommandRegistrar`, `setup-plan.sh`, `check-prerequisites.sh`,
  and the existing `validate-*-coverage.sh` scripts (HAZ-018
  round-trip risk would also be amplified).
- *Hybrid Python + shell* (Python for orchestration, shell for
  verification) — rejected because the LLM is the orchestrator in
  this project's paradigm; an in-process Python orchestrator is
  redundant.

---

## D-002 — Deliverable inventory: 3 prompts + 4 scripts + 4 PS mirrors + 3 YAML entries

**Decision**: The complete shippable surface area is:

| Path | Realises (V-Model IDs) |
|------|------------------------|
| `commands/plan.md` | SYS-001, SYS-005 (plan side), SYS-010 (plan side), SYS-012 (plan side); ARCH-001, ARCH-002, ARCH-008 (plan side), ARCH-013 (plan side), ARCH-014, ARCH-016 (plan side); MOD-001, MOD-002, MOD-011, MOD-021 (plan side) |
| `commands/tasks.md` | SYS-002, SYS-005 (tasks side), SYS-009, SYS-010 (tasks side), SYS-012 (tasks side); ARCH-003, ARCH-008 (tasks side), ARCH-012, ARCH-013 (tasks side), ARCH-014, ARCH-016 (tasks side); MOD-003, MOD-004, MOD-012, MOD-016, MOD-019, MOD-021 (tasks side) |
| `commands/implement.md` | SYS-003, SYS-006 (invocation), SYS-007 (invocation), SYS-008, SYS-012 (implement side), SYS-014; ARCH-004, ARCH-005, ARCH-006, ARCH-009 (invocation), ARCH-010 (invocation), ARCH-011, ARCH-016 (implement side), ARCH-017, ARCH-018; MOD-005, MOD-006, MOD-007, MOD-008, MOD-009, MOD-013 (invocation), MOD-015, MOD-021 (implement side), MOD-022, MOD-023 |
| `scripts/bash/run-v-model-gate.sh` (+ `.ps1`) | SYS-004; ARCH-007; MOD-010 |
| `scripts/bash/validate-implements-ids.sh` (+ `.ps1`) | SYS-006; ARCH-009; MOD-013, MOD-025 |
| `scripts/bash/splice-managed-regions.sh` (+ `.ps1`) | SYS-007; ARCH-010; MOD-014 (and SYS-015 atomic-write safeguard) |
| `scripts/bash/validate-core-schema.sh` (+ `.ps1`) | SYS-010 (shell side); ARCH-013; MOD-017 (`--plan`), MOD-018 (`--tasks`) |
| `extension.yml` (3 new YAML entries) | SYS-011; ARCH-015; MOD-020 |
| **Deferred-risk notes (no functional contract)** | ARCH-019, ARCH-020, ARCH-021, MOD-024, MOD-026, MOD-027 (and the deprecated stub SYS-013 retained for ID stability per drift-diff-plan.md §Addendum) |

**Rationale**: This 1:1 mapping is the post-rework realisation
table from `drift-diff-plan.md §Proposed Net-New Component
Inventory` reconciled against `module-design.md §Module Map`. The
total component count (62 → 7 net-new deliverables + 3 YAML lines)
is the project's chosen scope for v0.7.0. **Cited V-Model IDs**:
all 27 MOD-NNN, all 21 ARCH-NNN, all 15 SYS-NNN.

**Alternatives considered**:
- *Single combined `commands/v-model.md`* — rejected: spec-kit
  core's slash-command convention is one file per command
  (`commands/requirements.md`, `commands/acceptance.md`, etc.).
- *Single combined verification script* — rejected: each shell
  script exposes a distinct CLI contract (ARCH-007, ARCH-009,
  ARCH-010, ARCH-013) and is unit-tested independently
  (UTP-010-A, UTP-013-A, UTP-014-A, UTP-017-A, UTP-018-A).

---

## D-003 — Pre-Implementation Gate: thin shell coordinator that delegates to existing scripts

**Decision**: Implement `scripts/bash/run-v-model-gate.sh` as a
~30-line wrapper that invokes — in this order —
`scripts/bash/build-matrix.sh`,
`scripts/bash/validate-requirement-coverage.sh`,
`scripts/bash/validate-system-coverage.sh`,
`scripts/bash/validate-architecture-coverage.sh`,
`scripts/bash/validate-module-coverage.sh`, and
`scripts/bash/validate-hazard-coverage.sh`. Aggregate exit codes;
print each inner stdout verbatim; emit final line `GATE: PASS` or
`GATE: FAIL`. Exit non-zero on any inner non-zero. Introduce zero
new gating logic.

**Rationale**: (a) REQ-017 mandates reuse of existing
deterministic scripts and explicitly forbids a new wrapper script
beyond this thin coordinator. (b) REQ-CN-002 forbids inventing
new gate logic. (c) The constraint is exercised by ATP-017-A /
SCN-017-A1 — process-trace assertion that exactly the six
existing scripts and no others are invoked. (d) The contract is
fixed by ARCH-007 (CLI invocation, exit-code semantics, stdout
schema). (e) HAZ-009 (false-negative gate) and HAZ-010
(false-positive gate) are mitigated entirely by reusing
already-validated scripts. **Cited V-Model IDs: REQ-016, REQ-017,
REQ-NF-004, REQ-CN-002; SYS-004; ARCH-007; MOD-010; HAZ-009,
HAZ-010; ATP-017-A; SCN-017-A1; UTP-010-A**.

**Alternatives considered**:
- *Re-implement coverage logic in the wrapper* — rejected:
  duplicates already-tested code and violates REQ-CN-002.
- *Parallelise the inner scripts* — rejected: introduces new
  concurrency surface that REQ-CN-003 declines for v0.7.0
  (SYS-015).

---

## D-004 — Hallucination Guard: deterministic grep+awk, no LLM in the loop

**Decision**: Implement `scripts/bash/validate-implements-ids.sh`
(~80 lines) that (a) extracts the canonical V-Model ID set with
`grep -hoE '(REQ|SYS|ARCH|MOD|HAZ|ATP|ITP|UTP)-[A-Z0-9-]+'
specs/<feature>/v-model/*.md | sort -u`, (b) scans every generated
source file for `Implements <ID>` (and language-equivalent)
comments, (c) prints any unrecognised ID as `<file>:<line>:
unknown id <id>`, and (d) exits 1 if any unknown IDs are found
(emitting `GUARD: FAIL`) or 0 otherwise (emitting `GUARD: PASS`).
The script is invoked by `commands/implement.md` after generation
and BEFORE any `git commit`. No LLM call is involved.

**Rationale**: (a) REQ-023 + REQ-NF-002 + SC-002 require zero
hallucinated IDs in any generated artifact. (b) Constitution
Principle II forbids AI self-assessment for verification — the
guard MUST be deterministic. (c) The contract is fixed by ARCH-009
(CLI invocation, stdout schema, exit-code semantics). (d) HAZ-007
(value failure: hallucinated `// Implements <ID>` comment),
HAZ-012 (false-negative: guard misses an invalid ID), and HAZ-023
(scanner runs on stale snapshot — mitigated by invoking after
generation, before commit) are all addressed by this design.
(e) The algorithm spec is in `system-design.md §SYS-006 Algorithm
Specification`. **Cited V-Model IDs: REQ-023, REQ-NF-002; SC-002;
SYS-006; ARCH-009; MOD-013, MOD-025; HAZ-007, HAZ-012, HAZ-023;
ATP-019-A; SCN-019-A1; UTP-013-A**.

**Alternatives considered**:
- *LLM-based ID validation* — rejected: violates Principle II and
  falsifies the SC-002 evidence chain.
- *Embed ID extraction in spec-kit core* — rejected: violates
  REQ-CN-001 (MUST NOT modify spec-kit core).

---

## D-005 — Source Region Splicer: awk markers + caller-side atomic write

**Decision**: Implement `scripts/bash/splice-managed-regions.sh`
(~85 lines) that takes `<target-file> <generated-content-file>
<language>`. Uses `awk` to locate `<!-- BEGIN MANAGED id="…" -->` /
`<!-- END MANAGED id="…" -->` sentinel pairs (or
language-equivalent comment markers — `# BEGIN MANAGED id="…" #`,
`// BEGIN MANAGED id="…" //`, etc. per ARCH-010 contract).
Replaces only the interior content; preserves everything outside.
On overlapping or unbalanced sentinels, exits 1 with a diff report
on stderr (no stdout, no mutation). Successful spliced content is
emitted to stdout; the **caller** is responsible for the
`mktemp`+`mv` atomic rename (the same 3-line idiom that is the
v0.7.0 concurrency safeguard for SYS-015).

**Rationale**: (a) REQ-022 + REQ-NF-005 require user-authored
content outside V-Model regions to be preserved across re-runs.
(b) HAZ-014 (region-marker corruption) is the highest-severity
risk in this area; the splicer's fail-closed behaviour on
overlapping markers (no mutation, diff on stderr) is the in-force
mitigation. (c) The atomic-write boundary is intentionally pushed
to the caller so that the splicer can be unit-tested in isolation
(UTP-014-A) and so that the `mktemp`+`mv` idiom (the only SYS-015
safeguard delivered in v0.7.0) is visible at the call sites.
(d) The contract is fixed by ARCH-010. **Cited V-Model IDs:
REQ-022, REQ-NF-005; SYS-007, SYS-015; ARCH-010; MOD-014; HAZ-014,
HAZ-025; UTP-014-A**.

**Alternatives considered**:
- *Splicer performs its own atomic write* — rejected: hides the
  SYS-015 safeguard from call-site review and makes the splicer
  harder to unit-test (would require a writable target on every
  run).
- *Use `sed -i` instead of `awk`* — rejected: `sed -i` is
  non-portable across BSD/GNU and cannot atomically swap files.

---

## D-006 — Test ordering: TDD-first; tests for the four shell scripts written before any script body

**Decision**: For every new deliverable in D-002, write the test
cases first (BATS for shell, Pester for PowerShell, structural-eval
for prompt sections), confirm they fail, then write the
implementation. Order across deliverables: (i) BATS tests for the
four shell scripts (UTP-010-A, UTP-013-A, UTP-014-A, UTP-017-A, UTP-018-A,
UTP-025-A); (ii) shell script bodies; (iii) prompt-section
structural-eval cases for the three command files; (iv) prompt
section bodies; (v) integration-test ITP set; (vi) acceptance ATP
set against the running command-line.

**Rationale**: (a) Constitution Principle I §V-Model Discipline
requires tests-before-code: "tests are written and approved
before implementation begins, and MUST fail before the
corresponding feature code is written". (b) REQ-011 + ATP-011-A
require the *generated* `tasks.md` to honour TDD ordering, which
in turn requires the bridge commands themselves to be developed
under TDD (consistency rule). (c) The pre-implementation gate
(SYS-004) refuses to run when the V-Model trace matrix is
incomplete, so the implementation phase cannot start until tests
exist (REQ-016, REQ-NF-004; HAZ-009). **Cited V-Model IDs: REQ-011,
REQ-016, REQ-NF-001, REQ-NF-004; SYS-004; SC-008; UTP-010-A, UTP-013-A,
UTP-014-A, UTP-017-A, UTP-018-A, UTP-025-A; ATP-011-A**.

**Alternatives considered**:
- *Implementation-first, tests added in PR* — rejected: violates
  Principle I and SC-008.

---

## D-007 — Hook wiring: 3 declarative YAML entries; spec-kit core's CommandRegistrar does the work

**Decision**: Append to `extension.yml`:

```yaml
hooks:
  after_specify:
    command: speckit.v-model.requirements
  before_implement:
    command: speckit.v-model.trace
  after_implement:
    command: speckit.v-model.trace
```

Preserve the existing `after_tasks: speckit.v-model.trace` entry
and any `optional` / `prompt` / `description` fields that the
project already uses on hook entries. No new Python or shell
registration code is added; spec-kit core's `CommandRegistrar` in
`src/specify_cli/extensions.py` reads `extension.yml` at install
time and wires the hooks.

**Rationale**: (a) FR-028 (in `spec.md`) mandates exactly these
three hook entries. (b) REQ-IF-003 (split form) and REQ-IF-005
require `before_implement` / `after_implement` → `v-model.trace`
and `after_specify` → `v-model.requirements` respectively.
(c) REQ-NF-006 forbids any change to the hook *infrastructure* —
only the registered hooks themselves are in scope. (d) HAZ-019
(hook not registered) is mitigated by spec-kit core's
installation-time error if YAML is malformed. (e) ARCH-015 /
MOD-020 fix the contract as REUSE-CORE. **Cited V-Model IDs:
REQ-IF-003, REQ-IF-005, REQ-NF-006; SYS-011; ARCH-015; MOD-020;
HAZ-019**.

**Alternatives considered**:
- *Programmatic hook registration via Python* — rejected: spec-kit
  core already does this declaratively; duplication would violate
  REQ-CN-001.

---

## D-008 — Hallucination-guard invariant for plan generation (this very PR)

**Decision**: Before committing this `/speckit.plan` output (Step
A.1), extract the canonical ID set from the V-Model artifacts via
`grep -hoE 'REQ-(NF|IF|CN)-[0-9]{3}|(REQ|SYS|ARCH|MOD|HAZ)-[0-9]{3}'
specs/007-bridge-commands/v-model/*.md | sort -u` (extended with
the test-plan ID regexes per the work order), then grep every
generated output (`plan.md`, `research.md`, `data-model.md`,
`quickstart.md`, `contracts/*.md`) for ID-shaped tokens, and
diff. The diff MUST be empty before commit. D-NNN, SYS-013
(deprecated stub legitimately referenced), and SYS-015 (active)
are exempt by work-order rule.

**Rationale**: This is the dogfood of the very invariant the
implement command will enforce on generated source code (REQ-023,
REQ-NF-002, ARCH-009). Applying it to this PR's outputs catches
any hallucinated identifier introduced during plan synthesis
before the human reviewer sees it. **Cited V-Model IDs: REQ-023,
REQ-NF-002; SC-002; SYS-006; ARCH-009; MOD-013, MOD-025**.

**Alternatives considered**:
- *Trust the LLM to cite only real IDs* — rejected: violates
  Principle II and the entire SC-002 evidence chain.

---

## D-009 — PowerShell parity: shell-script-by-shell-script mirrors

**Decision**: Each new Bash script under `scripts/bash/` is
mirrored by a behaviourally-identical PowerShell 7+ script under
`scripts/powershell/`. The same CLI contract (positional args,
exit codes, stdout schema) holds; the same Pester unit tests
mirror the BATS tests. This follows the project's existing
convention (every existing `scripts/bash/*.sh` has a
`scripts/powershell/*.ps1` mirror).

**Rationale**: (a) The constitution lists Pester as a required
testing tool alongside BATS (constitution §Testing Stack);
(b) the existing 13 commands all have shell + PowerShell pairs;
(c) the contracts in `architecture-design.md` §Interface View are
expressed as `bash <script>` invocations but the project's
multi-platform support requires PowerShell parity per house style.
**Cited V-Model IDs: REQ-NF-001 (four-stack coverage including
Pester); SC-008; ARCH-007, ARCH-009, ARCH-010, ARCH-013**.

**Alternatives considered**:
- *Bash-only* — rejected: violates the project's existing
  cross-platform convention and the constitution's named Pester
  testing requirement.

---

## D-010 — LLM eval and structural validator strategy for prompt-section modules

**Decision**: For the 17 `NEW-PROMPT-SECTION` modules (MOD-001,
MOD-002, MOD-003, MOD-004, MOD-005, MOD-006, MOD-007, MOD-008,
MOD-009, MOD-011, MOD-012, MOD-015, MOD-016, MOD-019, MOD-021,
MOD-022, MOD-023), unit testing is performed under `tests/evals/`
using **pytest + DeepEval** with **Google `gemini-2.5-flash`** as
the LLM tier. Two test families are used: (a) *structural eval*
— a deterministic check that the LLM's output contains the
expected sub-sections in the expected order (re-uses the same
grep pattern shape as `validate-core-schema.sh`); (b)
*LLM-as-judge eval* — DeepEval GEval metrics scored against
golden examples for traceability-comment placement, hazard-task
priority, structured-summary completeness. The validator script
`scripts/bash/validate-core-schema.sh` (D-002, ARCH-013, MOD-017,
MOD-018) provides the deterministic schema-conformance check
that the prompts must satisfy on every run.

**Rationale**: (a) Constitution §Testing Stack pins exactly this
toolchain. (b) Constitution Principle II requires that *coverage
calculations and structural validations* be deterministic; the
schema validator covers that requirement, while DeepEval handles
the semantic-quality dimension. (c) The structural-eval ID-check
provides the SC-002 evidence chain. (d) Idempotency
(REQ-NF-005, ≥95% structural identity) is measured by re-running
the prompt and computing structural-identity via the same tooling.
**Cited V-Model IDs: REQ-NF-001, REQ-NF-002, REQ-NF-005; SC-002,
SC-007, SC-008; SYS-005, SYS-010; ARCH-008, ARCH-013, ARCH-016;
MOD-011, MOD-012, MOD-021; UTP-001-A, UTP-011-A, UTP-021-A**.

**Alternatives considered**:
- *Manual prompt review only* — rejected: violates Principle II.
- *Gemini Pro tier* — out of scope; the constitution pins
  `gemini-2.5-flash`.

---

## D-011 — Hazard-driven enrichment in `commands/tasks.md`

**Decision**: `commands/tasks.md` includes a `§Hazard Enrichment`
prompt section that activates when `hazard-analysis.md` is
present in the feature directory. The section instructs the LLM
to (a) raise the priority of mitigation tasks, (b) emit one
dedicated verification task per `HAZ-NNN` that explicitly
references the HAZ identifier, and (c) abort fail-closed if
`hazard-analysis.md` is malformed.

**Rationale**: (a) REQ-014 fixes the requirement and ATP-014-A /
ATP-014-B fix the test cases; SCN-014-A1 and SCN-014-B1 fix the
BDD scenarios. (b) HAZ-016 (hazard-driven tasks not emitted) is
the in-force risk and is the reason fail-closed behaviour on a
malformed hazard file is mandatory. (c) The contract is fixed by
ARCH-012 / MOD-016. **Cited V-Model IDs: REQ-014; SYS-009;
ARCH-012; MOD-016; HAZ-016; ATP-014-A, ATP-014-B; SCN-014-A1,
SCN-014-B1**.

**Alternatives considered**:
- *Treat hazards as plain tasks* — rejected: loses the
  catastrophic-severity prioritisation that REQ-014 mandates.

---

## D-012 — Trace-matrix regen invariant: `--output` rather than redirected stdout

**Decision**: When the implement command (or any author of this
PR) regenerates the V-Model trace matrix, invoke
`scripts/bash/build-matrix.sh` with the `--output <file>` flag
rather than `bash build-matrix.sh > <file>`. The latter loses
exit-code propagation (a non-zero matrix-build error becomes a
truncated output file with exit code 0 from the shell pipeline);
the former preserves both exit code and content.

**Rationale**: (a) The lesson is captured in
`drift-diff-plan.md §Cascading Impact on Other Artifacts` (the
matrix regeneration during the rework hit this very pitfall) and
is the reason the matrix was regenerated cleanly under
`8a2dc5d`. (b) REQ-NF-004 mandates 100% refusal on incomplete
matrix; a silently-truncated matrix would defeat the gate
(HAZ-009 false-negative). (c) ARCH-007's stdout-schema contract
("final line `GATE: PASS` or `GATE: FAIL`") is built on the
assumption that exit codes and stdout are both intact. **Cited
V-Model IDs: REQ-NF-004; SYS-004; ARCH-007; MOD-010; HAZ-009**.

**Alternatives considered**:
- *Pipe through `tee`* — partial fix; still loses exit code.
- *Wrap in `set -o pipefail`* — fragile: requires every script
  invoking the matrix to opt in.

---

## D-013 — Post-rework deviation: SYS-013 retained as deprecated stub; SYS-015 added for Concurrent Write Safety

**Decision**: SYS-013 ("Quality & Process Compliance Harness") is
retained in `system-design.md` §Decomposition View as
"`[DEPRECATED] Quality & Process Compliance Harness`" (a stub
preserved for ID stability per project rules). The functional
intent is recharacterised as `commands/implement.md` §Quality
Compliance prompt section under ARCH-017 / MOD-022 (parent
SYS-003). A *new* SYS-015 ("Concurrent Write Safety") row was
added for the same Concurrent-Write-Safety scope; ARCH-010 lists
SYS-015 as a parent; STP-015-A inspection test case satisfies
SYS-015 → STP coverage.

**Rationale**: The original work order asked to deprecate SYS-013
and rename "Concurrent Write Safety" to **SYS-014**, but two
blockers (SYS-014 already taken by Commit Annotator; the
validators do not honour `[DEPRECATED]` on SYS rows) made the
literal rename impossible without breaking forward coverage.
Resolution per `drift-diff-plan.md §Addendum item 1` preserves
both the audit trail and the validator invariants. The
plan-template.md Constitution Check requires this deviation to be
surfaced; D-013 records it. **Cited V-Model IDs: SYS-013, SYS-015;
ARCH-010, ARCH-017; MOD-022; HAZ-021; STP-015-A**.

**Alternatives considered**:
- *Force-rename to SYS-014* — rejected: collides with existing
  Commit Annotator.
- *Drop SYS-013 entirely* — rejected: breaks forward coverage
  in `validate-system-coverage.sh` until validators learn the
  `[DEPRECATED]` marker.

---

## D-014 — Post-rework deviation: ARCH-017 / MOD-022 reactivated as `NEW-PROMPT-SECTION`

**Decision**: ARCH-017 (Quality Compliance Harness) and MOD-022
(Quality Compliance Harness module) are reactivated as
`NEW-PROMPT-SECTION` realised by `commands/implement.md`
§Quality Compliance. The parent list for ARCH-017 includes both
the active SYS-003 and the deprecated SYS-013 to preserve
traceability of the recharacterised functional intent.

**Rationale**: Per `drift-diff-plan.md §Addendum item 2`. The
prompt section instructs the LLM to invoke the existing
four-stack harnesses (BATS, Pester, structural eval, LLM eval),
gate merge on 100% coverage, and run scope-guardrail and
dogfood-discipline audits. This satisfies HAZ-021 (coverage gate
not enforced) without a Python module. **Cited V-Model IDs:
SYS-003, SYS-013; ARCH-017; MOD-022; HAZ-021; REQ-NF-001,
REQ-CN-003, REQ-CN-004**.

**Alternatives considered**:
- *Leave ARCH-017 / MOD-022 as DROP* — rejected: would leave
  HAZ-021 without an in-force mitigation.

---

## D-015 — Sentinel preservation across edits: `<!-- BEGIN MANAGED id="…" -->` / `<!-- END MANAGED id="…" -->`

**Decision**: V-Model-managed regions inside generated source
files are demarcated with `<!-- BEGIN MANAGED id="<MOD-NNN>" -->`
and `<!-- END MANAGED id="<MOD-NNN>" -->` (or
language-appropriate comment syntax — `# BEGIN MANAGED id="…" #`,
`// BEGIN MANAGED id="…" //`, etc.). On every re-run, the
Source Region Splicer (D-005) replaces only the interior content;
sentinels themselves are never rewritten unless the splicer
detects an unbalanced or overlapping pair (in which case it exits
1 and leaves the file untouched).

**Rationale**: (a) REQ-022 + HAZ-014 require sentinel preservation
to avoid silent loss of user code. (b) ATP-018-A / SCN-018-A1
verify that the comment lands at the declared path. (c) The
sentinel choice (`MANAGED id="<MOD-NNN>"`) ties the region
directly to the V-Model ID it implements, which feeds the
Hallucination Guard (D-004; ARCH-009). **Cited V-Model IDs:
REQ-022; SYS-007; ARCH-010; MOD-014; HAZ-014; ATP-018-A;
SCN-018-A1; UTP-014-A**.

**Alternatives considered**:
- *Hash-based region detection* — rejected: opaque to humans
  reading the source; sentinels are self-documenting.
- *Per-language native annotations* (e.g., `@implements` in
  JavaDoc) — rejected: not uniformly available across the
  generated-language set.

---

## D-016 — Atomic-commit policy for region-preserving re-runs

**Decision**: For every file that the implement command rewrites,
use the inline 3-line idiom

```bash
tmp=$(mktemp -p "$(dirname "$f")")
printf '%s' "$content" > "$tmp"
mv "$tmp" "$f"
```

— the `mktemp` lives in the same directory as the target so the
final `mv` is a same-filesystem rename (atomic on POSIX). This
idiom is used directly inside the four new shell scripts (where
needed) AND at every call site that writes a file produced by
`splice-managed-regions.sh`. The idiom is the SOLE concurrency
safeguard delivered for SYS-015 in v0.7.0 (process-wide locking
is deferred).

**Rationale**: (a) REQ-CN-003 + REQ-CN-004 + SYS-015 §Risk Note
declare concurrent same-feature-directory invocations out of scope
for v0.7.0. (b) HAZ-014 (region-marker corruption) and HAZ-025
(structured summary truncated) are mitigated by atomic semantics
on the file-write side (HAZ-025 also requires the §Structured
Summary section to flush on every exit path). (c) The idiom is
trivially small (drift-diff-plan.md notes "ARCH-021 dropped — this
is a 3-line pattern, not a module"), so MOD-027 carries no
functional contract. **Cited V-Model IDs: REQ-CN-003, REQ-CN-004;
SYS-007, SYS-015; ARCH-010; MOD-014; HAZ-014, HAZ-025**.

**Alternatives considered**:
- *`flock`-based advisory locking* — explicitly deferred per
  SYS-015 §Risk Note.
- *Direct in-place write* — rejected: would violate atomic
  semantics and re-open HAZ-014.

---

## Decision summary table

| D-ID | Title | Primary V-Model citations |
|------|-------|---------------------------|
| D-001 | Markdown+shell+YAML paradigm; 0 new Python | SYS-001, SYS-002, SYS-003, ARCH-001, ARCH-002, ARCH-003, ARCH-004, MOD-001, MOD-003, MOD-005 |
| D-002 | Deliverable inventory | All 27 MOD, 21 ARCH, 15 SYS |
| D-003 | Pre-Implementation Gate = thin coordinator | REQ-016, REQ-017, REQ-NF-004, REQ-CN-002, SYS-004, ARCH-007, MOD-010, HAZ-009, HAZ-010, ATP-017-A, SCN-017-A1, UTP-010-A |
| D-004 | Hallucination Guard = grep+awk | REQ-023, REQ-NF-002, SYS-006, ARCH-009, MOD-013, MOD-025, HAZ-007, HAZ-012, HAZ-023, ATP-019-A, SCN-019-A1, UTP-013-A |
| D-005 | Source Region Splicer = awk + caller-side atomic write | REQ-022, REQ-NF-005, SYS-007, SYS-015, ARCH-010, MOD-014, HAZ-014, HAZ-025, UTP-014-A |
| D-006 | TDD-first test ordering | REQ-011, REQ-016, REQ-NF-001, REQ-NF-004, SYS-004, UTP-010-A, UTP-013-A, UTP-014-A, UTP-017-A, UTP-018-A, UTP-025-A, ATP-011-A |
| D-007 | Hook wiring = 3 declarative YAML entries | REQ-IF-003, REQ-IF-005, REQ-NF-006, SYS-011, ARCH-015, MOD-020, HAZ-019 |
| D-008 | Hallucination guard for the plan generation itself | REQ-023, REQ-NF-002, SYS-006, ARCH-009, MOD-013, MOD-025 |
| D-009 | PowerShell parity | REQ-NF-001, ARCH-007, ARCH-009, ARCH-010, ARCH-013 |
| D-010 | LLM eval + structural validator strategy | REQ-NF-001, REQ-NF-002, REQ-NF-005, SYS-005, SYS-010, ARCH-008, ARCH-013, ARCH-016, MOD-011, MOD-012, MOD-021, UTP-001-A, UTP-011-A, UTP-021-A |
| D-011 | Hazard-driven enrichment | REQ-014, SYS-009, ARCH-012, MOD-016, HAZ-016, ATP-014-A, ATP-014-B, SCN-014-A1, SCN-014-B1 |
| D-012 | Trace-matrix regen `--output` invariant | REQ-NF-004, SYS-004, ARCH-007, MOD-010, HAZ-009 |
| D-013 | SYS-013 deprecation deferred; SYS-015 added | SYS-013, SYS-015, ARCH-010, ARCH-017, MOD-022, HAZ-021, STP-015-A |
| D-014 | ARCH-017 / MOD-022 reactivated as prompt section | SYS-003, SYS-013, ARCH-017, MOD-022, HAZ-021, REQ-NF-001, REQ-CN-003, REQ-CN-004 |
| D-015 | Sentinel preservation grammar | REQ-022, SYS-007, ARCH-010, MOD-014, HAZ-014, ATP-018-A, SCN-018-A1, UTP-014-A |
| D-016 | Atomic-commit policy for re-runs | REQ-CN-003, REQ-CN-004, SYS-007, SYS-015, ARCH-010, MOD-014, HAZ-014, HAZ-025 |

**Total decisions**: 16 (target was 10–18). All
`NEEDS CLARIFICATION` markers in the Technical Context section of
`plan.md`: **0**.
