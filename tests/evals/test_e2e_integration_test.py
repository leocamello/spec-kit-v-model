"""End-to-end evaluation: /speckit.v-model.integration-test command.

Invokes the integration-test command via the E2E harness (LLM call),
then judges the output with both structural and quality metrics.

Requires GOOGLE_API_KEY environment variable.
"""

import pytest
from deepeval import assert_test
from deepeval.test_case import LLMTestCase

from tests.evals.harness import invoke
from tests.evals.metrics.structural import StructuralIntegrationTestMetric
from tests.evals.metrics.integration_test_quality import (
    create_integration_coverage_quality_metric,
    create_technique_appropriateness_metric,
)


class TestE2EIntegrationTest:
    """End-to-end tests: invoke integration-test command → judge output."""

    @pytest.mark.e2e
    def test_medical_device_structural(self, medical_device_architecture_design):
        """Invoke integration-test command with medical-device architecture design, validate structure."""
        output = invoke(
            "integration-test",
            context_files={"architecture-design.md": medical_device_architecture_design},
            arguments="Generate integration tests for this architecture design",
        )
        tc = LLMTestCase(
            input=medical_device_architecture_design,
            actual_output=output,
        )
        assert_test(tc, [StructuralIntegrationTestMetric(threshold=0.90)])

    @pytest.mark.e2e
    def test_automotive_adas_structural(self, automotive_adas_architecture_design):
        """Invoke integration-test command with automotive-adas architecture design, validate structure."""
        output = invoke(
            "integration-test",
            context_files={"architecture-design.md": automotive_adas_architecture_design},
            arguments="Generate integration tests for this architecture design",
        )
        tc = LLMTestCase(
            input=automotive_adas_architecture_design,
            actual_output=output,
        )
        assert_test(tc, [StructuralIntegrationTestMetric(threshold=0.90)])

    @pytest.mark.e2e
    def test_medical_device_quality(self, medical_device_architecture_design):
        """Invoke integration-test command with medical-device architecture design, judge quality."""
        output = invoke(
            "integration-test",
            context_files={"architecture-design.md": medical_device_architecture_design},
            arguments="Generate integration tests for this architecture design",
        )
        tc = LLMTestCase(
            input=medical_device_architecture_design,
            actual_output=output,
            expected_output=(
                "An integration test plan covering all medical device ARCH modules "
                "with ITP/ITS test cases using domain-appropriate techniques "
                "(Interface Contract Testing, Data Flow Testing, Interface Fault "
                "Injection, Concurrency & Race Condition Testing)."
            ),
        )
        assert_test(tc, [
            create_integration_coverage_quality_metric(threshold=0.7),
            create_technique_appropriateness_metric(threshold=0.7),
        ])

    @pytest.mark.e2e
    def test_automotive_adas_quality(self, automotive_adas_architecture_design):
        """Invoke integration-test command with automotive-adas architecture design, judge quality."""
        output = invoke(
            "integration-test",
            context_files={"architecture-design.md": automotive_adas_architecture_design},
            arguments="Generate integration tests for this architecture design",
        )
        tc = LLMTestCase(
            input=automotive_adas_architecture_design,
            actual_output=output,
            expected_output=(
                "An integration test plan covering all AEB ARCH modules with "
                "ASIL-D rigor, ITP/ITS test cases using Interface Contract Testing, "
                "Data Flow Testing, Interface Fault Injection, and Concurrency & "
                "Race Condition Testing."
            ),
        )
        assert_test(tc, [
            create_integration_coverage_quality_metric(threshold=0.7),
            create_technique_appropriateness_metric(threshold=0.7),
        ])
