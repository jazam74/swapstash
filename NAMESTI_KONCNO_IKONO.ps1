$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$PayloadRoot = Join-Path $ProjectRoot "_swapstash_icon_payload"

function Require-Path {
    param(
        [string]$Path,
        [string]$Description
    )

    if (-not (Test-Path $Path)) {
        throw "Manjka $Description`: $Path"
    }
}

Require-Path (Join-Path $ProjectRoot "pubspec.yaml") "pubspec.yaml"
Require-Path `
    (Join-Path $PayloadRoot "assets\app_icon\swapstash_launcher_icon.png") `
    "izbrana ikona"
Require-Path `
    (Join-Path $PayloadRoot "flutter_launcher_icons.yaml") `
    "konfiguracija ikon"

$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$BackupRoot = Join-Path $ProjectRoot "_icon_backup\$Timestamp"
New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null

# Back up Flutter package files.
$ProjectFiles = @(
    "pubspec.yaml",
    "pubspec.lock",
    "flutter_launcher_icons.yaml"
)

foreach ($RelativePath in $ProjectFiles) {
    $Source = Join-Path $ProjectRoot $RelativePath

    if (Test-Path $Source) {
        $Destination = Join-Path $BackupRoot $RelativePath
        $DestinationDirectory = Split-Path -Parent $Destination

        if ($DestinationDirectory) {
            New-Item `
                -ItemType Directory `
                -Path $DestinationDirectory `
                -Force |
                Out-Null
        }

        Copy-Item $Source $Destination -Force
    }
}

# Back up current Android launcher resources.
$ResourceRoot = Join-Path $ProjectRoot "android\app\src\main\res"

if (Test-Path $ResourceRoot) {
    $LauncherResources = Get-ChildItem `
        -Path $ResourceRoot `
        -Directory `
        -Filter "mipmap*"

    foreach ($Folder in $LauncherResources) {
        $Destination = Join-Path `
            $BackupRoot `
            ("android\app\src\main\res\" + $Folder.Name)

        Copy-Item $Folder.FullName $Destination -Recurse -Force
    }
}

# Install the source icon and package configuration.
$AssetDestination = Join-Path `
    $ProjectRoot `
    "assets\app_icon\swapstash_launcher_icon.png"

New-Item `
    -ItemType Directory `
    -Path (Split-Path -Parent $AssetDestination) `
    -Force |
    Out-Null

Copy-Item `
    (Join-Path `
        $PayloadRoot `
        "assets\app_icon\swapstash_launcher_icon.png") `
    $AssetDestination `
    -Force

Copy-Item `
    (Join-Path $PayloadRoot "flutter_launcher_icons.yaml") `
    (Join-Path $ProjectRoot "flutter_launcher_icons.yaml") `
    -Force

Set-Location $ProjectRoot

Write-Host ""
Write-Host "1/4 Dodajanje generatorja ikon" -ForegroundColor Cyan
flutter pub add --dev flutter_launcher_icons
if ($LASTEXITCODE -ne 0) {
    throw "Dodajanje flutter_launcher_icons ni uspelo."
}

Write-Host ""
Write-Host "2/4 Ustvarjanje Android ikon" -ForegroundColor Cyan
dart run flutter_launcher_icons -f flutter_launcher_icons.yaml
if ($LASTEXITCODE -ne 0) {
    throw "Ustvarjanje Android ikon ni uspelo."
}

Write-Host ""
Write-Host "3/4 Flutter clean" -ForegroundColor Cyan
flutter clean
if ($LASTEXITCODE -ne 0) {
    throw "flutter clean ni uspel."
}

Write-Host ""
Write-Host "4/4 Flutter analyze" -ForegroundColor Cyan
flutter pub get
if ($LASTEXITCODE -ne 0) {
    throw "flutter pub get ni uspel."
}

flutter analyze
if ($LASTEXITCODE -ne 0) {
    throw "flutter analyze je nasel napake."
}

$RequiredIcon = Join-Path `
    $ProjectRoot `
    "android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png"

if (-not (Test-Path $RequiredIcon)) {
    throw "Nova Android ikona ni bila najdena."
}

Write-Host ""
Write-Host "Končna ikona SwapStash je uspešno nameščena." `
    -ForegroundColor Green
Write-Host ""
Write-Host "Varnostna kopija:"
Write-Host "  $BackupRoot"
Write-Host ""
Write-Host "Za test na emulatorju zaženi:"
Write-Host "  flutter run -d emulator-5554"
Write-Host ""
Write-Host "Po uspešnem testu ponovno zgradi AAB:"
Write-Host "  .\ZGRADI_RELEASE_AAB.ps1"
