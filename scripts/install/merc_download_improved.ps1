# install/merc_download.ps1 - Mercedes Full Pack Download (IMPROVED)
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

#-- Helpers com cores melhoradas ---------------------------------------------
function Write-Header {
    Clear-Host
    Write-Host ""
    Write-Host "  ${e}[38;2;29;155;255m╔══════════════════════════════════════════════════════╗${e}[0m"
    Write-Host "  ${e}[38;2;29;155;255m║${e}[0m  ${e}[1;97mMercedes Full Pack${e}[0m  ${e}[38;2;100;149;237m│  Download Manager${e}[0m           ${e}[38;2;29;155;255m║${e}[0m"
    Write-Host "  ${e}[38;2;29;155;255m╚══════════════════════════════════════════════════════╝${e}[0m"
    Write-Host ""
}

function Write-OK($msg)   { Write-Host "  ${e}[38;2;46;204;113m✓${e}[0m  ${e}[38;2;46;204;113m$msg${e}[0m" }
function Write-Err($msg)  { Write-Host "  ${e}[38;2;239;68;68m✗${e}[0m  ${e}[38;2;239;68;68m$msg${e}[0m" }
function Write-Warn($msg) { Write-Host "  ${e}[38;2;250;204;21m⚠${e}[0m  ${e}[38;2;250;204;21m$msg${e}[0m" }
function Write-Info($msg) { Write-Host "  ${e}[38;2;148;163;184m●${e}[0m  ${e}[38;2;148;163;184m$msg${e}[0m" }
function Write-Progress($msg) { Write-Host "  ${e}[38;2;52;152;219m▶${e}[0m  ${e}[38;2;52;152;219m$msg${e}[0m" }

#-- Box drawing para status --------------------------------------------------
function Write-StatusBox($title, $items) {
    $width = 54
    Write-Host "  ${e}[38;2;100;149;237m┌$('─' * $width)┐${e}[0m"
    Write-Host "  ${e}[38;2;100;149;237m│${e}[0m ${e}[1;97m$title${e}[0m$(' ' * ($width - $title.Length - 1))${e}[38;2;100;149;237m│${e}[0m"
    Write-Host "  ${e}[38;2;100;149;237m├$('─' * $width)┤${e}[0m"
    foreach ($item in $items) {
        $text = "  $($item.icon) $($item.text)"
        $padding = $width - ($text.Length - 20)  # Ajuste para ANSI codes
        Write-Host "  ${e}[38;2;100;149;237m│${e}[0m$text$(' ' * $padding)${e}[38;2;100;149;237m│${e}[0m"
    }
    Write-Host "  ${e}[38;2;100;149;237m└$('─' * $width)┘${e}[0m"
}

#-- Barra de progresso melhorada com gradiente -------------------------------
function Get-ProgressBar($percent, $width = 50) {
    $filled = [math]::Round($percent / 100 * $width)
    $empty = $width - $filled

    # Gradiente de cores baseado no progresso
    $color = if ($percent -ge 100) {
        "46;204;113"  # Verde
    } elseif ($percent -ge 75) {
        "52;211;153"  # Verde claro
    } elseif ($percent -ge 50) {
        "59;130;246"  # Azul
    } elseif ($percent -ge 25) {
        "96;165;250"  # Azul claro
    } else {
        "148;163;184"  # Cinza
    }

    $barFill = "${e}[48;2;${color}m" + ("█" * $filled) + "${e}[0m"
    $barEmpty = "${e}[48;2;30;41;59m" + ("░" * $empty) + "${e}[0m"

    return "$barFill$barEmpty"
}

#-- Formatar tamanho de ficheiro ---------------------------------------------
function Format-FileSize($bytes) {
    if ($bytes -ge 1GB) {
        return "{0:N2} GB" -f ($bytes / 1GB)
    } elseif ($bytes -ge 1MB) {
        return "{0:N1} MB" -f ($bytes / 1MB)
    } elseif ($bytes -ge 1KB) {
        return "{0:N0} KB" -f ($bytes / 1KB)
    } else {
        return "$bytes B"
    }
}

#-- Formatar tempo restante --------------------------------------------------
function Format-ETA($seconds) {
    if ($seconds -lt 0) { return "--:--" }
    if ($seconds -ge 3600) {
        $h = [int]($seconds / 3600)
        $m = [int](($seconds % 3600) / 60)
        return "${h}h ${m}m"
    } elseif ($seconds -ge 60) {
        $m = [int]($seconds / 60)
        $s = [int]($seconds % 60)
        return "${m}m ${s}s"
    } else {
        return "${seconds}s"
    }
}

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

