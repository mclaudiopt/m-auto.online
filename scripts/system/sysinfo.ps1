# system/sysinfo.ps1 - Informacao do Sistema
$e = [char]27

function Write-Row($label, $value, $color = "97") {
    Write-Host "  ${e}[38;2;100;149;237m$($label.PadRight(28))${e}[0m  ${e}[${color}m$value${e}[0m"
}

Write-Host ""
Write-Host "  ${e}[1;97mInformacao do Sistema${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

# ── Windows Version ─────────────────────────────────────────────────────
$os = Get-CimInstance Win32_OperatingSystem
$winVer = if ($os.Caption -match "11") { "Windows 11" } elseif ($os.Caption -match "10") { "Windows 10" } else { $os.Caption }
Write-Row "SO" "$winVer"
Write-Row "Build" "$($os.BuildNumber)"

# ── Computer Info ───────────────────────────────────────────────────────
$comp = Get-CimInstance Win32_ComputerSystem
Write-Row "Marca" "$($comp.Manufacturer)"
Write-Row "Modelo" "$($comp.Model)"

# ── Processor ───────────────────────────────────────────────────────────
$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
Write-Row "Processador" "$($cpu.Name.Trim())"

# ── Memory ──────────────────────────────────────────────────────────────
$ram = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
$free = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
$usado = $ram - $free
$percUsado = [math]::Round(($usado / $ram) * 100, 1)
Write-Row "RAM" "${usado} GB / ${ram} GB ($percUsado%)"

# ── Discos ──────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m>> Discos${e}[0m"
Write-Host ""

$drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Name -match "^[A-Z]$" }
$drives | ForEach-Object {
    $used = [math]::Round($_.Used / 1GB, 1)
    $free = [math]::Round($_.Free / 1GB, 1)
    $total = $used + $free
    $perc = [math]::Round(($used / $total) * 100, 1)
    $color = if ($perc -gt 80) { "31" } elseif ($perc -gt 60) { "33" } else { "97" }
    Write-Row "Disco $($_.Name):" "$used GB / $total GB ($perc%)" $color
}

$diskCount = ($drives | Measure-Object).Count
Write-Row "Total Discos" "$diskCount"

# ── Seguranca ───────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m>> Seguranca${e}[0m"
Write-Host ""

# Secure Boot
try {
    $sbEnabled = Confirm-SecureBootUEFI -ErrorAction SilentlyContinue
    $sbStatus = if ($sbEnabled -eq $true) { "${e}[38;2;34;197;94mACTIVO${e}[0m" } else { "${e}[38;2;239;68;68mDESACTIVADO${e}[0m" }
    Write-Host "  ${e}[38;2;100;149;237m$("Secure Boot".PadRight(28))${e}[0m  $sbStatus"
} catch {
    Write-Host "  ${e}[38;2;100;149;237m$("Secure Boot".PadRight(28))${e}[0m  ${e}[38;2;148;163;184m(nao disponivel/Legacy BIOS)${e}[0m"
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
    Write-Host "  ${e}[38;2;100;149;237m$("BitLocker".PadRight(28))${e}[0m  ${e}[38;2;148;163;184m(nao disponivel)${e}[0m"
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
    Write-Host "  ${e}[38;2;100;149;237m$("Windows Defender".PadRight(28))${e}[0m  ${e}[38;2;148;163;184m(nao disponivel)${e}[0m"
}

# Firewall
try {
    $fw = Get-NetFirewallProfile -All -ErrorAction SilentlyContinue
    $fwEnabled = $fw | Where-Object { $_.Enabled -eq $true } | Measure-Object | Select-Object -ExpandProperty Count
    $fwStatus = if ($fwEnabled -gt 0) { "${e}[38;2;34;197;94mACTIVO ($fwEnabled)${e}[0m" } else { "${e}[38;2;239;68;68mDESACTIVADO${e}[0m" }
    Write-Host "  ${e}[38;2;100;149;237m$("Firewall".PadRight(28))${e}[0m  $fwStatus"
} catch {
    Write-Host "  ${e}[38;2;100;149;237m$("Firewall".PadRight(28))${e}[0m  ${e}[38;2;148;163;184m(nao disponivel)${e}[0m"
}

# ── Drivers ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m>> Drivers${e}[0m"
Write-Host ""

try {
    $pnpDevices = Get-PnpDevice -Status Error -ErrorAction SilentlyContinue
    $errorCount = ($pnpDevices | Measure-Object).Count
    if ($errorCount -gt 0) {
        Write-Host "  ${e}[38;2;239;68;68m[X]  $errorCount dispositivos com drivers em falta:${e}[0m"
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
