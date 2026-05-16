# install/renault_download.ps1 - Renault CLIP Download Enhanced
# v3.0: SHA256, Smart Retry, Notifications, Cache, History Cleanup
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null
$e = [char]27

#-- Import shared functions ---------------------------------------------------
# Note: When executed via irm | iex, $PSScriptRoot is empty, so we fetch remotely
$BASE_URL = "https://m-auto.online/scripts"
try {
    $sharedFuncs = irm "$BASE_URL/install/shared-functions.ps1" -UseBasicParsing
    Invoke-Expression $sharedFuncs
} catch {
    Write-Host "Erro ao carregar shared-functions.ps1: $_"
    exit 1
}

$LOG_DIR = "C:\M-auto\Logs"

#-- Parse-Selection: Suporta "1", "1,3,5", "1-3" --------------------------
function Parse-Selection {
    param([string]$selection, [int]$maxNum)
    $selected = @()
    $parts = $selection -split ','
    foreach ($part in $parts) {
        $part = $part.Trim()
        if ($part -match '^(\d+)-(\d+)$') {
            # Range: "1-3" -> 1, 2, 3
            $start = [int]$matches[1]
            $end = [int]$matches[2]
            if ($start -le $end -and $start -ge 1 -and $end -le $maxNum) {
                for ($i = $start; $i -le $end; $i++) { $selected += $i - 1 }
            } else {
                return $null
            }
        } elseif ($part -match '^\d+$') {
            # Single: "1" -> 0
            $num = [int]$part
            if ($num -ge 1 -and $num -le $maxNum) { $selected += $num - 1 }
            else { return $null }
        } else {
            return $null
        }
    }
    return @($selected | Sort-Object -Unique)
}

$LINKS_URL = "https://m-auto.online/renault_links.json"
$DEST_DIR  = "C:\M-auto\Temp"

if (-not (Test-Path $DEST_DIR)) { New-Item -ItemType Directory -Path $DEST_DIR -Force | Out-Null }

