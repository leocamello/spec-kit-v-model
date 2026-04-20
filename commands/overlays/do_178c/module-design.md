# Module Design — DO-178C Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: do_178c`.
> It provides domain-specific safety-critical module design sections for the base `module-design` command.
> Content in this overlay replaces the generic "Safety-Critical Sections" in the base command when this domain is active.

## Complexity Constraints (DO-178C §6.3.4 + CERT-C / DO-333)

For each `MOD-NNN`, document the complexity constraints required for DO-178C §6.3.4 ("Low-Level Requirements") and the project's coding standard compliance:

| Module | DAL | Cyclomatic Complexity Limit | Coding Standard | Deviations |
|--------|-----|----------------------------|-----------------|------------|
| MOD-NNN | DAL [A–E] | ≤ [10 / 15 / 20] per function | [CERT-C / MISRA C:2012 / Project Standard] | [Deviation ID + rationale] |

**DAL-dependent Complexity Limits**:
- **DAL A**: Cyclomatic complexity ≤ 10; CERT-C or project-qualified coding standard mandatory; formal proof or structural coverage (MC/DC) for all decisions
- **DAL B**: Cyclomatic complexity ≤ 15; coding standard with documented deviations; decision coverage (DC) at minimum
- **DAL C**: Cyclomatic complexity ≤ 20; coding guidelines applied; statement coverage (SC) at minimum
- **DAL D–E**: Complexity documented; guidelines applied as best practice

**Rules**:
- Coding standard deviations must be documented in the Software Development Plan (SDP) or equivalent deviation log, with tool configuration records referencing DO-330 §5 for tool qualification
- For DO-333 (formal methods supplement): annotate modules where formal proofs replace structural testing

## Memory Management (DO-178C §6.3.3b + §6.3.3c)

For each `MOD-NNN`, document memory management constraints aligned with DO-178C §6.3.3 (software partitioning and resource management):

| Module | DAL | Dynamic Allocation Policy | Stack Estimate | WCET Estimate | Partition |
|--------|-----|--------------------------|----------------|---------------|-----------|
| MOD-NNN | DAL [A–E] | Forbidden / Init-time only / Permitted | [bytes] | [ms] | [ARINC 653 partition or N/A] |

**DAL-dependent Memory Rules**:
- **DAL A–B**: Dynamic memory allocation forbidden after initialization; all allocations statically verified; worst-case execution time (WCET) analysis required for time-critical functions; robust partitioning (ARINC 653) enforced where applicable
- **DAL C**: Dynamic allocation restricted; WCET estimates documented; heap/stack separation verified
- **DAL D–E**: Memory usage documented; dynamic allocation discouraged

**Additional Rules**:
- All loops MUST have provable worst-case termination (DO-178C §6.3.3 prohibits unbounded loops in DAL A–B)
- Stack overflow analysis required for DAL A–B: document maximum call depth and per-frame stack usage
- Resource budgets (memory, CPU time, I/O) must be consistent with system partition boundaries defined in architecture-design.md

## Single Entry/Exit (DO-178C §6.3.4 + DO-178C Advisory — Level A)

For each `MOD-NNN` at DAL A, enforce single entry/exit per DO-178C §6.3.4 guidance and the project's Software Development Plan:

| Module | DAL | Entry Points | Exit Points | Verification Method | Notes |
|--------|-----|-------------|-------------|-------------------|-------|
| MOD-NNN | DAL [A–E] | 1 | 1 | MC/DC / DC / SC | [Rationale for any multiple-exit patterns] |

**Rules**:
- **DAL A**: Strictly one entry and one exit per function strongly recommended; deviations must be justified in the SDP
- **DAL B–C**: Multiple exits permitted where structural coverage (MC/DC for B, DC for C) is maintained; document clearly
- Document how `goto` and `longjmp` (prohibited in most avionics coding standards) are avoided
- Recursive calls: forbidden at DAL A–B unless stack depth is provably bounded and documented

## Additional Review Criteria (peer-review overlays only)

### Module Design — DO-178C Extensions

When reviewing `module-design.md` under DO-178C:
- **DAL Consistency**: Does each MOD-NNN's DAL match the parent ARCH-NNN allocation from the PSAC/SDP?
- **Complexity Limits**: Are complexity limits set per DAL (≤10 for DAL A)?
- **Coding Standard**: Is the applicable coding standard identified in the SDP? Are deviations traceable?
- **WCET**: Are worst-case execution time estimates provided for time-critical DAL A–B modules?
- **Memory Rules**: Is dynamic allocation forbidden/restricted per DAL? Is stack usage analyzed?
- **Single Entry/Exit**: Are DAL A modules single-exit? Are any deviations justified in the SDP?
