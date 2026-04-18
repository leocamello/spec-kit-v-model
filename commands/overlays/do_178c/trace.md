# DO-178C — Trace Command Overlay

## Regulatory References

- **DO-178C Section 6.3.4**: Traceability Analysis — "Traceability between system requirements allocated to software, high-level requirements, low-level requirements, source code, and test cases." This defines the multi-level traceability chain that the trace command validates.
- **DO-178C Table A-9**: Verification of Verification Process Results — requires that traceability data is complete and correct as a verification objective.

## Compliance Interpretation

When presenting traceability results:

- **DAL-dependent rigor**: Report coverage per Design Assurance Level (DAL A through DAL E). DAL A requires complete MC/DC structural coverage — any gap in the traceability chain at DAL A is a certification finding.
- **Multi-level chain**: DO-178C requires traceability across ALL levels: system requirements → high-level requirements (REQ) → low-level requirements (MOD) → source code → test cases. The trace command validates the specification-side chain (REQ → ATP/STP/ITP/UTP). Code-level traceability is validated at implementation time.
- **Derived requirements**: Flag any derived requirements (REQ not traceable to a system requirement) — these require additional verification per DO-178C §5.2.1.
- **Deactivated code**: If any requirement is marked [DEPRECATED], verify that corresponding code and tests are also deactivated — deactivated code traceability is a certification concern per §6.4.4.2.
