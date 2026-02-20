"""Evaluation test cases for /speckit.v-model.system-test output quality.

These tests validate that system test plans meet both structural
(STP/STS ID format, ISO 29119 technique naming, technical BDD language)
and qualitative (coverage quality, technique appropriateness, scenario
independence) standards.
"""

import pytest
from deepeval import assert_test
from deepeval.test_case import LLMTestCase

from tests.evals.metrics.structural import StructuralSystemTestMetric
from tests.evals.metrics.system_test_quality import (
    create_test_coverage_quality_metric,
    create_technique_appropriateness_metric,
    create_scenario_independence_metric,
)


# ---------------------------------------------------------------------------
# Structural tests (deterministic, no LLM calls)
# ---------------------------------------------------------------------------


class TestSystemTestStructural:
    """Deterministic structural validation of system test plans."""

    @pytest.mark.structural
    def test_minimal_stp_sts_id_compliance(self, fixture_dir):
        """All STP and STS IDs in system-design-minimal follow correct format."""
        test_plan = (
            fixture_dir / "system-design-minimal" / "system-test.md"
        ).read_text()
        tc = LLMTestCase(
            input="Minimal system test fixture",
            actual_output=test_plan,
        )
        assert_test(tc, [StructuralSystemTestMetric(threshold=0.95)])

    @pytest.mark.structural
    def test_minimal_iso_29119_techniques(self, fixture_dir):
        """All techniques in system-design-minimal are valid ISO 29119 names."""
        test_plan = (
            fixture_dir / "system-design-minimal" / "system-test.md"
        ).read_text()
        tc = LLMTestCase(
            input="Minimal system test fixture",
            actual_output=test_plan,
        )
        metric = StructuralSystemTestMetric(threshold=0.0)
        metric.measure(tc)
        assert "Non-ISO 29119 technique" not in (metric.reason or ""), (
            f"Invalid technique names: {metric.reason}"
        )

    @pytest.mark.structural
    def test_minimal_no_user_journey_language(self, fixture_dir):
        """System-design-minimal system test uses technical, not user-journey language."""
        test_plan = (
            fixture_dir / "system-design-minimal" / "system-test.md"
        ).read_text()
        tc = LLMTestCase(
            input="Minimal system test fixture",
            actual_output=test_plan,
        )
        metric = StructuralSystemTestMetric(threshold=0.0)
        metric.measure(tc)
        assert "User-journey phrase detected" not in (metric.reason or ""), (
            f"User-journey language found: {metric.reason}"
        )

    @pytest.mark.structural
    def test_complex_structural_compliance(self, fixture_dir):
        """Complex fixture (6 STP, 6 STS) passes all structural checks."""
        test_plan = (
            fixture_dir / "system-design-complex" / "system-test.md"
        ).read_text()
        tc = LLMTestCase(
            input="Complex system test fixture",
            actual_output=test_plan,
        )
        assert_test(tc, [StructuralSystemTestMetric(threshold=0.95)])


# ---------------------------------------------------------------------------
# LLM-as-judge quality tests (require GOOGLE_API_KEY)
# ---------------------------------------------------------------------------


class TestSystemTestQuality:
    """LLM-as-judge evaluation of system test quality."""

    @pytest.mark.eval
    def test_minimal_coverage_quality(self, fixture_dir):
        """Minimal fixture system test meets coverage quality bar."""
        test_plan = (
            fixture_dir / "system-design-minimal" / "system-test.md"
        ).read_text()
        design = (
            fixture_dir / "system-design-minimal" / "system-design.md"
        ).read_text()
        tc = LLMTestCase(
            input=design,
            actual_output=test_plan,
            expected_output=(
                "A system test plan with STP test cases covering all 3 SYS "
                "components (Data Processor, Alert Engine, Display Renderer) — "
                "each with concrete STS scenarios verifying specific behaviors "
                "with measurable outcomes."
            ),
        )
        metric = create_test_coverage_quality_metric(threshold=0.7)
        assert_test(tc, [metric])

    @pytest.mark.eval
    def test_minimal_technique_appropriateness(self, fixture_dir):
        """Minimal fixture uses appropriate ISO 29119 techniques for each component."""
        test_plan = (
            fixture_dir / "system-design-minimal" / "system-test.md"
        ).read_text()
        tc = LLMTestCase(
            input="System test plan for sensor monitoring components",
            actual_output=test_plan,
            expected_output=(
                "A system test plan where each test case uses an ISO 29119 "
                "technique appropriate for the component under test — Interface "
                "Contract Testing for API/protocol components, Boundary Value "
                "Analysis for threshold-based components, etc."
            ),
        )
        metric = create_technique_appropriateness_metric(threshold=0.7)
        assert_test(tc, [metric])

    @pytest.mark.eval
    def test_minimal_scenario_independence(self, fixture_dir):
        """Minimal fixture scenarios are independent and use technical language."""
        test_plan = (
            fixture_dir / "system-design-minimal" / "system-test.md"
        ).read_text()
        tc = LLMTestCase(
            input="System test plan for sensor monitoring components",
            actual_output=test_plan,
            expected_output=(
                "A system test plan with self-contained scenarios that use "
                "precise technical language — referencing components, protocols, "
                "and measurable thresholds rather than user-journey phrases. "
                "Each scenario is independently executable."
            ),
        )
        metric = create_scenario_independence_metric(threshold=0.7)
        assert_test(tc, [metric])
