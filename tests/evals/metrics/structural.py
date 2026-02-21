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
from tests.validators.system_validators import (
    extract_ids as sys_extract_ids,
    validate_id_format as sys_validate_id_format,
    extract_parent_requirements,
    validate_all as sys_validate_all,
)
from tests.validators.architecture_validators import (
    extract_ids as arch_extract_ids,
    validate_id_format as arch_validate_id_format,
    extract_parent_system_components,
)


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


class StructuralSystemDesignMetric(BaseMetric):
    """Deterministic metric for system design structural validation.

    Checks SYS-NNN ID format, IEEE 1016 views presence, and parent REQ references.
    """

    _IEEE_1016_VIEWS = [
        "Decomposition",
        "Dependency",
        "Interface",
        "Data Design",
    ]

    def __init__(self, threshold: float = 0.95):
        self.threshold = threshold
        self.score = None
        self.reason = None
        self.success = None

    @property
    def __name__(self):
        return "System Design Structural Compliance"

    async def a_measure(self, test_case: LLMTestCase, *args, **kwargs) -> float:
        return self.measure(test_case)

    def measure(self, test_case: LLMTestCase, *args, **kwargs) -> float:
        text = test_case.actual_output or ""
        issues: list[str] = []
        total_checks = 0

        # 1. SYS-NNN ID format compliance
        sys_ids = sys_extract_ids(text, "SYS")
        unique_sys = list(dict.fromkeys(sys_ids))
        total_checks += max(len(unique_sys), 1)
        bad = sys_validate_id_format(unique_sys, "SYS")
        for b in bad:
            issues.append(f"Malformed SYS ID: {b}")

        # 2. IEEE 1016 views presence
        for view in self._IEEE_1016_VIEWS:
            total_checks += 1
            if view.lower() not in text.lower():
                issues.append(f"Missing IEEE 1016 view: {view}")

        # 3. Parent REQ references in every SYS row
        for sys_id in unique_sys:
            total_checks += 1
            parents = extract_parent_requirements(text, sys_id)
            if not parents:
                issues.append(f"{sys_id} has no parent REQ reference")

        if total_checks == 0:
            self.score = 0.0
        else:
            self.score = round(max(0.0, 1.0 - len(issues) / total_checks), 2)
        self.success = self.score >= self.threshold
        if issues:
            self.reason = "; ".join(issues[:5])
        else:
            self.reason = "All system design structural checks pass"
        return self.score

    def is_successful(self) -> bool:
        return self.success if self.success is not None else False


class StructuralSystemTestMetric(BaseMetric):
    """Deterministic metric for system test structural validation.

    Checks STP-NNN-X / STS-NNN-X# ID format, ISO 29119 technique naming,
    and technical BDD language (no user-journey phrases).
    """

    _ISO_29119_TECHNIQUES = {
        "Interface Contract Testing",
        "Boundary Value Analysis",
        "Fault Injection",
        "Equivalence Partitioning",
        "State Transition Testing",
    }

    _USER_JOURNEY_PATTERNS = [
        "the user clicks",
        "the user sees",
        "the user navigates",
        "the user selects",
        "the user enters",
        "the user logs in",
    ]

    def __init__(self, threshold: float = 0.95):
        self.threshold = threshold
        self.score = None
        self.reason = None
        self.success = None

    @property
    def __name__(self):
        return "System Test Structural Compliance"

    async def a_measure(self, test_case: LLMTestCase, *args, **kwargs) -> float:
        return self.measure(test_case)

    def measure(self, test_case: LLMTestCase, *args, **kwargs) -> float:
        import re

        text = test_case.actual_output or ""
        issues: list[str] = []
        total_checks = 0

        # 1. STP-NNN-X ID format compliance
        stp_ids = sys_extract_ids(text, "STP")
        unique_stp = list(dict.fromkeys(stp_ids))
        total_checks += max(len(unique_stp), 1)
        bad_stp = sys_validate_id_format(unique_stp, "STP")
        for b in bad_stp:
            issues.append(f"Malformed STP ID: {b}")

        # 2. STS-NNN-X# ID format compliance
        sts_ids = sys_extract_ids(text, "STS")
        unique_sts = list(dict.fromkeys(sts_ids))
        total_checks += max(len(unique_sts), 1)
        bad_sts = sys_validate_id_format(unique_sts, "STS")
        for b in bad_sts:
            issues.append(f"Malformed STS ID: {b}")

        # 3. ISO 29119 technique naming
        technique_pattern = re.compile(r"\*\*Technique\*\*:\s*(.+)")
        found_techniques = technique_pattern.findall(text)
        for tech in found_techniques:
            total_checks += 1
            tech_stripped = tech.strip()
            if tech_stripped not in self._ISO_29119_TECHNIQUES:
                issues.append(f"Non-ISO 29119 technique: {tech_stripped}")

        # 4. Technical BDD language (no user-journey phrases)
        text_lower = text.lower()
        for phrase in self._USER_JOURNEY_PATTERNS:
            total_checks += 1
            if phrase in text_lower:
                issues.append(f"User-journey phrase detected: '{phrase}'")

        if total_checks == 0:
            self.score = 0.0
        else:
            self.score = round(max(0.0, 1.0 - len(issues) / total_checks), 2)
        self.success = self.score >= self.threshold
        if issues:
            self.reason = "; ".join(issues[:5])
        else:
            self.reason = "All system test structural checks pass"
        return self.score

    def is_successful(self) -> bool:
        return self.success if self.success is not None else False


