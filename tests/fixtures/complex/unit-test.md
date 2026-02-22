# Unit Test Plan — Complex Fixture

### Module: MOD-001 (MQTT Parser)

**Parent Architecture Modules**: ARCH-001 (MQTT Receiver)
**Target Source File(s)**: `src/mqtt/parser.py`

#### Test Case: UTP-001-A (Parse Valid & Invalid Messages)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic
**Description**: Exercise all branches in `parse()` including empty-payload path.

**Dependency & Mock Registry:**

| Dependency | Mock/Stub | Reason |
|------------|-----------|--------|
| None | — | Module is self-contained |

* **Unit Scenario: UTS-001-A1**
  * **Arrange**: Construct raw_bytes with valid 4-byte header, topic "sensor/temp", and 20-byte payload.
  * **Act**: Call `parse(raw_bytes)`.
  * **Assert**: Returned `MQTTMessage.topic == "sensor/temp"` and `payload` length is 20.

* **Unit Scenario: UTS-001-A2**
  * **Arrange**: Construct raw_bytes with valid header but zero-length payload.
  * **Act**: Call `parse(raw_bytes)`.
  * **Assert**: `EmptyPayloadError` is raised.

#### Test Case: UTP-001-B (Header Isolation)

**Technique**: Strict Isolation
**Target View**: Algorithmic/Logic
**Description**: Verify header decoding in isolation from payload processing.

**Dependency & Mock Registry:**

| Dependency | Mock/Stub | Reason |
|------------|-----------|--------|
| None | — | Module is self-contained |

* **Unit Scenario: UTS-001-B1**
  * **Arrange**: Provide raw_bytes with `topic_len=5`, `qos=1`, `retain=True`.
  * **Act**: Call `parse(raw_bytes)`.
  * **Assert**: `MQTTMessage.qos == 1`.

* **Unit Scenario: UTS-001-B2**
  * **Arrange**: Provide truncated raw_bytes (2 bytes only).
  * **Act**: Call `parse(raw_bytes)`.
  * **Assert**: `HeaderDecodeError` is raised.

---

### Module: MOD-002 (Checksum Verifier)

**Parent Architecture Modules**: ARCH-002 (Data Validator)
**Target Source File(s)**: `src/validation/checksum.py`

#### Test Case: UTP-002-A (Verify Match & Mismatch)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic
**Description**: Cover both matching and non-matching checksum branches.

**Dependency & Mock Registry:**

| Dependency | Mock/Stub | Reason |
|------------|-----------|--------|
| None | — | Module is self-contained |

* **Unit Scenario: UTS-002-A1**
  * **Arrange**: `payload = b"hello"`, `expected = sha256(b"hello").hex()`.
  * **Act**: Call `verify(payload, expected)`.
  * **Assert**: Returns `True`.

* **Unit Scenario: UTS-002-A2**
  * **Arrange**: `payload = b"hello"`, `expected = "a" * 64`.
  * **Act**: Call `verify(payload, expected)`.
  * **Assert**: `ChecksumMismatchError` is raised.

#### Test Case: UTP-002-B (Checksum Length Boundaries)

**Technique**: Boundary Value Analysis
**Target View**: Algorithmic/Logic
**Description**: Test checksum length at and around the required 64-character boundary.

**Dependency & Mock Registry:**

| Dependency | Mock/Stub | Reason |
|------------|-----------|--------|
| None | — | Module is self-contained |

* **Unit Scenario: UTS-002-B1**
  * **Arrange**: `expected` string of length 0 (empty).
  * **Act**: Call `verify(b"data", expected)`.
  * **Assert**: `InvalidChecksumLengthError` is raised.

* **Unit Scenario: UTS-002-B2**
  * **Arrange**: `expected` string of length 63.
  * **Act**: Call `verify(b"data", expected)`.
  * **Assert**: `InvalidChecksumLengthError` is raised.

* **Unit Scenario: UTS-002-B3**
  * **Arrange**: `expected` = valid 64-char hex matching `sha256(b"data")`.
  * **Act**: Call `verify(b"data", expected)`.
  * **Assert**: Returns `True`.

* **Unit Scenario: UTS-002-B4**
  * **Arrange**: `expected` string of length 65.
  * **Act**: Call `verify(b"data", expected)`.
  * **Assert**: `InvalidChecksumLengthError` is raised.

* **Unit Scenario: UTS-002-B5**
  * **Arrange**: `expected` string of length 128.
  * **Act**: Call `verify(b"data", expected)`.
  * **Assert**: `InvalidChecksumLengthError` is raised.

---

### Module: MOD-003 (Sliding Window)

