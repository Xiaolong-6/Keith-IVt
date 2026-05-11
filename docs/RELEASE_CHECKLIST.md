# Keith-IVt Public Release Checklist

Use this checklist for every public release candidate.

## Release Target

- Current target: `0.3.0 beta`
- Current internal version: `0.3.0 beta`
- Release type: public beta after hardware and packaging verification

## Before Tagging

- Confirm the version in `+core/AppInfo.m`.
- Confirm the release URL in `+core/AppInfo.m` points to the active GitHub releases page.
- Confirm `README.md` launch instructions on a clean MATLAB session.
- Confirm `ABOUT.txt` matches the release behavior.
- Confirm `docs/ARCHITECTURE.md` still matches the code layout.
- Confirm `docs/ROADMAP.md` separates post-release ideas from release blockers.
- Confirm `LICENSE` still matches the intended release terms.

## Non-Hardware Checks

Run from the project folder:

```matlab
addpath('dev_checks');
run_all_checks
```

Required result:

```text
All dev checks passed.
```

## Hardware Gate

Run only with a Keithley connected in safe open-circuit, low-current conditions:

```matlab
addpath('hardware_checks');
results = run_hardware_checks("COM3", 9600, "REAR");
```

Adjust the COM port, baud rate, and terminal for the lab setup.

Required coverage:

- Connection and `*IDN?` profile detection.
- Front/rear terminal selection.
- 2-wire and 4-wire sense commands.
- Measurement range configuration.
- Safe output-off after each check.
- Open-circuit sweep returns numeric data without unsafe levels.
- Time trace returns numeric elapsed-time data.

Save the MATLAB command-window output with the release notes.

## Manual UI Smoke Test

- Launch with `START_Keith_IVt`.
- Open Light theme and Dark theme.
- Confirm setup controls are readable at default font size.
- Confirm Measure controls remain usable with the fixed action area visible.
- Confirm Debug Device can run a short Sweep.
- Confirm Debug Device can run a short Time Trace.
- Confirm Pause, Resume, Stop, and Output Off update state correctly.
- Confirm Devices table, plot refresh, selected export, and recovery import still work.

## Packaging

- Follow `docs/PACKAGING.md`.
- Build from a clean folder or clean checkout.
- Exclude `cache/`, `archive/`, generated exports, backups, and local test data.
- Confirm the packaged app launches on a machine without local path assumptions.
- Confirm known MATLAB Runtime limitations are documented.

## Release Notes

Include:

- Supported MATLAB version used for testing.
- Supported Keithley models listed in the app profile table.
- Hardware check instrument model and firmware from `*IDN?`.
- Known limitations.
- Safety note reminding users to verify wiring, terminals, sense mode, and compliance.

## Stop The Release If

- Any dev check fails.
- Any hardware check fails or leaves output on.
- App launch depends on local absolute paths.
- Export/import breaks existing CSV compatibility.
- Metadata omits source mode, sense mode, terminal, operator, or timing fields.
- The release URL is still unresolved.
