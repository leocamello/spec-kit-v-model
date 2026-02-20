"""E2E eval harness — renders spec-kit command templates into LLM prompts and invokes them.

This module provides the infrastructure for end-to-end evaluation tests:
1. Parse command markdown files (YAML frontmatter + prompt body)
2. Render prompts by replacing placeholders with test inputs
3. Provide context documents (requirements.md, templates, etc.)
4. Call the LLM and return raw output for evaluation

Requires GOOGLE_API_KEY environment variable.
"""

import os
import pathlib
import re

import yaml

COMMANDS_DIR = pathlib.Path(__file__).parent.parent.parent / "commands"
TEMPLATES_DIR = pathlib.Path(__file__).parent.parent.parent / "templates"

# Map command names to the template files they reference
COMMAND_TEMPLATES = {
    "requirements": "requirements-template.md",
    "acceptance": "acceptance-plan-template.md",
    "system-design": "system-design-template.md",
    "system-test": "system-test-template.md",
}

E2E_MODEL_NAME = os.getenv("E2E_MODEL", "gemini-2.5-flash")


def parse_command(command_name: str) -> tuple[dict, str]:
    """Parse a command markdown file into (frontmatter, prompt_body).

    Args:
        command_name: Command filename without extension (e.g., "requirements").

    Returns:
        Tuple of (YAML frontmatter dict, prompt body string).
    """
    path = COMMANDS_DIR / f"{command_name}.md"
    text = path.read_text()

    match = re.match(r"^---\n(.*?)\n---\n(.*)", text, re.DOTALL)
    if not match:
        raise ValueError(f"Could not parse YAML frontmatter from {path}")

    frontmatter = yaml.safe_load(match.group(1))
    body = match.group(2).strip()
    return frontmatter, body


def render_prompt(
    command_name: str,
    context_files: dict[str, str],
    arguments: str = "",
) -> str:
    """Render a command template into a complete LLM prompt.

    Args:
        command_name: Name of the command (e.g., "requirements", "acceptance").
        context_files: Dict mapping filename to content
            (e.g., {"requirements.md": "..."}).
        arguments: User input to substitute for $ARGUMENTS.

    Returns:
        The assembled prompt string ready for LLM invocation.
    """
    _, body = parse_command(command_name)

    # Substitute user input
    body = body.replace("$ARGUMENTS", arguments or "(no user input)")

    # Neutralize script/path placeholders — context is provided directly
    body = re.sub(r"\{SCRIPT\}", "[setup script — skip, context provided below]", body)
    body = re.sub(r"\{SCRIPTS_DIR\}", "[scripts directory — skip]", body)
    body = re.sub(r"\{VMODEL_DIR\}", "[output directory]", body)
    body = re.sub(r"\{FEATURE_DIR\}", "[feature directory]", body)

    # Load the matching template if available
    template_name = COMMAND_TEMPLATES.get(command_name)
    if template_name:
        template_path = TEMPLATES_DIR / template_name
        if template_path.exists():
            context_files = {
                template_name: template_path.read_text(),
                **context_files,
            }

    # Append context files as a block the LLM can reference
    context_section = (
        "\n\n---\n\n"
        "## Context Files (provided for this evaluation)\n\n"
        "The files below replace the setup-script and file-loading steps above. "
        "Use them as if you had loaded them from disk.\n\n"
    )
    for filename, content in context_files.items():
        context_section += f"### {filename}\n\n```markdown\n{content}\n```\n\n"

    # Evaluation-specific instructions
    eval_instructions = (
        "---\n\n"
        "## E2E Evaluation Instructions\n\n"
        "You are being evaluated on the quality of your output. Follow these rules:\n"
        "1. **Skip** the setup script execution — all required context is above.\n"
        "2. **Skip** helper-script validation steps (validate-coverage, diff-requirements) "
        "— the evaluator will run structural checks on your output.\n"
        "3. **Generate ONLY the output document** (the markdown that would be written "
        "to the output file). No status messages, summaries, or next-step prompts.\n"
        "4. **Do NOT wrap** the output in a code fence. Output raw markdown directly.\n"
    )

    return body + context_section + eval_instructions


def invoke(
    command_name: str,
    context_files: dict[str, str],
    arguments: str = "",
    model: str | None = None,
) -> str:
    """Invoke a spec-kit command via LLM and return the generated document.

    Args:
        command_name: Name of the command (e.g., "requirements").
        context_files: Dict mapping filename to content.
        arguments: User input for $ARGUMENTS.
        model: Gemini model name override (defaults to E2E_MODEL env var).

    Returns:
        The LLM-generated output document as a string.

    Raises:
        EnvironmentError: If GOOGLE_API_KEY is not set.
    """
    if not os.getenv("GOOGLE_API_KEY"):
        raise EnvironmentError(
            "GOOGLE_API_KEY environment variable is required for E2E evals"
        )

    # Lazy import to avoid requiring google-genai for structural-only runs
    from google import genai

    prompt = render_prompt(command_name, context_files, arguments)

    client = genai.Client()
    response = client.models.generate_content(
        model=model or E2E_MODEL_NAME,
        contents=prompt,
    )
    return response.text
