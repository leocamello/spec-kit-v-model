"""Evaluation test cases for /speckit.v-model.hazard-analysis output quality.

These tests validate that hazard analysis (FMEA) documents meet both structural
(HAZ ID format, FMEA table fields, required sections, mitigation refs) and
qualitative (FMEA completeness, severity accuracy, operational state coverage)
standards.
"""

import pytest
from deepeval import assert_test
from deepeval.test_case import LLMTestCase

from tests.evals.metrics.structural import StructuralHazardAnalysisMetric
from tests.evals.metrics.hazard_analysis_quality import (
    create_fmea_completeness_metric,
    create_severity_assessment_metric,
    create_operational_state_metric,
)


# ---------------------------------------------------------------------------
# Structural tests (deterministic, no LLM calls)
# ---------------------------------------------------------------------------


class TestHazardAnalysisStructural:
    """Deterministic structural validation of hazard analysis documents."""

    @pytest.mark.structural
    def test_minimal_haz_id_compliance(self, fixture_dir):
        """All HAZ IDs in minimal hazard-analysis follow HAZ-NNN format."""
        ha = (fixture_dir / "minimal" / "hazard-analysis.md").read_text()
        tc = LLMTestCase(
            input="Minimal hazard analysis fixture",
            actual_output=ha,
        )
        metric = StructuralHazardAnalysisMetric(threshold=1.0)
        metric.measure(tc)
        assert "Malformed HAZ ID" not in (metric.reason or ""), (
            f"HAZ ID format issues: {metric.reason}"
        )

    @pytest.mark.structural
    def test_minimal_required_sections(self, fixture_dir):
        """Minimal fixture has all required FMEA sections."""
        ha = (fixture_dir / "minimal" / "hazard-analysis.md").read_text()
        tc = LLMTestCase(
            input="Minimal hazard analysis fixture",
            actual_output=ha,
        )
        metric = StructuralHazardAnalysisMetric(threshold=1.0)
        metric.measure(tc)
        assert "Missing required section" not in (metric.reason or ""), (
            f"Missing sections: {metric.reason}"
        )

    @pytest.mark.structural
    def test_minimal_mitigation_refs(self, fixture_dir):
        """Every HAZ row in minimal fixture references at least one REQ/SYS."""
        ha = (fixture_dir / "minimal" / "hazard-analysis.md").read_text()
        tc = LLMTestCase(
            input="Minimal hazard analysis fixture",
            actual_output=ha,
        )
        metric = StructuralHazardAnalysisMetric(threshold=1.0)
        metric.measure(tc)
        assert "no REQ/SYS reference" not in (metric.reason or ""), (
            f"Missing mitigation references: {metric.reason}"
        )

    @pytest.mark.structural
    def test_minimal_with_system_design_coverage(self, fixture_dir):
        """All SYS in minimal system-design are covered by HAZ entries."""
        ha = (fixture_dir / "minimal" / "hazard-analysis.md").read_text()
        sd = (fixture_dir / "minimal" / "system-design.md").read_text()
        tc = LLMTestCase(
            input="Minimal hazard analysis fixture",
            actual_output=ha,
        )
        metric = StructuralHazardAnalysisMetric(threshold=1.0, system_design_text=sd)
        assert_test(tc, [metric])

    @pytest.mark.structural
    def test_complex_structural_compliance(self, fixture_dir):
        """Complex fixture (12 HAZ, 3 states, many-to-many) passes structural checks."""
        ha = (fixture_dir / "complex" / "hazard-analysis.md").read_text()
        sd = (fixture_dir / "complex" / "system-design.md").read_text()
        tc = LLMTestCase(
            input="Complex hazard analysis fixture",
            actual_output=ha,
        )
        assert_test(tc, [StructuralHazardAnalysisMetric(threshold=1.0, system_design_text=sd)])

    @pytest.mark.structural
    def test_gaps_fixture_detects_coverage_gap(self, fixture_dir):
        """Gaps fixture correctly scores below 1.0 due to missing SYS-002 coverage."""
        ha = (fixture_dir / "gaps" / "hazard-analysis.md").read_text()
        sd = (fixture_dir / "gaps" / "system-design.md").read_text()
        tc = LLMTestCase(
            input="Gaps hazard analysis fixture",
            actual_output=ha,
        )
        metric = StructuralHazardAnalysisMetric(threshold=0.0, system_design_text=sd)
        metric.measure(tc)
        assert metric.score < 1.0, "Gaps fixture should not score 1.0"
        assert "SYS-002" in (metric.reason or ""), (
            f"Should detect SYS-002 gap: {metric.reason}"
        )

    @pytest.mark.structural
    def test_golden_medical_device_structural(self, medical_device_hazard_analysis, medical_device_system_design):
        """Golden medical-device hazard analysis passes all structural checks."""
        tc = LLMTestCase(
            input="Golden medical-device hazard analysis",
            actual_output=medical_device_hazard_analysis,
        )
        assert_test(tc, [StructuralHazardAnalysisMetric(
            threshold=1.0, system_design_text=medical_device_system_design,
        )])

    @pytest.mark.structural
    def test_golden_automotive_adas_structural(self, automotive_adas_hazard_analysis, automotive_adas_system_design):
        """Golden automotive-adas hazard analysis passes all structural checks."""
        tc = LLMTestCase(
            input="Golden automotive-adas hazard analysis",
            actual_output=automotive_adas_hazard_analysis,
        )
        assert_test(tc, [StructuralHazardAnalysisMetric(
            threshold=1.0, system_design_text=automotive_adas_system_design,
        )])


