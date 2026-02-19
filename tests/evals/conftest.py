"""Pytest fixtures and shared configuration for DeepEval evaluations."""

import pathlib

import pytest

FIXTURES_DIR = pathlib.Path(__file__).parent.parent / "fixtures"
GOLDEN_DIR = FIXTURES_DIR / "golden"


@pytest.fixture
def medical_device_input():
    return (GOLDEN_DIR / "medical-device" / "input-spec.md").read_text()


@pytest.fixture
def medical_device_requirements():
    return (GOLDEN_DIR / "medical-device" / "expected-requirements.md").read_text()


@pytest.fixture
def medical_device_acceptance():
    return (GOLDEN_DIR / "medical-device" / "expected-acceptance.md").read_text()


@pytest.fixture
def automotive_adas_input():
    return (GOLDEN_DIR / "automotive-adas" / "input-spec.md").read_text()


@pytest.fixture
def automotive_adas_requirements():
    return (GOLDEN_DIR / "automotive-adas" / "expected-requirements.md").read_text()


@pytest.fixture
def automotive_adas_acceptance():
    return (GOLDEN_DIR / "automotive-adas" / "expected-acceptance.md").read_text()


@pytest.fixture
def fixture_dir():
    """Return the base fixtures directory path."""
    return FIXTURES_DIR
