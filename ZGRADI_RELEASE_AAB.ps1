$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ProjectRoot

$KeyPropertiesPath = Join-Path $ProjectRoot "android\key.properties"

if (-not (Test-Path $KeyPropertiesPath)) {
    throw "Manjka android/key.properties. Najprej zazeni PRIPRAVI_RELEASE_PODPIS.ps1."
}

Write-Host ""
Write-Host "1/4 Flutter clean" -ForegroundColor Cyan
flutter clean
if ($LASTEXITCODE -ne 0) {
    throw "flutter clean ni uspel."
}

Write-Host ""
Write-Host "2/4 Flutter pub get" -ForegroundColor Cyan
flutter pub get
if ($LASTEXITCODE -ne 0) {
    throw "flutter pub get ni uspel."
}

Write-Host ""
Write-Host "3/4 Flutter analyze" -ForegroundColor Cyan
flutter analyze
if ($LASTEXITCODE -ne 0) {
    throw "flutter analyze je nasel napake."
}

Write-Host ""
Write-Host "4/4 Gradnja podpisanega Android App Bundle" `
    -ForegroundColor Cyan
flutter build appbundle --release
if ($LASTEXITCODE -ne 0) {
    throw "Gradnja release AAB ni uspela."
}

$BundlePath = Join-Path `
    $ProjectRoot `
    "build\app\outputs\bundle\release\app-release.aab"

if (-not (Test-Path $BundlePath)) {
    throw "AAB datoteka po gradnji ni bila najdena."
}

$Bundle = Get-Item $BundlePath
$Hash = Get-FileHash $BundlePath -Algorithm SHA256

Write-Host ""
Write-Host "Podpisani AAB je uspesno ustvarjen." `
    -ForegroundColor Green
Write-Host ""
Write-Host "Datoteka:"
Write-Host "  $BundlePath"
Write-Host ""
Write-Host "Velikost:"
Write-Host ("  {0:N2} MB" -f ($Bundle.Length / 1MB))
Write-Host ""
Write-Host "SHA-256:"
Write-Host "  $($Hash.Hash)"
Write-Host ""
Write-Host "Pred nalaganjem v Google Play se uredi se koncna ikona aplikacije."
