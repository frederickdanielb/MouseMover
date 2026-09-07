[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$projectPath = Join-Path $repositoryRoot 'MouseTestMover\MouseTestMover.csproj'
$publishPath = Join-Path $repositoryRoot 'artifacts\publish'
$scriptPath = Join-Path $PSScriptRoot 'MouseTestMover.iss'

dotnet publish $projectPath -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -o $publishPath
if ($LASTEXITCODE -ne 0) { throw 'La publicacion de la aplicacion fallo.' }

$compiler = Get-Command 'ISCC.exe' -ErrorAction SilentlyContinue
if ($null -eq $compiler) {
    $knownCompilerPaths = @(
        "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe",
        "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
        "$env:ProgramFiles\Inno Setup 6\ISCC.exe"
    )
    $compilerPath = $knownCompilerPaths | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
}
else {
    $compilerPath = $compiler.Source
}

if ([string]::IsNullOrWhiteSpace($compilerPath)) {
    throw 'No se encontro ISCC.exe. Instala Inno Setup 6 y ejecuta este script nuevamente.'
}

& $compilerPath $scriptPath
if ($LASTEXITCODE -ne 0) { throw 'La compilacion del instalador fallo.' }

Write-Host "Instalador creado en: $repositoryRoot\artifacts\installer\MouseTestMover-Setup.exe"
