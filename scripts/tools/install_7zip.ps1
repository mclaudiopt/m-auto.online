# tools/install_7zip.ps1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null
$e = [char]27

$arch = $env:PROCESSOR_ARCHITECTURE
$exe  = if ($arch -eq "ARM64") { "7z2409-arm64.exe" } elseif ($arch -eq "x86") { "7z2409.exe" } else { "7z2409-x64.exe" }
$URL  = "https://www.7-zip.org/a/$exe"
$DL_DIR = "C:\M-auto\Temp"
if (-not (Test-Path $DL_DIR)) { New-Item -ItemType Directory -Path $DL_DIR -Force | Out-Null }
$TMP = "$DL_DIR\7z_setup.exe"

Write-Host ""
Write-Host "  ${e}[1;97mInstalar 7-Zip${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

$installed = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" `
    -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "*7-Zip*" }

if ($installed) {
    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m  7-Zip ja esta instalado: $($installed.DisplayVersion)"
    Write-Host ""
    Read-Host "  Pressione ENTER para voltar"
    return
}

Write-Host "  ${e}[38;2;100;149;237m[..]${e}[0m  A transferir 7-Zip ($exe)..." -NoNewline
try {
    Invoke-WebRequest -Uri $URL -OutFile $TMP -UseBasicParsing -ErrorAction Stop -TimeoutSec 60
    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
} catch {
    Write-Host ""
    Write-Host "  ${e}[38;2;239;68;68m[X]${e}[0m   Erro ao transferir: $($_.Exception.Message)"
    Read-Host "  Pressione ENTER para voltar"
    return
}

Write-Host "  ${e}[38;2;100;149;237m[..]${e}[0m  A instalar..." -NoNewline
Start-Process -FilePath $TMP -ArgumentList "/S" -Wait
Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"

Remove-Item $TMP -Force -ErrorAction SilentlyContinue
Write-Host ""
Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m  7-Zip instalado com sucesso."
Write-Host ""
Read-Host "  Pressione ENTER para voltar"
