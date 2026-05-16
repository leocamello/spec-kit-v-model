# Implements: REQ-CN-001, REQ-IF-003, REQ-IF-005, SYS-011, ARCH-015, MOD-020, ATP-003-A, HAZ-011, HAZ-018, D-007
"""Structural validator for ``extension.yml`` (T023).

Asserts the bridge-command registration shape promised by Step B.6 / T019:

- Exactly the **3 new commands** (``speckit.v-model.plan``,
  ``speckit.v-model.tasks``, ``speckit.v-model.implement``) are registered
  on top of the v0.6.0 baseline (REQ-CN-001, MOD-020).
- Exactly the **3 new hooks** (``after_specify``, ``before_implement``,
  ``after_implement``) are added, each with ``optional: true``, while the
  existing ``after_tasks`` → ``speckit.v-model.trace`` hook remains intact
  (REQ-IF-003, REQ-IF-005, ARCH-015, D-007).
- No spec-kit-core file outside ``extension.yml`` is touched (HAZ-018).

Pure pytest + PyYAML — no LLM, no DeepEval. Per ATP-003-A.
"""

from __future__ import annotations

import pathlib
import subprocess

import pytest
import yaml

REPO_ROOT = pathlib.Path(__file__).resolve().parents[2]
EXT_YML = REPO_ROOT / "extension.yml"

NEW_COMMANDS = {
    "speckit.v-model.plan",
    "speckit.v-model.tasks",
    "speckit.v-model.implement",
}

EXPECTED_NEW_HOOKS = {
    "after_specify": "speckit.v-model.requirements",
    "before_implement": "speckit.v-model.trace",
    "after_implement": "speckit.v-model.trace",
}

EXPECTED_EXISTING_HOOK = ("after_tasks", "speckit.v-model.trace")


@pytest.fixture(scope="module")
def extension() -> dict:
    return yaml.safe_load(EXT_YML.read_text(encoding="utf-8"))


# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------


@pytest.mark.structural
def test_extension_registers_three_new_commands(extension: dict):
    """REQ-CN-001/MOD-020: the three v0.7.0 bridge commands are registered."""
    cmds = {c["name"] for c in extension["provides"]["commands"]}
    missing = NEW_COMMANDS - cmds
    assert not missing, f"extension.yml is missing bridge commands: {missing}"


@pytest.mark.structural
def test_total_command_count_is_baseline_plus_three(extension: dict):
    """Baseline (14) + 3 new = 17 commands (per Step B.6)."""
    cmds = extension["provides"]["commands"]
    assert len(cmds) == 17, (
        f"extension.yml must register exactly 17 commands "
        f"(14 baseline + 3 bridge); found {len(cmds)}"
    )


@pytest.mark.structural
def test_no_duplicate_command_names(extension: dict):
    names = [c["name"] for c in extension["provides"]["commands"]]
    assert len(names) == len(set(names)), (
        f"extension.yml has duplicate command names: {sorted(names)}"
    )


@pytest.mark.structural
def test_new_commands_point_to_existing_files(extension: dict):
    cmds = {c["name"]: c for c in extension["provides"]["commands"]}
    for name in NEW_COMMANDS:
        cmd = cmds[name]
        cmd_path = REPO_ROOT / cmd["file"]
        assert cmd_path.is_file(), (
            f"extension.yml command {name!r} points to missing file: {cmd['file']}"
        )


# ---------------------------------------------------------------------------
# Hooks
# ---------------------------------------------------------------------------


@pytest.mark.structural
def test_existing_after_tasks_hook_preserved(extension: dict):
    """The pre-existing ``after_tasks`` → ``v-model.trace`` hook must remain."""
    hook_name, expected_cmd = EXPECTED_EXISTING_HOOK
    hooks = extension.get("hooks", {})
    assert hook_name in hooks, f"existing hook {hook_name!r} was removed"
    assert hooks[hook_name]["command"] == expected_cmd, (
        f"hook {hook_name!r} no longer dispatches to {expected_cmd!r}: "
        f"{hooks[hook_name]}"
    )


@pytest.mark.structural
def test_three_new_hooks_added_with_optional_true(extension: dict):
    """REQ-IF-003/REQ-IF-005/ARCH-015: the three new hooks are present and optional."""
    hooks = extension.get("hooks", {})
    for name, expected_cmd in EXPECTED_NEW_HOOKS.items():
        assert name in hooks, f"extension.yml is missing hook: {name}"
        entry = hooks[name]
        assert entry.get("command") == expected_cmd, (
            f"hook {name!r} dispatches to {entry.get('command')!r}, "
            f"expected {expected_cmd!r}"
        )
        assert entry.get("optional") is True, (
            f"hook {name!r} must be optional: true (D-007 cooperative posture)"
        )


@pytest.mark.structural
def test_total_hook_count_is_one_plus_three(extension: dict):
    hooks = extension.get("hooks", {})
    assert len(hooks) == 4, (
        f"extension.yml must declare exactly 4 hooks (1 baseline + 3 bridge); "
        f"found {len(hooks)}: {sorted(hooks)}"
    )


# ---------------------------------------------------------------------------
# Cross-cutting: no spec-kit-core file modified outside extension.yml
# ---------------------------------------------------------------------------


def _run_git(*args: str) -> tuple[int, str, str]:
    proc = subprocess.run(
        ["git", "-C", str(REPO_ROOT), *args],
        capture_output=True,
        text=True,
    )
    return proc.returncode, proc.stdout, proc.stderr


@pytest.mark.structural
def test_no_spec_kit_core_file_modified_outside_extension_yml():
    """HAZ-018: only ``extension.yml`` is touched in the spec-kit-core surface."""
    rc, _, _ = _run_git("rev-parse", "origin/main")
    if rc != 0:
        pytest.skip("origin/main unavailable; skipping cross-cutting modification check")
    rc, base, _ = _run_git("merge-base", "HEAD", "origin/main")
    if rc != 0:
        pytest.skip("could not compute merge-base with origin/main")
    base = base.strip()
    rc, out, err = _run_git("diff", "--name-only", f"{base}..HEAD")
    if rc != 0:
        pytest.skip(f"git diff failed: {err}")
    changed = [p for p in out.splitlines() if p.strip()]
    # Allowed surfaces (extension only owns these paths).
    allowed_prefixes = (
        "extension.yml",
        "specs/",
        "tests/",
        "commands/",
        "scripts/",
        "templates/",
        "overlays/",
        "docs/",
        "CHANGELOG.md",
        "AGENTS.md",
        "CLAUDE.md",
        "README.md",
        "pyproject.toml",
        ".github/",
        ".specify/",
        ".gitignore",
        "v-model-config.yml.example",
        "catalog-entry.json",
        "site/",
        "CONTRIBUTING.md",
        "SECURITY.md",
        "CODE_OF_CONDUCT.md",
    )
    offenders = [
        p for p in changed
        if not any(p == prefix or p.startswith(prefix) for prefix in allowed_prefixes)
    ]
    assert not offenders, (
        f"Bridge work has touched files outside the extension surface "
        f"(spec-kit-core territory): {offenders}"
    )
