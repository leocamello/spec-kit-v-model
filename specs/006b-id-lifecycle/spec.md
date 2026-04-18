# Feature 006b: ID Lifecycle Model

## Problem Statement

All V-Model commands in spec-kit-v-model currently use an **append-only** model for specification IDs: preserve existing IDs, append new ones after them, never renumber, never modify, never delete. This model works well for forward development — incrementally growing a specification from scratch — but it fundamentally blocks **specification evolution**.

In real projects, requirements change. Features get descoped. Safety analysis reveals that a requirement was misclassified. A system component gets replaced by a different approach. When any of these happen today, the team has no supported mechanism to:

- **Retire an obsolete requirement** — REQ-003 is no longer needed, but deleting it would break the traceability chain (ATP-003-A, SYS-002, ARCH-003, MOD-005, UTP-005-A all trace back to it).
- **Replace a requirement with an updated one** — REQ-003 is superseded by REQ-012, but downstream artifacts still point to REQ-003 with no signal that they need review.
- **Signal that downstream artifacts need review** — When a parent ID changes, child IDs silently become stale. There is no mechanism to mark them as needing attention.
- **Evolve specifications in-place** — Modifying a requirement's content while preserving its ID and downstream links.

### Current State Audit (Verified)

A scan of all 14 commands reveals the following lifecycle support:

#### Append-Only Pattern (10 generative commands)

Every generative command contains the same pattern with minor wording variations:

| Command | Preserve Instruction | Append Instruction |
|---------|---------------------|--------------------|
| `requirements.md` | "preserve existing IDs and content" (line 55) | "New requirements append after existing ones — **never renumber**" (line 57) |
| `acceptance.md` | "preserve existing ATPs and SCNs" (line 52) | "**Never renumber** existing IDs" (line 79) |
| `system-design.md` | "preserve existing SYS IDs and content" (line 58) | "New components append after existing ones — **never renumber**" (line 60) |
| `system-test.md` | "preserve existing STP/STS IDs and content" (line 63) | "New test cases append after existing ones — **never renumber**" (line 65) |
| `architecture-design.md` | "preserve existing ARCH IDs and content" (line 68) | "New modules append after existing ones — **never renumber**" (line 70) |
| `integration-test.md` | "preserve existing ITP/ITS IDs and content" (line 65) | "New test cases append after existing ones — **never renumber**" (line 67) |
| `module-design.md` | "preserve existing MOD-NNN IDs and content" (line 65) | "New modules append after existing ones — **never renumber**" (line 67) |
| `unit-test.md` | "preserve existing UTP/UTS IDs and content" (line 67) | "New test cases append after existing ones — **never renumber**" (line 69) |
| `hazard-analysis.md` | "preserve existing HAZ IDs and content" (line 80) | "Never modify existing HAZ-NNN entries — append only" (line 196) |
| `peer-review.md` | N/A (stateless linter — regenerates each run) | N/A |

All 10 commands also have a trailing Operating Constraints line reinforcing this: "When updating existing [artifacts], preserve all existing IDs and append new ones."

#### Existing Partial Lifecycle Support

Three commands already have fragments of lifecycle awareness:

| Command | Existing Support | Gap |
|---------|-----------------|-----|
| `acceptance.md` | Line 77: "Removed REQs: Add a `[DEPRECATED]` tag to their ATPs/SCNs. Do NOT delete them." | Only supports one deprecation type (removal). No supersession syntax. No suspect cascade to downstream. |
| `trace.md` | Line 56: "When requirements change, linked tests become 'suspect' until re-verified." Line 177: Example output shows `[DEPRECATED] ATP-005-A: Parent REQ-005 was removed` | Awareness exists in concept, but no formal state model. No standardized suspect syntax. |
| `impact-analysis.md` | Line 65: "Suspect Artifacts — All affected IDs organized by V-Model level" | Already reports suspects, but the commands that receive this report have no mechanism to act on it. |

#### Commands with Zero Lifecycle Support

The remaining 7 generative commands (`requirements`, `system-design`, `system-test`, `architecture-design`, `integration-test`, `module-design`, `unit-test`) have no deprecation, no suspect detection, and no modification-in-place capability beyond simple content append.

### Why This Matters

