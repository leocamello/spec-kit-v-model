# Security Policy

## Supported Versions

| Version | Supported          |
|---------|--------------------|
| 0.4.x   | :white_check_mark: |
| 0.3.x   | :white_check_mark: |
| 0.2.x   | :white_check_mark: |
| 0.1.x   | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability in the V-Model Extension Pack, please report it responsibly.

### How to Report

1. **Do NOT open a public issue.** Security vulnerabilities must be reported privately.
2. **Email**: Open a [private security advisory](https://github.com/leocamello/spec-kit-v-model/security/advisories/new) on GitHub.
3. **Include**:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### What to Expect

- **Acknowledgment** within 48 hours of your report.
- **Assessment** of severity and impact within 1 week.
- **Fix and disclosure** coordinated with you before any public announcement.

### Scope

This extension generates markdown files and runs shell scripts for deterministic parsing. Security concerns may include:

- **Shell injection** via user-provided arguments passed to helper scripts
- **Path traversal** in script file operations
- **Sensitive data exposure** in generated specification documents

### Out of Scope

- Vulnerabilities in [Spec Kit](https://github.com/github/spec-kit) itself (report those upstream)
- Issues with the AI agent's behavior (these are prompt engineering concerns, not security vulnerabilities)
