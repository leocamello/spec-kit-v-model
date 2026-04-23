"""Evaluation test cases for impact-analysis output quality.

Since impact-analysis is a deterministic script (no LLM), all evaluations
are structural: JSON schema validation, golden output comparison, and
graph traversal property verification.
"""

import json
import pathlib
import subprocess

import pytest
from deepeval import assert_test
from deepeval.test_case import LLMTestCase

from tests.evals.metrics.structural import StructuralImpactAnalysisMetric

FIXTURES_DIR = pathlib.Path(__file__).parent.parent / "fixtures"
GOLDEN_DIR = FIXTURES_DIR / "commands/impact-analysis/expected"
IMPACT_DIR = FIXTURES_DIR / "commands/impact-analysis/inputs"
SCRIPTS_DIR = pathlib.Path(__file__).parent.parent.parent / "scripts" / "bash"


def _run_impact_analysis(args: list[str]) -> str:
    """Run impact-analysis.sh with given args, return stdout."""
    result = subprocess.run(
        ["bash", str(SCRIPTS_DIR / "impact-analysis.sh")] + args,
        capture_output=True, text=True, timeout=30,
    )
    assert result.returncode == 0, f"Script failed: {result.stderr}"
    return result.stdout


def _load_golden(fixture: str, name: str) -> dict:
    """Load a golden JSON file."""
    return json.loads((GOLDEN_DIR / fixture / name).read_text())


def _normalize(d):
    """Normalize JSON for comparison (sort string lists, sort dict keys)."""
    if isinstance(d, dict):
        return {k: _normalize(v) for k, v in sorted(d.items())}
    if isinstance(d, list):
        return sorted(d) if all(isinstance(x, str) for x in d) else d
    return d


# ---------------------------------------------------------------------------
# Structural validation (deterministic, no LLM)
# ---------------------------------------------------------------------------


class TestImpactAnalysisStructural:
    """Deterministic structural validation of impact-analysis JSON output."""

    @pytest.mark.structural
    @pytest.mark.parametrize("fixture,mode,args,golden_file", [
        ("minimal", "downward", ["--downward", "REQ-001"], "downward-REQ-001.json"),
        ("minimal", "upward", ["--upward", "MOD-001"], "upward-MOD-001.json"),
        ("minimal", "full", ["--full", "SYS-001"], "full-SYS-001.json"),
        ("complex", "downward", ["--downward", "REQ-001"], "downward-REQ-001.json"),
        ("complex", "upward", ["--upward", "MOD-006"], "upward-MOD-006.json"),
        ("complex", "full", ["--full", "SYS-003"], "full-SYS-003.json"),
        ("gaps", "downward", ["--downward", "REQ-001"], "downward-REQ-001.json"),
        ("gaps", "upward", ["--upward", "MOD-001"], "upward-MOD-001.json"),
    ], ids=lambda p: f"{p}" if isinstance(p, str) else None)
    def test_existing_fixture_passes_validation(self, fixture, mode, args, golden_file):
        """Each fixture+mode JSON output passes structural validation."""
        vmodel_dir = str(FIXTURES_DIR / fixture)
        output = _run_impact_analysis(["--json"] + args + [vmodel_dir])
        tc = LLMTestCase(
            input=f"{fixture} {mode}",
            actual_output=output,
        )
        assert_test(tc, [StructuralImpactAnalysisMetric(threshold=1.0)])

    @pytest.mark.structural
    @pytest.mark.parametrize("fixture,mode,args,golden_file", [
        ("linear", "downward", ["--downward", "REQ-001"], "downward-REQ-001.json"),
        ("linear", "upward", ["--upward", "MOD-001"], "upward-MOD-001.json"),
        ("linear", "full", ["--full", "SYS-001"], "full-SYS-001.json"),
        ("diamond", "downward", ["--downward", "REQ-001"], "downward-REQ-001.json"),
        ("diamond", "upward", ["--upward", "MOD-002"], "upward-MOD-002.json"),
        ("diamond", "full", ["--full", "ARCH-004"], "full-ARCH-004.json"),
        ("disconnected", "downward-a", ["--downward", "REQ-001"], "downward-REQ-001.json"),
        ("disconnected", "downward-b", ["--downward", "REQ-002"], "downward-REQ-002.json"),
        ("disconnected", "upward", ["--upward", "MOD-001"], "upward-MOD-001.json"),
    ], ids=lambda p: f"{p}" if isinstance(p, str) else None)
    def test_impact_fixture_passes_validation(self, fixture, mode, args, golden_file):
        """Each impact-specific fixture+mode passes structural validation."""
        if fixture in ("linear", "diamond", "disconnected"):
            vmodel_dir = str(IMPACT_DIR / fixture)
        else:
            vmodel_dir = str(FIXTURES_DIR / fixture)
        output = _run_impact_analysis(["--json"] + args + [vmodel_dir])
        tc = LLMTestCase(
            input=f"impact/{fixture} {mode}",
            actual_output=output,
        )
        assert_test(tc, [StructuralImpactAnalysisMetric(threshold=1.0)])


# ---------------------------------------------------------------------------
# Golden output comparison
# ---------------------------------------------------------------------------


