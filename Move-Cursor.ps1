[CmdletBinding()]
param(
    [ValidateRange(1, 3600)]
    [int]$IntervalSeconds = 30,

    [ValidateRange(1, 500)]
    [int]$OffsetPixels = 15,

    [ValidateRange(0, 1440)]
    [int]$DurationMinutes = 0,

    [switch]$NoInteractive
)

if (-not ('CursorNativeMethods' -as [type])) {
    Add-Type @'
using System.Runtime.InteropServices;

public static class CursorNativeMethods
{
    [DllImport("user32.dll")]
    public static extern bool GetCursorPos(out POINT point);

    [DllImport("user32.dll")]
    public static extern bool SetCursorPos(int x, int y);

    [DllImport("user32.dll")]
    public static extern int GetSystemMetrics(int index);

    [DllImport("user32.dll")]
    public static extern bool GetLastInputInfo(ref LASTINPUTINFO info);

    public struct POINT
    {
        public int X;
        public int Y;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct LASTINPUTINFO
    {
        public uint cbSize;
        public uint dwTime;
    }
}
'@
}

function Write-Status {
    param(
        [string]$Message,
        [ConsoleColor]$Color = [ConsoleColor]::White
    )

    $time = Get-Date -Format 'HH:mm:ss'
    Write-Host "[$time] $Message" -ForegroundColor $Color
}

function Read-IntOrDefault {
    param(
        [string]$Prompt,
        [int]$Default,
        [int]$Min,
        [int]$Max
    )

    $raw = Read-Host "$Prompt [$Default]"
    if ([string]::IsNullOrWhiteSpace($raw)) { return $Default }

    $parsed = 0
    if ([int]::TryParse($raw, [ref]$parsed) -and $parsed -ge $Min -and $parsed -le $Max) {
        return $parsed
    }

    Write-Host "Valor invalido, se usa $Default." -ForegroundColor Yellow
    return $Default
}

function Get-IdleSeconds {
    $info = New-Object CursorNativeMethods+LASTINPUTINFO
    $info.cbSize = [System.Runtime.InteropServices.Marshal]::SizeOf($info)
    if ([CursorNativeMethods]::GetLastInputInfo([ref]$info)) {
        return [Math]::Max(0, [Math]::Round(([Environment]::TickCount - $info.dwTime) / 1000))
    }
    return -1
}

if (-not $NoInteractive -and $PSBoundParameters.Count -eq 0) {
    Write-Host ''
    Write-Host '=== MouseMover - script de consola ===' -ForegroundColor Cyan
    Write-Host 'Presiona Enter en cada pregunta para aceptar el valor por defecto.' -ForegroundColor DarkGray
    Write-Host ''
    $IntervalSeconds = Read-IntOrDefault 'Intervalo en segundos' $IntervalSeconds 1 3600
    $OffsetPixels = Read-IntOrDefault 'Desplazamiento en pixeles' $OffsetPixels 1 500
    $DurationMinutes = Read-IntOrDefault 'Duracion en minutos (0 = sin limite)' $DurationMinutes 0 1440
    Write-Host ''
}

$virtualScreenLeft = [CursorNativeMethods]::GetSystemMetrics(76) # SM_XVIRTUALSCREEN
$virtualScreenWidth = [CursorNativeMethods]::GetSystemMetrics(78) # SM_CXVIRTUALSCREEN
$virtualScreenRight = $virtualScreenLeft + $virtualScreenWidth - 1
$movementCount = 0
$isPaused = $false
$requestStop = $false
$startedAt = Get-Date
$stopAt = $null
if ($DurationMinutes -gt 0) { $stopAt = $startedAt.AddMinutes($DurationMinutes) }

$hotKeysSupported = $true
$originalTreatControlCAsInput = $false
try {
    $originalTreatControlCAsInput = [Console]::TreatControlCAsInput
    [Console]::TreatControlCAsInput = $true
}
catch {
    $hotKeysSupported = $false
}

if ($hotKeysSupported) {
    Write-Status "Moviendo el cursor $OffsetPixels px cada $IntervalSeconds s. [P] pausar/reanudar, [Q] o Ctrl+C para salir." Cyan
}
else {
    Write-Status "Moviendo el cursor $OffsetPixels px cada $IntervalSeconds s. Presiona Ctrl+C para salir (esta consola no soporta pausar con teclas)." Cyan
}
if ($stopAt) { Write-Status "Se detendra automaticamente a las $($stopAt.ToString('HH:mm:ss'))." DarkCyan }

function Test-HotKey {
    if (-not $script:hotKeysSupported) { return }

    try {
        if (-not [Console]::KeyAvailable) { return }
        $key = [Console]::ReadKey($true)
    }
    catch {
        $script:hotKeysSupported = $false
        return
    }

    $isQuit = ($key.Key -eq 'Q') -or (($key.Modifiers -band [ConsoleModifiers]::Control) -and $key.Key -eq 'C')
    if ($isQuit) {
        $script:requestStop = $true
        return
    }
    if ($key.Key -eq 'P') {
        $script:isPaused = -not $script:isPaused
        if ($script:isPaused) { Write-Status 'En pausa. Presiona P para reanudar.' Yellow }
        else { Write-Status 'Reanudado.' Green }
    }
}

try {
    while (-not $requestStop) {
        if ($stopAt -and (Get-Date) -ge $stopAt) {
            Write-Status 'Duracion completada.' Yellow
            break
        }

        if (-not $isPaused) {
            $position = New-Object CursorNativeMethods+POINT
            if ([CursorNativeMethods]::GetCursorPos([ref]$position)) {
                $targetX = $position.X + $OffsetPixels
                if ($targetX -gt $virtualScreenRight) {
                    $targetX = $position.X - $OffsetPixels
                }

                $targetX = [Math]::Max($virtualScreenLeft, [Math]::Min($targetX, $virtualScreenRight))
                [void][CursorNativeMethods]::SetCursorPos($targetX, $position.Y)
                Start-Sleep -Milliseconds 100
                [void][CursorNativeMethods]::SetCursorPos($position.X, $position.Y)

                $movementCount++
                Write-Status "Movimiento #$movementCount | Posicion: ($($position.X), $($position.Y)) -> ($targetX, $($position.Y))" Green
            }
        }

        $remaining = $IntervalSeconds
        while ($remaining -gt 0 -and -not $requestStop) {
            if ($stopAt -and (Get-Date) -ge $stopAt) { break }

            for ($tick = 0; $tick -lt 5 -and -not $requestStop; $tick++) {
                Test-HotKey
                Start-Sleep -Milliseconds 200
            }
            if ($requestStop) { break }

            if (-not $isPaused) { $remaining-- }

            $idleSeconds = Get-IdleSeconds
            $statusLabel = if ($isPaused) { 'PAUSADO' } else { 'activo' }
            $percent = [int]((($IntervalSeconds - $remaining) / [double]$IntervalSeconds) * 100)
            Write-Progress -Activity 'MouseMover' -Status "$statusLabel | proximo movimiento en $remaining s | inactividad Windows: $idleSeconds s | movimientos: $movementCount" -PercentComplete $percent
        }
    }
}
finally {
    Write-Progress -Activity 'MouseMover' -Completed
    if ($hotKeysSupported) {
        try { [Console]::TreatControlCAsInput = $originalTreatControlCAsInput } catch { }
    }
    $sessionDuration = (Get-Date) - $startedAt
    Write-Host ''
    Write-Status "Sesion finalizada. Movimientos realizados: $movementCount. Duracion: $($sessionDuration.ToString('hh\:mm\:ss'))." Cyan
}
