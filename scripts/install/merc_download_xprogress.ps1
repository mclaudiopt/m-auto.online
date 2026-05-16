# install/merc_download_xprogress.ps1 - Mercedes Download TEST (xProgress + aria2c RPC)
# Tests: xProgress module + aria2c JSON-RPC for real connection count and speed
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null
$e = [char]27

$LINKS_URL = "https://m-auto.online/merc_links.json"
$DEST_DIR  = "C:\M-auto\Temp"
$LOG_DIR   = "C:\M-auto\Logs"
$RPC_PORT  = 6801   # different port from default to avoid conflicts
$CONNECTIONS = 16

$FILE_ALIASES = @{
    "FullFix By Samik v4.9.3.exe"             = "Fix Base"
    "FullFix for Xentry and Truck v9.0.6.exe" = "Fix Full"
}

if (-not (Test-Path $DEST_DIR)) { New-Item -ItemType Directory -Path $DEST_DIR -Force | Out-Null }
if (-not (Test-Path $LOG_DIR))  { New-Item -ItemType Directory -Path $LOG_DIR  -Force | Out-Null }

#-- Helpers ------------------------------------------------------------------
function Write-Header {
    Clear-Host
    Write-Host ""
    Write-Host "  ${e}[38;2;255;195;0m${e}[1mMercedes Full Pack${e}[0m  ${e}[38;2;180;140;0mDownload${e}[0m  ${e}[38;2;100;80;0m[TEST $([char]0x2014) xProgress + RPC]${e}[0m"
    Write-Host "  ${e}[38;2;100;80;0m$(([string][char]0x2500) * 62)${e}[0m"
    Write-Host ""
}
function Write-OK($msg)   { Write-Host "  ${e}[38;2;34;197;94m$([char]0x2713)${e}[0m  $msg" }
function Write-Err($msg)  { Write-Host "  ${e}[38;2;239;68;68m$([char]0x2717)${e}[0m  $msg" }
function Write-Warn($msg) { Write-Host "  ${e}[38;2;255;195;0m!${e}[0m  $msg" }
function Write-Info($msg) { Write-Host "  ${e}[38;2;120;100;40m$([char]0x00B7)${e}[0m  ${e}[38;2;180;160;80m$msg${e}[0m" }

#-- Instalar/importar xProgress ----------------------------------------------
function Import-XProgress {
    # Already loaded?
    if (Get-Module -Name xProgress -ErrorAction SilentlyContinue) { return $true }
    # Installed but not loaded?
    if (Get-Module -ListAvailable -Name xProgress -ErrorAction SilentlyContinue) {
        try {
            Import-Module xProgress -ErrorAction Stop
            return $true
        } catch {
            Write-Warn "xProgress instalado mas nao pode ser carregado (execution policy?). A usar fallback."
            return $false
        }
    }
    # Not installed — try to install
    Write-Info "Modulo xProgress nao instalado $([char]0x2014) a instalar..."
    try {
        $null = Install-Module -Name xProgress -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
        Import-Module xProgress -ErrorAction Stop
        Write-OK "xProgress instalado e importado."
        return $true
    } catch {
        Write-Warn "Falha ao instalar/carregar xProgress: $_"
        Write-Info "A usar Write-Progress nativo como fallback."
        return $false
    }
}

#-- Obter links --------------------------------------------------------------
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
        return @($json.files)
    } catch { return $null }
}