#-- Verificar links com melhor feedback --------------------------------------
function Get-Links {
    Write-Progress "A verificar links disponiveis..."
    try {
        $url = "$LINKS_URL`?t=$([DateTimeOffset]::UtcNow.ToUnixTimeSeconds())"
        $raw = irm $url -UseBasicParsing -TimeoutSec 8 -ErrorAction Stop
        $json = if ($raw -is [string]) { $raw | ConvertFrom-Json } else { $raw }

        if ([string]::IsNullOrWhiteSpace($json.expires)) {
            Write-Warn "JSON sem campo 'expires'"
            return $null
        }
        if (-not $json.files -or $json.files.Count -eq 0) {
            Write-Warn "Nenhum ficheiro disponivel"
            return $null
        }

        $exp = [datetime]::Parse($json.expires,
            [System.Globalization.CultureInfo]::InvariantCulture,
            [System.Globalization.DateTimeStyles]::RoundtripKind)

        if ((Get-Date).ToUniversalTime() -gt $exp.ToUniversalTime()) {
            Write-Warn "Links expirados em $($exp.ToString('yyyy-MM-dd HH:mm:ss'))"
            return $null
        }

        $timeLeft = $exp.ToUniversalTime() - (Get-Date).ToUniversalTime()
        Write-OK "Links validos — expira em $(Format-ETA $timeLeft.TotalSeconds)"
        return $json.files
    } catch {
        Write-Err "Erro ao verificar links: $_"
        return $null
    }
}