**Parent Architecture Modules**: ARCH-003 (Stream Aggregator)
**Target Source File(s)**: `src/aggregation/window.py`

#### Test Case: UTP-003-A (State Transitions)

**Technique**: State Transition Testing
**Target View**: State Machine
**Description**: Walk the stateDiagram-v2 path Empty→Filling→Full→Flushing→Empty.

**Dependency & Mock Registry:**

| Dependency | Mock/Stub | Reason |
|------------|-----------|--------|
| None | — | Module is self-contained |

* **Unit Scenario: UTS-003-A1**
  * **Arrange**: Create `SlidingWindow(max_size=3)`. State is Empty.
  * **Act**: Call `add(reading)` once.
  * **Assert**: State transitions to Filling; `add` returns `None`.

* **Unit Scenario: UTS-003-A2**
  * **Arrange**: Window in Filling state with 2 readings, `max_size=3`.
  * **Act**: Call `add(reading)` (3rd reading).
  * **Assert**: State transitions to Full; `add` returns an `AggregatedBatch`.

* **Unit Scenario: UTS-003-A3**
  * **Arrange**: Window just flushed.
  * **Act**: Inspect buffer.
  * **Assert**: State is Empty; buffer length is 0.

#### Test Case: UTP-003-B (Window Size Boundaries)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Test window behavior at size boundaries 0, 1, and max_size.

**Dependency & Mock Registry:**

| Dependency | Mock/Stub | Reason |
|------------|-----------|--------|
| None | — | Module is self-contained |

* **Unit Scenario: UTS-003-B1**
  * **Arrange**: `SlidingWindow(max_size=1)`.
  * **Act**: Call `add(reading)`.
  * **Assert**: Immediately returns `AggregatedBatch` with count=1.

* **Unit Scenario: UTS-003-B2**
  * **Arrange**: Empty window.
  * **Act**: Call `flush()` (force flush on empty).
  * **Assert**: `EmptyWindowError` is raised.

* **Unit Scenario: UTS-003-B3**
  * **Arrange**: Window with `max_size=1000`, add 2000 readings without consuming.
  * **Act**: Observe behavior.
  * **Assert**: `WindowOverflowError` is raised at 2× capacity.

---

### Module: MOD-004 (WAL Writer)

**Parent Architecture Modules**: ARCH-004 (Storage Writer)
**Target Source File(s)**: `src/storage/wal.py`

#### Test Case: UTP-004-A (WAL State Transitions)

**Technique**: State Transition Testing
**Target View**: State Machine
**Description**: Walk Idle→Writing→Syncing→Idle and Idle→Writing→Idle paths.

**Dependency & Mock Registry:**

| Dependency | Mock/Stub | Reason |
|------------|-----------|--------|
| `filesystem` | Stub `fsync`, `rename` | Isolate from disk I/O |

* **Unit Scenario: UTS-004-A1**
  * **Arrange**: WAL in Idle state, `sync_threshold=100`, file size at 99.
  * **Act**: Call `write(record)` (pushes size to 100).
  * **Assert**: `fsync` is called; state returns to Idle via Syncing.

* **Unit Scenario: UTS-004-A2**
  * **Arrange**: WAL in Idle state, `sync_threshold=100`, file size at 0.
  * **Act**: Call `write(record)` (size stays below threshold).
  * **Assert**: `fsync` is NOT called; state returns to Idle directly.

#### Test Case: UTP-004-B (Write & Error Branches)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic
**Description**: Cover successful write and disk-full error paths.

**Dependency & Mock Registry:**

| Dependency | Mock/Stub | Reason |
|------------|-----------|--------|
| `filesystem` | Stub `append` to raise `OSError` | Simulate disk full |

* **Unit Scenario: UTS-004-B1**
  * **Arrange**: Valid record, sufficient disk space (stubbed).
  * **Act**: Call `write(record)`.
  * **Assert**: Returns `WriteReceipt` with correct `record_id`.

* **Unit Scenario: UTS-004-B2**
  * **Arrange**: Stub filesystem `append` to raise `OSError`.
  * **Act**: Call `write(record)`.
  * **Assert**: `DiskFullError` is raised.

---

### Module: MOD-005 (SQL Parser)

**Parent Architecture Modules**: ARCH-005 (Query Engine)
**Target Source File(s)**: `src/query/parser.py`

#### Test Case: UTP-005-A (Parse Valid & Invalid Queries)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic
**Description**: Cover successful parse and invalid-filter error branch.

**Dependency & Mock Registry:**

| Dependency | Mock/Stub | Reason |
|------------|-----------|--------|
| None | — | Module is self-contained |