1. **Brownfield V-cycle impossible** — spec-kit-v-model's own dogfooding (evolving Features 001–005 through the V-cycle for M0.5) requires the ability to deprecate domain-specific IDs and supersede them with domain-agnostic ones. Without an ID lifecycle model, this evolution cannot be done with preserved traceability.

2. **Real projects evolve** — In regulated industries, change is constant. ISO 26262 Part 8 §7 (Configuration Management) and DO-178C §7 explicitly require change tracking with impact analysis. The current append-only model means changed requirements leave silently stale downstream artifacts.

3. **Impact analysis produces actionable output with nowhere to go** — The `impact-analysis` command already identifies suspect artifacts when upstream IDs change. But the downstream commands have no mechanism to consume this information and mark their artifacts accordingly.

4. **Traceability gaps during evolution** — If a user manually deletes an obsolete REQ, all downstream trace links break silently. If they leave it in place, auditors see requirements that are no longer relevant with no indication of their status.

## Proposed Solution

Introduce a formal **ID lifecycle model** with three new states (DEPRECATED, MODIFIED, SUSPECT) that extends every generative command. The model enables proper specification evolution while preserving full traceability — no ID is ever deleted, every state change is annotated with a reason, and downstream impacts cascade systematically.

### Lifecycle States

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
                                        │  "Parent {ID} deprecated"     │
                                        │  Needs review:                │
                                        │  → Re-parent to superseding ID│
                                        │  → Deprecate (cascade down)   │
                                        │  → Confirm still valid        │
                                        └──────────────────────────────┘
```

### Key Characteristics

1. **Never delete an ID** — This principle is preserved and strengthened. IDs transition between states but are never removed from artifacts. The full history is visible in `git diff`.

2. **Two deprecation types with distinct syntax:**
   - **Supersession:** `[DEPRECATED — Superseded by REQ-NNN]` — The capability continues under a new ID. Downstream artifacts should re-parent to the new ID.
   - **Withdrawal:** `[DEPRECATED — Withdrawn: <reason>]` — The capability is removed entirely. Downstream artifacts should be deprecated or confirmed as still valid through other parent links.

3. **Suspect cascade** — When a parent ID is deprecated, all immediate downstream IDs that trace to it are automatically marked `[SUSPECT — Parent {ID} deprecated]`. Each suspect item must be resolved by the human or the next command invocation: re-parent to the superseding ID, deprecate (which cascades further), or confirm still valid.

4. **Modification-in-place** — When a requirement's content changes but its intent remains, the ID is preserved and content is updated in-place. Downstream artifacts become SUSPECT (content may need adjustment) but are not deprecated.

5. **Standard lifecycle rules section** — Every generative command gains a "Lifecycle Rules" section inserted between the existing "Load existing artifact" step and the "Generate new content" step. The section is identical across all commands (with ID prefix variations), creating a consistent, predictable pattern.

6. **Lifecycle-aware tracing** — The `trace` command gains awareness of lifecycle states: deprecated chains are reported separately, suspect items are flagged for review, and coverage metrics exclude deprecated items from denominators.

7. **Lifecycle-aware impact analysis** — The `impact-analysis` command already reports suspects. With formal lifecycle states, its output becomes directly consumable by downstream commands: "REQ-003 deprecated → mark SYS-002 as SUSPECT."

8. **Lifecycle-aware diffing** — The `diff-requirements.sh` script is extended to detect lifecycle transitions (new deprecations, new suspects, resolved suspects) in addition to content additions and removals.

### User Experience Guarantee: Less Noise, Not More

The lifecycle model is designed to be **invisible during forward development** and **helpful during evolution**:

- **Forward development (building from scratch):** If you never deprecate or modify an existing ID, you never see a lifecycle annotation. The commands work exactly as they do today — preserve and append. Zero new noise.

- **Evolution (changing existing specs):** Today, when upstream artifacts change, downstream artifacts silently become stale. The user gets no signal, no help, and no guidance. The lifecycle model replaces this silence with clear, actionable markers that the commands manage automatically. The user reviews and approves — they don't write annotations by hand.

- **Net effect:** The extension becomes safer to evolve. Teams that previously avoided changing requirements (because the downstream cleanup was manual and error-prone) can now evolve specifications with confidence that nothing is silently stale.

### Operationalization: How It Works in Practice

The lifecycle model is **command-driven, not manual**. The user never writes `[SUSPECT]` or `[DEPRECATED]` annotations by hand. The commands handle all state transitions; the user makes content decisions.

#### The Detection Mechanism

The `acceptance` command already implements the proven pattern for change detection (Step 3: "Detect Incremental Changes"). It uses `diff-requirements.sh` to compare the current `requirements.md` against its last committed version via `git show HEAD:`, classifying each parent REQ as `added`, `modified`, or `removed`.

The lifecycle model **generalizes this diff-based detection to all generative commands**. Each lifecycle-aware command:

1. Reads the parent artifact (e.g., `system-design.md` reads `requirements.md`)
2. Reads its own existing output (e.g., `system-design.md` reads existing `system-design.md`)
3. Compares parent IDs against traced parent links in the existing output
4. Classifies each parent ID as: **unchanged**, **modified** (content changed), **deprecated** (has `[DEPRECATED]` annotation), or **added** (new, no existing child)
5. Applies lifecycle rules: modified/deprecated parents → mark children as `[SUSPECT]`; added parents → generate new children; unchanged parents → preserve children as-is

This comparison is performed by the LLM as part of the command's instruction flow — it is a natural extension of the existing "Load existing artifact" step, not a separate script. The LLM reads both files, understands the trace links, and detects mismatches. For the `acceptance` command specifically, the existing `diff-requirements.sh` script continues to serve as a deterministic accelerator alongside the LLM's comparison.

#### Concrete Scenario: SYS-002 Needs Modification

All V-cycle artifacts have been generated. During implementation, the team discovers that SYS-002 (Sensor Data Acquisition) needs to change its interface from polling to event-driven.

**Step 1 — Modify the upstream artifact.**
The engineer edits `system-design.md` directly, updating SYS-002's content (interface description, data flow). The ID `SYS-002` stays the same. This is a normal `git` edit.

**Step 2 — Assess the blast radius (recommended).**
The engineer runs `impact-analysis.sh --downward SYS-002` to see all downstream artifacts affected. Output:
```
Changed IDs: SYS-002
Suspect Artifacts:
  System Test:    STP-002-A, STP-002-B
  Architecture:   ARCH-003
  Integration:    ITP-003-A
  Module:         MOD-005
  Unit Test:      UTP-005-A, UTP-005-B
