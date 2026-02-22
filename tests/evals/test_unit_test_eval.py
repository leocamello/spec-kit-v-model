"""Evaluation test cases for /speckit.v-model.unit-test output quality.

These tests validate that unit test plans meet both structural
(UTP/UTS ID format, technique naming, mock registries, Arrange/Act/Assert)
and qualitative (coverage quality, technique appropriateness, isolation
strictness) standards.
"""

import pytest
from deepeval import assert_test
from deepeval.test_case import LLMTestCase

from tests.evals.metrics.structural import StructuralUnitTestMetric
from tests.evals.metrics.unit_test_quality import (
    create_unit_coverage_quality_metric,
    create_technique_appropriateness_metric,
    create_isolation_strictness_metric,
)


# ---------------------------------------------------------------------------
# Structural tests (deterministic, no LLM calls)
# ---------------------------------------------------------------------------


class TestUnitTestStructural:
    """Deterministic structural validation of unit test plans."""

    @pytest.mark.structural
    def test_minimal_utp_uts_id_compliance(self, fixture_dir):
        """All UTP and UTS IDs in minimal fixture follow correct format."""
        test_plan = (fixture_dir / "minimal" / "unit-test.md").read_text()
        tc = LLMTestCase(
            input="Minimal unit test fixture",
            actual_output=test_plan,
        )
        assert_test(tc, [StructuralUnitTestMetric(threshold=0.95)])

    @pytest.mark.structural
    def test_minimal_technique_naming(self, fixture_dir):
        """All techniques in minimal fixture are valid unit test technique names."""
        test_plan = (fixture_dir / "minimal" / "unit-test.md").read_text()
        tc = LLMTestCase(
            input="Minimal unit test fixture",
            actual_output=test_plan,
        )
        metric = StructuralUnitTestMetric(threshold=0.0)
        metric.measure(tc)
        assert "Non-standard unit technique" not in (metric.reason or ""), (
            f"Invalid technique names: {metric.reason}"
        )

    @pytest.mark.structural
    def test_minimal_mock_registry_presence(self, fixture_dir):
        """All UTP test cases in minimal fixture have Dependency & Mock Registry."""
        test_plan = (fixture_dir / "minimal" / "unit-test.md").read_text()
        tc = LLMTestCase(
            input="Minimal unit test fixture",
            actual_output=test_plan,
        )
        metric = StructuralUnitTestMetric(threshold=0.0)
        metric.measure(tc)
        assert "No Dependency & Mock Registry" not in (metric.reason or ""), (
            f"Missing mock registries: {metric.reason}"
        )

    @pytest.mark.structural
    def test_minimal_scenario_format(self, fixture_dir):
        """Minimal fixture has Unit Scenario lines with UTS-NNN-X# format."""
        test_plan = (fixture_dir / "minimal" / "unit-test.md").read_text()
        tc = LLMTestCase(
            input="Minimal unit test fixture",
            actual_output=test_plan,
        )
        metric = StructuralUnitTestMetric(threshold=0.0)
        metric.measure(tc)
        assert "No '**Unit Scenario:" not in (metric.reason or ""), (
            f"Missing Unit Scenario lines: {metric.reason}"
        )

    @pytest.mark.structural
    def test_complex_structural_compliance(self, fixture_dir):
        """Complex fixture passes all unit test structural checks."""
        test_plan = (fixture_dir / "complex" / "unit-test.md").read_text()
        tc = LLMTestCase(
            input="Complex unit test fixture",
            actual_output=test_plan,
        )
        assert_test(tc, [StructuralUnitTestMetric(threshold=0.95)])

    @pytest.mark.structural
    def test_golden_medical_device_structural(self, medical_device_unit_test):
        """Golden medical-device unit test passes all structural checks."""
        tc = LLMTestCase(
            input="Golden medical-device unit test",
            actual_output=medical_device_unit_test,
        )
        assert_test(tc, [StructuralUnitTestMetric(threshold=1.0)])

    @pytest.mark.structural
    def test_golden_automotive_adas_structural(self, automotive_adas_unit_test):
        """Golden automotive-adas unit test passes all structural checks."""
        tc = LLMTestCase(
            input="Golden automotive-adas unit test",
            actual_output=automotive_adas_unit_test,
        )
        assert_test(tc, [StructuralUnitTestMetric(threshold=1.0)])


