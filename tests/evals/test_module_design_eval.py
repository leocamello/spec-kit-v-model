"""Evaluation test cases for /speckit.v-model.module-design output quality.

These tests validate that module design documents meet both structural
(MOD ID format, pseudocode blocks, 4 views, parent ARCH references) and
qualitative (completeness, logic quality, data structure precision) standards.
"""

import pytest
from deepeval import assert_test
from deepeval.test_case import LLMTestCase

from tests.evals.metrics.structural import StructuralModuleDesignMetric
from tests.evals.metrics.module_design_quality import (
    create_module_completeness_metric,
    create_logic_quality_metric,
    create_data_structure_precision_metric,
)


# ---------------------------------------------------------------------------
# Structural tests (deterministic, no LLM calls)
# ---------------------------------------------------------------------------


class TestModuleDesignStructural:
    """Deterministic structural validation of module design documents."""

    @pytest.mark.structural
    def test_minimal_mod_id_compliance(self, fixture_dir):
        """All MOD IDs in minimal fixture follow MOD-NNN format."""
        design = (fixture_dir / "minimal" / "module-design.md").read_text()
        tc = LLMTestCase(
            input="Minimal module design fixture",
            actual_output=design,
        )
        metric = StructuralModuleDesignMetric(threshold=0.95)
        metric.measure(tc)
        assert "Malformed MOD ID" not in (metric.reason or ""), (
            f"MOD ID format issues: {metric.reason}"
        )

    @pytest.mark.structural
    def test_minimal_parent_arch_references(self, fixture_dir):
        """Every MOD in minimal fixture references at least one parent ARCH."""
        design = (fixture_dir / "minimal" / "module-design.md").read_text()
        tc = LLMTestCase(
            input="Minimal module design fixture",
            actual_output=design,
        )
        metric = StructuralModuleDesignMetric(threshold=0.0)
        metric.measure(tc)
        assert "has no parent ARCH reference" not in (metric.reason or ""), (
            f"Missing parent ARCH references: {metric.reason}"
        )

    @pytest.mark.structural
    def test_minimal_pseudocode_blocks(self, fixture_dir):
        """Minimal fixture contains pseudocode blocks."""
        design = (fixture_dir / "minimal" / "module-design.md").read_text()
        tc = LLMTestCase(
            input="Minimal module design fixture",
            actual_output=design,
        )
        metric = StructuralModuleDesignMetric(threshold=0.0)
        metric.measure(tc)
        assert "No ```pseudocode blocks" not in (metric.reason or ""), (
            f"Missing pseudocode blocks: {metric.reason}"
        )

    @pytest.mark.structural
    def test_minimal_required_views(self, fixture_dir):
        """Minimal fixture contains all 4 required views."""
        design = (fixture_dir / "minimal" / "module-design.md").read_text()
        tc = LLMTestCase(
            input="Minimal module design fixture",
            actual_output=design,
        )
        metric = StructuralModuleDesignMetric(threshold=0.0)
        metric.measure(tc)
        assert "Missing view:" not in (metric.reason or ""), (
            f"Missing views: {metric.reason}"
        )

    @pytest.mark.structural
    def test_complex_structural_compliance(self, fixture_dir):
        """Complex fixture passes module design structural checks."""
        design = (fixture_dir / "complex" / "module-design.md").read_text()
        tc = LLMTestCase(
            input="Complex module design fixture",
            actual_output=design,
        )
        assert_test(tc, [StructuralModuleDesignMetric(threshold=0.95)])

    @pytest.mark.structural
    def test_golden_medical_device_structural(self, medical_device_module_design):
        """Golden medical-device module design passes all structural checks."""
        tc = LLMTestCase(
            input="Golden medical-device module design",
            actual_output=medical_device_module_design,
        )
        assert_test(tc, [StructuralModuleDesignMetric(threshold=1.0)])

    @pytest.mark.structural
    def test_golden_automotive_adas_structural(self, automotive_adas_module_design):
        """Golden automotive-adas module design passes all structural checks."""
        tc = LLMTestCase(
            input="Golden automotive-adas module design",
            actual_output=automotive_adas_module_design,
        )
        assert_test(tc, [StructuralModuleDesignMetric(threshold=1.0)])


