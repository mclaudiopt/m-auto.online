# utils/remove_news_taskbar.ps1 - Remover News and Interests da Taskbar
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$e = [char]27

Write-Host ""
Write-Host "  ${e}[1;97mRemover News and Interests da Taskbar${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A remover..." -NoNewline

try {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds"

    # Criar a chave se nao existir
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }

    # 0 = Disabled, 1 = Enabled
    Set-ItemProperty -Path $regPath -Name "ShellFeedsTaskbarViewMode" -Value 0 -ErrorAction Stop

    # Tambem desativar no News and Interests
    $regPath2 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    if (-not (Test-Path $regPath2)) {
        New-Item -Path $regPath2 -Force | Out-Null
    }

    Set-ItemProperty -Path $regPath2 -Name "NewsFeedsTaskbarMode" -Value 0 -ErrorAction Stop

    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
} catch {
    Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
    Write-Host "  ${e}[38;2;148;163;184m    $_${e}[0m"
}

Write-Host ""
Read-Host "  Pressione ENTER para voltar"
