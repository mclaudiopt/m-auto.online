# tools/install_fdm.ps1 - Free Download Manager
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$e = [char]27
$URL = "https://dn.freedownloadmanager.org/6/fdm_x64_setup.exe"
$TMP = "$env:TEMP\fdm_setup.exe"

Write-Host ""
Write-Host "  ${e}[1;97mInstalar Free Download Manager${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

# Verificar se já está instalado
$installed = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* `
    -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "*Free Download Manager*" }

if ($installed) {
    Write-Host "  ${e}[38;2;34;197;94m✔${e}[0m  Free Download Manager já está instalado: $($installed.DisplayVersion)"
    Write-Host ""
    Read-Host "  Pressione ENTER para voltar"
    return
}

Write-Host "  ${e}[38;2;148;163;184m·${e}[0m  A transferir Free Download Manager..." -NoNewline
try {
    Invoke-WebRequest -Uri $URL -OutFile $TMP -UseBasicParsing -ErrorAction Stop -TimeoutSec 60
    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
} catch {
    Write-Host ""
    Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m  Erro ao transferir: $($_.Exception.Message)"
    Write-Host ""
    Read-Host "  Pressione ENTER para voltar"
    return
}

Write-Host "  ${e}[38;2;148;163;184m·${e}[0m  A instalar..." -NoNewline
try {
    Start-Process -FilePath $TMP -ArgumentList "/S" -Wait -ErrorAction Stop
    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
} catch {
    Write-Host ""
    Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m  Erro na instalacao: $($_.Exception.Message)"
    Write-Host ""
    Read-Host "  Pressione ENTER para voltar"
    return
}

Remove-Item $TMP -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "  ${e}[38;2;34;197;94m✔${e}[0m  Free Download Manager instalado com sucesso."
Write-Host ""
Read-Host "  Pressione ENTER para voltar"
