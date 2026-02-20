# System Test — Minimal Fixture

### Component Verification: SYS-001 (Data Processor)

#### Test Case: STP-001-A (Valid Data Processing)

**Technique**: Interface Contract Testing

* **System Scenario: STS-001-A1**
  * **Given** the Data Processor receives a valid sensor reading
  * **When** the processing pipeline executes
  * **Then** the Data Processor returns a normalized value within 100ms

### Component Verification: SYS-002 (Alert Engine)

#### Test Case: STP-002-A (Alert Generation)

**Technique**: Boundary Value Analysis

* **System Scenario: STS-002-A1**
  * **Given** the sensor value exceeds the threshold of 100 degrees
  * **When** the Alert Engine evaluates the reading
  * **Then** the Alert Engine emits a critical alert event

### Component Verification: SYS-003 (Display Renderer)

#### Test Case: STP-003-A (Status Rendering)

**Technique**: Interface Contract Testing

* **System Scenario: STS-003-A1**
  * **Given** the Display Renderer receives a status update payload
  * **When** the render cycle executes
  * **Then** the Display Renderer outputs valid HTML within 200ms
