# Trace — DO-178C Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: do_178c`.
> It provides domain-specific safety-critical traceability sections for the base `trace` command.

## Regulatory References

- **DO-178C Section 6.3.4**: Traceability Analysis — "Traceability between system requirements allocated to software, high-level requirements, low-level requirements, source code, and test cases." This defines the multi-level traceability chain that the trace command validates.
- **DO-178C Table A-9**: Verification of Verification Process Results — requires that traceability data is complete and correct as a verification objective.

## Compliance Interpretation

When presenting traceability results:

- **DAL-dependent rigor**: Report coverage per Design Assurance Level (DAL A through DAL E). DAL A requires complete MC/DC structural coverage — any gap in the traceability chain at DAL A is a certification finding.
- **Multi-level chain**: DO-178C requires traceability across ALL levels: system requirements → high-level requirements (REQ) → low-level requirements (MOD) → source code → test cases. The trace command validates the specification-side chain (REQ → ATP/STP/ITP/UTP). Code-level traceability is validated at implementation time.
- **Derived requirements**: Flag any derived requirements (REQ not traceable to a system requirement) — these require additional verification per DO-178C §5.2.1.
- **Deactivated code**: If any requirement is marked [DEPRECATED], verify that corresponding code and tests are also deactivated — deactivated code traceability is a certification concern per §6.4.4.2.
- **Bidirectional traceability**: Both forward (requirement → test) and backward (test → requirement) traceability must be validated at DAL A–C per §6.3.4. Orphan tests (not linked to any requirement) should be flagged.

## DAL-Dependent Traceability Requirements

| DAL | Traceability Chain | Bidirectional | Independence | Table A-9 Objectives |
|-----|-------------------|---------------|--------------|---------------------|
| DAL A | SYS → HLR → LLR → Code → Test (all levels) | Mandatory | Independent review required | All objectives apply |
| DAL B | SYS → HLR → LLR → Code → Test (all levels) | Mandatory | Independent review recommended | All objectives apply |
| DAL C | SYS → HLR → LLR → Test | Mandatory | Self-review acceptable | Most objectives apply |
| DAL D | SYS → HLR → Test | Required | Self-review acceptable | Reduced set applies |
| DAL E | Not required | Not required | N/A | N/A |

**Rules**:
- DAL A–B: bidirectional traceability is a certification objective — both forward (requirement → test) and backward (test → requirement) must be demonstrated
- DAL A: traceability data must be independently reviewed (reviewer ≠ developer)
- All DAL levels: derived requirements must be flagged and communicated to the system safety assessment
- Deactivated features (DEPRECATED) must trace to deactivation evidence

## Traceability Gap Analysis

When the trace command identifies gaps, classify them by certification impact:

| Gap Type | DAL A Impact | DAL B–C Impact | DAL D–E Impact |
|----------|-------------|----------------|----------------|
| HLR → no test case | **Blocks SOI-4** | Must resolve before verification | Documentation note |
| LLR → no test case | **Blocks SOI-4** | Must resolve before verification | N/A |
| Test → no requirement (orphan) | Certification concern | Documentation cleanup | Informational |
| Deprecated REQ → no successor | **Blocks SOI-4** | Must resolve | Documentation cleanup |
| System REQ → no HLR | **Blocks SOI-3** | Must resolve | Documentation note |
| Derived HLR → no justification | **Blocks SOI-3** | Must resolve | N/A |

**SOI References** (Stage of Involvement):
- SOI-1: Software Planning Review
- SOI-2: Software Development Review
- SOI-3: Software Verification Review
- SOI-4: Final Certification Review
