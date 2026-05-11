# Keith-IVt Architecture Notes

This project is a MATLAB `uifigure` desktop app for Keithley 2400 Series SourceMeter measurements. The code is organized so UI layout, UI callback glue, measurement logic, hardware communication, and file I/O can evolve separately.

## Entry Point

- `START_Keith_IVt.m` launches the app.
- `+ui/IVStudioApp.m` is the app coordinator. It should stay thin: initialize app state, build panels, wire callbacks, and coordinate workflows.

## Package Roles

- `+ui` contains UI panels, controller/workflow glue, plotting, theme, logging, and status helpers.
- `+core` contains sweep/time-trace planning, runner orchestration, autosave, metadata, timing estimates, and math.
- `+hardware` contains the Keithley driver, debug simulator, and 2400-series instrument profiles.
- `+data` contains CSV import/export, metadata parsing, presets, recovery/cache table data, and filename helpers.
- `dev_checks` contains non-hardware regression checks.
- `hardware_checks` contains manual checks for a real Keithley connected safely in open-circuit conditions.

## UI Layout Files

- `+ui/ControlsPanel.m`: left navigation, parameter pages, About/Log pages, and fixed action area.
- `+ui/AboutView.m`: styled user-facing About renderer built from `ABOUT.txt`.
- `+ui/PlotPanel.m`: plot tabs, plot toolbar, and axes creation.
- `+ui/DevicesPanel.m`: Devices/Recovery tables and action buttons.
- `+ui/StatusBarPanel.m`: bottom status bar.
- `+ui/Theme.m`: colors, fonts, dark/light theme, and common styling.

## UI Logic Files

- `+ui/AppUiWorkflow.m`: About page actions, font scale, theme switch, update link, export folder chooser, ABOUT text loading.
- `+ui/AdaptiveRuleWorkflow.m`: adaptive rule add/delete/validate logic.
- `+ui/DeviceDataController.m`: device table, selected export, import, recovery import, save all, clear all glue.
- `+ui/ConnectionWorkflow.m`: disconnect, debug mode toggle, output safe-off helpers.
- `+ui/SweepWorkflow.m`: sweep preparation, completed-device creation, sweep status text, debug profile selection.
- `+ui/SweepMetadataWorkflow.m`: measurement metadata context and final autosave metadata handoff.
- `+ui/PlotWorkflow.m` and `+ui/PlotView.m`: plotting, axis labels, range handling, fullscreen windows.
- `+ui/ControlStateManager.m`: enables/disables controls based on connection, debug, busy, data, and mode state.

## Measurement Flow

1. `IVStudioApp.startSweep` checks connection and sets run flags.
2. `ui.SweepWorkflow.prepare` reads UI controls and builds a `core.SweepPlan`.
3. `core.SweepRunner` runs hardware or debug sweep/time trace.
4. Autosave snapshots are written during the run by `core.SweepAutosave`.
5. Completed or aborted data is saved to cache and added to the device list.
6. `ui.PlotWorkflow.refresh` redraws stored data.

## Hardware Flow

- Real instruments use `+hardware/K2400Driver.m`.
- Debug mode uses `+hardware/DebugSMU.m` and debug paths in `core.SweepRunner`.
- Model detection and limits live in `+hardware/InstrumentProfile.m`.
- 2-wire/4-wire, terminal, range, compliance, NPLC, and delay are recorded in metadata.

## Data Flow

- Recovery/current autosave files go to `cache/` with stable latest-file names.
- Selected/all-device export uses `+data/ExportWorkflow.m`.
- CSV reading and metadata compatibility live in `+data/ImportManager.m`, `+data/CsvIO.m`, and `+data/ExportMetadata.m`.
- New visible metadata should use `Operator`; old `Comment` metadata remains import-compatible.

## Development Rules

- Keep `IVStudioApp.m` as coordinator glue only. New behavior should usually go into a small `+ui/*Workflow.m` or `+ui/*Controller.m` file, or into `+core`, `+data`, or `+hardware` if it is not UI-specific.
- Panel files should create controls, assign tags, and connect callbacks, but should avoid business logic.
- Workflow/controller files should avoid creating controls; they should transform app state and return messages/results.
- Hardware code should not depend on UI controls.
- Data code should not depend on UI controls.
- Keep UI text in English.

## Checks

Run these after meaningful changes:

```matlab
addpath('dev_checks'); run_all_checks
```

Use hardware checks only with a real instrument connected and safe open-circuit conditions:

```matlab
addpath('hardware_checks'); run_hardware_checks
```

## First Release Readiness

Current non-hardware regression checks pass with dev_checks/run_all_checks.m. Before a public first release, run the hardware smoke checks on a real instrument in open-circuit, low-current conditions, confirm 2-wire/4-wire metadata, verify packaging with MATLAB Runtime, and replace the placeholder release URL in +core/AppInfo.m.
