# Contract: ARCH-015 — Hook Registrar

- **Type**: REUSE-CORE (declarative YAML)
- **Classification**: REUSE-CORE
- **Realised by**: YAML entries in `extension.yml`; registration handled by `CommandRegistrar` in spec-kit core's `src/specify_cli/extensions.py`. This feature ships **no new registration code** (REQ-CN-001, REQ-NF-006).
- **Parent system component**: SYS-011 (Hook Registration)
- **Child modules**: MOD-020 (Hook Registrar)
- **Parent requirements**: REQ-IF-003, REQ-IF-005, REQ-NF-006

## YAML entries (D-007)

```yaml
hooks:
  after_specify:
    command: speckit.v-model.requirements
  before_implement:
    command: speckit.v-model.trace
  after_implement:
    command: speckit.v-model.trace
```

The existing `after_tasks: speckit.v-model.trace` entry is preserved unchanged.

## Preconditions

- `extension.yml` exists at the project root.
- Spec-kit core is present (provides `CommandRegistrar`).

## Postconditions

- The three new hooks are registered idempotently on the next CLI invocation; re-runs do not duplicate entries.

## Side-effects

None at this feature's level — registration is performed entirely by core.

## Error path

Schema-invalid YAML ⇒ core's `CommandRegistrar` rejects at install time (HAZ-019 — hook not registered). This feature contributes only the YAML payload.

## Verification

- ITP for hook firing (BATS test that exercises `after_specify` → `v-model.requirements`)
- ATP-IF-003-A, ATP-IF-005-A
