[CmdletBinding()]
param(
    [switch]$SkipJuliaInstall,
    [switch]$SkipPythonInstall
)

$ErrorActionPreference = 'Stop'
$repoRoot = $PSScriptRoot

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'Git is required. Install Git for Windows, reopen PowerShell, and rerun this script.'
}

if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    if ($SkipPythonInstall) {
        throw 'Python is not on PATH and -SkipPythonInstall was supplied.'
    }
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw 'Python is not on PATH and winget is unavailable. Install Python 3.11 or newer, then rerun.'
    }
    Write-Host 'Installing Python with winget...'
    winget install --id Python.Python.3.12 --exact --accept-package-agreements --accept-source-agreements
    $machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = "$machinePath;$userPath"
}

Write-Host 'Installing the Python practice dependencies...'
& python -m pip install --requirement (Join-Path $repoRoot 'requirements.txt')

if (-not (Get-Command julia -ErrorAction SilentlyContinue)) {
    if ($SkipJuliaInstall) {
        throw 'Julia is not on PATH and -SkipJuliaInstall was supplied.'
    }
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw 'Julia is not on PATH and winget is unavailable. Install Julia 1.10 or newer, then rerun.'
    }
    Write-Host 'Installing Julia with winget...'
    winget install --id Julialang.Julia --exact --accept-package-agreements --accept-source-agreements
    $machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = "$machinePath;$userPath"
}

if (-not (Get-Command julia -ErrorAction SilentlyContinue)) {
    throw 'Julia was installed but is not visible yet. Open a new PowerShell window and rerun this script.'
}

Write-Host 'Instantiating the course environment...'
& julia --project=$repoRoot -e 'using Pkg; Pkg.instantiate(); Pkg.precompile()'
& julia --project=$repoRoot (Join-Path $repoRoot 'setup\week01_check.jl')

$week2 = Join-Path $repoRoot 'week02\lab\EC991Week2'
Write-Host 'Instantiating and testing the Week 2 package...'
& julia --project=$week2 -e 'using Pkg; Pkg.instantiate(); Pkg.test()'

Write-Host 'Environment ready.'
Write-Host "Open Pluto with: julia --project=`"$repoRoot`" -e 'using Pluto; Pluto.run()'"
