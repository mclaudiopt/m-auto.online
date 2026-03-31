# utils/remove_onedrive_visual.ps1 - Remover OneDrive do Visual
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$e = [char]27

Write-Host ""
Write-Host "  ${e}[1;97mRemover OneDrive do Visual${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A remover ícone..." -NoNewline

try {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }

    # Ocultar OneDrive do File Explorer
    Set-ItemProperty -Path $regPath -Name "ShowSyncProviderNotifications" -Value 0 -ErrorAction Stop

    # Remover OneDrive do Sidebar (Quick Access)
    $regPath2 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2"
    Get-Item $regPath2 -ErrorAction SilentlyContinue |
        Get-ChildItem -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -like "*OneDrive*" } |
        Remove-Item -ErrorAction SilentlyContinue

    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
} catch {
    Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
    Write-Host "  ${e}[38;2;148;163;184m    $_${e}[0m"
}

Write-Host ""
Read-Host "  Pressione ENTER para voltar"
