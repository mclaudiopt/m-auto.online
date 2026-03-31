# prep/firewall_off.ps1 - Desativar Firewall e apagar regras
$e = [char]27

Write-Host ""
Write-Host "  ${e}[1;97mFirewall OFF + Limpar Regras${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

Write-Host "  ${e}[38;2;148;163;184m·${e}[0m  A desativar Firewall..." -NoNewline

try {
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False -ErrorAction Stop
    $rules = Get-NetFirewallRule -ErrorAction SilentlyContinue
    $count = if ($rules) { $rules.Count } else { 0 }
    if ($count -gt 0) {
        Remove-NetFirewallRule -All -ErrorAction SilentlyContinue
        Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m ($count regras apagadas)"
    } else {
        Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m (firewall ja limpa)"
    }
} catch {
    Write-Host "  ${e}[38;2;239;68;68m[FALHOU]${e}[0m"
    Write-Host "  ${e}[38;2;148;163;184m    $_${e}[0m"
}

Write-Host ""
Read-Host "  Pressione ENTER para voltar"