#-- Instalar aria2c com barra de progresso -----------------------------------
function Install-Aria2c {
    $aria2Path = "C:\M-auto\Tools\aria2c.exe"
    if (Test-Path $aria2Path) { return $aria2Path }

    Write-Progress "A transferir aria2c (gestor de downloads)..."
    $aria2Url = "https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0-win-64bit-build1.zip"
    $tempZip = "$env:TEMP\aria2.zip"
    $tempDir = "$env:TEMP\aria2_extract"

    try {
        $wc = New-Object System.Net.WebClient
        $global:wcDone = $false
        $global:wcError = $null

        $progressSub = Register-ObjectEvent -InputObject $wc -EventName DownloadProgressChanged -Action {
            $pct = $Event.SourceEventArgs.ProgressPercentage
            $recv = [math]::Round($Event.SourceEventArgs.BytesReceived / 1MB, 1)
            $total = [math]::Round($Event.SourceEventArgs.TotalBytesToReceive / 1MB, 1)

            $bar = Get-ProgressBar $pct 40
            Write-Host -NoNewline "`r  ${e}[1;97m$($pct.ToString().PadLeft(3))%${e}[0m $bar  ${e}[90m$recv / $total MB${e}[0m   "
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

        Write-Progress "A extrair aria2c..."
        Expand-Archive -Path $tempZip -DestinationPath $tempDir -Force
        $aria2Exe = Get-ChildItem -Path $tempDir -Filter "aria2c.exe" -Recurse | Select-Object -First 1

        $toolsDir = "C:\M-auto\Tools"
        if (-not (Test-Path $toolsDir)) { New-Item -ItemType Directory -Path $toolsDir -Force | Out-Null }

        Copy-Item $aria2Exe.FullName -Destination $aria2Path -Force
        Remove-Item $tempZip, $tempDir -Recurse -Force -ErrorAction SilentlyContinue

        Write-OK "aria2c instalado com sucesso"
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
        $len = $resp.ContentLength
        $resp.Close()
        return $len
    } catch { return 0 }
}

#-- Download com aria2c e barra melhorada ------------------------------------
function Invoke-Download {
    param([string]$Url, [string]$Name, [int]$Idx, [int]$Total, [long]$Size = 0)

    $dest = Join-Path $DEST_DIR $Name
    $destDir = Split-Path $dest -Parent
    $fileName = Split-Path $dest -Leaf
    $width = 50

    if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }

    $aria2 = Install-Aria2c
    if (-not $aria2) { Write-Err "aria2c nao disponivel"; return $false }

    $totalBytes = if ($Size -gt 0) { $Size } else { Get-RemoteSize -Url $Url }
    $totalSize = Format-FileSize $totalBytes

    Write-Host ""
    Write-Host "  ${e}[38;2;100;149;237m┌─ Download [$Idx/$Total] ─────────────────────────────────────┐${e}[0m"
    Write-Host "  ${e}[38;2;100;149;237m│${e}[0m ${e}[1;97m$Name${e}[0m"
    Write-Host "  ${e}[38;2;100;149;237m│${e}[0m ${e}[38;2;148;163;184mTamanho: $totalSize${e}[0m"
    Write-Host "  ${e}[38;2;100;149;237m└──────────────────────────────────────────────────────────────┘${e}[0m"
    Write-Host ""

    $proxy = Get-ProxyConfig
    $cn = if ($totalBytes -gt 0 -and $totalBytes -lt 5MB) { 4 } else { 16 }

    $argList = [System.Collections.Generic.List[string]]::new()
    $argList.Add("--max-connection-per-server=$cn")
    $argList.Add("--split=$cn")
    $argList.Add("--min-split-size=1M")
    $argList.Add("--continue=true")
    $argList.Add("--max-tries=3")
    $argList.Add("--retry-wait=2")
    $argList.Add("--timeout=60")
    $argList.Add("--connect-timeout=30")
    $argList.Add("--console-log-level=error")
    $argList.Add("--summary-interval=0")
    $argList.Add("--file-allocation=none")
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

    $argStr = ($argList.ToArray() | ForEach-Object {
        if ($_ -match ' ') { '"' + $_ + '"' } else { $_ }
    }) -join ' '

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $aria2
    $psi.Arguments = $argStr
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $proc = [System.Diagnostics.Process]::Start($psi)

    $startTime = Get-Date
    $startBytes = if (Test-Path $dest) { (Get-Item $dest).Length } else { 0 }
    $prevBytes = $startBytes
    $samples = [System.Collections.Generic.Queue[object]]::new()
    $spinIdx = 0
    $spinChars = @('⠋','⠙','⠹','⠸','⠼','⠴','⠦','⠧','⠇','⠏')

    while (-not $proc.HasExited) {
        Start-Sleep -Milliseconds 400

        $now = Get-Date
        $dlBytes = if (Test-Path $dest) { (Get-Item $dest).Length } else { 0 }
        $recvSize = Format-FileSize $dlBytes

        $samples.Enqueue([PSCustomObject]@{ t = $now; b = $dlBytes })
        while ($samples.Count -gt 0 -and ($now - $samples.Peek().t).TotalSeconds -gt 3) {
            [void]$samples.Dequeue()
        }

        $speedMB = 0
        if ($samples.Count -ge 2) {
            $first = $samples.Peek()
            $dt = ($now - $first.t).TotalSeconds
            if ($dt -gt 0.1) { $speedMB = [math]::Round(($dlBytes - $first.b) / $dt / 1MB, 1) }
        }
        $prevBytes = $dlBytes
        $spdStr = if ($speedMB -gt 0) { "$speedMB MB/s" } else { "-- MB/s" }

        if ($totalBytes -gt 0) {
            $rawPct = [math]::Round($dlBytes / $totalBytes * 100)
            $verifying = ($dlBytes -ge $totalBytes)
            $pct = if ($verifying) { 100 } else { [math]::Min(99, $rawPct) }

            $eta = if ($verifying) {
                "verificando"
            } elseif ($speedMB -gt 0.01 -and $totalBytes -gt $dlBytes) {
                $s = [int](($totalBytes - $dlBytes) / ($speedMB * 1MB))
                Format-ETA $s
            } else { "--:--" }

            $bar = Get-ProgressBar $pct $width
            $pctText = "${e}[1;97m$($pct.ToString().PadLeft(3))%${e}[0m"
            Write-Host -NoNewline "`r  $pctText $bar ${e}[90m$recvSize/$totalSize  $spdStr  ETA $eta${e}[0m  "
        } else {
            $spin = $spinChars[$spinIdx % $spinChars.Count]; $spinIdx++
            $pulse = $spinIdx % ($width * 2)
            $pos = if ($pulse -lt $width) { $pulse } else { $width * 2 - $pulse }
            $pos = [math]::Max(0, [math]::Min($pos, $width - 2))
            $bar = (" " * $pos) + "${e}[48;2;52;152;219m██${e}[0m" + (" " * ($width - $pos - 2))
            Write-Host -NoNewline "`r  ${e}[1;97m$spin${e}[0m [$bar] ${e}[90m$recvSize  $spdStr${e}[0m  "
        }
    }

    $errOutput = if (Test-Path $logFile) { Get-Content $logFile -Raw -ErrorAction SilentlyContinue } else { "" }
    Remove-Item $logFile -Force -ErrorAction SilentlyContinue
    Write-Host ""

    if ($proc.ExitCode -eq 0 -and (Test-Path $dest)) {
        $finalSize = Format-FileSize (Get-Item $dest).Length
        Write-OK "$Name transferido ($finalSize)"
        return $true
    }

    Write-Err "Download falhou (codigo $($proc.ExitCode))"
    if ($errOutput -and $errOutput.Trim()) {
        $errOutput.Trim() -split "`n" | Where-Object { $_.Trim() } | ForEach-Object {
            Write-Host "  ${e}[38;2;239;68;68m    $($_.Trim())${e}[0m"
        }
    }
    return $false
}

#-- Loop principal com menu melhorado ----------------------------------------
Write-Header

if (-not (Test-WritePermissions)) {
    Start-Sleep -Seconds 3
    exit 1
}

$proxy = Get-ProxyConfig
if ($proxy) {
    Write-Info "Proxy detetado: $proxy"
}

