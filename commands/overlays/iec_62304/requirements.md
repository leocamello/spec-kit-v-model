# Requirements — IEC 62304 Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: iec_62304`.
> It provides domain-specific safety-critical requirements sections for the base `requirements` command.

## Risk Analysis Input (§5.2)

When generating requirements, integrate risk analysis outputs from ISO 14971:

- Requirements that implement **risk control measures** must be tagged: `[RISK CONTROL: HAZ-NNN]`.
- The risk control measure must specify the risk reduction mechanism (inherent safety, protective measures, or information for safety).
- Risk control requirements must be verifiable — include specific acceptance criteria that demonstrate the risk control is effective.

## Safety Class Rigor (IEC 62304 §4.3)

IEC 62304 defines three safety classes that determine the rigor of software development activities:

| Safety Class | Definition | Requirements Rigor |
|---|---|---|
| **Class A** | No injury or damage to health is possible | Basic requirements documentation |
| **Class B** | Non-serious injury is possible | Detailed requirements with traceability |
| **Class C** | Death or serious injury is possible | Comprehensive requirements with formal V&V |

- Tag safety-critical requirements with the applicable safety class: `[CLASS C]`, `[CLASS B]`.
- Class C requirements must have complete, unambiguous acceptance criteria — no vague language permitted.
- Class B and C requirements must trace to risk analysis outputs (ISO 14971).

## SOUP Requirements (§5.3.3)

If the system uses Software of Unknown Provenance (SOUP):

- Each SOUP component must have requirements specifying:
  - Functional and performance requirements allocated to the SOUP item
  - The SOUP item's hardware and software compatibility requirements
  - Known anomaly lists reviewed for impact on the intended use
- SOUP requirements are tagged: `[SOUP: <component-name>]`.

## Regulatory Submission Context

Requirements documents for medical devices are reviewed by regulatory bodies (FDA, Notified Bodies). Ensure:

- Requirements language is unambiguous and testable (the banned words table in the base command is especially critical for regulatory submissions).
- Every requirement traces to an intended use or user need (per FDA 21 CFR 820 §820.30).
- Software requirements specification (SRS) follows the structure expected by regulatory guidance (e.g., FDA Guidance on Software Validation).
