# Pruebas

Antes de compartir un cambio, compilá en modo Release:

```powershell
dotnet build .\MouseMover.slnx -c Release
```

Luego ejecutá la aplicación:

```powershell
dotnet run --project .\MouseMover\MouseMover.csproj
```

Realizá estas verificaciones manuales:

1. La ventana principal es visible al iniciar y no se abre automáticamente con Windows.
2. Se puede seleccionar cada opción de intervalo mientras está detenido.
3. **Iniciar** cambia el estado a activo e inicia la cuenta regresiva.
4. Al llegar al intervalo seleccionado, el contador de movimientos realizados aumenta.
5. **Detener** y **Detener ahora** detienen la cuenta regresiva y vuelven a habilitar el selector de intervalo.
6. Cerrar la ventana detiene el estado activo.
7. Con la app activa, dejá pasar el tiempo normal de apagado de pantalla y verificá que la pantalla se mantenga encendida. Luego detené la app y verificá que el comportamiento normal del sistema se restablezca.
8. Verificá que la app no hace ninguna solicitud de red y no crea archivos de configuración locales.
9. Sin tocar el mouse ni el teclado, comprobá que el tiempo de inactividad de Windows aumenta mientras está detenido. Iniciá la app y comprobá si baja después de cada movimiento aceptado. El indicador de "evento enviado" por sí solo no confirma un reinicio del tiempo de inactividad ni la presencia en Teams.
10. Probá cerca del borde derecho y en un monitor secundario (incluyendo uno ubicado a la izquierda del monitor principal). Confirmá que el cursor regresa a su posición inicial.
11. Confirmá que al detener se evitan más movimientos generados, mientras el indicador de inactividad sigue actualizándose.
12. El ratón se asoma al azar desde una de las cuatro esquinas del panel de estado en cada movimiento, y vuelve a esconderse solo.
