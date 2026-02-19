"""Evaluation test cases for /speckit.v-model.requirements command output.

These tests validate that requirements documents meet both structural
and qualitative standards. Structural tests are deterministic (no LLM).
Quality tests use LLM-as-judge (require OPENAI_API_KEY).
"""

import pytest
from deepeval import assert_test
from deepeval.test_case import LLMTestCase

from tests.evals.metrics.structural import StructuralIDMetric, StructuralTemplateMetric
from tests.evals.metrics.requirements_quality import create_requirements_quality_metric


# ---------------------------------------------------------------------------
# Structural tests (deterministic, no LLM calls)
# ---------------------------------------------------------------------------


class TestRequirementsStructural:
    """Deterministic structural validation of requirements documents."""

    @pytest.mark.structural
    def test_medical_device_id_compliance(
        self, medical_device_requirements, medical_device_acceptance
    ):
        """All IDs in medical-device golden example pass format/hierarchy checks."""
        tc = LLMTestCase(
            input="Medical device glucose monitor spec",
            actual_output=medical_device_requirements + "\n" + medical_device_acceptance,
        )
        assert_test(tc, [StructuralIDMetric(threshold=1.0)])

    @pytest.mark.structural
    def test_automotive_adas_id_compliance(
        self, automotive_adas_requirements, automotive_adas_acceptance
    ):
        """All IDs in automotive-adas golden example pass format/hierarchy checks."""
        tc = LLMTestCase(
            input="Automotive AEB system spec",
            actual_output=automotive_adas_requirements + "\n" + automotive_adas_acceptance,
        )
        assert_test(tc, [StructuralIDMetric(threshold=1.0)])

    @pytest.mark.structural
    def test_medical_device_template_conformance(self, medical_device_requirements):
        """Medical-device requirements follow the expected template structure."""
        tc = LLMTestCase(
            input="Medical device glucose monitor spec",
            actual_output=medical_device_requirements,
        )
        assert_test(tc, [StructuralTemplateMetric("requirements", threshold=1.0)])

    @pytest.mark.structural
    def test_automotive_adas_template_conformance(self, automotive_adas_requirements):
        """Automotive-adas requirements follow the expected template structure."""
        tc = LLMTestCase(
            input="Automotive AEB system spec",
            actual_output=automotive_adas_requirements,
        )
        assert_test(tc, [StructuralTemplateMetric("requirements", threshold=1.0)])

    @pytest.mark.structural
    def test_fixture_minimal_passes(self, fixture_dir):
        """Minimal fixture passes structural validation."""
        reqs = (fixture_dir / "minimal" / "requirements.md").read_text()
        tc = LLMTestCase(input="minimal fixture", actual_output=reqs)
        assert_test(tc, [StructuralTemplateMetric("requirements", threshold=0.95)])

    @pytest.mark.structural
    def test_fixture_complex_passes(self, fixture_dir):
        """Complex fixture (16 REQs, 4 categories) passes structural validation."""
        reqs = (fixture_dir / "complex" / "requirements.md").read_text()
        tc = LLMTestCase(input="complex fixture", actual_output=reqs)
        assert_test(tc, [StructuralTemplateMetric("requirements", threshold=0.95)])


# ---------------------------------------------------------------------------
# LLM-as-judge quality tests (require OPENAI_API_KEY)
# ---------------------------------------------------------------------------


class TestRequirementsQuality:
    """LLM-as-judge evaluation of requirements quality using IEEE 29148 criteria."""

    @pytest.mark.eval
    def test_medical_device_requirements_quality(
        self, medical_device_requirements, medical_device_input
    ):
        """Medical-device golden requirements meet IEEE 29148 quality bar."""
        tc = LLMTestCase(
            input=medical_device_input,
            actual_output=medical_device_requirements,
            expected_output=(
                "A requirements specification with 5 traceable REQ-NNN items "
                "covering glucose monitoring, alarms, accuracy, BLE connectivity, "
                "and data retention — all with IEEE 29148 quality attributes."
            ),
        )
        metric = create_requirements_quality_metric(threshold=0.7)
        assert_test(tc, [metric])

    @pytest.mark.eval
    def test_automotive_adas_requirements_quality(
        self, automotive_adas_requirements, automotive_adas_input
    ):
        """Automotive-adas golden requirements meet IEEE 29148 quality bar."""
        tc = LLMTestCase(
            input=automotive_adas_input,
            actual_output=automotive_adas_requirements,
            expected_output=(
                "A requirements specification with 5 traceable REQ-NNN items "
                "covering sensor fusion, emergency braking, false positive rate, "
                "CAN-FD/Ethernet interfaces, and fail-safe degradation — all with "
                "IEEE 29148 quality attributes."
            ),
        )
        metric = create_requirements_quality_metric(threshold=0.7)
        assert_test(tc, [metric])
