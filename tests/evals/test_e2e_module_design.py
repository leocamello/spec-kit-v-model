"""End-to-end evaluation: /speckit.v-model.module-design command.

Invokes the module-design command via the E2E harness (LLM call),
then judges the output with both structural and quality metrics.

Requires GOOGLE_API_KEY environment variable.
"""

import pytest
from deepeval import assert_test
from deepeval.test_case import LLMTestCase

from tests.evals.harness import invoke
from tests.evals.metrics.structural import StructuralModuleDesignMetric
from tests.evals.metrics.module_design_quality import (
    create_module_completeness_metric,
    create_logic_quality_metric,
)


class TestE2EModuleDesign:
    """End-to-end tests: invoke module-design command → judge output."""

    @pytest.mark.e2e
    def test_medical_device_structural(self, medical_device_architecture_design):
        """Invoke module-design command with medical-device architecture, validate structure."""
        output = invoke(
            "module-design",
            context_files={"architecture-design.md": medical_device_architecture_design},
            arguments="Generate module design for this architecture design",
        )
        tc = LLMTestCase(
            input=medical_device_architecture_design,
            actual_output=output,
        )
        assert_test(tc, [StructuralModuleDesignMetric(threshold=0.90)])

    @pytest.mark.e2e
    def test_automotive_adas_structural(self, automotive_adas_architecture_design):
        """Invoke module-design command with automotive-adas architecture, validate structure."""
        output = invoke(
            "module-design",
            context_files={"architecture-design.md": automotive_adas_architecture_design},
            arguments="Generate module design for this architecture design",
        )
        tc = LLMTestCase(
            input=automotive_adas_architecture_design,
            actual_output=output,
        )
        assert_test(tc, [StructuralModuleDesignMetric(threshold=0.90)])

    @pytest.mark.e2e
    def test_medical_device_quality(self, medical_device_architecture_design):
        """Invoke module-design command with medical-device architecture, judge quality."""
        output = invoke(
            "module-design",
            context_files={"architecture-design.md": medical_device_architecture_design},
            arguments="Generate module design for this architecture design",
        )
        tc = LLMTestCase(
            input=medical_device_architecture_design,
            actual_output=output,
            expected_output=(
                "A module design decomposing all medical device ARCH modules "
                "into MOD-NNN modules with pseudocode, state machines, data "
                "structures, and error handling for each — with parent ARCH "
                "traceability and target source files."
            ),
        )
        assert_test(tc, [
            create_module_completeness_metric(threshold=0.7),
            create_logic_quality_metric(threshold=0.7),
        ])

    @pytest.mark.e2e
    def test_automotive_adas_quality(self, automotive_adas_architecture_design):
        """Invoke module-design command with automotive-adas architecture, judge quality."""
        output = invoke(
            "module-design",
            context_files={"architecture-design.md": automotive_adas_architecture_design},
            arguments="Generate module design for this architecture design",
        )
        tc = LLMTestCase(
            input=automotive_adas_architecture_design,
            actual_output=output,
            expected_output=(
                "A module design decomposing all AEB ARCH modules into MOD-NNN "
                "modules with ASIL-D safety constraints, pseudocode, state "
                "machines, data structures, and error handling."
            ),
        )
        assert_test(tc, [
            create_module_completeness_metric(threshold=0.7),
            create_logic_quality_metric(threshold=0.7),
        ])
