# Implements: REQ-011, REQ-012, REQ-013, REQ-IF-002, SYS-002, ARCH-003, MOD-003, MOD-004, MOD-012, UTP-003-A, UTP-012-A, ATP-011-A, ATP-012-A, ATP-013-A, SCN-011-A1, D-006, D-010
"""Eval suite for TDD section ordering in ``commands/tasks.md`` outputs (T021).

Asserts the right-hand V-Model TDD ordering — write-unit → implement →
run-unit → write-integration → run-integration → write-system → run-system
→ write-acceptance — both as documented in the prompt (structural) and as
emitted in synthesised ``tasks.md`` (LLM-judge). Mirrors the
structural-vs-llm_judge split established by ``test_module_design_eval.py``
per D-006 (TDD discipline) and D-010 (eval strategy).
"""

from __future__ import annotations

import os
import pathlib
import re

import pytest

REPO_ROOT = pathlib.Path(__file__).resolve().parents[2]
TASKS_MD = REPO_ROOT / "commands" / "tasks.md"

TDD_SEQUENCE = [
    "**Write unit tests**",
    "**Implement modules**",
    "**Run unit tests**",
    "**Write integration tests**",
    "**Run integration tests**",
    "**Write system tests**",
    "**Run system tests**",
    "**Write acceptance tests**",
]

_SKIP_NO_KEY = pytest.mark.skipif(
    not os.environ.get("GOOGLE_API_KEY"),
    reason="GOOGLE_API_KEY not set; LLM-judge tests skipped",
)


# ---------------------------------------------------------------------------
# Structural (no LLM)
# ---------------------------------------------------------------------------


class TestTasksOrderStructural:
    """Deterministic checks against ``commands/tasks.md``."""

    @pytest.mark.structural
    def test_prompt_documents_tdd_sequence_in_order(self):
        """REQ-011/MOD-004/D-006: prompt must document the eight TDD phases in order."""
        body = TASKS_MD.read_text(encoding="utf-8")
        positions: list[int] = []
        for keyword in TDD_SEQUENCE:
            idx = body.find(keyword)
            assert idx >= 0, f"commands/tasks.md missing TDD phase keyword: {keyword!r}"
            positions.append(idx)
        # Strictly monotonically non-decreasing first-occurrences ⇒ documented order.
        assert positions == sorted(positions), (
            f"TDD ordering keywords appear out of sequence in commands/tasks.md "
            f"(positions={positions}, expected non-decreasing)"
        )

    @pytest.mark.structural
    def test_prompt_documents_parallel_marker_and_traces_to(self):
        """REQ-013/REQ-012/ARCH-003: prompt documents the ``[P]`` and ``traces-to`` grammar."""
        body = TASKS_MD.read_text(encoding="utf-8")
        assert "[P]" in body, "commands/tasks.md must document the [P] parallel marker"
        assert "traces-to" in body, "commands/tasks.md must document the traces-to comment"


# ---------------------------------------------------------------------------
# LLM-judge
# ---------------------------------------------------------------------------


def _load_fixture(name: str) -> dict[str, str]:
    fdir = REPO_ROOT / "tests" / "fixtures" / "v-model" / name
    return {p.name: p.read_text(encoding="utf-8") for p in sorted(fdir.glob("*.md"))}


def _phase_positions(text: str) -> list[int]:
    return [text.find(k) for k in TDD_SEQUENCE]


class TestTasksOrderLLMJudge:
    """Replay the tasks prompt and assert ordering survives in the output."""

    @pytest.mark.llm_judge
    @_SKIP_NO_KEY
    def test_complete_fixture_emits_tdd_ordering(self):
        """SCN-011-A1/ATP-011-A: synthesised tasks.md preserves the TDD phase order."""
        from tests.evals.harness import invoke

        ctx = _load_fixture("complete")
        output = invoke(
            "tasks",
            context_files=ctx,
            arguments="Generate TDD-ordered tasks for the complete fixture",
        )
        positions = _phase_positions(output)
        present = [(k, p) for k, p in zip(TDD_SEQUENCE, positions) if p >= 0]
        assert len(present) >= 4, (
            f"Synthesised tasks.md missing too many TDD phase keywords: {present}"
        )
        ordered = [p for _, p in present]
        assert ordered == sorted(ordered), (
            f"Synthesised tasks.md violates TDD phase ordering: {present}"
        )

    @pytest.mark.llm_judge
    @_SKIP_NO_KEY
    def test_complete_fixture_emits_parallel_marker_or_traces(self):
        """REQ-013/REQ-012: at least one [P] marker or traces-to comment surfaces."""
        from tests.evals.harness import invoke

        ctx = _load_fixture("complete")
        output = invoke("tasks", context_files=ctx, arguments="generate tasks")
        assert re.search(r"\[P\]", output) or "traces-to" in output, (
            "tasks output must carry either a [P] marker or a traces-to comment"
        )
