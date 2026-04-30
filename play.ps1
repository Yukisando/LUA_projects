# Plays one of the LÖVE games in this repo using the bundled love.exe.
# Usage: .\play.ps1 [gameName]
#   e.g. .\play.ps1 neonrunner
# If no name is given, you get an interactive picker.

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$love = Join-Path $root 'LoveToAndroid\tools\love-win\love.exe'

if (-not (Test-Path $love)) {
    Write-Error "Bundled love.exe not found at $love"
    exit 1
}

$games = @(
    'blindspot','bob','concron','diidle','golfgame',
    'nanotank','neonrunner','NewGame','nodino','Yukiland'
) | Where-Object { Test-Path (Join-Path $root "$_\main.lua") }

$choice = $args[0]
if (-not $choice) {
    for ($i = 0; $i -lt $games.Count; $i++) {
        Write-Host ("  [{0}] {1}" -f ($i + 1), $games[$i])
    }
    $sel = Read-Host 'Pick a game number'
    if ($sel -match '^\d+$' -and [int]$sel -ge 1 -and [int]$sel -le $games.Count) {
        $choice = $games[[int]$sel - 1]
    } else {
        Write-Error 'Invalid selection.'
        exit 1
    }
}

$gameDir = Join-Path $root $choice
if (-not (Test-Path (Join-Path $gameDir 'main.lua'))) {
    Write-Error "No main.lua found in $gameDir"
    exit 1
}

Write-Host "Launching $choice..."
& $love $gameDir
