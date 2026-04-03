# Architecture Design — Disconnected Fixture

## Logical View (Component Breakdown)

Two independent architecture modules — no cross-references.

| ARCH ID | Name | Description | Parent System Components |
|---------|------|-------------|--------------------------|
| ARCH-001 | Crypto Engine | AES-256 encryption module | SYS-001 |
| ARCH-002 | PDF Renderer | Generates PDF reports | SYS-002 |

## Interface View (API Contracts)

### ARCH-001: Crypto Engine
- **Inputs:** Plaintext buffer, encryption key
- **Outputs:** Ciphertext buffer
- **Exceptions:** `CryptoError`

### ARCH-002: PDF Renderer
- **Inputs:** Report data, template
- **Outputs:** PDF byte stream
- **Exceptions:** `RenderError`