* **Unit Scenario: UTS-005-A1**
  * **Arrange**: `query_string = "SELECT * WHERE ts > '2024-01-01'"`.
  * **Act**: Call `parse(query_string)`.
  * **Assert**: Returns `QueryPlan` with valid AST.

* **Unit Scenario: UTS-005-A2**
  * **Arrange**: `query_string = "SELECT * WHERE ts ~~~ invalid"`.
  * **Act**: Call `parse(query_string)`.
  * **Assert**: `InvalidFilterError` is raised.

#### Test Case: UTP-005-B (Query Partitions)

**Technique**: Equivalence Partitioning
**Target View**: Algorithmic/Logic
**Description**: Partition inputs into simple filter, compound filter, and empty query classes.

**Dependency & Mock Registry:**

| Dependency | Mock/Stub | Reason |
|------------|-----------|--------|
| None | — | Module is self-contained |

* **Unit Scenario: UTS-005-B1**
  * **Arrange**: Simple equality filter `"SELECT * WHERE id = 42"`.
  * **Act**: Call `parse(query_string)`.
  * **Assert**: AST root is `EqualityNode`.

* **Unit Scenario: UTS-005-B2**
  * **Arrange**: Compound filter `"SELECT * WHERE id = 42 AND ts > '2024-01-01'"`.
  * **Act**: Call `parse(query_string)`.
  * **Assert**: AST root is `AndNode` with two children.

* **Unit Scenario: UTS-005-B3**
  * **Arrange**: Empty string `""`.
  * **Act**: Call `parse(query_string)`.
  * **Assert**: `InvalidFilterError` is raised.

---

### Module: MOD-006 (Prometheus Formatter)

**Parent Architecture Modules**: ARCH-006 (Metrics Exporter)
**Target Source File(s)**: `src/metrics/formatter.py`

#### Test Case: UTP-006-A (Format Output Branches)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic
**Description**: Cover single-metric and multi-sample branches.

**Dependency & Mock Registry:**

| Dependency | Mock/Stub | Reason |
|------------|-----------|--------|
| None | — | Module is self-contained |

* **Unit Scenario: UTS-006-A1**
  * **Arrange**: One `MetricFamily` with name="http_requests", type="counter", one sample.
  * **Act**: Call `format(metrics)`.
  * **Assert**: Output contains `# TYPE http_requests counter` and one sample line.

* **Unit Scenario: UTS-006-A2**
  * **Arrange**: One `MetricFamily` with 3 samples having different label sets.
  * **Act**: Call `format(metrics)`.
  * **Assert**: Output contains exactly 3 sample lines plus HELP/TYPE headers.

---

### Module: MOD-007 (AES-256 Wrapper) [EXTERNAL]

> Module MOD-007 is [EXTERNAL] — wrapper behavior tested at integration level.

---

### Module: MOD-008 (Log Rotator) [CROSS-CUTTING]

**Parent Architecture Modules**: ARCH-008 (Logger) [CROSS-CUTTING]
**Target Source File(s)**: `src/logging/rotator.py`

#### Test Case: UTP-008-A (Rotation Partitions)

**Technique**: Equivalence Partitioning
**Target View**: Algorithmic/Logic
**Description**: Partition into under-limit (no rotation) and over-limit (rotation triggered) classes.

**Dependency & Mock Registry:**

| Dependency | Mock/Stub | Reason |
|------------|-----------|--------|
| `filesystem` | Stub `rename`, `compress` | Isolate from disk I/O |

* **Unit Scenario: UTS-008-A1**
  * **Arrange**: `log_file.size = 500`, `max_bytes = 1000`.
  * **Act**: Call `rotate_if_needed(log_file)`.
  * **Assert**: Returns same `log_file`; no rotation occurs.

* **Unit Scenario: UTS-008-A2**
  * **Arrange**: `log_file.size = 1000`, `max_bytes = 1000`.
  * **Act**: Call `rotate_if_needed(log_file)`.
  * **Assert**: `rename` and `compress` are called; returns new log file handle.

---

## Coverage Summary

| Metric | Value |
|--------|-------|
| Total MODs | 8 |
| MODs tested | 7 |
| MODs bypassed | 1 (MOD-007 [EXTERNAL]) |
| Total UTPs | 13 |
| Total UTSs | 30 |

### Technique Distribution

| Technique | UTP Count |
|-----------|-----------|
| Statement & Branch Coverage | 5 |
| Boundary Value Analysis | 2 |
| State Transition Testing | 2 |
| Equivalence Partitioning | 2 |
| Strict Isolation | 1 |
| **Total** | **13** |
