# Contributing

Thank you for improving Mouse Test Mover.

## Local workflow

1. Create a local branch.
2. Build the solution:

   ```powershell
   dotnet build .\MouseTestMover.slnx -c Release
   ```

3. Follow the checks in [TESTING.md](TESTING.md).
4. Keep changes focused and update `CHANGELOG.md` when user-visible behavior changes.

## Guidelines

- Preserve the local-only design: do not add network access, telemetry, persistence, auto-start, or administrator requirements without explicit discussion.
- Keep the window visible while the feature is active.
- Use clear Spanish user-facing text and clear English code identifiers.
- Do not commit generated output such as `bin`, `obj`, `artifacts`, or installers.
