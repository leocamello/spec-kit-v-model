"""DeepEval GEval metrics for hazard analysis (FMEA) quality scoring.

This metric uses an LLM judge to evaluate hazard analysis documents
against FMEA completeness, severity assessment accuracy, operational
state coverage, and mitigation traceability quality.

Requires GOOGLE_API_KEY environment variable.
"""

import os

from deepeval.metrics import GEval
from deepeval.models import GeminiModel
from deepeval.test_case import LLMTestCaseParams

EVAL_MODEL_NAME = os.getenv("DEEPEVAL_MODEL", "gemini-2.5-flash")


def _get_model():
    return GeminiModel(model=EVAL_MODEL_NAME)


FMEA_COMPLETENESS_CRITERIA = """\
You are evaluating a hazard analysis (FMEA) document for completeness. \
Score it against these 3 criteria (0.0-1.0 each):

1. **Component Coverage**: Every system component (SYS-NNN) from the system \
design is analyzed for at least one failure mode. No component is skipped \
or marked as "no failure mode" without justification.

2. **Failure Mode Diversity**: Each component has realistic, diverse failure \
modes — not just one generic "component fails" entry. Consider function \
failures, timing failures, value corruption, and interface failures.

3. **Field Completeness**: Every FMEA row has all 10 required fields populated \
with substantive content (not placeholders). Severity, Likelihood, and Risk \
Level are from the standard scales. Mitigation references valid REQ/SYS IDs.

Return the average score across all 3 criteria. \
A thorough FMEA scores 0.8+. A superficial FMEA with boilerplate scores 0.3-0.5.\
"""

SEVERITY_ASSESSMENT_CRITERIA = """\
You are evaluating the severity and risk assessment quality of an FMEA document. \
Score it against these 3 criteria (0.0-1.0 each):

1. **Severity Accuracy**: Severity levels are realistic for the described effect. \
A failure causing "data loss" should not be rated Catastrophic in a non-safety \
system. A failure causing "patient death" should not be rated Minor. The ratings \
reflect actual consequence proportionality.

2. **Risk Matrix Consistency**: The Risk Level in each row correctly follows \
from the combination of Severity × Likelihood using the risk matrix defined \
in the document. No rows where the risk level contradicts the matrix.

3. **Residual Risk Reasonableness**: Residual risk after mitigation is lower \
than the original risk level. The residual risk narrative explains WHY the \
mitigation reduces risk, not just restating the mitigation.

Return the average score across all 3 criteria. \
Accurate risk assessment scores 0.8+. Inconsistent or implausible scores 0.3-0.5.\
"""

OPERATIONAL_STATE_CRITERIA = """\
You are evaluating how well an FMEA document handles operational states. \
Score it against these 3 criteria (0.0-1.0 each):

1. **State-Contextual Severity**: The same failure mode is assessed across \
different operational states where the consequence differs. For example, \
a sensor failure while idle vs. at high speed should have different severity \
ratings. The document shows awareness of state-dependent consequences.

2. **State Coverage**: All operational states defined in the system design \
are represented in the hazard analysis. No state is completely ignored. \
States where no hazards apply should have explicit justification.

3. **State Realism**: The operational states referenced are realistic and \
derived from the system design, not invented. Each state name matches \
what is defined in the source artifacts.

Return the average score across all 3 criteria. \
Thorough state-aware analysis scores 0.8+. State-ignorant analysis scores 0.3-0.5.\
"""


def create_fmea_completeness_metric(threshold: float = 0.7) -> GEval:
    """Create a GEval metric for FMEA completeness."""
    return GEval(
        name="FMEA Completeness",
        criteria=FMEA_COMPLETENESS_CRITERIA,
        evaluation_params=[
            LLMTestCaseParams.ACTUAL_OUTPUT,
            LLMTestCaseParams.EXPECTED_OUTPUT,
        ],
        model=_get_model(),
        threshold=threshold,
    )


def create_severity_assessment_metric(threshold: float = 0.7) -> GEval:
    """Create a GEval metric for severity and risk assessment quality."""
    return GEval(
        name="Severity Assessment Quality",
        criteria=SEVERITY_ASSESSMENT_CRITERIA,
        evaluation_params=[
            LLMTestCaseParams.ACTUAL_OUTPUT,
            LLMTestCaseParams.EXPECTED_OUTPUT,
        ],
        model=_get_model(),
        threshold=threshold,
    )


def create_operational_state_metric(threshold: float = 0.7) -> GEval:
    """Create a GEval metric for operational state coverage quality."""
    return GEval(
        name="Operational State Coverage",
        criteria=OPERATIONAL_STATE_CRITERIA,
        evaluation_params=[
            LLMTestCaseParams.ACTUAL_OUTPUT,
            LLMTestCaseParams.EXPECTED_OUTPUT,
        ],
        model=_get_model(),
        threshold=threshold,
    )
