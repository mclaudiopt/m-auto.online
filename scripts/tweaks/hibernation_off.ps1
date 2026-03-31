# tweaks/hibernation_off.ps1 - Desativar Hibernacao
$e = [char]27

Write-Host ""
Write-Host "  ${e}[1;97mDesativar Hibernacao${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

Write-Host "  ${e}[38;2;100;149;237m>${e}[0m  Executando: powercfg -h off"
Write-Host ""

try {
    & cmd /c "powercfg -h off" 2>&1 | Out-Null
    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m]  Hibernacao desativada"
    Write-Host "  ${e}[38;2;148;163;184m  Ficheiro hiberfil.sys sera deletado (libertando GB).${e}[0m"
} catch {
    Write-Host "  ${e}[38;2;239;68;68m[X]   Erro ao desativar hibernacao${e}[0m"
    Write-Host "  ${e}[38;2;148;163;184m    $_${e}[0m"
}

Write-Host ""

# Verificar estado
try {
    $status = & cmd /c "powercfg /a" 2>&1 | Select-String -Pattern "Hibernation" | Select-Object -First 1
    if ($status -match "not available|desativada|disabled") {
        Write-Host "  ${e}[38;2;34;197;94m[VERIFICADO]${e}[0m]  Hibernacao nao disponivel"
    } else {
        Write-Host "  ${e}[38;2;250;204;21m[!]   Hibernacao pode ainda estar activa${e}[0m"
    }
} catch {}

Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m>> Nota:${e}[0m]"
Write-Host "  ${e}[38;2;148;163;184m  Se usas Sleep/Suspend, hibernacao nao e necessaria.${e}[0m"
Write-Host ""
Wait-Key
