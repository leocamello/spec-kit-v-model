# ARCH-020 [CROSS-CUTTING]: Subprocess Runner

<!-- v-model-enrichment: feature=007-bridge-commands -->
<!-- source: architecture-design.md §Interface View ARCH-020 -->

**Module Type**: Cross-cutting subprocess wrapper  
**Target Source File**: `src/v_model_extension/shared/subprocess_runner.py` (MOD-026)  
**Invoked by**: ARCH-007, ARCH-017, ARCH-018

---

## Interface Contract

| Direction | Name | Type | Format | Constraints |
|-----------|------|------|--------|-------------|
| Input | `command` | list[string] | argv | first element MUST be a script path the project itself ships (REQ-CN-002 — no new wrapper script) |
| Input | `cwd` | path | absolute | |
| Output | `RunResult` | struct | `{exit_code: int, stdout: str, stderr: str}` | UTF-8; binary output rejected |
| Exception | `SubprocessFailure` | raised | text + exit code | propagated to caller for fail-closed handling |
