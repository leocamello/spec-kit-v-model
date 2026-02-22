"""DeepEval GEval metric for unit test quality scoring.

This metric uses an LLM judge (Google Gemini) to evaluate unit test plans
against coverage quality, technique appropriateness, and isolation strictness.

Requires GOOGLE_API_KEY environment variable.
"""

import os

from deepeval.metrics import GEval
from deepeval.models import GeminiModel
from deepeval.test_case import LLMTestCaseParams

EVAL_MODEL_NAME = os.getenv("DEEPEVAL_MODEL", "gemini-2.5-flash")


def _get_model():
    return GeminiModel(model=EVAL_MODEL_NAME)


UNIT_COVERAGE_QUALITY_CRITERIA = """\
You are evaluating a unit test plan for test coverage quality. \
Score it against these 3 criteria (0.0-1.0 each):

1. **MOD Coverage**: Every MOD module from the module design has at least \
one corresponding UTP test case. No module is left untested. External \
modules may legitimately have no unit tests if tagged [EXTERNAL].

2. **Scenario Completeness**: Each UTP has at least one UTS scenario with \
concrete Arrange/Act/Assert steps. Scenarios specify measurable outcomes \
(return values, state changes, exception types) rather than vague assertions.

3. **Edge Case Inclusion**: The plan includes boundary values, error paths, \
and invalid input scenarios — not just happy-path unit tests. For stateful \
modules, state transition coverage is included.

Return the average score across all 3 criteria. \
A thorough test plan scores 0.8+. A superficial plan scores 0.4-0.6.\
"""

TECHNIQUE_APPROPRIATENESS_CRITERIA = """\
You are evaluating whether unit test techniques are appropriately assigned \
to test cases. Score against these 4 criteria (0.0-1.0 each):

1. **Statement & Branch Coverage**: Used for algorithmic modules to exercise \
all code paths including branches. Tests verify both true and false branches \
of conditional logic.

2. **Boundary Value Analysis**: Used for modules with numeric or range-based \
inputs. Tests exercise values at boundaries (min, max, just inside, just \
outside) rather than arbitrary middle values.

3. **Equivalence Partitioning**: Used for modules with discrete input classes. \
Tests select representative values from each equivalence class rather than \
exhaustively testing every possible input.

4. **State Transition Testing**: Used for stateful modules to cover valid and \
invalid state transitions. Tests verify all states are reachable and invalid \
transitions are properly rejected.

Return the average score across all 4 criteria. \
Well-matched techniques score 0.8+. Mismatched or uniform techniques score 0.3-0.5.\
"""

ISOLATION_STRICTNESS_CRITERIA = """\
You are evaluating unit test isolation and mock discipline. \
Score against these 3 criteria (0.0-1.0 each):

1. **Mock Registry Completeness**: Every UTP declares a Dependency & Mock \
Registry listing all external dependencies and their mock strategies. No \
test case silently uses real dependencies.

2. **Isolation Discipline**: Test scenarios mock all external dependencies \
(databases, network, file system, hardware). Arrange steps set up mocks \
explicitly. No test depends on global state or other module implementations.

3. **Arrange/Act/Assert Structure**: Every UTS scenario follows strict \
Arrange/Act/Assert structure with explicit setup, a single action under \
test, and concrete assertions. No scenario combines multiple actions or \
has ambiguous assertions.

Return the average score across all 3 criteria. \
Strictly isolated tests score 0.8+. Loosely coupled tests score 0.3-0.5.\
"""


def create_unit_coverage_quality_metric(threshold: float = 0.7) -> GEval:
    """Create a GEval metric for unit test coverage quality."""
    return GEval(
        name="Unit Test Coverage Quality",
        criteria=UNIT_COVERAGE_QUALITY_CRITERIA,
        evaluation_params=[
            LLMTestCaseParams.ACTUAL_OUTPUT,
            LLMTestCaseParams.EXPECTED_OUTPUT,
        ],
        model=_get_model(),
        threshold=threshold,
    )


def create_technique_appropriateness_metric(threshold: float = 0.7) -> GEval:
    """Create a GEval metric for unit test technique appropriateness."""
    return GEval(
        name="Unit Technique Appropriateness",
        criteria=TECHNIQUE_APPROPRIATENESS_CRITERIA,
        evaluation_params=[
            LLMTestCaseParams.ACTUAL_OUTPUT,
            LLMTestCaseParams.EXPECTED_OUTPUT,
        ],
        model=_get_model(),
        threshold=threshold,
    )


def create_isolation_strictness_metric(threshold: float = 0.7) -> GEval:
    """Create a GEval metric for unit test isolation strictness."""
    return GEval(
        name="Unit Test Isolation Strictness",
        criteria=ISOLATION_STRICTNESS_CRITERIA,
        evaluation_params=[
            LLMTestCaseParams.ACTUAL_OUTPUT,
            LLMTestCaseParams.EXPECTED_OUTPUT,
        ],
        model=_get_model(),
        threshold=threshold,
    )
