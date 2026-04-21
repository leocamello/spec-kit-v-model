---
description: Run deterministic impact analysis to identify all V-Model artifacts affected by a change to one or more IDs.
handoffs:
  - label: View Traceability Matrix
    agent: speckit.v-model.trace
    prompt: Build the full traceability matrix to see current coverage
    send: true
  - label: Run Peer Review
    agent: speckit.v-model.peer-review
    prompt: Review the affected artifacts identified by impact analysis
scripts:
  sh: scripts/bash/impact-analysis.sh
  ps: scripts/powershell/impact-analysis.ps1
---

## User Input

```text
$ARGUMENTS
```

## Goal

Run **deterministic impact analysis** on V-Model artifacts to identify the blast radius of a change. This is a **script-only command** — no AI generation is needed. The script scans all markdown files in the V-Model directory, builds an ID dependency graph, and traverses it from the specified changed IDs to produce an impact report.

This command implements the **IEEE 828-2012 §6.3 Configuration Control** process: when a configuration item changes, the impact on all related configuration items must be evaluated before the change is approved. The Re-validation Order in the output directly supports IEEE 828's Change Control Board (CCB) review by providing the ordered list of artifacts requiring re-validation, in dependency order.

## How to Use

This command is invoked directly via the script, not through AI generation:

### Bash
```bash
# Downward traversal (default): what depends on REQ-001?
scripts/bash/impact-analysis.sh --downward REQ-001 specs/<feature>/v-model

# Upward traversal: what does MOD-003 depend on?
scripts/bash/impact-analysis.sh --upward MOD-003 specs/<feature>/v-model

# Full traversal: complete blast radius of SYS-002
scripts/bash/impact-analysis.sh --full SYS-002 specs/<feature>/v-model

# JSON output to stdout
scripts/bash/impact-analysis.sh --json --downward REQ-001 REQ-002 specs/<feature>/v-model

# Custom output path
scripts/bash/impact-analysis.sh --output /tmp/report.md REQ-001 specs/<feature>/v-model
```

### PowerShell
```powershell
# Downward traversal (default)
scripts/powershell/impact-analysis.ps1 -Downward -Ids REQ-001 -VModelDir specs/<feature>/v-model

# Upward traversal
scripts/powershell/impact-analysis.ps1 -Upward -Ids MOD-003 -VModelDir specs/<feature>/v-model

# Full traversal with JSON output
scripts/powershell/impact-analysis.ps1 -Full -Json -Ids SYS-002 -VModelDir specs/<feature>/v-model
```

## Output

The script produces an **Impact Analysis Report** containing:

1. **Changed IDs** — The IDs specified by the user with their V-Model level
2. **Suspect Artifacts** — All affected IDs organized by V-Model level
3. **Lifecycle State Detection** — Any `[DEPRECATED]`, `[SUSPECT]`, or `[MODIFIED]` tags found on the changed IDs or their downstream dependents. The report distinguishes between:
   - **Already deprecated** — the changed ID carries a `[DEPRECATED — Superseded by X-NNN]` or `[DEPRECATED — Withdrawn: <reason>]` tag; downstream artifacts inheriting from it should also be deprecated or re-parented
   - **Already suspect** — the changed ID or a dependent carries a `[SUSPECT — Parent X-NNN {deprecated|modified}]` tag indicating an unresolved lifecycle review
   - **Newly impacted** — artifacts that are not yet tagged but trace to a changed ID; these are candidates for `[SUSPECT]` tagging in their respective V-Model commands
4. **Blast Radius** — Statistics showing the count of affected artifacts per level, broken down by lifecycle state (active, deprecated, suspect)
5. **Re-validation Order** — Ordered list of artifacts that should be re-validated, excluding fully deprecated chains (all downstream artifacts already deprecated)

### Traversal Modes

| Mode | Flag | Description |
|------|------|-------------|
| Downward | `--downward` (default) | Traces from changed IDs to all downstream dependents |
| Upward | `--upward` | Traces from changed IDs to all upstream parents |
| Full | `--full` | Both directions, with upstream/downstream separation |

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Analysis completed successfully |
| 1 | Error (invalid args, no artifacts, no valid IDs) |

### Lifecycle-Aware Analysis

The impact analysis script detects lifecycle tags when traversing the dependency graph:

- When a **changed ID** is already `[DEPRECATED]`, the report notes that its downstream chain should already be deprecated or re-parented. Any downstream artifacts that are still `Active` are flagged as **"unresolved deprecation cascade"**.
- When a **changed ID** is `[MODIFIED]` (content updated in-place), all direct downstream dependents are listed as candidates for `[SUSPECT]` tagging.
- When a **downstream artifact** already carries a `[SUSPECT]` tag, the report notes it as **"pre-existing suspect"** and includes the original suspect reason.
- The **JSON output** (`--json`) includes a `lifecycle` object:
  ```json
  {
    "lifecycle": {
      "deprecated_changed": ["REQ-003"],
      "suspect_found": ["SYS-005", "ARCH-007"],
      "unresolved_cascades": [
        {"source": "REQ-003", "active_dependents": ["ATP-003-A", "SYS-005"]}
      ]
    }
  }
  ```

## Quality Criteria

- The script is **deterministic**: same inputs always produce the same output
- The script is **read-only**: no existing V-Model artifacts are modified
- The script uses **no external tooling** beyond standard Bash/PowerShell utilities
- The script completes within **10 seconds** for projects with up to 20 files and 500 IDs
- Bash and PowerShell produce **identical JSON structure** and exit codes
- The Re-validation Order satisfies the **IEEE 828-2012 §6.3.3** requirement that a change impact assessment identifies all affected configuration items — in dependency order — prior to change approval

## Governing Standards

This command is governed by the following standard for change impact analysis:

| Standard | Full Name | Role in this Command |
|----------|-----------|----------------------|
| **IEEE 828-2012** | IEEE Standard for Configuration Management in Systems and Software Engineering | Configuration management governance: defines the change management process — change request submission, impact evaluation, change control board review, and change disposition. The suspect-artifact classification, propagation scope, and rework prioritization in this command are grounded in IEEE 828 §6.3 (Configuration Control). |

> **Domain extensions:** If a domain overlay is loaded, additional domain-specific change impact requirements apply (e.g., ISO 26262-8 §8 Safety-Impacted Item Assessment and ASIL re-evaluation, DO-178C §7 Software Change Control with problem reporting, IEC 62304 §6 Software Maintenance and §8 CM per safety class). These are defined in the domain overlay files.
