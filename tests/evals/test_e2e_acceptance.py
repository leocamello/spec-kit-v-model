"""End-to-end evaluation: /speckit.v-model.acceptance command.

Invokes the acceptance command via the E2E harness (LLM call),
then judges the output with both structural and quality metrics.

Requires GOOGLE_API_KEY environment variable.
"""

import pytest
from deepeval import assert_test
from deepeval.test_case import LLMTestCase

from tests.evals.harness import invoke
from tests.evals.metrics.structural import StructuralBDDMetric, StructuralTemplateMetric
from tests.evals.metrics.bdd_quality import create_bdd_quality_metric


class TestE2EAcceptance:
    """End-to-end tests: invoke acceptance command → judge output."""

    @pytest.mark.e2e
    def test_medical_device_structural(
        self, medical_device_input, medical_device_requirements
    ):
        """Invoke acceptance command with medical-device requirements, validate structure."""
        output = invoke(
            "acceptance",
            context_files={"requirements.md": medical_device_requirements},
            arguments="Generate acceptance test plan for these medical device requirements",
        )
        tc = LLMTestCase(
            input=medical_device_requirements,
            actual_output=output,
        )
        assert_test(tc, [
            StructuralBDDMetric(threshold=0.90),
            StructuralTemplateMetric("acceptance", threshold=0.90),
        ])

    @pytest.mark.e2e
    def test_automotive_adas_structural(
        self, automotive_adas_input, automotive_adas_requirements
    ):
        """Invoke acceptance command with automotive-adas requirements, validate structure."""
        output = invoke(
            "acceptance",
            context_files={"requirements.md": automotive_adas_requirements},
            arguments="Generate acceptance test plan for these automotive AEB requirements",
        )
        tc = LLMTestCase(
            input=automotive_adas_requirements,
            actual_output=output,
        )
        assert_test(tc, [
            StructuralBDDMetric(threshold=0.90),
            StructuralTemplateMetric("acceptance", threshold=0.90),
        ])

    @pytest.mark.e2e
    def test_medical_device_quality(
        self, medical_device_input, medical_device_requirements
    ):
        """Invoke acceptance command with medical-device requirements, judge quality."""
        output = invoke(
            "acceptance",
            context_files={"requirements.md": medical_device_requirements},
            arguments="Generate acceptance test plan for these medical device requirements",
        )
        tc = LLMTestCase(
            input=medical_device_requirements,
            actual_output=output,
            expected_output=(
                "A three-tier acceptance test plan with ATP-NNN-X test cases "
                "and SCN-NNN-X# BDD scenarios covering all medical device "
                "requirements (glucose monitoring, alarms, accuracy, BLE, "
                "data retention) with 100% coverage."
            ),
        )
        assert_test(tc, [create_bdd_quality_metric(threshold=0.7)])

    @pytest.mark.e2e
    def test_automotive_adas_quality(
        self, automotive_adas_input, automotive_adas_requirements
    ):
        """Invoke acceptance command with automotive-adas requirements, judge quality."""
        output = invoke(
            "acceptance",
            context_files={"requirements.md": automotive_adas_requirements},
            arguments="Generate acceptance test plan for these automotive AEB requirements",
        )
        tc = LLMTestCase(
            input=automotive_adas_requirements,
            actual_output=output,
            expected_output=(
                "A three-tier acceptance test plan with ATP-NNN-X test cases "
                "and SCN-NNN-X# BDD scenarios covering all AEB requirements "
                "(collision detection, braking, false positive rate, interfaces, "
                "fail-safe) with 100% coverage."
            ),
        )
        assert_test(tc, [create_bdd_quality_metric(threshold=0.7)])
