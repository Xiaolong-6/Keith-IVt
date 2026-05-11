# Changelog

## 0.3.0 beta - 2026-05-11

Public beta source release.

### Added

- MIT license under Xiaolong Liu.
- Public release README with prerequisites, launch steps, safety notes, hardware checks, and known limitations.
- Packaging notes and public release checklist.
- Release verification record for MATLAB R2025b and Keithley 2401 hardware checks.
- Conservative unknown-resistor hardware characterization script.
- `.gitignore` rules for cache files, archives, backups, and build output.
- GitHub README screenshots.
- Windows Runtime package built with MATLAB Compiler R2025b.

### Verified

- Non-hardware regression checks passed with `dev_checks/run_all_checks.m`.
- Hardware checks passed on Keithley 2401 over `COM3`, `9600` baud, `REAR` terminal.
- 2-wire and 4-wire sense readback checks passed.
- Auto and fixed measure range checks passed.
- Open-circuit sweep and time trace returned finite data.
- Unknown resistor connected to rear terminals measured approximately `148 Mohm`.
- Keithley output was confirmed OFF after hardware testing.
- Compiled Windows executable smoke-tested on the build machine.
- Runtime build verified to open the UI, load About text, and close without the deleted-object wait error.

### Fixed

- Corrected the 4-wire hardware check result-table allocation.
- Adjusted the fixed action area so the Pause/Resume button text is not clipped.
- Runtime deployments now store cache, logs, presets, and default exports under `%APPDATA%/Keith-IVt`.
- Reduced one duplicate full-UI theme pass during startup.
- Runtime entrypoint now guards against a deleted figure handle during shutdown.
- Runtime resource lookup now finds packaged `ABOUT.txt`.
- Windows Runtime executable is built with GUI mode (`mcc -e`) to avoid an extra console window.

### Known Limitations

- Public beta is hardware-verified on Keithley 2401 only.
- MATLAB Runtime startup can take tens of seconds, especially from synced folders or on first launch.
- Instrument profile limits are not yet fully enforced in the UI.
- Users must verify wiring, terminals, sense mode, compliance, and serial settings for their own setup.