#-- Instalar aria2c ----------------------------------------------------------
function Install-Aria2c {
    $aria2Path = "C:\M-auto\Tools\aria2c.exe"
    if (Test-Path $aria2Path) { return $aria2Path }
    Write-Info "A transferir aria2c..."
    $aria2Url = "https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0-win-64bit-build1.zip"
    $tempZip = "$env:TEMP\aria2_xp.zip"
    $tempDir = "$env:TEMP\aria2_xp_extract"
    try {
        $wc = New-Object System.Net.WebClient
        $global:wcDone2 = $false
        $global:wcErr2  = $null
        $sub1 = Register-ObjectEvent $wc DownloadProgressChanged -Action {
            $p = $Event.SourceEventArgs.ProgressPercentage
            Write-Progress -Activity "Instalando aria2c" -Status "$p%" -PercentComplete $p
        }
        $sub2 = Register-ObjectEvent $wc DownloadFileCompleted -Action {
            $global:wcDone2 = $true; $global:wcErr2 = $Event.SourceEventArgs.Error
        }
        $wc.DownloadFileAsync([Uri]$aria2Url, $tempZip)
        while (-not $global:wcDone2) { Start-Sleep -Milliseconds 300 }
        $wc.Dispose()
        Unregister-Event $sub1.Name -EA SilentlyContinue
        Unregister-Event $sub2.Name -EA SilentlyContinue
        Remove-Job $sub1.Name, $sub2.Name -Force -EA SilentlyContinue
        Write-Progress -Activity "Instalando aria2c" -Completed
        if ($global:wcErr2) { throw $global:wcErr2.Message }
        Expand-Archive $tempZip $tempDir -Force
        $exe = Get-ChildItem $tempDir -Filter "aria2c.exe" -Recurse | Select-Object -First 1
        $toolsDir = "C:\M-auto\Tools"
        if (-not (Test-Path $toolsDir)) { New-Item -ItemType Directory $toolsDir -Force | Out-Null }
        Copy-Item $exe.FullName $aria2Path -Force
        Remove-Item $tempZip, $tempDir -Recurse -Force -EA SilentlyContinue
        Write-OK "aria2c instalado."
        return $aria2Path
    } catch {
        Write-Err "Falha ao instalar aria2c: $_"
        return $null
    }
}

