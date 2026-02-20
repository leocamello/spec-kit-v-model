"""End-to-end evaluation: /speckit.v-model.requirements command.

Invokes the requirements command via the E2E harness (LLM call),
then judges the output with both structural and quality metrics.

Requires GOOGLE_API_KEY environment variable.
"""

import pytest
from deepeval import assert_test
from deepeval.test_case import LLMTestCase

from tests.evals.harness import invoke
from tests.evals.metrics.structural import StructuralTemplateMetric
from tests.evals.metrics.requirements_quality import create_requirements_quality_metric


class TestE2ERequirements:
    """End-to-end tests: invoke requirements command → judge output."""

    @pytest.mark.e2e
    def test_medical_device_structural(self, medical_device_input):
        """Invoke requirements command with medical-device spec, validate structure."""
        output = invoke(
            "requirements",
            context_files={"spec.md": medical_device_input},
            arguments="Generate V-Model requirements from this medical device spec",
        )
        tc = LLMTestCase(
            input=medical_device_input,
            actual_output=output,
        )
        assert_test(tc, [
            StructuralTemplateMetric("requirements", threshold=0.90),
        ])

    @pytest.mark.e2e
    def test_automotive_adas_structural(self, automotive_adas_input):
        """Invoke requirements command with automotive-adas spec, validate structure."""
        output = invoke(
            "requirements",
            context_files={"spec.md": automotive_adas_input},
            arguments="Generate V-Model requirements from this automotive AEB spec",
        )
        tc = LLMTestCase(
            input=automotive_adas_input,
            actual_output=output,
        )
        assert_test(tc, [
            StructuralTemplateMetric("requirements", threshold=0.90),
        ])

    @pytest.mark.e2e
    def test_medical_device_quality(self, medical_device_input):
        """Invoke requirements command with medical-device spec, judge quality."""
        output = invoke(
            "requirements",
            context_files={"spec.md": medical_device_input},
            arguments="Generate V-Model requirements from this medical device spec",
        )
        tc = LLMTestCase(
            input=medical_device_input,
            actual_output=output,
            expected_output=(
                "A requirements specification with traceable REQ-NNN items "
                "covering glucose monitoring, alarms, accuracy, BLE connectivity, "
                "and data retention — all with IEEE 29148 quality attributes "
                "(unambiguous, testable, atomic, complete)."
            ),
        )
        assert_test(tc, [create_requirements_quality_metric(threshold=0.7)])

    @pytest.mark.e2e
    def test_automotive_adas_quality(self, automotive_adas_input):
        """Invoke requirements command with automotive-adas spec, judge quality."""
        output = invoke(
            "requirements",
            context_files={"spec.md": automotive_adas_input},
            arguments="Generate V-Model requirements from this automotive AEB spec",
        )
        tc = LLMTestCase(
            input=automotive_adas_input,
            actual_output=output,
            expected_output=(
                "A requirements specification with traceable REQ-NNN items "
                "covering sensor fusion, emergency braking, false positive rate, "
                "CAN-FD/Ethernet interfaces, and fail-safe degradation — all with "
                "IEEE 29148 quality attributes."
            ),
        )
        assert_test(tc, [create_requirements_quality_metric(threshold=0.7)])
