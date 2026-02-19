# Product Specification: Continuous Blood Glucose Monitoring System (CBGMS)

## Product Overview

The Continuous Blood Glucose Monitoring System (CBGMS) is a Class IIb medical device
designed for real-time interstitial glucose monitoring in patients with Type 1 and
Type 2 diabetes. The system consists of a subcutaneous sensor, a wearable transmitter,
and a mobile companion application.

## Key Capabilities

The sensor measures interstitial glucose levels every 5 minutes and transmits readings
via Bluetooth Low Energy (BLE) to the companion mobile app. Users can configure
personal alert thresholds for hypoglycemia (default: 70 mg/dL) and hyperglycemia
(default: 180 mg/dL). The system must support configurable thresholds within the
clinically meaningful range of 55–400 mg/dL.

When glucose values breach configured thresholds, the system triggers audible and
haptic alarms. If the user does not acknowledge a hypoglycemia alarm within 15 minutes,
the alert escalates to an emergency contact via SMS notification.

All glucose readings are stored locally on the transmitter and synced to the companion
app, retaining a minimum 90-day rolling history. Data must be exportable in CSV and
PDF formats for clinical review.

## Connectivity and Interface

The transmitter communicates with the companion app over Bluetooth Low Energy 5.0.
The BLE connection must auto-reconnect within 30 seconds if interrupted. The companion
app supports iOS 15+ and Android 12+ and communicates with a cloud backend via
HTTPS REST APIs for data backup and sharing with healthcare providers.

## Accuracy and Compliance

Clinical accuracy must be within ±15% of a YSI laboratory reference value for glucose
concentrations between 75–400 mg/dL, and within ±15 mg/dL for concentrations below
75 mg/dL, in accordance with ISO 15197:2013 accuracy requirements. The system software
is classified as Class C under IEC 62304, reflecting the potential for serious injury
if the software fails to alert on dangerously low glucose levels.

## Intended Use Environment

Home-use by adult patients (18+) with diabetes, under the guidance of a healthcare
professional. The device operates in ambient temperatures of 10–40°C and relative
humidity of 20–80% (non-condensing).
