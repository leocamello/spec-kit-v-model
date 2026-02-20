"""End-to-end evaluation: /speckit.v-model.system-test command.

Invokes the system-test command via the E2E harness (LLM call),
then judges the output with both structural and quality metrics.

Requires GOOGLE_API_KEY environment variable.
"""

import pytest
from deepeval import assert_test
from deepeval.test_case import LLMTestCase

from tests.evals.harness import invoke
from tests.evals.metrics.structural import StructuralSystemTestMetric
from tests.evals.metrics.system_test_quality import (
    create_test_coverage_quality_metric,
    create_technique_appropriateness_metric,
)


class TestE2ESystemTest:
    """End-to-end tests: invoke system-test command → judge output."""

    @pytest.mark.e2e
    def test_medical_device_structural(
        self, medical_device_requirements, medical_device_system_design
    ):
        """Invoke system-test command with medical-device design, validate structure."""
        output = invoke(
            "system-test",
            context_files={
                "requirements.md": medical_device_requirements,
                "system-design.md": medical_device_system_design,
            },
            arguments="Generate system tests for this medical device system design",
        )
        tc = LLMTestCase(
            input=medical_device_system_design,
            actual_output=output,
        )
        assert_test(tc, [StructuralSystemTestMetric(threshold=0.90)])

    @pytest.mark.e2e
    def test_automotive_adas_structural(
        self, automotive_adas_requirements, automotive_adas_system_design
    ):
        """Invoke system-test command with automotive-adas design, validate structure."""
        output = invoke(
            "system-test",
            context_files={
                "requirements.md": automotive_adas_requirements,
                "system-design.md": automotive_adas_system_design,
            },
            arguments="Generate system tests for this automotive AEB system design",
        )
        tc = LLMTestCase(
            input=automotive_adas_system_design,
            actual_output=output,
        )
        assert_test(tc, [StructuralSystemTestMetric(threshold=0.90)])

    @pytest.mark.e2e
    def test_medical_device_quality(
        self, medical_device_requirements, medical_device_system_design
    ):
        """Invoke system-test command with medical-device design, judge quality."""
        output = invoke(
            "system-test",
            context_files={
                "requirements.md": medical_device_requirements,
                "system-design.md": medical_device_system_design,
            },
            arguments="Generate system tests for this medical device system design",
        )
        tc = LLMTestCase(
            input=medical_device_system_design,
            actual_output=output,
            expected_output=(
                "An ISO 29119 system test plan covering all medical device SYS "
                "components (Glucose Sensor Interface, Signal Processing Engine, "
                "Alert Manager, BLE Communication Module, Data Storage Manager) "
                "with STP/STS test cases using domain-appropriate techniques."
            ),
        )
        assert_test(tc, [
            create_test_coverage_quality_metric(threshold=0.7),
            create_technique_appropriateness_metric(threshold=0.7),
        ])

    @pytest.mark.e2e
    def test_automotive_adas_quality(
        self, automotive_adas_requirements, automotive_adas_system_design
    ):
        """Invoke system-test command with automotive-adas design, judge quality."""
        output = invoke(
            "system-test",
            context_files={
                "requirements.md": automotive_adas_requirements,
                "system-design.md": automotive_adas_system_design,
            },
            arguments="Generate system tests for this automotive AEB system design",
        )
        tc = LLMTestCase(
            input=automotive_adas_system_design,
            actual_output=output,
            expected_output=(
                "An ISO 29119 system test plan covering all AEB SYS components "
                "(Radar Processing Unit, Camera Processing Unit, Sensor Fusion "
                "Engine, Braking Controller, Fault Manager) with ASIL-D rigor "
                "and ISO 29119 techniques."
            ),
        )
        assert_test(tc, [
            create_test_coverage_quality_metric(threshold=0.7),
            create_technique_appropriateness_metric(threshold=0.7),
        ])
