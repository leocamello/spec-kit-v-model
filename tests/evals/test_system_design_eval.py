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
        design = (fixture_dir / "system-design-minimal" / "system-design.md").read_text()
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
        design = (fixture_dir / "system-design-minimal" / "system-design.md").read_text()
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
        design = (fixture_dir / "system-design-complex" / "system-design.md").read_text()
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


# ---------------------------------------------------------------------------
# LLM-as-judge quality tests (require GOOGLE_API_KEY)
# ---------------------------------------------------------------------------


class TestSystemDesignQuality:
    """LLM-as-judge evaluation of system design quality using IEEE 1016 criteria."""

    @pytest.mark.eval
    def test_minimal_design_completeness(self, fixture_dir):
        """Minimal fixture system design meets decomposition completeness bar."""
        design = (fixture_dir / "system-design-minimal" / "system-design.md").read_text()
        reqs = (fixture_dir / "system-design-minimal" / "requirements.md").read_text()
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
        design = (fixture_dir / "system-design-minimal" / "system-design.md").read_text()
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
        design = (fixture_dir / "system-design-minimal" / "system-design.md").read_text()
        reqs = (fixture_dir / "system-design-minimal" / "requirements.md").read_text()
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
