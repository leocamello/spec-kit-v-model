---
title: ID Lifecycle Model
description: How V-Model IDs evolve through ACTIVE, DEPRECATED, MODIFIED, and SUSPECT states to support specification evolution without losing traceability.
---

# ID Lifecycle Model

The ID Lifecycle Model enables V-Model specifications to evolve over time — requirements can be deprecated, replaced, or modified — while preserving full traceability. No ID is ever silently deleted. Every change leaves an auditable trail.

---

## The Problem

Before v0.6.0, all V-Model commands used an **append-only model**: preserve existing IDs, never modify them, never delete them. This worked for forward development and incremental growth, but blocked specification evolution.

Consider what happens when a requirement becomes obsolete:

- The requirement could not be properly retired — it remained ACTIVE even though it no longer reflected the system
- Downstream artifacts (acceptance tests, system design, architecture modules) stayed linked to a dead requirement, silently giving false coverage
- There was no mechanism to mark dependent artifacts as needing review
- "Update the spec" meant adding new requirements but leaving the old ones dangling

The append-only model created ghost requirements: IDs that existed in the traceability matrix, passed coverage checks, and counted toward completeness — but referred to functionality that had been removed or replaced.

---

## Lifecycle States

Every V-Model ID moves through four states:

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
                    │  new content,│    │  │ Superseded by {X}-NNN   │ │
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

| State | Meaning | Action Required |
|-------|---------|----------------|
| **ACTIVE** | Current and must be satisfied by downstream artifacts | None — normal state |
| **MODIFIED** | Same ID, content updated in-place; downstream may be stale | Review downstream artifacts for accuracy |
| **DEPRECATED** | No longer current; either superseded or withdrawn | Downstream items become SUSPECT automatically |
| **SUSPECT** | Parent ID was deprecated; this item needs review | Re-parent, deprecate, or confirm still active |

---

## Deprecation Types

There are two ways to deprecate an ID, each with a specific syntax:

### Supersession

Use when the ID is **replaced by a new item**. The capability continues, but under a new, updated ID.

```markdown
REQ-001 [DEPRECATED — Superseded by REQ-007]
~~The system shall authenticate users via ISO 26262 ASIL-B security checks.~~
```

The superseding ID (REQ-007) contains the updated, domain-agnostic replacement. Downstream items tracing to REQ-001 should be re-parented to REQ-007.

### Withdrawal

Use when the ID is **removed entirely** with a documented reason.

```markdown
REQ-004 [DEPRECATED — Withdrawn: Requirement superseded by domain overlay architecture; safety classification now determined by v-model-config.yml domain field]
~~The system shall embed ISO 26262 safety tables in all output artifacts.~~
```

The requirement is gone. Downstream items tracing to REQ-004 should be deprecated (if the capability is removed) or re-parented to a different active requirement.

---

## Suspect Cascade

When a parent ID is deprecated, **all downstream IDs that trace to it automatically become SUSPECT**. This cascade propagates down the entire V-chain.

```
REQ-001 [DEPRECATED — Superseded by REQ-007]
  │
  ├── ATP-001-A [SUSPECT — Parent REQ-001 deprecated]
  ├── ATP-001-B [SUSPECT — Parent REQ-001 deprecated]
  │
  ├── SYS-002 [SUSPECT — Parent REQ-001 deprecated]
  │     └── STP-002-A [SUSPECT — Parent SYS-002 suspect]
  │
  └── ARCH-003 [SUSPECT — Parent SYS-002 suspect]
        ├── ITP-003-A [SUSPECT — Parent ARCH-003 suspect]
        └── MOD-005 [SUSPECT — Parent ARCH-003 suspect]
              └── UTP-005-A [SUSPECT — Parent MOD-005 suspect]
```

Each SUSPECT item must be **resolved** before the artifact chain is considered clean:

| Resolution | When to use |
|-----------|-------------|
| **Re-parent** | The capability continues under the superseding ID — update the traceability link |
| **Deprecate** | The capability is removed — propagate deprecation down |
| **Confirm active** | The item is still valid despite the parent change — document the rationale |

---

## Lifecycle Rules

Each V-Model command that supports lifecycle operations follows five rules:

**Rule 1: Never delete an ID**

IDs are permanent identifiers. Mark as `[DEPRECATED]`, never remove the entry. This preserves the audit trail — reviewers can see what existed and why it changed.