#-- Helpers ------------------------------------------------------------------
function Write-Header {
    Clear-Host
    Write-Host ""
    Write-Host "  ${e}[38;2;255;204;0m+------------------------------------------------------+${e}[0m"
    Write-Host "  ${e}[38;2;255;204;0m|${e}[0m  ${e}[1;97mRenault CLIP${e}[0m  ${e}[38;2;255;204;0mDownload${e}[0m"
    Write-Host "  ${e}[38;2;255;204;0m+------------------------------------------------------+${e}[0m"
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
            $fillColor = if ($pct -eq 100) { "46;204;113" } else { "255;204;0" }
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
        Remove-Job -Name $progressSub.Name, $completedSub.Name -Force -ErrorAction SilentlyContinue
        Write-Host ""

        if ($global:wcError) { throw $global:wcError.Message }

        # Extrair
        Write-Info "A extrair aria2c..."
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

#-- Obter tamanho do ficheiro via HEAD ---------------------------------------
function Get-RemoteSize {
    param([string]$Url)
    try {
        $req = [System.Net.HttpWebRequest]::Create($Url)
        $req.Method = "HEAD"; $req.Timeout = 8000; $req.AllowAutoRedirect = $true
        $resp = $req.GetResponse()
        $len  = $resp.ContentLength
        $resp.Close()
        return $len
    } catch { return 0 }
}

#-- Download com aria2c (4 conexoes para progresso linear) -------------------
function Invoke-Download {
    param([string]$Url, [string]$Name, [int]$Idx, [int]$Total, [long]$Size = 0)

    $dest     = Join-Path $DEST_DIR $Name
    $destDir  = Split-Path $dest -Parent
    $fileName = Split-Path $dest -Leaf
    $width    = 50

    if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }

    $aria2 = Install-Aria2c
    if (-not $aria2) { Write-Err "aria2c nao disponivel."; return $false }

    $totalBytes = if ($Size -gt 0) { $Size } else { Get-RemoteSize -Url $Url }
    $totalMB    = if ($totalBytes -gt 0) { [math]::Round($totalBytes / 1MB, 1) } else { 0 }
    Write-Host "  ${e}[38;2;148;163;184m[.]${e}[0m   $(if ($totalMB -gt 0) { "$totalMB MB" } else { "tamanho desconhecido" })"

    $proxy = Get-ProxyConfig
    # MELHORIA: usar 4 conexoes para progresso mais linear
    $cn = 4

    $argList = [System.Collections.Generic.List[string]]::new()
    $argList.Add("--max-connection-per-server=$cn")
    $argList.Add("--split=$cn")
    $argList.Add("--min-split-size=1M")  # Chunks pequenos = rebalanceamento dinÃ¢mico = fim rÃ¡pido
    $argList.Add("--continue=true")
    $argList.Add("--max-tries=3")
    $argList.Add("--retry-wait=2")
    $argList.Add("--timeout=300")
    $argList.Add("--connect-timeout=60")
    $argList.Add("--disable-ipv6=true")
    $argList.Add("--console-log-level=error")
    $argList.Add("--summary-interval=0")
    $argList.Add("--file-allocation=prealloc")  # Pre-alocar para melhor estimativa
    $argList.Add("--check-certificate=false")
    $argList.Add("--auto-file-renaming=false")
    $argList.Add("--allow-overwrite=true")
    $argList.Add("--dir=$destDir")
    $argList.Add("--out=$fileName")
    $logFile = Join-Path $env:TEMP "aria2c_$PID.log"
    Remove-Item $logFile -Force -ErrorAction SilentlyContinue
    $argList.Add("--log=$logFile")
    $argList.Add("--log-level=warn")
    if ($proxy) { $argList.Add("--all-proxy=http://$proxy") }
    $argList.Add($Url)

    Remove-Item "$dest.aria2" -Force -ErrorAction SilentlyContinue

    # Start aria2c process and capture it for monitoring
    $proc = Start-Process -FilePath $aria2 -ArgumentList $argList.ToArray() -NoNewWindow -PassThru
    Start-Sleep -Milliseconds 200

    $startTime  = Get-Date
    $startBytes = if (Test-Path $dest) { (Get-Item $dest).Length } else { 0 }
    $samples    = [System.Collections.Generic.Queue[object]]::new()
    $spinIdx    = 0
    $spinChars  = @('|','/','-','\')

    while (-not $proc.HasExited) {
        Start-Sleep -Milliseconds 400

        $now      = Get-Date
        $dlBytes  = if (Test-Path $dest) { (Get-Item $dest).Length } else { 0 }
        $recvMB   = [math]::Round($dlBytes / 1MB, 1)

        $samples.Enqueue([PSCustomObject]@{ t = $now; b = $dlBytes })
        while ($samples.Count -gt 0 -and ($now - $samples.Peek().t).TotalSeconds -gt 3) {
            [void]$samples.Dequeue()
        }
        $speedMB = 0
        if ($samples.Count -ge 2) {
            $first = $samples.Peek()
            $dt    = ($now - $first.t).TotalSeconds
            if ($dt -gt 0.1) { $speedMB = [math]::Round(($dlBytes - $first.b) / $dt / 1MB, 1) }
        }

        if ($totalBytes -gt 0) {
            $rawPct = [math]::Round($dlBytes / $totalBytes * 100)
            $verifying = ($dlBytes -ge $totalBytes)
            $pct = if ($verifying) { 100 } else { $rawPct }
            $eta = if ($verifying) {
                "verif"
            } elseif ($speedMB -gt 0.01 -and $totalBytes -gt $dlBytes) {
                $s = [int](($totalBytes - $dlBytes) / ($speedMB * 1MB))
                "{0}:{1:D2}" -f [int]($s/60), ($s%60)
            } else { "--" }
            $filled    = [math]::Round($pct / 100 * $width)
            $empty     = $width - $filled
            $fillColor = if ($pct -ge 99) { "46;204;113" } else { "255;204;0" }
            $barFill   = "${e}[48;2;${fillColor}m" + (" " * $filled) + "${e}[0m"
            $barEmpty  = "${e}[48;2;52;73;94m"     + (" " * $empty)  + "${e}[0m"
            $pctText   = "${e}[1;97m$($pct.ToString().PadLeft(3))%${e}[0m"
            Write-Host -NoNewline "`r  $pctText $barFill$barEmpty  ${e}[90m$recvMB/$totalMB MB  $speedMB MB/s  ETA $eta  [$Idx/$Total]${e}[0m  "
        } else {
            $spin  = $spinChars[$spinIdx % $spinChars.Count]; $spinIdx++
            $pulse = $spinIdx % ($width * 2)
            $pos   = if ($pulse -lt $width) { $pulse } else { $width * 2 - $pulse }
            $pos   = [math]::Max(0, [math]::Min($pos, $width - 2))
            $bar   = (" " * $pos) + "${e}[48;2;255;204;0m  ${e}[0m" + (" " * ($width - $pos - 2))
            Write-Host -NoNewline "`r  ${e}[1;97m $spin ${e}[0m[$bar]  ${e}[90m$recvMB MB  $speedMB MB/s  [$Idx/$Total]${e}[0m  "
        }
    }

    $errOutput = if (Test-Path $logFile) { Get-Content $logFile -Raw -ErrorAction SilentlyContinue } else { "" }
    Remove-Item $logFile -Force -ErrorAction SilentlyContinue
    Write-Host ""

    if ($proc.ExitCode -eq 0 -and (Test-Path $dest)) {
        $finalMB = [math]::Round((Get-Item $dest).Length / 1MB, 1)
        Write-OK "$Name transferido ($finalMB MB)."
        return $true
    }

    Write-Err "aria2c falhou (codigo $($proc.ExitCode))"
    if ($errOutput -and $errOutput.Trim()) {
        $errOutput.Trim() -split "`n" | Where-Object { $_.Trim() } | ForEach-Object {
            Write-Host "  ${e}[38;2;239;68;68m    $($_.Trim())${e}[0m"
        }
    }
    return $false
}

#-- Loop principal -----------------------------------------------------------
Write-Header

if (-not (Test-WritePermissions)) {
    Start-Sleep -Seconds 3
    Clear-History -ErrorAction SilentlyContinue`nWrite-Info "Local history cleared for security"`nexit 1
}

$proxy = Get-ProxyConfig
if ($proxy) { Write-Info "Proxy detetado: $proxy" }

$maxRetries = 60
$retry = 0

while ($retry -lt $maxRetries) {
    $links = Get-Links

    if ($links) {
        Write-Header
        Write-OK "Links validos â€” $($links.Count) ficheiro(s) disponiveis."
        Write-Host ""
        Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
        Write-Host ""

        for ($i = 0; $i -lt $links.Count; $i++) {
            $f = $links[$i]
            $dest = Join-Path $DEST_DIR $f.name
            $num = $i + 1

            if (Test-Path $dest) {
                $sizeMB = [math]::Round((Get-Item $dest).Length / 1MB, 1)
                Write-Host "  ${e}[38;2;100;130;100m[$num]${e}[0m ${e}[38;2;34;197;94m[OK]${e}[0m  $($f.name) ${e}[38;2;100;130;100m($sizeMB MB â€” ja existe)${e}[0m"
            } else {
                Write-Host "  ${e}[38;2;148;163;184m[$num]${e}[0m ${e}[38;2;250;204;21m[--]${e}[0m  $($f.name) ${e}[38;2;148;163;184m(por transferir)${e}[0m"
            }
        }
        Write-Host ""
        Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
        Write-Host ""
        Write-Host "  ${e}[38;2;148;163;184mEscolha:${e}[0m"
        Write-Host "    ${e}[38;2;255;204;0m[A]${e}[0m Transferir TODOS os em falta"
        Write-Host "    ${e}[38;2;255;204;0m[1,2,3]${e}[0m Transferir multiplos (ex: 1,3,5)"
        Write-Host "    ${e}[38;2;255;204;0m[1-3]${e}[0m Transferir range (ex: 1-3)"
        Write-Host "    ${e}[38;2;255;204;0m[1]${e}[0m Transferir um (ex: 2)"
        Write-Host "    ${e}[38;2;239;68;68m[0]${e}[0m Voltar ao menu anterior"
        Write-Host "    ${e}[38;2;239;68;68m[S]${e}[0m Sair"
        Write-Host ""
        $choice = Read-Host "  Opcao"

        if ($choice -eq "0") {
            Write-Info "A voltar ao menu..."
            Start-Sleep -Seconds 1
            return
        }

        if ($choice -eq "S" -or $choice -eq "s") {
            Write-Info "Cancelado pelo utilizador."
            Clear-History -ErrorAction SilentlyContinue`nWrite-Info "Local history cleared for security"`nexit 0
        }

        $toDownload = @()
        if ($choice -eq "A" -or $choice -eq "a") {
            for ($i = 0; $i -lt $links.Count; $i++) {
                $f    = $links[$i]
                $dest = Join-Path $DEST_DIR $f.name
                $complete = $false
                if (Test-Path $dest) {
                    $localSize = (Get-Item $dest).Length
                    $complete  = ($f.size -gt 0 -and $localSize -eq $f.size) -or
                                 ($f.size -eq 0 -and $localSize -gt 0)
                }
                if (-not $complete) { $toDownload += $i }
            }
        } else {
            # MELHORIA: multi-select
            $parsed = Parse-Selection -selection $choice -maxNum $links.Count
            if ($parsed) {
                $toDownload = $parsed
            } else {
                Write-Err "Selecao invalida. Use: 1 ou 1,3,5 ou 1-3"
                Start-Sleep -Seconds 2
                continue
            }
        }

        if ($toDownload.Count -eq 0) {
            Write-Info "Nenhum ficheiro para transferir."
            Start-Sleep -Seconds 2
            Clear-History -ErrorAction SilentlyContinue`nWrite-Info "Local history cleared for security"`nexit 0
        }

        Write-Header
        Write-OK "A transferir $($toDownload.Count) ficheiro(s) â€” 4 conexoes por ficheiro..."
        Write-Host ""

        $ok = 0; $fail = 0
        $total = $toDownload.Count
        $current = 0

        foreach ($idx in $toDownload) {
            $f = $links[$idx]
            $current++

            Write-Host ""
            Write-Host "  ${e}[38;2;255;204;0m>> [$current/$total] $($f.name)${e}[0m"
            Write-Host ""

            $size = if ($f.size) { [long]$f.size } else { 0 }
            $result = Invoke-Download -Url $f.url -Name $f.name -Idx $current -Total $total -Size $size

            if ($result) { $ok++ } else { $fail++ }
        }

        Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
        if ($ok -gt 0)   { Write-OK "$ok ficheiro(s) transferido(s) com sucesso." }
        if ($fail -gt 0) { Write-Err "$fail ficheiro(s) falharam." }
        Write-Host ""
        if ($fail -gt 0) {
            Read-Host "  Pressione ENTER para continuar"
        } else {
            Write-Info "A voltar ao menu..."
            Start-Sleep -Seconds 2
        }
        $retry = 0
        continue
    }

    if ($retry -eq 0) {
        Write-Warn "Links expirados. A aguardar renovacao pelo tecnico..."
        Write-Info "A verificar de 5 em 5 segundos (max 5 min). Prima Ctrl+C para cancelar."
        Write-Host ""

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
Clear-History -ErrorAction SilentlyContinue`nWrite-Info "Local history cleared for security"`nexit 1


