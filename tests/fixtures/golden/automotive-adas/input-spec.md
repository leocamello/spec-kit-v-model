# Product Specification: Automatic Emergency Braking (AEB) System

## Product Overview

The Automatic Emergency Braking (AEB) system is an ADAS (Advanced Driver Assistance
System) designed for passenger vehicles. It provides forward collision avoidance by
autonomously applying emergency braking when an imminent collision is detected and the
driver fails to respond. The system is developed to ISO 26262 ASIL-D integrity level,
reflecting the highest automotive safety classification.

## Sensor Fusion and Detection

The AEB system employs a multi-sensor architecture combining a 77 GHz long-range radar
and a forward-facing stereo camera. Sensor data is fused in real time to detect and
classify objects in the vehicle's forward path, including other vehicles, pedestrians,
and cyclists. The system must detect vehicles at distances up to 200 meters and
pedestrians at distances up to 80 meters in both daylight and nighttime conditions.

## Braking Activation Logic

When the fused perception pipeline determines that the Time-to-Collision (TTC) with a
detected obstacle falls below 1.5 seconds and the driver has not initiated a braking
or evasive maneuver, the system SHALL autonomously apply maximum braking force. Prior
to autonomous braking, the system SHALL issue a forward collision warning (visual and
audible) at TTC < 2.5 seconds to allow for voluntary driver response.

## False Positive Rate

The system must maintain a false positive activation rate of fewer than 1 autonomous
braking event per 10,000 km of driving under mixed traffic conditions. False activations
erode driver trust and may constitute a safety hazard in themselves (e.g., unexpected
deceleration on a highway).

## Fail-Safe Behavior

If the radar or camera subsystem experiences a fault or degraded performance (e.g., due
to sensor blindness from mud, ice, or hardware failure), the system SHALL degrade
gracefully. Graceful degradation means the AEB function is disabled, a malfunction
indicator is presented to the driver on the instrument cluster, and a diagnostic trouble
code (DTC) is stored. The system must never apply autonomous braking based on data from
a single failed sensor. This fail-safe behavior is mandated by ISO 26262 Part 4 for
ASIL-D systems.

## Target Vehicles and Operating Conditions

The system must operate at ego-vehicle speeds between 5 km/h and 200 km/h. Target
scenarios include rear-end collisions with slower or stationary vehicles and pedestrian
crossings in urban environments.
