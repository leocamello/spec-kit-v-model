"""End-to-end evaluation: /speckit.v-model.architecture-design command.

Invokes the architecture-design command via the E2E harness (LLM call),
then judges the output with both structural and quality metrics.

Requires GOOGLE_API_KEY environment variable.
"""

import pytest
from deepeval import assert_test
from deepeval.test_case import LLMTestCase

from tests.evals.harness import invoke
from tests.evals.metrics.structural import StructuralArchitectureDesignMetric
from tests.evals.metrics.architecture_design_quality import (
    create_architecture_completeness_metric,
    create_view_quality_metric,
)


class TestE2EArchitectureDesign:
    """End-to-end tests: invoke architecture-design command → judge output."""

    @pytest.mark.e2e
    def test_medical_device_structural(self, medical_device_system_design):
        """Invoke architecture-design command with medical-device system design, validate structure."""
        output = invoke(
            "architecture-design",
            context_files={"system-design.md": medical_device_system_design},
            arguments="Decompose this system design into architecture modules",
        )
        tc = LLMTestCase(
            input=medical_device_system_design,
            actual_output=output,
        )
        assert_test(tc, [StructuralArchitectureDesignMetric(threshold=0.90)])

    @pytest.mark.e2e
    def test_automotive_adas_structural(self, automotive_adas_system_design):
        """Invoke architecture-design command with automotive-adas system design, validate structure."""
        output = invoke(
            "architecture-design",
            context_files={"system-design.md": automotive_adas_system_design},
            arguments="Decompose this system design into architecture modules",
        )
        tc = LLMTestCase(
            input=automotive_adas_system_design,
            actual_output=output,
        )
        assert_test(tc, [StructuralArchitectureDesignMetric(threshold=0.90)])

    @pytest.mark.e2e
    def test_medical_device_quality(self, medical_device_system_design):
        """Invoke architecture-design command with medical-device system design, judge quality."""
        output = invoke(
            "architecture-design",
            context_files={"system-design.md": medical_device_system_design},
            arguments="Decompose this system design into architecture modules",
        )
        tc = LLMTestCase(
            input=medical_device_system_design,
            actual_output=output,
            expected_output=(
                "A Kruchten 4+1 architecture design decomposing all medical device "
                "SYS components into ARCH-NNN modules with four architectural "
                "views, parent SYS traceability, and cross-cutting concerns."
            ),
        )
        assert_test(tc, [
            create_architecture_completeness_metric(threshold=0.7),
            create_view_quality_metric(threshold=0.7),
        ])

    @pytest.mark.e2e
    def test_automotive_adas_quality(self, automotive_adas_system_design):
        """Invoke architecture-design command with automotive-adas system design, judge quality."""
        output = invoke(
            "architecture-design",
            context_files={"system-design.md": automotive_adas_system_design},
            arguments="Decompose this system design into architecture modules",
        )
        tc = LLMTestCase(
            input=automotive_adas_system_design,
            actual_output=output,
            expected_output=(
                "A Kruchten 4+1 architecture design decomposing all AEB SYS "
                "components into ARCH-NNN modules with ASIL-D safety constraints, "
                "four architectural views, and cross-cutting concerns."
            ),
        )
        assert_test(tc, [
            create_architecture_completeness_metric(threshold=0.7),
            create_view_quality_metric(threshold=0.7),
        ])
