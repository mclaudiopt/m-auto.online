# tools/install_7zip.ps1
$ESC = [char]27
$URL = "https://www.7-zip.org/a/7z2600-x64.exe"
$TMP = "$env:TEMP\7z_setup.exe"

Write-Host ""
Write-Host "  $ESC[1;97mInstalar 7-Zip$ESC[0m"
Write-Host "  $ESC[38;2;50;60;80m" + ("─" * 54) + "$ESC[0m"
Write-Host ""

# Verificar se já está instalado
$installed = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* `
    -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "*7-Zip*" }

if ($installed) {
    Write-Host "  $ESC[38;2;34;197;94m✔$ESC[0m  7-Zip já está instalado: $($installed.DisplayVersion)"
    Write-Host ""
    Invoke-Pause
    return
}

Write-Host "  $ESC[38;2;148;163;184m·$ESC[0m  A transferir 7-Zip..." -NoNewline
try {
    Invoke-WebRequest -Uri $URL -OutFile $TMP -UseBasicParsing
    Write-Host "  $ESC[38;2;34;197;94mOK$ESC[0m"
} catch {
    Write-Host ""
    Write-Host "  $ESC[38;2;239;68;68m✖$ESC[0m  Erro ao transferir: $($_.Exception.Message)"
    Invoke-Pause
    return
}

Write-Host "  $ESC[38;2;148;163;184m·$ESC[0m  A instalar..." -NoNewline
Start-Process -FilePath $TMP -ArgumentList "/S" -Wait
Write-Host "  $ESC[38;2;34;197;94mOK$ESC[0m"

Remove-Item $TMP -Force -ErrorAction SilentlyContinue
Write-Host ""
Write-Host "  $ESC[38;2;34;197;94m✔$ESC[0m  7-Zip instalado com sucesso."
Write-Host ""
Invoke-Pause
