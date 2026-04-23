---
title: Brownfield Evolution Guide
description: How to evolve existing V-Model artifact chains through specification changes using the ID lifecycle model — for teams adopting the extension on existing projects.
---

# Brownfield Evolution Guide

Brownfield evolution is the process of updating an existing V-Model artifact chain when specifications change — deprecating stale IDs, creating new ones, and resolving the SUSPECT items that cascade downstream. This guide explains the pattern and walks through a concrete example.

---

## What Is Brownfield Evolution?

**Greenfield** — you are creating new V-Model artifacts from scratch against a new specification. No existing artifacts to consider. Every command generates forward.

**Brownfield** — you are evolving existing V-Model artifacts. The specification has changed, and the existing artifacts (requirements, acceptance tests, system design, architecture, module design, unit tests) must be updated in a way that:

- Preserves full traceability (no IDs deleted)
- Documents what changed and why (deprecation audit trail)
- Identifies what needs review (SUSPECT cascade)
- Does not silently overwrite existing work

Brownfield evolution is the normal state of living software. Specifications change. Requirements get refined. Architectural decisions get revised. The ID lifecycle model makes these changes traceable.

---

## The Three-Step Pattern

Every brownfield evolution follows the same three-step pattern, derived from the v0.6.0 dogfooding experience across features 002–005e.

### Step 1: Manually evolve `spec.md`

Before running any commands, update the feature specification:

- **Describe the new behavior** — what changed, why, and how the system should behave now
- **Remove hardcoded domain references** — if the spec referenced "ISO 26262 ASIL-B" or "DO-178C DAL-A", replace them with domain-agnostic language (e.g., "functional safety classification appropriate to the configured domain")
- **Add evolution context** — note which previous requirements are being superseded and why

This manual step is deliberate. Specification evolution requires human judgment — the AI commands handle the mechanical propagation, but the human must make the architectural decisions about what changes and why.

### Step 2: Run commands in V-model order with evolution context

Run each command top-down the V with `--evolve` context:

```
/speckit.v-model.requirements --evolve
  [describe: which REQs are superseded, which are withdrawn, which are new]

/speckit.v-model.acceptance
  [diff-requirements detects deprecated REQs → marks ATPs as SUSPECT/DEPRECATED]

/speckit.v-model.system-design --evolve
  [suspect detection on deprecated REQs → mark SYS items as SUSPECT]

/speckit.v-model.system-test --evolve
  [suspect detection on deprecated SYS items → mark STP items as SUSPECT]

/speckit.v-model.architecture-design --evolve
/speckit.v-model.integration-test --evolve
/speckit.v-model.module-design --evolve
/speckit.v-model.unit-test --evolve

/speckit.v-model.trace
  [validates full chain: deprecated items, suspect resolutions, new coverage]
```

Each command reads the existing artifact and applies [lifecycle rules](id-lifecycle.md):

- Items whose parents are deprecated become SUSPECT
- New requirements get new downstream artifacts
- Nothing is silently deleted

### Step 3: Resolve SUSPECT items

After the commands run, work through every SUSPECT item in the artifact chain:

| Resolution | When to use | Action |
|-----------|-------------|--------|
| **Re-parent** | Capability continues under superseding ID | Update the traceability link to the new parent ID |
| **Deprecate** | Capability is removed | Mark `[DEPRECATED — Superseded by {ID}]` or `[DEPRECATED — Withdrawn: {reason}]` and cascade down |
| **Confirm active** | Item is still valid despite parent change | Add a rationale note and mark as resolved |

After all SUSPECT items are resolved, run `/speckit.v-model.trace` to verify the chain is clean — no orphaned IDs, no unresolved suspects, full coverage of new requirements.

---

## Example: Removing a Hardcoded Domain Reference

### Context

Feature 002 (system-design + system-test commands) had requirements that referenced ISO 26262 directly in their text. With the domain overlay architecture, these references should move to the overlay files — the base requirements should use domain-agnostic language.

### Starting state

`requirements.md`:

```markdown
## REQ-010
The system-design command shall include an ISO 26262 Freedom from Interference (FFI)
analysis section for all components with ASIL B or higher classification.

## REQ-011
The system-design command shall enforce Restricted Complexity per ISO 26262 §7.4.9
with a maximum cyclomatic complexity of 10.
```

`system-design.md`:

```markdown
## SYS-005 (traces REQ-010)
The command instruction set shall include an FFI section template with ASIL-specific
guidance columns.

## SYS-006 (traces REQ-011)
The command instruction set shall enforce cyclomatic complexity ≤ 10 for all
safety-classified modules.
```

### After evolving `spec.md`

The spec is updated: the system-design command should emit FFI and complexity constraints only when the configured domain requires them. The base command should be domain-neutral.

### Step 1 result — evolved `requirements.md`

