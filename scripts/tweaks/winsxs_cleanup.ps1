# tweaks/winsxs_cleanup.ps1 - WinSxS ResetBase + System Cleanup
$e = [char]27

Write-Host ""
Write-Host "  ${e}[1;97mLimpeza WinSxS + StartComponentCleanup${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

Write-Host "  ${e}[38;2;100;149;237m>${e}[0m  Executando: Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase"
Write-Host "  ${e}[38;2;148;163;184m  Isto pode demorar 5-15 minutos...${e}[0m"
Write-Host ""

try {
    $start = Get-Date
    $output = & cmd /c "Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase 2>&1"
    
    # Mostrar output relevante
    $output | ForEach-Object {
        if ($_ -match "%" -or $_ -match "Cleanup" -or $_ -match "sucesso|success") {
            Write-Host "  ${e}[38;2;100;149;237m$_${e}[0m"
        }
    }
    
    $elapsed = (Get-Date) - $start
    Write-Host ""
    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m]  WinSxS cleanup completado em $([math]::Round($elapsed.TotalMinutes, 1)) minutos"
    Write-Host "  ${e}[38;2;148;163;184m  Bastantes GB podem ter sido libertados.${e}[0m"
} catch {
    Write-Host "  ${e}[38;2;239;68;68m[X]   Erro ao executar DISM cleanup${e}[0m"
    Write-Host "  ${e}[38;2;148;163;184m    $_${e}[0m"
}

Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m>> Nota:${e}[0m]"
Write-Host "  ${e}[38;2;148;163;184m  ResetBase remove os backups de componentes de SO anteriores.${e}[0m"
Write-Host ""
Wait-Key
