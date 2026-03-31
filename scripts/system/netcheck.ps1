# system/netcheck.ps1 - Teste de Internet + Speedtest
$e = [char]27

function Test-Ping($host) {
    try {
        $ping = Test-Connection -ComputerName $host -Count 1 -Quiet -ErrorAction Stop
        return $ping
    } catch {
        return $false
    }
}

function Measure-Speed($url, $name) {
    Write-Host "  ${e}[38;2;100;149;237m>${e}[0m  $name..." -NoNewline
    $start = Get-Date
    try {
        $web = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
        $elapsed = (Get-Date) - $start
        $size = $web.RawContentLength
        $speed = if ($elapsed.TotalSeconds -gt 0) { [math]::Round(($size / 1MB) / $elapsed.TotalSeconds, 2) } else { 0 }
        Write-Host "  ${e}[38;2;34;197;94m${speed} MB/s${e}[0m"
        return $speed
    } catch {
        Write-Host "  ${e}[38;2;239;68;68m FALHOU${e}[0m"
        return 0
    }
}

Write-Host ""
Write-Host "  ${e}[1;97mTeste de Conectividade & Velocidade${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

# Teste basico
Write-Host "  ${e}[38;2;100;149;237m>> Teste Basico${e}[0m"
Write-Host ""

$google = Test-Ping "8.8.8.8"
$status = if ($google) { "${e}[38;2;34;197;94m[OK]${e}[0m" } else { "${e}[38;2;239;68;68m[FALHOU]${e}[0m" }
Write-Host "  Google DNS (8.8.8.8)              $status"

$cloudflare = Test-Ping "1.1.1.1"
$status = if ($cloudflare) { "${e}[38;2;34;197;94m[OK]${e}[0m" } else { "${e}[38;2;239;68;68m[FALHOU]${e}[0m" }
Write-Host "  Cloudflare DNS (1.1.1.1)          $status"

Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m>> Teste de Velocidade (Download)${e}[0m"
Write-Host ""

$speeds = @()
$speeds += Measure-Speed "https://www.google.com" "Google (HTML)"
$speeds += Measure-Speed "https://www.cloudflare.com" "Cloudflare (HTML)"
$speeds += Measure-Speed "https://speed.cloudflare.com/__down?bytes=10000000" "Cloudflare 10MB"

$avg = $speeds | Measure-Object -Average
Write-Host ""
Write-Host "  Velocidade media:                 ${e}[38;2;100;149;237m$([math]::Round($avg.Average, 2)) MB/s${e}[0m"

Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m>> Info da Ligacao${e}[0m"
Write-Host ""

try {
    $gw = Get-NetRoute -DestinationPrefix 0.0.0.0/0 -ErrorAction SilentlyContinue | Select-Object -First 1
    $ip = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.InterfaceAlias -notmatch "Loopback" } | Select-Object -First 1
    $dns = Get-DnsClientServerAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Select-Object -First 1
    
    Write-Host "  IP Privado:                       ${e}[97m$($ip.IPAddress)${e}[0m"
    Write-Host "  Gateway:                          ${e}[97m$($gw.NextHop)${e}[0m"
    Write-Host "  DNS Primario:                     ${e}[97m$($dns.ServerAddresses[0])${e}[0m"
    Write-Host "  DNS Secundario:                   ${e}[97m$($dns.ServerAddresses[1])${e}[0m"
} catch {
    Write-Host "  ${e}[38;2;250;204;21m[!]   Nao foi possivel obter info da ligacao${e}[0m"
}

Write-Host ""
Wait-Key
