$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$PayloadRoot = Join-Path $ProjectRoot "_swapstash_package_payload"

function Require-Path {
    param([string]$Path, [string]$Description)

    if (-not (Test-Path $Path)) {
        throw "Manjka $Description`: $Path"
    }
}

Require-Path (Join-Path $ProjectRoot "pubspec.yaml") "pubspec.yaml"
Require-Path (Join-Path $ProjectRoot "android\app") "mapa android\app"
Require-Path $PayloadRoot "namestitveni paket"

$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$BackupRoot = Join-Path $ProjectRoot "_package_rename_backup\$Timestamp"
New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null

$FilesToBackup = @(
    "android\app\build.gradle.kts",
    "android\app\google-services.json",
    "lib\firebase_options.dart",
    "android\app\src\main\kotlin\com\example\swapstash\MainActivity.kt"
)

foreach ($RelativePath in $FilesToBackup) {
    $Source = Join-Path $ProjectRoot $RelativePath

    if (Test-Path $Source) {
        $Destination = Join-Path $BackupRoot $RelativePath
        $DestinationDirectory = Split-Path -Parent $Destination
        New-Item -ItemType Directory -Path $DestinationDirectory -Force |
            Out-Null
        Copy-Item $Source $Destination -Force
    }
}

$PayloadFiles = @(
    "android\app\build.gradle.kts",
    "android\app\google-services.json",
    "lib\firebase_options.dart",
    "android\app\src\main\kotlin\net\swapstash\app\MainActivity.kt"
)

foreach ($RelativePath in $PayloadFiles) {
    $Source = Join-Path $PayloadRoot $RelativePath
    $Destination = Join-Path $ProjectRoot $RelativePath

    Require-Path $Source "datoteka paketa"

    $DestinationDirectory = Split-Path -Parent $Destination
    New-Item -ItemType Directory -Path $DestinationDirectory -Force |
        Out-Null
    Copy-Item $Source $Destination -Force
}

$OldMainActivity = Join-Path $ProjectRoot `
    "android\app\src\main\kotlin\com\example\swapstash\MainActivity.kt"

if (Test-Path $OldMainActivity) {
    Remove-Item $OldMainActivity -Force
}

# Remove empty legacy folders, from deepest to shallowest.
$LegacyFolders = @(
    "android\app\src\main\kotlin\com\example\swapstash",
    "android\app\src\main\kotlin\com\example",
    "android\app\src\main\kotlin\com"
)

foreach ($RelativeFolder in $LegacyFolders) {
    $Folder = Join-Path $ProjectRoot $RelativeFolder

    if (Test-Path $Folder) {
        $RemainingItems = Get-ChildItem $Folder -Force

        if ($RemainingItems.Count -eq 0) {
            Remove-Item $Folder -Force
        }
    }
}

$BuildGradle = Get-Content `
    (Join-Path $ProjectRoot "android\app\build.gradle.kts") -Raw
$FirebaseOptions = Get-Content `
    (Join-Path $ProjectRoot "lib\firebase_options.dart") -Raw
$MainActivity = Get-Content `
    (Join-Path $ProjectRoot `
        "android\app\src\main\kotlin\net\swapstash\app\MainActivity.kt") -Raw
$GoogleServices = Get-Content `
    (Join-Path $ProjectRoot "android\app\google-services.json") -Raw

if ($BuildGradle -notmatch 'namespace\s*=\s*"net\.swapstash\.app"') {
    throw "Preverjanje namespace ni uspelo."
}

if ($BuildGradle -notmatch 'applicationId\s*=\s*"net\.swapstash\.app"') {
    throw "Preverjanje applicationId ni uspelo."
}

if ($MainActivity -notmatch 'package\s+net\.swapstash\.app') {
    throw "Preverjanje MainActivity ni uspelo."
}

if (
    $FirebaseOptions -notmatch
    '1:216798493473:android:62ff8893c397ae3d24dc60'
) {
    throw "Preverjanje Firebase App ID ni uspelo."
}

if ($GoogleServices -notmatch '"package_name":\s*"net\.swapstash\.app"') {
    throw "Preverjanje google-services.json ni uspelo."
}

Write-Host ""
Write-Host "Sprememba package imena je uspešno izvedena." -ForegroundColor Green
Write-Host "Novo Android package ime: net.swapstash.app"
Write-Host "Varnostna kopija: $BackupRoot"
Write-Host ""
Write-Host "Nato zaženi:"
Write-Host "  flutter clean"
Write-Host "  flutter pub get"
Write-Host "  flutter analyze"
Write-Host "  flutter run"
Write-Host ""
Write-Host "Pri flutter run izberi Android emulator 1 ali 2."
