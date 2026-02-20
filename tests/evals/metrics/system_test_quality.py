"""DeepEval GEval metric for system test quality scoring.

This metric uses an LLM judge (Google Gemini) to evaluate system test
plans against coverage quality, technique appropriateness, and scenario
independence.

Requires GOOGLE_API_KEY environment variable.
"""

import os

from deepeval.metrics import GEval
from deepeval.models import GeminiModel
from deepeval.test_case import LLMTestCaseParams

EVAL_MODEL_NAME = os.getenv("DEEPEVAL_MODEL", "gemini-2.5-flash")


def _get_model():
    return GeminiModel(model=EVAL_MODEL_NAME)

TEST_COVERAGE_QUALITY_CRITERIA = """\
You are evaluating a system test plan for test coverage quality. \
Score it against these 3 criteria (0.0-1.0 each):

1. **SYS Coverage**: Every SYS component from the system design has at least \
one corresponding STP test case. No component is left untested. \
Each test case targets a specific, verifiable behavior of its parent component.

2. **Scenario Completeness**: Each STP has at least one STS scenario with \
concrete Given/When/Then steps. Scenarios specify measurable outcomes \
(e.g., response times, status codes, data formats) rather than vague assertions.

3. **Edge Case Inclusion**: The plan includes negative paths, boundary \
conditions, and error scenarios — not just happy paths. For critical \
components, there should be fault injection or stress scenarios.

Return the average score across all 3 criteria. \
A thorough test plan scores 0.8+. A superficial plan scores 0.4-0.6.\
"""

TECHNIQUE_APPROPRIATENESS_CRITERIA = """\
You are evaluating whether ISO 29119 test techniques are appropriately \
assigned to system test cases. Score against these 3 criteria (0.0-1.0 each):

1. **Technique Selection**: Each test technique is appropriate for the \
component being tested. Interface Contract Testing for API/protocol tests, \
Boundary Value Analysis for threshold/limit tests, Fault Injection for \
resilience tests, Equivalence Partitioning for input classification tests, \
State Transition Testing for stateful component tests.

2. **Technique Diversity**: The plan uses multiple distinct techniques \
across the full test suite, not just one technique for everything. \
Different component types should warrant different testing approaches.

3. **Technique-Scenario Alignment**: The Given/When/Then steps in each \
scenario actually exercise the declared technique. A test declared as \
Boundary Value Analysis should test actual boundary values, not just \
normal operation.

Return the average score across all 3 criteria. \
Well-matched techniques score 0.8+. Mismatched or uniform techniques score 0.3-0.5.\
"""

SCENARIO_INDEPENDENCE_CRITERIA = """\
You are evaluating system test scenarios for independence and technical \
precision. Score against these 3 criteria (0.0-1.0 each):

1. **Scenario Independence**: Each STS scenario is self-contained. No \
scenario depends on the state left by a previous scenario. Setup is \
explicit in Given steps. Teardown is not required between scenarios.

2. **Technical Language**: Scenarios use precise, technical language \
appropriate for system-level testing. Steps reference components, APIs, \
protocols, and measurable outcomes — not user-journey phrases like \
"the user clicks" or "the user sees".

3. **Determinism**: Steps produce repeatable results. No dependency on \
real-time clocks, randomness, or external services that could vary \
between test runs. Thresholds and expected values are explicit.

Return the average score across all 3 criteria. \
Precise, independent scenarios score 0.8+. Vague or coupled scenarios score 0.3-0.5.\
"""


def create_test_coverage_quality_metric(threshold: float = 0.7) -> GEval:
    """Create a GEval metric for system test coverage quality."""
    return GEval(
        name="System Test Coverage Quality",
        criteria=TEST_COVERAGE_QUALITY_CRITERIA,
        evaluation_params=[
            LLMTestCaseParams.ACTUAL_OUTPUT,
            LLMTestCaseParams.EXPECTED_OUTPUT,
        ],
        model=_get_model(),
        threshold=threshold,
    )


def create_technique_appropriateness_metric(threshold: float = 0.7) -> GEval:
    """Create a GEval metric for ISO 29119 technique appropriateness."""
    return GEval(
        name="Technique Appropriateness (ISO 29119)",
        criteria=TECHNIQUE_APPROPRIATENESS_CRITERIA,
        evaluation_params=[
            LLMTestCaseParams.ACTUAL_OUTPUT,
            LLMTestCaseParams.EXPECTED_OUTPUT,
        ],
        model=_get_model(),
        threshold=threshold,
    )


def create_scenario_independence_metric(threshold: float = 0.7) -> GEval:
    """Create a GEval metric for scenario independence and technical precision."""
    return GEval(
        name="Scenario Independence",
        criteria=SCENARIO_INDEPENDENCE_CRITERIA,
        evaluation_params=[
            LLMTestCaseParams.ACTUAL_OUTPUT,
            LLMTestCaseParams.EXPECTED_OUTPUT,
        ],
        model=_get_model(),
        threshold=threshold,
    )
