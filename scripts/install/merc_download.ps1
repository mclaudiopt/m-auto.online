# install/merc_download.ps1 - Mercedes Full Pack Download
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null
$e = [char]27

$LINKS_URL = "https://m-auto.online/merc_links.json"
$DEST_DIR  = "C:\M-auto\Temp"

# Aliases para ficheiros
$FILE_ALIASES = @{
    "FullFix By Samik v4.9.3.exe" = "Fix Base"
    "FullFix for Xentry and Truck v9.0.6.exe" = "Fix Full"
}

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

#-- Instalar aria2c se necessario -------------------------------------------
function Install-Aria2c {
    $aria2Path = "C:\M-auto\Tools\aria2c.exe"
    if (Test-Path $aria2Path) { return $aria2Path }

    Write-Info "A transferir aria2c..."
    $aria2Url = "https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0-win-64bit-build1.zip"
    $tempZip = "$env:TEMP\aria2.zip"
    $tempDir = "$env:TEMP\aria2_extract"

    try {
        # Download com progress bar
        $wc = New-Object System.Net.WebClient
        $global:wcDone = $false
        $global:wcError = $null

        $progressSub = Register-ObjectEvent -InputObject $wc -EventName DownloadProgressChanged -Action {
            $pct = $Event.SourceEventArgs.ProgressPercentage
            $recv = [math]::Round($Event.SourceEventArgs.BytesReceived / 1KB, 0)
            $total = [math]::Round($Event.SourceEventArgs.TotalBytesToReceive / 1KB, 0)
            $width = 50
            $filled = [math]::Round($pct / 100 * $width)
            $empty = $width - $filled
            $fillColor = if ($pct -eq 100) { "46;204;113" } else { "52;152;219" }
            $emptyColor = "52;73;94"
            $e = [char]27
            $barFilled = "${e}[48;2;${fillColor}m" + (" " * $filled) + "${e}[0m"
            $barEmpty = "${e}[48;2;${emptyColor}m" + (" " * $empty) + "${e}[0m"
            $percentText = "${e}[1;97m$pct%${e}[0m".PadLeft(12)
            Write-Host -NoNewline "`r  $percentText $barFilled$barEmpty  ${e}[90m$recv KB / $total KB${e}[0m   "
        }

        $completedSub = Register-ObjectEvent -InputObject $wc -EventName DownloadFileCompleted -Action {
            $global:wcDone = $true
            $global:wcError = $Event.SourceEventArgs.Error
        }

        $wc.DownloadFileAsync([Uri]$aria2Url, $tempZip)
        while (-not $global:wcDone) { Start-Sleep -Milliseconds 500 }

        $wc.Dispose()
        Unregister-Event -SourceIdentifier $progressSub.Name -ErrorAction SilentlyContinue
        Unregister-Event -SourceIdentifier $completedSub.Name -ErrorAction SilentlyContinue
        Remove-Job -Name $progressSub.Name -Force -ErrorAction SilentlyContinue
        Remove-Job -Name $completedSub.Name -Force -ErrorAction SilentlyContinue
        Write-Host ""

        if ($global:wcError) { throw $global:wcError.Message }

        Expand-Archive -Path $tempZip -DestinationPath $tempDir -Force
        $aria2Exe = Get-ChildItem -Path $tempDir -Filter "aria2c.exe" -Recurse | Select-Object -First 1

        $toolsDir = "C:\M-auto\Tools"
        if (-not (Test-Path $toolsDir)) { New-Item -ItemType Directory -Path $toolsDir -Force | Out-Null }

        Copy-Item $aria2Exe.FullName -Destination $aria2Path -Force
        Remove-Item $tempZip, $tempDir -Recurse -Force -ErrorAction SilentlyContinue

        Write-OK "aria2c instalado."
        return $aria2Path
    } catch {
        Write-Err "Falha ao instalar aria2c: $_"
        return $null
    }
}

