"""DeepEval GEval metric for BDD scenario quality scoring.

This metric uses an LLM judge (Google Gemini) to evaluate acceptance
test plans with BDD (Given/When/Then) scenarios for quality and
completeness.

Requires GOOGLE_API_KEY environment variable.
"""

import os

from deepeval.metrics import GEval
from deepeval.models import GeminiModel
from deepeval.test_case import LLMTestCaseParams

EVAL_MODEL_NAME = os.getenv("DEEPEVAL_MODEL", "gemini-2.5-flash")


def _get_model():
    return GeminiModel(model=EVAL_MODEL_NAME)

BDD_QUALITY_CRITERIA = """\
You are evaluating a BDD (Behavior-Driven Development) acceptance test plan. \
Score it against these 5 quality criteria (0.0-1.0 each):

1. **Given/When/Then Clarity**: Each step is concrete, specific, and actionable. \
"Given the user is logged in" is good. "Given some precondition" is vague. \
Steps should be precise enough for a tester to execute without interpretation.

2. **Edge Case Coverage**: The plan includes negative paths, boundary conditions, \
and error scenarios — not just happy paths. For every "valid input" test, \
there should be at least one "invalid input" or error case.

3. **Independence**: Each scenario is self-contained. No scenario depends on \
the state left by a previous scenario. Setup is explicit in Given steps.

4. **Determinism**: Steps produce repeatable results. No dependency on time, \
randomness, or external state that could vary between test runs.

5. **Completeness**: Every test case (ATP) has at least one executable scenario (SCN). \
Scenarios cover the full validation condition described in the test case.

Return the average score across all 5 criteria. \
A thorough, well-written plan scores 0.8+. A superficial plan scores 0.4-0.6.\
"""


def create_bdd_quality_metric(threshold: float = 0.7) -> GEval:
    """Create a GEval metric for BDD scenario quality assessment."""
    return GEval(
        name="BDD Scenario Quality",
        criteria=BDD_QUALITY_CRITERIA,
        evaluation_params=[
            LLMTestCaseParams.ACTUAL_OUTPUT,
            LLMTestCaseParams.EXPECTED_OUTPUT,
        ],
        model=_get_model(),
        threshold=threshold,
    )
