# Keith-IVt

Keith-IVt is a MATLAB desktop app for Keithley 2400 Series SourceMeter measurements. It supports source sweeps, time traces, live and stored plotting, CSV import/export, autosave recovery, presets, and an offline debug mode for data exploration without an attached instrument.

The current release target is `0.3.0 beta`.

Repository: <https://github.com/Xiaolong-6/Keith-IVt>

Release page: <https://github.com/Xiaolong-6/Keith-IVt/releases>

## Screenshots

Setup and live plot area:

![Keith-IVt setup screen](docs/screenshots/keith-ivt-setup.png)

Measurement controls:

![Keith-IVt measure screen](docs/screenshots/keith-ivt-measure.png)

About and settings page:

![Keith-IVt about screen](docs/screenshots/keith-ivt-about.png)

## License

Keith-IVt is released under the MIT License. See `LICENSE`.

## Documentation

- [Architecture notes](docs/ARCHITECTURE.md)
- [Roadmap](docs/ROADMAP.md)
- [Packaging notes](docs/PACKAGING.md)
- [Release checklist](docs/RELEASE_CHECKLIST.md)
- [Release verification record](docs/RELEASE_VERIFICATION_2026-05-11.md)

## Getting Started

### From Source (MATLAB Required)

Prerequisites:

- MATLAB with `uifigure`, `serialport`, and `serialportlist` support.
- Tested with MATLAB R2025b on Windows.

Launch:

```matlab
START_Keith_IVt
```

The launcher creates the app from `+ui/IVStudioApp.m`.

### From Windows Runtime Package

Prerequisites:

- Free MATLAB Runtime R2025b (25.2) for Windows. Download from [MathWorks](https://www.mathworks.com/products/compiler/mcr/).

Download and Launch:

1. Download `Keith-IVt-v0.3.0-beta-runtime-win-gui.zip` from the [Release page](https://github.com/Xiaolong-6/Keith-IVt/releases).
2. Unzip the package.
3. Run `Keith_IVt.exe`.
4. On first launch, Windows may need to download and install MATLAB Runtime R2025b (one-time setup, a few minutes).
5. The app will open after MATLAB Runtime initializes (which can take tens of seconds on first launch).

## Debug Mode

Debug mode lets you explore the app without hardware:

- **No Keithley meter required** — no serial connection needed.
- **Import and analyze existing measurement data** — load CSV files from previous measurements.
- **Create synthetic test data** — verify UI behavior and measurement workflows.

To activate:

1. Open the About page.
2. Enable **Debug Device**.
3. Choose connection settings on the Setup page (these are ignored in debug mode).
4. Configure Sweep or Time Trace measurement settings.
5. Start the run and review data in plots.

## Hardware Mode

To measure with a real Keithley 2400 Series SourceMeter:

Prerequisites:

- A Keithley 2400 Series SourceMeter.
- A working serial/USB serial connection that appears as a COM port (e.g., `COM3` on Windows).
- The OS driver for the serial adapter or USB-to-serial cable, if needed.
- Matching serial settings in the app and on the instrument. The release checks used `9600` baud.

Hardware Check:

Before measuring, connect the Keithley in safe open-circuit, low-current conditions and run:

```matlab
addpath('hardware_checks');
results = run_hardware_checks("COM3", 9600, "REAR");
```

Change the port, baud rate, and terminal setting to match your setup.

The public beta hardware gate was verified with:

- Instrument: Keithley 2401
- Port: `COM3`
- Baud rate: `9600`
- Terminal setting: `REAR`

Other Keithley 2400 Series models should be confirmed with the hardware checks before release use.

## Basic Workflow

1. Choose connection settings on the Setup page.
2. For debug exploration: open the About page and enable **Debug Device**.
   For hardware measurements: connect a real Keithley and run hardware checks.
3. Configure Sweep or Time Trace measurement settings.
4. Set Device and Operator metadata.
5. Start the run, then review data in Devices and plots.
6. Export selected data or save all devices when finished.

## Safety Notes

- Start with conservative compliance or limit values.
- Verify front/rear terminal selection before enabling output.
- Verify 2-wire or 4-wire sense mode before measuring.
- Use Stop/Output Off after errors, aborts, or completed runs when working with real hardware.

## Data And Recovery

- Presets are stored in `config/presets.mat`.
- Autosave and recovery files are stored in `cache/`.
- Exported CSV files include visible metadata for measurement type, operator, source mode, sense mode, terminal, instrument, timing, range, and compliance settings.
- Older files that used `Comment` metadata remain import-compatible.

## Runtime Data Directory

The Windows Runtime package stores runtime data (cache, logs, presets, and default exports) under:

```text
%APPDATA%/Keith-IVt
```

This keeps user data separate from the application install folder.

## Development Checks

Run non-hardware checks from the project folder:

```matlab
addpath('dev_checks');
run_all_checks
```

Run hardware checks only with a real instrument connected safely in open-circuit, low-current conditions:

```matlab
addpath('hardware_checks');
results = run_hardware_checks("COM3", 9600, "REAR");
```

## Known Limitations

- Hardware smoke checks have been run on a Keithley 2401. Other models and serial adapters should be verified before release use.
- A Windows Runtime package has been built and smoke-tested on the build machine. Runtime startup can take tens of seconds because MATLAB Runtime initializes the JVM/uifigure stack.
- Instrument profiles are detected, but UI limits are not yet fully clamped by the detected model.
