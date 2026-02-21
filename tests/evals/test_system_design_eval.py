"""Evaluation test cases for /speckit.v-model.system-design output quality.

These tests validate that system design documents meet both structural
(SYS ID format, IEEE 1016 views, parent REQ references) and qualitative
(completeness, view quality, derived requirement flagging) standards.
"""

import pytest
from deepeval import assert_test
from deepeval.test_case import LLMTestCase

from tests.evals.metrics.structural import StructuralSystemDesignMetric
from tests.evals.metrics.system_design_quality import (
    create_design_completeness_metric,
    create_view_quality_metric,
    create_derived_requirement_metric,
)


# ---------------------------------------------------------------------------
# Structural tests (deterministic, no LLM calls)
# ---------------------------------------------------------------------------


class TestSystemDesignStructural:
    """Deterministic structural validation of system design documents."""

    @pytest.mark.structural
    def test_minimal_sys_id_compliance(self, fixture_dir):
        """All SYS IDs in system-design-minimal follow SYS-NNN format."""
        design = (fixture_dir / "minimal" / "system-design.md").read_text()
        tc = LLMTestCase(
            input="Minimal system design fixture",
            actual_output=design,
        )
        metric = StructuralSystemDesignMetric(threshold=0.95)
        metric.measure(tc)
        # Minimal fixture only has Decomposition view; check ID + REQ parts pass
        assert all(
            "Malformed SYS ID" not in (metric.reason or "")
            for _ in [None]
        ), f"SYS ID format issues: {metric.reason}"

    @pytest.mark.structural
    def test_minimal_parent_req_references(self, fixture_dir):
        """Every SYS row in system-design-minimal references at least one parent REQ."""
        design = (fixture_dir / "minimal" / "system-design.md").read_text()
        tc = LLMTestCase(
            input="Minimal system design fixture",
            actual_output=design,
        )
        metric = StructuralSystemDesignMetric(threshold=0.0)
        metric.measure(tc)
        assert "has no parent REQ reference" not in (metric.reason or ""), (
            f"Missing parent REQ references: {metric.reason}"
        )

    @pytest.mark.structural
    def test_complex_structural_compliance(self, fixture_dir):
        """Complex fixture (6 SYS, multi-category REQs) passes structural checks."""
        design = (fixture_dir / "complex" / "system-design.md").read_text()
        tc = LLMTestCase(
            input="Complex system design fixture",
            actual_output=design,
        )
        metric = StructuralSystemDesignMetric(threshold=0.95)
        metric.measure(tc)
        assert all(
            "Malformed SYS ID" not in (metric.reason or "")
            for _ in [None]
        ), f"SYS ID format issues: {metric.reason}"

    @pytest.mark.structural
    def test_golden_medical_device_structural(self, medical_device_system_design):
        """Golden medical-device system design passes all structural checks."""
        tc = LLMTestCase(
            input="Golden medical-device system design",
            actual_output=medical_device_system_design,
        )
        assert_test(tc, [StructuralSystemDesignMetric(threshold=1.0)])

    @pytest.mark.structural
    def test_golden_automotive_adas_structural(self, automotive_adas_system_design):
        """Golden automotive-adas system design passes all structural checks."""
        tc = LLMTestCase(
            input="Golden automotive-adas system design",
            actual_output=automotive_adas_system_design,
        )
        assert_test(tc, [StructuralSystemDesignMetric(threshold=1.0)])


# ---------------------------------------------------------------------------
# LLM-as-judge quality tests (require GOOGLE_API_KEY)
# ---------------------------------------------------------------------------


class TestSystemDesignQuality:
    """LLM-as-judge evaluation of system design quality using IEEE 1016 criteria."""

    @pytest.mark.eval
    def test_minimal_design_completeness(self, fixture_dir):
        """Minimal fixture system design meets decomposition completeness bar."""
        design = (fixture_dir / "minimal" / "system-design.md").read_text()
        reqs = (fixture_dir / "minimal" / "requirements.md").read_text()
        tc = LLMTestCase(
            input=reqs,
            actual_output=design,
            expected_output=(
                "A system design document with SYS-NNN components that decompose "
                "all 3 requirements (sensor processing, alerts, display) into "
                "distinct modules with clear parent REQ traceability."
            ),
        )
        metric = create_design_completeness_metric(threshold=0.7)
        assert_test(tc, [metric])

    @pytest.mark.eval
    def test_minimal_view_quality(self, fixture_dir):
        """Minimal fixture system design views are meaningful, not boilerplate."""
        design = (fixture_dir / "minimal" / "system-design.md").read_text()
        tc = LLMTestCase(
            input="System design for a minimal sensor monitoring system",
            actual_output=design,
            expected_output=(
                "An IEEE 1016 system design with substantive architectural views "
                "including decomposition with typed components, dependency "
                "relationships, interface contracts, and data design — each "
                "providing unique technical information."
            ),
        )
        metric = create_view_quality_metric(threshold=0.7)
        assert_test(tc, [metric])

    @pytest.mark.eval
    def test_minimal_derived_requirement_flagging(self, fixture_dir):
        """Minimal fixture correctly identifies derived requirements."""
        design = (fixture_dir / "minimal" / "system-design.md").read_text()
        reqs = (fixture_dir / "minimal" / "requirements.md").read_text()
        tc = LLMTestCase(
            input=reqs,
            actual_output=design,
            expected_output=(
                "A system design that identifies and flags any derived requirements "
                "introduced by architectural decisions — such as inter-component "
                "communication protocols or shared data formats — that are not "
                "explicitly stated in the parent requirements."
            ),
        )
        metric = create_derived_requirement_metric(threshold=0.7)
        assert_test(tc, [metric])

    @pytest.mark.eval
    def test_golden_medical_device_design_completeness(
        self, medical_device_requirements, medical_device_system_design
    ):
        """Golden medical-device system design meets decomposition completeness bar."""
        tc = LLMTestCase(
            input=medical_device_requirements,
            actual_output=medical_device_system_design,
            expected_output=(
                "An IEEE 1016 system design decomposing all 5 requirements "
                "(glucose sampling, alarms, accuracy, BLE connectivity, data retention) "
                "into distinct SYS-NNN components with clear parent REQ traceability, "
                "four architectural views, and derived requirements."
            ),
        )
        assert_test(tc, [
            create_design_completeness_metric(threshold=0.7),
            create_view_quality_metric(threshold=0.7),
        ])

    @pytest.mark.eval
    def test_golden_automotive_adas_design_completeness(
        self, automotive_adas_requirements, automotive_adas_system_design
    ):
        """Golden automotive-adas system design meets decomposition completeness bar."""
        tc = LLMTestCase(
            input=automotive_adas_requirements,
            actual_output=automotive_adas_system_design,
            expected_output=(
                "An IEEE 1016 system design decomposing all 5 requirements "
                "(collision detection, braking, false positive rate, sensor interfaces, "
                "fail-safe degradation) into distinct SYS-NNN components with ASIL-D "
                "safety constraints, four architectural views, and derived requirements."
            ),
        )
        assert_test(tc, [
            create_design_completeness_metric(threshold=0.7),
            create_view_quality_metric(threshold=0.7),
        ])
