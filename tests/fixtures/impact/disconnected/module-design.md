# Module Design — Disconnected Fixture

### Module: MOD-001 (AES Encryptor)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `src/crypto/aes.py`

#### Algorithmic / Logic View

```pseudocode
FUNCTION encrypt(plaintext: bytes, key: bytes) → bytes:
    cipher ← AES(key, mode=CBC)
    RETURN cipher.encrypt(pad(plaintext))
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Description |
|------|------|-------------|
| plaintext | bytes | Input data |
| key | bytes[32] | AES-256 key |

#### Error Handling & Return Codes

| Code | Condition | Recovery |
|------|-----------|----------|
| CryptoError | Invalid key length | Reject with error |

---

### Module: MOD-002 (Report Builder)

**Parent Architecture Modules**: ARCH-002
**Target Source File(s)**: `src/reports/builder.py`

#### Algorithmic / Logic View

```pseudocode
FUNCTION build_report(data: dict, template: string) → bytes:
    html ← render_template(template, data)
    pdf ← convert_to_pdf(html)
    RETURN pdf
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Description |
|------|------|-------------|
| data | dict | Report data |
| template | string | HTML template path |

#### Error Handling & Return Codes

| Code | Condition | Recovery |
|------|-----------|----------|
| RenderError | Template not found | Return error |
