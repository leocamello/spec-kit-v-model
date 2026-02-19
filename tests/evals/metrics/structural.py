"""DeepEval metric wrappers for V-Model structural validators.

These metrics are deterministic (no LLM calls) and wrap the validators
from tests/validators/ into DeepEval-compatible metric classes.
"""

from deepeval.metrics import BaseMetric
from deepeval.test_case import LLMTestCase

from tests.validators.id_validator import validate_all as validate_ids
from tests.validators.template_validator import (
    validate_requirements,
    validate_acceptance_plan,
    validate_traceability_matrix,
)
from tests.validators.bdd_validator import validate_all_scenarios


class StructuralIDMetric(BaseMetric):
    """Deterministic metric for V-Model ID format and hierarchy validation."""

    def __init__(self, threshold: float = 0.95):
        self.threshold = threshold
        self.score = None
        self.reason = None
        self.success = None

    @property
    def __name__(self):
        return "Structural ID Compliance"

    async def a_measure(self, test_case: LLMTestCase, *args, **kwargs) -> float:
        return self.measure(test_case)

    def measure(self, test_case: LLMTestCase, *args, **kwargs) -> float:
        text = test_case.actual_output or ""
        result = validate_ids(text)
        self.score = result["score"]
        self.success = self.score >= self.threshold
        if result["issues"]:
            self.reason = "; ".join(result["issues"][:5])
        else:
            self.reason = "All IDs pass format and hierarchy validation"
        return self.score

    def is_successful(self) -> bool:
        return self.success if self.success is not None else False


class StructuralTemplateMetric(BaseMetric):
    """Deterministic metric for V-Model document template conformance."""

    def __init__(self, document_type: str = "requirements", threshold: float = 0.95):
        """
        Args:
            document_type: One of 'requirements', 'acceptance', 'traceability'
            threshold: Minimum score to pass (0.0-1.0)
        """
        self.document_type = document_type
        self.threshold = threshold
        self.score = None
        self.reason = None
        self.success = None

        self._validators = {
            "requirements": validate_requirements,
            "acceptance": validate_acceptance_plan,
            "traceability": validate_traceability_matrix,
        }
        if document_type not in self._validators:
            raise ValueError(f"Unknown document_type: {document_type}")

    @property
    def __name__(self):
        return f"Template Conformance ({self.document_type})"

    async def a_measure(self, test_case: LLMTestCase, *args, **kwargs) -> float:
        return self.measure(test_case)

    def measure(self, test_case: LLMTestCase, *args, **kwargs) -> float:
        text = test_case.actual_output or ""
        validator = self._validators[self.document_type]
        result = validator(text)
        self.score = result["score"]
        self.success = self.score >= self.threshold
        if result["issues"]:
            self.reason = "; ".join(result["issues"][:5])
        else:
            self.reason = f"Document passes all {self.document_type} template checks"
        return self.score

    def is_successful(self) -> bool:
        return self.success if self.success is not None else False


class StructuralBDDMetric(BaseMetric):
    """Deterministic metric for BDD scenario format validation."""

    def __init__(self, threshold: float = 0.95):
        self.threshold = threshold
        self.score = None
        self.reason = None
        self.success = None

    @property
    def __name__(self):
        return "BDD Scenario Compliance"

    async def a_measure(self, test_case: LLMTestCase, *args, **kwargs) -> float:
        return self.measure(test_case)

    def measure(self, test_case: LLMTestCase, *args, **kwargs) -> float:
        text = test_case.actual_output or ""
        result = validate_all_scenarios(text)
        self.score = result["score"]
        self.success = self.score >= self.threshold
        total = result["total_scenarios"]
        valid = result["valid_scenarios"]
        if result["issues"]:
            self.reason = f"{valid}/{total} valid; " + "; ".join(result["issues"][:5])
        else:
            self.reason = f"All {total} scenarios have valid Given/When/Then structure"
        return self.score

    def is_successful(self) -> bool:
        return self.success if self.success is not None else False
