"""DeepEval GEval metric for integration test quality scoring.

This metric uses an LLM judge (Google Gemini) to evaluate integration test
plans against coverage quality, technique appropriateness, and scenario
boundary language.

Requires GOOGLE_API_KEY environment variable.
"""

import os

from deepeval.metrics import GEval
from deepeval.models import GeminiModel
from deepeval.test_case import LLMTestCaseParams

EVAL_MODEL_NAME = os.getenv("DEEPEVAL_MODEL", "gemini-2.5-flash")


def _get_model():
    return GeminiModel(model=EVAL_MODEL_NAME)

INTEGRATION_COVERAGE_QUALITY_CRITERIA = """\
You are evaluating an integration test plan for test coverage quality. \
Score it against these 3 criteria (0.0-1.0 each):

1. **ARCH Coverage**: Every ARCH module from the architecture design has at least \
one corresponding ITP test case. No module is left untested. \
Each test case targets a specific, verifiable interaction at a module boundary.

2. **Scenario Completeness**: Each ITP has at least one ITS scenario with \
concrete Given/When/Then steps. Scenarios specify measurable outcomes \
(e.g., response formats, error codes, data transformations) rather than vague assertions.

3. **Edge Case Inclusion**: The plan includes negative paths, fault injection \
scenarios, and race condition tests — not just happy-path integration flows. \
For critical module boundaries, there should be contract violation and timeout scenarios.

Return the average score across all 3 criteria. \
A thorough test plan scores 0.8+. A superficial plan scores 0.4-0.6.\
"""

TECHNIQUE_APPROPRIATENESS_CRITERIA = """\
You are evaluating whether integration test techniques are appropriately \
assigned to test cases. Score against these 4 criteria (0.0-1.0 each):

1. **Interface Contract Testing**: Used for API contract and protocol boundary \
tests where request/response schemas must be validated. Tests verify that module \
interfaces conform to their declared contracts.

2. **Data Flow Testing**: Used for data transformation chain tests where data \
passes through multiple modules. Tests verify data integrity, format conversions, \
and transformation correctness across module boundaries.

3. **Interface Fault Injection**: Used for error path and failure mode tests. \
Tests inject faults at module interfaces (timeouts, malformed data, service \
unavailability) to verify graceful degradation and error propagation.

4. **Concurrency & Race Condition Testing**: Used for tests involving parallel \
access, shared resources, or timing-dependent interactions between modules. \
Tests verify thread safety, locking, and ordering guarantees.

Return the average score across all 4 criteria. \
Well-matched techniques score 0.8+. Mismatched or uniform techniques score 0.3-0.5.\
"""

SCENARIO_BOUNDARY_CRITERIA = """\
You are evaluating integration test scenarios for module-boundary focus and \
technical precision. Score against these 3 criteria (0.0-1.0 each):

1. **Module Boundary Focus**: Scenarios test interactions between modules at \
their boundaries — handshakes, contracts, and seams — not internal module logic. \
Steps reference module interfaces, not implementation details.

2. **Technical Language**: Scenarios use precise, technical language appropriate \
for integration-level testing. Steps reference modules, interfaces, protocols, \
and data contracts — not user-journey phrases like "the user clicks" or \
"the user sees".

3. **Contract Verification**: Steps verify specific contract properties — data \
formats, error codes, response schemas, timing constraints — rather than \
vague behavioral assertions. Each scenario tests a specific integration point.

Return the average score across all 3 criteria. \
Precise, boundary-focused scenarios score 0.8+. Vague or internal-logic scenarios score 0.3-0.5.\
"""


def create_integration_coverage_quality_metric(threshold: float = 0.7) -> GEval:
    """Create a GEval metric for integration test coverage quality."""
    return GEval(
        name="Integration Test Coverage Quality",
        criteria=INTEGRATION_COVERAGE_QUALITY_CRITERIA,
        evaluation_params=[
            LLMTestCaseParams.ACTUAL_OUTPUT,
            LLMTestCaseParams.EXPECTED_OUTPUT,
        ],
        model=_get_model(),
        threshold=threshold,
    )


def create_technique_appropriateness_metric(threshold: float = 0.7) -> GEval:
    """Create a GEval metric for integration technique appropriateness."""
    return GEval(
        name="Integration Technique Appropriateness",
        criteria=TECHNIQUE_APPROPRIATENESS_CRITERIA,
        evaluation_params=[
            LLMTestCaseParams.ACTUAL_OUTPUT,
            LLMTestCaseParams.EXPECTED_OUTPUT,
        ],
        model=_get_model(),
        threshold=threshold,
    )


def create_scenario_boundary_metric(threshold: float = 0.7) -> GEval:
    """Create a GEval metric for scenario boundary language and focus."""
    return GEval(
        name="Scenario Boundary Focus",
        criteria=SCENARIO_BOUNDARY_CRITERIA,
        evaluation_params=[
            LLMTestCaseParams.ACTUAL_OUTPUT,
            LLMTestCaseParams.EXPECTED_OUTPUT,
        ],
        model=_get_model(),
        threshold=threshold,
    )
