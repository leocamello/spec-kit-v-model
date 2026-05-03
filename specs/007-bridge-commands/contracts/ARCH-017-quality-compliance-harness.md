# Contract: ARCH-017 — Quality Compliance Harness

- **Type**: Prompt section
- **Classification**: NEW-PROMPT-SECTION
- **Realised by**: `commands/implement.md` §Quality Compliance
- **Parent system components**: SYS-003 (active), SYS-013 (deprecated stub — see D-013, D-014; this prompt section is the recharacterised functional intent of the original "Quality & Process Compliance Harness")
- **Child modules**: MOD-022 (Quality Compliance Harness)
- **Parent requirements**: REQ-NF-001, REQ-CN-003, REQ-CN-004

## Preconditions

- The four-stack harnesses (BATS, Pester, structural eval via pytest, LLM eval via DeepEval + `gemini-2.5-flash`) are installed and on `PATH` (constitution §Testing Stack).

## Postconditions

- Each harness reports 100% on its scope.
- Scope-guardrail audits reject orchestrator/sandbox additions (REQ-CN-001, REQ-CN-003, REQ-CN-004).
- Dogfood-discipline checks pass.

## Expected sections in `commands/implement.md`

§Quality Compliance (per-harness invocation, merge-gate rule, audit checklists).

## Error path

Any harness <100% ⇒ merge-gate blocks. Any audit fails ⇒ exit 1 (HAZ-021 — coverage gate not enforced).

## Verification

- STP-013-A (four-stack coverage)
- ATP-NF-001-A (merge-gate enforcement)
