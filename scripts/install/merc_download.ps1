# install/merc_download.ps1 - Mercedes Pack download via aria2c
# Called via Run-Sub from m-auto.ps1

$LINKS_JSON = "https://m-auto.online/scripts/data/merc_links.json"
$ARIA        = "$env:TEMP\aria2c.exe"
$RPC         = "http://localhost:6801/jsonrpc"
$TOK         = "mauto2026"
$DEST_ROOT   = "C:\M-AUTO\Temp"
$e           = [char]27

function Write-Step($m) { Write-Host "  ${e}[38;2;100;149;237m[..]${e}[0m  $m" }
function Write-OK($m)   { Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m  $m" }
function Write-Err($m)  { Write-Host "  ${e}[38;2;239;68;68m[X]${e}[0m   $m" }
function Write-Warn($m) { Write-Host "  ${e}[38;2;250;204;21m[!]${e}[0m   $m" }
function Write-Sep      { Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m" }

function Ensure-Aria2c {
    if (Test-Path $ARIA) { return $true }
    Write-Step "A instalar aria2c..."
    try {
        $zip = "$env:TEMP\aria2.zip"
        Invoke-WebRequest "https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0-win-64bit-build1.zip" -OutFile $zip -UseBasicParsing
        Expand-Archive $zip -DestinationPath "$env:TEMP\aria2x" -Force
        Copy-Item "$env:TEMP\aria2x\aria2-1.37.0-win-64bit-build1\aria2c.exe" $ARIA -Force
        Remove-Item $zip,"$env:TEMP\aria2x" -Recurse -Force -EA SilentlyContinue
        Write-OK "aria2c pronto."
        return $true
    } catch { Write-Err "Erro: $_"; return $false }
}

function Get-ProxyArg {
    try {
        $rp = Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -EA SilentlyContinue
        if ($rp.ProxyEnable -eq 1 -and $rp.ProxyServer) {
            Write-Warn "Proxy detetado: $($rp.ProxyServer)"
            return "--all-proxy=http://$($rp.ProxyServer)"
        }
    } catch {}
    return ""
}

function Start-Aria2cDaemon($proxyArg) {
    if ($proxyArg) {
        Get-Process -Name aria2c -EA SilentlyContinue | Stop-Process -Force -EA SilentlyContinue
        Start-Sleep -Milliseconds 400
        $proc = Start-Process -FilePath $ARIA -ArgumentList "--enable-rpc --rpc-listen-port=6801 --rpc-secret=$TOK --rpc-allow-origin-all --file-allocation=none --quiet=true --disable-ipv6=true $proxyArg" -PassThru -WindowStyle Hidden
        Start-Sleep -Milliseconds 1200
        return $proc
    }
    try {
        Invoke-RestMethod -Uri $RPC -Method Post -Body '{"jsonrpc":"2.0","id":"1","method":"aria2.getVersion","params":["token:mauto2026"]}' -ContentType "application/json" -TimeoutSec 2 -EA Stop | Out-Null
        return $null
    } catch {
        $proc = Start-Process -FilePath $ARIA -ArgumentList "--enable-rpc --rpc-listen-port=6801 --rpc-secret=$TOK --rpc-allow-origin-all --file-allocation=none --quiet=true --disable-ipv6=true" -PassThru -WindowStyle Hidden
        Start-Sleep -Milliseconds 1200
        return $proc
    }
}

function Invoke-Aria2cDownload($url, $dest) {
    # dest may include subfolders, e.g. "EPC 2018-11/EPC_1118_1of4_a1.iso"
    $destPath = Join-Path $DEST_ROOT $dest.Replace('/', '\')
    $destDir  = Split-Path $destPath -Parent
    if (-not (Test-Path $destDir)) { New-Item -ItemType Directory $destDir -Force | Out-Null }

    $barW = 36; $lastDown = 0; $lastTick = [DateTime]::Now
    $opts = @{ dir = $destDir.Replace('\','/'); out = (Split-Path $destPath -Leaf); split = "32"; "max-connection-per-server" = "32"; "min-split-size" = "4M" }
    $body = @{ jsonrpc="2.0"; id="1"; method="aria2.addUri"; params=@("token:$TOK",@("$url"),$opts) } | ConvertTo-Json -Depth 5 -Compress
    $gid  = (Invoke-RestMethod -Uri $RPC -Method Post -Body $body -ContentType "application/json").result
    do {
        Start-Sleep -Milliseconds 800
        $sb  = @{ jsonrpc="2.0"; id="1"; method="aria2.tellStatus"; params=@("token:$TOK","$gid") } | ConvertTo-Json -Depth 3 -Compress
        $s   = (Invoke-RestMethod -Uri $RPC -Method Post -Body $sb -ContentType "application/json").result
        $tot = [long]$s.totalLength; $down = [long]$s.completedLength; $cn = $s.connections
        $dt  = ([DateTime]::Now - $lastTick).TotalSeconds
        $spd = if ($dt -gt 0) { ($down - $lastDown) / $dt } else { 0 }
        $lastDown = $down; $lastTick = [DateTime]::Now
        $pct    = if ($tot -gt 0) { [int]($down/$tot*100) } else { 0 }
        $mb     = "{0:N1}" -f ($down/1MB); $totMB = "{0:N1}" -f ($tot/1MB)
        $spdStr = if ($spd -gt 1MB) { "{0:N1} MB/s" -f ($spd/1MB) } elseif ($spd -gt 1KB) { "{0:N0} KB/s" -f ($spd/1KB) } else { "-- KB/s" }
        $etaStr = if ($spd -gt 0 -and $tot -gt $down) {
            $r = ($tot-$down)/$spd
            if ($r -gt 3600) { "{0}h{1:D2}m" -f [int]($r/3600),[int](($r%3600)/60) }
            elseif ($r -gt 60) { "{0}m{1:D2}s" -f [int]($r/60),[int]($r%60) }
            else { "{0}s" -f [int]$r }
        } else { "--" }
        $filled = [int]($barW * $pct / 100)
        $bar    = ("${e}[38;2;29;155;255m" + ([string][char]9608*$filled)) + ("${e}[38;2;40;50;70m" + ([string][char]9617*($barW-$filled))) + "${e}[0m"
        Write-Host -NoNewline ([char]13 + "  [$bar] ${e}[1;97m$pct%${e}[0m  ${e}[38;2;148;163;184m$mb/$totMB MB${e}[0m  ${e}[38;2;34;197;94m$spdStr${e}[0m  ETA ${e}[38;2;250;204;21m$etaStr${e}[0m  CN:$cn   ")
    } while ($s.status -eq "active" -or $s.status -eq "waiting")
    Write-Host ""
    return $s.status
}

function Fetch-Links {
    # Returns links array, or $null on network error
    # Retries every 5 seconds if all URLs are empty (links expired, waiting for renew)
    $attempt = 0
    while ($true) {
        $attempt++
        try {
            $links = Invoke-RestMethod -Uri $LINKS_JSON -UseBasicParsing -TimeoutSec 15
        } catch {
            Write-Err "Nao foi possivel obter links: $([string]$_)"
            Write-Host ""
            Read-Host "  ENTER para voltar"
            return $null
        }

        # Check if any link has a valid (non-expired) URL
        $now   = Get-Date
        $valid = $links | Where-Object {
            $_.url -and
            $_.expires -and
            ([datetime]::Parse($_.expires)) -gt $now
        }

        if ($valid.Count -gt 0) { return $links }

        # All expired — wait for renew
        if ($attempt -eq 1) {
            Write-Host ""
            Write-Host "  ${e}[38;2;250;204;21m[!]${e}[0m   Links expirados. A aguardar renovacao pelo tecnico..."
            Write-Host "  ${e}[38;2;148;163;184m       A verificar de 5 em 5 segundos. Prima Ctrl+C para cancelar.${e}[0m"
            Write-Host ""
        }
        $t = Get-Date -Format "HH:mm:ss"
        Write-Host -NoNewline ([char]13 + "  ${e}[38;2;80;100;140m[$t]  A aguardar...${e}[0m        ")
        Start-Sleep -Seconds 5
    }
}

# ── Main loop ────────────────────────────────────────────────────────────────
while ($true) {
    Clear-Host
    Write-Host ""
    Write-Host "  ${e}[38;2;29;155;255m+------------------------------------------------------+${e}[0m"
    Write-Host "  ${e}[38;2;29;155;255m|${e}[0m  ${e}[1;97mMercedes Full Pack${e}[0m  ${e}[38;2;100;149;237mDownload${e}[0m"
    Write-Host "  ${e}[38;2;29;155;255m+------------------------------------------------------+${e}[0m"
    Write-Host ""

    # Fetch JSON (with retry on expired)
    $links = Fetch-Links
    if ($null -eq $links) { return }

    $now = Get-Date

    # Show file list
    $i = 0
    foreach ($lnk in $links) {
        $i++
        $destPath = Join-Path $DEST_ROOT $lnk.dest.Replace('/', '\')
        $exists   = Test-Path $destPath
        $tag      = if ($exists) { "${e}[38;2;34;197;94m OK ${e}[0m" } else { "${e}[38;2;80;100;140mN/A${e}[0m" }

        $expStr = ""
        if ($lnk.url -and $lnk.expires) {
            try {
                $exp  = [datetime]::Parse($lnk.expires)
                $left = ($exp - $now).TotalMinutes
                $expStr = if ($left -lt 0) {
                    "  ${e}[38;2;239;68;68m[expirado]${e}[0m"
                } elseif ($left -lt 30) {
                    "  ${e}[38;2;250;204;21m[$([int]$left)min]${e}[0m"
                } else {
                    "  ${e}[38;2;80;100;140m[ate $(([datetime]::Parse($lnk.expires)).ToString('HH:mm'))]${e}[0m"
                }
            } catch {}
        }

        if ($lnk.url) {
            Write-Host "  [$tag]  ${e}[38;2;100;149;237m[$i]${e}[0m  ${e}[97m$($lnk.label)${e}[0m$expStr"
        } else {
            Write-Host "  [$tag]  ${e}[38;2;80;100;140m[$i]  $($lnk.label)  [sem link]${e}[0m"
        }
    }

    Write-Host ""
    Write-Sep
    Write-Host "  ${e}[38;2;80;100;140m[0]${e}[0m  Voltar"
    Write-Host ""
    Write-Host -NoNewline "  ${e}[38;2;29;155;255m>${e}[0m  Opcao: "
    $opt = ($Host.UI.ReadLine()).Trim()
    Write-Host ""

    if ($opt -eq "0") { return }

    # Resolve target — one file at a time
    if ($opt -match '^\d+$') {
        $idx = [int]$opt - 1
        if ($idx -ge 0 -and $idx -lt $links.Count -and $links[$idx].url) {
            $target = $links[$idx]
        } else {
            Write-Warn "Opcao invalida ou link nao disponivel."
            Start-Sleep -Seconds 1; continue
        }
    } else { continue }

    # Ensure aria2c + start daemon
    if (-not (Ensure-Aria2c)) { Read-Host "  ENTER"; continue }
    $proxyArg  = Get-ProxyArg
    $aria2Proc = Start-Aria2cDaemon $proxyArg

    try {
        Write-Host ""
        Write-Host "  ${e}[38;2;148;163;184mFicheiro:${e}[0m ${e}[1;97m$($target.label)${e}[0m"
        Write-Host "  ${e}[38;2;148;163;184mDestino: ${e}[0m $DEST_ROOT\$($target.dest.Replace('/','\'))"
        Write-Host ""
        $status = Invoke-Aria2cDownload -url $target.url -dest $target.dest
        if ($status -eq "complete") { Write-OK "$($target.label) concluido." }
        else { Write-Err "$($target.label) falhou." }
    } catch {
        Write-Err "Erro: $_"
    } finally {
        if ($aria2Proc) { $aria2Proc | Stop-Process -Force -EA SilentlyContinue }
    }

    Write-Host ""
    Read-Host "  ENTER para continuar"
}
