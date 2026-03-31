# system/sysinfo.ps1 - Informacao completa do sistema
$e = [char]27

function Write-Row($label, $value, $color = "97") {
    Write-Host "  ${e}[38;2;100;149;237m$($label.PadRight(28))${e}[0m  ${e}[${color}m$value${e}[0m"
}

Write-Host ""
Write-Host "  ${e}[1;97mInformacao Detalhada do Sistema${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

# ── Windows Version ─────────────────────────────────────────────────────
Write-Host "  ${e}[38;2;100;149;237m>> Sistema Operativo${e}[0m"
Write-Host ""

$os = Get-CimInstance Win32_OperatingSystem
$winVer = if ($os.Caption -match "11") { "Windows 11" } elseif ($os.Caption -match "10") { "Windows 10" } else { $os.Caption }
Write-Row "OS" "$winVer"
Write-Row "Build" "$($os.BuildNumber)"
Write-Row "Versao" "$($os.Version)"

# ── Computer Info ───────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m>> Computador${e}[0m"
Write-Host ""

$comp = Get-CimInstance Win32_ComputerSystem
$bios = Get-CimInstance Win32_BIOS
Write-Row "Marca" "$($comp.Manufacturer)"
Write-Row "Modelo" "$($comp.Model)"
Write-Row "Hostname" "$($comp.Name)"
Write-Row "Utilizador" "$($env:USERNAME)"
Write-Row "BIOS" "$($bios.Manufacturer) $($bios.SMBIOSBIOSVersion)"

# ── Processor ───────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m>> Processador${e}[0m"
Write-Host ""

$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
Write-Row "Nome" "$($cpu.Name.Trim())"
Write-Row "Nucleos" "$($cpu.NumberOfCores)"
Write-Row "Threads" "$($cpu.NumberOfLogicalProcessors)"
Write-Row "Frequencia" "$($cpu.MaxClockSpeed) MHz"

# ── Memory ──────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m>> Memoria${e}[0m"
Write-Host ""

$ram = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
$free = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
$usado = $ram - $free
$percUsado = [math]::Round(($usado / $ram) * 100, 1)
Write-Row "RAM Total" "${ram} GB"
Write-Row "RAM Usada" "${usado} GB ($percUsado%)"
Write-Row "RAM Livre" "${free} GB"

# ── Discos ──────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m>> Armazenamento${e}[0m"
Write-Host ""

Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Name -match "^[A-Z]$" } | ForEach-Object {
    $drive = $_
    $used = [math]::Round($drive.Used / 1GB, 1)
    $free = [math]::Round($drive.Free / 1GB, 1)
    $total = $used + $free
    $perc = [math]::Round(($used / $total) * 100, 1)
    $color = if ($perc -gt 80) { "31" } elseif ($perc -gt 60) { "33" } else { "97" }
    Write-Row "Disco $($drive.Name):" "$used GB / $total GB ($perc%)" $color
}

# Discos fisicos
$disks = Get-CimInstance Win32_LogicalDisk
$diskCount = ($disks | Measure-Object).Count
Write-Row "Total Discos" "$diskCount"

# ── Seguranca ───────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m>> Seguranca${e}[0m"
Write-Host ""

# Secure Boot
try {
    $sb = Get-SecureBootUEFI -ErrorAction SilentlyContinue
    $sbStatus = if ($sb) { "${e}[38;2;34;197;94mACTIVO${e}[0m" } else { "${e}[38;2;239;68;68mDESACTIVADO${e}[0m" }
    Write-Host "  ${e}[38;2;100;149;237m$("Secure Boot".PadRight(28))${e}[0m  $sbStatus"
} catch {
    Write-Host "  ${e}[38;2;100;149;237m$("Secure Boot".PadRight(28))${e}[0m  ${e}[38;2;148;163;184m(indisponivel)${e}[0m"
}

# BitLocker
try {
    $bl = Get-BitLockerVolume -MountPoint C: -ErrorAction SilentlyContinue
    $blStatus = if ($bl -and $bl.ProtectionStatus -eq "On") { 
        "${e}[38;2;34;197;94mACTIVO${e}[0m" 
    } else { 
        "${e}[38;2;239;68;68mDESACTIVADO${e}[0m" 
    }
    Write-Host "  ${e}[38;2;100;149;237m$("BitLocker".PadRight(28))${e}[0m  $blStatus"
} catch {
    Write-Host "  ${e}[38;2;100;149;237m$("BitLocker".PadRight(28))${e}[0m  ${e}[38;2;148;163;184m(indisponivel)${e}[0m"
}

# Defender
try {
    $def = Get-MpComputerStatus -ErrorAction SilentlyContinue
    $defStatus = if ($def.RealTimeProtectionEnabled) { 
        "${e}[38;2;34;197;94mACTIVO${e}[0m" 
    } else { 
        "${e}[38;2;239;68;68mDESACTIVADO${e}[0m" 
    }
    Write-Host "  ${e}[38;2;100;149;237m$("Windows Defender".PadRight(28))${e}[0m  $defStatus"
} catch {
    Write-Host "  ${e}[38;2;100;149;237m$("Windows Defender".PadRight(28))${e}[0m  ${e}[38;2;148;163;184m(indisponivel)${e}[0m"
}

# Firewall
try {
    $fw = Get-NetFirewallProfile -All -ErrorAction SilentlyContinue
    $fwEnabled = $fw | Where-Object { $_.Enabled -eq $true } | Measure-Object | Select-Object -ExpandProperty Count
    $fwStatus = if ($fwEnabled -gt 0) { "${e}[38;2;34;197;94mACTIVO ($fwEnabled)${e}[0m" } else { "${e}[38;2;239;68;68mDESACTIVADO${e}[0m" }
    Write-Host "  ${e}[38;2;100;149;237m$("Firewall".PadRight(28))${e}[0m  $fwStatus"
} catch {
    Write-Host "  ${e}[38;2;100;149;237m$("Firewall".PadRight(28))${e}[0m  ${e}[38;2;148;163;184m(indisponivel)${e}[0m"
}

# ── Drivers ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m>> Drivers${e}[0m"
Write-Host ""

try {
    $pnpDevices = Get-PnpDevice -Status Error -ErrorAction SilentlyContinue
    $errorCount = ($pnpDevices | Measure-Object).Count
    if ($errorCount -gt 0) {
        Write-Host "  ${e}[38;2;239;68;68m[X]  $errorCount dispositivos com drivers em falta${e}[0m"
        $pnpDevices | Select-Object -First 5 | ForEach-Object {
            Write-Host "      - $($_.Name)"
        }
        if ($errorCount -gt 5) {
            Write-Host "      ... e mais $($errorCount - 5)"
        }
    } else {
        Write-Host "  ${e}[38;2;34;197;94m[OK]  Todos os drivers instalados${e}[0m"
    }
} catch {
    Write-Host "  ${e}[38;2;148;163;184m(nao foi possivel verificar drivers)${e}[0m"
}

Write-Host ""
Wait-Key
