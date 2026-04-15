# Mercedes Full Pack - Download Manager
# Carregado por: Run-Sub "install/merc_full_pack"

$e = [char]27

#-- URLs presigned (validos 7 dias - regenerar em 2026-04-22) ------------------
$LINKS = @{
    "SDMEDIA"   = @{ label = "Xentry SDMEDIA (Diagnostico)";      file = "SDMEDIA.zip";                                      url = "https://8d2cf9429e3c19524a14a659e5a07183.r2.cloudflarestorage.com/m-auto-software/Daimler/Pack/Installer/SDMEDIA.zip?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=59cb46144927b03a7dc575be0b734ff4%2F20260415%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260415T095026Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&x-id=GetObject&X-Amz-Signature=1dda44304d4cf1bc4db098c38dbdb0de23343aaeb2cf7fb9996aae43f72aa6e1" }
    "DB"        = @{ label = "Databases";                          file = "Databases.7z";                                     url = "https://8d2cf9429e3c19524a14a659e5a07183.r2.cloudflarestorage.com/m-auto-software/Daimler/Pack/Installer/Databases.7z?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=59cb46144927b03a7dc575be0b734ff4%2F20260415%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260415T095027Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&x-id=GetObject&X-Amz-Signature=1f3f490d127d1cd4687bf9060f27d8d60914bc198aba7a776e7a2d6a83cd0e31" }
    "WIS"       = @{ label = "WIS / ASRA Standalone 2021";         file = "Mercedes-Benz.WIS.ASRA.Standalone.v10.2021.Anywhere.rar"; url = "https://8d2cf9429e3c19524a14a659e5a07183.r2.cloudflarestorage.com/m-auto-software/Daimler/Pack/Installer/Mercedes-Benz.WIS.ASRA.Standalone.v10.2021.Anywhere.rar?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=59cb46144927b03a7dc575be0b734ff4%2F20260415%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260415T095028Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&x-id=GetObject&X-Amz-Signature=6d6325cbfbd88b46cea33ff9e141a385794f00c734504090a696f6795e6423dc" }
    "FINDER"    = @{ label = "StarFinder 2024";                    file = "Startfifinder 2024.7z";                            url = "https://8d2cf9429e3c19524a14a659e5a07183.r2.cloudflarestorage.com/m-auto-software/Daimler/Pack/Installer/Startfifinder%202024.7z?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=59cb46144927b03a7dc575be0b734ff4%2F20260415%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260415T095028Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&x-id=GetObject&X-Amz-Signature=5fa5dc8f6868706b5be4594aa8a0f92099e16e6020ac1eb916d302d3115a66c4" }
    "EWA"       = @{ label = "EWA Net";                            file = "EWA.7z";                                           url = "https://8d2cf9429e3c19524a14a659e5a07183.r2.cloudflarestorage.com/m-auto-software/Daimler/Pack/Installer/EWA.7z?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=59cb46144927b03a7dc575be0b734ff4%2F20260415%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260415T095029Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&x-id=GetObject&X-Amz-Signature=dbb69857024a6986d803aae5aab19a270281d017563b4ad4dcc6e9f70bfc1558" }
    "VEDIAMO"   = @{ label = "Vediamo J2534";                      file = "Vediamo J2534.exe";                                url = "https://8d2cf9429e3c19524a14a659e5a07183.r2.cloudflarestorage.com/m-auto-software/Daimler/Pack/Installer/Vediamo%20J2534.exe?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=59cb46144927b03a7dc575be0b734ff4%2F20260415%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260415T095030Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&x-id=GetObject&X-Amz-Signature=a6efe22c803e2c78df30367c4b67dc69bd1d68c91f69bf0d80d74d32ddcd4b8b" }
}

$ARIA2   = "$env:TEMP\aria2c.exe"
$DESTDIR = "C:\M-AUTO\Temp"
if (-not (Test-Path $DESTDIR)) { New-Item -ItemType Directory -Path $DESTDIR -Force | Out-Null }
$RPC_URL = "http://localhost:6801/jsonrpc"
$RPC_TOK = "mauto2026"
$aria2Proc = $null

