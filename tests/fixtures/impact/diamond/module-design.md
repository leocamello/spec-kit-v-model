# Module Design — Diamond Fixture

### Module: MOD-001 (Header Decoder)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `src/telemetry/decoder.py`

#### Algorithmic / Logic View

```pseudocode
FUNCTION decode(raw: bytes) → ParsedPacket:
    header ← raw[0:8]
    payload ← raw[8:]
    RETURN ParsedPacket(parse_fields(header, payload))
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Description |
|------|------|-------------|
| raw | bytes | Raw telemetry bytes |
| ParsedPacket | struct{fields: dict} | Decoded packet |

#### Error Handling & Return Codes

| Code | Condition | Recovery |
|------|-----------|----------|
| ParseError | Header too short | Return error |

---

### Module: MOD-002 (Field Validator)

**Parent Architecture Modules**: ARCH-002
**Target Source File(s)**: `src/telemetry/validator.py`

#### Algorithmic / Logic View

```pseudocode
FUNCTION validate(packet: ParsedPacket, schema: Schema) → ValidatedPacket:
    FOR field IN schema.required:
        IF field NOT IN packet.fields THEN RETURN Error(SchemaError)
    RETURN ValidatedPacket(packet.fields, valid=True)
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Description |
|------|------|-------------|
| Schema | struct{required: list[string]} | Validation rules |
| ValidatedPacket | struct{fields: dict, valid: bool} | Result |

#### Error Handling & Return Codes

| Code | Condition | Recovery |
|------|-----------|----------|
| SchemaError | Missing required field | Reject packet |

---

### Module: MOD-003 (Disk Flusher)

**Parent Architecture Modules**: ARCH-003
**Target Source File(s)**: `src/storage/flusher.py`

#### Algorithmic / Logic View

```pseudocode
FUNCTION flush(batch: ValidatedPacket[], path: string) → Result:
    data ← serialize(batch)
    write_file(path, data)
    RETURN OK
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Description |
|------|------|-------------|
| batch | list[ValidatedPacket] | Packets to write |

#### Error Handling & Return Codes

| Code | Condition | Recovery |
|------|-----------|----------|
| DiskFullError | No space left | Return error to caller |

---

### Module: MOD-004 (Metric Aggregator) [CROSS-CUTTING]

**Parent Architecture Modules**: ARCH-004
**Target Source File(s)**: `src/metrics/aggregator.py`

#### Algorithmic / Logic View

```pseudocode
FUNCTION record(name: string, value: float) → void:
    counters[name] += value
```

#### State Machine View

N/A — Stateless accumulator

#### Internal Data Structures

| Name | Type | Description |
|------|------|-------------|
| counters | dict[string, float] | Running totals |

#### Error Handling & Return Codes

| Code | Condition | Recovery |
|------|-----------|----------|
| MetricOverflowError | Counter exceeds max | Reset to 0, log warning |