```markdown
## REQ-010 [DEPRECATED — Superseded by REQ-022]
~~The system-design command shall include an ISO 26262 Freedom from Interference (FFI)
analysis section for all components with ASIL B or higher classification.~~

## REQ-011 [DEPRECATED — Superseded by REQ-023]
~~The system-design command shall enforce Restricted Complexity per ISO 26262 §7.4.9
with a maximum cyclomatic complexity of 10.~~

## REQ-022
The system-design command base instructions shall contain only IEEE 1016–governed
design views; domain-specific safety sections (e.g., FFI analysis, complexity limits)
shall be loaded from the domain overlay file at runtime.

## REQ-023
When domain: iso_26262 is configured, the system-design overlay shall inject an FFI
analysis section and a Restricted Complexity section into the command output.
```

### Step 2 result — SUSPECT cascade in `system-design.md`

```markdown
## SYS-005 [SUSPECT — Parent REQ-010 deprecated]
~~The command instruction set shall include an FFI section template with ASIL-specific
guidance columns.~~
<!-- Resolution needed -->

## SYS-006 [SUSPECT — Parent REQ-011 deprecated]
~~The command instruction set shall enforce cyclomatic complexity ≤ 10 for all
safety-classified modules.~~
<!-- Resolution needed -->

## SYS-015 (traces REQ-022) [NEW]
The base system-design command shall contain only IEEE 1016 design views (Decomposition,
Dependency, Interface, Data Design) with no domain-specific safety sections.

## SYS-016 (traces REQ-023) [NEW]
The iso_26262 domain overlay for system-design shall inject FFI analysis and Restricted
Complexity sections when loaded.
```

### Step 3 — resolve SUSPECT items

SYS-005 and SYS-006 described capabilities that moved to the overlay. They are not withdrawn — they are superseded:

```markdown
## SYS-005 [DEPRECATED — Superseded by SYS-016]
~~The command instruction set shall include an FFI section template...~~

## SYS-006 [DEPRECATED — Superseded by SYS-016]
~~The command instruction set shall enforce cyclomatic complexity...~~
```

All downstream artifacts tracing to SYS-005 and SYS-006 (system test plans, architecture components) are then reviewed and re-parented to SYS-015/SYS-016 as appropriate.

Final `trace` run confirms: no unresolved suspects, full coverage of REQ-022 and REQ-023 through the new SYS → ARCH → MOD → UTP chain.

---

## Checklist

Use this checklist for a complete brownfield evolution pass:

- [ ] Updated `spec.md` with domain-agnostic language and evolution rationale
- [ ] Identified all REQs being superseded (list their old and new IDs)
- [ ] Identified all REQs being withdrawn (list IDs and reasons)
- [ ] Ran `/speckit.v-model.requirements --evolve` — deprecated old REQs, created new REQs
- [ ] Ran `/speckit.v-model.acceptance` — ATPs for deprecated REQs marked SUSPECT/DEPRECATED
- [ ] Ran `/speckit.v-model.system-design --evolve` — SYS items reviewed for SUSPECT
- [ ] Ran `/speckit.v-model.system-test --evolve` — STPs reviewed for SUSPECT
- [ ] Ran `/speckit.v-model.architecture-design --evolve` — ARCH items reviewed
- [ ] Ran `/speckit.v-model.integration-test --evolve` — ITPs reviewed
- [ ] Ran `/speckit.v-model.module-design --evolve` — MOD items reviewed
- [ ] Ran `/speckit.v-model.unit-test --evolve` — UTPs reviewed
- [ ] Resolved all SUSPECT items (re-parent, deprecate, or confirm active)
- [ ] Ran `/speckit.v-model.trace` — clean chain, no orphans, no unresolved suspects
- [ ] Ran validation scripts (`validate-requirement-coverage.sh`, etc.) — all pass
- [ ] Reviewed peer-review findings for evolved artifacts — no critical/major findings

---

## Impact Analysis Integration

Before starting a brownfield evolution, run impact analysis to understand the blast radius:

```bash
# Which downstream artifacts trace to REQ-010?
scripts/bash/impact-analysis.sh --downward REQ-010 specs/<feature>/v-model

# What is the full blast radius of deprecating both REQ-010 and REQ-011?
scripts/bash/impact-analysis.sh --downward REQ-010 REQ-011 specs/<feature>/v-model --json
```

Or using the command:

```
/speckit.v-model.impact-analysis --downward REQ-010 REQ-011
```

The impact analysis output gives you:

- **Blast radius** — total count of artifacts that will become SUSPECT
- **Suspect artifacts by level** — broken down by Requirements, System Design, Architecture, etc.
- **Re-validation order** — the sequence in which to resolve suspects (top-down: REQ → SYS → ARCH → MOD)

Running impact analysis first means you go into the evolution with a complete picture of what's changing — no surprises mid-way through the V-cycle.

!!! tip "Start small"
    For your first brownfield evolution, pick a single requirement that touches only one or two downstream artifacts. This gives you a clean example of the three-step pattern before tackling a large-scale evolution with dozens of SUSPECT items.

!!! info "See also"
    - [ID Lifecycle Model](id-lifecycle.md) — detailed reference for lifecycle states, syntax, and rules
    - [Impact Analysis](impact-analysis.md) — how to compute blast radius before starting an evolution
    - [Domain Overlay Architecture](domain-overlays.md) — the overlay system that motivated most v0.6.0 evolutions
