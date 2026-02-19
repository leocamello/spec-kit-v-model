"""DeepEval GEval metric for traceability completeness scoring.

This metric uses an LLM judge (Google Gemini) to evaluate traceability
matrices for bidirectional completeness, granularity, and auditability.

Requires GOOGLE_API_KEY environment variable.
"""

import os

from deepeval.metrics import GEval
from deepeval.models import GeminiModel
from deepeval.test_case import LLMTestCaseParams

EVAL_MODEL_NAME = os.getenv("DEEPEVAL_MODEL", "gemini-2.5-flash")


def _get_model():
    return GeminiModel(model=EVAL_MODEL_NAME)

TRACEABILITY_CRITERIA = """\
You are evaluating a requirements traceability matrix (RTM) for a \
safety-critical or regulated software project. Score it against these \
4 criteria (0.0-1.0 each):

1. **Bidirectional Completeness**: Every requirement (REQ) maps forward \
to at least one test case (ATP), AND every test case maps backward to \
exactly one requirement. No requirement is untested, no test is purposeless.

2. **Coverage Depth**: Every test case (ATP) has at least one executable \
scenario (SCN) with BDD steps. The three-tier chain REQ → ATP → SCN is \
unbroken throughout the matrix.

3. **Granularity**: Test cases are specific enough to validate individual \
requirements. A single ATP that vaguely "tests the whole module" is poor. \
Each ATP should target a specific aspect of its parent requirement.

4. **Auditability**: A compliance auditor (ISO 26262, IEC 62304, DO-178C) \
could verify the full chain from requirement to executable test scenario \
without ambiguity. IDs are properly formatted, descriptions are clear, \
and the matrix includes coverage metrics and gap analysis.

Return the average score across all 4 criteria. \
A regulatory-grade matrix scores 0.85+. A basic matrix scores 0.5-0.7.\
"""


def create_traceability_metric(threshold: float = 0.8) -> GEval:
    """Create a GEval metric for traceability completeness assessment."""
    return GEval(
        name="Traceability Completeness",
        criteria=TRACEABILITY_CRITERIA,
        evaluation_params=[
            LLMTestCaseParams.ACTUAL_OUTPUT,
            LLMTestCaseParams.EXPECTED_OUTPUT,
        ],
        model=_get_model(),
        threshold=threshold,
    )