class TestImpactAnalysisGoldenComparison:
    """Verify script output matches golden reference files exactly."""

    @pytest.mark.structural
    @pytest.mark.parametrize("fixture,args,golden_file,vmodel_base", [
        ("minimal", ["--downward", "REQ-001"], "downward-REQ-001.json", None),
        ("minimal", ["--upward", "MOD-001"], "upward-MOD-001.json", None),
        ("minimal", ["--full", "SYS-001"], "full-SYS-001.json", None),
        ("complex", ["--downward", "REQ-001"], "downward-REQ-001.json", None),
        ("linear", ["--downward", "REQ-001"], "downward-REQ-001.json", "commands/impact-analysis/inputs"),
        ("diamond", ["--downward", "REQ-001"], "downward-REQ-001.json", "commands/impact-analysis/inputs"),
        ("disconnected", ["--downward", "REQ-001"], "downward-REQ-001.json", "commands/impact-analysis/inputs"),
        ("disconnected", ["--downward", "REQ-002"], "downward-REQ-002.json", "commands/impact-analysis/inputs"),
    ])
    def test_matches_golden(self, fixture, args, golden_file, vmodel_base):
        """Script output matches golden reference after normalization."""
        if vmodel_base:
            vmodel_dir = str(FIXTURES_DIR / vmodel_base / fixture)
        else:
            vmodel_dir = str(FIXTURES_DIR / fixture)
        output = _run_impact_analysis(["--json"] + args + [vmodel_dir])
        actual = _normalize(json.loads(output))
        golden = _normalize(_load_golden(fixture, golden_file))
        assert actual == golden, f"Output differs from golden {fixture}/{golden_file}"


# ---------------------------------------------------------------------------
# Graph property tests
# ---------------------------------------------------------------------------


class TestImpactAnalysisGraphProperties:
    """Verify graph traversal properties that must always hold."""

    @pytest.mark.structural
    def test_disconnected_subgraphs_no_overlap(self):
        """Two disconnected subgraphs produce disjoint suspect sets."""
        out1 = _run_impact_analysis([
            "--json", "--downward", "REQ-001", str(IMPACT_DIR / "disconnected"),
        ])
        out2 = _run_impact_analysis([
            "--json", "--downward", "REQ-002", str(IMPACT_DIR / "disconnected"),
        ])
        d1 = json.loads(out1)
        d2 = json.loads(out2)
        ids1 = {v for lst in d1["suspect_artifacts"].values() for v in lst}
        ids2 = {v for lst in d2["suspect_artifacts"].values() for v in lst}
        assert len(ids1 & ids2) == 0, f"Subgraphs overlap: {ids1 & ids2}"

    @pytest.mark.structural
    def test_changed_ids_not_in_suspects(self):
        """Changed IDs should never appear in their own suspect list."""
        output = _run_impact_analysis([
            "--json", "--downward", "REQ-001", str(FIXTURES_DIR / "minimal"),
        ])
        d = json.loads(output)
        changed = set(d["changed_ids"])
        for ids in d["suspect_artifacts"].values():
            for vid in ids:
                assert vid not in changed, f"{vid} is both changed and suspect"

    @pytest.mark.structural
    def test_full_mode_subsumes_downward_and_upward(self):
        """Full mode suspects should include all downward + upward suspects."""
        vmodel = str(FIXTURES_DIR / "minimal")
        down = json.loads(_run_impact_analysis(["--json", "--downward", "SYS-001", vmodel]))
        up = json.loads(_run_impact_analysis(["--json", "--upward", "SYS-001", vmodel]))
        full = json.loads(_run_impact_analysis(["--json", "--full", "SYS-001", vmodel]))

        down_ids = {v for lst in down["suspect_artifacts"].values() for v in lst}
        up_ids = {v for lst in up["suspect_artifacts"].values() for v in lst}

        full_down = full["suspect_artifacts"].get("downstream", {})
        full_up = full["suspect_artifacts"].get("upstream", {})
        full_down_ids = {v for lst in full_down.values() for v in lst}
        full_up_ids = {v for lst in full_up.values() for v in lst}

        assert down_ids == full_down_ids, (
            f"Downward mismatch: {down_ids - full_down_ids} / {full_down_ids - down_ids}"
        )
        assert up_ids == full_up_ids, (
            f"Upward mismatch: {up_ids - full_up_ids} / {full_up_ids - up_ids}"
        )

    @pytest.mark.structural
    def test_revalidation_order_count_matches_total(self):
        """Revalidation order length equals blast radius total."""
        output = _run_impact_analysis([
            "--json", "--downward", "REQ-001", str(FIXTURES_DIR / "minimal"),
        ])
        d = json.loads(output)
        assert len(d["revalidation_order"]) == d["blast_radius"]["total"]

    @pytest.mark.structural
    def test_blast_by_level_sums_to_total(self):
        """Sum of by_level counts equals total."""
        output = _run_impact_analysis([
            "--json", "--full", "SYS-001", str(FIXTURES_DIR / "minimal"),
        ])
        d = json.loads(output)
        assert sum(d["blast_radius"]["by_level"].values()) == d["blast_radius"]["total"]
