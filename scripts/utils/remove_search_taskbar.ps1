# utils/remove_search_taskbar.ps1 - Remover Search Box da Taskbar
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$e = [char]27

Write-Host ""
Write-Host "  ${e}[1;97mRemover Search Box da Taskbar${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A remover..." -NoNewline

try {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"

    # Criar a chave se nao existir
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }

    # 0 = Hide, 1 = Show as icon, 2 = Show as box
    Set-ItemProperty -Path $regPath -Name "SearchboxTaskbarMode" -Value 0 -ErrorAction Stop

    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
} catch {
    Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
    Write-Host "  ${e}[38;2;148;163;184m    $_${e}[0m"
}

Write-Host ""
Read-Host "  Pressione ENTER para voltar"
