"""DeepEval GEval metric for IEEE 1016 system design quality scoring.

This metric uses an LLM judge (Google Gemini) to evaluate system design
documents against completeness, view quality, and derived requirement
flagging accuracy.

Requires GOOGLE_API_KEY environment variable.
"""

import os

from deepeval.metrics import GEval
from deepeval.models import GeminiModel
from deepeval.test_case import LLMTestCaseParams

EVAL_MODEL_NAME = os.getenv("DEEPEVAL_MODEL", "gemini-2.5-flash")


def _get_model():
    return GeminiModel(model=EVAL_MODEL_NAME)

DESIGN_COMPLETENESS_CRITERIA = """\
You are evaluating a system design document (IEEE 1016) for decomposition completeness. \
Score it against these 3 criteria (0.0-1.0 each):

1. **Requirement Decomposition**: Every parent requirement referenced in the input \
is decomposed into at least one SYS component. No requirement is left unaddressed. \
The decomposition should cover functional, non-functional, and interface requirements.

2. **Component Granularity**: Each SYS component addresses a single, well-defined \
responsibility. No monolithic components that combine multiple unrelated functions. \
Names and descriptions clearly convey the component's purpose.

3. **Parent Traceability**: Every SYS row references at least one valid parent REQ. \
The references are accurate — each listed REQ actually relates to the component's \
described functionality.

Return the average score across all 3 criteria. \
A thorough design scores 0.8+. A superficial design scores 0.4-0.6.\
"""

VIEW_QUALITY_CRITERIA = """\
You are evaluating the quality of IEEE 1016 architectural views in a system design \
document. Score it against these 3 criteria (0.0-1.0 each):

1. **Decomposition View Quality**: The decomposition table contains meaningful \
component names, clear descriptions, and accurate type classifications. \
Not just placeholder text or boilerplate.

2. **View Diversity**: The document includes multiple distinct architectural \
perspectives (e.g., Decomposition, Dependency, Interface, Data Design). \
Each view adds unique information not present in the others.

3. **View Depth**: Each view contains substantive technical content — specific \
protocols, data formats, dependency relationships, or interface contracts. \
Shallow views that merely restate component names score poorly.

Return the average score across all 3 criteria. \
A complete, meaningful design scores 0.8+. A boilerplate design scores 0.3-0.5.\
"""

DERIVED_REQUIREMENT_CRITERIA = """\
You are evaluating a system design document for derived requirement identification. \
Score it against these 3 criteria (0.0-1.0 each):

1. **Derived Requirement Detection**: The design correctly identifies components \
or constraints that emerge from architectural decisions but are not explicitly \
stated in the parent requirements. These are flagged or annotated appropriately.

2. **Flagging Accuracy**: Derived requirements are genuinely new constraints \
introduced by the design, not simply restatements of existing requirements. \
False positives (flagging existing requirements as derived) reduce the score.

3. **Completeness**: All significant derived requirements are identified. \
Missing obvious architectural constraints (e.g., inter-component communication \
protocols, shared data stores, timing constraints) reduces the score.

Return the average score across all 3 criteria. \
Accurate, complete flagging scores 0.8+. Missing or inaccurate flagging scores 0.3-0.5.\
"""


def create_design_completeness_metric(threshold: float = 0.7) -> GEval:
    """Create a GEval metric for design decomposition completeness."""
    return GEval(
        name="Design Completeness (IEEE 1016)",
        criteria=DESIGN_COMPLETENESS_CRITERIA,
        evaluation_params=[
            LLMTestCaseParams.ACTUAL_OUTPUT,
            LLMTestCaseParams.EXPECTED_OUTPUT,
        ],
        model=_get_model(),
        threshold=threshold,
    )


def create_view_quality_metric(threshold: float = 0.7) -> GEval:
    """Create a GEval metric for IEEE 1016 view quality."""
    return GEval(
        name="View Quality (IEEE 1016)",
        criteria=VIEW_QUALITY_CRITERIA,
        evaluation_params=[
            LLMTestCaseParams.ACTUAL_OUTPUT,
            LLMTestCaseParams.EXPECTED_OUTPUT,
        ],
        model=_get_model(),
        threshold=threshold,
    )


def create_derived_requirement_metric(threshold: float = 0.7) -> GEval:
    """Create a GEval metric for derived requirement flagging accuracy."""
    return GEval(
        name="Derived Requirement Flagging",
        criteria=DERIVED_REQUIREMENT_CRITERIA,
        evaluation_params=[
            LLMTestCaseParams.ACTUAL_OUTPUT,
            LLMTestCaseParams.EXPECTED_OUTPUT,
        ],
        model=_get_model(),
        threshold=threshold,
    )
