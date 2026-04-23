# Product Specification: Flight Warning Computer (FWC)

## Product Overview

The Flight Warning Computer (FWC) is a safety-critical avionics system designed for
commercial transport category aircraft. It monitors flight parameters in real time and
generates timely audio, visual, and tactile warnings to the flight crew when the
aircraft approaches or exceeds safe operational limits. The system is developed to
DO-178C Design Assurance Level A (DAL-A), the highest software assurance level,
reflecting the catastrophic consequence class if the FWC fails to generate a required
warning.

## Warning Functions

The FWC implements five primary warning functions. The **overspeed warning** monitors
airspeed from the Air Data Inertial Reference Unit (ADIRU) and triggers an audible
voice alert ("OVERSPEED, OVERSPEED") and visual annunciator when airspeed exceeds
the aircraft's Maximum Operating Speed (VMO/MMO). The **stall warning** monitors
angle of attack (AoA) from the ADIRU and activates the stick shaker actuator when
AoA reaches the stall warning threshold (typically 1.2 Vs), providing a tactile
warning to the pilot.

The **altitude alerting** function monitors barometric altitude and radio altimeter
data to generate approach-to-selected-altitude and altitude deviation alerts. The
**Ground Proximity Warning System (GPWS)** function uses radio altimeter terrain
clearance data to generate proximity alerts for approach to terrain with gear or
flaps not configured. The **attitude limit warning** monitors bank angle and pitch
attitude from the ADIRU and generates a "BANK ANGLE" or "PITCH" voice call when
attitude limits are exceeded.

## System Interfaces

The FWC receives data via ARINC 429 serial bus from the ADIRU (airspeed, altitude,
angle of attack, attitude), the radio altimeter (terrain clearance height), and the
Flight Management System (FMS) (selected altitude, flight phase). Outputs are sent
to the Audio Management Unit (AMU) for voice alerts, the centralized warning panel
for visual annunciators, and the stick shaker actuator control unit for stall
prevention. A Built-In Test Equipment (BITE) interface provides fault isolation and
maintenance reporting.

## Safety Requirements

All warning generation logic is classified DAL-A under DO-178C. Software structural
coverage requirements include Modified Condition/Decision Coverage (MC/DC) for all
DAL-A code. A Software Quality Assurance Plan (SQAP) is required, and independent
Software Verification and Validation (V&V) is mandated for all DAL-A software items.
The system must meet a probability of undetected loss of warning function better than
1×10⁻⁹ per flight hour, consistent with catastrophic failure condition classification
under ARP4761A.

## Operating Envelope

The FWC operates continuously from engine start to engine shutdown. It must function
correctly from sea level to 51,000 feet pressure altitude, at airspeeds from 60 kt to
VMO/MMO, and across temperature ranges from −55°C to +70°C. All ARINC 429 inputs are
validated for freshness (label age check) and No Computed Data (NCD) flags before use
in warning logic.
