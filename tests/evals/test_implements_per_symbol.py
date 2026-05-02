# Implements: REQ-019, REQ-020, REQ-NF-002, SYS-003, ARCH-005, ARCH-006, MOD-006, MOD-007, UTP-006-A, UTP-007-A, ATP-019-A, ATP-020-A, SCN-019-A1, SCN-020-A1, D-010
"""Eval suite for per-symbol ``Implements`` directives + four-level test emission (T022).

Verifies that ``commands/implement.md``:

- documents the public-symbol ``Implements <ID>`` requirement
  (REQ-019 / SCN-019-A1) at the prompt level (structural);
- documents four-level test emission — UTP / ITP / STP / ATP
  (REQ-020 / SCN-020-A1) at the prompt level (structural);
- when invoked end-to-end, emits code where every public symbol carries
  an ``Implements <ID>`` comment and tests appear at all four V-Model
  levels (LLM-judge, requires ``GOOGLE_API_KEY``).

Per D-010 (eval strategy).
"""

from __future__ import annotations

import os
import pathlib
import re

import pytest

REPO_ROOT = pathlib.Path(__file__).resolve().parents[2]
IMPLEMENT_MD = REPO_ROOT / "commands" / "implement.md"

_SKIP_NO_KEY = pytest.mark.skipif(
    not os.environ.get("GOOGLE_API_KEY"),
    reason="GOOGLE_API_KEY not set; LLM-judge tests skipped",
)


# ---------------------------------------------------------------------------
# Structural
# ---------------------------------------------------------------------------


class TestImplementsPerSymbolStructural:
    """Deterministic checks against ``commands/implement.md``."""

    @pytest.mark.structural
    def test_prompt_documents_per_public_symbol_implements(self):
        """REQ-019/SCN-019-A1: prompt names the per-public-symbol Implements rule."""
        body = IMPLEMENT_MD.read_text(encoding="utf-8")
        assert re.search(
            r"public symbol", body, re.IGNORECASE
        ), "commands/implement.md must reference 'public symbol' coverage"
        assert "Implements" in body and "REQ-019" in body, (
            "commands/implement.md must cite REQ-019 and document Implements directives"
        )

    @pytest.mark.structural
    def test_prompt_documents_four_level_test_emission(self):
        """REQ-020/SCN-020-A1: UTP, ITP, STP, ATP all referenced as test families."""
        body = IMPLEMENT_MD.read_text(encoding="utf-8")
        for fam in ("UTP", "ITP", "STP", "ATP"):
            assert fam in body, (
                f"commands/implement.md must reference test family {fam} "
                f"(four-level emission per REQ-020 / SCN-020-A1)"
            )
        # Sanity: the four canonical test directories must be named.
        for tdir in (
            "tests/unit",
            "tests/integration",
            "tests/system",
            "tests/acceptance",
        ):
            assert tdir in body, (
                f"commands/implement.md must direct emission into {tdir}/"
            )


# ---------------------------------------------------------------------------
# LLM-judge
# ---------------------------------------------------------------------------


def _load_fixture(name: str) -> dict[str, str]:
    fdir = REPO_ROOT / "tests" / "fixtures" / "v-model" / name
    return {p.name: p.read_text(encoding="utf-8") for p in sorted(fdir.glob("*.md"))}


_PUBLIC_SYMBOL_RE = re.compile(
    r"^\s*(?:def|class|function|export\s+(?:function|class|const)|public\s+\w+)\s+"
    r"(?P<name>[A-Za-z_][A-Za-z0-9_]*)",
    re.MULTILINE,
)


class TestImplementsPerSymbolLLMJudge:
    """Invoke implement command and inspect the emitted artefacts."""

    @pytest.mark.llm_judge
    @_SKIP_NO_KEY
    def test_every_public_symbol_has_implements_comment(self):
        """SCN-019-A1: 100% of emitted public symbols carry Implements <ID>."""
        from tests.evals.harness import invoke

        ctx = _load_fixture("complete")
        output = invoke(
            "implement",
            context_files=ctx,
            arguments="Generate code for the complete fixture",
        )
        symbols = _PUBLIC_SYMBOL_RE.findall(output)
        if not symbols:
            pytest.skip("LLM did not emit recognisable public symbols")
        # Heuristic: count Implements occurrences ≥ number of public symbols.
        implements_count = len(re.findall(r"\bImplements\b\s*[:=]?\s*[A-Z]", output))
        assert implements_count >= len(symbols), (
            f"Per-public-symbol Implements coverage failed: "
            f"{len(symbols)} symbols, {implements_count} Implements directives"
        )

    @pytest.mark.llm_judge
    @_SKIP_NO_KEY
    def test_four_level_tests_all_emitted(self):
        """SCN-020-A1: all four test families appear in the emitted content."""
        from tests.evals.harness import invoke

        ctx = _load_fixture("complete")
        output = invoke("implement", context_files=ctx, arguments="implement")
        for fam in ("tests/unit", "tests/integration", "tests/system", "tests/acceptance"):
            assert fam in output, (
                f"Implement output must mention {fam}/ (four-level emission)"
            )
