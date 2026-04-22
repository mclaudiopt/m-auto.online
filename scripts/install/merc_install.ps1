# install/merc_install.ps1 - Mercedes Pack Installation
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null
$e = [char]27

$DEST_DIR = "C:\M-auto\Temp"

#-- Helpers ------------------------------------------------------------------
function Write-Header {
    Clear-Host
    Write-Host ""
    Write-Host "  ${e}[38;2;29;155;255m+------------------------------------------------------+${e}[0m"
    Write-Host "  ${e}[38;2;29;155;255m|${e}[0m  ${e}[1;97mMercedes Pack${e}[0m  ${e}[38;2;100;149;237mInstalar${e}[0m"
    Write-Host "  ${e}[38;2;29;155;255m+------------------------------------------------------+${e}[0m"
    Write-Host ""
}

function Write-OK($msg)   { Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m  $msg" }
function Write-Err($msg)  { Write-Host "  ${e}[38;2;239;68;68m[X]${e}[0m   $msg" }
function Write-Warn($msg) { Write-Host "  ${e}[38;2;250;204;21m[!]${e}[0m   $msg" }
function Write-Info($msg) { Write-Host "  ${e}[38;2;148;163;184m[.]${e}[0m   $msg" }
function Write-Skip($msg) { Write-Host "  ${e}[38;2;80;100;140m[--]${e}[0m  $msg" }

#-- Find 7-Zip ---------------------------------------------------------------
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

#-- Progress bar helper -----------------------------------------------------
function Show-Progress {
    param([int]$Percent, [int]$Width = 50, [string]$Label = "")

    $filled = [math]::Round($Percent / 100 * $Width)
    $empty = $Width - $filled

    # Cores: verde para completo, azul para progresso
    if ($Percent -eq 100) {
        $barColor = "42;157;143"  # Verde
        $emptyColor = "38;70;83"  # Cinza escuro
    } else {
        $barColor = "233;196;106"  # Amarelo/dourado
        $emptyColor = "38;70;83"   # Cinza escuro
    }

    $barFilled = "${e}[48;2;${barColor}m" + (" " * $filled) + "${e}[0m"
    $barEmpty = "${e}[48;2;${emptyColor}m" + (" " * $empty) + "${e}[0m"

    $percentText = "$Percent%".PadLeft(4)
    $labelText = if ($Label) { " $Label" } else { "" }

    Write-Host -NoNewline "`r  ${e}[97m${percentText}${e}[0m ${barFilled}${barEmpty}${labelText}"

    if ($Percent -eq 100) { Write-Host "" }
}

#-- Extract with progress ----------------------------------------------------
function Invoke-Extract {
    param([string]$szExe, [string]$Source, [string]$Dest, [string]$Pass = "")

    Write-Info "A extrair $(Split-Path $Source -Leaf)..."

    $xArgs = @("x", $Source, "-o$Dest", "-bsp1", "-y")
    if ($Pass) { $xArgs += "-p$Pass" }

    $lastP = -1
    & $szExe @xArgs | ForEach-Object {
        if ($_ -match '^\s*(\d+)%') {
            $p = [int]$Matches[1]
            if ($p -ne $lastP) {
                $lastP = $p
                Show-Progress -Percent $p
            }
        }
    }
    if ($LASTEXITCODE -eq 0) { Show-Progress -Percent 100 }
    return $LASTEXITCODE
}

#-- Desktop resolution -------------------------------------------------------
function Resolve-Desktop {
    $candidates = @()
    try {
        $loggedUser = (Get-CimInstance Win32_ComputerSystem -EA SilentlyContinue).UserName
        if ($loggedUser -match '\\') {
            $uname = $loggedUser.Split('\')[-1]
            $candidates += "C:\Users\$uname\OneDrive\Desktop"
            $candidates += "C:\Users\$uname\Desktop"
        }
    } catch {}
    try {
        $reg = [Environment]::ExpandEnvironmentVariables(
            (Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" `
                -Name "Desktop" -EA Stop).Desktop)
        $candidates += $reg
    } catch {}
    Get-ChildItem "C:\Users" -Directory -EA SilentlyContinue | ForEach-Object {
        $candidates += "$($_.FullName)\OneDrive\Desktop"
        $candidates += "$($_.FullName)\Desktop"
    }
    foreach ($path in $candidates) {
        if ($path -and (Test-Path $path)) { return $path }
    }
    return $null
}

#-- Create shortcut ----------------------------------------------------------
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

#-- Install EWA --------------------------------------------------------------
function Install-EWA {
    $zip = "$DEST_DIR\EWA.7z"
    if (-not (Test-Path $zip)) { Write-Skip "EWA.7z nao encontrado"; return }

    $szExe = Find-7Zip
    if (-not $szExe) { Write-Err "7-Zip nao encontrado"; return }

    $extract = "$DEST_DIR\ewa_temp"
    if (-not (Test-Path $extract)) { New-Item -ItemType Directory -Path $extract -Force | Out-Null }

    $rc = Invoke-Extract -szExe $szExe -Source $zip -Dest $extract -Pass "Fiesta77"
    if ($rc -ne 0) { Write-Err "Erro na extracao (codigo $rc)"; return }

    Write-OK "EWA extraido"
    Remove-Item $zip -Force -EA SilentlyContinue

    $setup = "$extract\EWA\EWA\SETUP.EXE"
    if (Test-Path $setup) {
        Write-Info "A lancar SETUP.EXE..."
        Start-Process -FilePath $setup -Wait -EA SilentlyContinue
        Write-OK "Instalador fechado"

        Write-Host ""
        Read-Host "  Prima ENTER para mover ficheiros EWA"

        $srcDir = "$extract\EWA\Files\ewa"
        $destDir = "C:\Program Files (x86)\ewa"
        if (Test-Path $srcDir) {
            Write-Info "A mover ficheiros..."
            robocopy $srcDir $destDir /E /MOVE /IS /IT /NP /NFL /NDL /NJH /NJS /NC /NS | Out-Null
            if ($LASTEXITCODE -le 7) { Write-OK "Ficheiros movidos" }
        }

        Remove-Item $extract -Recurse -Force -EA SilentlyContinue

        $jre = "C:\Program Files (x86)\EWA\clientapps\jre\JRE.EXE"
        if (Test-Path $jre) {
            Write-Info "A instalar Java..."
            Start-Process -FilePath $jre -ArgumentList "/s" -Wait -PassThru -EA SilentlyContinue | Out-Null
            Write-OK "Java instalado"
        }
    }
}

#-- Install StarFinder -------------------------------------------------------
function Install-StarFinder {
    $zip = "$DEST_DIR\Startfifinder 2024.7z"
    if (-not (Test-Path $zip)) { Write-Skip "Startfifinder 2024.7z nao encontrado"; return }

    $szExe = Find-7Zip
    if (-not $szExe) { Write-Err "7-Zip nao encontrado"; return }

    $rc = Invoke-Extract -szExe $szExe -Source $zip -Dest "C:\M-auto" -Pass "Fiesta77"
    if ($rc -ne 0) { Write-Err "Erro na extracao"; return }

    Write-OK "StarFinder extraido"
    Remove-Item $zip -Force -EA SilentlyContinue

    $desktop = Resolve-Desktop
    if ($desktop) {
        $exe = "C:\M-Auto\Startfifinder 2024\StarFinder_webETM\WebETM-SDmedia.exe"
        if (New-DesktopShortcut -Desktop $desktop -Name "StarFinder WebETM" -Target $exe) {
            Write-OK "Atalho criado"
        }
    }
}

#-- Install SDMEDIA ----------------------------------------------------------
function Install-SDMEDIA {
    $zip = "$DEST_DIR\SDMEDIA.zip"
    if (-not (Test-Path $zip)) { Write-Skip "SDMEDIA.zip nao encontrado"; return }

    $szExe = Find-7Zip
    if (-not $szExe) { Write-Err "7-Zip nao encontrado"; return }

    $dest = "C:\M-auto\SDmedia"
    if (-not (Test-Path $dest)) { New-Item -ItemType Directory -Path $dest -Force | Out-Null }

    $rc = Invoke-Extract -szExe $szExe -Source $zip -Dest $dest -Pass "Fiesta77"
    if ($rc -ne 0) { Write-Err "Erro na extracao"; return }

    Write-OK "SDMEDIA extraido"
    Remove-Item $zip -Force -EA SilentlyContinue

    $desktop = Resolve-Desktop
    if ($desktop) {
        if (New-DesktopShortcut -Desktop $desktop -Name "SDMEDIA" `
            -Target "C:\M-auto\SDMEDIA\index.html" -Icon "C:\M-auto\SDMEDIA\icon.ico,0") {
            Write-OK "Atalho criado"
        }
    }
}

#-- Install WIS --------------------------------------------------------------
function Install-WIS {
    $rar = "$DEST_DIR\wis2021.rar"
    if (-not (Test-Path $rar)) { Write-Skip "wis2021.rar nao encontrado"; return }

    $szExe = Find-7Zip
    if (-not $szExe) { Write-Err "7-Zip nao encontrado"; return }

    $dest = "$DEST_DIR\wis2021_temp"
    if (-not (Test-Path $dest)) { New-Item -ItemType Directory -Path $dest -Force | Out-Null }

    $rc = Invoke-Extract -szExe $szExe -Source $rar -Dest $dest -Pass "autogmt.com"
    if ($rc -ne 0) { Write-Err "Erro na extracao"; return }

    Write-OK "WIS extraido"

    $exe = "$dest\Mercedes-Benz.WIS.ASRA.Standalone.v10.2021.Anywhere_autogmt.com.exe"
    if (Test-Path $exe) {
        Write-Info "A lancar instalador WIS..."
        Start-Process -FilePath $exe -Wait -EA Stop
        Write-OK "Instalador fechado"
    }

    Remove-Item $dest -Recurse -Force -EA SilentlyContinue
}

#-- Mapeamento de ficheiros --------------------------------------------------
$INSTALL_MAP = @{
    "EWA.7z" = { Install-EWA }
    "Startfifinder 2024.7z" = { Install-StarFinder }
    "SDMEDIA.zip" = { Install-SDMEDIA }
    "wis2021.rar" = { Install-WIS }
}

#-- Instalar ficheiro especifico ---------------------------------------------
function Install-File {
    param([string]$FileName)

    $installer = $INSTALL_MAP[$FileName]
    if (-not $installer) {
        Write-Warn "Instalacao automatica nao disponivel para $FileName"
        return
    }

    Write-Header
    Write-Host "  ${e}[38;2;100;149;237m-- Instalar: $FileName --${e}[0m"
    Write-Host ""

    & $installer

    Write-Host ""
    Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
    Write-Host ""
}

#-- Menu instalacao ----------------------------------------------------------
function Show-InstallMenu {
    while ($true) {
        Write-Header

        $files = Get-ChildItem $DEST_DIR -File -EA SilentlyContinue | Where-Object { $INSTALL_MAP.ContainsKey($_.Name) }

        if ($files.Count -eq 0) {
            Write-Warn "Nenhum ficheiro disponivel para instalacao em $DEST_DIR"
            Write-Host ""
            Read-Host "  Pressione ENTER para voltar"
            return
        }

        Write-Host "  ${e}[38;2;148;163;184mFicheiros disponiveis:${e}[0m"
        Write-Host ""

        $i = 0
        foreach ($f in $files) {
            $i++
            $sizeMB = [math]::Round($f.Length / 1MB, 1)
            Write-Host "    ${e}[38;2;100;149;237m[$i]${e}[0m  $($f.Name) ${e}[38;2;148;163;184m($sizeMB MB)${e}[0m"
        }

        Write-Host ""
        Write-Host "    ${e}[38;2;100;149;237m[A]${e}[0m  Instalar todos"
        Write-Host "    ${e}[38;2;239;68;68m[0]${e}[0m  Voltar"
        Write-Host ""
        $choice = Read-Host "  Opcao"

        if ($choice -eq "0") { return }

        if ($choice -eq "A" -or $choice -eq "a") {
            foreach ($f in $files) {
                Install-File -FileName $f.Name
                Read-Host "  Pressione ENTER para continuar"
            }
        } elseif ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $files.Count) {
            $idx = [int]$choice - 1
            Install-File -FileName $files[$idx].Name
            Read-Host "  Pressione ENTER para continuar"
        } else {
            Write-Err "Opcao invalida"
            Start-Sleep -Seconds 1
        }
    }
}

#-- Entry point --------------------------------------------------------------
Show-InstallMenu
