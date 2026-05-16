# AGENTS.md — spec-kit-v-model

> **Audience.** This file is for AI coding agents — Claude Code, GitHub
> Copilot, Cursor, Windsurf, or any other — working **on the
> `spec-kit-v-model` project itself**. It guides the maintainer and
> contributors who evolve the V-Model Extension Pack.
>
> **Not for end users of the extension.** Teams *using* `spec-kit-v-model`
> on their own safety-critical project will have their own `AGENTS.md`
> (or `CLAUDE.md`) and their own `.specify/memory/constitution.md` in
> *their* repository, governing *their* project. This file governs ours.
>
> **Aspirational where today's code disagrees.** This file describes the
> simplified end-state the project is converging on. Where the current
> repository diverges, treat the divergence as debt to pay down — not as
> a pattern to extend.
>
> Authoritative companion: [`.specify/memory/constitution.md`](.specify/memory/constitution.md).
> When this file and the constitution disagree, the constitution wins.

---

## 1. What this is

`spec-kit-v-model` is an **extension** to [GitHub Spec Kit](https://github.com/github/spec-kit).
It adds the V-Model — the verification-and-validation discipline used in
safety-critical industries (IEC 62304 / FDA 21 CFR Part 820 for medical
devices, ISO 26262 for automotive, DO-178C for aerospace, IEEE 29148 for
requirements engineering) — to Spec-Driven Development at AI speed.

The thesis: **every development artifact has a simultaneously generated,
paired testing artifact, with deterministic bidirectional traceability,
enforced at AI velocity without sacrificing the audit evidence regulators
demand.**

This is not a documentation generator. It is a discipline enforcer.

See [`docs/product-vision.md`](docs/product-vision.md) for the full vision,
including industry-specific value propositions and the architectural
philosophy of trust through separation of concerns.

---

## 2. The mantra

> **The AI drafts. The human decides. The scripts verify. Git remembers.**

Every rule in this file is a corollary of that sentence. When in doubt
about what an agent is allowed to do, ask which of the four roles you are
performing — and whether the role you are about to perform is actually
yours.

---

## 3. Trust separation — what each actor is for

A compliance tool that uses AI for everything cannot be trusted for
compliance. Roles in this repo are **strictly separated** and agents
MUST stay inside their lane.

| Responsibility | Handled by | Why |
|---|---|---|
| Creative translation (spec → structured `REQ-NNN`, `ATP-NNN-X`, etc.) | **AI**, with human review | Requires natural-language interpretation and domain context |
| Coverage calculation, traceability matrix, gap detection | **Deterministic scripts** (Bash / PowerShell / Python; regex-based) | Must be mathematically correct and reproducible across runs |
| Substance verification (test plans actually test, designs actually specify) | **Substance validators** (deterministic scripts) | Schema is necessary but never sufficient — see §6 |
| Quality assessment (are the generated artifacts good?) | **LLM-as-judge** (DeepEval + Gemini), clearly labeled as advisory | Qualitative judgment where human-like reasoning adds value |
| Final approval | **Human**, via Pull Request review | The systems engineer is the responsible party; AI is the exoskeleton |
| Audit trail | **Git** (cryptographic commit hashes) | Immutable, mathematically verifiable history |

**Non-negotiable rules for agents:**

- An agent MUST NOT compute coverage, build a traceability matrix, or
  evaluate gap closure. Those are deterministic-script jobs.
- An agent MUST NOT self-assess the correctness of its own output. The
  scripts judge; the human approves.
- An agent MUST NOT modify a compliance-critical artifact silently — every
  change is a Git commit with a descriptive message authored or co-authored
  by a human.
- When a specification is ambiguous, the agent MUST insert
  `[NEEDS CLARIFICATION: <reason>]` and stop generating dependent
  artifacts. Guessing intent is prohibited.

---

## 4. The 8 V-Model artifacts are the single source of truth

Four levels of the V, paired. Each row is a dev-side artifact and its
sibling test-side artifact. **These eight files are the canonical
specification.** Everything else — `plan.md`, `tasks.md`, `data-model.md`,
`quickstart.md`, `research.md`, `contracts/`, generated source, generated
tests — is a **projection** of these eight.

| Level | Dev-side (left of V) | Test-side (right of V) |
|---|---|---|
| L1 — Acceptance | Requirements Specification (`REQ-NNN`) | Acceptance Test Plan (`ATP-NNN-X` → `SCN-NNN-X#`) |
| L2 — System | System Design (`SYS-NNN`) | System Test Plan (`STP-NNN-X` → `STS-NNN-X#`) |
| L3 — Architecture | Architecture Design (`ARCH-NNN`) | Integration Test Plan (`ITP-NNN-X` → `ITS-NNN-X#`) |
| L4 — Module | Module Design (`MOD-NNN`) | Unit Test Plan (`UTP-NNN-X` → `UTS-NNN-X#`) |

**Auxiliary artifacts** (not part of the eight, but governed by the same
rules): Hazard Analysis (`HAZ-NNN`), Peer Review Findings (`PRF-{ARTIFACT}-NNN`),
Waivers (`WAV-NNN`), the Bidirectional Traceability Matrix, the Release
Audit Report.

**Sibling files are editable projections.** A human may edit `data-model.md`,
`quickstart.md`, `research.md`, or files under `contracts/`. Those edits
MUST be propagated back to their V-Model source via HTML-comment anchors.
A sibling file that diverges from its V-Model source is a defect — bridges
MUST refuse to run until the divergence is resolved.

**Direction of authority is one-way.** V-Model artifacts authorize sibling
files; sibling files never authorize V-Model artifacts.

---

## 5. Bridge command discipline

The three **bridge commands** — `speckit.v-model.plan`,
`speckit.v-model.tasks`, `speckit.v-model.implement` — translate the
V-Model artifact set into Spec-Kit-canonical outputs. They are the place
where the V-Model meets generated code, and they are the place where
v0.7.0 went wrong: bridges produced structurally valid outputs that
lacked verification substance — passing schema checks while leaving
compliance-critical content empty or trivial.

The locked-in discipline (codified in
[constitution §Bridge Command Discipline](.specify/memory/constitution.md)):

1. **Strict mode only.** All 8 V-Model artifacts must exist and be
   `[Approved]` before any bridge runs. No permissive mode. No hybrid
   fallback.
2. **Bridges translate, never invent.** When translation is not possible,
   bridges refuse and surface `[NEEDS CLARIFICATION]` on the upstream
   V-Model artifact.
3. **Substance over shape.** Substance validators
   (`validate-test-plan-implementation.sh`,
   `validate-module-implementation-depth.sh`) run as pre-flight and
   fail closed.
4. **Bridges never write to V-Model artifacts.** Read-only access. Any
   needed change is routed back through the relevant
   `speckit.v-model.<level>` command.
5. **Report Completion is versioned JSON persisted to `.runs/`.**

An agent invoking a bridge command MUST honor these rules. An agent
implementing a bridge command MUST encode these rules as fail-closed
gates, not advisory warnings.

---

## 6. Substance over shape

Schema validation answers *"does the file have the right sections?"*
Substance validation answers *"do those sections contain anything that
verifies the requirement?"*

v0.7.0 exposed this failure mode in practice: bridges produced
structurally perfect artifacts with empty substance — test plans that
named test methods but defined no scenarios, module designs that listed
functions but specified no behavior. Schema-only validation let this
through.

**An agent producing or modifying any V-Model artifact MUST treat
substance failures as equivalent to schema failures.** Examples of
substance failures that MUST be caught:

- A test case with no Given / When / Then BDD scenarios.
- A module design where a function block specifies no preconditions,
  postconditions, or invariants.
- An architecture module listed as `[Implements REQ-NNN]` where the
  module's behavior does not address the requirement's verifiable claim.

If substance validators do not yet exist for a given level, an agent
MUST flag this in its Report Completion and not silently approve.

---

## 7. ID schema and lifecycle

The authoritative table lives in
[constitution §ID Schema and Artifact Naming](.specify/memory/constitution.md).
Summary for agents:

- **Identifier prefixes** are listed in `extension.yml` under `defaults.id_prefixes`.
  That file is the single source of truth for prefix strings.
- **Never renumber.** Stable IDs are a record-keeping requirement. When
  an artifact is removed or superseded, mark it `[DEPRECATED]` — do not
  reclaim its ID.
- **Lifecycle markers** are: `[Approved]`, `[DEPRECATED]`, `[SUSPECT]`.
  An artifact missing a status marker is treated as unapproved.
- **Category tags** for requirements: `[FN]` (functional), `[NF]`
  (non-functional), `[IF]` (interface), `[CN]` (constraint).
- **Scope markers**: `[EXTERNAL]` (out of scope for unit coverage),
  `[CROSS-CUTTING]` (tested at a higher level). Definitions live in
  one authoritative source; synonym drift is a documentation defect.

---

## 8. Repository map — canonical sources

Each top-level directory has **one declared purpose**. When an agent is
deciding where a new file belongs, the purpose below is the test.

| Directory | Purpose | Canonical? |
|---|---|---|
| `commands/` | **Canonical source** for command prompts (bare names: `requirements.md`, `plan.md`, etc.). | ✅ Yes |
| `commands/overlays/<domain>/` | Domain-specific deltas only (ISO 26262, DO-178C, IEC 62304). Base prompts own shared behavior. | ✅ Yes |
| `templates/` | Output document templates (`requirements-template.md`, `acceptance-plan-template.md`, etc.). | ✅ Yes |
| `templates/overlays/<domain>/` | Domain-specific template deltas. | ✅ Yes (when populated) |
| `scripts/bash/`, `scripts/powershell/`, `scripts/python/` | Deterministic verification logic. Cross-platform pairs MUST be equivalent. | ✅ Yes |
| `tests/` | BATS, Pester, pytest, evals, fixtures. | ✅ Yes |
| `docs/` | User-facing documentation (vision, overview, config, standards, usage). | ✅ Yes |
| `specs/` | **Historical design history.** Read-only reference for understanding decisions. Not a current source of truth — see `docs/` for that. | History only |
| `.github/agents/` | **Generated** from `commands/*.md` for GitHub Copilot agent recognition. Do not edit manually. (Epic 3 of the roadmap will wire generation.) | ❌ Generated |
| `.specify/` | Vendored Spec Kit internals + the constitution at `.specify/memory/constitution.md`. | Vendored |
| `site/` | Generated docs site output (MkDocs). | ❌ Generated |
| `extension.yml`, `catalog-entry.json` | Extension metadata published to Spec Kit's registry. | ✅ Yes |
| `refactoring_plan/` | **Transient.** Present only while a stabilization cycle is active; holds that cycle's audit and roadmap. Removed when the cycle closes. Do not rely on its presence. | Transient |

**Rule for agents:** If a directory is marked "Generated," do not edit
files in it directly. Edit the canonical source and re-run the
generation step.

---

## 9. Command naming convention

- **End-user / extension contract:** commands are advertised as
  `speckit.v-model.<name>` (e.g., `speckit.v-model.requirements`,
  `speckit.v-model.plan`). This is the name a user types and the name
  in `extension.yml`. It is the **canonical contract**.
- **In-repo filenames:** `commands/<name>.md` (bare, no prefix). This
  matches upstream Spec Kit's convention (`templates/commands/*.md`).
  The bare filename is an internal detail.
- **Generated GitHub-agent filenames:** `.github/agents/speckit.v-model.<name>.md`.
  These are generated from the canonical `commands/<name>.md`.

When introducing a new command, an agent MUST:
1. Add the canonical prompt as `commands/<name>.md`.
2. Add the entry to `extension.yml` under `provides.commands` with the
   `speckit.v-model.<name>` identifier.
3. Add the corresponding template under `templates/<name>-template.md`
   if the command produces a new artifact type.
4. NOT manually create the `.github/agents/speckit.v-model.<name>.md`
   sibling — that comes from generation.

---

## 10. Working conventions an agent must follow

**Bash scripts:**
- Start every script with `set -euo pipefail`.
- Validate option arguments before consuming them
  (e.g., check `$2` exists before `shift 2`).
- Machine-readable output goes to **stdout**; warnings and errors go to
  **stderr**. Exit codes are part of the script's contract.

**PowerShell scripts:**
- Use `[CmdletBinding()]` and `$ErrorActionPreference = 'Stop'`.
- Declare parameters with explicit validation attributes
  (`[Parameter(Mandatory=$true)]`, `[ValidateSet(...)]`).
- No silent `catch { }` blocks — every catch documents its fallback.

**Bash / PowerShell parity:**
- Scripts in `scripts/bash/<name>.sh` and `scripts/powershell/<Name>.ps1`
  with the same logical name MUST produce **equivalent output for the
  same inputs**. Equivalence is enforced by parity tests (see
  `tests/validators/parity_validator.py`).

**Markdown artifacts:**
- All compliance-critical artifacts are plaintext Markdown stored in
  Git. No binary formats, no external SaaS, no proprietary databases.
- Every artifact references its source by ID
  (e.g., `[Implements REQ-001]` in code, `[Verifies ATP-001-A]` in
  scenarios).

**Commits:**
- Every artifact change is a Git commit with a descriptive message.
- Commits may include `Co-Authored-By:` for AI-assisted changes.
- The default branch is protected: PRs only, at least one human reviewer
  for compliance-critical artifacts, CI green.

**Source code (when bridges generate it):**
- Source files carry `// Implements REQ-NNN` / `# Implements REQ-NNN`
  (language-appropriate) tying every implementation back to its
  requirement.
- Tests carry `// Implements ATP-NNN-X` (or the equivalent level-3 /
  level-4 ID) tying every test back to its plan entry.

---

## 11. Cleanup is welcome; sprawl needs approval

The project periodically enters **stabilization cycles** to pay down
the kind of debt that accumulates when features ship faster than the
underlying contracts solidify (duplicated prompts, copy-synchronized
script pairs, fixture taxonomies, doc/config drift). Whether or not a
cycle is currently active, contributors and agents working on this
repository observe one durable rule:

> **A change that removes duplication, narrows a taxonomy, or aligns
> docs to reality is welcome at any time. A change that adds a new
> parallel surface (new prompt copy, new script duplicate, new fixture
> root, new term for an existing concept) needs explicit maintainer
> approval — and is rejected by default during an active stabilization
> cycle.**

Specifically, agents MUST NOT, without explicit human approval:

- Add new prompt duplications. If `commands/<name>.md` exists, do not
  also write `.github/agents/speckit.v-model.<name>.md` by hand —
  that file is generated.
- Add a Bash script with a PowerShell counterpart (or vice versa)
  without a parity test in the same change.
- Create a new fixture root. Place new fixtures under an existing
  root (`tests/fixtures/...`) following the conventions already in use.
- Invent a new term for an existing concept (Domain Overlay,
  `[EXTERNAL]`, `[CROSS-CUTTING]`, bridge mode, etc.). One name per
  concept; one canonical definition per name. If a definition is
  hard to find, ask the maintainer rather than coining a synonym.

**Active cycle, if any.** When a stabilization cycle is in flight, a
`refactoring_plan/` directory at the repository root holds its audit
and roadmap. Consult it for cycle-specific scope and priorities.
The directory is transient — its presence is not guaranteed and its
absence does not relax the rule above.

---

## 12. Common pitfalls

Drawn from the v0.7.0 audit. An agent that finds itself about to do one
of these things should stop and ask.

1. **Prompt duplication.** Editing one of the duplicate prompts and
   forgetting the other. The cleanup is one-canonical-source; do not
   make the duplication worse.
2. **AI computing verification.** Using the model to "check coverage,"
   "build a matrix," or "estimate test completeness." These are
   deterministic-script outputs by constitutional rule.
3. **Bridges inventing.** A bridge filling in details the V-Model
   artifact didn't specify. Bridges translate; bridges do not author.
4. **Schema-passes-substance-fails.** Generating an artifact that
   matches the template structure but contains no verifiable content
   — the substance-over-shape lesson from v0.7.0.
5. **Sibling-file divergence.** Editing `data-model.md` (or any
   projection file) without propagating the change back to its V-Model
   source.
6. **ID reuse.** Reclaiming a `REQ-NNN` after deprecating its prior
   holder. Never. Mark deprecated; allocate a new ID.
7. **Silent script failures.** `catch { }` in PowerShell or unguarded
   `$2` access in Bash. Every error path is documented or fails loudly.
8. **Docs drift from code.** Saying the config is Git-tracked when
   `.gitignore` ignores it. Reconcile in the same PR.
9. **Adding to the stabilization debt.** New domain overlays, new
   handoff loops, new prompt boilerplate — all need explicit approval
   during the stabilization cycle.

---

## 13. When in doubt

1. Re-read [`.specify/memory/constitution.md`](.specify/memory/constitution.md).
2. Re-read [`docs/product-vision.md`](docs/product-vision.md) for *why*.
3. If a `refactoring_plan/` directory exists, consult it for the
   currently active stabilization cycle's scope.
4. Ask the maintainer. Guessing is prohibited; clarifying is encouraged.

The mantra, one more time, because it is load-bearing:

> **The AI drafts. The human decides. The scripts verify. Git remembers.**

---

<!--
  ========================================================================
  AUTO-MANAGED FOOTER — do not edit by hand.
  The two sections below (`## Active Technologies` and `## Recent Changes`)
  are maintained automatically by:
    .specify/scripts/bash/update-agent-context.sh
    .specify/scripts/powershell/update-agent-context.ps1
  When a new feature plan is created, those scripts append the feature's
  language/framework to `## Active Technologies` and prepend a one-line
  changelog entry to `## Recent Changes` (rotating to the last 3 entries).
  Anything above this comment block is hand-curated and must be preserved.
  ========================================================================
-->

## Active Technologies

- Python 3.11 + Bash + PowerShell (deterministic verification stack: `pathlib`, `re`, `subprocess`, `yaml`; BATS, Pester, pytest + DeepEval) (007-bridge-commands)

## Recent Changes

- 007-bridge-commands: Strict-mode bridges (`plan` / `tasks` / `implement`) with substance validators and persisted Report Completion JSON.

