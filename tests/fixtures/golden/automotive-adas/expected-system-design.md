# System Design — Automatic Emergency Braking System (AEB)

## ID Schema

System components use the `SYS-NNN` identifier format (sequential, never renumbered).
Each component traces to one or more parent requirements via the "Parent Requirements" column.

## Decomposition View (IEEE 1016 §5.1)

| SYS ID | Name | Description | Parent Requirements | Type |
|--------|------|-------------|---------------------|------|
| SYS-001 | Radar Processing Unit | Processes 77 GHz FMCW radar returns at 20 Hz; extracts range (0–200 m), velocity (±250 km/h), and azimuth for each detected object | REQ-001, REQ-IF-001 | Module |
| SYS-002 | Camera Processing Unit | Processes stereo camera frames at 15 Hz; performs object classification (vehicle, pedestrian, cyclist) and depth estimation up to 80 m | REQ-001, REQ-IF-001 | Module |
| SYS-003 | Sensor Fusion Engine | Fuses radar tracks and camera detections using extended Kalman filter; computes Time-to-Collision (TTC) for each fused object; filters false positives to maintain <1 per 10,000 km rate | REQ-001, REQ-NF-001 | Module |
| SYS-004 | Braking Controller | Issues forward collision warning at TTC < 2.5 s; commands autonomous full braking at TTC < 1.5 s via brake-by-wire CAN interface; manages deceleration profile (max 10 m/s²) | REQ-002 | Controller |
| SYS-005 | Fault Manager | Monitors all subsystem health via heartbeat; triggers graceful degradation on sensor fault (single-sensor fallback); logs Diagnostic Trouble Codes (DTC) to non-volatile memory | REQ-CN-001 | Service |

## Dependency View (IEEE 1016 §5.2)

| Source | Target | Relationship | Failure Impact |
|--------|--------|-------------|----------------|
| SYS-001 | SYS-003 | SYS-001 provides radar track list (range, velocity, azimuth) to SYS-003 at 20 Hz | Loss of SYS-001 triggers SYS-005 degradation to camera-only mode; detection range reduced to 80 m |
| SYS-002 | SYS-003 | SYS-002 provides classified object list (class, bounding box, depth) to SYS-003 at 15 Hz | Loss of SYS-002 triggers SYS-005 degradation to radar-only mode; no pedestrian classification available |
| SYS-003 | SYS-004 | SYS-003 publishes fused threat list with TTC values to SYS-004 at 20 Hz | Loss of SYS-003 triggers SYS-005 emergency stop; SYS-004 enters safe-state with maximum braking applied |
| SYS-005 | SYS-001 | SYS-005 monitors SYS-001 heartbeat; commands restart or degradation on failure | SYS-005 failure results in last-known-good sensor mode; watchdog timer triggers safe-state after 100 ms |
| SYS-005 | SYS-002 | SYS-005 monitors SYS-002 heartbeat; commands restart or degradation on failure | Same as SYS-001 failure handling |
| SYS-005 | SYS-003 | SYS-005 monitors SYS-003 heartbeat; triggers safe-state on failure | SYS-003 failure triggers immediate safe-state (maximum braking) |
| SYS-005 | SYS-004 | SYS-005 monitors SYS-004 heartbeat; commands mechanical fallback on failure | SYS-004 failure engages hydraulic backup braking circuit |

## Interface View (IEEE 1016 §5.3)

### External Interfaces

| Interface | Protocol | Direction | Data Format | Error Handling |
|-----------|----------|-----------|-------------|----------------|
| 77 GHz Radar Sensor | CAN-FD (2 Mbps) | Inbound | Radar track frame: object ID, range (m), velocity (m/s), azimuth (°), RCS (dBsm) | Message counter + CRC-32 validation; discard and request retransmission on checksum failure |
| Stereo Camera | Automotive Ethernet (100BASE-T1) | Inbound | Compressed frame pair (H.265) + metadata (timestamp, exposure, IMU quaternion) | Sequence number gap detection; flag stale frame to SYS-003 |
| Brake-by-Wire ECU | CAN-FD (2 Mbps) | Outbound | Brake command: deceleration target (m/s²), activation flag, priority level | Dual-channel redundancy; if primary CAN bus fails, fallback to secondary within 10 ms |
| Instrument Cluster | CAN (500 kbps) | Outbound | Warning indicator: collision warning icon, audible chime trigger, distance display | Best-effort delivery; visual warning repeated at 2 Hz until acknowledged or threat cleared |

### Internal Interfaces

| Producer | Consumer | Contract | Latency Budget |
|----------|----------|----------|----------------|
| SYS-001 | SYS-003 | `RadarTrack { object_id: u16, range_m: f32, velocity_ms: f32, azimuth_deg: f32, rcs_dbsm: f32 }` | ≤ 5 ms |
| SYS-002 | SYS-003 | `CameraDetection { class: enum(Vehicle,Pedestrian,Cyclist), bbox: Rect, depth_m: f32, confidence: f32 }` | ≤ 10 ms |
| SYS-003 | SYS-004 | `FusedThreat { object_id: u16, ttc_s: f32, class: enum, confidence: f32, range_m: f32 }` | ≤ 5 ms |
| SYS-005 | ALL | `HealthStatus { component_id: u8, state: enum(OK,Degraded,Failed), timestamp_us: u64 }` | ≤ 1 ms |

## Data Design View (IEEE 1016 §5.4)

| Entity | Storage | Retention | Protection at Rest | Protection in Transit |
|--------|---------|-----------|--------------------|-----------------------|
| Radar Track Log | Cyclic NVRAM buffer (2 MB) | Last 30 seconds (rolling) | Not encrypted (real-time performance constraint) | CAN-FD CRC-32 + message authentication |
| Camera Frame Buffer | DDR4 ring buffer (512 MB) | Last 5 seconds (rolling) | Not encrypted (real-time performance constraint) | Automotive Ethernet MACsec |
| Fused Threat History | NVRAM event log (4 MB) | Last 1,000 braking events | AES-128-CMAC integrity tag | Internal bus — no transit protection required |
| DTC Log | Non-volatile flash (1 MB) | Lifetime of vehicle (read via OBD-II) | AES-128-CMAC integrity tag | UDS over CAN (ISO 14229) |

## Coverage Summary

| Metric | Value |
|--------|-------|
| Total SYS Components | 5 |
| Requirements Covered | 5 / 5 (100%) |
| Uncovered Requirements | — |

## Derived Requirements

| ID | Description | Source Component | Rationale |
|----|-------------|-----------------|-----------|
| REQ-DR-001 | The system SHALL maintain a maximum end-to-end latency of 50 ms from radar frame reception to brake command output | SYS-001, SYS-003, SYS-004 | Architectural constraint: TTC calculation and braking actuation must complete within one radar frame period to meet ASIL-D response time |
| REQ-DR-002 | The system SHALL operate in single-sensor degraded mode (radar-only or camera-only) when one sensor subsystem fails, with automatic DTC logging | SYS-005 | Safety constraint: discovered during dependency analysis; complete AEB shutdown on single sensor failure is unacceptable for ASIL-D |
| REQ-DR-003 | The system SHALL engage hydraulic backup braking within 10 ms when the brake-by-wire primary CAN bus is unavailable | SYS-004, SYS-005 | Safety constraint: brake-by-wire single point of failure requires mechanical fallback path |
