# Feature 005b: Impact Analysis Command

## Problem Statement

When a requirement, design element, or test case changes in a V-Model project, engineers must manually identify all downstream and upstream artifacts affected by the change. In regulated industries (medical devices, automotive, aerospace), missing an affected artifact during re-validation can result in audit findings, delayed releases, or safety incidents. This manual "blast-radius" search is error-prone, time-consuming, and does not scale.

## Proposed Solution

Add an `/speckit.v-model.impact-analysis` command that performs **deterministic, bidirectional traversal** of the V-Model ID graph to produce an impact report. Given one or more changed IDs, the script traces through all V-Model artifacts and identifies every artifact that is directly or transitively affected.

### Key Capabilities

1. **Downward traversal (`--downward`, default)**: Given a changed design ID (e.g., `REQ-014`), trace to all downstream test cases, design elements, and hazards that depend on it. Every downstream artifact is flagged as "Suspect" for re-validation.

2. **Upward traversal (`--upward`)**: Given a changed implementation-level ID (e.g., `MOD-004`), trace upward through the V-Model to identify which requirements are affected. Answers: "which user requirements are unverified if this module is redesigned?"

3. **Full traversal (`--full`)**: Combines downward and upward traversal from the given ID. Shows the complete blast radius in both directions.

### Use Cases

- A product manager changes REQ-014 → engineer runs `impact-analysis --downward REQ-014` to find all affected SYS, ARCH, MOD, tests, and HAZ entries
- A hardware component goes end-of-life → `impact-analysis --upward MOD-004` reveals which REQs are impacted
- An integration test consistently fails → `impact-analysis --upward ITS-002-A1` shows which user requirements are currently unverified
- A system component is redesigned → `impact-analysis --full SYS-003` shows both upstream REQs and downstream ARCH/MOD/tests

### Output

The command produces `impact-report.md` containing:
- **Changed ID(s)** with their artifact type and description
- **Suspect artifact list** organized by V-Model level (REQ → SYS → ARCH → MOD → HAZ, plus all test layers)
- **Blast radius statistics** (count of affected artifacts per level)
- **Suggested re-validation order** (bottom-up for downward traversal, top-down for upward)

### Implementation Notes

- **Purely deterministic** — script-only, no AI generation. Uses regex parsing of existing V-Model markdown files.
- **No new ID prefixes** — works entirely with existing ID graph (REQ, SYS, ARCH, MOD, HAZ, ATP, STP, ITP, UTP, SCN, STS, ITS, UTS)
- **Cross-cutting** — can be invoked after any V-Model layer, at any time
- **JSON output** (`--json`) for machine consumption and CI integration
- **Multi-ID input** — accepts multiple changed IDs in a single invocation
- **Bash + PowerShell parity** — `impact-analysis.sh` and `impact-analysis.ps1`

## Target Audience

- Engineers managing requirement changes in regulated software projects
- QA teams identifying regression testing scope after design changes
- Safety officers tracing the impact of component failures on system-level requirements

## Success Criteria

- Given any valid V-Model ID, the script correctly identifies all directly and transitively affected artifacts
- Downward, upward, and full traversal modes produce correct and complete results
- The script handles missing artifacts gracefully (e.g., if architecture-design.md doesn't exist yet, traversal stops at the system level)
- JSON output is parseable and contains all suspect artifact IDs
- Bash and PowerShell implementations produce identical results
