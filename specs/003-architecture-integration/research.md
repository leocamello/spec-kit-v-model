# Research: Architecture Design ↔ Integration Testing

**Branch**: `003-architecture-integration`
**Date**: 2026-02-21
**Status**: Complete

## Research Questions

### RQ-1: How should many-to-many SYS↔ARCH relationships be represented in plaintext Markdown?

**Finding**: At the architecture level, one `SYS-NNN` may decompose into multiple `ARCH-NNN` modules, and one `ARCH-NNN` may serve multiple `SYS-NNN` components (e.g., a logging module serving both the command and the validation script). This mirrors the v0.2.0 many-to-many REQ↔SYS pattern.

**Decision**: Each `ARCH-NNN` module in the Logical View includes an explicit "Parent System Components" field with a comma-separated list of `SYS-NNN` identifiers. Infrastructure modules use `[CROSS-CUTTING]` tag instead of a `SYS-NNN` reference, with a rationale field explaining the module's purpose.

**Rationale**: Consistent with v0.2.0's "Parent Requirements" pattern (RQ-1). Keeps traceability data in the Markdown file. The `[CROSS-CUTTING]` tag addresses the "Derived Module Friction" identified in the spec Red Team review — utility modules (Logger, Thread Pool, Secrets Manager) are legitimate architecture components that don't trace to a single SYS.

**Alternatives considered**:
- Force all ARCH modules to have a SYS parent: Rejected — would artificially inflate SYS count with "utility subsystem" wrappers.
- Separate cross-cutting module section: Rejected — fragments the Logical View; cross-cutting modules should appear inline with business-logic modules for complete architecture picture.

### RQ-2: What ISO/IEC/IEEE 42010 + Kruchten 4+1 views are mandatory for the architecture-design command?

**Finding**: IEEE 42010:2011 mandates architecture descriptions organized by viewpoints. Kruchten's 4+1 View Model (1995) provides a well-established decomposition for software architecture. For the architecture level (decomposing SYS components into software modules), four views provide complete coverage:

1. **Logical View (Component Breakdown)** — ARCH-NNN modules with parent SYS references, descriptions, and cross-cutting tags. Directly extends the Decomposition View from system-design.
2. **Process View (Dynamic Behavior)** — Runtime interactions between ARCH modules: sequences, concurrency, thread management. Mermaid sequence diagrams provide renderable, auditable visualizations.
3. **Interface View (Strict API Contracts)** — Every ARCH-NNN defines inputs, outputs, and exceptions. This is the primary driver for Interface Contract Testing.
4. **Data Flow View (Data Control Flow)** — Data transformation chains tracing input → intermediate formats → output. Feeds Data Flow Testing.

**Decision**: All four views mandatory in `architecture-design.md`. Template enforces section headers for each.

**Rationale**: The 4+1 model's "Scenarios" view is covered by the integration test command (ITP/ITS scenarios exercise the architecture views). Four views cover decomposition, dynamic behavior, contracts, and data flow — the four dimensions needed for integration test generation.

**Source**: ISO/IEC/IEEE 42010:2011 §5 (Architecture viewpoints), Kruchten 1995 (4+1 View Model), ISO 26262-6 §8 (Software unit design and implementation).

### RQ-3: What ISO 29119-4 integration test techniques are mandatory?

**Finding**: Integration testing per ISO 29119-4 focuses on seams and handshakes between modules, not internal logic. Four techniques map directly to the four architecture views:

1. **Interface Contract Testing** — Verifies ARCH modules honor their published API contracts from the Interface View. Originally termed "Consumer-Driven Contract Testing (CDCT)" but renamed to remain framework-agnostic (Red Team Critique 2 — CDCT implies specific tooling like Pact).
2. **Data Flow Testing** — Validates end-to-end data transformation chains from the Data Flow View.
3. **Interface Fault Injection** — Tests graceful failure when modules receive malformed payloads, timeouts, or unavailable dependencies. Driven by Interface View error contracts + Process View timing.
4. **Concurrency & Race Condition Testing** — Verifies mutex strategies, resource contention, queue ordering from the Process View concurrency model.

**Decision**: Each `ITP-NNN-X` test case must identify its technique by name and anchor to a specific architecture view. Integration test scenarios (ITS) use module-boundary-oriented BDD language.

**Rationale**: Named techniques force rigorous test design. The technique-to-view linkage creates a traceable chain: View → Technique → Test Case → Scenario. The language mandate prevents regression to user-journey phrasing.

**Source**: ISO/IEC/IEEE 29119-4:2021, ISO 29119-3:2021.

### RQ-4: How should ASIL decomposition and other safety-critical architecture sections be gated?

