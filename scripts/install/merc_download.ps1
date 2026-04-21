# install/merc_download.ps1 - Mercedes Full Pack Download
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null
$e = [char]27

$LINKS_URL = "https://m-auto.online/merc_links.json"
$DEST_DIR  = "C:\M-auto\Temp"

if (-not (Test-Path $DEST_DIR)) { New-Item -ItemType Directory -Path $DEST_DIR -Force | Out-Null }

#-- Helpers ------------------------------------------------------------------
function Write-Header {
    Clear-Host
    Write-Host ""
    Write-Host "  ${e}[38;2;29;155;255m+------------------------------------------------------+${e}[0m"
    Write-Host "  ${e}[38;2;29;155;255m|${e}[0m  ${e}[1;97mMercedes Full Pack${e}[0m  ${e}[38;2;100;149;237mDownload${e}[0m"
    Write-Host "  ${e}[38;2;29;155;255m+------------------------------------------------------+${e}[0m"
    Write-Host ""
}

function Write-OK($msg)   { Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m  $msg" }
function Write-Err($msg)  { Write-Host "  ${e}[38;2;239;68;68m[X]${e}[0m   $msg" }
function Write-Warn($msg) { Write-Host "  ${e}[38;2;250;204;21m[!]${e}[0m   $msg" }
function Write-Info($msg) { Write-Host "  ${e}[38;2;148;163;184m[.]${e}[0m   $msg" }

#-- Verificar links ----------------------------------------------------------
function Get-Links {
    try {
        $url  = "$LINKS_URL`?t=$([DateTimeOffset]::UtcNow.ToUnixTimeSeconds())"
        $raw  = irm $url -UseBasicParsing -TimeoutSec 8 -ErrorAction Stop
        $json = if ($raw -is [string]) { $raw | ConvertFrom-Json } else { $raw }

        if ([string]::IsNullOrWhiteSpace($json.expires)) { return $null }
        if (-not $json.files -or $json.files.Count -eq 0) { return $null }

        $exp = [datetime]::Parse($json.expires,
            [System.Globalization.CultureInfo]::InvariantCulture,
            [System.Globalization.DateTimeStyles]::RoundtripKind)

        if ((Get-Date).ToUniversalTime() -gt $exp.ToUniversalTime()) { return $null }

        return $json
    } catch {
        return $null
    }
}

#-- Download com aria2c ------------------------------------------------------
function Invoke-Download {
    param([string]$Url, [string]$Name)

    $ARIA = "$env:TEMP\aria2c.exe"
    $RPC  = "http://localhost:6801/jsonrpc"
    $TOK  = "mauto2026"

    # Instalar aria2c se necessario
    if (-not (Test-Path $ARIA)) {
        Write-Info "A instalar aria2c..."
        try {
            $zip = "$env:TEMP\aria2.zip"
            Invoke-WebRequest "https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0-win-64bit-build1.zip" -OutFile $zip -UseBasicParsing
            Expand-Archive $zip -DestinationPath "$env:TEMP\aria2x" -Force
            Copy-Item "$env:TEMP\aria2x\aria2-1.37.0-win-64bit-build1\aria2c.exe" $ARIA -Force
            Remove-Item $zip, "$env:TEMP\aria2x" -Recurse -Force -EA SilentlyContinue
            Write-OK "aria2c pronto"
            Write-Host ""
        } catch {
            Write-Err "Erro: $_"
            Read-Host "ENTER"
            return $false
        }
    }

    # Detectar proxy
    $proxyArg = ""
    try {
        $r = Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -EA Stop
        if ($r.ProxyEnable -eq 1 -and $r.ProxyServer) {
            $proxyArg = "--all-proxy=http://$($r.ProxyServer)"
            Write-Info "Proxy detetado: $($r.ProxyServer)"
        }
    } catch {}

    # Iniciar daemon aria2c
    $aria2Proc = $null
    try {
        Invoke-RestMethod -Uri $RPC -Method Post -Body '{"jsonrpc":"2.0","id":"1","method":"aria2.getVersion","params":["token:mauto2026"]}' -ContentType "application/json" -TimeoutSec 2 -EA Stop | Out-Null
    } catch {
        if ($proxyArg) {
            Get-Process -Name aria2c -EA SilentlyContinue | Stop-Process -Force -EA SilentlyContinue
            Start-Sleep -Milliseconds 400
        }
        $aria2Proc = Start-Process -FilePath $ARIA -ArgumentList "--enable-rpc --rpc-listen-port=6801 --rpc-secret=$TOK --rpc-allow-origin-all --file-allocation=none --quiet=true --disable-ipv6=true $proxyArg" -PassThru -WindowStyle Hidden
        Start-Sleep -Milliseconds 1200
    }

    # Adicionar download
    try {
        $opts = @{
            dir = $DEST_DIR
            out = $Name
            split = "32"
        }
        $body = @{
            jsonrpc = "2.0"
            id = "1"
            method = "aria2.addUri"
            params = @("token:$TOK", @($Url), $opts)
        } | ConvertTo-Json -Depth 5 -Compress

        $gid = (Invoke-RestMethod -Uri $RPC -Method Post -Body $body -ContentType "application/json").result

        # Monitorizar progresso
        $barW = 36
        $lastDown = 0
        $lastTick = [DateTime]::Now

        do {
            Start-Sleep -Milliseconds 800
            $sb = @{jsonrpc="2.0";id="1";method="aria2.tellStatus";params=@("token:$TOK",$gid)} | ConvertTo-Json -Depth 3 -Compress
            $s = (Invoke-RestMethod -Uri $RPC -Method Post -Body $sb -ContentType "application/json").result

            $tot = [long]$s.totalLength
            $down = [long]$s.completedLength
            $cn = $s.connections

            $dt = ([DateTime]::Now - $lastTick).TotalSeconds
            $spd = if ($dt -gt 0) { ($down - $lastDown) / $dt } else { 0 }
            $lastDown = $down
            $lastTick = [DateTime]::Now

            $pct = if ($tot -gt 0) { [int]($down / $tot * 100) } else { 0 }
            $mb = "{0:N1}" -f ($down / 1MB)
            $totMB = "{0:N1}" -f ($tot / 1MB)

            $spdStr = if ($spd -gt 1MB) { "{0:N1} MB/s" -f ($spd / 1MB) } elseif ($spd -gt 1KB) { "{0:N0} KB/s" -f ($spd / 1KB) } else { "-- KB/s" }

            $etaStr = if ($spd -gt 0 -and $tot -gt $down) {
                $r = ($tot - $down) / $spd
                if ($r -gt 3600) { "{0}h{1:D2}m" -f [int]($r / 3600), [int](($r % 3600) / 60) }
                elseif ($r -gt 60) { "{0}m{1:D2}s" -f [int]($r / 60), [int]($r % 60) }
                else { "{0}s" -f [int]$r }
            } else { "--" }

            $filled = [int]($barW * $pct / 100)
            $bar = ("${e}[38;2;29;155;255m" + ([string][char]9608 * $filled)) + ("${e}[38;2;40;50;70m" + ([string][char]9617 * ($barW - $filled))) + "${e}[0m"

            Write-Host -NoNewline ([char]13 + "  [$bar] ${e}[1;97m$pct%${e}[0m  ${e}[38;2;148;163;184m$mb/$totMB MB${e}[0m  ${e}[38;2;34;197;94m$spdStr${e}[0m  ETA ${e}[38;2;250;204;21m$etaStr${e}[0m  CN:$cn  ")

        } while ($s.status -eq "active" -or $s.status -eq "waiting")

        Write-Host ""
        Write-Host ""

        if ($s.status -eq "complete") {
            Write-OK "Concluido: $DEST_DIR\$Name"
            return $true
        } else {
            Write-Err "Erro: $($s.errorMessage)"
            return $false
        }
    } catch {
        Write-Err "Erro: $_"
        return $false
    } finally {
        if ($aria2Proc) { $aria2Proc | Stop-Process -Force -EA SilentlyContinue }
    }
}

#-- Main ---------------------------------------------------------------------
Write-Header

$retry = 0
while ($true) {
    $data = Get-Links

    if ($data) {
        # Links validos — mostrar menu
        $links = $data.files
        $exp = [datetime]::Parse($data.expires,
            [System.Globalization.CultureInfo]::InvariantCulture,
            [System.Globalization.DateTimeStyles]::RoundtripKind)

        Write-OK "Links validos ate: $($exp.ToLocalTime().ToString('dd/MM/yyyy HH:mm'))"
        Write-Host ""
        Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"

        for ($i = 0; $i -lt $links.Count; $i++) {
            Write-Host "  ${e}[38;2;100;149;237m[$($i+1)]${e}[0m  $($links[$i].name)"
        }

        Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
        Write-Host "  ${e}[38;2;100;149;237m[0]${e}[0m  Voltar"
        Write-Host ""

        $choice = Read-Host "  Escolha"

        if ($choice -eq "0") { return }

        $idx = [int]$choice - 1
        if ($idx -ge 0 -and $idx -lt $links.Count) {
            $f = $links[$idx]
            Write-Host ""
            Write-Host "  ${e}[38;2;100;149;237m-- $($f.name) --${e}[0m"
            Write-Host ""
            Invoke-Download -Url $f.url -Name $f.name
            Write-Host ""
            Read-Host "  Pressione ENTER para continuar"
            Write-Header
        } else {
            Write-Err "Opcao invalida"
            Start-Sleep -Seconds 1
            Write-Header
        }
        continue
    }

    # Links expirados — aguardar
    if ($retry -eq 0) {
        Write-Warn "Links expirados. A aguardar renovacao pelo tecnico..."
        Write-Info "A verificar de 5 em 5 segundos. Prima Ctrl+C para cancelar."
        Write-Host ""
    }

    $retry++
    $ts = Get-Date -Format "HH:mm:ss"
    Write-Host -NoNewline "`r  ${e}[38;2;80;100;140m[$ts]${e}[0m  A aguardar... (tentativa $retry)  "
    Start-Sleep -Seconds 5
}
