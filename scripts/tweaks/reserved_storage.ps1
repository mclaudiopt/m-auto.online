# tweaks/reserved_storage.ps1 - Desativar Reserved Storage
$e = [char]27

Write-Host ""
Write-Host "  ${e}[1;97mDesativar Reserved Storage${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

Write-Host "  ${e}[38;2;100;149;237m>${e}[0m  Executando: DISM.exe /Online /Set-ReservedStorageState /State:Disabled"
Write-Host ""

try {
    $output = & cmd /c "DISM.exe /Online /Set-ReservedStorageState /State:Disabled 2>&1"
    if ($output -match "sucesso|success|completed" -or $LASTEXITCODE -eq 0) {
        Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m]  Reserved Storage desativado"
        Write-Host "  ${e}[38;2;148;163;184m  Isto pode libertar alguns GB de espaço em disco.${e}[0m"
    } else {
        Write-Host "  ${e}[38;2;250;204;21m[!]   Ja pode estar desativado ou requer atualizacao de sistema${e}[0m"
    }
} catch {
    Write-Host "  ${e}[38;2;239;68;68m[X]   Erro ao executar DISM${e}[0m"
    Write-Host "  ${e}[38;2;148;163;184m    $_${e}[0m"
}

Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m>> Aviso:${e}[0m]"
Write-Host "  ${e}[38;2;148;163;184m  Esta alteracao e permanente. Recomenda-se reiniciar.${e}[0m"
Write-Host ""
Wait-Key
