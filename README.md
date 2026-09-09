# MouseMover

MouseMover es una aplicación de escritorio WPF para Windows, visible y de uso 100% local. Al activarla, mueve brevemente el cursor del mouse unos pocos píxeles hacia la derecha y de inmediato lo devuelve a su posición original, a un intervalo seleccionado.

El repositorio también incluye `Move-Cursor.ps1`, un script de PowerShell independiente que hace lo mismo desde una terminal, para computadoras donde ejecutar el `.exe` compilado directamente esté restringido.

## Características

- Ventana visible con controles de iniciar, detener y detener ahora.
- Intervalos de 15 segundos, 30 segundos, 1 minuto o 5 minutos.
- Estado claro, cuenta regresiva del próximo movimiento y contador de movimientos realizados.
- Usa `GetCursorPos` y `SendInput` para mover 15 píxeles y regresar, usando coordenadas absolutas del escritorio virtual.
- Muestra el tiempo de inactividad de la sesión obtenido de `GetLastInputInfo` e indica si Windows aceptó el movimiento completo. Esto no garantiza un estado de presencia particular en Teams.
- Solicita a Windows mantener la pantalla encendida solo mientras la app está activa; la solicitud se libera al detenerla o cerrarla.
- Un pequeño ratón se asoma al azar desde una de las cuatro esquinas del panel de estado cada vez que se envía un movimiento.

## Privacidad y alcance

- Funciona 100% local: sin red, servidor, telemetría, analítica ni recolección de datos.
- No guarda configuraciones ni ningún otro dato.
- No se inicia automáticamente con Windows.
- No requiere permisos de administrador.
- Solo Windows. La app usa WPF y APIs nativas de Windows.

## Requisitos

- Windows 10 o superior
- SDK de .NET 10 para compilar desde el código fuente

Verificá tus SDKs instalados:

```powershell
dotnet --list-sdks
```

## Compilar y ejecutar

Desde la raíz del repositorio:

```powershell
dotnet build .\MouseMover.slnx -c Release
dotnet run --project .\MouseMover\MouseMover.csproj
```

## Publicar para otra computadora con Windows

Creá una versión autocontenida para Windows x64. La computadora destino no necesitará tener instalado el runtime de .NET.

```powershell
dotnet publish .\MouseMover\MouseMover.csproj -c Release -r win-x64 --self-contained true -o .\artifacts\publish
```

Distribuí todos los archivos de `artifacts\publish`, ya que WPF puede incluir bibliotecas nativas auxiliares junto al ejecutable.

Si la ejecución directa del ejecutable está restringida, `artifacts\publish\Abrir-MouseMover.bat` inicia la aplicación mediante un comando `dotnet` instalado. Mantenelo en la misma carpeta que `MouseMover.dll`; requiere el .NET 10 Desktop Runtime o el SDK en la computadora destino.

> Algunas herramientas de protección de endpoints (agentes de control de aplicaciones como ManageEngine) bloquean ejecutables recién compilados que se corren directamente desde una carpeta de usuario. En ese caso, instalá la app con el asistente de instalación de abajo (que la coloca bajo `%LocalAppData%\Programs`) o pedile a IT que autorice el ejecutable.

## Crear un instalador

La carpeta local `installer` contiene una definición de Inno Setup 6. Genera un asistente de instalación en español, instala para el usuario actual sin permisos de administrador, ofrece un acceso directo opcional en el escritorio, crea una entrada de desinstalación y no configura el inicio automático.

1. Instalá [Inno Setup 6](https://jrsoftware.org/isdl.php).
2. Desde la raíz del repositorio, ejecutá:

   ```powershell
   .\installer\build-installer.ps1
   ```

3. Compartí el archivo generado:

   ```text
   artifacts\installer\MouseMover-Setup.exe
   ```

## Uso

1. Abrí la aplicación.
2. Seleccioná un intervalo.
3. Seleccioná **Iniciar**.
4. Seleccioná **Detener**, **Detener ahora**, o cerrá la ventana para detenerla.

## Alternativa por consola: Move-Cursor.ps1

`Move-Cursor.ps1`, en la raíz del repositorio, es un script de PowerShell autocontenido que no requiere compilación. Es útil cuando no podés ejecutar la app WPF (por ejemplo, mientras esperás que IT la autorice) y solo necesitás el movimiento del cursor desde una terminal.

### Menú interactivo

Ejecutado sin parámetros, el script muestra un menú simple para configurar el intervalo, el desplazamiento y la duración (Enter acepta el valor por defecto que se muestra entre corchetes):

```powershell
.\Move-Cursor.ps1
```

### Modo directo (para automatizar)

Pasando cualquier parámetro, o agregando `-NoInteractive`, se omite el menú y arranca de inmediato:

```powershell
.\Move-Cursor.ps1 -IntervalSeconds 60 -OffsetPixels 20 -DurationMinutes 120
```

| Parámetro | Valor por defecto | Descripción |
| --- | --- | --- |
| `-IntervalSeconds` | 30 | Segundos entre movimientos (1 a 3600). |
| `-OffsetPixels` | 15 | Píxeles que se desplaza el cursor antes de regresar (1 a 500). |
| `-DurationMinutes` | 0 (sin límite) | Minutos que corre antes de detenerse solo (0 a 1440). |
| `-NoInteractive` | (desactivado) | Omite el menú inicial aunque no se pase ningún otro parámetro. |

### Mientras corre

- Muestra una barra de progreso nativa de PowerShell con el estado, el próximo movimiento, la inactividad real registrada por Windows (`GetLastInputInfo`) y el total de movimientos.
- `P` pausa y reanuda sin cerrar el script (la cuenta regresiva se congela mientras está en pausa).
- `Q` o `Ctrl+C` lo detienen de forma prolija y muestran un resumen final (movimientos realizados y duración de la sesión). En consolas que no admiten lectura de teclas (por ejemplo, entrada redirigida desde un archivo) el script lo detecta solo y sigue funcionando con `Ctrl+C` como única forma de salir.

El script solo usa `GetCursorPos`, `SetCursorPos` y `GetLastInputInfo` de `user32.dll`, imprime todo en la consola, y no escribe ningún archivo ni deja un proceso en segundo plano al salir.

## Desarrollo

Consultá [CONTRIBUTING.md](CONTRIBUTING.md) para la guía de contribución local, [TESTING.md](TESTING.md) para los pasos de validación, y [CHANGELOG.md](CHANGELOG.md) para el historial de versiones.

## Licencia

Este proyecto está licenciado bajo la [Licencia MIT](LICENSE).
