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
