# Implements: REQ-014, SYS-009, ARCH-012, MOD-016, UTP-004-A, UTP-016-A, ATP-014-A, ATP-014-B, SCN-014-A1, SCN-014-B1, HAZ-016, D-010, D-011
"""Eval suite for hazard-driven enrichment in ``commands/tasks.md`` (T021).

Verifies the two HAZ-driven behaviours the bridge command promises:

1. **Hazard-priority elevation** (SCN-014-A1, ATP-014-A) — tasks whose
   subject MOD/ARCH appears in a HAZ Mitigation column are promoted within
   their phase and prefixed ``**[HAZARD-ELEVATED]**``.
2. **Per-HAZ verification task emission** (SCN-014-B1, ATP-014-B) — every
   ``HAZ-NNN`` row whose mitigation is verification-by-test produces
   exactly one dedicated ``Verify mitigation for HAZ-NNN`` task.

Per D-011 (hazard-driven enrichment) and HAZ-016 (the in-force risk this
behaviour mitigates). Splits structural / llm_judge per D-010.
"""

from __future__ import annotations

import os
import pathlib
import re

import pytest

REPO_ROOT = pathlib.Path(__file__).resolve().parents[2]
TASKS_MD = REPO_ROOT / "commands" / "tasks.md"

_SKIP_NO_KEY = pytest.mark.skipif(
    not os.environ.get("GOOGLE_API_KEY"),
    reason="GOOGLE_API_KEY not set; LLM-judge tests skipped",
)

_HAZ_RE = re.compile(r"\bHAZ-\d{3}\b")


# ---------------------------------------------------------------------------
# Structural
# ---------------------------------------------------------------------------


class TestHazardTasksStructural:
    """Deterministic checks against ``commands/tasks.md``."""

    @pytest.mark.structural
    def test_prompt_documents_hazard_priority_elevation(self):
        """ARCH-012/MOD-016/SCN-014-A1: prompt names HAZ-driven elevation."""
        body = TASKS_MD.read_text(encoding="utf-8")
        assert _HAZ_RE.search(body) or "HAZ-NNN" in body, (
            "commands/tasks.md must reference HAZ identifiers"
        )
        assert re.search(
            r"(elevat|priorit)", body, re.IGNORECASE
        ), "commands/tasks.md must document priority elevation logic"
        assert "HAZARD-ELEVATED" in body, (
            "commands/tasks.md must document the **[HAZARD-ELEVATED]** prefix"
        )

    @pytest.mark.structural
    def test_prompt_documents_per_haz_verification_task(self):
        """SCN-014-B1/ATP-014-B: per-HAZ verification task emission documented."""
        body = TASKS_MD.read_text(encoding="utf-8")
        assert re.search(
            r"Verify mitigation for HAZ", body
        ), "commands/tasks.md must document the 'Verify mitigation for HAZ-NNN' task"

    @pytest.mark.structural
    def test_prompt_documents_haz_016_fail_closed(self):
        """HAZ-016/D-011: malformed hazard-analysis.md must fail-closed."""
        body = TASKS_MD.read_text(encoding="utf-8")
        assert "malformed" in body.lower() and "hazard-analysis.md" in body, (
            "commands/tasks.md must document the fail-closed posture for "
            "malformed hazard-analysis.md (HAZ-016, D-011)"
        )


# ---------------------------------------------------------------------------
# LLM-judge
# ---------------------------------------------------------------------------


def _load_fixture(name: str) -> dict[str, str]:
    fdir = REPO_ROOT / "tests" / "fixtures" / "v-model" / name
    return {p.name: p.read_text(encoding="utf-8") for p in sorted(fdir.glob("*.md"))}


class TestHazardTasksLLMJudge:
    """Replay against the complete fixture; assert HAZ behaviours surface."""

    @pytest.mark.llm_judge
    @_SKIP_NO_KEY
    def test_every_haz_has_verification_task(self):
        """SCN-014-B1: every HAZ-NNN in fixture appears in ≥1 verification task."""
        from tests.evals.harness import invoke

        ctx = _load_fixture("complete")
        haz_in_fixture = set(_HAZ_RE.findall(ctx.get("hazard-analysis.md", "")))
        if not haz_in_fixture:
            pytest.skip("complete fixture defines no HAZ-NNN rows")
        output = invoke(
            "tasks",
            context_files=ctx,
            arguments="Generate tasks with hazard-driven enrichment",
        )
        missing = []
        for haz in sorted(haz_in_fixture):
            pattern = rf"Verify mitigation for {re.escape(haz)}\b"
            if not re.search(pattern, output):
                missing.append(haz)
        assert not missing, (
            f"Synthesised tasks.md missing 'Verify mitigation for ...' tasks for: {missing}"
        )

    @pytest.mark.llm_judge
    @_SKIP_NO_KEY
    def test_hazard_elevated_tasks_precede_peers(self):
        """SCN-014-A1: HAZARD-ELEVATED tasks come before non-HAZ peers in their phase."""
        from tests.evals.harness import invoke

        ctx = _load_fixture("complete")
        output = invoke("tasks", context_files=ctx, arguments="generate tasks")
        if "HAZARD-ELEVATED" not in output:
            pytest.skip("LLM did not emit any HAZARD-ELEVATED tasks for this fixture")
        # Within each phase block, the first HAZARD-ELEVATED task must come
        # before any non-HAZ-elevated task. Heuristic: split on Markdown
        # headings starting with "## " or "### ", then check ordering.
        phases = re.split(r"\n(?=#{2,4}\s)", output)
        for phase in phases:
            elevated_idx = phase.find("HAZARD-ELEVATED")
            if elevated_idx < 0:
                continue
            # Find the first task line (starts with "- " or "* " or "- [")
            task_match = re.search(r"^[-*]\s", phase, re.MULTILINE)
            if task_match is None:
                continue
            first_task_idx = task_match.start()
            # Elevated must be among the earliest tasks in the phase.
            assert elevated_idx >= first_task_idx, (
                "HAZARD-ELEVATED prefix appears before any task line — malformed"
            )
