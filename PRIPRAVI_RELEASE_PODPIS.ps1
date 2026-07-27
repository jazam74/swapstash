$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$PayloadRoot = Join-Path $ProjectRoot "_release_signing_payload"

function Require-Path {
    param(
        [string]$Path,
        [string]$Description
    )

    if (-not (Test-Path $Path)) {
        throw "Manjka $Description`: $Path"
    }
}

function Convert-SecureStringToPlainText {
    param([Security.SecureString]$SecureValue)

    $Pointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR(
        $SecureValue
    )

    try {
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR(
            $Pointer
        )
    }
    finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($Pointer)
    }
}

function Find-KeyTool {
    $Command = Get-Command "keytool.exe" -ErrorAction SilentlyContinue

    if ($Command) {
        return $Command.Source
    }

    $Candidates = New-Object System.Collections.Generic.List[string]

    if (-not [string]::IsNullOrWhiteSpace($env:JAVA_HOME)) {
        $Candidates.Add(
            (Join-Path $env:JAVA_HOME "bin\keytool.exe")
        )
    }

    if (-not [string]::IsNullOrWhiteSpace($env:LOCALAPPDATA)) {
        $Candidates.Add(
            (Join-Path $env:LOCALAPPDATA `
                "Programs\Android Studio\jbr\bin\keytool.exe")
        )
    }

    $Candidates.Add(
        "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
    )
    $Candidates.Add(
        "C:\Program Files\Android\Android Studio\jre\bin\keytool.exe"
    )

    foreach ($Candidate in $Candidates) {
        if (Test-Path $Candidate) {
            return $Candidate
        }
    }

    throw (
        "keytool.exe ni bil najden. Preveri namestitev Android Studio " +
        "ali nastavi JAVA_HOME."
    )
}

Require-Path (Join-Path $ProjectRoot "pubspec.yaml") "pubspec.yaml"
Require-Path (Join-Path $ProjectRoot "android\app\build.gradle.kts") `
    "android/app/build.gradle.kts"
Require-Path (Join-Path $PayloadRoot "android\app\build.gradle.kts") `
    "release Gradle konfiguracija"

$CurrentGradle = Get-Content `
    (Join-Path $ProjectRoot "android\app\build.gradle.kts") -Raw

if ($CurrentGradle -notmatch 'applicationId\s*=\s*"net\.swapstash\.app"') {
    throw "Projekt nima pricakovanega applicationId net.swapstash.app."
}

$KeyDirectory = Join-Path $env:USERPROFILE ".swapstash"
$KeyStorePath = Join-Path $KeyDirectory "swapstash-upload-keystore.jks"
$KeyPropertiesPath = Join-Path $ProjectRoot "android\key.properties"
$KeyAlias = "swapstash-upload"

if (Test-Path $KeyStorePath) {
    Write-Host ""
    Write-Host "Upload kljuc ze obstaja:" -ForegroundColor Yellow
    Write-Host $KeyStorePath
    Write-Host ""
    throw "Obstojeci kljuc ni bil prepisan."
}

if (Test-Path $KeyPropertiesPath) {
    Write-Host ""
    Write-Host "android/key.properties ze obstaja:" `
        -ForegroundColor Yellow
    Write-Host $KeyPropertiesPath
    Write-Host ""
    throw "Obstojeca konfiguracija ni bila prepisana."
}

Write-Host ""
Write-Host "Ustvarjanje trajnega SwapStash upload kljuca" `
    -ForegroundColor Cyan
Write-Host ""
Write-Host "Geslo shrani v upravljalnik gesel."
Write-Host "Ne poslji ga po e-posti ali v ta pogovor."
Write-Host ""

do {
    $SecurePassword = Read-Host `
        "Vnesi novo geslo za upload kljuc (najmanj 8 znakov)" `
        -AsSecureString
    $Password = Convert-SecureStringToPlainText $SecurePassword

    if ($Password.Length -lt 8) {
        Write-Host "Geslo mora imeti najmanj 8 znakov." `
            -ForegroundColor Yellow
    }
} while ($Password.Length -lt 8)

$SecureConfirmation = Read-Host "Ponovi geslo" -AsSecureString
$Confirmation = Convert-SecureStringToPlainText $SecureConfirmation

if ($Password -cne $Confirmation) {
    throw "Gesli se ne ujemata. Nic ni bilo spremenjeno."
}

$KeyTool = Find-KeyTool
New-Item -ItemType Directory -Path $KeyDirectory -Force | Out-Null

$Arguments = @(
    "-genkeypair",
    "-v",
    "-keystore", $KeyStorePath,
    "-storetype", "JKS",
    "-keyalg", "RSA",
    "-keysize", "2048",
    "-validity", "10000",
    "-alias", $KeyAlias,
    "-storepass", $Password,
    "-keypass", $Password,
    "-dname", "CN=SwapStash, OU=Mobile, O=SwapStash, C=SI"
)

& $KeyTool @Arguments

if ($LASTEXITCODE -ne 0 -or -not (Test-Path $KeyStorePath)) {
    throw "Ustvarjanje upload kljuca ni uspelo."
}

$ForwardSlashKeyStorePath = $KeyStorePath.Replace("\", "/")

$KeyProperties = @"
storePassword=$Password
keyPassword=$Password
keyAlias=$KeyAlias
storeFile=$ForwardSlashKeyStorePath
"@

Set-Content `
    -Path $KeyPropertiesPath `
    -Value $KeyProperties `
    -Encoding UTF8

$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$BackupRoot = Join-Path `
    $ProjectRoot `
    "_release_signing_backup\$Timestamp"

New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null

Copy-Item `
    (Join-Path $ProjectRoot "android\app\build.gradle.kts") `
    (Join-Path $BackupRoot "build.gradle.kts") `
    -Force

Copy-Item `
    (Join-Path $PayloadRoot "android\app\build.gradle.kts") `
    (Join-Path $ProjectRoot "android\app\build.gradle.kts") `
    -Force

$GitIgnorePath = Join-Path $ProjectRoot ".gitignore"

if (-not (Test-Path $GitIgnorePath)) {
    New-Item -ItemType File -Path $GitIgnorePath -Force | Out-Null
}

$GitIgnoreContent = Get-Content $GitIgnorePath -Raw

$IgnoreEntries = @(
    "",
    "# SwapStash Android release signing",
    "android/key.properties",
    "*.jks",
    "*.keystore"
)

foreach ($Entry in $IgnoreEntries) {
    if (
        $Entry -and
        $GitIgnoreContent -notmatch [Regex]::Escape($Entry)
    ) {
        Add-Content -Path $GitIgnorePath -Value $Entry
    }
}

$InstalledGradle = Get-Content `
    (Join-Path $ProjectRoot "android\app\build.gradle.kts") -Raw

if ($InstalledGradle -notmatch 'signingConfigs') {
    throw "Release signing konfiguracija ni bila namescena."
}

if ($InstalledGradle -notmatch 'getByName\("release"\)') {
    throw "Release build ne uporablja release podpisa."
}

Write-Host ""
Write-Host "Release podpis je uspesno pripravljen." `
    -ForegroundColor Green
Write-Host ""
Write-Host "Upload kljuc:"
Write-Host "  $KeyStorePath"
Write-Host ""
Write-Host "Konfiguracija:"
Write-Host "  $KeyPropertiesPath"
Write-Host ""
Write-Host "Varnostna kopija Gradle datoteke:"
Write-Host "  $BackupRoot"
Write-Host ""
Write-Host "OBVEZNO:"
Write-Host "1. Geslo shrani v upravljalnik gesel."
Write-Host "2. Datoteko .jks kopiraj na vsaj eno varno rezervno lokacijo."
Write-Host "3. Datotek .jks in key.properties ne nalagaj v Git ali v pogovor."
Write-Host ""
Write-Host "Za izdelavo AAB nato zazeni:"
Write-Host "  .\ZGRADI_RELEASE_AAB.ps1"
