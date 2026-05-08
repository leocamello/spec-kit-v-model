"""DeepEval GEval metric for IEEE 42010 software architecture design quality scoring.

This metric uses an LLM judge (Google Gemini) to evaluate software architecture
design documents against completeness, view quality, and interface contract strictness.

Software architecture design (Path B) replaces system-design + architecture-design.
ARCH modules trace directly to REQ (no SYS intermediate layer). The artifact uses
IEEE 42010 viewpoint framework with four mandatory views.

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
You are evaluating a software architecture design document (IEEE 42010) for \
decomposition completeness. Score it against these 3 criteria (0.0-1.0 each):

1. **REQ Decomposition**: Every parent requirement referenced in the input \
is decomposed into at least one ARCH module. No REQ is left unaddressed. \
The decomposition covers functional and non-functional requirements directly \
without an intermediate system layer.

2. **Many-to-Many Traceability**: ARCH modules correctly reference their parent \
REQ identifiers. Multiple ARCH modules may trace to the same REQ, and a single \
ARCH may trace to multiple REQ. Cross-cutting modules are identified with \
[CROSS-CUTTING] annotations.

3. **Cross-Cutting Identification**: The design identifies and explicitly marks \
cross-cutting modules (logging, security, configuration, etc.) that span multiple \
requirements rather than mapping to a single parent.

Return the average score across all 3 criteria. \
A thorough architecture scores 0.8+. A superficial architecture scores 0.4-0.6.\
"""

VIEW_QUALITY_CRITERIA = """\
You are evaluating the quality of IEEE 42010 architectural views in a software \
architecture design document. Score it against these 4 criteria (0.0-1.0 each):

1. **Logical View Quality**: The Logical View table contains meaningful module \
names, clear descriptions, accurate type classifications, and valid parent REQ \
references. No intermediate SYS layer is present.

2. **Process View Quality**: The Process View includes Mermaid sequence or flow \
diagrams showing runtime interactions between ARCH modules. Diagrams use correct \
Mermaid syntax and convey meaningful message flows.

3. **Interface View Quality**: The Interface View defines contracts for each \
module boundary — specifying inputs, outputs, protocols, and data formats. \
External interfaces are distinguished from internal interfaces.

4. **Data Flow View Quality**: The Data Flow View describes data transformations \
as data moves between modules — including formats, validation steps, and \
transformation logic.

Return the average score across all 4 criteria. \
A complete, meaningful architecture scores 0.8+. A boilerplate architecture scores 0.3-0.5.\
"""

INTERFACE_CONTRACT_CRITERIA = """\
You are evaluating a software architecture design document for interface contract \
strictness. Score it against these 3 criteria (0.0-1.0 each):

1. **Input/Output Definition**: Each interface contract explicitly defines its \
inputs and outputs with specific data types, not just prose descriptions. \
For example, "JSON object with fields: temperature (float), timestamp (ISO 8601)" \
rather than "sensor data".

2. **Exception/Error Handling**: Contracts specify error conditions, exception \
types, and failure modes. Each interface documents what happens when inputs are \
invalid or the service is unavailable.

3. **Protocol Specificity**: Contracts specify concrete protocols (REST, gRPC, \
MQTT, shared memory) and data formats (JSON, Protobuf, CSV) rather than generic \
"sends data to" descriptions. External vs internal protocol distinction is clear.

Return the average score across all 3 criteria. \
Strict, well-defined contracts score 0.8+. Vague contracts score 0.3-0.5.\
"""


def create_design_completeness_metric(threshold: float = 0.7) -> GEval:
    """Create a GEval metric for software architecture design decomposition completeness."""
    return GEval(
        name="Software Architecture Design Completeness (IEEE 42010)",
        criteria=DESIGN_COMPLETENESS_CRITERIA,
        evaluation_params=[
            LLMTestCaseParams.ACTUAL_OUTPUT,
            LLMTestCaseParams.EXPECTED_OUTPUT,
        ],
        model=_get_model(),
        threshold=threshold,
    )


def create_view_quality_metric(threshold: float = 0.7) -> GEval:
    """Create a GEval metric for IEEE 42010 view quality."""
    return GEval(
        name="Software Architecture View Quality (IEEE 42010)",
        criteria=VIEW_QUALITY_CRITERIA,
        evaluation_params=[
            LLMTestCaseParams.ACTUAL_OUTPUT,
            LLMTestCaseParams.EXPECTED_OUTPUT,
        ],
        model=_get_model(),
        threshold=threshold,
    )


def create_interface_contract_metric(threshold: float = 0.7) -> GEval:
    """Create a GEval metric for interface contract strictness."""
    return GEval(
        name="Software Architecture Interface Contract Strictness",
        criteria=INTERFACE_CONTRACT_CRITERIA,
        evaluation_params=[
            LLMTestCaseParams.ACTUAL_OUTPUT,
            LLMTestCaseParams.EXPECTED_OUTPUT,
        ],
        model=_get_model(),
        threshold=threshold,
    )
