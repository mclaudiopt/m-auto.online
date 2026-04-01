# utils/remove_search_taskbar.ps1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$e = [char]27

Write-Host ""
Write-Host "  ${e}[1;97mRemover Search do Taskbar${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A remover..." -NoNewline

try {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    Set-ItemProperty -Path $regPath -Name "SearchboxTaskbarMode" -Value 0 -ErrorAction Stop
    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
} catch {
    Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
    Write-Host "  ${e}[38;2;239;68;68m✖${e}[0m  Erro: $($_.Exception.Message)"
}

Write-Host ""
Read-Host "  Pressione ENTER para voltar"
