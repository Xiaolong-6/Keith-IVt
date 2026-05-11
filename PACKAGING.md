# Keith-IVt Packaging Notes

These notes define the intended packaging process for a public beta. Update them after the first successful MATLAB Runtime packaging test.

## Source Package

Include:

- `START_Keith_IVt.m`
- `ABOUT.txt`
- `README.md`
- `LICENSE`
- `ARCHITECTURE.md`
- `ROADMAP.md`
- `RELEASE_CHECKLIST.md`
- `PACKAGING.md`
- `+core/`
- `+data/`
- `+hardware/`
- `+ui/`
- `config/`
- `dev_checks/`
- `hardware_checks/`

Exclude:

- `cache/` contents
- `archive/`
- Generated exports
- Backup files
- Local MATLAB project files unless intentionally maintained
- Zip files from previous builds

## MATLAB App Package

Before building:

1. Start MATLAB in the project folder.
2. Run `addpath('dev_checks'); run_all_checks`.
3. Launch `START_Keith_IVt`.
4. Confirm debug sweep and time trace work.
5. Clear local runtime cache files.

Package using MATLAB's Application Compiler or App Packaging workflow. The startup file should be:

```text
START_Keith_IVt.m
```

Include package folders and documentation as additional files.

## Runtime Validation

Validate the package on a clean machine or clean user profile:

- App opens without adding manual paths.
- Debug Device mode works without hardware.
- Presets save and load from `config/presets.mat`.
- Autosave/recovery writes to `cache/`.
- CSV export/import works with a short debug dataset.
- The About page shows the expected version and release URL.

## Public Beta Notes

Document these limitations until they are resolved:

- Real hardware behavior must be verified by the user on their own wiring and safety setup.
- Instrument profile limits are not yet fully enforced in the UI.
- MATLAB Runtime compatibility must be tested for each published package.
- Serial-port names differ across Windows, macOS, and Linux.
