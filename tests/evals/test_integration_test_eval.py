"""Evaluation test cases for /speckit.v-model.integration-test output quality.

These tests validate that integration test plans meet both structural
(ITP/ITS ID format, integration technique naming, module-boundary BDD language)
and qualitative (coverage quality, technique appropriateness, scenario
boundary focus) standards.
"""

import pytest
from deepeval import assert_test
from deepeval.test_case import LLMTestCase

from tests.evals.metrics.structural import StructuralIntegrationTestMetric
from tests.evals.metrics.integration_test_quality import (
    create_integration_coverage_quality_metric,
    create_technique_appropriateness_metric,
    create_scenario_boundary_metric,
)


# ---------------------------------------------------------------------------
# Structural tests (deterministic, no LLM calls)
# ---------------------------------------------------------------------------


class TestIntegrationTestStructural:
    """Deterministic structural validation of integration test plans."""

    @pytest.mark.structural
    def test_minimal_itp_its_id_compliance(self, fixture_dir):
        """All ITP and ITS IDs in minimal fixture follow correct format."""
        test_plan = (
            fixture_dir / "minimal" / "integration-test.md"
        ).read_text()
        tc = LLMTestCase(
            input="Minimal integration test fixture",
            actual_output=test_plan,
        )
        assert_test(tc, [StructuralIntegrationTestMetric(threshold=0.95)])

    @pytest.mark.structural
    def test_minimal_technique_naming(self, fixture_dir):
        """All techniques in minimal fixture are valid integration test technique names."""
        test_plan = (
            fixture_dir / "minimal" / "integration-test.md"
        ).read_text()
        tc = LLMTestCase(
            input="Minimal integration test fixture",
            actual_output=test_plan,
        )
        metric = StructuralIntegrationTestMetric(threshold=0.0)
        metric.measure(tc)
        assert "Non-standard integration technique" not in (metric.reason or ""), (
            f"Invalid technique names: {metric.reason}"
        )

    @pytest.mark.structural
    def test_minimal_no_user_journey_language(self, fixture_dir):
        """Minimal integration test uses module-boundary, not user-journey language."""
        test_plan = (
            fixture_dir / "minimal" / "integration-test.md"
        ).read_text()
        tc = LLMTestCase(
            input="Minimal integration test fixture",
            actual_output=test_plan,
        )
        metric = StructuralIntegrationTestMetric(threshold=0.0)
        metric.measure(tc)
        assert "User-journey phrase detected" not in (metric.reason or ""), (
            f"User-journey language found: {metric.reason}"
        )

    @pytest.mark.structural
    def test_complex_structural_compliance(self, fixture_dir):
        """Complex fixture passes all integration test structural checks."""
        test_plan = (
            fixture_dir / "complex" / "integration-test.md"
        ).read_text()
        tc = LLMTestCase(
            input="Complex integration test fixture",
            actual_output=test_plan,
        )
        assert_test(tc, [StructuralIntegrationTestMetric(threshold=0.95)])

    @pytest.mark.structural
    def test_golden_medical_device_structural(self, medical_device_integration_test):
        """Golden medical-device integration test passes all structural checks."""
        tc = LLMTestCase(
            input="Golden medical-device integration test",
            actual_output=medical_device_integration_test,
        )
        assert_test(tc, [StructuralIntegrationTestMetric(threshold=1.0)])

    @pytest.mark.structural
    def test_golden_automotive_adas_structural(self, automotive_adas_integration_test):
        """Golden automotive-adas integration test passes all structural checks."""
        tc = LLMTestCase(
            input="Golden automotive-adas integration test",
            actual_output=automotive_adas_integration_test,
        )
        assert_test(tc, [StructuralIntegrationTestMetric(threshold=1.0)])


# ---------------------------------------------------------------------------
# LLM-as-judge quality tests (require GOOGLE_API_KEY)
# ---------------------------------------------------------------------------


