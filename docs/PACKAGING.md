# Keith-IVt Packaging Notes

These notes define the packaging process for the public beta. The first Windows Runtime package was built and smoke-tested with MATLAB Compiler R2025b.

Repository: `https://github.com/Xiaolong-6/Keith-IVt`

## Source Package

Include:

- `START_Keith_IVt.m`
- `ABOUT.txt`
- `README.md`
- `LICENSE`
- `CHANGELOG.md`
- `docs/ARCHITECTURE.md`
- `docs/ROADMAP.md`
- `docs/RELEASE_CHECKLIST.md`
- `docs/PACKAGING.md`
- `docs/RELEASE_VERIFICATION_2026-05-11.md`
- `docs/screenshots/`
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

## 0.3.0 Beta Windows Runtime Build

Built package:

```text
dist/Keith-IVt-v0.3.0-beta-runtime-win-gui.zip
```

Distribution location:

- Keep source code and documentation in the Git repository.
- Upload the Runtime zip and its SHA256 file as GitHub Release assets.
- Do not commit compiled Runtime builds to the repository.
- GitHub Packages is not needed for this MATLAB desktop app.

Executable inside the package:

```text
Keith_IVt.exe
```

Required Runtime:

```text
MATLAB Runtime R2025b (25.2) for Windows
```

Smoke test performed on the build machine:

- Compiled executable launched successfully.
- The UI opened successfully after MATLAB Runtime initialization.
- The package was rebuilt with `mcc -e` so Windows launches the GUI app without an extra console window.
- The About page loads packaged `ABOUT.txt`.
- Closing the UI does not raise the deleted-object wait error.
- Generated runtime data is directed to `%APPDATA%/Keith-IVt` instead of the app install folder or MATLAB Runtime cache.
- Startup can take tens of seconds because MATLAB Runtime initializes the JVM/uifigure stack and packaged resources.

## Public Beta Notes

Document these limitations until they are resolved:

- Real hardware behavior must be verified by the user on their own wiring and safety setup.
- Instrument profile limits are not yet fully enforced in the UI.
- MATLAB Runtime startup is slower than launching from MATLAB source, especially on the first run or from synced folders.
- Serial-port names differ across Windows, macOS, and Linux.
