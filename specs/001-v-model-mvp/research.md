# Research: V-Model Extension Pack MVP

**Branch**: `001-v-model-mvp`
**Date**: 2026-02-19
**Status**: Complete (retroactive documentation)

## Research Questions

### RQ-1: How do Spec Kit extensions define commands?

**Finding**: Commands are Markdown files in `commands/` that contain
structured prompt definitions. The AI assistant (GitHub Copilot) reads
the command file and follows its instructions. Each command file specifies
inputs, outputs, workflow steps, quality criteria, and validation rules.

**Source**: Spec Kit extension architecture (`extension.yml` schema,
existing Spec Kit extensions).

### RQ-2: What ID schema supports bidirectional traceability without external databases?

**Finding**: A hierarchical ID scheme where child IDs embed parent IDs
(`REQ-001` → `ATP-001-A` → `SCN-001-A1`) enables traceability via regex
extraction. The suffix encodes lineage: the numeric prefix of an ATP
matches its parent REQ, and the numeric prefix of an SCN matches its
parent ATP. This approach requires no mapping tables or databases.

**Source**: IEEE 29148 traceability requirements, DO-178C bidirectional
traceability guidance, IEC 62304 software lifecycle documentation.

### RQ-3: What quality criteria should requirements meet for regulatory acceptance?

**Finding**: Eight criteria are widely recognized across regulatory
standards: unambiguous, testable/verifiable, atomic, complete, consistent,
traceable, feasible, and necessary. The command enforces these by
maintaining a banned-words list (vague terms like "fast", "user-friendly",
"robust") and requiring measurable language.

**Source**: IEEE 29148:2018 §5.2.5 (requirement characteristics),
INCOSE Guide for Writing Requirements.

### RQ-4: How should coverage validation be implemented for audit trust?

**Finding**: Regex-based parsing of structured Markdown provides
deterministic, repeatable results. The scripts extract all `REQ-NNN`,
`ATP-NNN-X`, and `SCN-NNN-X#` identifiers, then cross-reference to
detect gaps (requirements without tests) and orphans (tests without
requirements). Exit codes (0 = full coverage, 1 = gaps) enable CI
integration.

**Source**: Constitution Principle II (Deterministic Verification),
DO-178C §6.4 (verification of verification process).

### RQ-5: What LLM evaluation approach validates AI-generated artifact quality?

**Finding**: DeepEval's GEval metrics with Google Gemini as the judge
model provide semantic quality evaluation. Three custom metrics assess
requirements quality (clarity, atomicity, measurability), BDD quality
(declarative style, single-action, observable outcomes), and traceability
completeness. Golden examples (medical device, automotive ADAS) serve as
reference standards.

**Source**: DeepEval documentation, Google Gemini API, iterative
testing during Phase 2 QA implementation.
