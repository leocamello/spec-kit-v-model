# Architecture Design — Linear Fixture

## Logical View (Component Breakdown)

| ARCH ID | Name | Description | Parent System Components |
|---------|------|-------------|--------------------------|
| ARCH-001 | Conversion Engine | Core conversion logic | SYS-001 |
| ARCH-002 | Log Writer | Writes audit entries | SYS-002 |

## Interface View (API Contracts)

### ARCH-001: Conversion Engine
- **Inputs:** Raw data buffer
- **Outputs:** Converted data
- **Exceptions:** `ConversionError`

### ARCH-002: Log Writer
- **Inputs:** Event record
- **Outputs:** Acknowledgment
- **Exceptions:** `LogWriteError`