# ---------------------------------------------------------------------------
# LLM-as-judge quality tests (require GOOGLE_API_KEY)
# ---------------------------------------------------------------------------


class TestUnitTestQuality:
    """LLM-as-judge evaluation of unit test quality."""

    @pytest.mark.eval
    def test_minimal_unit_coverage_quality(self, fixture_dir):
        """Minimal fixture unit test meets coverage quality bar."""
        test_plan = (fixture_dir / "minimal" / "unit-test.md").read_text()
        design = (fixture_dir / "minimal" / "module-design.md").read_text()
        tc = LLMTestCase(
            input=design,
            actual_output=test_plan,
            expected_output=(
                "A unit test plan with UTP test cases covering all MOD modules "
                "— each with concrete UTS scenarios verifying specific module "
                "behaviors with Arrange/Act/Assert structure."
            ),
        )
        metric = create_unit_coverage_quality_metric(threshold=0.7)
        assert_test(tc, [metric])

    @pytest.mark.eval
    def test_minimal_technique_appropriateness(self, fixture_dir):
        """Minimal fixture uses appropriate unit test techniques for each module."""
        test_plan = (fixture_dir / "minimal" / "unit-test.md").read_text()
        tc = LLMTestCase(
            input="Unit test plan for sensor monitoring module design",
            actual_output=test_plan,
            expected_output=(
                "A unit test plan where each test case uses a technique "
                "appropriate for the module under test — Statement & Branch "
                "Coverage for algorithmic modules, State Transition Testing "
                "for stateful modules, Boundary Value Analysis for numeric "
                "inputs, Equivalence Partitioning for discrete classes."
            ),
        )
        metric = create_technique_appropriateness_metric(threshold=0.7)
        assert_test(tc, [metric])

    @pytest.mark.eval
    def test_minimal_isolation_strictness(self, fixture_dir):
        """Minimal fixture unit tests maintain strict isolation."""
        test_plan = (fixture_dir / "minimal" / "unit-test.md").read_text()
        tc = LLMTestCase(
            input="Unit test plan for sensor monitoring module design",
            actual_output=test_plan,
            expected_output=(
                "A unit test plan with strict isolation — every UTP has a "
                "Dependency & Mock Registry, every UTS uses Arrange/Act/Assert "
                "structure, and all external dependencies are explicitly mocked."
            ),
        )
        metric = create_isolation_strictness_metric(threshold=0.7)
        assert_test(tc, [metric])

    @pytest.mark.eval
    def test_golden_medical_device_unit_quality(
        self, medical_device_module_design, medical_device_unit_test
    ):
        """Golden medical-device unit test meets coverage and technique quality bar."""
        tc = LLMTestCase(
            input=medical_device_module_design,
            actual_output=medical_device_unit_test,
            expected_output=(
                "A unit test plan covering all medical device MOD modules with "
                "UTP/UTS test cases using domain-appropriate techniques "
                "(Statement & Branch Coverage, Boundary Value Analysis, State "
                "Transition Testing, Equivalence Partitioning) and strict "
                "isolation via mock registries."
            ),
        )
        assert_test(tc, [
            create_unit_coverage_quality_metric(threshold=0.7),
            create_technique_appropriateness_metric(threshold=0.7),
        ])

    @pytest.mark.eval
    def test_golden_automotive_adas_unit_quality(
        self, automotive_adas_module_design, automotive_adas_unit_test
    ):
        """Golden automotive-adas unit test meets coverage and technique quality bar."""
        tc = LLMTestCase(
            input=automotive_adas_module_design,
            actual_output=automotive_adas_unit_test,
            expected_output=(
                "A unit test plan covering all AEB MOD modules with ASIL-D "
                "rigor, UTP/UTS test cases using Statement & Branch Coverage, "
                "MC/DC Coverage, Boundary Value Analysis, State Transition "
                "Testing, and strict isolation via mock registries."
            ),
        )
        assert_test(tc, [
            create_unit_coverage_quality_metric(threshold=0.7),
            create_technique_appropriateness_metric(threshold=0.7),
        ])
