# Keith-IVt Release Verification - 2026-05-11

This record captures the release-gate checks run for the public beta track.

## Environment

- Date: 2026-05-11
- MATLAB host: Windows
- Serial port: `COM3`
- Baud rate: `9600`
- Terminal setting: `REAR`
- Instrument ID: `KEITHLEY INSTRUMENTS INC.,MODEL 2401,4612952,B02 Jan 20 2021 10:19:49/B01  /W/N`
- Detected profile: `Keithley 2401`

## Hardware Checks

Command:

```matlab
addpath('hardware_checks');
results = run_hardware_checks('COM3', 9600, 'REAR');
```

Result: passed.

Coverage observed:

- Connection and instrument profile detection passed.
- 2-wire remote-sense readback returned `RSEN=0`.
- 4-wire remote-sense readback returned `RSEN=1`.
- Return to 2-wire remote-sense readback returned `RSEN=0`.
- Auto measure range readback passed.
- Fixed measure range readback passed.
- Open-circuit sweep returned `3/3` finite readings.
- Time trace returned `3/3` finite readings.
- Hardware check runner completed with `All hardware checks completed.`

Representative open-circuit current readings at 0 V:

- 2-wire: `4.61374e-09 A`
- 4-wire: `2.20428e-09 A`
- 2-wire after reset: `-6.99674e-09 A`

## Non-Hardware Checks

Command:

```matlab
addpath('dev_checks');
run_all_checks
```

Result: passed.

The check runner printed `All dev checks passed.`

## Unknown Resistor Hardware Characterization

An unknown resistor was connected on the rear terminals and measured with conservative voltage-source settings.

Script:

```matlab
addpath('hardware_checks');
result = characterize_unknown_resistor('COM3',9600,'REAR');
```

Initial safe sweep:

- Voltage points: `[-0.1 -0.05 -0.01 0.01 0.05 0.1] V`
- Current compliance: `1e-6 A`
- Fitted resistance: approximately `148.96 Mohm`
- Maximum absolute power: approximately `7.05e-11 W`

Higher-signal sweep:

- Voltage points: `[-1 -0.5 -0.1 0.1 0.5 1] V`
- Current compliance: `1e-7 A`
- Fitted resistance: approximately `147.98 Mohm`
- Maximum absolute power: approximately `6.78e-9 W`

Stability check:

- Voltage: `1 V`
- Repeated readings: `10/10` finite
- Mean current: approximately `6.751e-9 A`
- Current standard deviation: approximately `3.85e-12 A`
- Mean resistance: approximately `148.12 Mohm`
- Resistance standard deviation: approximately `0.084 Mohm`
- Output state after the test was queried as `0` (OFF).

## Fix Applied During Verification

`hardware_checks/verify_4wire_sense_mode.m` had a result-table preallocation mismatch: the table stored 7 columns, but the intermediate `rows` cell array was allocated with 6 columns. The preallocation was corrected to 7 columns, then the full hardware check suite passed.

Added `hardware_checks/characterize_unknown_resistor.m` for conservative unknown-resistor characterization using low voltage and current compliance.

## Remaining Release Items

- Replace the placeholder release URL in `+core/AppInfo.m`.
- Complete the manual Light/Dark UI smoke test.
- Package from a clean source folder and validate the package.
