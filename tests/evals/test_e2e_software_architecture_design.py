"""End-to-end evaluation: /speckit.v-model.software-architecture-design command.

Invokes the software-architecture-design command via the E2E harness (LLM call),
then judges the output with both structural and quality metrics.

Requires GOOGLE_API_KEY environment variable.
"""

import pytest
from deepeval import assert_test
from deepeval.test_case import LLMTestCase

from tests.evals.harness import invoke
from tests.evals.metrics.structural import StructuralSoftwareArchitectureDesignMetric
from tests.evals.metrics.software_architecture_design_quality import (
    create_design_completeness_metric,
    create_view_quality_metric,
)


class TestE2ESoftwareArchitectureDesign:
    """End-to-end tests: invoke software-architecture-design command → judge output."""

    @pytest.mark.e2e
    def test_medical_device_structural(self, medical_device_requirements):
        """Invoke software-architecture-design with medical-device requirements, validate structure."""
        output = invoke(
            "software-architecture-design",
            context_files={"requirements.md": medical_device_requirements},
            arguments="Decompose these medical device requirements into architecture modules",
        )
        tc = LLMTestCase(
            input=medical_device_requirements,
            actual_output=output,
        )
        assert_test(tc, [StructuralSoftwareArchitectureDesignMetric(threshold=0.90)])

    @pytest.mark.e2e
    def test_automotive_adas_structural(self, automotive_adas_requirements):
        """Invoke software-architecture-design with automotive-adas requirements, validate structure."""
        output = invoke(
            "software-architecture-design",
            context_files={"requirements.md": automotive_adas_requirements},
            arguments="Decompose these automotive AEB requirements into architecture modules",
        )
        tc = LLMTestCase(
            input=automotive_adas_requirements,
            actual_output=output,
        )
        assert_test(tc, [StructuralSoftwareArchitectureDesignMetric(threshold=0.90)])

    @pytest.mark.e2e
    def test_medical_device_quality(self, medical_device_requirements):
        """Invoke software-architecture-design with medical-device requirements, judge quality."""
        output = invoke(
            "software-architecture-design",
            context_files={"requirements.md": medical_device_requirements},
            arguments="Decompose these medical device requirements into architecture modules",
        )
        tc = LLMTestCase(
            input=medical_device_requirements,
            actual_output=output,
            expected_output=(
                "An IEEE 42010 software architecture design decomposing all "
                "medical device requirements (glucose sampling, alarms, accuracy, "
                "BLE, data retention) into ARCH-NNN modules with four architectural "
                "views, parent REQ traceability, and cross-cutting concerns."
            ),
        )
        assert_test(tc, [
            create_design_completeness_metric(threshold=0.7),
            create_view_quality_metric(threshold=0.7),
        ])

    @pytest.mark.e2e
    def test_automotive_adas_quality(self, automotive_adas_requirements):
        """Invoke software-architecture-design with automotive-adas requirements, judge quality."""
        output = invoke(
            "software-architecture-design",
            context_files={"requirements.md": automotive_adas_requirements},
            arguments="Decompose these automotive AEB requirements into architecture modules",
        )
        tc = LLMTestCase(
            input=automotive_adas_requirements,
            actual_output=output,
            expected_output=(
                "An IEEE 42010 software architecture design decomposing all "
                "AEB requirements (collision detection, braking, false positive "
                "rate, sensor interfaces, fail-safe degradation) into ARCH-NNN "
                "modules with four architectural views and parent REQ traceability."
            ),
        )
        assert_test(tc, [
            create_design_completeness_metric(threshold=0.7),
            create_view_quality_metric(threshold=0.7),
        ])