# ---------------------------------------------------------------------------
# LLM-as-judge quality tests (require GOOGLE_API_KEY)
# ---------------------------------------------------------------------------


class TestModuleDesignQuality:
    """LLM-as-judge evaluation of module design quality."""

    @pytest.mark.eval
    def test_minimal_module_completeness(self, fixture_dir):
        """Minimal fixture module design meets decomposition completeness bar."""
        design = (fixture_dir / "minimal" / "module-design.md").read_text()
        arch_design = (fixture_dir / "minimal" / "architecture-design.md").read_text()
        tc = LLMTestCase(
            input=arch_design,
            actual_output=design,
            expected_output=(
                "A module design document with MOD-NNN modules that decompose "
                "all ARCH modules into detailed modules with pseudocode, 4 views, "
                "parent ARCH traceability, and target source file mapping."
            ),
        )
        metric = create_module_completeness_metric(threshold=0.7)
        assert_test(tc, [metric])

    @pytest.mark.eval
    def test_minimal_logic_quality(self, fixture_dir):
        """Minimal fixture module design logic is precise, not boilerplate."""
        design = (fixture_dir / "minimal" / "module-design.md").read_text()
        tc = LLMTestCase(
            input="Module design for a minimal sensor monitoring system",
            actual_output=design,
            expected_output=(
                "A module design with substantive pseudocode blocks containing "
                "typed parameters, clear control flow, concrete algorithms — "
                "not vague prose or empty placeholders. Stateful modules have "
                "complete state machine diagrams."
            ),
        )
        metric = create_logic_quality_metric(threshold=0.7)
        assert_test(tc, [metric])

    @pytest.mark.eval
    def test_minimal_data_structure_precision(self, fixture_dir):
        """Minimal fixture module design data structures are precise."""
        design = (fixture_dir / "minimal" / "module-design.md").read_text()
        tc = LLMTestCase(
            input="Module design for a minimal sensor monitoring system",
            actual_output=design,
            expected_output=(
                "A module design with precise Internal Data Structures sections "
                "defining all data types with field names, types, and constraints. "
                "Error Handling sections enumerate concrete error conditions and "
                "return codes."
            ),
        )
        metric = create_data_structure_precision_metric(threshold=0.7)
        assert_test(tc, [metric])

    @pytest.mark.eval
    def test_golden_medical_device_module_completeness(
        self, medical_device_architecture_design, medical_device_module_design
    ):
        """Golden medical-device module design meets completeness bar."""
        tc = LLMTestCase(
            input=medical_device_architecture_design,
            actual_output=medical_device_module_design,
            expected_output=(
                "A module design decomposing all medical device ARCH modules "
                "(Glucose Sensor Interface, Signal Processing Engine, Alert "
                "Manager, BLE Communication Module, Data Storage Manager) into "
                "MOD-NNN modules with pseudocode, state machines, data structures, "
                "and error handling for each."
            ),
        )
        assert_test(tc, [
            create_module_completeness_metric(threshold=0.7),
            create_logic_quality_metric(threshold=0.7),
        ])

    @pytest.mark.eval
    def test_golden_automotive_adas_module_completeness(
        self, automotive_adas_architecture_design, automotive_adas_module_design
    ):
        """Golden automotive-adas module design meets completeness bar."""
        tc = LLMTestCase(
            input=automotive_adas_architecture_design,
            actual_output=automotive_adas_module_design,
            expected_output=(
                "A module design decomposing all AEB ARCH modules (Radar "
                "Processing Unit, Camera Processing Unit, Sensor Fusion Engine, "
                "Braking Controller, Fault Manager) into MOD-NNN modules with "
                "ASIL-D safety constraints, pseudocode, state machines, and "
                "error handling."
            ),
        )
        assert_test(tc, [
            create_module_completeness_metric(threshold=0.7),
            create_logic_quality_metric(threshold=0.7),
        ])