#-- Instalar aria2c se necessario ---------------------------------------------
function Ensure-Aria2 {
    if (Test-Path $ARIA2) { return }
    Write-Host ""
    Write-Host "  ${e}[38;2;250;204;21m[!]   A instalar aria2c (download rapido)...${e}[0m"
    $zip = "$env:TEMP\aria2.zip"
    try {
        Invoke-WebRequest "https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0-win-64bit-build1.zip" -OutFile $zip -UseBasicParsing
        Expand-Archive $zip -DestinationPath "$env:TEMP\aria2_extract" -Force
        Copy-Item "$env:TEMP\aria2_extract\aria2-1.37.0-win-64bit-build1\aria2c.exe" $ARIA2 -Force
        Remove-Item $zip -Force -ErrorAction SilentlyContinue
        Remove-Item "$env:TEMP\aria2_extract" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "  ${e}[38;2;34;197;94m[OK]  aria2c instalado${e}[0m"
    } catch {
        Write-Host "  ${e}[38;2;239;68;68m[X]   Erro ao instalar aria2c: $_${e}[0m"
    }
}

#-- Iniciar daemon aria2c com RPC ---------------------------------------------
function Start-Aria2Daemon {
    # Verificar se ja esta a correr
    try {
        $test = Invoke-RestMethod -Uri $RPC_URL -Method Post -Body '{"jsonrpc":"2.0","id":"1","method":"aria2.getVersion","params":["token:mauto2026"]}' -ContentType "application/json" -TimeoutSec 2 -ErrorAction SilentlyContinue
        if ($test.result) { return $null }
    } catch {}

    $script:aria2Proc = Start-Process -FilePath $ARIA2 `
        -ArgumentList "--enable-rpc --rpc-listen-port=6801 --rpc-secret=$RPC_TOK --rpc-allow-origin-all --file-allocation=none --quiet=true --daemon=false" `
        -PassThru -WindowStyle Hidden
    Start-Sleep -Milliseconds 1200
    return $script:aria2Proc
}

#-- Parar daemon --------------------------------------------------------------
function Stop-Aria2Daemon {
    if ($script:aria2Proc -and -not $script:aria2Proc.HasExited) {
        $script:aria2Proc | Stop-Process -Force -ErrorAction SilentlyContinue
    }
}

#-- Adicionar download via RPC ------------------------------------------------
function Add-Download($url, $fileName) {
    $opts = @{ dir = $DESTDIR; out = $fileName; split = "16"; "max-connection-per-server" = "16"; "min-split-size" = "10M" }
    $body = @{ jsonrpc = "2.0"; id = "1"; method = "aria2.addUri"; params = @("token:$RPC_TOK", @($url), $opts) } | ConvertTo-Json -Depth 5 -Compress
    $r = Invoke-RestMethod -Uri $RPC_URL -Method Post -Body $body -ContentType "application/json"
    return $r.result
}