```
This tells the engineer which commands to re-run and in what order.

**Step 3 — Re-run downstream commands, one level at a time.**

The engineer re-runs `/speckit.v-model.system-test`. The command:
- Reads `system-design.md` → detects SYS-002's content differs from what STP-002-A/B were testing
- Marks STP-002-A as `[SUSPECT — Parent SYS-002 modified]`
- Proposes updated test content that aligns with SYS-002's new interface
- The engineer **reviews the proposal and approves** (or edits)
- The suspect annotation is resolved: STP-002-A gets updated content, annotation removed

The engineer then re-runs `/speckit.v-model.architecture-design`. Same process for ARCH-003. If ARCH-003's content changes, the engineer continues to `integration-test`, `module-design`, `unit-test` — each level resolving its suspects before feeding the next.

**Step 4 — Verify resolution.**
Once all downstream commands have been re-run, the engineer runs `impact-analysis.sh --downward SYS-002` again. If all suspects are resolved, the output shows zero suspect artifacts. The `trace` command confirms full coverage with no suspect items.

#### Concrete Scenario: REQ-003 Is No Longer Needed

Product decides to descope a feature. REQ-003 must be retired.

**Step 1 — Deprecate in the upstream artifact.**
The engineer re-runs `/speckit.v-model.requirements` with updated input (e.g., a modified `spec.md` that no longer includes the capability). The command:
- Detects that REQ-003's parent capability is gone
- Marks REQ-003 as `[DEPRECATED — Withdrawn: Feature descoped per product decision]`
- Does NOT delete REQ-003 — it remains in `requirements.md` with the annotation

**Step 2 — Cascade downstream.**
The engineer re-runs `/speckit.v-model.acceptance`. The command:
- Reads `requirements.md` → sees REQ-003 is `[DEPRECATED]`
- Marks ATP-003-A, ATP-003-B, SCN-003-A as `[SUSPECT — Parent REQ-003 deprecated]`
- Proposes deprecating all three (since the parent is withdrawn, not superseded)
- The engineer reviews: "Yes, deprecate all three."
- The command marks them as `[DEPRECATED — Withdrawn: Parent REQ-003 withdrawn]`

The engineer continues through `system-design` → `system-test` → `architecture-design` → etc. At each level, the command detects the deprecated parent and proposes deprecation or re-parenting for the children. The engineer approves at each step.

**Step 3 — Verify.**
The `trace` command shows REQ-003 and its entire downstream chain as deprecated. Coverage metrics exclude deprecated items from denominators — the team's coverage percentage is unaffected by the retired requirement.

#### Key Workflow Properties

1. **One level at a time** — Each command resolves suspects at its own level. There is no single "cascade everything" button because each level requires human judgment about whether to re-parent, deprecate, or confirm.

2. **Commands do the bookkeeping** — The user never writes lifecycle annotations manually. Commands detect, propose, and annotate. The user reviews and makes content decisions.

3. **Impact analysis is the map** — Run it before cascading to know the full blast radius. Run it after to confirm all suspects are resolved.

4. **Git is the audit trail** — Every lifecycle transition is a `git diff`. Deprecated items stay in the file with their annotation. Auditors can trace exactly when and why each change happened.

5. **No new scripts required for detection** — The LLM performs the parent-child comparison as part of its existing instruction flow. The `diff-requirements.sh` script remains a useful accelerator for the `acceptance` command but is not required for the general lifecycle mechanism.

### The Lifecycle Rules Section (Added to All 10 Generative Commands)

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

### Command-Specific Changes

| Command | ID Prefix | Parent Artifact | Changes |
|---------|-----------|----------------|---------|
| `requirements` | REQ | `spec.md` | + Deprecation support + modification-in-place |
| `acceptance` | ATP/SCN | `requirements.md` | + Suspect detection from parent REQ (extend existing `[DEPRECATED]` support with supersession syntax) |
| `system-design` | SYS | `requirements.md` | + Suspect detection from parent REQ + deprecation |
| `system-test` | STP/STS | `system-design.md` | + Suspect detection from parent SYS + deprecation |
| `architecture-design` | ARCH | `system-design.md` | + Suspect detection from parent SYS + deprecation |
| `integration-test` | ITP/ITS | `architecture-design.md` | + Suspect detection from parent ARCH + deprecation |
| `module-design` | MOD | `architecture-design.md` | + Suspect detection from parent ARCH + deprecation |
| `unit-test` | UTP/UTS | `module-design.md` | + Suspect detection from parent MOD + deprecation |
| `trace` | N/A | All artifacts | + Deprecation-aware coverage (exclude deprecated from denominators) + suspect summary |
| `impact-analysis` | N/A | All artifacts | + Lifecycle-aware output format (already reports suspects; gains formal state syntax) |

### Interaction with Feature 006a (Domain Overlay Architecture)

The lifecycle model and domain overlay architecture are complementary but independent:

- **006a** changes WHERE content lives (base vs. overlay files)
- **006b** changes HOW IDs evolve (append-only → lifecycle states)
- Both features can be implemented in either order
- The lifecycle model applies equally to base command IDs and overlay-enriched IDs
- During M0.5 Wave 2 (evolving existing features), both features work together: domain-specific IDs are deprecated via lifecycle rules, and domain-agnostic replacements are generated from cleaned base commands

### What This Feature Does NOT Include

1. **Automated suspect resolution** — The lifecycle model MARKS suspects; it does not automatically resolve them. Resolution requires human judgment (or the next command invocation with human review). An agent should never autonomously decide that a suspect item is still valid for safety-critical artifacts.

2. **Version history within artifacts** — The lifecycle model tracks current state only. Full history is available through `git log` on the artifact file. There is no embedded changelog or revision table within the Markdown artifact.

3. **Lifecycle state persistence outside artifacts** — States are embedded in the Markdown text itself (as inline annotations). There is no external database or state file. Git is the system of record.

4. **Domain overlay architecture** — Moving domain-specific content to overlay files is Feature 006a, not this feature.

5. **Bridge commands** — The `v-model.plan`, `v-model.tasks`, and `v-model.implement` commands are M1 (v0.7.0) scope. They will be born lifecycle-aware since the model will exist by then.

6. **Multi-level cascade automation** — When REQ-003 is deprecated, SYS-002 becomes SUSPECT. If SYS-002 is then also deprecated, ARCH-003 becomes SUSPECT. This multi-level cascade is supported conceptually but each level requires a separate command invocation with human review — there is no single-command "cascade deprecation through all levels" action.
