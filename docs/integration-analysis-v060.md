# Integration Analysis: Foundation Hardening (v0.6.0)

> **Purpose:** Define how the domain decoupling refactoring, ID lifecycle model, and standards enrichment fit into the master plan as a new milestone between M0 (v0.5.0) and M1 (Bridge Commands).
>
> **Approach:** Approach B (SDD-based spec evolution) — evolve existing feature specifications through the V-cycle, then re-implement. See [Spec-Driven Development philosophy](https://github.com/github/spec-kit/blob/main/spec-driven.md).
>
> **Related documents:**
> - [Standards Reference](standards-reference.md) — audit of all 15 current + 9 proposed standards
> - [Domain Decoupling Design](domain-decoupling-design.md) — overlay architecture and per-file refactoring plan

---

## 1. The Core Dependency — Why This Must Precede Bridge Commands

The M1 bridge commands (`v-model.implement`, `v-model.plan`, `v-model.tasks`) read **ALL** existing V-Model artifacts. If those artifacts contain hardcoded safety/domain references, the bridge commands inherit the contamination and will need to be reworked later. This is not about preference — it's about technical dependency.

Additionally, since bridge commands orchestrate the full V-cycle, they need every feature to have a **complete** V-Model artifact chain. Features 001–004 currently have incomplete V-Model directories (0 to 7 of 9 artifacts). Filling these gaps now means bridge commands will operate on a uniform, complete artifact landscape from day one.

Finally, bridge commands need to support the `--evolve` lifecycle pattern (deprecation + supersession) from inception. If the lifecycle model is bolted on after M1, every bridge command must be retroactively updated.

---

## 2. Revised Milestone Structure

```
M0   (v0.5.0) — Foundation                              ← DONE
M0.5 (v0.6.0) — Foundation Hardening                    ← NEW
  ├─ Wave 1: Feature 006 — Foundation Infrastructure
  │    ├─ Pillar 1: Domain Overlay Architecture
  │    └─ Pillar 2: ID Lifecycle Model
  ├─ Wave 2: Evolve existing features (001–005e) through V-cycle
  │    ├─ Retroactively complete V-Model artifacts for features 001–004
  │    ├─ Evolve specifications using ID lifecycle (deprecation + supersession)
  │    └─ Enrich commands with new best-practice standards
  └─ Wave 3: Validation & brownfield lessons
M1   (v0.7.0) — Bridge Commands
M2   (v0.8.0) — Orchestration & Reasoning Transparency
M3   (v0.9.0) — Hardening & Auditability
M4   (v1.0+)  — Enterprise Cloud Platform               ← DEFERRED
```

Feature numbering stays aligned with releases: features 001–005e shipped in v0.5.0 (M0), feature 006 + feature evolutions ship in v0.6.0 (M0.5), bridge commands become feature 007 in v0.7.0 (M1), and so on.

---

## 3. Feature 006: Foundation Infrastructure

Feature 006 provides two cross-cutting pillars that all subsequent feature evolutions depend on.

### Pillar 1: Domain Overlay Architecture

> Full design: [domain-decoupling-design.md](domain-decoupling-design.md)

**Problem:** 31 of 60 existing V-Model artifacts contain safety/domain references (ISO 26262, DO-178C, IEC 62304) despite spec-kit-v-model being a non-safety developer tool. Commands mix domain-specific content from multiple standards even when a single domain is configured. The `config-template.yml` has no `domain` field despite commands referencing it.

**Solution:** The Domain Overlay Architecture — base commands contain ONLY best-practice standards; domain-specific content lives in overlay directories loaded at runtime based on configuration.

**Deliverables:**

| Deliverable | Description |
|-------------|-------------|
| `config-template.yml` update | Add `domain` field (values: empty, `iso_26262`, `do_178c`, `iec_62304`) |
| `commands/overlays/` | Per-domain overlay directories with focused instruction files |
| `templates/overlays/` | Per-domain template overlay directories |
| `_domain.yml` manifests | Per-domain manifests describing what each overlay extends |
| Assembly protocol | Standardized domain loading step (reusable instruction block for all commands) |
| Preference-based indirection | Base content has defaults; overlay content overrides when loaded |

### Pillar 2: ID Lifecycle Model

**Problem:** All V-Model commands use an "append-only" model: preserve existing IDs, never modify, never delete. This supports forward development and incremental growth, but blocks specification evolution — requirements that become obsolete cannot be properly retired, and downstream artifacts cannot be updated in place.

The `acceptance` command already has a partial lifecycle model (it marks removed REQs as `[DEPRECATED]` and replaces modified REQ sections in-place), but no other command supports this pattern.

**Solution:** A formal ID lifecycle model extended to ALL generative commands, enabling proper specification evolution while preserving full traceability.

**The lifecycle states:**

```
                    ┌──────────────────────────────────┐
                    │             ACTIVE                │
                    │   (current, must be satisfied)    │
                    └──────┬──────────────────┬─────────┘
                           │                  │
                    content changed     no longer needed
                           │                  │
                    ┌──────▼──────┐     ┌─────▼─────────────────────────┐
                    │  MODIFIED   │     │          DEPRECATED            │
                    │  (same ID,  │     │  ┌──────────────────────────┐ │
                    │  new content,│     │  │ Superseded by {X}-NNN   │ │
                    │  downstream │     │  └──────────────────────────┘ │
                    │  → suspect) │     │  ┌──────────────────────────┐ │
                    └─────────────┘     │  │ Withdrawn: <reason>      │ │
                                        │  └──────────────────────────┘ │
                                        └──────────────┬────────────────┘
                                                       │
                                              downstream items
                                               become SUSPECT
                                                       │
                                        ┌──────────────▼───────────────┐
                                        │           SUSPECT             │
                                        │  "Parent REQ-003 deprecated"  │
                                        │  Needs review:                │
                                        │  → Re-parent to superseding ID│
                                        │  → Deprecate (cascade down)   │
                                        │  → Confirm still valid        │
                                        └──────────────────────────────┘
```

**Deprecation types:**

| Type | Syntax | Meaning |
|------|--------|---------|
| Supersession | `[DEPRECATED — Superseded by REQ-NNN]` | Replaced by a new item; downstream should re-parent |
| Withdrawal | `[DEPRECATED — Withdrawn: <reason>]` | Removed entirely; downstream should be deprecated or confirmed |

**Suspect cascade:** When a parent ID is deprecated, all downstream IDs that trace to it become `[SUSPECT]`. Each suspect item must be reviewed and resolved (re-parented, deprecated, or confirmed active).

**Command changes required:**

| Command | Current Model | Added Capability |
|---------|---------------|-----------------|
| `requirements` | Preserve + append | + Deprecation support + modification-in-place |
| `acceptance` | ✅ Already has `[DEPRECATED]` + in-place replacement | + Suspect detection from parent REQ |
| `system-design` | Preserve + append | + Suspect detection from parent REQ + deprecation |
| `system-test` | Preserve + append | + Suspect detection from parent SYS + deprecation |
| `architecture-design` | Preserve + append | + Suspect detection from parent SYS + deprecation |
| `integration-test` | Preserve + append | + Suspect detection from parent ARCH + deprecation |
| `module-design` | Preserve + append | + Suspect detection from parent ARCH + deprecation |
| `unit-test` | Preserve + append | + Suspect detection from parent MOD + deprecation |
| `trace` | Coverage analysis | + Deprecation-aware reporting (deprecated chains, suspect items) |
| `impact-analysis` | Change detection | + Natural fit: "what is impacted by deprecating REQ-001?" |

**Each command gains a "Lifecycle Rules" section** between the existing "Load existing" and "Generate new" steps:

```markdown
### Lifecycle Rules (applies when evolving existing artifacts)

1. **Never delete an ID** — mark as `[DEPRECATED]`
2. **Deprecation types:**
   - `[DEPRECATED — Superseded by {ID}]`: Replaced by a new item
   - `[DEPRECATED — Withdrawn: {reason}]`: Removed with justification
3. **Suspect detection:** If a parent ID (from the upstream artifact) is
   deprecated, mark the linked item as `[SUSPECT — Parent {ID} deprecated]`
4. **Suspect resolution:** For each suspect item:
   - Re-parent to the superseding ID (if capability continues)
   - Deprecate (if capability is removed)
   - Confirm active (if still valid despite parent change)
5. **Modified items:** Update content in-place, preserve ID
```

### Feature 006 V-Model Artifacts

Feature 006 will have a full V-Model artifact chain covering both pillars:

```
specs/006-foundation-infrastructure/
  spec.md
  v-model/
    requirements.md        → REQs for: overlay directories, config domain field,
                              assembly protocol, _domain.yml manifests,
                              ID lifecycle states, deprecation syntax,
                              suspect cascade rules, per-command lifecycle section
    acceptance-plan.md     → ATPs: overlay loading with/without domain,
                              deprecation preserves traceability,
                              suspect detection works across V-chain
    system-design.md       → SYS: overlay file resolution, config parsing,
                              lifecycle state machine, suspect propagation
    system-test.md         → STP: end-to-end overlay assembly, lifecycle cascade
    architecture-design.md → ARCH: overlay loading architecture, lifecycle rules
                              integration into command instruction structure
    integration-test.md    → ITP: cross-command overlay + lifecycle consistency
    module-design.md       → MOD: individual overlay files, lifecycle section template
    unit-test.md           → UTP: config parsing, overlay loading, state transitions
    traceability-matrix.md → Full REQ↔SYS↔ARCH↔MOD↔test trace
```

---

## 4. Wave 2 — Evolve Existing Features Through the V-Cycle

Each feature evolution combines **three activities** in a single V-cycle pass:

1. **Complete the V-Model** — create any missing artifacts retroactively
2. **Evolve specifications** — deprecate safety-specific IDs, create domain-agnostic replacements using the ID lifecycle model
3. **Enrich with new standards** — weave in relevant standards from [standards-reference.md](standards-reference.md)

### Evolution Execution Pattern

For each feature, the execution follows this pattern:

```
Step 1: Manually evolve spec.md
         (describe overlay-aware behavior, remove hardcoded domain references)
                │
Step 2: Run /speckit.v-model.requirements with evolution $ARGUMENTS
         (command deprecates stale REQs, creates new domain-agnostic REQs)
                │
Step 3: Run /speckit.v-model.acceptance
         (diff-requirements.sh detects changes; deprecated REQs → [DEPRECATED] ATPs;
          new REQs → new ATPs/SCNs)
                │
Step 4: Run /speckit.v-model.system-design (or create if missing)
         (suspect detection on deprecated REQs → resolve SYS items)
                │
Step 5: Continue down the V-cycle...
         system-test → architecture-design → integration-test →
         module-design → unit-test → trace
                │
Step 6: Run /speckit.v-model.trace
         (validates full chain; reports deprecated items, suspect resolutions,
          coverage of new domain-agnostic requirements)
```

**For missing artifacts** (features 001–004): The commands detect that no artifact exists and generate from scratch against the updated spec.md. No lifecycle complexity — pure greenfield generation.

**For existing artifacts** (features 002–005e): The commands use the lifecycle model to deprecate stale items, create replacements, detect suspects, and resolve them. Full traceability is preserved.

### Per-Feature Analysis

#### Feature 001 — v-model-mvp (trace + requirements + acceptance commands)

| Dimension | Current State | Target State |
|-----------|--------------|--------------|
| **V-Model completeness** | 0/9 (no v-model/ directory) | 9/9 — full V-Model created retroactively |
| **Domain coupling** | `trace.md` ❌ HARDCODED: 5 safety standards cited unconditionally; `requirements.md` ✅ clean; `acceptance.md` ✅ clean | All 3 commands clean in base; trace safety content in domain overlays |
| **Standards enrichment** | `acceptance.md` has ZERO governing standards; `requirements.md` has IEEE 29148 + INCOSE | + IEEE 1012:2016 (acceptance V&V), + ISO/IEC 25010:2023 (requirements quality taxonomy), + ISO/IEC/IEEE 15289:2019 (trace documentation) |
| **Lifecycle usage** | N/A (no existing artifacts to evolve) | Greenfield — all 9 artifacts created fresh from updated spec.md |

**Update depth: 🔴 Deep** — creating 9 V-Model artifacts from scratch + major rewrite of trace.md command + moderate updates to acceptance.md and requirements.md commands.

#### Feature 002 — system-design-testing (system-design + system-test commands)

| Dimension | Current State | Target State |
|-----------|--------------|--------------|
| **V-Model completeness** | 3/9 (requirements, acceptance-plan, traceability-matrix) | 9/9 — 6 artifacts created retroactively |
| **Domain coupling** | `system-design.md` conditional but safety sections are 100% ISO 26262 (FFI §7.4.8, Restricted Complexity §7.4.9); `system-test.md` conditional but mixes ISO 26262-6 + DO-178C references | Base commands clean; FFI/Restricted Complexity in iso_26262 overlay; MC/DC in do_178c overlay |
| **Standards enrichment** | IEEE 1016 (system design), ISO 29119 (system test) | + ISO/IEC 25010:2023 (quality taxonomy for design decisions) |
| **Lifecycle usage** | Deprecate safety-specific REQs in existing requirements.md → create overlay-aware replacements | Existing 3 artifacts evolved via lifecycle; 6 new artifacts created fresh |

**Update depth: 🟡 Medium** — evolving 3 existing artifacts + creating 6 new + extracting conditional safety sections to overlays.

#### Feature 003 — architecture-integration (architecture-design + integration-test commands)

| Dimension | Current State | Target State |
|-----------|--------------|--------------|
| **V-Model completeness** | 5/9 (requirements, acceptance-plan, system-design, system-test, traceability-matrix) | 9/9 — 4 artifacts created retroactively |
| **Domain coupling** | `architecture-design.md` conditional but mixes ASIL Decomposition (ISO 26262 only) + Temporal Constraints (DO-178C only) — both shown to all domains; `integration-test.md` conditional but mixes SIL/HIL references | Base commands clean; ASIL Decomposition in iso_26262 overlay; Temporal Constraints in do_178c overlay; SIL/HIL split per domain |
| **Standards enrichment** | IEEE 42010 + Kruchten 4+1 (architecture), ISO 29119 (integration test) | + ISO/IEC 42030:2019 (architecture evaluation — adds evaluation step alongside description) |
| **Lifecycle usage** | Deprecate domain-mixed REQs/SYS in existing artifacts → create domain-agnostic replacements | Existing 5 artifacts evolved via lifecycle; 4 new artifacts created fresh |

**Update depth: 🟡 Medium** — evolving 5 existing artifacts + creating 4 new + extracting mixed domain content to per-domain overlays.

#### Feature 004 — module-unit (module-design + unit-test commands)

| Dimension | Current State | Target State |
|-----------|--------------|--------------|
| **V-Model completeness** | 7/9 (all except module-design, unit-test) | 9/9 — 2 artifacts created retroactively |
| **Domain coupling** | `module-design.md` ⚠️ MIXED: "DO-178C/ISO 26262-compliant" in opening framing, MISRA/Memory/Entry-Exit hardcoded in base; `unit-test.md` conditional but MC/DC coverage reference mixed | Base commands use generic software engineering framing; MISRA/MC/DC/Memory in domain overlays |
| **Standards enrichment** | IEEE 1016 (module design), ISO 29119-4 (unit test) | + ISO/IEC/IEEE 12207:2017 (lifecycle processes for module design rigor) |
| **Lifecycle usage** | Deprecate safety-framed REQs/SYS/ARCH in existing artifacts → create generic replacements | Existing 7 artifacts evolved via lifecycle; 2 new artifacts created fresh |

**Update depth: 🔴 Deep** — evolving 7 existing artifacts + creating 2 new + rewriting module-design.md framing + extracting safety sections.

*Note: Feature 004 delivered the module-design and unit-test COMMANDS but is missing the module-design.md and unit-test.md V-MODEL ARTIFACTS for itself. Creating these retroactively is a meaningful dogfooding moment.*

#### Feature 005a — hazard-analysis

| Dimension | Current State | Target State |
|-----------|--------------|--------------|
| **V-Model completeness** | 9/9 ✅ | 9/9 — evolve existing artifacts |
| **Domain coupling** | ⚠️ MIXED: "ISO 14971/ISO 26262-compliant" in opening framing; ASIL + DAL severity tables hardcoded for all domains | Base command uses generic risk analysis framing; severity tables (ASIL, DAL, SIL) in respective domain overlays |
| **Standards enrichment** | ISO 14971, ISO 26262 | No new standards needed — already well-covered |
| **Lifecycle usage** | Deprecate domain-hardcoded REQs → create generic risk analysis REQs + domain overlay REQs | All 9 artifacts evolved via lifecycle |

**Update depth: 🔴 Deep** — all 9 artifacts evolved; framing genericized + severity tables extracted to overlays.

#### Feature 005b — impact-analysis

| Dimension | Current State | Target State |
|-----------|--------------|--------------|
| **V-Model completeness** | 9/9 ✅ | 9/9 — evolve existing artifacts |
| **Domain coupling** | ✅ CLEAN — deterministic script, no safety content | Add overlay-aware impact tracking as a future capability reference |
| **Standards enrichment** | None currently | + IEEE 828 (configuration management — impact analysis is fundamentally about change tracking) |
| **Lifecycle usage** | Minimal — mostly additive enrichment via $ARGUMENTS | Light evolution; new REQs appended for overlay awareness + IEEE 828 |

**Update depth: 🟢 Light** — artifacts exist and are clean; updates are additive.

#### Feature 005c — peer-review

| Dimension | Current State | Target State |
|-----------|--------------|--------------|
| **V-Model completeness** | 9/9 ✅ | 9/9 — evolve existing artifacts |
| **Domain coupling** | ⚠️ MIXED: hardcoded "DO-178C / ISO 26262" as governing standards in review table | Base command uses generic review methodology; domain-specific governing standards in overlays |
| **Standards enrichment** | None currently (no governing standard cited for generic reviews) | + IEEE 1028:2008 (formal review types) + ISO/IEC 20246:2017 (review techniques) |
| **Lifecycle usage** | Deprecate domain-hardcoded governing standards REQs → create generic review methodology REQs | Affected artifacts evolved via lifecycle |

**Update depth: 🟡 Medium** — governing standards table genericized + two new standards added.

#### Feature 005d — test-results

| Dimension | Current State | Target State |
|-----------|--------------|--------------|
| **V-Model completeness** | 9/9 ✅ | 9/9 — no changes needed |
| **Domain coupling** | ✅ CLEAN — deterministic script, no safety content | Already clean |
| **Standards enrichment** | None | None needed |
| **Lifecycle usage** | None | None |

**Update depth: ⚪ Skip** — fully complete, fully clean, no standards gap.

#### Feature 005e — audit-report

| Dimension | Current State | Target State |
|-----------|--------------|--------------|
| **V-Model completeness** | 9/9 ✅ | 9/9 — evolve existing artifacts |
| **Domain coupling** | 🟢 Minor — safety-specific examples only (not instructions) | Replace safety-specific examples with generic ones |
| **Standards enrichment** | None currently | + IEEE 828 (config management audit) + ISO 19011:2018 (audit methodology) + ISO/IEC/IEEE 15289:2019 (documentation standards) |
| **Lifecycle usage** | Light — mostly additive enrichment | Light evolution; example cleanup + new standards appended |

**Update depth: 🟢 Light** — minor example cleanup + three new standards as enrichment.

### Aggregate Numbers

| Metric | Count |
|--------|-------|
| New V-Model artifacts to create (features 001–004) | **21** |
| Existing V-Model artifacts to evolve (features 002–005e) | **~55** |
| New feature 006 V-Model artifacts | **9** |
| Total V-Model artifacts touched | **~85** |
| Domain overlay files to create (commands + templates × 3 domains) | **~20** |
| New best-practice standards woven into commands | **9** |
| Features with no changes needed | **1** (005d) |
| Commands gaining lifecycle model | **10** (all generative + trace) |

---

## 5. Execution Order

The dependency graph dictates the order:

```
Wave 1: Feature 006 — Foundation Infrastructure
         │  (overlay architecture + ID lifecycle model)
         │
         │  Infrastructure MUST exist before any feature can use
         │  overlays or the lifecycle model.
         ▼
Wave 2a: Feature 001 — trace (worst offender ❌, cross-cutting, 9 new artifacts)
         Feature 005a — hazard-analysis (MIXED ⚠️, standalone, deep rewrite)
         │
         │  These can be parallel — independent features.
         │  001 establishes the overlay creation pattern for a HARDCODED command.
         │  005a establishes the pattern for a MIXED command with severity tables.
         ▼
Wave 2b: Feature 002 — system-design + system-test (6 new artifacts, conditional → overlay)
         Feature 003 — architecture + integration (4 new artifacts, mixed → overlay)
         │
         │  These can be parallel — independent features.
         │  They establish the pattern for V-Left + V-Right paired commands.
         ▼
Wave 2c: Feature 004 — module + unit (2 new artifacts, framing rewrite)
         │
         │  Benefits from patterns established in 002/003.
         │  Fills the ironic gap: module/unit commands without their own
         │  V-Model module/unit artifacts.
         ▼
Wave 2d: Feature 005c — peer-review (genericize governing standards)
         Feature 005b — impact-analysis (add overlay awareness + IEEE 828)
         Feature 005e — audit-report (example cleanup + 3 new standards)
         │
         │  Cross-cutting features — can use all prior overlays as
         │  reference examples.
         │  005d (test-results) is SKIPPED — already complete and clean.
         ▼
Wave 3:  Validation & brownfield lessons
         │  End-to-end testing: every command with domain=none,
         │  iso_26262, do_178c, iec_62304
         │  Document brownfield V-cycle lessons for extension users
         └─ Ship v0.6.0
```

---

## 6. Standards Integration

Since Approach B weaves new standards into feature evolutions, the entire [standards-reference.md](standards-reference.md) roadmap is absorbed into M0.5 — no separate phases needed:

| Standard | Priority | Woven Into Feature |
|----------|----------|-------------------|
| ISO/IEC 25010:2023 (quality taxonomy) | P1 — Critical | Features 001 (requirements), 002 (system-design) |
| IEEE 1012:2016 (V&V) | P1 — Critical | Feature 001 (acceptance — fills the zero-standard gap) |
| ISO/IEC 42030:2019 (architecture evaluation) | P1 — Critical | Feature 003 (adds evaluation alongside description) |
| IEEE 1028:2008 (formal reviews) | P2 — Strengthen | Feature 005c (adds formal review types) |
| ISO/IEC 20246:2017 (review techniques) | P2 — Strengthen | Feature 005c (adds review techniques) |
| ISO/IEC/IEEE 12207:2017 (lifecycle processes) | P2 — Strengthen | Feature 004 (adds lifecycle process rigor) |
| ISO/IEC/IEEE 15289:2019 (documentation) | P3 — Complete | Features 001 (trace) + 005e (audit documentation) |
| IEEE 828 (config management) | P3 — Complete | Features 005b (impact/change tracking) + 005e (audit) |
| ISO 19011:2018 (auditing) | P3 — Complete | Feature 005e (audit methodology) |

**All 9 standards integrated in M0.5** — no deferred phases to M1/M2/M3.

---

## 7. Deliverables — What M0.5 (v0.6.0) Produces

| Deliverable | Source |
|-------------|--------|
| Overlay directory infrastructure (`commands/overlays/`, `templates/overlays/`, manifests) | Feature 006, Pillar 1 |
| ID lifecycle model in all generative commands (deprecation, suspect cascade) | Feature 006, Pillar 2 |
| **21 new V-Model artifacts** (retroactive completeness for features 001–004) | Feature evolutions |
| **~55 evolved V-Model artifacts** (deprecated safety IDs → domain-agnostic replacements) | Feature evolutions |
| ~20 domain overlay files (commands + templates × 3 domains) | Feature evolutions (re-implementation) |
| 14 clean base commands (zero safety/domain content) | Feature evolutions (re-implementation) |
| 7 clean base templates (zero safety sections) | Feature evolutions (re-implementation) |
| Updated `config-template.yml` with `domain` field | Feature 006 |
| Updated `extension.yml` with generic command descriptions | Features 001, 004, 005a |
| 9 new best-practice standards integrated into command instructions | Woven into feature evolutions |
| **Complete, uniform 9/9 V-Model artifact chains across all features** | Retroactive creation + evolution |
| Brownfield V-cycle lessons documented | Dogfooding experience |

---

## 8. Impact on Downstream Milestones

### M1 (v0.7.0) — Bridge Commands

M1 inherits a significantly cleaner and more complete foundation:

| M1 Task | Before M0.5 | After M0.5 (v0.6.0) |
|---------|-------------|----------------------|
| `v-model.implement` design | Must handle contaminated + incomplete artifact input | Reads clean, complete base artifacts; overlay is a known pattern |
| `v-model.plan` design | Must decide whether to include safety framing; some features have no V-Model to plan against | All features have complete 9/9 V-Model chains; domain handling is configured, not guessed |
| `v-model.tasks` design | Uneven artifact landscape (0–9 per feature) | Uniform 9-artifact landscape across all features |
| `workflow-yaml` | Would need ad-hoc domain handling | Domain configuration is Step 0 of the pipeline (specified in feature 006) |
| `bridge-tests` | Must test with inconsistent artifact states | Tests operate on uniform, complete V-Model directories |

Bridge commands themselves will be **born overlay-aware and lifecycle-aware** from day one. The `v-model.implement` command includes the standardized domain loading step and supports the deprecation/suspect model natively.

**M1 spec numbering:** Bridge commands become `specs/007-bridge-commands/` (shifted from 006).

### M2 (v0.8.0) — Orchestration & Reasoning Transparency

| Impact | Detail |
|--------|--------|
| Adversarial consensus protocol | Can reference IEEE 1028 debate methodology (already integrated into peer-review in M0.5) |
| Multi-model prescreen | Operates on clean, complete artifact chains |
| Orchestrator agent | Pipeline routing can check domain config to select appropriate overlay-aware steps |

### M3 (v0.9.0) — Hardening & Auditability

| Impact | Detail |
|--------|--------|
| Implementation gate | Validates against complete 9/9 V-Model chains, not partial ones |
| ISO 15289 documentation checks | Deepening what M0.5 introduced in trace and audit |
| Correlation log | Cleaner signal — no false positives from contaminated artifacts |
| Audit report | Leverages ISO 19011 methodology (integrated in M0.5) |

---

## 9. The Brownfield Dividend

Approach B provides something no other approach can: **proof that the V-cycle works for specification evolution and retroactive adoption.** After M0.5:

1. **8 features** went through spec evolution → re-implementation using the ID lifecycle model
2. **21 V-Model artifacts** were created retroactively for features that shipped without them
3. **~55 V-Model artifacts** were evolved using deprecation + supersession (not deleted + regenerated)
4. You know exactly which V-cycle steps work well for brownfield and which need improvement
5. You've tested `v-model.impact-analysis` on real cross-cutting changes
6. You've validated that the overlay architecture works across ALL existing features
7. You've validated that the ID lifecycle model preserves traceability through evolution
8. The extension's brownfield story is validated by its own development history — **you can tell users: "we did this ourselves, here's what we learned"**

### Dogfooding Insights Expected

| Area | What We'll Learn |
|------|-----------------|
| Retroactive V-Model creation | How painful is it to create V-Model artifacts for already-shipped features? What information is missing? |
| Specification evolution | Does deprecation + supersession produce readable, auditable artifacts? Are the deprecated chains useful or noise? |
| ID lifecycle cascade | Does suspect detection across the V-chain actually help, or is it overwhelming? |
| Overlay architecture | Is the assembly protocol intuitive? Do overlays compose well? |
| Standards enrichment | Does adding a new governing standard improve the command's output quality measurably? |

---

## 10. Summary of Master Plan Changes

| Section | Change |
|---------|--------|
| **New milestone M0.5** | Added between M0 (v0.5.0) and M1, versioned as **v0.6.0** |
| **Version cascade** | M1 → v0.7.0, M2 → v0.8.0, M3 → v0.9.0 |
| **M0.5 scope** | Feature 006 (2 pillars) + 8 feature evolutions (001–005e), structured in 3 waves |
| **Feature 006 content** | Pillar 1: Domain Overlay Architecture + Pillar 2: ID Lifecycle Model |
| **V-Model retroactive completeness** | 21 new artifacts for features 001–004, bringing all features to 9/9 |
| **M0.5 execution model** | SDD-based: evolve specs using lifecycle model → re-implement; no delete + regenerate |
| **Standards integration** | All 9 new standards woven into M0.5 feature evolutions (not separate phases) |
| **M1 bridge commands** | Born overlay-aware and lifecycle-aware; operate on uniform 9/9 artifact landscape |
| **M1 spec numbering** | Bridge commands shift from `specs/006-*` to `specs/007-*` |
| **M2/M3** | Lighter load; mostly deepening what M0.5 introduced |
| **Incremental adoption** | v0.6.0 entry updated from "Bridge Commands" to "Foundation Hardening" |
