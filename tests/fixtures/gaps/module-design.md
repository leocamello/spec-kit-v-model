# Module Design — Gaps Fixture

### Module: MOD-001 (Password Hasher)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `src/auth/hasher.py`

#### Algorithmic / Logic View

```pseudocode
FUNCTION hash_password(plain: string) -> string:
    salt = generate_random_bytes(16)
    RETURN base64_encode(salt + pbkdf2_hmac("sha256", plain, salt, 100000))

FUNCTION verify_password(plain: string, stored: string) -> bool:
    decoded = base64_decode(stored)
    actual = pbkdf2_hmac("sha256", plain, decoded[0:16], 100000)
    RETURN constant_time_compare(actual, decoded[16:])
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| salt | bytes | 16 bytes | random | Cryptographic salt |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Empty password | ValueError | ARCH-001 Interface | Raise immediately |

### Module: MOD-002 (Token Generator)

**Parent Architecture Modules**: ARCH-002
**Target Source File(s)**: `src/auth/token.py`

#### Algorithmic / Logic View

```pseudocode
FUNCTION generate_token(user_id: string, ttl: int) -> string:
    RETURN jwt_encode({"sub": user_id, "exp": now() + ttl}, SECRET_KEY, "HS256")
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| ttl | int | 1-86400 | 3600 | Token time-to-live in seconds |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Missing user_id | ValueError | ARCH-002 Interface | Raise immediately |

### Module: MOD-099 (Orphan Module)

**Parent Architecture Modules**: ARCH-099
**Target Source File(s)**: `src/orphan.py`

#### Algorithmic / Logic View

```pseudocode
FUNCTION orphan_op(data: string) -> string:
    RETURN data.upper()
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| data | string | max 256 chars | empty | Input data |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Empty input | ValueError | ARCH-099 Interface | Raise immediately |

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Module Designs (MOD) | 3 |
| External Modules (`[EXTERNAL]`) | 0 |
| Stateful Modules | 0 |
| Stateless Modules | 3 |
| **Forward Coverage (ARCH→MOD)** | **100%** |