class StructuralArchitectureDesignMetric(BaseMetric):
    """Deterministic metric for architecture design structural validation.

    Checks ARCH-NNN ID format, Kruchten 4+1 views presence, and parent SYS references.
    """

    _KRUCHTEN_VIEWS = [
        "Logical",
        "Process",
        "Interface",
        "Data Flow",
    ]

    def __init__(self, threshold: float = 0.95):
        self.threshold = threshold
        self.score = None
        self.reason = None
        self.success = None

    @property
    def __name__(self):
        return "Architecture Design Structural Compliance"

    async def a_measure(self, test_case: LLMTestCase, *args, **kwargs) -> float:
        return self.measure(test_case)

    def measure(self, test_case: LLMTestCase, *args, **kwargs) -> float:
        import re

        text = test_case.actual_output or ""
        issues: list[str] = []
        total_checks = 0

        # 1. ARCH-NNN ID format compliance
        arch_ids = arch_extract_ids(text, "ARCH")
        unique_arch = list(dict.fromkeys(arch_ids))
        total_checks += max(len(unique_arch), 1)
        bad = arch_validate_id_format(unique_arch, "ARCH")
        for b in bad:
            issues.append(f"Malformed ARCH ID: {b}")

        # 2. Kruchten 4+1 views presence
        for view in self._KRUCHTEN_VIEWS:
            total_checks += 1
            if view.lower() not in text.lower():
                issues.append(f"Missing Kruchten 4+1 view: {view}")

        # 3. Parent SYS references in every ARCH row
        for arch_id in unique_arch:
            total_checks += 1
            parents = extract_parent_system_components(text, arch_id)
            if not parents:
                issues.append(f"{arch_id} has no parent SYS reference")

        if total_checks == 0:
            self.score = 0.0
        else:
            self.score = round(max(0.0, 1.0 - len(issues) / total_checks), 2)
        self.success = self.score >= self.threshold
        if issues:
            self.reason = "; ".join(issues[:5])
        else:
            self.reason = "All architecture design structural checks pass"
        return self.score

    def is_successful(self) -> bool:
        return self.success if self.success is not None else False


class StructuralIntegrationTestMetric(BaseMetric):
    """Deterministic metric for integration test structural validation.

    Checks ITP-NNN-X / ITS-NNN-X# ID format, integration test technique naming,
    and module-boundary BDD language (no user-journey phrases).
    """

    _INTEGRATION_TECHNIQUES = {
        "Interface Contract Testing",
        "Data Flow Testing",
        "Interface Fault Injection",
        "Concurrency & Race Condition Testing",
    }

    _USER_JOURNEY_PATTERNS = [
        "the user clicks",
        "the user sees",
        "the user navigates",
        "the user selects",
        "the user enters",
        "the user logs in",
    ]

    def __init__(self, threshold: float = 0.95):
        self.threshold = threshold
        self.score = None
        self.reason = None
        self.success = None

    @property
    def __name__(self):
        return "Integration Test Structural Compliance"

    async def a_measure(self, test_case: LLMTestCase, *args, **kwargs) -> float:
        return self.measure(test_case)

    def measure(self, test_case: LLMTestCase, *args, **kwargs) -> float:
        import re

        text = test_case.actual_output or ""
        issues: list[str] = []
        total_checks = 0

        # 1. ITP-NNN-X ID format compliance
        itp_ids = arch_extract_ids(text, "ITP")
        unique_itp = list(dict.fromkeys(itp_ids))
        total_checks += max(len(unique_itp), 1)
        bad_itp = arch_validate_id_format(unique_itp, "ITP")
        for b in bad_itp:
            issues.append(f"Malformed ITP ID: {b}")

        # 2. ITS-NNN-X# ID format compliance
        its_ids = arch_extract_ids(text, "ITS")
        unique_its = list(dict.fromkeys(its_ids))
        total_checks += max(len(unique_its), 1)
        bad_its = arch_validate_id_format(unique_its, "ITS")
        for b in bad_its:
            issues.append(f"Malformed ITS ID: {b}")

        # 3. Integration test technique naming
        technique_pattern = re.compile(r"\*\*Technique\*\*:\s*(.+)")
        found_techniques = technique_pattern.findall(text)
        for tech in found_techniques:
            total_checks += 1
            tech_stripped = tech.strip()
            if tech_stripped not in self._INTEGRATION_TECHNIQUES:
                issues.append(f"Non-standard integration technique: {tech_stripped}")

        # 4. Module-boundary BDD language (no user-journey phrases)
        text_lower = text.lower()
        for phrase in self._USER_JOURNEY_PATTERNS:
            total_checks += 1
            if phrase in text_lower:
                issues.append(f"User-journey phrase detected: '{phrase}'")

        if total_checks == 0:
            self.score = 0.0
        else:
            self.score = round(max(0.0, 1.0 - len(issues) / total_checks), 2)
        self.success = self.score >= self.threshold
        if issues:
            self.reason = "; ".join(issues[:5])
        else:
            self.reason = "All integration test structural checks pass"
        return self.score

    def is_successful(self) -> bool:
        return self.success if self.success is not None else False
