"""E2E eval harness — faithfully simulates spec-kit command invocation.

Spec-kit commands are LLM agent prompts. At runtime the LLM:
  1. Receives the full command markdown as its prompt
  2. Executes the setup script (setup-v-model.sh) → gets JSON with paths
  3. Reads files from those paths (requirements.md, templates, etc.)
  4. Follows the command's execution steps to generate the output document

This harness replicates that pipeline:
  - The command prompt body is used UNMODIFIED (no placeholder neutralisation)
  - The setup-script JSON output is simulated with realistic paths
  - File contents are pre-loaded as tool-call results (as Copilot would provide)
  - The LLM is given a system instruction matching spec-kit's agent role

Requires GOOGLE_API_KEY environment variable.
"""

import json
import os
import pathlib
import re

import yaml

REPO_ROOT = pathlib.Path(__file__).parent.parent.parent
COMMANDS_DIR = REPO_ROOT / "commands"
TEMPLATES_DIR = REPO_ROOT / "templates"

# Map command names to the template files they reference
COMMAND_TEMPLATES = {
    "requirements": "requirements-template.md",
    "acceptance": "acceptance-plan-template.md",
    "system-design": "system-design-template.md",
    "system-test": "system-test-template.md",
    "architecture-design": "architecture-design-template.md",
    "integration-test": "integration-test-template.md",
    "module-design": "module-design-template.md",
    "unit-test": "unit-test-template.md",
}

# Map command names to which docs they need available
COMMAND_AVAILABLE_DOCS = {
    "requirements": lambda ctx: (
        ["spec.md"] if "spec.md" in ctx else []
    ),
    "acceptance": lambda ctx: (
        ["requirements.md"] + (["spec.md"] if "spec.md" in ctx else [])
    ),
    "system-design": lambda ctx: (
        ["requirements.md"] + (["spec.md"] if "spec.md" in ctx else [])
    ),
    "system-test": lambda ctx: (
        ["requirements.md", "system-design.md"]
        + (["spec.md"] if "spec.md" in ctx else [])
    ),
    "architecture-design": lambda ctx: (
        ["requirements.md", "system-design.md"]
        + (["spec.md"] if "spec.md" in ctx else [])
    ),
    "integration-test": lambda ctx: (
        ["requirements.md", "architecture-design.md"]
        + (["system-design.md"] if "system-design.md" in ctx else [])
        + (["spec.md"] if "spec.md" in ctx else [])
    ),
    "module-design": lambda ctx: (
        ["requirements.md", "architecture-design.md"]
        + (["system-design.md"] if "system-design.md" in ctx else [])
        + (["spec.md"] if "spec.md" in ctx else [])
    ),
    "unit-test": lambda ctx: (
        ["requirements.md", "architecture-design.md", "module-design.md"]
        + (["system-design.md"] if "system-design.md" in ctx else [])
        + (["spec.md"] if "spec.md" in ctx else [])
    ),
}

E2E_MODEL_NAME = os.getenv("E2E_MODEL", "gemini-2.5-flash")

# Simulated project paths (matching real setup-v-model.sh output format)
_SIM_REPO = "/workspace/project"
_SIM_FEATURE = f"{_SIM_REPO}/specs/eval-feature"
_SIM_VMODEL = f"{_SIM_FEATURE}/v-model"


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


def _build_script_json(command_name: str, context_files: dict[str, str]) -> str:
    """Build the simulated JSON output from setup-v-model.sh.

    Mirrors the real script's output format exactly.
    """
    available_docs_fn = COMMAND_AVAILABLE_DOCS.get(command_name, lambda _: [])
    available_docs = available_docs_fn(context_files)

    return json.dumps({
        "REPO_ROOT": _SIM_REPO,
        "BRANCH": "eval-feature",
        "FEATURE_DIR": _SIM_FEATURE,
        "VMODEL_DIR": _SIM_VMODEL,
        "SPEC": f"{_SIM_FEATURE}/spec.md",
        "REQUIREMENTS": f"{_SIM_VMODEL}/requirements.md",
        "ACCEPTANCE": f"{_SIM_VMODEL}/acceptance-plan.md",
        "TRACE_MATRIX": f"{_SIM_VMODEL}/traceability-matrix.md",
        "SYSTEM_DESIGN": f"{_SIM_VMODEL}/system-design.md",
        "SYSTEM_TEST": f"{_SIM_VMODEL}/system-test.md",
        "ARCH_DESIGN": f"{_SIM_VMODEL}/architecture-design.md",
        "INTEGRATION_TEST": f"{_SIM_VMODEL}/integration-test.md",
        "MODULE_DESIGN": f"{_SIM_VMODEL}/module-design.md",
        "UNIT_TEST": f"{_SIM_VMODEL}/unit-test.md",
        "AVAILABLE_DOCS": available_docs,
    })