# ---------------------------------------------------------------------------
# LLM-as-judge quality tests (require GOOGLE_API_KEY)
# ---------------------------------------------------------------------------


class TestHazardAnalysisQuality:
    """LLM-as-judge evaluation of hazard analysis quality using FMEA criteria."""

    @pytest.mark.eval
    def test_minimal_fmea_completeness(self, fixture_dir):
        """Minimal fixture FMEA meets component coverage and field completeness bar."""
        ha = (fixture_dir / "minimal" / "hazard-analysis.md").read_text()
        sd = (fixture_dir / "minimal" / "system-design.md").read_text()
        tc = LLMTestCase(
            input=sd,
            actual_output=ha,
            expected_output=(
                "An FMEA document analyzing all 3 system components (Data Processor, "
                "Alert Engine, Display Renderer) with realistic failure modes, "
                "standard severity/likelihood scales, and mitigation references "
                "to REQ-NNN identifiers."
            ),
        )
        assert_test(tc, [create_fmea_completeness_metric(threshold=0.7)])

    @pytest.mark.eval
    def test_minimal_severity_assessment(self, fixture_dir):
        """Minimal fixture severity ratings are proportional to described effects."""
        ha = (fixture_dir / "minimal" / "hazard-analysis.md").read_text()
        tc = LLMTestCase(
            input="Sensor monitoring system with data processing, alerting, and display",
            actual_output=ha,
            expected_output=(
                "An FMEA with proportional severity ratings: a Data Processor "
                "corruption causing false alerts should be Serious, not "
                "Catastrophic. An unresponsive processor should be Critical. "
                "Alert fatigue is Minor. Risk levels follow the severity × "
                "likelihood matrix consistently."
            ),
        )
        assert_test(tc, [create_severity_assessment_metric(threshold=0.7)])

    @pytest.mark.eval
    def test_golden_automotive_fmea_completeness(
        self, automotive_adas_hazard_analysis, automotive_adas_system_design
    ):
        """Golden automotive FMEA covers all SYS with ISO 26262 rigor."""
        tc = LLMTestCase(
            input=automotive_adas_system_design,
            actual_output=automotive_adas_hazard_analysis,
            expected_output=(
                "A comprehensive FMEA analyzing all 5 AEB system components "
                "(Radar, Camera, Sensor Fusion, Braking Controller, Fault Manager) "
                "with diverse failure modes including sensor blindness, false "
                "positives, TTC miscalculation, and brake actuator failure. "
                "Severity ratings reflect ISO 26262 ASIL-D context."
            ),
        )
        assert_test(tc, [
            create_fmea_completeness_metric(threshold=0.7),
            create_severity_assessment_metric(threshold=0.7),
        ])

    @pytest.mark.eval
    def test_golden_automotive_operational_states(
        self, automotive_adas_hazard_analysis, automotive_adas_system_design
    ):
        """Golden automotive FMEA analyzes failures across vehicle operational states."""
        tc = LLMTestCase(
            input=automotive_adas_system_design,
            actual_output=automotive_adas_hazard_analysis,
            expected_output=(
                "An FMEA that varies severity by operational state: radar failure "
                "at HIGHWAY speed is Catastrophic, the same failure at LOW_SPEED "
                "is Minor. Camera failure at night in URBAN is more severe than "
                "in daylight. All 5 states (PARKED, LOW_SPEED, URBAN, HIGHWAY, "
                "SENSOR_DEGRADED) are represented."
            ),
        )
        assert_test(tc, [create_operational_state_metric(threshold=0.7)])

    @pytest.mark.eval
    def test_golden_medical_fmea_completeness(
        self, medical_device_hazard_analysis, medical_device_system_design
    ):
        """Golden medical FMEA covers all SYS with ISO 14971 rigor."""
        tc = LLMTestCase(
            input=medical_device_system_design,
            actual_output=medical_device_hazard_analysis,
            expected_output=(
                "A comprehensive FMEA analyzing all 5 CBGMS components "
                "(Glucose Sensor, Signal Processing, Alert Manager, BLE Module, "
                "Data Storage) with diverse failure modes including sensor fault, "
                "calibration error, missed alarms, BLE disconnection, and data "
                "loss. Severity ratings reflect ISO 14971 patient safety context."
            ),
        )
        assert_test(tc, [
            create_fmea_completeness_metric(threshold=0.7),
            create_severity_assessment_metric(threshold=0.7),
        ])

    @pytest.mark.eval
    def test_golden_medical_operational_states(
        self, medical_device_hazard_analysis, medical_device_system_design
    ):
        """Golden medical FMEA analyzes failures across device operational states."""
        tc = LLMTestCase(
            input=medical_device_system_design,
            actual_output=medical_device_hazard_analysis,
            expected_output=(
                "An FMEA that varies severity by operational state: sensor fault "
                "during MONITORING is Catastrophic (patient unaware of glucose), "
                "during SENSOR_WARMUP is Negligible (expected behavior). BLE "
                "disconnection during LOW_BATTERY is more severe than during "
                "normal MONITORING. All 4 states represented."
            ),
        )
        assert_test(tc, [create_operational_state_metric(threshold=0.7)])

    @pytest.mark.eval
    def test_golden_fwc_fmea_completeness(
        self, flight_warning_computer_hazard_analysis, flight_warning_computer_system_design
    ):
        """Golden FWC FMEA covers all SYS with DO-178C DAL-A rigor."""
        tc = LLMTestCase(
            input=flight_warning_computer_system_design,
            actual_output=flight_warning_computer_hazard_analysis,
            expected_output=(
                "A comprehensive FMEA analyzing all 3 FWC SYS components (Air Data "
                "Interface, Warning Logic Engine, Output Control) with 9+ failure "
                "modes including bus timeout, stale data, threshold corruption, logic "
                "faults, and output failures. Severity ratings reflect DO-178C DAL-A "
                "catastrophic consequence classification for missed warning functions."
            ),
        )
        assert_test(tc, [
            create_fmea_completeness_metric(threshold=0.7),
            create_severity_assessment_metric(threshold=0.7),
        ])

    @pytest.mark.eval
    def test_golden_fwc_operational_states(
        self, flight_warning_computer_hazard_analysis, flight_warning_computer_system_design
    ):
        """Golden FWC FMEA analyzes failures across avionics operational states."""
        tc = LLMTestCase(
            input=flight_warning_computer_system_design,
            actual_output=flight_warning_computer_hazard_analysis,
            expected_output=(
                "Hazard analysis covering FWC operational states (POWER_ON_SELF_TEST, "
                "MONITORING, DEGRADED, MAINTENANCE) with failure modes analyzed per "
                "state, ensuring DO-178C DAL-A Catastrophic/Major failure conditions "
                "are mitigated in each state."
            ),
        )
        assert_test(tc, [create_operational_state_metric(threshold=0.7)])