class TestIntegrationTestQuality:
    """LLM-as-judge evaluation of integration test quality."""

    @pytest.mark.eval
    def test_minimal_integration_coverage_quality(self, fixture_dir):
        """Minimal fixture integration test meets coverage quality bar."""
        test_plan = (
            fixture_dir / "minimal" / "integration-test.md"
        ).read_text()
        design = (
            fixture_dir / "minimal" / "architecture-design.md"
        ).read_text()
        tc = LLMTestCase(
            input=design,
            actual_output=test_plan,
            expected_output=(
                "An integration test plan with ITP test cases covering all ARCH "
                "modules — each with concrete ITS scenarios verifying specific "
                "module-boundary interactions with measurable outcomes."
            ),
        )
        metric = create_integration_coverage_quality_metric(threshold=0.7)
        assert_test(tc, [metric])

    @pytest.mark.eval
    def test_minimal_technique_appropriateness(self, fixture_dir):
        """Minimal fixture uses appropriate integration techniques for each module boundary."""
        test_plan = (
            fixture_dir / "minimal" / "integration-test.md"
        ).read_text()
        tc = LLMTestCase(
            input="Integration test plan for sensor monitoring architecture modules",
            actual_output=test_plan,
            expected_output=(
                "An integration test plan where each test case uses a technique "
                "appropriate for the module boundary under test — Interface "
                "Contract Testing for API contracts, Data Flow Testing for "
                "transformation chains, Interface Fault Injection for error "
                "paths, Concurrency for race conditions."
            ),
        )
        metric = create_technique_appropriateness_metric(threshold=0.7)
        assert_test(tc, [metric])

    @pytest.mark.eval
    def test_minimal_scenario_boundary_language(self, fixture_dir):
        """Minimal fixture scenarios focus on module boundaries, not internal logic."""
        test_plan = (
            fixture_dir / "minimal" / "integration-test.md"
        ).read_text()
        tc = LLMTestCase(
            input="Integration test plan for sensor monitoring architecture modules",
            actual_output=test_plan,
            expected_output=(
                "An integration test plan with scenarios that test module "
                "boundaries — handshakes, contracts, and seams — using precise "
                "technical language rather than user-journey phrases. Each "
                "scenario is focused on a specific integration point."
            ),
        )
        metric = create_scenario_boundary_metric(threshold=0.7)
        assert_test(tc, [metric])

    @pytest.mark.eval
    def test_golden_medical_device_integration_quality(
        self, medical_device_architecture_design, medical_device_integration_test
    ):
        """Golden medical-device integration test meets coverage and technique quality bar."""
        tc = LLMTestCase(
            input=medical_device_architecture_design,
            actual_output=medical_device_integration_test,
            expected_output=(
                "An integration test plan covering all medical device ARCH modules "
                "with ITP/ITS test cases using domain-appropriate techniques "
                "(Interface Contract Testing for sensor protocols, Data Flow Testing "
                "for signal processing chains, Interface Fault Injection for failure "
                "modes, Concurrency for concurrent access)."
            ),
        )
        assert_test(tc, [
            create_integration_coverage_quality_metric(threshold=0.7),
            create_technique_appropriateness_metric(threshold=0.7),
        ])

    @pytest.mark.eval
    def test_golden_automotive_adas_integration_quality(
        self, automotive_adas_architecture_design, automotive_adas_integration_test
    ):
        """Golden automotive-adas integration test meets coverage and technique quality bar."""
        tc = LLMTestCase(
            input=automotive_adas_architecture_design,
            actual_output=automotive_adas_integration_test,
            expected_output=(
                "An integration test plan covering all AEB ARCH modules with "
                "ASIL-D rigor, ITP/ITS test cases using Interface Contract Testing "
                "for sensor fusion interfaces, Data Flow Testing for radar/camera "
                "processing chains, Interface Fault Injection for degradation modes, "
                "and Concurrency for real-time timing constraints."
            ),
        )
        assert_test(tc, [
            create_integration_coverage_quality_metric(threshold=0.7),
            create_technique_appropriateness_metric(threshold=0.7),
        ])
