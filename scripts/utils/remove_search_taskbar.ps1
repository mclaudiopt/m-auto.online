# utils/remove_search_taskbar.ps1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$e = [char]27

Write-Host ""
Write-Host "  ${e}[1;97mRemover Search do Taskbar${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A aplicar no registry..." -NoNewline

try {
    # Windows 10 e 11 - ocultar search box/button
    $searchPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
    if (-not (Test-Path $searchPath)) {
        New-Item -Path $searchPath -Force | Out-Null
    }
    Set-ItemProperty -Path $searchPath -Name "SearchboxTaskbarMode" -Value 0 -ErrorAction Stop

    # Windows 11 - desativar botao de pesquisa adicional
    $taskbarPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Set-ItemProperty -Path $taskbarPath -Name "ShowTaskViewButton" -Value 0 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $taskbarPath -Name "TaskbarDa" -Value 0 -ErrorAction SilentlyContinue

    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"

    # Reiniciar Explorer para aplicar
    Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A reiniciar Explorer..." -NoNewline
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 1500
    Start-Process explorer
    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"

} catch {
    Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
    Write-Host "  ${e}[38;2;239;68;68m✖${e}[0m  Erro: $($_.Exception.Message)"
}

Write-Host ""
Read-Host "  Pressione ENTER para voltar"
