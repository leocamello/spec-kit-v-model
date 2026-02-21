# Integration Test — Minimal Fixture

### Module Integration: ARCH-001 → ARCH-002 (Sensor to Alert)

#### Test Case: ITP-001-A (Sensor Reading Contract)
**Technique**: Interface Contract Testing

* **Integration Scenario: ITS-001-A1**
  * **Given** ARCH-001 produces a SensorReading with value=25.5 and timestamp=2024-01-01T00:00:00Z
  * **When** ARCH-002 receives the SensorReading
  * **Then** ARCH-002 accepts the reading without error

#### Test Case: ITP-001-B (Malformed Sensor Data Rejection)
**Technique**: Interface Fault Injection

* **Integration Scenario: ITS-001-B1**
  * **Given** ARCH-001 produces a SensorReading with value=NaN and timestamp=2024-01-01T00:00:00Z
  * **When** ARCH-002 receives the SensorReading
  * **Then** ARCH-002 rejects with InvalidReadingError and does not generate an alert

### Module Integration: ARCH-002 → ARCH-003 (Alert to Display)

#### Test Case: ITP-002-A (Alert Event Contract)
**Technique**: Interface Contract Testing

* **Integration Scenario: ITS-002-A1**
  * **Given** ARCH-002 produces an AlertEvent with level=WARN and message="High temperature"
  * **When** ARCH-003 receives the AlertEvent
  * **Then** ARCH-003 renders the alert on the display

#### Test Case: ITP-002-B (Alert Timeout Handling)
**Technique**: Interface Fault Injection

* **Integration Scenario: ITS-002-B1**
  * **Given** ARCH-002 does not produce an AlertEvent within 5 seconds
  * **When** ARCH-003 polling interval expires
  * **Then** ARCH-003 displays "No Data" status and logs a timeout warning

### Module Integration: ARCH-001 → ARCH-003 (Sensor Data Flow)

#### Test Case: ITP-003-A (End-to-End Data Flow)
**Technique**: Data Flow Testing

* **Integration Scenario: ITS-003-A1**
  * **Given** raw sensor data is available on the I2C bus
  * **When** the data flows through ARCH-001 → ARCH-002 → ARCH-003
  * **Then** the display shows the correct status derived from the sensor reading

### Cross-Cutting Integration: ARCH-004 (Logger)

#### Test Case: ITP-004-A (Cross-Cutting Log Recording)
**Technique**: Interface Contract Testing

* **Integration Scenario: ITS-004-A1**
  * **Given** ARCH-001 produces a SensorReading with value=25.5
  * **When** the reading is processed by the system
  * **Then** ARCH-004 records a LogEntry with source="SensorDriver" and level=INFO
