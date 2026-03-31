# utils/remove_cortana.ps1 - Desabilitar Cortana
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$e = [char]27

Write-Host ""
Write-Host "  ${e}[1;97mDesabilitar Cortana${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A desabilitar..." -NoNewline

try {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"

    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }

    # 0 = Desabilitar, 1 = Habilitar
    Set-ItemProperty -Path $regPath -Name "CortanaEnabled" -Value 0 -ErrorAction Stop

    # Tambem no Local Machine (requer admin)
    $regPath2 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    if (Test-Path $regPath2) {
        Set-ItemProperty -Path $regPath2 -Name "AllowCortana" -Value 0 -ErrorAction SilentlyContinue
    }

    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
} catch {
    Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
    Write-Host "  ${e}[38;2;148;163;184m    $_${e}[0m"
}

Write-Host ""
Read-Host "  Pressione ENTER para voltar"
