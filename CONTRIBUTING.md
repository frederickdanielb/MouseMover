# Contribuir

Gracias por mejorar MouseMover.

## Flujo de trabajo local

1. Creá una rama local.
2. Compilá la solución:

   ```powershell
   dotnet build .\MouseMover.slnx -c Release
   ```

3. Seguí las verificaciones en [TESTING.md](TESTING.md).
4. Mantené los cambios enfocados y actualizá `CHANGELOG.md` cuando cambie el comportamiento visible para el usuario.

## Lineamientos

- Preservá el diseño 100% local: no agregues acceso a red, telemetría, persistencia, inicio automático ni requisitos de administrador sin discutirlo explícitamente.
- Mantené la ventana visible mientras la función está activa.
- Usá texto claro en español para el usuario e identificadores de código claros en inglés.
- No subas archivos generados como `bin`, `obj`, `artifacts` o instaladores.
