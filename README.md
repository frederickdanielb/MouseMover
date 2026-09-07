# Mouse Test Mover

Mouse Test Mover is a visible, local-only WPF desktop application for Windows. When enabled, it briefly moves the mouse cursor a few pixels to the right and immediately restores its original position at a selected interval.

## Features

- Visible window with start, stop, and stop-now controls.
- Intervals of 15 seconds, 30 seconds, 1 minute, or 5 minutes.
- Clear status, next-movement countdown, and completed-movement counter.
- Uses the Windows `GetCursorPos` and `SetCursorPos` APIs through P/Invoke.
- Requests that Windows keep the display on only while the app is active; the request is released when stopped or closed.

## Privacy and scope

- Runs locally only: no network, server, telemetry, analytics, or data collection.
- Does not store settings or other data.
- Does not start automatically with Windows.
- Does not require administrator permissions.
- Windows only. The app uses WPF and Windows-native APIs.

## Requirements

- Windows 10 or later
- .NET 10 SDK to build from source

Verify your installed SDKs:

```powershell
dotnet --list-sdks
```

## Build and run

From the repository root:

```powershell
dotnet build .\MouseTestMover.slnx -c Release
dotnet run --project .\MouseTestMover\MouseTestMover.csproj
```

## Publish for another Windows computer

Create a self-contained Windows x64 release. The target computer will not need the .NET runtime installed.

```powershell
dotnet publish .\MouseTestMover\MouseTestMover.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -o .\artifacts\publish
```

Distribute all files in `artifacts\publish`, as WPF may include native helper libraries alongside the executable.

## Create an installation wizard

The local `installer` folder contains an Inno Setup 6 definition. It creates a Spanish-language installation wizard, installs for the current user without administrator permissions, offers an optional desktop shortcut, creates an uninstall entry, and does not configure automatic startup.

1. Install [Inno Setup 6](https://jrsoftware.org/isdl.php).
2. From the repository root, run:

   ```powershell
   .\installer\build-installer.ps1
   ```

3. Share the generated file:

   ```text
   artifacts\installer\MouseTestMover-Setup.exe
   ```

## Use

1. Open the application.
2. Select an interval.
3. Select **Iniciar**.
4. Select **Detener**, **Detener ahora**, or close the window to stop.

## Development

See [CONTRIBUTING.md](CONTRIBUTING.md) for local contribution guidance, [TESTING.md](TESTING.md) for validation steps, and [CHANGELOG.md](CHANGELOG.md) for release history.

## License

This project is licensed under the [MIT License](LICENSE).
