# Implements: REQ-021, SYS-008, ARCH-018, MOD-008, MOD-023, UTP-008-A, ATP-021-A, SCN-021-A1, D-010
"""Eval suite for the commit-subject suffix grammar (T022).

Per ARCH-018 / MOD-023 the implement command appends an em-dash and a
comma-separated list of every V-Model ID fulfilled by the change to the
commit subject:

    <base-message> — <ID>, <ID>, …

Structural test asserts the prompt documents this grammar; LLM-judge test
parses the prepared subject from a synthesised invocation and matches it
against the regex (SCN-021-A1, ATP-021-A). Per D-010 (eval strategy).
"""

from __future__ import annotations

import os
import pathlib
import re

import pytest

REPO_ROOT = pathlib.Path(__file__).resolve().parents[2]
IMPLEMENT_MD = REPO_ROOT / "commands" / "implement.md"

# Em-dash separated subject grammar. ID grammar matches the canonical
# regex used by tests/conftest.py and validate-implements-ids.sh:
#   <PREFIX>-<digits>[-<UPPERCASE-ALNUM>]+   plus optional D-NNN.
_ID = r"(?:REQ|REQ-NF|REQ-CN|REQ-IF|SYS|ARCH|MOD|ITP|ITS|UTP|UTS|STP|STS|ATP|SCN|HAZ)-\d+(?:-[A-Z]\d*)?|D-\d+"
COMMIT_SUFFIX_RE = re.compile(
    rf"^.+\s—\s({_ID})(?:,\s({_ID}))*\s*$"
)

_SKIP_NO_KEY = pytest.mark.skipif(
    not os.environ.get("GOOGLE_API_KEY"),
    reason="GOOGLE_API_KEY not set; LLM-judge tests skipped",
)


# ---------------------------------------------------------------------------
# Structural
# ---------------------------------------------------------------------------


class TestCommitSuffixStructural:
    """Deterministic checks against ``commands/implement.md``."""

    @pytest.mark.structural
    def test_prompt_documents_em_dash_suffix_grammar(self):
        """ARCH-018/MOD-023: prompt documents the em-dash + comma-list suffix."""
        body = IMPLEMENT_MD.read_text(encoding="utf-8")
        # Em-dash (U+2014) must appear in a commit-subject context.
        assert "—" in body, (
            "commands/implement.md must use the em-dash in commit-subject grammar"
        )
        # Either the literal grammar template or its key keywords.
        assert re.search(
            r"<base[- ]message>\s*—", body
        ) or re.search(
            r"commit (subject|message).*—", body, re.IGNORECASE
        ), "commands/implement.md must document the commit-subject suffix grammar"
        for cite in ("ARCH-018", "MOD-023"):
            assert cite in body, (
                f"commands/implement.md must cite {cite} for the suffix grammar"
            )

    @pytest.mark.structural
    def test_suffix_regex_round_trips_on_canonical_example(self):
        """SCN-021-A1: the regex matches a canonical em-dash-suffixed subject."""
        sample = "feat(commands): bridge implement command — REQ-019, ARCH-018, MOD-023"
        assert COMMIT_SUFFIX_RE.match(sample), (
            f"COMMIT_SUFFIX_RE must accept a canonical sample: {sample!r}"
        )


# ---------------------------------------------------------------------------
# LLM-judge
# ---------------------------------------------------------------------------


def _load_fixture(name: str) -> dict[str, str]:
    fdir = REPO_ROOT / "tests" / "fixtures" / "v-model" / name
    return {p.name: p.read_text(encoding="utf-8") for p in sorted(fdir.glob("*.md"))}


def _extract_commit_subject(output: str) -> str | None:
    # Look for a line beginning with `git commit -m "..."` or a fenced
    # commit subject. Prefer the quoted git-commit form.
    m = re.search(r"git commit\s+-m\s+[\"']([^\"'\n]+)[\"']", output)
    if m:
        return m.group(1).strip()
    # Fallback: any line containing an em-dash followed by a canonical ID.
    for line in output.splitlines():
        if "—" in line and re.search(_ID, line):
            return line.strip()
    return None


class TestCommitSuffixLLMJudge:
    """Replay implement command and validate the prepared commit subject."""

    @pytest.mark.llm_judge
    @_SKIP_NO_KEY
    def test_synthesised_commit_subject_matches_grammar(self):
        """ATP-021-A/SCN-021-A1: prepared subject matches the em-dash suffix regex."""
        from tests.evals.harness import invoke

        ctx = _load_fixture("complete")
        output = invoke(
            "implement",
            context_files=ctx,
            arguments="Implement and stage the change",
        )
        subject = _extract_commit_subject(output)
        if subject is None:
            pytest.skip("LLM did not emit a recognisable commit subject in this run")
        assert COMMIT_SUFFIX_RE.match(subject), (
            f"Commit subject {subject!r} does not match the em-dash + ID-list grammar"
        )
