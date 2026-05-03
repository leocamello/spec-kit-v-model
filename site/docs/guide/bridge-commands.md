---
title: Bridge Commands — From V-Model Artifacts to Gated Implementation
description: How the v0.7.0 bridge commands (plan, tasks, implement) carry V-Model artifacts forward into deterministic, gated implementation — including the 8-stage gate, the splicer, the hallucination guard, and the compliant-vs-hybrid mode distinction.
---

# Bridge Commands

The **bridge commands** (introduced in v0.7.0) close the gap between V-Model artifacts and executable implementation. They wrap the corresponding `spec-kit-core` commands and add V-Model awareness, deterministic gates, sentinel-managed splicing, and a hallucination guard.

| Bridge command | Wraps | Adds |
|---|---|---|
| `/speckit.v-model.plan` | `/speckit.plan` | V-Model-enriched `plan.md` synthesis, pinned-schema validation, structured run summary |
| `/speckit.v-model.tasks` | `/speckit.tasks` | TDD-ordered task decomposition aware of all four test plans; per-task `Implements`-directive headers |
| `/speckit.v-model.implement` | `/speckit.implement` | Pre-flight `run-v-model-gate.sh`; four-level test generation; sentinel-managed splicing; `Implements`-directive hallucination guard; post-implement trace hook |

The bridge sequence is strict: **plan → tasks → implement**. Skipping straight from plan to implement bypasses the TDD-ordered task decomposition the rest of the system expects.

---

## End-to-End Workflow

```text
specs/<feature>/v-model/   ← produced by the 14 base/cross-cutting commands
        │
        ▼
/speckit.v-model.plan       ─►  specs/<feature>/plan.md   (5-H2 canonical schema, validated)
        │
        ▼
/speckit.v-model.tasks      ─►  specs/<feature>/tasks.md  (12-H2 schema, TDD-ordered, hazard-elevated)
        │
        ▼
/speckit.v-model.implement  ─►  src/**, tests/{unit,integration,system,acceptance}/**
        │                       + annotated commit
        │                       + structured run summary
        │                       + diff -u of every spliced file
        ▼
/speckit.v-model.trace      ─►  matrix refresh (invoked by the after_implement hook)
```

### `/speckit.v-model.plan`

- Reads every canonical V-Model artifact present under `specs/<feature>/v-model/` plus `v-model-config.yml` (for domain context).
- Synthesises `plan.md` with the five pinned H2 sections in fixed order: **Summary**, **Technical Context**, **Constitution Check**, **Project Structure**, **Complexity Tracking**.
- Adds V-Model enrichment as **HTML comments** so the upstream `spec-kit-core` schema is not altered — the plan still validates against `plan-schema-v0.7.0.json`.
- Validation: `validate-core-schema.sh --plan` runs three passes (existence → ordering → wedge rejection) and fails with a `diff -u` against the canonical heading sequence on any deviation.

### `/speckit.v-model.tasks`

- Reads `plan.md` plus `requirements.md`, `acceptance-plan.md`, `system-test.md`, `integration-test.md`, `unit-test.md`, and `hazard-analysis.md`.
- Produces `tasks.md` whose 12 H2s are preserved verbatim from `spec-kit-core`. Within those sections, tasks are emitted in **TDD order**: tests before implementation.
- Tasks tied to `HAZ-NNN` mitigations are **priority-elevated** and paired with explicit per-hazard verification tasks.
- Every task carries an `` `Implements`-directive `` header listing the V-Model IDs it realises (REQ/SYS/ARCH/MOD/HAZ). The downstream `implement` command validates these headers.

### `/speckit.v-model.implement`

The 12-step pipeline:

