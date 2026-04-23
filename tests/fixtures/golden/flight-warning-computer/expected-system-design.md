# System Design — Flight Warning Computer (FWC)

## ID Schema

System components use the `SYS-NNN` identifier format (sequential, never renumbered).
Each component traces to one or more parent requirements via the "Parent Requirements" column.

## Decomposition View (IEEE 1016 §5.1)

| SYS ID | Name | Description | Parent Requirements | Type |
|--------|------|-------------|---------------------|------|
| SYS-001 | Air Data Interface | Receives ARINC 429 serial data from the ADIRU (airspeed, altitude, AoA, attitude) and radio altimeter; validates label freshness (≤ 150 ms age) and NCD flags before forwarding to warning logic | REQ-IF-001, REQ-CN-001 | Hardware Abstraction |
| SYS-002 | Warning Logic Engine | Evaluates validated sensor inputs against configured warning thresholds for all five warning functions (overspeed, stall, altitude alerting, GPWS, attitude limit); produces warning commands | REQ-001, REQ-002, REQ-NF-001 | Module |
| SYS-003 | Output Control | Receives warning commands from the Warning Logic Engine and drives the Audio Management Unit (voice alerts), centralized warning panel (visual annunciators), and stick shaker actuator; guarantees output latency within budget | REQ-001, REQ-002, REQ-NF-001 | Service |

## Dependency View (IEEE 1016 §5.2)

| Source | Target | Relationship | Failure Impact |
|--------|--------|-------------|----------------|
| SYS-001 | SYS-002 | SYS-001 provides validated sensor data frames to SYS-002 for threshold evaluation | Loss of SYS-001 halts all warning functions; SYS-003 annunciates FWC FAIL on the centralized warning panel |
| SYS-002 | SYS-003 | SYS-002 dispatches warning activation commands to SYS-003 for output driving | Loss of SYS-002 results in no warning outputs; SYS-001 BITE detects watchdog timeout and sets FWC FAIL |
| SYS-001 | SYS-003 | SYS-001 provides BITE health status to SYS-003 for maintenance annunciator activation | BITE failure does not affect warning functions; maintenance reporting is degraded |

## Interface View (IEEE 1016 §5.3)

### External Interfaces

| Interface | Protocol | Direction | Data Format | Error Handling |
|-----------|----------|-----------|-------------|----------------|
| ADIRU (Primary + Secondary) | ARINC 429 High Speed (100 kbps) | Inbound | ARINC 429 32-bit words (label, SDI, data, SSM) | Age check ≤ 150 ms; NCD flag triggers sensor fail annunciator |
| Radio Altimeter | ARINC 429 Low Speed (12.5 kbps) | Inbound | Radio altitude in feet (BNR format, label 164) | Range check 0–2500 ft; NCD triggers GPWS inhibit |
| Audio Management Unit | ARINC 429 Low Speed | Outbound | Alert discretes with priority encoding (OVERSPEED > STALL > GPWS > ALT ALERT > ATTITUDE) | AMU watchdog; FWC retransmits on no acknowledgement within 100 ms |
| Centralized Warning Panel | Discrete (28 VDC) | Outbound | Individual annunciator drive lines per warning function | Open-circuit detection via BITE current monitoring |
| Stick Shaker Actuator | Discrete (28 VDC) | Outbound | ON/OFF activation signal | Actuator feedback line monitored for stuck-on/stuck-off detection |
| FMS | ARINC 429 Low Speed | Inbound | Selected altitude, flight phase discrete | Loss of FMS data inhibits altitude alerting; GPWS uses radio altimeter only |

### Internal Interfaces

| Producer | Consumer | Contract | Latency Budget |
|----------|----------|----------|----------------|
| SYS-001 | SYS-002 | `ValidatedFrame { label: u8, value: f32, sdi: u2, age_ms: u16, ncd: bool }` | ≤ 10 ms per ARINC 429 cycle |
| SYS-002 | SYS-003 | `WarningCommand { function: enum, state: Active\|Inactive, priority: u8 }` | ≤ 5 ms |

## Data Design View (IEEE 1016 §5.4)

| Entity | Storage | Retention | Protection at Rest | Protection in Transit |
|--------|---------|-----------|--------------------|-----------------------|
| ARINC 429 Input Frame | Volatile RAM ring buffer (64 frames per channel) | 1 ARINC cycle (10 ms) | ECC RAM on DAL-A processor | ARINC 429 SSM field; CRC-32 over internal bus |
| Warning State | Non-volatile EEPROM (256 bytes) | Preserved across power cycles | Write-protect hardware pin | Internal bus parity check |
| BITE Fault Log | Non-volatile EEPROM (4 KB) | 100 flight hours rolling | ECC EEPROM | Internal bus parity check |
| Calibration Data | OTP (One-Time Programmable) ROM | Permanent | Hardware lock bit | Read-back verification at startup |

## Operational States

| State | Description |
|-------|------------|
| POWER_ON_SELF_TEST | BITE self-test sequence on power application; all outputs inhibited until test completes |
| MONITORING | Normal inflight warning monitoring; all five warning functions active with valid sensor data |
| DEGRADED | One or more sensor inputs invalid (NCD or stale); affected warning functions inhibited, maintenance annunciators active |
| MAINTENANCE | Ground maintenance mode; BITE fault log accessible; outputs inhibited |

## Quality Attribute Coverage (ISO/IEC 25010:2023)

| Quality Characteristic | System Components Addressing It | Design Decision |
|------------------------|--------------------------------|-----------------|
| Reliability | SYS-001, SYS-002 | Dual-channel ARINC 429 inputs with cross-comparison; watchdog timer on Warning Logic Engine |
| Performance Efficiency | SYS-001, SYS-002, SYS-003 | ARINC 429 interrupt-driven processing; dedicated output driver task at highest priority |
| Safety | SYS-002, SYS-003 | DO-178C DAL-A MC/DC coverage; fail-safe output drivers (alarm ON is default state) |
| Maintainability | SYS-001 | BITE fault log with flight-hour-stamped entries accessible via maintenance port |

## Coverage Summary

| Metric | Value |
|--------|-------|
| Total SYS Components | 3 |
| Requirements Covered | 5 / 5 (100%) |
| Uncovered Requirements | — |

## Derived Requirements

| ID | Description | Source Component | Rationale |
|----|-------------|-----------------|-----------|
| REQ-DR-001 | The FWC SHALL complete the Power-On Self-Test within 5 seconds and SHALL inhibit all warning outputs during self-test | SYS-001, SYS-003 | Architectural constraint: spurious warnings during self-test are hazardous; BITE completion time derived from ARINC 429 channel scan latency |
| REQ-DR-002 | The FWC SHALL implement a watchdog timer with a 20 ms timeout on the Warning Logic Engine; expiry SHALL set the FWC FAIL annunciator | SYS-002 | Safety constraint: undetected software failure in DAL-A logic must not silently suppress warnings |

## Governing Standards

| Standard | Full Name | Role in this Document |
|----------|-----------|----------------------|
| **IEEE 1016:2009** | IEEE Standard for Information Technology — Software Design Descriptions | Primary structure standard: four mandatory design views |
| **ISO/IEC 25010:2023** | Systems and Software Quality Models | Quality attribute taxonomy applied in Quality Attribute Coverage section |
| **DO-178C** | Software Considerations in Airborne Systems and Equipment Certification | DAL-A design constraints; fail-safe and watchdog requirements |
