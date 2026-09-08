@echo off
setlocal

where dotnet >nul 2>&1
if errorlevel 1 (
    echo No se encontro .NET en este computador.
    echo Solicita a TI la instalacion de .NET 10 Desktop Runtime o la autorizacion del instalador.
    pause
    exit /b 1
)

dotnet "%~dp0MouseTestMover.dll"
