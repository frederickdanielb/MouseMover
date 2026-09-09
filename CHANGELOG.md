# Historial de cambios

Todos los cambios relevantes de este proyecto se documentan en este archivo.

## [Sin publicar]

### Cambiado

- Se renombró el proyecto y la solución de Mouse Test Mover a MouseMover (carpeta, namespace, ensamblado, instalador y referencias de CI) tras confirmar que el nombre/compilación anterior era bloqueado por una política de control de aplicaciones del endpoint.
- Se quitó la ilustración estática del programador y sus animaciones; el panel principal ahora es una simple tarjeta de estado.
- El ratón ahora se asoma desde una esquina aleatoria detrás del panel de estado en cada movimiento del cursor, con una expresión más enojada (cejas fruncidas, ojos rojos, colmillos).
- La ventana ahora ajusta su tamaño al contenido (`SizeToContent="Height"`) en lugar de tener una altura fija.

### Agregado

- Se agregó `Move-Cursor.ps1`, una alternativa por consola a la app WPF, con sus parámetros documentados en el README.
- `Move-Cursor.ps1` ahora tiene menú interactivo inicial (si se ejecuta sin parámetros), barra de progreso nativa con inactividad real de Windows, pausar/reanudar con `P`, salida prolija con `Q` o `Ctrl+C`, resumen final de sesión, y detección automática de consolas sin soporte de teclas (con `-NoInteractive` para omitir el menú).

## [1.0.0] - 2026-09-06

### Agregado

- Interfaz de escritorio WPF para pruebas locales de movimiento del cursor.
- Selector de intervalo, indicador de estado activo, cuenta regresiva y contador de movimientos.
- Integración P/Invoke con `GetCursorPos` y `SetCursorPos`.
- Solicitud de pantalla encendida mientras la aplicación está activa.
- Modelo de privacidad 100% local y detención automática al cerrar la ventana.
