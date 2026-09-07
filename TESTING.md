# Testing

Run the release build before sharing a change:

```powershell
dotnet build .\MouseTestMover.slnx -c Release
```

Then run the application:

```powershell
dotnet run --project .\MouseTestMover\MouseTestMover.csproj
```

Perform these manual checks:

1. The main window is visible on startup and does not start automatically with Windows.
2. Each interval option can be selected while stopped.
3. **Iniciar** changes the status to active and starts the countdown.
4. At the selected interval, the completed-movement counter increments.
5. **Detener** and **Detener ahora** stop the countdown and re-enable the interval selector.
6. Closing the window stops the active state.
7. With the app active, allow the normal display timeout to pass and verify that the display remains on. Then stop the app and verify normal system behavior resumes.
8. Verify the app makes no network requests and creates no local configuration files.
