# system/dns_cloudflare.ps1 - Mudar DNS para Cloudflare
$e = [char]27

Write-Host ""
Write-Host "  ${e}[1;97mAlterar DNS para Cloudflare${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

# DNS Cloudflare
$primary = "1.1.1.1"
$secondary = "1.0.0.1"

# Obter adaptador de rede activo
$nic = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1

if (-not $nic) {
    Write-Host "  ${e}[38;2;239;68;68m[X]   Nenhuma interface de rede activa encontrada.${e}[0m"
    Write-Host ""
    Wait-Key
    return
}

$nicName = $nic.Name
Write-Host "  ${e}[38;2;100;149;237m>> Adaptador: $nicName${e}[0m"
Write-Host ""

# Mostrar DNS actual
$dnsAtual = Get-DnsClientServerAddress -InterfaceAlias $nicName -AddressFamily IPv4 -ErrorAction SilentlyContinue
if ($dnsAtual -and $dnsAtual.ServerAddresses) {
    Write-Host "  DNS Actual:"
    $dnsAtual.ServerAddresses | ForEach-Object { Write-Host "    ${e}[38;2;148;163;184m$_${e}[0m" }
} else {
    Write-Host "  ${e}[38;2;148;163;184m  (nenhum DNS configurado)${e}[0m"
}

Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m>> Aplicando DNS Cloudflare...${e}[0m"
Write-Host ""

try {
    Set-DnsClientServerAddress -InterfaceAlias $nicName `
        -ServerAddresses $primary, $secondary `
        -Validate `
        -ErrorAction Stop
    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m]  DNS alterado para:"
    Write-Host "    ${e}[38;2;100;149;237m$primary${e}[0m]  (Cloudflare)"
    Write-Host "    ${e}[38;2;100;149;237m$secondary${e}[0m]  (Cloudflare secundario)"
} catch {
    Write-Host "  ${e}[38;2;239;68;68m[X]   Erro ao alterar DNS${e}[0m"
    Write-Host "  ${e}[38;2;148;163;184m    $_${e}[0m"
}

Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m>> Teste de conectividade${e}[0m"
Write-Host ""

$test = Test-Connection -ComputerName 1.1.1.1 -Count 1 -Quiet -ErrorAction SilentlyContinue
if ($test) {
    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m]  DNS respondendo correctamente"
} else {
    Write-Host "  ${e}[38;2;250;204;21m[!]   DNS pode nao estar respondendo${e}[0m"
}

Write-Host ""
Wait-Key