1. **Setup** — `setup-implement.sh` surfaces `VMODEL_DIR` and the canonical paths.
2. **Gate** — `run-v-model-gate.sh` runs the 8-stage pipeline (see below). Any non-zero exit aborts before codegen.
3. **Domain overlay load** — read `v-model-config.yml`; if a `domain:` is set, layer the matching overlay instructions onto the prompt.
4. **Codegen** — generate or modify source under `src/`.
5. **4-level test gen** — generate paired tests under `tests/unit/`, `tests/integration/`, `tests/system/`, `tests/acceptance/`.
6. **Splice** — `splice-managed-regions.sh` injects generated code into existing files via sentinel markers (`<<<REGION id="X">>>` … `<<<END>>>`); emits `diff -u original spliced` on stderr.
7. **Hallucination guard** — `validate-implements-ids.sh --canonical specs/<feature>/v-model --scan <repo-root> --changed-only` rejects any `Implements`-directive that cites an ID absent from the canonical V-Model artifact set.
8. **Quality harness** — re-runs structural and (optionally) LLM evals on the new artifacts.
9. **Reduced-enrichment fallback** — if quality drops below threshold, retry with reduced overlay enrichment to isolate prompt-injection regressions.
10. **Commit annotation** — generates a commit subject of the form `feat(<scope>): <summary> — REQ-NNN, SYS-NNN, MOD-NNN` (the literal em-dash `—`, U+2014, is the ID-list separator).
11. **Structured summary** — emits a single structured stdout/stderr block summarising files written, tests run, and gate results.
12. **Handoffs** — invokes the `after_implement` hook, which re-runs `/speckit.v-model.trace` to refresh the matrix.

---

## The 8-Stage Gate (`run-v-model-gate.sh`)

The gate is the deterministic backbone of the bridge. Every stage is a single sub-validator; any non-zero exit aborts the pipeline.

