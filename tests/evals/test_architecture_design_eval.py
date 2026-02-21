"""Evaluation test cases for /speckit.v-model.architecture-design output quality.

These tests validate that architecture design documents meet both structural
(ARCH ID format, Kruchten 4+1 views, parent SYS references) and qualitative
(completeness, view quality, interface contract strictness) standards.
"""

import pytest
from deepeval import assert_test
from deepeval.test_case import LLMTestCase

from tests.evals.metrics.structural import StructuralArchitectureDesignMetric
from tests.evals.metrics.architecture_design_quality import (
    create_architecture_completeness_metric,
    create_view_quality_metric,
    create_interface_contract_metric,
)


# ---------------------------------------------------------------------------
# Structural tests (deterministic, no LLM calls)
# ---------------------------------------------------------------------------


class TestArchitectureDesignStructural:
    """Deterministic structural validation of architecture design documents."""

    @pytest.mark.structural
    def test_minimal_arch_id_compliance(self, fixture_dir):
        """All ARCH IDs in minimal fixture follow ARCH-NNN format."""
        design = (fixture_dir / "minimal" / "architecture-design.md").read_text()
        tc = LLMTestCase(
            input="Minimal architecture design fixture",
            actual_output=design,
        )
        metric = StructuralArchitectureDesignMetric(threshold=0.95)
        metric.measure(tc)
        assert all(
            "Malformed ARCH ID" not in (metric.reason or "")
            for _ in [None]
        ), f"ARCH ID format issues: {metric.reason}"

    @pytest.mark.structural
    def test_minimal_parent_sys_references(self, fixture_dir):
        """Every ARCH row in minimal fixture references at least one parent SYS."""
        design = (fixture_dir / "minimal" / "architecture-design.md").read_text()
        tc = LLMTestCase(
            input="Minimal architecture design fixture",
            actual_output=design,
        )
        metric = StructuralArchitectureDesignMetric(threshold=0.0)
        metric.measure(tc)
        assert "has no parent SYS reference" not in (metric.reason or ""), (
            f"Missing parent SYS references: {metric.reason}"
        )

    @pytest.mark.structural
    def test_complex_structural_compliance(self, fixture_dir):
        """Complex fixture passes architecture design structural checks."""
        design = (fixture_dir / "complex" / "architecture-design.md").read_text()
        tc = LLMTestCase(
            input="Complex architecture design fixture",
            actual_output=design,
        )
        metric = StructuralArchitectureDesignMetric(threshold=0.95)
        metric.measure(tc)
        assert all(
            "Malformed ARCH ID" not in (metric.reason or "")
            for _ in [None]
        ), f"ARCH ID format issues: {metric.reason}"

    @pytest.mark.structural
    def test_golden_medical_device_structural(self, medical_device_architecture_design):
        """Golden medical-device architecture design passes all structural checks."""
        tc = LLMTestCase(
            input="Golden medical-device architecture design",
            actual_output=medical_device_architecture_design,
        )
        assert_test(tc, [StructuralArchitectureDesignMetric(threshold=1.0)])

    @pytest.mark.structural
    def test_golden_automotive_adas_structural(self, automotive_adas_architecture_design):
        """Golden automotive-adas architecture design passes all structural checks."""
        tc = LLMTestCase(
            input="Golden automotive-adas architecture design",
            actual_output=automotive_adas_architecture_design,
        )
        assert_test(tc, [StructuralArchitectureDesignMetric(threshold=1.0)])


# ---------------------------------------------------------------------------
# LLM-as-judge quality tests (require GOOGLE_API_KEY)
# ---------------------------------------------------------------------------


class TestArchitectureDesignQuality:
    """LLM-as-judge evaluation of architecture design quality using Kruchten 4+1 criteria."""

    @pytest.mark.eval
    def test_minimal_architecture_completeness(self, fixture_dir):
        """Minimal fixture architecture design meets decomposition completeness bar."""
        design = (fixture_dir / "minimal" / "architecture-design.md").read_text()
        sys_design = (fixture_dir / "minimal" / "system-design.md").read_text()
        tc = LLMTestCase(
            input=sys_design,
            actual_output=design,
            expected_output=(
                "An architecture design document with ARCH-NNN modules that decompose "
                "all SYS components into distinct architecture modules with clear "
                "parent SYS traceability and cross-cutting concern identification."
            ),
        )
        metric = create_architecture_completeness_metric(threshold=0.7)
        assert_test(tc, [metric])

    @pytest.mark.eval
    def test_minimal_view_quality(self, fixture_dir):
        """Minimal fixture architecture design views are meaningful, not boilerplate."""
        design = (fixture_dir / "minimal" / "architecture-design.md").read_text()
        tc = LLMTestCase(
            input="Architecture design for a minimal sensor monitoring system",
            actual_output=design,
            expected_output=(
                "A Kruchten 4+1 architecture design with substantive views "
                "including Logical with typed modules, Process with Mermaid "
                "diagrams, Interface with contracts, and Data Flow with "
                "transformation descriptions — each providing unique technical "
                "information."
            ),
        )
        metric = create_view_quality_metric(threshold=0.7)
        assert_test(tc, [metric])

    @pytest.mark.eval
    def test_minimal_interface_contract_quality(self, fixture_dir):
        """Minimal fixture defines strict interface contracts."""
        design = (fixture_dir / "minimal" / "architecture-design.md").read_text()
        tc = LLMTestCase(
            input="Architecture design for a minimal sensor monitoring system",
            actual_output=design,
            expected_output=(
                "An architecture design with strict interface contracts that "
                "define specific inputs, outputs, data types, error conditions, "
                "and protocols for each module boundary — not just prose "
                "descriptions."
            ),
        )
        metric = create_interface_contract_metric(threshold=0.7)
        assert_test(tc, [metric])

    @pytest.mark.eval
    def test_golden_medical_device_architecture_completeness(
        self, medical_device_system_design, medical_device_architecture_design
    ):
        """Golden medical-device architecture design meets completeness bar."""
        tc = LLMTestCase(
            input=medical_device_system_design,
            actual_output=medical_device_architecture_design,
            expected_output=(
                "A Kruchten 4+1 architecture design decomposing all medical device "
                "SYS components (Glucose Sensor Interface, Signal Processing Engine, "
                "Alert Manager, BLE Communication Module, Data Storage Manager) into "
                "ARCH-NNN modules with four architectural views, parent SYS "
                "traceability, and cross-cutting concerns."
            ),
        )
        assert_test(tc, [
            create_architecture_completeness_metric(threshold=0.7),
            create_view_quality_metric(threshold=0.7),
        ])

    @pytest.mark.eval
    def test_golden_automotive_adas_architecture_completeness(
        self, automotive_adas_system_design, automotive_adas_architecture_design
    ):
        """Golden automotive-adas architecture design meets completeness bar."""
        tc = LLMTestCase(
            input=automotive_adas_system_design,
            actual_output=automotive_adas_architecture_design,
            expected_output=(
                "A Kruchten 4+1 architecture design decomposing all AEB SYS "
                "components (Radar Processing Unit, Camera Processing Unit, Sensor "
                "Fusion Engine, Braking Controller, Fault Manager) into ARCH-NNN "
                "modules with ASIL-D safety constraints, four architectural views, "
                "and cross-cutting concerns."
            ),
        )
        assert_test(tc, [
            create_architecture_completeness_metric(threshold=0.7),
            create_view_quality_metric(threshold=0.7),
        ])
