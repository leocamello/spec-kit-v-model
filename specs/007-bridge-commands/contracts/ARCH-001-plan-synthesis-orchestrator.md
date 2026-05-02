# Contract: ARCH-001 — Plan Synthesis Orchestrator

- **Type**: Prompt section
- **Classification**: NEW-PROMPT-SECTION
- **Realised by**: `commands/plan.md` §Execution Flow
- **Parent system component**: SYS-001 (Plan Synthesis)
- **Child modules**: MOD-001 (Plan Synthesis Orchestrator)
- **Parent requirements**: REQ-001, REQ-002, REQ-NF-005

## Preconditions

- `feature_dir` contains `requirements.md`.
- Spec Kit Core's `setup-plan.sh` is on `PATH`.
- The V-Model artifact set under `specs/<feature>/v-model/` is present (optional artifacts may be absent — they are listed in `optional_artifacts_skipped` per ATP-001-B / SCN-001-B1).

## Postconditions

- The canonical artifact set is written to `feature_dir/` (delegated to ARCH-002).
- The structured summary (ARCH-016) is printed.
- Exit code is 0 on success; on failure, exit code is 1 and the summary is still emitted.

## Expected sections in `commands/plan.md`

§Execution Flow, §Output Artifacts, §Enrichment, §Structured Summary.

## Error path

Any failure (missing input, ARCH-013 non-zero, write failure) ⇒ the LLM aborts, emits §Structured Summary with `fatal_errors[]` populated, exits 1. No partial canonical artifact set is left behind (atomic-write semantics from ARCH-002).

## Verification

- ATP-001-A / SCN-001-A1 (full artifact set discovery)
- ATP-001-B / SCN-001-B1 (partial artifact set)
- UTP-001-A (structural eval against §Execution Flow)
- ITP for end-to-end plan run (see `quickstart.md` Walkthrough 1)
