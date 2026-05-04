# install/merc_full_pack.ps1 - Mercedes Full Pack 2026
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null
$e = [char]27

#-- Helpers ------------------------------------------------------------------
function Write-Step($msg) { Write-Host "  ${e}[38;2;100;149;237m[..]${e}[0m  $msg" }
function Write-OK($msg)   { Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m  $msg" }
function Write-Err($msg)  { Write-Host "  ${e}[38;2;239;68;68m[X]${e}[0m   $msg" }
function Write-Warn($msg) { Write-Host "  ${e}[38;2;250;204;21m[!]${e}[0m   $msg" }
function Write-Skip($msg) { Write-Host "  ${e}[38;2;80;100;140m[--]${e}[0m  $msg  ${e}[38;2;80;100;140m(skip)${e}[0m" }
function Write-Sep       { Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m" }

function Invoke-Extract {
    param([string]$szExe, [string]$Source, [string]$Dest, [string]$Pass = "")
    Clear-Host
    Write-Host ""
    Write-Host "  ${e}[1;97mA extrair...${e}[0m"
    Write-Host "  ${e}[38;2;148;163;184m  $(Split-Path $Source -Leaf)${e}[0m"
    Write-Host ""

    $xArgs = @("x", $Source, "-o$Dest", "-bsp1", "-y")
    if ($Pass) { $xArgs += "-p$Pass" }

    $lastP = -1
    & $szExe @xArgs | ForEach-Object {
        if ($_ -match '^\s*(\d+)%') {
            $p = [int]$Matches[1]
            if ($p -ne $lastP) {
                $lastP = $p
                $filled = [math]::Round($p / 100 * 50)
                $bar    = ("#" * $filled).PadRight(50, '-')
                Write-Host -NoNewline "`r  [${e}[38;2;100;149;237m$bar${e}[0m] $p%   "
            }
        }
    }
    $rc = $LASTEXITCODE
    if ($rc -eq 0) {
        $bar = "#" * 50
        Write-Host "`r  [${e}[38;2;34;197;94m$bar${e}[0m] 100%"
    }
    Write-Host ""
    return $rc
}

function Find-7Zip {
    $paths = @(
        "C:\Program Files\7-Zip\7z.exe",
        "C:\Program Files (x86)\7-Zip\7z.exe"
    )
    foreach ($p in $paths) { if (Test-Path $p) { return $p } }
    $found = Get-Command "7z.exe" -ErrorAction SilentlyContinue
    if ($found) { return $found.Source }
    return $null
}

function Resolve-Desktop {
    $candidates = [System.Collections.Generic.List[string]]::new()
    try {
        $loggedUser = (Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue).UserName
        if ($loggedUser -match '\\') {
            $uname = $loggedUser.Split('\')[-1]
            $uProfile = "C:\Users\$uname"
            $candidates.Add("$uProfile\OneDrive\Desktop")
            $candidates.Add("$uProfile\Desktop")
        }
    } catch {}
    try {
        $reg = [Environment]::ExpandEnvironmentVariables(
            (Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" `
                -Name "Desktop" -ErrorAction Stop).Desktop)
        $candidates.Add($reg)
    } catch {}
    Get-ChildItem "C:\Users" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $candidates.Add("$($_.FullName)\OneDrive\Desktop")
        $candidates.Add("$($_.FullName)\Desktop")
    }
    foreach ($path in $candidates) {
        if ($path -and (Test-Path $path)) { return $path }
    }
    return $null
}

function New-DesktopShortcut {
    param([string]$Desktop, [string]$Name, [string]$Target, [string]$Icon = "")
    $lnkPath = "$Desktop\$Name.lnk"
    try {
        $shell = New-Object -ComObject WScript.Shell
        $sc = $shell.CreateShortcut($lnkPath)
        $sc.TargetPath = $Target
        if ($Icon) { $sc.IconLocation = $Icon }
        $sc.Save()
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($shell) | Out-Null
        return $true
    } catch { return $false }
}

#-- Definicao das operacoes --------------------------------------------------
$ops = @(
    @{ Label = "EWA"              ; File = "C:\M-auto\Temp\ewa.7z"                     },
    @{ Label = "StarFinder 2024"  ; File = "C:\M-auto\Temp\Startfifinder 2024.7z"      },
    @{ Label = "SDMEDIA"          ; File = "C:\M-auto\Temp\SDMEDIA.zip"                 },
    @{ Label = "Coding Tutorials" ; File = "C:\M-auto\Temp\Coding tutorials full.7z"   },
    @{ Label = "Databases"        ; File = "C:\M-auto\Temp\Databases.7z"               },
    @{ Label = "WIS 2021"         ; File = "C:\M-auto\Temp\wis2021.rar"                }
)

$LINKS_JSON = "https://m-auto.online/scripts/data/merc_links.json"
$ARIA        = "$env:TEMP\aria2c.exe"
$RPC         = "http://localhost:6801/jsonrpc"
$TOK         = "mauto2026"

#-- Download helpers ---------------------------------------------------------
function Ensure-Aria2c {
    if (Test-Path $ARIA) { return $true }
    Write-Step "A instalar aria2c..."
    try {
        $zip = "$env:TEMP\aria2.zip"
        Invoke-WebRequest "https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0-win-64bit-build1.zip" -OutFile $zip -UseBasicParsing
        Expand-Archive $zip -DestinationPath "$env:TEMP\aria2x" -Force
        Copy-Item "$env:TEMP\aria2x\aria2-1.37.0-win-64bit-build1\aria2c.exe" $ARIA -Force
        Remove-Item $zip, "$env:TEMP\aria2x" -Recurse -Force -EA SilentlyContinue
        Write-OK "aria2c pronto."
        return $true
    } catch { Write-Err "Erro ao instalar aria2c: $_"; return $false }
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
    } else {
        try {
            Invoke-RestMethod -Uri $RPC -Method Post -Body '{"jsonrpc":"2.0","id":"1","method":"aria2.getVersion","params":["token:mauto2026"]}' -ContentType "application/json" -TimeoutSec 2 -EA Stop | Out-Null
            return $null
        } catch {
            $proc = Start-Process -FilePath $ARIA -ArgumentList "--enable-rpc --rpc-listen-port=6801 --rpc-secret=$TOK --rpc-allow-origin-all --file-allocation=none --quiet=true --disable-ipv6=true" -PassThru -WindowStyle Hidden
            Start-Sleep -Milliseconds 1200
            return $proc
        }
    }
}

function Invoke-Aria2cDownload($url, $fileName) {
    $barW = 36; $lastDown = 0; $lastTick = [DateTime]::Now
    $opts = @{ dir = "C:\M-AUTO\Temp"; out = $fileName; split = "32"; "max-connection-per-server" = "32"; "min-split-size" = "4M" }
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

function Show-DownloadMenu {
    # Fetch links JSON
    Write-Host ""
    Write-Step "A obter links de m-auto.online..."
    try {
        $links = Invoke-RestMethod -Uri $LINKS_JSON -UseBasicParsing -TimeoutSec 15
    } catch {
        Write-Err "Nao foi possivel obter links: $_"
        Write-Host ""; Read-Host "  ENTER para voltar"; return
    }

    while ($true) {
        Clear-Host
        Write-Host ""
        Write-Host "  ${e}[1;97mMercedes Full Pack${e}[0m  ${e}[38;2;100;149;237mDownload${e}[0m"
        Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
        Write-Host ""

        $i = 0
        foreach ($lnk in $links) {
            $i++
            $exists = Test-Path "C:\M-AUTO\Temp\$($lnk.dest)"
            $tag = if ($exists) { "${e}[38;2;34;197;94m OK ${e}[0m" } else { "${e}[38;2;80;100;140mN/A${e}[0m" }
            $expStr = ""
            if ($lnk.expires) {
                $exp = [datetime]::Parse($lnk.expires)
                $left = ($exp - (Get-Date)).TotalHours
                $expStr = if ($left -lt 0) { "  ${e}[38;2;239;68;68m[expirado]${e}[0m" } elseif ($left -lt 6) { "  ${e}[38;2;250;204;21m[$([int]$left)h]${e}[0m" } else { "  ${e}[38;2;80;100;140m[$(([datetime]::Parse($lnk.expires)).ToString('dd/MM HH:mm'))]${e}[0m" }
            }
            if ($lnk.url) {
                Write-Host "  [$tag]  ${e}[38;2;100;149;237m[$i]${e}[0m  $($lnk.label)$expStr"
            } else {
                Write-Host "  [$tag]  ${e}[38;2;80;100;140m[$i]${e}[0m  $($lnk.label)  ${e}[38;2;239;68;68m[sem link — renovar]${e}[0m"
            }
        }

        Write-Host ""
        Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
        Write-Host "  ${e}[38;2;80;100;140m[0]${e}[0m  Voltar"
        Write-Host ""
        Write-Host -NoNewline "  ${e}[38;2;29;155;255m>${e}[0m  Opcao: "
        $opt = ($Host.UI.ReadLine()).Trim()
        Write-Host ""

        if ($opt -eq "0") { return }

        # One file at a time
        $targets = @()
        if ($opt -match '^\d+$') {
            $idx = [int]$opt - 1
            if ($idx -ge 0 -and $idx -lt $links.Count -and $links[$idx].url) {
                $targets = @($links[$idx])
            } else {
                Write-Warn "Opcao invalida ou sem link."
                Start-Sleep -Seconds 1; continue
            }
        } else { continue }

        if ($targets.Count -eq 0) { Write-Warn "Nenhum ficheiro disponivel."; Start-Sleep -Seconds 1; continue }

        # Ensure Temp dir
        if (-not (Test-Path "C:\M-AUTO\Temp")) { New-Item -ItemType Directory -Path "C:\M-AUTO\Temp" -Force | Out-Null }

        # Start aria2c
        if (-not (Ensure-Aria2c)) { Read-Host "  ENTER para voltar"; continue }
        $proxyArg  = Get-ProxyArg
        $aria2Proc = Start-Aria2cDaemon $proxyArg

        foreach ($lnk in $targets) {
            Write-Host ""
            Write-Host "  ${e}[38;2;148;163;184mA descarregar:${e}[0m ${e}[1;97m$($lnk.label)${e}[0m"
            Write-Host "  ${e}[38;2;148;163;184mDestino:${e}[0m C:\M-AUTO\Temp\$($lnk.dest)"
            Write-Host ""
            try {
                $status = Invoke-Aria2cDownload -url $lnk.url -fileName $lnk.dest
                if ($status -eq "complete") { Write-OK "$($lnk.label) concluido." }
                else { Write-Err "$($lnk.label) falhou." }
            } catch {
                Write-Err "Erro: $_"
            }
        }

        if ($aria2Proc) { $aria2Proc | Stop-Process -Force -EA SilentlyContinue }

        Write-Host ""
        Read-Host "  ENTER para continuar"
    }
}

#-- Header -------------------------------------------------------------------
function Show-Header {
    Clear-Host
    Write-Host ""
    Write-Host "  ${e}[1;97mMercedes Full Pack 2026${e}[0m"
    Write-Sep
    Write-Host "  ${e}[38;2;148;163;184m  Xentry + WIS + EPC + Vediamo${e}[0m"
    Write-Host ""
}

#-- Menu loop ----------------------------------------------------------------
while ($true) {
    Show-Header

    # Mostrar estado de cada ficheiro
    foreach ($op in $ops) {
        $exists = Test-Path $op.File
        $tag    = if ($exists) { "${e}[38;2;34;197;94m OK ${e}[0m" } else { "${e}[38;2;80;100;140mN/A${e}[0m" }
        Write-Host "  [$tag]  $($op.Label)"
        Write-Host "         ${e}[38;2;50;60;80m$($op.File)${e}[0m"
    }

    Write-Host ""
    Write-Sep
    Write-Host "  ${e}[38;2;100;149;237m[D]${e}[0m  Descarregar ficheiros (via Internet)"
    Write-Host "  ${e}[38;2;100;149;237m[1]${e}[0m  Instalar tudo (skip se ficheiro nao existir)"
    Write-Host "  ${e}[38;2;80;100;140m[0]${e}[0m  Voltar"
    Write-Host ""
    Write-Host -NoNewline "  ${e}[38;2;29;155;255m>${e}[0m  Opcao: "
    $opcao = ($Host.UI.ReadLine()).Trim().ToUpper()
    Write-Host ""

    if ($opcao -eq "0") { return }
    if ($opcao -eq "D") { Show-DownloadMenu; continue }
    if ($opcao -ne "1") { continue }

    $szExe = Find-7Zip
    if (-not $szExe) {
        Write-Err "7-Zip nao encontrado. Instale primeiro via Start Engine."
        Write-Host ""
        Read-Host "  Pressione ENTER para continuar"
        continue
    }

    $desktop = Resolve-Desktop

    #==========================================================================
    #  EWA
    #==========================================================================
    Write-Host "  ${e}[38;2;100;149;237m>> EWA${e}[0m"
    Write-Sep
    $ewaZip = "C:\M-auto\Temp\ewa.7z"
    if (-not (Test-Path $ewaZip)) {
        Write-Skip "ewa.7z"
    } else {
        # Passo 1: Extrair
        $extract = "C:\M-auto\Temp\ewa"
        if (-not (Test-Path $extract)) { New-Item -ItemType Directory -Path $extract -Force | Out-Null }
        $rc = Invoke-Extract -szExe $szExe -Source $ewaZip -Dest $extract -Pass "Fiesta77"
        if ($rc -ne 0) {
            Write-Err "Erro na extracao do EWA (codigo $rc)."
        } else {
            Write-OK "EWA extraido."
            try { Remove-Item $ewaZip -Force -ErrorAction Stop; Write-OK "ewa.7z apagado." }
            catch { Write-Warn "Nao foi possivel apagar ewa.7z: $_" }

            # Passo 2: SETUP.EXE
            $setup = "C:\M-auto\Temp\ewa\EWA\EWA\SETUP.EXE"
            if (Test-Path $setup) {
                Write-Host ""
                Write-Step "A lancar SETUP.EXE..."
                Start-Process -FilePath $setup -Wait -ErrorAction SilentlyContinue
                Write-OK "Instalador fechado."
                Write-Host ""
                Write-Host -NoNewline "  ${e}[38;2;29;155;255m>${e}[0m  Prima ENTER para mover os ficheiros EWA..."
                $null = $Host.UI.ReadLine()
                Write-Host ""

                # Passo 3: Mover Files\ewa
                $srcDir  = "C:\M-auto\Temp\ewa\EWA\Files\ewa"
                $destDir = "C:\Program Files (x86)\ewa"
                if (Test-Path $srcDir) {
                    Write-Step "A mover Files\ewa para Program Files (x86)..."
                    robocopy $srcDir $destDir /E /MOVE /IS /IT /NP /NFL /NDL /NJH /NJS /NC /NS | Out-Null
                    if ($LASTEXITCODE -le 7) { Write-OK "Ficheiros movidos para $destDir." }
                    else { Write-Err "Robocopy erro $LASTEXITCODE." }
                }

                # Passo 4: Limpar pasta temp
                if (Test-Path "C:\M-auto\Temp\ewa") {
                    Write-Step "A apagar pasta temp EWA..."
                    Remove-Item "C:\M-auto\Temp\ewa" -Recurse -Force -ErrorAction SilentlyContinue
                    Write-OK "Pasta temporaria apagada."
                }
            } else {
                Write-Warn "SETUP.EXE nao encontrado: $setup"
            }

            # Java (logo apos EWA)
            $jre = "C:\Program Files (x86)\EWA\clientapps\jre\JRE.EXE"
            if (Test-Path $jre) {
                Write-Host ""
                Write-Step "A instalar Java (silent)..."
                $proc = Start-Process -FilePath $jre -ArgumentList "/s" -Wait -PassThru -ErrorAction SilentlyContinue
                if ($proc.ExitCode -eq 0) { Write-OK "Java instalado." }
                else { Write-Warn "Java terminou com codigo $($proc.ExitCode)." }
            }
        }
    }

    Write-Host ""

    #==========================================================================
    #  StarFinder 2024
    #==========================================================================
    Write-Host "  ${e}[38;2;100;149;237m>> StarFinder 2024${e}[0m"
    Write-Sep
    $sfZip = "C:\M-auto\Temp\Startfifinder 2024.7z"
    if (-not (Test-Path $sfZip)) {
        Write-Skip "Startfifinder 2024.7z"
    } else {
        $rc = Invoke-Extract -szExe $szExe -Source $sfZip -Dest "C:\M-auto" -Pass "Fiesta77"
        if ($rc -ne 0) {
            Write-Err "Erro na extracao (codigo $rc)."
        } else {
            Write-OK "StarFinder 2024 extraido."
            try { Remove-Item $sfZip -Force -ErrorAction Stop; Write-OK "Ficheiro .7z apagado." }
            catch { Write-Warn "Nao foi possivel apagar: $_" }

            if ($desktop) {
                $sfExe = "C:\M-Auto\Startfifinder 2024\StarFinder_webETM\WebETM-SDmedia.exe"
                if (New-DesktopShortcut -Desktop $desktop -Name "StarFinder WebETM" -Target $sfExe) {
                    Write-OK "Atalho StarFinder criado."
                } else { Write-Warn "Atalho nao criado (executavel ausente ou erro)." }
            }
        }
    }

    Write-Host ""

    #==========================================================================
    #  SDMEDIA
    #==========================================================================
    Write-Host "  ${e}[38;2;100;149;237m>> SDMEDIA${e}[0m"
    Write-Sep
    $sdZip = "C:\M-auto\Temp\SDMEDIA.zip"
    if (-not (Test-Path $sdZip)) {
        Write-Skip "SDMEDIA.zip"
    } else {
        $sdDest = "C:\M-auto\SDmedia"
        if (-not (Test-Path $sdDest)) { New-Item -ItemType Directory -Path $sdDest -Force | Out-Null }
        $rc = Invoke-Extract -szExe $szExe -Source $sdZip -Dest $sdDest -Pass "Fiesta77"
        if ($rc -ne 0) {
            Write-Err "Erro na extracao (codigo $rc)."
        } else {
            Write-OK "SDMEDIA extraido."
            try { Remove-Item $sdZip -Force -ErrorAction Stop; Write-OK "Ficheiro .zip apagado." }
            catch { Write-Warn "Nao foi possivel apagar: $_" }

            if ($desktop) {
                if (New-DesktopShortcut -Desktop $desktop -Name "SDMEDIA" `
                    -Target "C:\M-auto\SDMEDIA\index.html" -Icon "C:\M-auto\SDMEDIA\icon.ico,0") {
                    Write-OK "Atalho SDMEDIA criado."
                } else { Write-Warn "Atalho nao criado." }
            }
        }
    }

    Write-Host ""

    #==========================================================================
    #  Coding Tutorials
    #==========================================================================
    Write-Host "  ${e}[38;2;100;149;237m>> Coding Tutorials${e}[0m"
    Write-Sep
    $ctZip = "C:\M-auto\Temp\Coding tutorials full.7z"
    if (-not (Test-Path $ctZip)) {
        Write-Skip "Coding tutorials full.7z"
    } else {
        $rc = Invoke-Extract -szExe $szExe -Source $ctZip -Dest "C:\M-auto" -Pass "Fiesta77"
        if ($rc -ne 0) {
            Write-Err "Erro na extracao (codigo $rc)."
        } else {
            Write-OK "Coding Tutorials extraido."
            try { Remove-Item $ctZip -Force -ErrorAction Stop; Write-OK "Ficheiro .7z apagado." }
            catch { Write-Warn "Nao foi possivel apagar: $_" }

            if ($desktop) {
                if (New-DesktopShortcut -Desktop $desktop -Name "Coding Tutorials" `
                    -Target "C:\M-auto\Coding tutorials full") {
                    Write-OK "Atalho Coding Tutorials criado."
                } else { Write-Warn "Atalho nao criado." }
            }
        }
    }

    Write-Host ""

    #==========================================================================
    #  Databases
    #==========================================================================
    Write-Host "  ${e}[38;2;100;149;237m>> Databases${e}[0m"
    Write-Sep
    $dbZip = "C:\M-auto\Temp\Databases.7z"
    if (-not (Test-Path $dbZip)) {
        Write-Skip "Databases.7z"
    } else {
        $rc = Invoke-Extract -szExe $szExe -Source $dbZip -Dest "C:\M-auto" -Pass "Fiesta77"
        if ($rc -ne 0) {
            Write-Err "Erro na extracao (codigo $rc)."
        } else {
            Write-OK "Databases extraido."
            try { Remove-Item $dbZip -Force -ErrorAction Stop; Write-OK "Ficheiro .7z apagado." }
            catch { Write-Warn "Nao foi possivel apagar: $_" }

            if ($desktop) {
                if (New-DesktopShortcut -Desktop $desktop -Name "Databases" `
                    -Target "C:\M-auto\Databases") {
                    Write-OK "Atalho Databases criado."
                } else { Write-Warn "Atalho nao criado." }
            }

            # Mover ProgramData para C:\
            $dbProgData = "C:\M-auto\Databases\Programdata"
            if (Test-Path $dbProgData) {
                Write-Step "A mover ProgramData para C:\..."
                robocopy $dbProgData "C:\Programdata" /E /MOVE /IS /IT /NP /NFL /NDL /NJH /NJS /NC /NS | Out-Null
                if ($LASTEXITCODE -le 7) {
                    Write-OK "ProgramData movido para C:\."
                    Remove-Item $dbProgData -Recurse -Force -ErrorAction SilentlyContinue
                } else {
                    Write-Err "Robocopy erro $LASTEXITCODE ao mover ProgramData."
                }
            } else {
                Write-Skip "C:\M-auto\Databases\Programdata nao encontrado"
            }
        }
    }

    Write-Host ""

    #==========================================================================
    #  WIS 2021
    #==========================================================================
    Write-Host "  ${e}[38;2;100;149;237m>> WIS 2021${e}[0m"
    Write-Sep
    $wisRar  = "C:\M-auto\Temp\wis2021.rar"
    $wisDest = "C:\M-auto\Temp\wis2021"
    $wisExe  = "$wisDest\Mercedes-Benz.WIS.ASRA.Standalone.v10.2021.Anywhere_autogmt.com.exe"
    if (-not (Test-Path $wisRar)) {
        Write-Skip "wis2021.rar"
    } else {
        if (-not (Test-Path $wisDest)) { New-Item -ItemType Directory -Path $wisDest -Force | Out-Null }

        $rc = Invoke-Extract -szExe $szExe -Source $wisRar -Dest $wisDest -Pass "autogmt.com"
        if ($rc -ne 0) {
            Write-Err "Erro na extracao do WIS 2021 (codigo $rc)."
        } else {
            Write-OK "WIS 2021 extraido."

            if (-not (Test-Path $wisExe)) {
                Write-Err "Instalador nao encontrado: $wisExe"
            } else {
                Write-Host ""
                Write-Step "A lancar instalador WIS 2021..."
                try {
                    Start-Process -FilePath $wisExe -Wait -ErrorAction Stop
                    Write-OK "Instalador WIS 2021 fechado."
                } catch {
                    Write-Err "Erro ao lancar o instalador: $_"
                }
            }
        }
    }

    Write-Host ""

    #==========================================================================
    #  Mover atalhos para pasta Coding (sempre)
    #==========================================================================
    Write-Host "  ${e}[38;2;100;149;237m>> Atalhos para pasta Coding${e}[0m"
    Write-Sep
    if (-not $desktop) {
        Write-Warn "Desktop nao encontrado — atalhos nao movidos."
    } else {
        $coding = Join-Path $desktop "Coding"
        if (-not (Test-Path $coding)) { New-Item -ItemType Directory -Path $coding -Force | Out-Null }

        $allLinks = Get-ChildItem -Path $desktop -Filter "*.lnk" -ErrorAction SilentlyContinue
        $targets  = @(
            "*Vediamo*Start*Center*", "*Vediamo*",
            "*DTS*Venice*", "*DTS*Monaco*",
            "*OTX*Studio*", "*XENTRY*Special*Functions*",
            "*DAS*FDOK*", "*Keygens*"
        )
        $moved = @(); $matched = @()
        foreach ($pattern in $targets) {
            $hits = $allLinks | Where-Object { $_.Name -like $pattern -and $_.FullName -notin $matched }
            foreach ($lnk in $hits) {
                $matched += $lnk.FullName
                try {
                    Move-Item -Path $lnk.FullName -Destination (Join-Path $coding $lnk.Name) -Force -ErrorAction Stop
                    $moved += $lnk.BaseName
                } catch {}
            }
        }
        if ($moved.Count -gt 0) { Write-OK "$($moved.Count) atalho(s) movido(s): $($moved -join ', ')" }
        else { Write-Skip "Nenhum atalho de diagnostico encontrado no Desktop" }
    }

    Write-Host ""
    Write-Sep
    Write-Host "  ${e}[38;2;34;197;94m>> Concluido.${e}[0m  Recomenda-se reiniciar o PC."
    Write-Host ""
    Read-Host "  Pressione ENTER para voltar"
}
