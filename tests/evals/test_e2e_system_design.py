"""End-to-end evaluation: /speckit.v-model.system-design command.

Invokes the system-design command via the E2E harness (LLM call),
then judges the output with both structural and quality metrics.

Requires GOOGLE_API_KEY environment variable.
"""

import pytest
from deepeval import assert_test
from deepeval.test_case import LLMTestCase

from tests.evals.harness import invoke
from tests.evals.metrics.structural import StructuralSystemDesignMetric
from tests.evals.metrics.system_design_quality import (
    create_design_completeness_metric,
    create_view_quality_metric,
)


class TestE2ESystemDesign:
    """End-to-end tests: invoke system-design command → judge output."""

    @pytest.mark.e2e
    def test_medical_device_structural(self, medical_device_requirements):
        """Invoke system-design command with medical-device requirements, validate structure."""
        output = invoke(
            "system-design",
            context_files={"requirements.md": medical_device_requirements},
            arguments="Decompose these medical device requirements into system components",
        )
        tc = LLMTestCase(
            input=medical_device_requirements,
            actual_output=output,
        )
        assert_test(tc, [StructuralSystemDesignMetric(threshold=0.90)])

    @pytest.mark.e2e
    def test_automotive_adas_structural(self, automotive_adas_requirements):
        """Invoke system-design command with automotive-adas requirements, validate structure."""
        output = invoke(
            "system-design",
            context_files={"requirements.md": automotive_adas_requirements},
            arguments="Decompose these automotive AEB requirements into system components",
        )
        tc = LLMTestCase(
            input=automotive_adas_requirements,
            actual_output=output,
        )
        assert_test(tc, [StructuralSystemDesignMetric(threshold=0.90)])

    @pytest.mark.e2e
    def test_medical_device_quality(self, medical_device_requirements):
        """Invoke system-design command with medical-device requirements, judge quality."""
        output = invoke(
            "system-design",
            context_files={"requirements.md": medical_device_requirements},
            arguments="Decompose these medical device requirements into system components",
        )
        tc = LLMTestCase(
            input=medical_device_requirements,
            actual_output=output,
            expected_output=(
                "An IEEE 1016 system design decomposing all medical device "
                "requirements (glucose sampling, alarms, accuracy, BLE, data "
                "retention) into distinct SYS-NNN components with four "
                "architectural views and parent REQ traceability."
            ),
        )
        assert_test(tc, [
            create_design_completeness_metric(threshold=0.7),
            create_view_quality_metric(threshold=0.7),
        ])

    @pytest.mark.e2e
    def test_automotive_adas_quality(self, automotive_adas_requirements):
        """Invoke system-design command with automotive-adas requirements, judge quality."""
        output = invoke(
            "system-design",
            context_files={"requirements.md": automotive_adas_requirements},
            arguments="Decompose these automotive AEB requirements into system components",
        )
        tc = LLMTestCase(
            input=automotive_adas_requirements,
            actual_output=output,
            expected_output=(
                "An IEEE 1016 system design decomposing all AEB requirements "
                "(collision detection, braking, false positive rate, sensor "
                "interfaces, fail-safe degradation) into distinct SYS-NNN "
                "components with ASIL-D safety constraints and four views."
            ),
        )
        assert_test(tc, [
            create_design_completeness_metric(threshold=0.7),
            create_view_quality_metric(threshold=0.7),
        ])