#-- Download com aria2c (16 conexoes) ----------------------------------------
function Invoke-Download {
    param([string]$Url, [string]$Name, [int]$Idx, [int]$Total)

    $dest = Join-Path $DEST_DIR $Name
    $destDir = Split-Path $dest -Parent

    # Criar subdiretorios se necessario
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    # Instalar aria2c se necessario
    $aria2 = Install-Aria2c
    if (-not $aria2) {
        Write-Err "aria2c nao disponivel. A usar metodo alternativo..."
        return $false
    }

    # Configurar proxy
    $proxy = Get-ProxyConfig
    $proxyArg = if ($proxy) { "--all-proxy=http://$proxy" } else { "" }

    # Argumentos aria2c: 16 conexoes, resume automatico, timeout 60s
    $logFile = "$env:TEMP\aria2_$([guid]::NewGuid().ToString('N').Substring(0,8)).log"

    # Criar ProcessStartInfo para controlar argumentos corretamente
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $aria2
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true

    # Construir argumentos manualmente
    $psi.Arguments = "--max-connection-per-server=16 --split=16 --min-split-size=1M --continue=true --max-tries=3 --retry-wait=2 --timeout=60 --connect-timeout=30 --console-log-level=warn --summary-interval=0 --log-level=info `"--dir=$destDir`" `"--out=$Name`" `"--log=$logFile`""
    if ($proxyArg) { $psi.Arguments += " $proxyArg" }
    $psi.Arguments += " `"$Url`""

    $process = [System.Diagnostics.Process]::Start($psi)

    $startTime = Get-Date
    $spinnerFrames = @('⠋','⠙','⠹','⠸','⠼','⠴','⠦','⠧','⠇','⠏')
    $spinnerIdx = 0

    while (-not $process.HasExited) {
        Start-Sleep -Milliseconds 300

        if (Test-Path $dest) {
            $dlBytes = (Get-Item $dest).Length
            $elapsed = ((Get-Date) - $startTime).TotalSeconds
            $speed = if ($elapsed -gt 0.5) { $dlBytes / $elapsed / 1MB } else { 0 }
            $dlMB = [math]::Round($dlBytes / 1MB, 1)
            $spdStr = if ($speed -gt 0) { "{0:N1} MB/s" -f $speed } else { "-- MB/s" }

            $spinner = $spinnerFrames[$spinnerIdx % $spinnerFrames.Count]
            $spinnerIdx++

            Write-Host -NoNewline "`r  ${e}[38;2;100;149;237m$spinner${e}[0m $dlMB MB  $spdStr  ${e}[38;2;148;163;184m[CN:16] [$Idx/$Total]${e}[0m  "
        }
    }

    Remove-Item $logFile -Force -ErrorAction SilentlyContinue

    if ($process.ExitCode -eq 0 -and (Test-Path $dest)) {
        Write-Host ""
        Write-OK "$Name transferido."
        return $true
    } else {
        Write-Host ""
        Write-Err "Erro no download (codigo: $($process.ExitCode))"
        return $false
    }
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
        # Links validos — mostrar menu de selecao
        Write-Header
        Write-OK "Links validos — $($links.Count) ficheiro(s) disponiveis."
        Write-Host ""

        # Checklist de estado com numeracao
        for ($i = 0; $i -lt $links.Count; $i++) {
            $f = $links[$i]
            $dest = Join-Path $DEST_DIR $f.name
            $num = $i + 1

            # Usar alias se existir
            $displayName = if ($FILE_ALIASES.ContainsKey($f.name)) { $FILE_ALIASES[$f.name] } else { $f.name }

            if (Test-Path $dest) {
                $sizeMB = [math]::Round((Get-Item $dest).Length / 1MB, 1)
                Write-Host "  ${e}[38;2;100;130;100m[$num]${e}[0m ${e}[38;2;34;197;94m[OK]${e}[0m  $displayName ${e}[38;2;100;130;100m($sizeMB MB — ja existe)${e}[0m"
            } else {
                Write-Host "  ${e}[38;2;148;163;184m[$num]${e}[0m ${e}[38;2;250;204;21m[--]${e}[0m  $displayName ${e}[38;2;148;163;184m(por transferir)${e}[0m"
            }
        }
        Write-Host ""
        Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
        Write-Host ""
        Write-Host "  ${e}[38;2;148;163;184mEscolha:${e}[0m"
        Write-Host "    ${e}[38;2;100;149;237m[A]${e}[0m Transferir todos os ficheiros em falta"
        Write-Host "    ${e}[38;2;100;149;237m[1-$($links.Count)]${e}[0m Transferir ficheiro especifico"
        Write-Host "    ${e}[38;2;239;68;68m[C]${e}[0m Clean (limpeza)"
        Write-Host "    ${e}[38;2;239;68;68m[S]${e}[0m Sair"
        Write-Host ""
        $choice = Read-Host "  Opcao"

        if ($choice -eq "S" -or $choice -eq "s") {
            Write-Info "Cancelado pelo utilizador."
            exit 0
        }

        if ($choice -eq "C" -or $choice -eq "c") {
            $cleanScript = Join-Path $PSScriptRoot "merc_clean.ps1"
            if (Test-Path $cleanScript) {
                & $cleanScript
            } else {
                Write-Err "Script de limpeza nao encontrado: $cleanScript"
                Start-Sleep -Seconds 2
            }
            continue
        }

        $toDownload = @()
        if ($choice -eq "A" -or $choice -eq "a") {
            # Transferir todos os ficheiros em falta
            for ($i = 0; $i -lt $links.Count; $i++) {
                $dest = Join-Path $DEST_DIR $links[$i].name
                if (-not (Test-Path $dest)) {
                    $toDownload += $i
                }
            }
        } elseif ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $links.Count) {
            # Transferir ficheiro especifico
            $toDownload += ([int]$choice - 1)
        } else {
            Write-Err "Opcao invalida."
            Start-Sleep -Seconds 2
            continue
        }

        if ($toDownload.Count -eq 0) {
            Write-Info "Nenhum ficheiro para transferir."
            Start-Sleep -Seconds 2
            exit 0
        }

        # Iniciar downloads
        Write-Header
        Write-OK "A transferir $($toDownload.Count) ficheiro(s)..."
        Write-Host ""

        $ok = 0; $fail = 0
        foreach ($idx in $toDownload) {
            $f = $links[$idx]
            $dest = Join-Path $DEST_DIR $f.name

            # Usar alias se existir
            $displayName = if ($FILE_ALIASES.ContainsKey($f.name)) { $FILE_ALIASES[$f.name] } else { $f.name }

            Write-Host "  ${e}[38;2;100;149;237m-- $displayName ($($ok+$fail+1)/$($toDownload.Count)) --${e}[0m"

            $res = Invoke-Download -Url $f.url -Name $f.name -Idx ($ok+$fail+1) -Total $toDownload.Count
            if ($res) { $ok++ } else { $fail++ }
            Write-Host ""
        }

        Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
        if ($ok -gt 0)   { Write-OK "$ok ficheiro(s) transferido(s) com sucesso." }
        if ($fail -gt 0) { Write-Err "$fail ficheiro(s) falharam." }
        Write-Host ""
        Read-Host "  Pressione ENTER para continuar"
        $retry = 0
        continue
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
Write-Host ""
Read-Host "  Pressione ENTER para voltar"
exit 1
