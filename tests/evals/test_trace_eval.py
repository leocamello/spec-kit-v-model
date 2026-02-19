"""Evaluation test cases for /speckit.v-model.trace command output.

These tests validate traceability artifacts. Since trace command output
is primarily built by deterministic scripts (build-matrix.sh), structural
tests cover most cases. LLM-as-judge evaluates narrative quality of the
traceability analysis sections.
"""

import pytest
from deepeval import assert_test
from deepeval.test_case import LLMTestCase

from tests.evals.metrics.structural import StructuralIDMetric
from tests.evals.metrics.traceability import create_traceability_metric


# ---------------------------------------------------------------------------
# Structural tests (deterministic, no LLM calls)
# ---------------------------------------------------------------------------


class TestTraceStructural:
    """Deterministic structural validation of full artifact chains."""

    @pytest.mark.structural
    def test_medical_device_full_chain(
        self, medical_device_requirements, medical_device_acceptance
    ):
        """Medical-device: full REQ→ATP→SCN chain has no orphans or gaps."""
        combined = medical_device_requirements + "\n" + medical_device_acceptance
        tc = LLMTestCase(input="Medical device full chain", actual_output=combined)
        assert_test(tc, [StructuralIDMetric(threshold=1.0)])

    @pytest.mark.structural
    def test_automotive_adas_full_chain(
        self, automotive_adas_requirements, automotive_adas_acceptance
    ):
        """Automotive-adas: full REQ→ATP→SCN chain has no orphans or gaps."""
        combined = automotive_adas_requirements + "\n" + automotive_adas_acceptance
        tc = LLMTestCase(input="Automotive ADAS full chain", actual_output=combined)
        assert_test(tc, [StructuralIDMetric(threshold=1.0)])

    @pytest.mark.structural
    def test_gaps_fixture_detects_missing_coverage(self, fixture_dir):
        """Gaps fixture correctly scores < 1.0 due to missing ATP for REQ-NF-001."""
        reqs = (fixture_dir / "gaps" / "requirements.md").read_text()
        acc = (fixture_dir / "gaps" / "acceptance-plan.md").read_text()
        tc = LLMTestCase(input="gaps fixture", actual_output=reqs + "\n" + acc)
        metric = StructuralIDMetric(threshold=0.0)
        metric.measure(tc)
        assert metric.score < 1.0, "Gaps fixture should have score < 1.0"
        assert any(
            "REQ-NF-001" in issue for issue in metric.reason.split("; ")
        ), "Should identify REQ-NF-001 as uncovered"


# ---------------------------------------------------------------------------
# LLM-as-judge quality tests (require OPENAI_API_KEY)
# ---------------------------------------------------------------------------


class TestTraceQuality:
    """LLM-as-judge evaluation of traceability completeness and auditability."""

    @pytest.mark.eval
    def test_medical_device_traceability_quality(
        self, medical_device_requirements, medical_device_acceptance
    ):
        """Medical-device golden artifacts meet traceability quality bar."""
        combined = medical_device_requirements + "\n" + medical_device_acceptance
        tc = LLMTestCase(
            input="Trace the CBGMS requirements to acceptance tests",
            actual_output=combined,
            expected_output=(
                "A complete traceability chain where every REQ maps to at least "
                "one ATP with BDD scenarios, covering all 5 requirements for the "
                "blood glucose monitoring system with no gaps or orphans."
            ),
        )
        metric = create_traceability_metric(threshold=0.7)
        assert_test(tc, [metric])

    @pytest.mark.eval
    def test_automotive_adas_traceability_quality(
        self, automotive_adas_requirements, automotive_adas_acceptance
    ):
        """Automotive-adas golden artifacts meet traceability quality bar."""
        combined = automotive_adas_requirements + "\n" + automotive_adas_acceptance
        tc = LLMTestCase(
            input="Trace the AEB requirements to acceptance tests",
            actual_output=combined,
            expected_output=(
                "A complete traceability chain where every REQ maps to at least "
                "one ATP with BDD scenarios, covering all 5 requirements for the "
                "automatic emergency braking system with no gaps or orphans."
            ),
        )
        metric = create_traceability_metric(threshold=0.7)
        assert_test(tc, [metric])