| Stage | Sub-validator | What it enforces |
|-------|---------------|------------------|
| 1 | `validate-artifact-status` (MF-6) | Every canonical V-Model artifact carries `**Status**: Approved` (configurable via `--required-status`). |
| 2 | `validate-domain-profile` (MF-7) | `v-model-config.yml` (when present) names a valid domain (`iso_26262`, `do_178c`, `iec_62304`). Absent file → non-fatal SKIP. |
| 3 | `build-matrix --check` | The traceability matrix builds without orphans or cycles. |
| 4 | `validate-requirement-coverage` | REQ ↔ ATP/SCN coverage. |
| 5 | `validate-system-coverage` | SYS ↔ STP coverage. |
| 6 | `validate-architecture-coverage` | ARCH ↔ ITP coverage. ⚠️ Currently FAILs on the v0.7.0 dogfood feature `specs/007-bridge-commands/` — see [v0.7.0 Known Limitations](../community/changelog.md#known-limitations-deferred-to-v080). |
| 7 | `validate-module-coverage` | MOD ↔ UTP coverage. |
| 8 | `validate-hazard-coverage` | HAZ ↔ mitigation/verification coverage. |

The same gate runs as the `before_implement` hook (a redundant fail-fast check) and is wired into CI in [CI Integration](ci-integration.md).

---

## Splicer (MF-5) — Sentinel-Managed Regions

`splice-managed-regions.sh` injects generated code into existing source files without disturbing surrounding hand-written code. v0.7.0 hardens it against the failure modes catalogued in the pre-v0.8.0 audit:

| Mode / Flag | Behaviour |
|-------------|-----------|
| Single-payload (legacy) | Replace every region in the target with the supplied payload. Stdout byte-identical to v0.6.x. |
| `--region-from <regions-file>` | Replace each region with its matching payload from a regions file (per-region payload mode, new in v0.7.0). |
| `2>&1` capture | Every successful run emits `diff -u original spliced` on **stderr** — capture it (e.g. `2>> tests/.splicer-diffs.log`) for audit-trail evidence; suppress it (`2>/dev/null`) only if you do not need that evidence. |

| Exit | Cause |
|------|-------|
| 0 | Successful splice. |
| 1 | File not found, unbalanced markers, orphan markers, nested markers, bad CLI usage. |
| 2 | BEGIN/END `id` mismatch, duplicate region `id`, missing payload for a declared region, malformed regions file. |

---

## Hallucination Guard

`validate-implements-ids.sh` is the last line of defence between the LLM and the audit trail. It enforces an existence check: every cited V-Model ID must be present in the canonical artifact set.

```bash
validate-implements-ids.sh \
  --canonical specs/<feature>/v-model \
  --scan      "$(pwd)" \
  --changed-only
```

- `--canonical` — the authoritative ID source.
- `--scan` — where to look for `Implements`-directive headers (typically the repo root, so `src/` and `tests/{unit,integration,system,acceptance}/` are in scope).
- `--changed-only` — intersect the scan set with `git diff --name-only` so the guard only inspects modified files.

v0.8.0's [EPIC-4](../community/roadmap.md) layers semantic checks (path / symbol / reachability via the trace matrix) onto this existence check.

---

## Compliance and Hybrid Modes

The extension supports **two modes of operation**. Pick one and be explicit about it in your repository's README and CI configuration — this is the difference between a compliant audit trail and a prototyping shortcut.

### Compliant mode (recommended for regulated work)

Use the V-Model bridge end-to-end:

```text
/speckit.v-model.plan       →  plan.md (V-Model-enriched, schema-validated)
/speckit.v-model.tasks      →  tasks.md (TDD-ordered)
/speckit.v-model.implement  →  source + tests + hallucination guard + trace post-hook
```

Every step runs `run-v-model-gate.sh` (the 8 stages above), the `Implements`-directive hallucination guard, and the trace post-hook. This is the path designed for regulated work targeting IEC 62304, ISO 26262, or DO‑178C.

### Hybrid mode (prototyping only)

It is technically possible to feed a `tasks.md` produced by `/speckit.v-model.tasks` to **core** `/speckit.implement` — the schema round-trips. **This is a hybrid mode that bypasses the V-Model gates, the hallucination guard, and the trace post-hook.** Use it only for prototyping or for non-safety-critical features inside an otherwise-V-Model repository.

!!! danger "Audit guidance"
    A build that ran `/speckit.implement` against a V-Model `tasks.md` is **not** evidence of V-Model compliance, regardless of how the artifacts look. The deterministic gates left no record because they were not invoked.

v0.8.0's [EPIC-1 `compliance_mode: strict` profile](../community/roadmap.md) will make this distinction mechanically detectable in CI.

---

## Lifecycle Hooks

v0.7.0 ships **4 lifecycle hooks** that the bridge commands invoke automatically. They live under `commands/hooks/` and are `optional: true` in v0.7.0; EPIC-1 (v0.8.0) flips them to mandatory under the `strict` profile.

| Hook | Triggered after | Purpose |
|------|-----------------|---------|
| `after_specify` | `/speckit.specify` | Wire the V-Model directory layout under the new feature folder. |
| `after_tasks` | `/speckit.v-model.tasks` | Re-run `validate-core-schema.sh --tasks` to confirm the H2 order survived edits. |
| `before_implement` | (before) `/speckit.v-model.implement` | Re-run the 8-stage `run-v-model-gate.sh` as a fail-fast check. |
| `after_implement` | `/speckit.v-model.implement` | Re-run `/speckit.v-model.trace` to refresh the traceability matrix with the newly produced source/test pairs. |

---

## Migration Notes

- **`**Status**: Draft` headers** on canonical V-Model artifacts will fail the new MF-6 status validator. Either flip the status to `Approved` (the intended workflow) or invoke the validator directly with `--required-status Draft --required-status Approved` while migrating.
- **`v-model-config.yml`** values: rename `automotive | medical | aerospace` to `iso_26262 | do_178c | iec_62304`. The `general` overlay has been removed; non-regulated repositories should omit the `domain:` key entirely. See [Configuration — Migration](../reference/configuration.md#domain).
- **Splicer callers**: existing single-payload-for-all-regions invocations remain byte-identical on **stdout**. The new `diff -u` emission goes to **stderr** only.
- **Bridge commands in CI**: switch any direct `/speckit.plan` / `/speckit.tasks` / `/speckit.implement` invocations on V-Model repositories to the `/speckit.v-model.*` variants to pick up the gates and the hallucination guard. The hybrid path remains supported for prototyping.

---

## See Also

- [Command Reference — Bridge to Implementation](../reference/commands.md#bridge-to-implementation-commands)
- [Scripts Reference — v0.7.0 Bridge & Stabilization Scripts](../reference/scripts.md#v070-bridge-stabilization-scripts)
- [Configuration — Domain](../reference/configuration.md#domain)
- [CI Integration](ci-integration.md)
- [Roadmap — v0.8.0 Stabilization Backlog](../community/roadmap.md)