$maxRetries = 60
$retry = 0

while ($retry -lt $maxRetries) {
    $links = Get-Links

    if ($links) {
        Write-Header

        # Criar lista de status
        $statusItems = @()
        for ($i = 0; $i -lt $links.Count; $i++) {
            $f = $links[$i]
            $dest = Join-Path $DEST_DIR $f.name
            $num = $i + 1
            $displayName = if ($FILE_ALIASES.ContainsKey($f.name)) { $FILE_ALIASES[$f.name] } else { $f.name }

            if (Test-Path $dest) {
                $size = Format-FileSize (Get-Item $dest).Length
                $statusItems += @{
                    icon = "${e}[38;2;46;204;113m✓${e}[0m"
                    text = "${e}[38;2;148;163;184m[$num]${e}[0m ${e}[97m$displayName${e}[0m ${e}[38;2;100;130;100m($size)${e}[0m"
                }
            } else {
                $statusItems += @{
                    icon = "${e}[38;2;250;204;21m○${e}[0m"
                    text = "${e}[38;2;148;163;184m[$num]${e}[0m ${e}[97m$displayName${e}[0m ${e}[38;2;148;163;184m(pendente)${e}[0m"
                }
            }
        }

        Write-StatusBox "Ficheiros Disponiveis ($($links.Count))" $statusItems
        Write-Host ""
        Write-Host "  ${e}[38;2;148;163;184mOpcoes:${e}[0m"
        Write-Host "    ${e}[38;2;52;152;219m[A]${e}[0m Transferir todos os ficheiros em falta"
        Write-Host "    ${e}[38;2;52;152;219m[1-$($links.Count)]${e}[0m Transferir ficheiro especifico"
        Write-Host "    ${e}[38;2;239;68;68m[S]${e}[0m Sair"
        Write-Host ""
        $choice = Read-Host "  Escolha"

        if ($choice -eq "S" -or $choice -eq "s") {
            Write-Info "Cancelado pelo utilizador"
            exit 0
        }

        $toDownload = @()
        if ($choice -eq "A" -or $choice -eq "a") {
            for ($i = 0; $i -lt $links.Count; $i++) {
                $f = $links[$i]
                $dest = Join-Path $DEST_DIR $f.name
                $complete = $false
                if (Test-Path $dest) {
                    $localSize = (Get-Item $dest).Length
                    $complete = ($f.size -gt 0 -and $localSize -eq $f.size) -or ($f.size -eq 0 -and $localSize -gt 0)
                }
                if (-not $complete) { $toDownload += $i }
            }
        } elseif ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $links.Count) {
            $toDownload += ([int]$choice - 1)
        } else {
            Write-Err "Opcao invalida"
            Start-Sleep -Seconds 2
            continue
        }

        if ($toDownload.Count -eq 0) {
            Write-OK "Todos os ficheiros ja foram transferidos"
            Start-Sleep -Seconds 2
            exit 0
        }

        Write-Header
        Write-Progress "A iniciar downloads ($($toDownload.Count) ficheiro(s))..."
        Write-Host ""

        $ok = 0; $fail = 0
        $total = $toDownload.Count
        $current = 0

        foreach ($idx in $toDownload) {
            $f = $links[$idx]
            $current++
            $size = if ($f.size) { [long]$f.size } else { 0 }
            $result = Invoke-Download -Url $f.url -Name $f.name -Idx $current -Total $total -Size $size
            if ($result) { $ok++ } else { $fail++ }
        }

        Write-Host ""
        Write-Host "  ${e}[38;2;100;149;237m═══════════════════════════════════════════════════════${e}[0m"
        if ($ok -gt 0) { Write-OK "$ok ficheiro(s) transferido(s) com sucesso" }
        if ($fail -gt 0) { Write-Err "$fail ficheiro(s) falharam" }
        Write-Host ""

        if ($fail -gt 0) {
            Read-Host "  Pressione ENTER para continuar"
        } else {
            Write-Info "Concluido! A voltar ao menu..."
            Start-Sleep -Seconds 2
        }
        $retry = 0
        continue
    }

    if ($retry -eq 0) {
        Write-Warn "Links expirados ou indisponiveis"
        Write-Info "A verificar automaticamente de 5 em 5 segundos..."
        Write-Info "Prima Ctrl+C para cancelar"
        Write-Host ""
    }

    $retry++
    $ts = Get-Date -Format "HH:mm:ss"
    $remaining = $maxRetries - $retry
    Write-Host -NoNewline "`r  ${e}[38;2;148;163;184m[$ts]${e}[0m A aguardar... (${remaining}s restantes)  "
    Start-Sleep -Seconds 5
}

Write-Host ""
Write-Err "Timeout: links nao renovados apos 5 minutos"
Write-Host ""
Read-Host "  Pressione ENTER para sair"
exit 1
