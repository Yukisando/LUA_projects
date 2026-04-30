# Build script for The Connor Chronicles Android release.
#
# Usage:
#   .\build-android.ps1                    # Debug APK
#   .\build-android.ps1 -Aab                # Release AAB (signed if keystore.properties present)
#   .\build-android.ps1 -Apk                # Release APK (signed if keystore.properties present)
#
# Requires: ANDROID_HOME, JAVA_HOME (JDK 17+) set, or auto-detected.

param(
    [switch]$Aab,
    [switch]$Apk
)

$ErrorActionPreference = 'Stop'

# --- Resolve toolchain --------------------------------------------------------
$root      = Split-Path -Parent $MyInvocation.MyCommand.Path
$gameDir   = $root
$androidDir = Join-Path $gameDir 'android'
$assetsDest = Join-Path $androidDir 'app\src\embed\assets\game.love'

if (-not $env:ANDROID_HOME) {
    $candidate = Join-Path $env:LOCALAPPDATA 'Android\Sdk'
    if (Test-Path $candidate) { $env:ANDROID_HOME = $candidate; $env:ANDROID_SDK_ROOT = $candidate }
}
if (-not $env:ANDROID_HOME -or -not (Test-Path $env:ANDROID_HOME)) {
    throw "ANDROID_HOME is not set and no SDK found at $env:LOCALAPPDATA\Android\Sdk"
}

if (-not $env:JAVA_HOME) {
    # Try the JBR shipped with Android Studio.
    $jbr = Join-Path $env:ProgramFiles 'Android\Android Studio\jbr'
    if (Test-Path $jbr) { $env:JAVA_HOME = $jbr }
}
if (-not $env:JAVA_HOME) {
    # Fallback: search common JDK install locations.
    $candidates = @()
    foreach ($base in @('C:\Program Files\Java','C:\Program Files\Eclipse Adoptium','C:\Program Files\Microsoft','C:\Program Files\Amazon Corretto')) {
        if (Test-Path $base) {
            $candidates += Get-ChildItem $base -Directory -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -match '^(jdk|jbr)' -and $_.Name -notmatch 'jre' }
        }
    }
    # Pick newest.
    $jdk = $candidates | Sort-Object Name -Descending | Select-Object -First 1
    if ($jdk) { $env:JAVA_HOME = $jdk.FullName }
}
if (-not $env:JAVA_HOME -or -not (Test-Path $env:JAVA_HOME)) {
    throw "JAVA_HOME is not set. Install JDK 17+ (Android Studio bundles one at 'Android Studio\jbr')."
}
$env:Path = "$env:JAVA_HOME\bin;$env:Path"

Write-Host "ANDROID_HOME = $env:ANDROID_HOME"
Write-Host "JAVA_HOME    = $env:JAVA_HOME"

# Write local.properties so Gradle can find the SDK.
Set-Content -Path (Join-Path $androidDir 'local.properties') -Value ("sdk.dir=" + ($env:ANDROID_HOME -replace '\\','\\\\'))

# --- Build game.love ----------------------------------------------------------
Write-Host "Packaging game.love..."
if (Test-Path $assetsDest) { Remove-Item $assetsDest -Force }
New-Item -ItemType Directory -Path (Split-Path $assetsDest) -Force | Out-Null
Push-Location $gameDir
try {
    Compress-Archive -Path 'main.lua','conf.lua','data' -DestinationPath $assetsDest -Force
} finally {
    Pop-Location
}
Write-Host ("game.love size: {0:N0} bytes" -f (Get-Item $assetsDest).Length)

# --- Pick gradle task ---------------------------------------------------------
# Variant naming: <mode><Recording><BuildType>, e.g. embedNoRecordRelease
if ($Aab) {
    $task = ':app:bundleEmbedNoRecordRelease'
    $artifactGlob = 'app\build\outputs\bundle\embedNoRecordRelease\*.aab'
} elseif ($Apk) {
    $task = ':app:assembleEmbedNoRecordRelease'
    $artifactGlob = 'app\build\outputs\apk\embedNoRecord\release\*.apk'
} else {
    $task = ':app:assembleEmbedNoRecordDebug'
    $artifactGlob = 'app\build\outputs\apk\embedNoRecord\debug\*.apk'
}

# --- Run Gradle ---------------------------------------------------------------
Push-Location $androidDir
try {
    $gradleArgs = @($task, '--no-daemon', '--stacktrace')

    # Pull keystore properties if present.
    $kp = Join-Path $androidDir 'keystore.properties'
    if (Test-Path $kp) {
        Get-Content $kp | ForEach-Object {
            if ($_ -match '^\s*([A-Z_]+)\s*=\s*(.+?)\s*$') {
                $key = $Matches[1]
                $val = $Matches[2]
                # Resolve RELEASE_STORE_FILE to absolute (relative to android/).
                if ($key -eq 'RELEASE_STORE_FILE' -and -not [System.IO.Path]::IsPathRooted($val)) {
                    $val = (Resolve-Path (Join-Path $androidDir $val)).Path -replace '\\','/'
                }
                $gradleArgs += "-P$key=$val"
            }
        }
    } else {
        Write-Warning "keystore.properties not found — release artifact will be unsigned."
    }

    Write-Host "Running: gradlew.bat $($gradleArgs -join ' ')"
    & .\gradlew.bat @gradleArgs
    if ($LASTEXITCODE -ne 0) { throw "Gradle build failed with code $LASTEXITCODE" }

    $artifacts = Get-ChildItem (Join-Path $androidDir $artifactGlob) -ErrorAction SilentlyContinue
    if ($artifacts) {
        Write-Host "Built:"
        $artifacts | ForEach-Object { Write-Host "  $($_.FullName) ($([math]::Round($_.Length/1MB,2)) MB)" }
        Start-Process explorer.exe (Split-Path $artifacts[0].FullName)
    }
} finally {
    Pop-Location
}
