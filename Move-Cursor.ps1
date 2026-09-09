[CmdletBinding()]
param(
    [ValidateRange(1, 3600)]
    [int]$IntervalSeconds = 30,

    [ValidateRange(1, 500)]
    [int]$OffsetPixels = 15,

    [ValidateRange(0, 1440)]
    [int]$DurationMinutes = 0
)

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

    public struct POINT
    {
        public int X;
        public int Y;
    }
}
'@

function Write-Status {
    param(
        [string]$Message,
        [ConsoleColor]$Color = [ConsoleColor]::White
    )

    $time = Get-Date -Format 'HH:mm:ss'
    $line = "[$time] $Message"
    Write-Host $line -ForegroundColor $Color
}

$virtualScreenLeft = [CursorNativeMethods]::GetSystemMetrics(76) # SM_XVIRTUALSCREEN
$virtualScreenWidth = [CursorNativeMethods]::GetSystemMetrics(78) # SM_CXVIRTUALSCREEN
$virtualScreenRight = $virtualScreenLeft + $virtualScreenWidth - 1
$movementCount = 0
$stopAt = if ($DurationMinutes -gt 0) { (Get-Date).AddMinutes($DurationMinutes) } else { $null }
$durationMessage = if ($stopAt) { " Se detendrá a las $($stopAt.ToString('HH:mm'))." } else { '' }

Write-Status "Moviendo el cursor $OffsetPixels píxeles cada $IntervalSeconds segundos. Presiona Ctrl+C para detener.$durationMessage" Cyan

while ($true) {
    if ($stopAt -and (Get-Date) -ge $stopAt) {
        Write-Status "Duración completada. Movimientos realizados: $movementCount." Yellow
        break
    }

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
        Write-Status "Movimiento #$movementCount | Posición: ($($position.X), $($position.Y)) | Destino: ($targetX, $($position.Y))" Green
    }

    for ($remaining = $IntervalSeconds; $remaining -gt 0; $remaining--) {
        if ($stopAt -and (Get-Date) -ge $stopAt) { break }
        Write-Host "`rPróximo movimiento en: $remaining s   " -NoNewline -ForegroundColor Cyan
        Start-Sleep -Seconds 1
    }
    Write-Host "`r                                      `r" -NoNewline
}
