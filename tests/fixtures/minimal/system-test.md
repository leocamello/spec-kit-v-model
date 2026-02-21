# System Test — Minimal Fixture

### Component Verification: SYS-001 (Data Processor)

#### Test Case: STP-001-A (Valid Data Processing)

**Technique**: Interface Contract Testing

* **System Scenario: STS-001-A1**
  * **Given** the Data Processor receives a valid sensor reading
  * **When** the processing pipeline executes
  * **Then** the Data Processor returns a normalized value within 100ms

#### Test Case: STP-001-B (Invalid Sensor Data Handling)

**Technique**: Fault Injection

* **System Scenario: STS-001-B1**
  * **Given** the Data Processor receives a malformed sensor reading with value=NaN
  * **When** the processing pipeline executes
  * **Then** the Data Processor returns error code INVALID_READING and does not produce output

### Component Verification: SYS-002 (Alert Engine)

#### Test Case: STP-002-A (Alert Generation)

**Technique**: Boundary Value Analysis

* **System Scenario: STS-002-A1**
  * **Given** the sensor value exceeds the threshold of 100 degrees
  * **When** the Alert Engine evaluates the reading
  * **Then** the Alert Engine emits a critical alert event

#### Test Case: STP-002-B (Below-Threshold Suppression)

**Technique**: Boundary Value Analysis

* **System Scenario: STS-002-B1**
  * **Given** the sensor value is exactly at the threshold of 100 degrees
  * **When** the Alert Engine evaluates the reading
  * **Then** the Alert Engine does not emit an alert event

### Component Verification: SYS-003 (Display Renderer)

#### Test Case: STP-003-A (Status Rendering)

**Technique**: Interface Contract Testing

* **System Scenario: STS-003-A1**
  * **Given** the Display Renderer receives a status update payload
  * **When** the render cycle executes
  * **Then** the Display Renderer outputs valid HTML within 200ms
