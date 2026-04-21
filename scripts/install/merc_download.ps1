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

#-- Verificar permissoes de escrita ------------------------------------------
function Test-WritePermissions {
    try {
        $testFile = Join-Path $DEST_DIR ".test"
        "test" | Out-File $testFile -Force -ErrorAction Stop
        Remove-Item $testFile -Force -ErrorAction SilentlyContinue
        return $true
    } catch {
        Write-Err "Sem permissoes de escrita em $DEST_DIR"
        Write-Err "Erro: $_"
        return $false
    }
}

#-- Detectar proxy corporativo -----------------------------------------------
function Get-ProxyConfig {
    try {
        $reg = Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -EA Stop
        if ($reg.ProxyEnable -eq 1 -and $reg.ProxyServer) {
            return $reg.ProxyServer
        }
    } catch {}
    return $null
}

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

#-- Download com retry e timeout --------------------------------------------
function Invoke-Download {
    param([string]$Url, [string]$Name, [int]$Idx, [int]$Total)

    $dest = Join-Path $DEST_DIR $Name
    $destDir = Split-Path $dest -Parent

    # Criar subdiretorios se necessario
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    Write-Host "  ${e}[38;2;148;163;184mFicheiro:${e}[0m ${e}[97m$Name${e}[0m"
    Write-Host "  ${e}[38;2;148;163;184mDestino: ${e}[0m ${e}[97m$dest${e}[0m"
    Write-Host ""

    # Retry com backoff exponencial
    $maxRetries = 3
    $retryDelay = 2

    for ($attempt = 1; $attempt -le $maxRetries; $attempt++) {
        try {
            # Configurar proxy se necessario
            $proxy = Get-ProxyConfig
            $proxyArgs = @{}
            if ($proxy) {
                $proxyArgs['Proxy'] = "http://$proxy"
                $proxyArgs['ProxyUseDefaultCredentials'] = $true
            }

            # Download com timeout de 300 segundos (5 min)
            $job = Start-Job -ScriptBlock {
                param($url, $dest, $proxyArgs)
                Invoke-WebRequest -Uri $url -OutFile $dest -TimeoutSec 300 @proxyArgs
            } -ArgumentList $Url, $dest, $proxyArgs

            # Monitorizar progresso
            $startTime = Get-Date
            while ($job.State -eq 'Running') {
                Start-Sleep -Milliseconds 500

                if (Test-Path $dest) {
                    $dlBytes = (Get-Item $dest).Length
                    $elapsed = ((Get-Date) - $startTime).TotalSeconds
                    $speed = if ($elapsed -gt 0.5) { $dlBytes / $elapsed / 1MB } else { 0 }
                    $dlMB = [math]::Round($dlBytes / 1MB, 1)
                    $spdStr = if ($speed -gt 0) { "{0:N1} MB/s" -f $speed } else { "-- MB/s" }

                    Write-Host -NoNewline "`r  ${e}[38;2;100;149;237m↓${e}[0m $dlMB MB  $spdStr  ${e}[38;2;148;163;184m[$Idx/$Total]${e}[0m  "
                }
            }

            $result = Receive-Job -Job $job -Wait -ErrorAction Stop
            Remove-Job -Job $job -Force

            Write-Host ""
            Write-OK "$Name transferido."
            return $true

        } catch {
            Remove-Job -Job $job -Force -ErrorAction SilentlyContinue

            if ($attempt -lt $maxRetries) {
                Write-Warn "Tentativa $attempt falhou. A tentar novamente em ${retryDelay}s..."
                Start-Sleep -Seconds $retryDelay
                $retryDelay *= 2

                # Apagar ficheiro parcial
                if (Test-Path $dest) {
                    Remove-Item $dest -Force -ErrorAction SilentlyContinue
                }
            } else {
                Write-Host ""
                Write-Err "Erro apos $maxRetries tentativas: $_"
                return $false
            }
        }
    }

    return $false
}

#-- Loop principal -----------------------------------------------------------
Write-Header

# Verificar permissoes de escrita
if (-not (Test-WritePermissions)) {
    Start-Sleep -Seconds 3
    exit 1
}

# Detectar proxy
$proxy = Get-ProxyConfig
if ($proxy) {
    Write-Info "Proxy detetado: $proxy"
}

$maxRetries = 60  # 5 minutos (60 * 5s)
$retry = 0

while ($retry -lt $maxRetries) {
    $links = Get-Links

    if ($links) {
        # Links validos — mostrar checklist e iniciar downloads
        Write-Header
        Write-OK "Links validos — $($links.Count) ficheiro(s) disponiveis."
        Write-Host ""

        # Checklist de estado
        foreach ($f in $links) {
            $dest = Join-Path $DEST_DIR $f.name
            if (Test-Path $dest) {
                $sizeMB = [math]::Round((Get-Item $dest).Length / 1MB, 1)
                Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m  $($f.name) ${e}[38;2;100;130;100m($sizeMB MB — ja existe)${e}[0m"
            } else {
                Write-Host "  ${e}[38;2;250;204;21m[--]${e}[0m  $($f.name) ${e}[38;2;148;163;184m(por transferir)${e}[0m"
            }
        }
        Write-Host ""
        Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
        Write-Host ""

        $ok = 0; $fail = 0; $skip = 0
        for ($i = 0; $i -lt $links.Count; $i++) {
            $f    = $links[$i]
            $dest = Join-Path $DEST_DIR $f.name

            Write-Host "  ${e}[38;2;100;149;237m-- $($f.name) ($($i+1)/$($links.Count)) --${e}[0m"

            if (Test-Path $dest) {
                $sizeMB = [math]::Round((Get-Item $dest).Length / 1MB, 1)
                Write-OK "$($f.name) ja existe ($sizeMB MB) — a saltar."
                $skip++
            } else {
                $res = Invoke-Download -Url $f.url -Name $f.name -Idx ($i+1) -Total $links.Count
                if ($res) { $ok++ } else { $fail++ }
            }
            Write-Host ""
        }

        Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
        if ($ok -gt 0)   { Write-OK   "$ok ficheiro(s) transferido(s) com sucesso." }
        if ($skip -gt 0) { Write-Info "$skip ficheiro(s) ja existiam — saltados." }
        if ($fail -gt 0) { Write-Err  "$fail ficheiro(s) falharam." }
        Write-Host ""
        Start-Sleep -Seconds 2
        exit 0
    }

    # Links expirados — aguardar
    if ($retry -eq 0) {
        Write-Warn "Links expirados. A aguardar renovacao pelo tecnico..."
        Write-Info "A verificar de 5 em 5 segundos (max 5 min). Prima Ctrl+C para cancelar."
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
    Write-Host -NoNewline "`r  ${e}[38;2;80;100;140m[$ts]${e}[0m  A aguardar... (tentativa $retry/$maxRetries)  "
    Start-Sleep -Seconds 5
}

Write-Host ""
Write-Err "Timeout: links nao renovados apos 5 minutos."
Start-Sleep -Seconds 3
exit 1
