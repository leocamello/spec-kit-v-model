"""Evaluation test cases for /speckit.v-model.acceptance command output.

These tests validate that acceptance test plans meet both structural
(BDD format, template conformance) and qualitative (scenario quality)
standards.
"""

import pytest
from deepeval import assert_test
from deepeval.test_case import LLMTestCase

from tests.evals.metrics.structural import (
    StructuralBDDMetric,
    StructuralTemplateMetric,
)
from tests.evals.metrics.bdd_quality import create_bdd_quality_metric


# ---------------------------------------------------------------------------
# Structural tests (deterministic, no LLM calls)
# ---------------------------------------------------------------------------


class TestAcceptanceStructural:
    """Deterministic structural validation of acceptance test plans."""

    @pytest.mark.structural
    def test_medical_device_bdd_compliance(self, medical_device_acceptance):
        """All BDD scenarios in medical-device golden have Given/When/Then."""
        tc = LLMTestCase(
            input="Medical device glucose monitor acceptance plan",
            actual_output=medical_device_acceptance,
        )
        assert_test(tc, [StructuralBDDMetric(threshold=1.0)])

    @pytest.mark.structural
    def test_automotive_adas_bdd_compliance(self, automotive_adas_acceptance):
        """All BDD scenarios in automotive-adas golden have Given/When/Then."""
        tc = LLMTestCase(
            input="Automotive AEB system acceptance plan",
            actual_output=automotive_adas_acceptance,
        )
        assert_test(tc, [StructuralBDDMetric(threshold=1.0)])

    @pytest.mark.structural
    def test_medical_device_template_conformance(self, medical_device_acceptance):
        """Medical-device acceptance plan follows the expected template structure."""
        tc = LLMTestCase(
            input="Medical device glucose monitor acceptance plan",
            actual_output=medical_device_acceptance,
        )
        assert_test(tc, [StructuralTemplateMetric("acceptance", threshold=1.0)])

    @pytest.mark.structural
    def test_automotive_adas_template_conformance(self, automotive_adas_acceptance):
        """Automotive-adas acceptance plan follows the expected template structure."""
        tc = LLMTestCase(
            input="Automotive AEB system acceptance plan",
            actual_output=automotive_adas_acceptance,
        )
        assert_test(tc, [StructuralTemplateMetric("acceptance", threshold=1.0)])

    @pytest.mark.structural
    def test_fixture_minimal_passes(self, fixture_dir):
        """Minimal fixture acceptance plan passes structural validation."""
        acc = (fixture_dir / "minimal" / "acceptance-plan.md").read_text()
        tc = LLMTestCase(input="minimal fixture", actual_output=acc)
        assert_test(
            tc,
            [
                StructuralTemplateMetric("acceptance", threshold=0.95),
                StructuralBDDMetric(threshold=0.95),
            ],
        )

    @pytest.mark.structural
    def test_fixture_complex_passes(self, fixture_dir):
        """Complex fixture acceptance plan passes structural validation."""
        acc = (fixture_dir / "complex" / "acceptance-plan.md").read_text()
        tc = LLMTestCase(input="complex fixture", actual_output=acc)
        assert_test(
            tc,
            [
                StructuralTemplateMetric("acceptance", threshold=0.95),
                StructuralBDDMetric(threshold=0.95),
            ],
        )


# ---------------------------------------------------------------------------
# LLM-as-judge quality tests (require OPENAI_API_KEY)
# ---------------------------------------------------------------------------


class TestAcceptanceQuality:
    """LLM-as-judge evaluation of BDD scenario quality."""

    @pytest.mark.eval
    def test_medical_device_bdd_quality(
        self, medical_device_acceptance, medical_device_requirements
    ):
        """Medical-device golden acceptance plan meets BDD quality bar."""
        tc = LLMTestCase(
            input=medical_device_requirements,
            actual_output=medical_device_acceptance,
            expected_output=(
                "An acceptance test plan with BDD scenarios covering glucose "
                "sampling, alarm escalation, ISO 15197 accuracy, BLE connectivity, "
                "and data export — each with concrete, testable Given/When/Then steps."
            ),
        )
        metric = create_bdd_quality_metric(threshold=0.7)
        assert_test(tc, [metric])

    @pytest.mark.eval
    def test_automotive_adas_bdd_quality(
        self, automotive_adas_acceptance, automotive_adas_requirements
    ):
        """Automotive-adas golden acceptance plan meets BDD quality bar."""
        tc = LLMTestCase(
            input=automotive_adas_requirements,
            actual_output=automotive_adas_acceptance,
            expected_output=(
                "An acceptance test plan with BDD scenarios covering vehicle/pedestrian "
                "detection, emergency braking, false positive rate analysis, CAN-FD/Ethernet "
                "interface validation, and fail-safe degradation — each with concrete, "
                "testable Given/When/Then steps."
            ),
        )
        metric = create_bdd_quality_metric(threshold=0.7)
        assert_test(tc, [metric])
