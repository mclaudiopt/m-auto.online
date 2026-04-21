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
        # Cache-bust: evita CDN do GitHub Pages devolver versao antiga
        $url  = "$LINKS_URL`?t=$([DateTimeOffset]::UtcNow.ToUnixTimeSeconds())"
        $raw  = irm $url -UseBasicParsing -TimeoutSec 8 -ErrorAction Stop

        # irm pode devolver string ou PSCustomObject consoante o Content-Type
        $json = if ($raw -is [string]) { $raw | ConvertFrom-Json } else { $raw }

        # Sem expires ou sem ficheiros
        if ([string]::IsNullOrWhiteSpace($json.expires)) { return $null }
        if (-not $json.files -or $json.files.Count -eq 0) { return $null }

        # Parsing robusto da data (ISO 8601, invariant culture)
        $exp = [datetime]::Parse($json.expires,
            [System.Globalization.CultureInfo]::InvariantCulture,
            [System.Globalization.DateTimeStyles]::RoundtripKind)

        if ((Get-Date).ToUniversalTime() -gt $exp.ToUniversalTime()) { return $null }

        return $json.files
    } catch {
        return $null
    }
}

#-- Download com barra de progresso ------------------------------------------
function Invoke-Download {
    param([string]$Url, [string]$Name, [int]$Idx, [int]$Total)

    $dest = Join-Path $DEST_DIR $Name
    $barWidth = 36

    Write-Host "  ${e}[38;2;148;163;184mFicheiro:${e}[0m ${e}[97m$Name${e}[0m"
    Write-Host "  ${e}[38;2;148;163;184mDestino: ${e}[0m ${e}[97m$dest${e}[0m"
    Write-Host ""

    $global:dlDone  = $false
    $global:dlError = $null
    $global:dlBytes = 0
    $global:dlTotal = 0

    $wc = New-Object System.Net.WebClient

    $wc.add_DownloadProgressChanged({
        $global:dlBytes = $_.BytesReceived
        $global:dlTotal = $_.TotalBytesToReceive
    })

    $wc.add_DownloadFileCompleted({
        if ($_.Error) { $global:dlError = $_.Error.Message }
        $global:dlDone = $true
    })

    $startTime = Get-Date
    $wc.DownloadFileAsync([uri]$Url, $dest)

    while (-not $global:dlDone) {
        $dl   = $global:dlBytes
        $tot  = $global:dlTotal
        $perc = if ($tot -gt 0) { [math]::Round($dl / $tot * 100) } else { 0 }

        $elapsed = ((Get-Date) - $startTime).TotalSeconds
        $speed   = if ($elapsed -gt 0.5) { $dl / $elapsed / 1KB } else { 0 }
        $dlMB    = [math]::Round($dl  / 1MB, 1)
        $totMB   = if ($tot -gt 0) { [math]::Round($tot / 1MB, 1) } else { "?" }

        $eta = if ($speed -gt 0 -and $tot -gt $dl) {
            $secs = [int](($tot - $dl) / ($speed * 1KB))
            "{0}:{1:D2}" -f [int]($secs / 60), ($secs % 60)
        } else { "--" }

        $speedStr = if ($speed -gt 0) { "$([math]::Round($speed)) KB/s" } else { "-- KB/s" }
        $filled   = [math]::Round($perc / 100 * $barWidth)
        $bar      = ("$([char]0x2588)" * $filled).PadRight($barWidth, [char]0x2591)

        Write-Host -NoNewline "`r  [${e}[38;2;100;149;237m$bar${e}[0m] $perc%  $dlMB/$totMB MB  $speedStr  ETA $eta  CN:$Idx/$Total  "
        Start-Sleep -Milliseconds 400
    }

    Write-Host ""

    if ($global:dlError) {
        Write-Err "Erro: $($global:dlError)"
        return $false
    }

    Write-OK "$Name transferido."
    return $true
}

#-- Loop principal -----------------------------------------------------------
Write-Header

$retry = 0
while ($true) {
    $links = Get-Links

    if ($links) {
        # Links validos — iniciar downloads
        Write-Header
        Write-OK "Links validos. A iniciar download de $($links.Count) ficheiro(s)..."
        Write-Host ""

        $ok = 0; $fail = 0
        for ($i = 0; $i -lt $links.Count; $i++) {
            $f = $links[$i]
            Write-Host "  ${e}[38;2;100;149;237m-- $($f.name) ($($i+1)/$($links.Count)) --${e}[0m"
            $res = Invoke-Download -Url $f.url -Name $f.name -Idx ($i+1) -Total $links.Count
            if ($res) { $ok++ } else { $fail++ }
            Write-Host ""
        }

        Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
        if ($ok -gt 0)   { Write-OK   "$ok ficheiro(s) transferido(s) com sucesso." }
        if ($fail -gt 0) { Write-Err  "$fail ficheiro(s) falharam." }
        Write-Host ""
        Read-Host "  Pressione ENTER para sair"
        return
    }

    # Links expirados — aguardar
    if ($retry -eq 0) {
        Write-Warn "Links expirados. A aguardar renovacao pelo tecnico..."
        Write-Info "A verificar de 5 em 5 segundos. Prima Ctrl+C para cancelar."
        Write-Host ""

        # Mostrar o que foi lido do servidor para diagnostico
        try {
            $url  = "$LINKS_URL`?t=$([DateTimeOffset]::UtcNow.ToUnixTimeSeconds())"
            $raw  = irm $url -UseBasicParsing -TimeoutSec 8 -ErrorAction Stop
            $json = if ($raw -is [string]) { $raw | ConvertFrom-Json } else { $raw }
            $nf   = if ($json.files) { $json.files.Count } else { 0 }
            Write-Host "  ${e}[38;2;50;60;80m  URL:     $LINKS_URL${e}[0m"
            Write-Host "  ${e}[38;2;50;60;80m  expires: $($json.expires)${e}[0m"
            Write-Host "  ${e}[38;2;50;60;80m  files:   $nf ficheiro(s)${e}[0m"
        } catch {
            Write-Host "  ${e}[38;2;239;68;68m  Erro ao ler JSON: $_${e}[0m"
        }
        Write-Host ""
    }

    $retry++
    $ts = Get-Date -Format "HH:mm:ss"
    Write-Host -NoNewline "`r  ${e}[38;2;80;100;140m[$ts]${e}[0m  A aguardar... (tentativa $retry)  "
    Start-Sleep -Seconds 5
}