**Finding**: At the architecture level, safety-critical standards introduce additional analysis requirements:
- **ASIL Decomposition** (ISO 26262): A parent SYS-NNN at ASIL-D can decompose into ARCH modules with lower ASIL ratings if independence is proven (e.g., SYS ASIL-D → ARCH-001 ASIL-D + ARCH-002 ASIL-A).
- **Defensive Programming** (ISO 26262 + DO-178C): Invalid inputs from one module caught before corrupting the next.
- **Temporal & Execution Constraints** (DO-178C): Watchdog timers, execution order, deadlock prevention.
- **SIL/HIL Compatibility** (ISO 26262 + DO-178C): Integration test scenarios executable in Software/Hardware-in-the-Loop environments.
- **Resource Contention** (ISO 26262 + DO-178C): Prove modules don't exhaust shared resources during interaction.

**Decision**: Gate via existing `v-model-config.yml` `domain` field, consistent with v0.2.0 (RQ-4). Architecture-design command adds ASIL Decomposition, Defensive Programming, and Temporal Constraints sections. Integration-test command adds SIL/HIL Compatibility and Resource Contention sections.

**Rationale**: Extends the v0.2.0 gating pattern. No new config fields needed — the existing `domain` field already activates safety-critical sections at the system level.

### RQ-5: How should the validate-architecture-coverage.sh script structure differ from validate-system-coverage.sh?

**Finding**: The architecture-level validation has unique requirements:
1. **Three-file input** instead of v0.2.0's implicit directory scan: `system-design.md`, `architecture-design.md`, `integration-test.md` as positional arguments.
2. **Partial execution**: The script must validate forward-only (SYS→ARCH) when `integration-test.md` doesn't exist yet — the architecture-design command runs before integration-test.
3. **Cross-cutting handling**: `[CROSS-CUTTING]` modules have no SYS parent but must still appear in coverage validation for the backward direction (ARCH→ITP).
4. **ID lineage**: Regex can extract ARCH-NNN from ITP-NNN-X strings (direct parent), but SYS resolution requires file lookup due to many-to-many.

**Decision**: Three positional file arguments, `--json` output flag, partial execution support. Script validates forward (SYS→ARCH), backward (ARCH→ITP→ITS), and orphan detection. Cross-cutting modules are included in backward coverage. Exit code 0/1 for pass/fail.

**Rationale**: Positional arguments (vs directory scan) give the calling command explicit control over which files to validate. Partial execution enables the progressive validation pattern established in v0.2.0 (validate what exists, don't fail on missing future artifacts).

### RQ-6: How should Matrix C extend the traceability matrix?

**Finding**: Matrix C (Integration Verification) adds the architecture layer: `SYS → ARCH → ITP → ITS`. Key design decisions:
1. Each SYS cell includes parent REQ references in parentheses for end-to-end traceability (Red Team Critique 3 — prevents auditors from needing to cross-reference Matrix B).
2. Cross-cutting ARCH modules appear as pseudo-rows with `N/A (Cross-Cutting)` in the SYS column.
3. Matrix C is produced independently alongside A and B, not merged into a single wide table.
4. When architecture artifacts are absent, the trace command produces v0.2.0 output (A + B only) with no warning — backward compatible.

**Decision**: Matrix C as a separate table in `traceability-matrix.md` with independent coverage percentages. Progressive: A alone, A+B, A+B+C depending on available artifacts.

**Rationale**: Extends v0.2.0's dual-matrix pattern (RQ-6) to a triple-matrix output. Separate tables prevent an 8+ column monster. Independent coverage percentages per matrix maintain audit independence.

### RQ-7: How should the build-matrix.sh script parse architecture-level artifacts for Matrix C?

**Finding**: The v0.2.0 `build-matrix.sh` bug (discovered during Step 7 of this feature's dogfooding) revealed that SYS-NNN parsing must be scoped to the Decomposition View section only. The same principle applies to ARCH-NNN parsing — must be scoped to the Logical View section of `architecture-design.md`.

**Decision**: Section-boundary-aware parsing. The script detects `## Logical View` and `## Process View` (or next `##` header) to limit ARCH extraction to the correct table. Same pattern as the Decomposition View fix.

**Rationale**: The v0.2.0 bug showed that architecture documents with multiple tables containing the same ID prefix cause overwrites. Section scoping eliminates this class of bugs.

### RQ-8: How should Mermaid diagram syntax be validated in the evaluation suite?

**Finding**: LLMs frequently generate broken Mermaid syntax (Red Team Critique 4). The Process View mandates Mermaid sequence diagrams for runtime interactions. Broken diagrams silently pass coverage validation (which only checks IDs).

**Decision**: The evaluation suite (DeepEval structural evals) must verify syntactic validity of generated Mermaid diagrams. This is a structural check, not a semantic one — verify the diagram parses, not that it's "good architecture."

**Rationale**: A broken Mermaid diagram renders as raw text in GitHub/VSCode, making the architecture document useless for visual review. Treating broken syntax as a structural failure catches this before PR review.

**Alternatives considered**:
- Runtime Mermaid CLI validation: Rejected — adds a heavy dependency (Mermaid CLI is a Node.js tool). Regex-based syntax checks are sufficient for catching common errors.
- Manual review only: Rejected — human reviewers may miss subtle syntax errors; automated checks catch them deterministically.
