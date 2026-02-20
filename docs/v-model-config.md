# V-Model Configuration Reference

## File: `v-model-config.yml`

The optional configuration file controls extension behavior at the project level. Place it in the repository root.

## Schema

```yaml
# v-model-config.yml
domain: ""  # Regulated domain identifier (optional)
```

## Fields

### `domain`

**Type**: String (enum)
**Default**: `""` (empty — non-regulated)
**Required**: No

Controls safety-critical section generation in system design and system test commands.

| Value | Standard | System Design Extras | System Test Extras |
|-------|----------|---------------------|--------------------|
| `""` (empty) | None | — | — |
| `iso_26262` | ISO 26262 (Automotive) | FFI analysis, Restricted Complexity | MC/DC targets, WCET verification |
| `do_178c` | DO-178C (Aerospace) | FFI analysis, Restricted Complexity | MC/DC targets, WCET verification |
| `iec_62304` | IEC 62304 (Medical Devices) | FFI analysis, Restricted Complexity | MC/DC targets, WCET verification |

### Behavior

- **Config absent**: Treated as `domain: ""`. No safety-critical sections generated.
- **Config present, domain empty**: Same as absent — non-regulated mode.
- **Config present, domain set**: Commands generate additional safety-critical sections specific to the regulatory standard.

### Example

```yaml
# For an automotive ADAS project
domain: "iso_26262"
```

This triggers:
- `/speckit.v-model.system-design`: Adds **Freedom from Interference** (FFI) and **Restricted Complexity** sections
- `/speckit.v-model.system-test`: Adds **Structural Coverage** (MC/DC) and **Resource Usage Testing** (WCET, stack, heap) sections

### Rationale

Safety-critical analysis sections are mandatory under ISO 26262 and DO-178C but create noise for non-regulated projects. The opt-in approach keeps the default experience clean while enabling full regulatory compliance when needed. The config file is Git-tracked, making the decision auditable (Constitution Principle IV).