**Rule 2: Two deprecation types**

- `[DEPRECATED — Superseded by {ID}]` — Replaced by a new item
- `[DEPRECATED — Withdrawn: {reason}]` — Removed with justification

**Rule 3: Suspect detection**

When a command runs and detects that a parent ID (from the upstream artifact) is deprecated, it marks the linked item as:

```markdown
ATP-001-A [SUSPECT — Parent REQ-001 deprecated]
```

**Rule 4: Suspect resolution**

For each suspect item, the command (or human reviewer) must choose:

- Re-parent to the superseding ID (if the capability continues)
- Deprecate (if the capability is removed — cascade propagates down)
- Confirm active (if still valid despite parent change — document rationale)

**Rule 5: Modified items update in-place**

When a requirement's content changes but the ID remains valid, update the content in-place and preserve the ID. Downstream artifacts still trace to the same ID — no re-parenting needed, but a review is warranted to confirm the content change doesn't invalidate downstream work.

---

## Example: Evolving a Requirement

### Starting point

`requirements.md` contains:

```markdown
## REQ-001
The system shall authenticate users using ISO 26262 ASIL-B security classification.

## REQ-002
The system shall log all authentication events.
```

`acceptance-plan.md` contains:

```markdown
## ATP-001-A (traces REQ-001)
Verify ASIL-B security classification is applied to all authentication flows.

## ATP-002-A (traces REQ-002)
Verify authentication events are logged with timestamp and user ID.
```

### The change

REQ-001 referenced "ISO 26262 ASIL-B" directly — a safety domain reference that should live in the overlay, not the base requirement. The spec is updated to use domain-agnostic language.

### After lifecycle evolution

`requirements.md` becomes:

```markdown
## REQ-001 [DEPRECATED — Superseded by REQ-007]
~~The system shall authenticate users using ISO 26262 ASIL-B security classification.~~

## REQ-002
The system shall log all authentication events.

## REQ-007
The system shall authenticate users using functional safety classification appropriate
to the configured domain (see v-model-config.yml).
```

`acceptance-plan.md` becomes:

```markdown
## ATP-001-A [SUSPECT — Parent REQ-001 deprecated]
~~Verify ASIL-B security classification is applied to all authentication flows.~~
<!-- Resolution needed: re-parent to REQ-007 or deprecate -->

## ATP-001-B (traces REQ-007) [NEW]
Verify functional safety classification is applied according to the configured domain.

## ATP-002-A (traces REQ-002)
Verify authentication events are logged with timestamp and user ID.
```

ATP-001-A is now SUSPECT (its parent REQ-001 is deprecated). The human reviewer decides to supersede it with ATP-001-B that traces to REQ-007. ATP-001-A is then formally deprecated:

```markdown
## ATP-001-A [DEPRECATED — Superseded by ATP-001-B]
~~Verify ASIL-B security classification is applied to all authentication flows.~~
```

The traceability is preserved. Auditors can see the full evolution history: what was deprecated, why, and what replaced it.

---

## Integration with Commands

The lifecycle model is supported by all 8 generative commands:

| Command | Lifecycle Capability |
|---------|---------------------|
| `requirements` | Deprecation + modification-in-place |
| `acceptance` | Suspect detection from parent REQ + deprecation |
| `system-design` | Suspect detection from parent REQ + deprecation |
| `system-test` | Suspect detection from parent SYS + deprecation |
| `architecture-design` | Suspect detection from parent SYS + deprecation |
| `integration-test` | Suspect detection from parent ARCH + deprecation |
| `module-design` | Suspect detection from parent ARCH + deprecation |
| `unit-test` | Suspect detection from parent MOD + deprecation |

### Invoking evolution mode

Pass evolution context when running a command on existing artifacts:

```
/speckit.v-model.requirements --evolve
  $ARGUMENTS: "REQ-001 is deprecated — superseded by REQ-007 (see updated spec.md).
               Run suspect detection on all ATPs tracing to REQ-001."
```

The command reads the existing artifact, applies lifecycle rules, marks deprecations and suspects, and produces the evolved output. It does not generate from scratch — it evolves in-place.

!!! tip "Use impact-analysis first"
    Before starting an evolution run, use `/speckit.v-model.impact-analysis --downward REQ-001` to understand the full blast radius. This tells you exactly which downstream artifacts will become SUSPECT before you make the first change.