def _build_file_contents(
    command_name: str, context_files: dict[str, str]
) -> str:
    """Build the file-read results as the LLM would see them after loading.

    In spec-kit, the LLM uses tool calls to read files from the paths
    returned by the setup script. This simulates those tool-call results.
    """
    # Load the matching template (the command instructs the LLM to read it)
    template_name = COMMAND_TEMPLATES.get(command_name)
    all_files: dict[str, str] = {}
    if template_name:
        template_path = TEMPLATES_DIR / template_name
        if template_path.exists():
            all_files[f"templates/{template_name}"] = template_path.read_text()

    # Map context file names to their simulated paths
    path_map = {
        "spec.md": f"{_SIM_FEATURE}/spec.md",
        "requirements.md": f"{_SIM_VMODEL}/requirements.md",
        "acceptance-plan.md": f"{_SIM_VMODEL}/acceptance-plan.md",
        "system-design.md": f"{_SIM_VMODEL}/system-design.md",
        "system-test.md": f"{_SIM_VMODEL}/system-test.md",
        "architecture-design.md": f"{_SIM_VMODEL}/architecture-design.md",
        "integration-test.md": f"{_SIM_VMODEL}/integration-test.md",
        "module-design.md": f"{_SIM_VMODEL}/module-design.md",
        "unit-test.md": f"{_SIM_VMODEL}/unit-test.md",
    }
    for filename, content in context_files.items():
        path = path_map.get(filename, f"{_SIM_VMODEL}/{filename}")
        all_files[path] = content

    sections = []
    for path, content in all_files.items():
        sections.append(f"File: {path}\n```markdown\n{content}\n```")

    return "\n\n".join(sections)


def render_prompt(
    command_name: str,
    context_files: dict[str, str],
    arguments: str = "",
) -> str:
    """Render a spec-kit command into a faithful LLM prompt.

    Simulates the spec-kit runtime:
    1. The command body is used as-is (with $ARGUMENTS substituted)
    2. A pre-execution context block provides the setup-script JSON output
       and all file contents the command would load
    3. A minimal output instruction ensures only the document is returned

    Args:
        command_name: Name of the command (e.g., "requirements", "acceptance").
        context_files: Dict mapping filename to content
            (e.g., {"requirements.md": "...", "spec.md": "..."}).
        arguments: User input to substitute for $ARGUMENTS.

    Returns:
        The assembled prompt string ready for LLM invocation.
    """
    _, body = parse_command(command_name)

    # Substitute user input (spec-kit does this before sending to the LLM)
    body = body.replace("$ARGUMENTS", arguments or "(no user input)")

    # Build the simulated tool-call results that would precede the command
    script_json = _build_script_json(command_name, context_files)
    file_contents = _build_file_contents(command_name, context_files)

    pre_context = (
        "## Pre-loaded execution context\n\n"
        "The setup script and file reads have already been executed. "
        "Use these results directly — do not attempt to run scripts or "
        "read files yourself.\n\n"
        f"### Setup script output\n\n```json\n{script_json}\n```\n\n"
        f"### Loaded files\n\n{file_contents}\n\n"
        "---\n\n"
    )

    # Minimal output instruction — matches how spec-kit expects the LLM
    # to write the output file (step "Write Output" in every command)
    output_instruction = (
        "\n\n---\n\n"
        "Respond with ONLY the output document content (the markdown that "
        "would be written to the output file). Do not include status "
        "messages, completion reports, or code fences around the document."
    )

    return pre_context + body + output_instruction


SYSTEM_INSTRUCTION = (
    "You are a spec-kit extension agent executing a V-Model command. "
    "You have already run the setup script and loaded all required files. "
    "Follow the command's execution steps precisely, using the pre-loaded "
    "context provided. Generate only the output document."
)


def invoke(
    command_name: str,
    context_files: dict[str, str],
    arguments: str = "",
    model: str | None = None,
) -> str:
    """Invoke a spec-kit command via LLM and return the generated document.

    Simulates spec-kit's runtime by:
    1. Loading the actual command prompt from commands/{name}.md
    2. Providing simulated setup-script JSON and pre-loaded file contents
    3. Sending to the LLM with the spec-kit agent system instruction

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
    from google.genai import types

    prompt = render_prompt(command_name, context_files, arguments)

    client = genai.Client()
    response = client.models.generate_content(
        model=model or E2E_MODEL_NAME,
        contents=prompt,
        config=types.GenerateContentConfig(
            system_instruction=SYSTEM_INSTRUCTION,
        ),
    )
    return response.text
