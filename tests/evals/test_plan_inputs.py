# Implements: REQ-001, REQ-002, REQ-IF-001, SYS-001, SYS-005, ARCH-001, ARCH-002, ARCH-008, ARCH-014, MOD-001, MOD-002, MOD-011, UTP-001-A, UTP-002-A, ATP-001-A, ATP-002-A, SCN-001-A1, SCN-002-A1, D-010
"""Eval suite for `commands/plan.md` outputs (T020).

Covers SCN-001-A1 (full happy path against a complete V-Model fixture) and
SCN-001-B1 (reduced-enrichment fallback when ``hazard-analysis.md`` is
absent). Splits **structural** (deterministic, no LLM) tests from
**llm_judge** (DeepEval, Gemini ``gemini-2.5-flash``, skipped without
``GOOGLE_API_KEY``) per the existing ``tests/evals/*`` idiom and D-010.
"""

from __future__ import annotations

import os
import pathlib
import re
import subprocess

import pytest

REPO_ROOT = pathlib.Path(__file__).resolve().parents[2]
PLAN_MD = REPO_ROOT / "commands" / "plan.md"

# The 11 expected V-Model + spec-kit-core inputs the prompt enumerates.
EXPECTED_INPUTS = [
    "spec.md",
    "requirements.md",
    "system-design.md",
    "architecture-design.md",
    "module-design.md",
    "unit-test.md",
    "integration-test.md",
    "system-test.md",
    "acceptance-plan.md",
    "hazard-analysis.md",
    "traceability-matrix.md",
]

_SKIP_NO_KEY = pytest.mark.skipif(
    not os.environ.get("GOOGLE_API_KEY"),
    reason="GOOGLE_API_KEY not set; LLM-judge tests skipped",
)


# ---------------------------------------------------------------------------
# Structural (no LLM)
# ---------------------------------------------------------------------------


class TestPlanInputsStructural:
    """Deterministic checks against the on-disk ``commands/plan.md`` prompt."""

    @pytest.mark.structural
    def test_inputs_section_enumerates_eleven_artefacts(self):
        """SCN-001-A1: prompt must name all 11 expected inputs.

        Counts unique artefact filenames the prompt actually references —
        the canonical 10 V-Model artefacts plus ``spec.md`` from
        spec-kit-core. (Per ARCH-001/MOD-001 the bridge consumes the full
        V-Model artefact set; per REQ-IF-001 ``spec.md`` is the
        spec-kit-core upstream.)
        """
        body = PLAN_MD.read_text(encoding="utf-8")
        missing = [name for name in EXPECTED_INPUTS if name not in body]
        assert not missing, (
            f"commands/plan.md does not reference expected inputs: {missing}"
        )

    @pytest.mark.structural
    def test_missing_hazard_fallback_documented(self):
        """SCN-001-B1: reduced-enrichment branch documented for missing hazard."""
        body = PLAN_MD.read_text(encoding="utf-8")
        # ARCH-014 reduced-enrichment fallback: must mention the artefact and
        # the reduction posture.
        assert "hazard-analysis.md" in body
        assert re.search(r"reduced[- ]enrichment", body, re.IGNORECASE), (
            "plan.md must document a reduced-enrichment fallback path"
        )
        assert re.search(
            r"<!-- v-model: enrichment reduced", body
        ), "plan.md must specify the explanatory enrichment-reduced HTML comment"

    @pytest.mark.structural
    def test_additive_enrichment_grammar_v_model_comment(self):
        """ARCH-008/MOD-011: enrichment lines must use the ``<!-- v-model:`` prefix."""
        body = PLAN_MD.read_text(encoding="utf-8")
        assert "<!-- v-model:" in body, (
            "plan.md must require/illustrate the additive `<!-- v-model:` "
            "enrichment grammar"
        )


# ---------------------------------------------------------------------------
# LLM-judge (require GOOGLE_API_KEY)
# ---------------------------------------------------------------------------


def _load_fixture(name: str) -> dict[str, str]:
    fdir = REPO_ROOT / "tests" / "fixtures" / "v-model" / name
    return {p.name: p.read_text(encoding="utf-8") for p in sorted(fdir.glob("*.md"))}


class TestPlanInputsLLMJudge:
    """Replay the prompt against fixture sets (require GOOGLE_API_KEY)."""

    @pytest.mark.llm_judge
    @_SKIP_NO_KEY
    def test_complete_fixture_full_enrichment(self):
        """SCN-001-A1: full happy path lists all V-Model inputs and enriches."""
        from tests.evals.harness import invoke

        ctx = _load_fixture("complete")
        output = invoke(
            "plan",
            context_files=ctx,
            arguments="Synthesise a V-Model-enriched plan from the complete fixture",
        )
        assert "<!-- v-model:" in output, "missing additive enrichment marker"
        for name in ("requirements.md", "module-design.md", "architecture-design.md"):
            assert name in output, f"plan.md output should reference {name}"

    @pytest.mark.llm_judge
    @_SKIP_NO_KEY
    def test_complete_fixture_round_trips_validator(self, tmp_path):
        """ATP-001-A: synthesised plan.md round-trips through validate-core-schema.sh."""
        from tests.evals.harness import invoke

        ctx = _load_fixture("complete")
        output = invoke("plan", context_files=ctx, arguments="generate plan")
        plan_path = tmp_path / "plan.md"
        plan_path.write_text(output, encoding="utf-8")
        validator = REPO_ROOT / "scripts" / "bash" / "validate-core-schema.sh"
        result = subprocess.run(
            ["bash", str(validator), str(plan_path), "--plan"],
            capture_output=True,
            text=True,
        )
        assert result.returncode == 0, (
            f"validate-core-schema.sh --plan rejected synthesised plan.md:\n"
            f"stdout: {result.stdout}\nstderr: {result.stderr}"
        )

    @pytest.mark.llm_judge
    @_SKIP_NO_KEY
    def test_missing_hazard_fixture_reduced_enrichment(self):
        """SCN-001-B1: missing-hazard fixture yields reduced enrichment, no HAZ-NNN cites."""
        from tests.evals.harness import invoke

        ctx = _load_fixture("missing-hazard")
        output = invoke(
            "plan",
            context_files=ctx,
            arguments="Synthesise plan without hazard analysis",
        )
        assert not re.search(r"\bHAZ-\d{3}\b", output), (
            "Reduced-enrichment plan must not cite HAZ-NNN identifiers"
        )
        assert "reduced" in output.lower() or "<!-- v-model:" in output, (
            "Reduced enrichment must be observable in the synthesised plan"
        )