#-- Invocar RPC aria2c -------------------------------------------------------
function Invoke-Aria2RPC {
    param([string]$Method, [object[]]$Params = @())
    try {
        $body = @{ jsonrpc = "2.0"; id = "1"; method = $Method; params = $Params } | ConvertTo-Json -Depth 5
        $resp = Invoke-RestMethod -Uri "http://localhost:$RPC_PORT/jsonrpc" `
            -Method POST -Body $body -ContentType "application/json" -UseBasicParsing -TimeoutSec 2
        return $resp.result
    } catch { return $null }
}

#-- Download com aria2c + RPC + xProgress ------------------------------------
function Invoke-Download {
    param([string]$Url, [string]$Name, [int]$Idx, [int]$Total, [long]$Size = 0,
          [bool]$UseXProgress = $false)

    $dest      = Join-Path $DEST_DIR $Name
    $destDir   = Split-Path $dest -Parent
    $fileName  = Split-Path $dest -Leaf
    $dispName  = if ($FILE_ALIASES.ContainsKey($Name)) { $FILE_ALIASES[$Name] } else { $Name }

    if (-not (Test-Path $destDir)) { New-Item -ItemType Directory $destDir -Force | Out-Null }

    $aria2 = Install-Aria2c
    if (-not $aria2) { Write-Err "aria2c nao disponivel."; return $false }

    # Get remote size if not supplied
    if ($Size -le 0) {
        try {
            $req = [System.Net.HttpWebRequest]::Create($Url)
            $req.Method = "HEAD"; $req.Timeout = 8000; $req.AllowAutoRedirect = $true
            $resp = $req.GetResponse(); $Size = $resp.ContentLength; $resp.Close()
        } catch {}
    }
    $totalMB = if ($Size -gt 0) { [math]::Round($Size / 1MB, 1) } else { 0 }
    Write-Info "Ficheiro: $dispName  ($totalMB MB)"

    # Temp files
    $logFile   = Join-Path $env:TEMP "aria2c_xp_$PID.log"
    $inputFile = Join-Path $env:TEMP "aria2c_xp_input_$PID.txt"
    Remove-Item $logFile, $inputFile -Force -EA SilentlyContinue
    $nl = [System.Environment]::NewLine
    [System.IO.File]::WriteAllText($inputFile, "$Url$nl out=$fileName$nl dir=$destDir$nl",
        [System.Text.UTF8Encoding]::new($false))

    # Proxy
    $proxy = $null
    try {
        $reg = Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -EA Stop
        if ($reg.ProxyEnable -eq 1) { $proxy = $reg.ProxyServer }
    } catch {}

    # Build argument list ($argList $([char]0x2014) never use $args, it's a PS automatic variable)
    $argList = [System.Collections.Generic.List[string]]::new()
    $argList.Add("--max-connection-per-server=$CONNECTIONS")
    $argList.Add("--split=$CONNECTIONS")
    $argList.Add("--min-split-size=1M")
    $argList.Add("--continue=true")
    $argList.Add("--max-tries=5")
    $argList.Add("--retry-wait=3")
    $argList.Add("--timeout=300")
    $argList.Add("--connect-timeout=60")
    $argList.Add("--disable-ipv6=true")
    $argList.Add("--quiet=true")
    $argList.Add("--file-allocation=none")
    $argList.Add("--check-certificate=false")
    $argList.Add("--auto-file-renaming=false")
    $argList.Add("--allow-overwrite=true")
    $argList.Add("--log=$logFile")
    $argList.Add("--log-level=warn")
    # Enable RPC for real-time stats
    $argList.Add("--enable-rpc=true")
    $argList.Add("--rpc-listen-port=$RPC_PORT")
    $argList.Add("--rpc-allow-origin-all=true")
    $argList.Add("--input-file=$inputFile")
    if ($proxy) { $argList.Add("--all-proxy=http://$proxy") }

    Remove-Item "$dest.aria2" -Force -EA SilentlyContinue

    Write-Info "A iniciar aria2c ($CONNECTIONS CN, RPC :$RPC_PORT)..."
    $proc = Start-Process -FilePath $aria2 -ArgumentList $argList.ToArray() -NoNewWindow -PassThru
    if (-not $proc) { Write-Err "Falha ao iniciar aria2c."; return $false }
    Start-Sleep -Milliseconds 800  # give RPC time to start

    # Get GID (max 3s wait)
    $gid   = $null
    $rpcOk = $false

    for ($i = 0; $i -lt 6; $i++) {
        $active = Invoke-Aria2RPC "aria2.tellActive" @(@("gid"))
        if ($active -and $active.Count -gt 0) {
            $gid   = $active[0].gid
            $rpcOk = $true
            break
        }
        Start-Sleep -Milliseconds 500
    }

    if ($rpcOk) {
        Write-Info "RPC ligado  GID=$gid"
    } else {
        Write-Warn "RPC indisponivel $([char]0x2014) a usar polling de ficheiro"
    }
    Write-Host ""

    # xProgress setup
    $xp = $null
    if ($UseXProgress) {
        try {
            $xp = New-xProgress -Activity "[$Idx/$Total] $dispName" -TotalCount 100 -Id $Idx
        } catch { $xp = $null }
    }

    $samples   = [System.Collections.Generic.Queue[object]]::new()
    $startTime = Get-Date
    $lastCN    = 0

    while (-not $proc.HasExited) {
        Start-Sleep -Milliseconds 400
        $now = Get-Date

        # --- Get stats: try RPC first, fall back to file polling ---
        $dlBytes = 0; $speedBps = 0; $cnCount = 0; $rpcUsed = $false

        if ($rpcOk -and $gid) {
            $stat = Invoke-Aria2RPC "aria2.tellStatus" @($gid, @("completedLength","downloadSpeed","connections","status"))
            if ($stat -and $stat.status -ne $null) {
                $dlBytes  = [long]$stat.completedLength
                $speedBps = [long]$stat.downloadSpeed
                $cnCount  = [int]$stat.connections
                $rpcUsed  = $true
                if ($cnCount -gt 0) { $lastCN = $cnCount }
            }
        }

        if (-not $rpcUsed) {
            $dlBytes = if (Test-Path $dest) { (Get-Item $dest).Length } else { 0 }
            $samples.Enqueue([PSCustomObject]@{ t = $now; b = $dlBytes })
            while ($samples.Count -gt 0 -and ($now - $samples.Peek().t).TotalSeconds -gt 3) {
                [void]$samples.Dequeue()
            }
            if ($samples.Count -ge 2) {
                $first = $samples.Peek()
                $dt = ($now - $first.t).TotalSeconds
                if ($dt -gt 0.1) { $speedBps = ($dlBytes - $first.b) / $dt }
            }
        }

        $speedMB  = [math]::Round($speedBps / 1MB, 1)
        $recvMB   = [math]::Round($dlBytes / 1MB, 1)
        $pct      = if ($Size -gt 0) { [math]::Min(99, [math]::Round($dlBytes / $Size * 100)) } else { 0 }
        $etaSecs  = if ($speedBps -gt 100 -and $Size -gt $dlBytes) {
            [int](($Size - $dlBytes) / $speedBps)
        } else { -1 }

        $cnLabel  = if ($lastCN -gt 0) { "$lastCN CN" } else { "-- CN" }
        $src      = if ($rpcUsed) { "RPC" } else { "poll" }
        $status   = "$recvMB/$totalMB MB  |  $speedMB MB/s  |  $cnLabel  |  $src"

        # --- Display progress (Write-Progress for title bar + ANSI bar in console body) ---
        if ($xp -and $UseXProgress) {
            try {
                $xp.CurrentCount = $pct
                Write-xProgress -xProgress $xp -Status $status -SecondsRemaining $etaSecs
            } catch {
                Write-Progress -Activity "[$Idx/$Total] $dispName" -Status $status `
                    -PercentComplete $pct -SecondsRemaining $etaSecs
            }
        } else {
            Write-Progress -Activity "[$Idx/$Total] $dispName" -Status $status `
                -PercentComplete $pct -SecondsRemaining $etaSecs
        }

        # ANSI inline bar $([char]0x2014) always visible in console body regardless of terminal
        $filled   = [math]::Max(0, [math]::Min(40, [math]::Round($pct / 100 * 40)))
        $empty    = 40 - $filled
        $barFill  = "${e}[48;2;255;195;0m" + (" " * $filled) + "${e}[0m"
        $barEmpty = "${e}[48;2;52;40;0m"  + (" " * $empty)  + "${e}[0m"
        $pctStr   = "$pct%".PadLeft(4)
        $etaStr   = if ($etaSecs -gt 0) {
            if ($etaSecs -ge 3600) { "$([math]::Round($etaSecs/3600,1))h" }
            elseif ($etaSecs -ge 60) { "$([math]::Round($etaSecs/60))m" }
            else { "${etaSecs}s" }
        } else { "  " }
        Write-Host -NoNewline "`r  ${e}[1;38;2;255;195;0m$pctStr${e}[0m $barFill$barEmpty  ${e}[38;2;180;160;80m$speedMB MB/s${e}[0m  ${e}[38;2;120;100;40m$cnLabel${e}[0m  ${e}[38;2;100;80;0m$etaStr${e}[0m   "
    }

    # Complete progress $([char]0x2014) move past the ANSI bar line first
    Write-Host ""
    if ($xp -and $UseXProgress) {
        try { Complete-xProgress -xProgress $xp } catch {}
    }
    Write-Progress -Activity "[$Idx/$Total] $dispName" -Completed

    $errOutput = if (Test-Path $logFile) { Get-Content $logFile -Raw -EA SilentlyContinue } else { "" }
    Remove-Item $logFile, $inputFile -Force -EA SilentlyContinue

    if ($proc.ExitCode -eq 0 -and (Test-Path $dest)) {
        $finalMB  = [math]::Round((Get-Item $dest).Length / 1MB, 1)
        $elapsed  = [math]::Round(((Get-Date) - $startTime).TotalSeconds)
        $avgSpeed = if ($elapsed -gt 0 -and $finalMB -gt 0) { [math]::Round($finalMB / $elapsed, 1) } else { 0 }
        $sha256   = (Get-FileHash $dest -Algorithm SHA256).Hash.ToLower()

        Write-OK "$dispName $([char]0x2014) $finalMB MB em ${elapsed}s (media $avgSpeed MB/s, max $CONNECTIONS CN)"
        Write-Host "  ${e}[38;2;100;149;237m[SHA256]${e}[0m $sha256"

        # Log to manifest
        $manifest = Join-Path $LOG_DIR "download_manifest.json"
        $entry = [ordered]@{
            filename  = $Name
            size      = (Get-Item $dest).Length
            sha256    = $sha256
            timestamp = (Get-Date -Format "o")
            avgSpeedMBs = $avgSpeed
            connections = $lastCN
            status    = "success"
        }
        try {
            $data = if (Test-Path $manifest) {
                Get-Content $manifest -Raw | ConvertFrom-Json
            } else {
                [PSCustomObject]@{ downloads = @() }
            }
            $data.downloads = @($data.downloads) + $entry
            $data | ConvertTo-Json -Depth 5 | Set-Content $manifest -Encoding UTF8
        } catch {}

        return $true
    }

    Write-Err "aria2c falhou (saida $($proc.ExitCode))"
    if ($errOutput) {
        $errOutput.Trim() -split "`n" | Where-Object { $_.Trim() } | ForEach-Object {
            Write-Host "  ${e}[38;2;239;68;68m  $($_.Trim())${e}[0m"
        }
    }
    return $false
}

# =============================================================================
# Main
# =============================================================================
Write-Header
Write-Info "Script de teste: xProgress + aria2c JSON-RPC"
Write-Host ""

# Import xProgress
$useXP = Import-XProgress
Write-Info "Modo de progresso: $(if ($useXP) { 'xProgress (modulo)' } else { 'Write-Progress (nativo)' })"
Write-Host ""

# Get links
$links = Get-Links
if (-not $links) {
    Write-Err "Links expirados ou indisponiveis."
    Read-Host "  Pressione ENTER para sair"
    exit 1
}

# File table
$maxName = ($links | ForEach-Object {
    $n = if ($FILE_ALIASES.ContainsKey($_.name)) { $FILE_ALIASES[$_.name] } else { $_.name }
    $n.Length
} | Measure-Object -Maximum).Maximum
$nameW  = [math]::Max($maxName, 10)
$sep    = ([string][char]0x2500)

Write-Host "  ${e}[38;2;255;195;0m${e}[1m$("  Nr".PadRight(5)) $("Ficheiro".PadRight($nameW+2)) $("Tamanho".PadLeft(10))  Estado${e}[0m"
Write-Host "  ${e}[38;2;100;80;0m$($sep*4)  $($sep*($nameW+2))  $($sep*9)  $($sep*12)${e}[0m"

for ($i = 0; $i -lt $links.Count; $i++) {
    $f    = $links[$i]
    $dest = Join-Path $DEST_DIR $f.name
    $dn   = if ($FILE_ALIASES.ContainsKey($f.name)) { $FILE_ALIASES[$f.name] } else { $f.name }
    $num  = ($i+1).ToString().PadLeft(3)
    $szMB = if ($f.size -gt 0) { "$([math]::Round($f.size/1MB,1)) MB".PadLeft(9) } else { "  ? MB".PadLeft(9) }

    if (Test-Path $dest) {
        $lMB = "$([math]::Round((Get-Item $dest).Length/1MB,1)) MB".PadLeft(9)
        Write-Host "  ${e}[38;2;100;80;20m$num${e}[0m  ${e}[38;2;160;130;40m$($dn.PadRight($nameW+2))${e}[0m $lMB  ${e}[38;2;34;197;94m$([char]0x2713) local${e}[0m"
    } else {
        Write-Host "  ${e}[38;2;255;195;0m$num${e}[0m  ${e}[38;2;220;180;60m$($dn.PadRight($nameW+2))${e}[0m $szMB  ${e}[38;2;100;80;0m– pendente${e}[0m"
    }
}

Write-Host "  ${e}[38;2;100;80;0m$($sep*($nameW+30))${e}[0m"
Write-Host ""
Write-Host "  ${e}[38;2;100;80;0m$($sep*62)${e}[0m"
Write-Host "  ${e}[38;2;255;195;0m[ENTER]${e}[0m  Iniciar todos os downloads em falta  ${e}[38;2;100;80;0m($CONNECTIONS conexoes + RPC)${e}[0m"
Write-Host "  ${e}[38;2;180;160;80m[1-N]${e}[0m    Selecionar ficheiro(s)               ${e}[38;2;100;80;0m(ex: 2  ou  1,3  ou  2-4)${e}[0m"
Write-Host "  ${e}[38;2;239;68;68m[0]${e}[0m      Voltar"
Write-Host ""
Write-Host -NoNewline "  ${e}[38;2;255;195;0m$([char]0x203A)${e}[0m  Opcao [ENTER=todos / 0=voltar]: "
$choice = $Host.UI.ReadLine()
if ([string]::IsNullOrWhiteSpace($choice)) { $choice = "A" }

if ($choice -eq "0") {
    Write-Info "A voltar..."
    Clear-History -EA SilentlyContinue
    return
}

# Build download list
$toDownload = @()
if ($choice -eq "A" -or $choice -eq "a") {
    for ($i = 0; $i -lt $links.Count; $i++) {
        $dest = Join-Path $DEST_DIR $links[$i].name
        $ok   = $false
        if (Test-Path $dest) {
            $lsz = (Get-Item $dest).Length
            $ok  = ($links[$i].size -gt 0 -and $lsz -eq $links[$i].size) -or
                   ($links[$i].size -eq 0 -and $lsz -gt 0)
        }
        if (-not $ok) { $toDownload += $i }
    }
} else {
    # Parse selection
    $selected = @()
    foreach ($part in ($choice -split ',')) {
        $part = $part.Trim()
        if ($part -match '^(\d+)-(\d+)$') {
            for ($x = [int]$Matches[1]; $x -le [int]$Matches[2]; $x++) {
                if ($x -ge 1 -and $x -le $links.Count) { $selected += $x - 1 }
            }
        } elseif ($part -match '^\d+$') {
            $n = [int]$part
            if ($n -ge 1 -and $n -le $links.Count) { $selected += $n - 1 }
        }
    }
    $toDownload = @($selected | Sort-Object -Unique)
}

if ($toDownload.Count -eq 0) {
    Write-OK "Todos os ficheiros ja existem."
    Start-Sleep -Seconds 2
    Clear-History -EA SilentlyContinue
    exit 0
}

Write-Header
Write-OK "A iniciar $($toDownload.Count) download(s) $([char]0x2014) $CONNECTIONS conexoes + aria2c RPC"
Write-Host ""

$ok = 0; $fail = 0; $current = 0; $startAll = Get-Date

foreach ($idx in $toDownload) {
    $f = $links[$idx]
    $current++
    $dn   = if ($FILE_ALIASES.ContainsKey($f.name)) { $FILE_ALIASES[$f.name] } else { $f.name }
    $size = if ($f.size) { [long]$f.size } else { 0 }

    Write-Host "  ${e}[38;2;255;195;0m>> [$current/$($toDownload.Count)]${e}[0m  ${e}[38;2;220;180;60m$dn${e}[0m"
    Write-Host ""

    $result = Invoke-Download -Url $f.url -Name $f.name -Idx $current `
        -Total $toDownload.Count -Size $size -UseXProgress $useXP

    if ($result) { $ok++ } else { $fail++ }
    Write-Host ""
}

$elapsed = [math]::Round(((Get-Date) - $startAll).TotalSeconds)
Write-Host "  ${e}[38;2;100;80;0m$($sep * 62)${e}[0m"
if ($ok   -gt 0) { Write-OK   "$ok ficheiro(s) transferido(s) com sucesso  (${elapsed}s total)" }
if ($fail -gt 0) { Write-Err  "$fail ficheiro(s) falharam" }
Write-Host ""

if ($fail -gt 0) {
    Read-Host "  Pressione ENTER para continuar"
} else {
    Write-Info "Concluido. A voltar em 3s..."
    Start-Sleep -Seconds 3
}

Clear-History -EA SilentlyContinue
