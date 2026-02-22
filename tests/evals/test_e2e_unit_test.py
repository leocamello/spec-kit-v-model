"""End-to-end evaluation: /speckit.v-model.unit-test command.

Invokes the unit-test command via the E2E harness (LLM call),
then judges the output with both structural and quality metrics.

Requires GOOGLE_API_KEY environment variable.
"""

import pytest
from deepeval import assert_test
from deepeval.test_case import LLMTestCase

from tests.evals.harness import invoke
from tests.evals.metrics.structural import StructuralUnitTestMetric
from tests.evals.metrics.unit_test_quality import (
    create_unit_coverage_quality_metric,
    create_technique_appropriateness_metric,
)


class TestE2EUnitTest:
    """End-to-end tests: invoke unit-test command → judge output."""

    @pytest.mark.e2e
    def test_medical_device_structural(self, medical_device_module_design):
        """Invoke unit-test command with medical-device module design, validate structure."""
        output = invoke(
            "unit-test",
            context_files={"module-design.md": medical_device_module_design},
            arguments="Generate unit tests for this module design",
        )
        tc = LLMTestCase(
            input=medical_device_module_design,
            actual_output=output,
        )
        assert_test(tc, [StructuralUnitTestMetric(threshold=0.90)])

    @pytest.mark.e2e
    def test_automotive_adas_structural(self, automotive_adas_module_design):
        """Invoke unit-test command with automotive-adas module design, validate structure."""
        output = invoke(
            "unit-test",
            context_files={"module-design.md": automotive_adas_module_design},
            arguments="Generate unit tests for this module design",
        )
        tc = LLMTestCase(
            input=automotive_adas_module_design,
            actual_output=output,
        )
        assert_test(tc, [StructuralUnitTestMetric(threshold=0.90)])

    @pytest.mark.e2e
    def test_medical_device_quality(self, medical_device_module_design):
        """Invoke unit-test command with medical-device module design, judge quality."""
        output = invoke(
            "unit-test",
            context_files={"module-design.md": medical_device_module_design},
            arguments="Generate unit tests for this module design",
        )
        tc = LLMTestCase(
            input=medical_device_module_design,
            actual_output=output,
            expected_output=(
                "A unit test plan covering all medical device MOD modules with "
                "UTP/UTS test cases using domain-appropriate techniques and "
                "strict isolation via mock registries."
            ),
        )
        assert_test(tc, [
            create_unit_coverage_quality_metric(threshold=0.7),
            create_technique_appropriateness_metric(threshold=0.7),
        ])

    @pytest.mark.e2e
    def test_automotive_adas_quality(self, automotive_adas_module_design):
        """Invoke unit-test command with automotive-adas module design, judge quality."""
        output = invoke(
            "unit-test",
            context_files={"module-design.md": automotive_adas_module_design},
            arguments="Generate unit tests for this module design",
        )
        tc = LLMTestCase(
            input=automotive_adas_module_design,
            actual_output=output,
            expected_output=(
                "A unit test plan covering all AEB MOD modules with ASIL-D "
                "rigor, UTP/UTS test cases using Statement & Branch Coverage, "
                "MC/DC Coverage, Boundary Value Analysis, and strict isolation."
            ),
        )
        assert_test(tc, [
            create_unit_coverage_quality_metric(threshold=0.7),
            create_technique_appropriateness_metric(threshold=0.7),
        ])