#-- Barra de progresso profissional -------------------------------------------
function Show-Download($gid, $label) {
    $barW = 38
    $lastDown = 0
    $lastTime = [DateTime]::Now

    Write-Host ""
    Write-Host "  ${e}[38;2;100;149;237m>>  ${e}[1;97m$label${e}[0m"
    Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
    Write-Host ""

    do {
        Start-Sleep -Milliseconds 900
        $body = @{ jsonrpc = "2.0"; id = "1"; method = "aria2.tellStatus"; params = @("token:$RPC_TOK", $gid) } | ConvertTo-Json -Depth 3 -Compress
        try { $s = (Invoke-RestMethod -Uri $RPC_URL -Method Post -Body $body -ContentType "application/json").result }
        catch { continue }

        $total = [long]$s.totalLength
        $down  = [long]$s.completedLength
        $spd   = [long]$s.downloadSpeed
        $cn    = $s.connections
        $st    = $s.status

        # Velocidade suavizada
        $now  = [DateTime]::Now
        $dt   = ([DateTime]::Now - $lastTime).TotalSeconds
        if ($dt -gt 0) { $spd = ($down - $lastDown) / $dt }
        $lastDown = $down; $lastTime = $now

        $pct = if ($total -gt 0) { [int]($down / $total * 100) } else { 0 }
        $mb  = "{0:N1}" -f ($down / 1MB)
        $tot = "{0:N1}" -f ($total / 1MB)

        $spdStr = if ($spd -gt 1MB)     { "{0:N1} MB/s" -f ($spd/1MB) }
                  elseif ($spd -gt 1KB) { "{0:N0} KB/s" -f ($spd/1KB) }
                  else                  { "-- KB/s" }

        $etaStr = if ($spd -gt 0 -and $total -gt $down) {
            $r = ($total - $down) / $spd
            if ($r -gt 3600) { "{0}h{1:D2}m" -f [int]($r/3600), [int](($r%3600)/60) }
            elseif ($r -gt 60) { "{0}m{1:D2}s" -f [int]($r/60), [int]($r%60) }
            else { "{0}s" -f [int]$r }
        } elseif ($st -eq "waiting") { "A iniciar..." } else { "--" }

        $filled = [int]($barW * $pct / 100)
        $bar    = ("${e}[38;2;29;155;255m" + ([string][char]9608 * $filled)) + ("${e}[38;2;40;50;70m" + ([string][char]9617 * ($barW - $filled))) + "${e}[0m"

        $line = "  [$bar${e}[0m] ${e}[1;97m$pct%${e}[0m  ${e}[38;2;148;163;184m$mb / $tot MB${e}[0m  ${e}[38;2;34;197;94m$spdStr${e}[0m  ETA ${e}[38;2;250;204;21m$etaStr${e}[0m  CN:$cn   "
        Write-Host -NoNewline ([char]13 + $line)

    } while ($s.status -eq "active" -or $s.status -eq "waiting")

    Write-Host ""
    Write-Host ""
    if ($s.status -eq "complete") {
        Write-Host "  ${e}[38;2;34;197;94m[OK]  Concluido: $DESTDIR\$($s.files[0].path | Split-Path -Leaf)${e}[0m"
    } else {
        Write-Host "  ${e}[38;2;239;68;68m[X]   Erro: $($s.errorMessage)${e}[0m"
    }
}

#-- Download de um ficheiro ---------------------------------------------------
function Start-MercDownload($key) {
    $item = $LINKS[$key]
    Ensure-Aria2
    Start-Aria2Daemon

    Write-Host ""
    Write-Host "  ${e}[38;2;148;163;184m[.]   A adicionar download: $($item.file)${e}[0m"
    $gid = Add-Download $item.url $item.file
    if (-not $gid) { Write-Host "  ${e}[38;2;239;68;68m[X]   Erro ao iniciar download${e}[0m}"; return }

    Show-Download $gid $item.label
    Stop-Aria2Daemon
    Write-Host ""
    Read-Host "  Pressione ENTER para continuar"
}

#-- Menu Mercedes -------------------------------------------------------------
function Show-Merc {
    while ($true) {
        Write-Header
        Write-Title "Mercedes-Benz - Downloads"
        Write-Host "  ${e}[38;2;100;149;237m[Software de Diagnostico]${e}[0m"
        Write-Opt 1 "Xentry SDMEDIA"              "Diagnostico principal"
        Write-Opt 2 "Databases"                   "Base de dados Xentry"
        Write-Opt 3 "WIS / ASRA Standalone 2021"  "Workshop Information System"
        Write-Opt 4 "StarFinder 2024"             "Localizador de pecas"
        Write-Opt 5 "EWA Net"                     "Electric Wiring Assistant"
        Write-Opt 6 "Vediamo J2534"               "Engineering / SCN Coding"
        Write-Host ""
        Write-Opt 0 "<- Voltar"
        Write-Host ""
        switch (Read-Key) {
            "1" { Start-MercDownload "SDMEDIA"  }
            "2" { Start-MercDownload "DB"       }
            "3" { Start-MercDownload "WIS"      }
            "4" { Start-MercDownload "FINDER"   }
            "5" { Start-MercDownload "EWA"      }
            "6" { Start-MercDownload "VEDIAMO"  }
            "0" { Stop-Aria2Daemon; return }
            default { Write-Warn "Opcao invalida."; Start-Sleep -Milliseconds 600 }
        }
    }
}

#-- Entrada -------------------------------------------------------------------
Show-Merc
