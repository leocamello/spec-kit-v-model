"""DeepEval GEval metric for IEEE 29148 / INCOSE requirements quality scoring.

This metric uses an LLM judge (Google Gemini) to evaluate requirements
documents against the 8 quality criteria from IEEE 29148 and INCOSE
Guide for Writing Requirements.

Requires GOOGLE_API_KEY environment variable.
"""

import os

from deepeval.metrics import GEval
from deepeval.models import GeminiModel
from deepeval.test_case import LLMTestCaseParams

EVAL_MODEL_NAME = os.getenv("DEEPEVAL_MODEL", "gemini-2.5-flash")


def _get_model():
    return GeminiModel(model=EVAL_MODEL_NAME)

REQUIREMENTS_QUALITY_CRITERIA = """\
You are evaluating a software requirements specification document. \
Score it against these 8 IEEE 29148 / INCOSE quality criteria (0.0-1.0 each):

1. **Unambiguous**: Each requirement has exactly one interpretation. \
No vague terms like "fast", "user-friendly", "efficient" without measurable thresholds.

2. **Testable/Verifiable**: Each requirement specifies a measurable condition \
that can be verified through test, inspection, analysis, or demonstration. \
A requirement like "the system shall be reliable" fails; \
"the system shall achieve 99.9% uptime" passes.

3. **Complete**: No missing requirements implied by the specification context. \
All referenced entities, interfaces, and constraints are defined.

4. **Consistent**: No contradictions between requirements. \
No two requirements demand mutually exclusive behavior.

5. **Traceable**: Every requirement has a unique ID in the format REQ-NNN \
or REQ-{CATEGORY}-NNN (e.g., REQ-001, REQ-NF-001). IDs are sequential \
and category prefixes are consistent.

6. **Atomic**: Each requirement states exactly one thing. \
No compound requirements using "and" to combine multiple capabilities.

7. **Necessary**: No gold-plating or scope creep beyond the input specification. \
Every requirement traces back to a user need or constraint.

8. **Feasible**: Requirements are technically achievable. \
No impossible constraints (e.g., "zero latency", "100% accuracy").

Return the average score across all 8 criteria. \
A perfect document scores 1.0. A typical first-draft scores 0.5-0.7.\
"""


def create_requirements_quality_metric(threshold: float = 0.7) -> GEval:
    """Create a GEval metric for requirements quality assessment."""
    return GEval(
        name="Requirements Quality (IEEE 29148)",
        criteria=REQUIREMENTS_QUALITY_CRITERIA,
        evaluation_params=[
            LLMTestCaseParams.ACTUAL_OUTPUT,
            LLMTestCaseParams.EXPECTED_OUTPUT,
        ],
        model=_get_model(),
        threshold=threshold,
    )
