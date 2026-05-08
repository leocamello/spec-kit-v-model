"""Evaluation test cases for /speckit.v-model.software-architecture-design output quality.

These tests validate that software architecture design documents meet both structural
(ARCH ID format, IEEE 42010 views, parent REQ references — no SYS layer) and
qualitative (completeness, view quality, interface contract strictness) standards.

Software architecture design is the Path B replacement for system-design + architecture-design.
"""

import pytest
from deepeval import assert_test
from deepeval.test_case import LLMTestCase

from tests.evals.metrics.structural import StructuralSoftwareArchitectureDesignMetric
from tests.evals.metrics.software_architecture_design_quality import (
    create_design_completeness_metric,
    create_view_quality_metric,
    create_interface_contract_metric,
)


# ---------------------------------------------------------------------------
# Structural tests (deterministic, no LLM calls)
# ---------------------------------------------------------------------------


class TestSoftwareArchitectureDesignStructural:
    """Deterministic structural validation of software architecture design documents."""

    @pytest.mark.structural
    def test_path_b_fixture_arch_id_compliance(self, fixture_dir):
        """All ARCH IDs in path-b-combined fixture follow ARCH-NNN format."""
        design = (fixture_dir / "path-b-combined" / "software-architecture-design.md").read_text()
        tc = LLMTestCase(
            input="Path B combined fixture",
            actual_output=design,
        )
        metric = StructuralSoftwareArchitectureDesignMetric(threshold=0.95)
        metric.measure(tc)
        assert all(
            "Malformed ARCH ID" not in (metric.reason or "")
            for _ in [None]
        ), f"ARCH ID format issues: {metric.reason}"

    @pytest.mark.structural
    def test_path_b_fixture_parent_req_references(self, fixture_dir):
        """Every ARCH row in path-b-combined fixture references at least one parent REQ (no SYS)."""
        design = (fixture_dir / "path-b-combined" / "software-architecture-design.md").read_text()
        tc = LLMTestCase(
            input="Path B combined fixture",
            actual_output=design,
        )
        metric = StructuralSoftwareArchitectureDesignMetric(threshold=0.0)
        metric.measure(tc)
        assert "has no parent REQ reference" not in (metric.reason or ""), (
            f"Missing parent REQ references (SYS reference leaked?): {metric.reason}"
        )

    @pytest.mark.structural
    def test_path_b_fixture_no_sys_references(self, fixture_dir):
        """Path B software architecture design MUST NOT contain SYS-NNN references."""
        design = (fixture_dir / "path-b-combined" / "software-architecture-design.md").read_text()
        assert "SYS-" not in design, (
            "Path B fixture should not contain SYS references"
        )

    @pytest.mark.structural
    def test_path_b_fixture_all_views_present(self, fixture_dir):
        """Path B fixture includes all 4 IEEE 42010 views."""
        design = (fixture_dir / "path-b-combined" / "software-architecture-design.md").read_text()
        tc = LLMTestCase(
            input="Path B combined fixture",
            actual_output=design,
        )
        metric = StructuralSoftwareArchitectureDesignMetric(threshold=1.0)
        metric.measure(tc)
        assert metric.score >= 1.0, (
            f"Missing views or structural issues: {metric.reason}"
        )

    @pytest.mark.structural
    def test_golden_medical_device_structural(self, medical_device_software_architecture_design):
        """Golden medical-device software architecture design passes all structural checks."""
        tc = LLMTestCase(
            input="Golden medical-device software architecture design",
            actual_output=medical_device_software_architecture_design,
        )
        assert_test(tc, [StructuralSoftwareArchitectureDesignMetric(threshold=1.0)])

    @pytest.mark.structural
    def test_golden_automotive_adas_structural(self, automotive_adas_software_architecture_design):
        """Golden automotive-adas software architecture design passes all structural checks."""
        tc = LLMTestCase(
            input="Golden automotive-adas software architecture design",
            actual_output=automotive_adas_software_architecture_design,
        )
        assert_test(tc, [StructuralSoftwareArchitectureDesignMetric(threshold=1.0)])


# ---------------------------------------------------------------------------
# LLM-as-judge quality tests (require GOOGLE_API_KEY)
# ---------------------------------------------------------------------------


class TestSoftwareArchitectureDesignQuality:
    """LLM-as-judge evaluation of software architecture design quality using IEEE 42010 criteria."""

    @pytest.mark.eval
    def test_path_b_fixture_design_completeness(self, fixture_dir):
        """Path B fixture meets REQ→ARCH decomposition completeness bar."""
        design = (fixture_dir / "path-b-combined" / "software-architecture-design.md").read_text()
        reqs = (fixture_dir / "path-b-combined" / "requirements.md").read_text()
        tc = LLMTestCase(
            input=reqs,
            actual_output=design,
            expected_output=(
                "An IEEE 42010 software architecture design decomposing all "
                "sensor processing, alert, and display requirements into "
                "ARCH-NNN modules with four architectural views, parent REQ "
                "traceability, and cross-cutting concerns."
            ),
        )
        metric = create_design_completeness_metric(threshold=0.7)
        assert_test(tc, [metric])

    @pytest.mark.eval
    def test_path_b_fixture_view_quality(self, fixture_dir):
        """Path B fixture meets IEEE 42010 view quality bar."""
        design = (fixture_dir / "path-b-combined" / "software-architecture-design.md").read_text()
        tc = LLMTestCase(
            input="Path B combined fixture",
            actual_output=design,
            expected_output=(
                "An IEEE 42010 architecture with Logical, Process, Interface, "
                "and Data Flow views. The Interface View distinguishes external "
                "from internal interfaces."
            ),
        )
        assert_test(tc, [create_view_quality_metric(threshold=0.7)])

    @pytest.mark.eval
    def test_path_b_fixture_interface_contracts(self, fixture_dir):
        """Path B fixture meets interface contract strictness bar."""
        design = (fixture_dir / "path-b-combined" / "software-architecture-design.md").read_text()
        tc = LLMTestCase(
            input="Path B combined fixture",
            actual_output=design,
            expected_output=(
                "A software architecture design with strict interface contracts "
                "specifying inputs, outputs, protocols, and error handling for "
                "each ARCH module. External and internal interfaces are clearly "
                "distinguished."
            ),
        )
        assert_test(tc, [create_interface_contract_metric(threshold=0.7)])

    @pytest.mark.eval
    def test_golden_medical_device_quality(self, medical_device_software_architecture_design):
        """Golden medical-device software architecture design meets quality bar."""
        tc = LLMTestCase(
            input="Medical device software architecture design",
            actual_output=medical_device_software_architecture_design,
            expected_output=(
                "A complete IEEE 42010 software architecture design for a "
                "medical device. All requirements are decomposed into ARCH "
                "modules with proper views and interface contracts."
            ),
        )
        assert_test(tc, [
            create_design_completeness_metric(threshold=0.7),
            create_view_quality_metric(threshold=0.7),
        ])

    @pytest.mark.eval
    def test_golden_automotive_adas_quality(self, automotive_adas_software_architecture_design):
        """Golden automotive-adas software architecture design meets quality bar."""
        tc = LLMTestCase(
            input="Automotive ADAS software architecture design",
            actual_output=automotive_adas_software_architecture_design,
            expected_output=(
                "A complete IEEE 42010 software architecture design for an "
                "automotive ADAS system. All requirements are decomposed into "
                "ARCH modules with proper views and interface contracts."
            ),
        )
        assert_test(tc, [
            create_design_completeness_metric(threshold=0.7),
            create_view_quality_metric(threshold=0.7),
        ])
