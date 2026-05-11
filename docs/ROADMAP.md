# Keith-IVt Roadmap

This file is a fresh-mind direction note. It is intentionally separate from `ABOUT.txt` and `ARCHITECTURE.md`:

- `ABOUT.txt` is user-facing product information.
- `ARCHITECTURE.md` explains the current code structure.
- `ROADMAP.md` records what to improve next and why.

## Current Read

Keith-IVt is now past the "single experimental script" stage. The app has real modules, debug simulation, metadata, recovery, time trace, 2-wire/4-wire metadata, theme support, and non-hardware regression checks.

The next goal should not be adding many more controls. The next goal should be making the project reliable enough that a new maintainer can change one area without accidentally breaking measurement, export, or UI state.

## Short-Term Priorities

1. Stabilize the first beta release.
   - Keep feature scope mostly frozen.
   - Run `dev_checks/run_all_checks.m` before every release candidate.
   - Run `hardware_checks/run_hardware_checks.m` when the Keithley is available.
   - Replace the placeholder release URL in `+core/AppInfo.m`.
   - Add a short README with launch steps, supported MATLAB version, and known limitations.

2. Continue shrinking `+ui/IVStudioApp.m` carefully.
   - Target: under 900 lines next, not under 700 immediately.
   - Move only coherent behavior blocks, not random small callbacks.
   - Best next candidates: run flag handling, close/cleanup, mode-change protection, and preset callback glue.
   - Keep `IVStudioApp.m` as app state + callback coordinator.

3. Make UI code easier to reason about.
   - `ControlsPanel.m` and `Theme.m` are now the largest UI files.
   - Split `ControlsPanel.m` later into smaller builders: navigation, setup page, measure page, action area, export/preset/log/about pages.
   - Keep visual constants in `Theme.m`, but avoid making it a dumping ground for unrelated behavior.

4. Treat hardware verification as a release gate.
   - Open-circuit, low-current tests should confirm connection, IDN/profile detection, range setting, NPLC/delay behavior, 2-wire/4-wire commands, safe output-off, and time trace returns numeric data.
   - Hardware checks should produce clear PASS/FAIL text and avoid risky source levels.

5. Improve packaging and onboarding.
   - Add `README.md` for users.
   - Add `DEVELOPMENT.md` or expand `ARCHITECTURE.md` for maintainers if needed.
   - Document MATLAB Runtime packaging steps once tested.
   - Keep cache/export/config folders predictable.

## Medium-Term Direction

1. Add a constant source / live monitor mode.
   - Let the Keithley act as a stable continuous voltage or current source.
   - Continuously monitor the measured current or voltage while output is enabled.
   - Use an explicit manual Start Source and Stop/Output Off workflow, possibly reusing the existing Start and Stop controls when the mode is selected.
   - Make source-on state visually obvious and safety-critical, with clear status text/lamp behavior while output is active.
   - Record source mode, fixed source value, compliance/limit, terminal, sense mode, range, NPLC, and operator metadata.
   - Treat this as a safety-sensitive feature: require conservative defaults, obvious output-off behavior, and hardware verification before release.

2. Add optional startup update checks.
   - Check the configured GitHub release page for newer versions when the app starts.
   - Make the feature optional so users can disable network checks.
   - Do not block UI startup; run the check asynchronously or after the main window is visible.
   - Fail quietly when offline, behind a proxy, or when GitHub is unavailable.
   - Show a concise non-modal notification if a newer release is available.
   - Keep the existing manual Check Update button.

3. Make instrument profiles actually constrain the UI.
   - Profiles currently record limits, but UI limits are not fully clamped by model.
   - After hardware testing, use detected profile limits to guide source range, compliance, NPLC, and sense-mode warnings.

4. Separate measurement modes more cleanly.
   - Sweep and Time Trace share many fields but have different mental models.
   - Keep one Measure page for now, but internally separate planning, validation, and metadata per measurement type.

5. Make export/import versioned.
   - Add a metadata schema version.
   - Keep backward compatibility with older Comment fields.
   - Make mixed source-mode/sense-mode/range-mode datasets explicit in metadata.

6. Build confidence through tests.
   - Add tests for metadata schema stability.
   - Add tests for range clipping/OVR behavior in debug mode.
   - Add tests for import of old files and corrupted recovery files.

7. Prepare for possible Python migration.
   - Keep core ideas independent: measurement plan, runner, metadata, export/import, instrument profile.
   - Avoid burying business rules inside MATLAB UI callbacks.
   - The cleaner the MATLAB architecture becomes, the easier a future Python port will be.

## What Not To Do Next

- Do not add many new visual features before the first beta is stable.
- Do not chase a perfect modern UI while hardware behavior is still unverified.
- Do not force `IVStudioApp.m` below an arbitrary line count by scattering tiny callbacks everywhere.
- Do not make About a developer document again.
- Do not hide safety-critical settings behind clever UI.

## Suggested Next Session

1. Run the app once visually in Light and Dark themes.
2. Fix any obvious layout regression.
3. Add `README.md`.
4. Move one coherent block out of `IVStudioApp.m`.
5. Re-run `dev_checks/run_all_checks.m`.
6. Stop if checks are green.

## Release Readiness Opinion

The project is close to an internal beta. It is not yet a confident public first release until hardware smoke checks and packaging have been tested. The current best label is:

`Keith-IVt 0.2.0 beta`

A public `0.3.0 beta` would make sense after hardware checks, README, release URL, and packaging notes are complete.
