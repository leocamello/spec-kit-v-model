---
title: Security Policy
description: How to report security vulnerabilities in the V-Model Extension Pack for Spec Kit — supported versions, reporting process, response timeline, and scope.
---

# Security Policy

The V-Model Extension Pack takes security seriously. This page describes how to report vulnerabilities and what to expect from the process.

## Supported Versions

| Version | Status |
|---------|--------|
| 0.5.x | :material-check-circle:{ .text-green } Supported |
| 0.4.x | :material-check-circle:{ .text-green } Supported |
| 0.3.x | :material-check-circle:{ .text-green } Supported |
| 0.2.x | :material-check-circle:{ .text-green } Supported |
| 0.1.x | :material-check-circle:{ .text-green } Supported |

## Reporting a Vulnerability

!!! danger "Do NOT open a public issue"

    Security vulnerabilities **must** be reported privately. Public disclosure before a fix is available puts all users at risk.

### How to Report

Open a [**private security advisory**](https://github.com/leocamello/spec-kit-v-model/security/advisories/new) on GitHub. Include:

- **Description** of the vulnerability
- **Steps to reproduce** the issue
- **Potential impact** — what could an attacker achieve?
- **Suggested fix** (if you have one)

### What to Expect

| Step | Timeline |
|------|----------|
| **Acknowledgment** of your report | Within 48 hours |
| **Assessment** of severity and impact | Within 1 week |
| **Fix and coordinated disclosure** | Coordinated with you before any public announcement |

We will work with you to understand the issue and coordinate a fix. You will be credited in the security advisory (unless you prefer to remain anonymous).

## Scope

This extension generates Markdown files and runs shell scripts for deterministic parsing. Security concerns within scope include:

!!! warning "In-scope vulnerabilities"

    - **Shell injection** — User-provided arguments passed to helper scripts (e.g., `validate-requirement-coverage.sh`, `impact-analysis.sh`) could be exploited if not properly sanitized
    - **Path traversal** — Script file operations that read or write V-Model artifacts could be manipulated to access files outside the project directory
    - **Sensitive data exposure** — Generated specification documents could inadvertently include sensitive information from the source project

## Out of Scope

The following are **not** considered security vulnerabilities in this project:

- **Vulnerabilities in Spec Kit itself** — Report those to the [Spec Kit repository](https://github.com/github/spec-kit/security)
- **AI agent behavior issues** — Unexpected or incorrect AI-generated content is a prompt engineering concern, not a security vulnerability. See the [Contributing Guide](contributing.md) for how to report these.

## Related Pages

- [Contributing Guide](contributing.md) — How to report bugs and suggest features
- [Code of Conduct](code-of-conduct.md) — Community standards
