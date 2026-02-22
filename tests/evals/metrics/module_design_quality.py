"""DeepEval GEval metric for module design quality scoring.

This metric uses an LLM judge (Google Gemini) to evaluate module design
documents against completeness, logic quality, and data structure precision.

Requires GOOGLE_API_KEY environment variable.
"""

import os

from deepeval.metrics import GEval
from deepeval.models import GeminiModel
from deepeval.test_case import LLMTestCaseParams

EVAL_MODEL_NAME = os.getenv("DEEPEVAL_MODEL", "gemini-2.5-flash")


def _get_model():
    return GeminiModel(model=EVAL_MODEL_NAME)


MODULE_COMPLETENESS_CRITERIA = """\
You are evaluating a module design document for decomposition completeness. \
Score it against these 3 criteria (0.0-1.0 each):

1. **ARCH Coverage**: Every ARCH module from the architecture design has at \
least one corresponding MOD module. No architecture module is left \
undecomposed. Cross-cutting and external modules are properly tagged.

2. **View Completeness**: Each MOD has all four required views \
(Algorithmic / Logic, State Machine, Internal Data Structures, Error \
Handling & Return Codes). Stateless modules use "N/A — Stateless" bypass \
for State Machine View.

3. **Pseudocode Quality**: Each module's Algorithmic / Logic View contains a \
```pseudocode block with named functions, typed parameters, and clear \
control flow — not prose descriptions or empty placeholders.

Return the average score across all 3 criteria. \
A thorough module design scores 0.8+. A superficial design scores 0.4-0.6.\
"""

LOGIC_QUALITY_CRITERIA = """\
You are evaluating module design logic quality and algorithmic precision. \
Score against these 3 criteria (0.0-1.0 each):

1. **Algorithm Clarity**: Pseudocode is unambiguous — function signatures \
have typed parameters and return types, control flow uses standard \
constructs (if/else, for, while, try/catch), and invariants are stated.

2. **State Machine Precision**: Stateful modules define all states, \
transitions, guards, and actions in a stateDiagram-v2 mermaid block. \
Invalid transitions are explicitly noted. Stateless modules correctly \
use the N/A bypass.

3. **Error Handling Specificity**: Error Handling & Return Codes sections \
enumerate concrete error conditions, return codes / exceptions, and \
recovery actions — not vague "handle errors" statements.

Return the average score across all 3 criteria. \
Precise, implementable designs score 0.8+. Vague designs score 0.3-0.5.\
"""

DATA_STRUCTURE_PRECISION_CRITERIA = """\
You are evaluating module design internal data structure precision. \
Score against these 3 criteria (0.0-1.0 each):

1. **Type Completeness**: Internal Data Structures sections define all \
data types with field names, types, and constraints. Structs, enums, \
and constants are fully specified.

2. **Module Boundary Clarity**: Target source files are specified for each \
module. Parent ARCH traceability is explicit. Interface data flowing \
between modules is typed.

3. **Implementation Readiness**: The combined views provide enough detail \
for a developer to implement the module without design ambiguity. \
Algorithmic steps reference the declared data structures.

Return the average score across all 3 criteria. \
Implementation-ready designs score 0.8+. Abstract designs score 0.3-0.5.\
"""


def create_module_completeness_metric(threshold: float = 0.7) -> GEval:
    """Create a GEval metric for module design decomposition completeness."""
    return GEval(
        name="Module Design Completeness",
        criteria=MODULE_COMPLETENESS_CRITERIA,
        evaluation_params=[
            LLMTestCaseParams.ACTUAL_OUTPUT,
            LLMTestCaseParams.EXPECTED_OUTPUT,
        ],
        model=_get_model(),
        threshold=threshold,
    )


def create_logic_quality_metric(threshold: float = 0.7) -> GEval:
    """Create a GEval metric for module design logic and algorithmic quality."""
    return GEval(
        name="Module Logic Quality",
        criteria=LOGIC_QUALITY_CRITERIA,
        evaluation_params=[
            LLMTestCaseParams.ACTUAL_OUTPUT,
            LLMTestCaseParams.EXPECTED_OUTPUT,
        ],
        model=_get_model(),
        threshold=threshold,
    )


def create_data_structure_precision_metric(threshold: float = 0.7) -> GEval:
    """Create a GEval metric for module design data structure precision."""
    return GEval(
        name="Data Structure Precision",
        criteria=DATA_STRUCTURE_PRECISION_CRITERIA,
        evaluation_params=[
            LLMTestCaseParams.ACTUAL_OUTPUT,
            LLMTestCaseParams.EXPECTED_OUTPUT,
        ],
        model=_get_model(),
        threshold=threshold,
    )
