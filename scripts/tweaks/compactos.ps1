# tweaks/compactos.ps1 - CompactOS
$e = [char]27

Write-Host ""
Write-Host "  ${e}[1;97mCompactOS - Comprimir ficheiros do sistema${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

Write-Host "  ${e}[38;2;100;149;237m>${e}[0m  Executando: compact.exe /CompactOS:always"
Write-Host "  ${e}[38;2;148;163;184m  Isto pode demorar alguns minutos...${e}[0m"
Write-Host ""

try {
    $start = Get-Date
    & cmd /c "compact.exe /CompactOS:always" 2>&1 | ForEach-Object {
        if ($_ -match "^\d+") { Write-Host "  ${e}[38;2;100;149;237m$_${e}[0m" }
    }
    $elapsed = (Get-Date) - $start
    Write-Host ""
    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m]  CompactOS completado em $([math]::Round($elapsed.TotalMinutes, 1)) minutos"
    Write-Host "  ${e}[38;2;148;163;184m  Espaço em disco pode ter sido libertado.${e}[0m"
} catch {
    Write-Host "  ${e}[38;2;239;68;68m[X]   Erro ao executar CompactOS${e}[0m"
    Write-Host "  ${e}[38;2;148;163;184m    $_${e}[0m"
}

Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m>> Nota:${e}[0m]"
Write-Host "  ${e}[38;2;148;163;184m  CompactOS usa XPRESS ou LZ4 para comprimir o SO.${e}[0m"
Write-Host ""
Wait-Key
