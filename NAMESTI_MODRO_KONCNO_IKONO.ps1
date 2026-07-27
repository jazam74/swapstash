$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$PayloadRoot = Join-Path $ProjectRoot "_swapstash_blue_icon_payload"

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
    "nova modra ikona"
Require-Path `
    (Join-Path $PayloadRoot "flutter_launcher_icons.yaml") `
    "konfiguracija ikon"

$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$BackupRoot = Join-Path `
    "$env:USERPROFILE\Documents\swapstash_backups\icons" `
    $Timestamp

New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null

$FilesToBackup = @(
    "pubspec.yaml",
    "pubspec.lock",
    "flutter_launcher_icons.yaml",
    "assets\app_icon\swapstash_launcher_icon.png"
)

foreach ($RelativePath in $FilesToBackup) {
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

$ResourceRoot = Join-Path $ProjectRoot "android\app\src\main\res"

if (Test-Path $ResourceRoot) {
    Get-ChildItem `
        -Path $ResourceRoot `
        -Directory `
        -Filter "mipmap*" |
        ForEach-Object {
            $Destination = Join-Path `
                $BackupRoot `
                ("android\app\src\main\res\" + $_.Name)

            New-Item `
                -ItemType Directory `
                -Path (Split-Path -Parent $Destination) `
                -Force |
                Out-Null

            Copy-Item $_.FullName $Destination -Recurse -Force
        }
}

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
Write-Host "1/4 Preverjanje generatorja ikon" -ForegroundColor Cyan
flutter pub add --dev flutter_launcher_icons
if ($LASTEXITCODE -ne 0) {
    throw "Dodajanje ali preverjanje flutter_launcher_icons ni uspelo."
}

Write-Host ""
Write-Host "2/4 Ustvarjanje nove modre Android ikone" -ForegroundColor Cyan
dart run flutter_launcher_icons -f flutter_launcher_icons.yaml
if ($LASTEXITCODE -ne 0) {
    throw "Ustvarjanje Android ikon ni uspelo."
}

Write-Host ""
Write-Host "3/4 Ciscenje in odvisnosti" -ForegroundColor Cyan
flutter clean
if ($LASTEXITCODE -ne 0) {
    throw "flutter clean ni uspel."
}

flutter pub get
if ($LASTEXITCODE -ne 0) {
    throw "flutter pub get ni uspel."
}

Write-Host ""
Write-Host "4/4 Analiza projekta" -ForegroundColor Cyan
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
Write-Host "Nova modra ikona SwapStash je uspesno namescena." `
    -ForegroundColor Green
Write-Host ""
Write-Host "Varnostna kopija je izven projekta:"
Write-Host "  $BackupRoot"
Write-Host ""
Write-Host "Za preverjanje na emulatorju zazeni:"
Write-Host "  flutter run -d emulator-5554"
Write-Host ""
Write-Host "Po uspešnem testu ponovno zgradi AAB:"
Write-Host "  .\ZGRADI_RELEASE_AAB.ps1"
