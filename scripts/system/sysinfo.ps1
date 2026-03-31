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
Write-Row "Discos" ""

$drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Name -match "^[A-Z]$" }
$drives | ForEach-Object {
    $used = [math]::Round($_.Used / 1GB, 1)
    $free = [math]::Round($_.Free / 1GB, 1)
    $total = $used + $free
    $perc = [math]::Round(($used / $total) * 100, 1)
    $color = if ($perc -gt 80) { "31" } elseif ($perc -gt 60) { "33" } else { "97" }
    Write-Host "    ${e}[38;2;100;149;237m$($_.Name): $used GB / $total GB ($perc%)${e}[0m"
}

$diskCount = ($drives | Measure-Object).Count
Write-Row "Total Discos" "$diskCount"
Write-Row "Secure Boot" ""

# ── Seguranca ───────────────────────────────────────────────────────────
# Secure Boot
try {
    $sbEnabled = Confirm-SecureBootUEFI -ErrorAction SilentlyContinue
    $sbStatus = if ($sbEnabled -eq $true) { "${e}[38;2;34;197;94mACTIVO${e}[0m" } else { "${e}[38;2;239;68;68mDESACTIVADO${e}[0m" }
} catch {
    $sbStatus = "${e}[38;2;148;163;184mnao disponivel (Legacy BIOS)${e}[0m"
}
Write-Host "    $sbStatus"

# BitLocker
Write-Row "BitLocker" ""
try {
    $bl = Get-BitLockerVolume -MountPoint C: -ErrorAction SilentlyContinue
    if ($bl -and $bl.ProtectionStatus -eq "On") {
        Write-Host "    ${e}[38;2;34;197;94mACTIVO${e}[0m"
        $blActive = $true
    } else {
        Write-Host "    ${e}[38;2;239;68;68mDESACTIVADO${e}[0m"
        $blActive = $false
    }
} catch {
    Write-Host "    ${e}[38;2;148;163;184m(nao disponivel)${e}[0m"
    $blActive = $false
}

# Defender
Write-Row "Windows Defender" ""
try {
    $def = Get-MpComputerStatus -ErrorAction SilentlyContinue
    if ($def.RealTimeProtectionEnabled) {
        Write-Host "    ${e}[38;2;34;197;94mACTIVO${e}[0m"
        $defActive = $true
    } else {
        Write-Host "    ${e}[38;2;239;68;68mDESACTIVADO${e}[0m"
        $defActive = $false
    }
} catch {
    Write-Host "    ${e}[38;2;148;163;184m(nao disponivel)${e}[0m"
    $defActive = $false
}

# Firewall
Write-Row "Firewall" ""
try {
    $fw = Get-NetFirewallProfile -All -ErrorAction SilentlyContinue
    $fwEnabled = $fw | Where-Object { $_.Enabled -eq $true } | Measure-Object | Select-Object -ExpandProperty Count
    if ($fwEnabled -gt 0) {
        Write-Host "    ${e}[38;2;34;197;94mACTIVO ($fwEnabled)${e}[0m"
        $fwActive = $true
    } else {
        Write-Host "    ${e}[38;2;239;68;68mDESACTIVADO${e}[0m"
        $fwActive = $false
    }
} catch {
    Write-Host "    ${e}[38;2;148;163;184m(nao disponivel)${e}[0m"
    $fwActive = $false
}

# ── Drivers ─────────────────────────────────────────────────────────────
Write-Row "Drivers" ""
try {
    $pnpDevices = Get-PnpDevice -Status Error -ErrorAction SilentlyContinue
    $errorCount = ($pnpDevices | Measure-Object).Count
    if ($errorCount -gt 0) {
        Write-Host "    ${e}[38;2;239;68;68m[X] $errorCount em falta${e}[0m"
    } else {
        Write-Host "    ${e}[38;2;34;197;94m[OK] Todos instalados${e}[0m"
    }
} catch {
    Write-Host "    ${e}[38;2;148;163;184m(nao foi possivel verificar)${e}[0m"
}

Write-Host ""

# ── Confirmacoes ────────────────────────────────────────────────────────
$changes = @()

# BitLocker
if ($blActive) {
    $r = Read-Host "  Desativar BitLocker [s/n]"
    if ($r -match "^[sS]") {
        try {
            Disable-BitLocker -MountPoint C: -ErrorAction Stop | Out-Null
            Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m]  BitLocker desativado"
            $changes += "BitLocker"
        } catch {
            Write-Host "  ${e}[38;2;239;68;68m[X]   Erro ao desativar BitLocker${e}[0m"
        }
    }
}

# Defender
if ($defActive) {
    $r = Read-Host "  Desativar Windows Defender [s/n]"
    if ($r -match "^[sS]") {
        try {
            Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction Stop
            Stop-Service -Name WinDefend -Force -ErrorAction SilentlyContinue
            Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m]  Windows Defender desativado"
            $changes += "Defender"
        } catch {
            Write-Host "  ${e}[38;2;239;68;68m[X]   Erro ao desativar Defender${e}[0m"
        }
    }
}

# Firewall
if ($fwActive) {
    $r = Read-Host "  Desativar Firewall [s/n]"
    if ($r -match "^[sS]") {
        try {
            Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False -ErrorAction Stop
            Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m]  Firewall desativado"
            $changes += "Firewall"
        } catch {
            Write-Host "  ${e}[38;2;239;68;68m[X]   Erro ao desativar Firewall${e}[0m"
        }
    }
}

# Windows Activation
$r = Read-Host "  Activar Windows [s/n]"
if ($r -match "^[sS]") {
    Write-Host ""
    irm https://get.activated.win | iex
    $changes += "Windows Activation"
}

Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m>> Resumo Final${e}[0m]"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

# Mostra info atualizada
$os = Get-CimInstance Win32_OperatingSystem
$winVer = if ($os.Caption -match "11") { "Windows 11" } elseif ($os.Caption -match "10") { "Windows 10" } else { $os.Caption }
Write-Row "SO" "$winVer"

$comp = Get-CimInstance Win32_ComputerSystem
Write-Row "Marca" "$($comp.Manufacturer)"
Write-Row "Modelo" "$($comp.Model)"

$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
Write-Row "Processador" "$($cpu.Name.Trim())"

$ram = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
$free = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
$usado = $ram - $free
$percUsado = [math]::Round(($usado / $ram) * 100, 1)
Write-Row "RAM" "${usado} GB / ${ram} GB ($percUsado%)"
Write-Row "Discos" ""

$drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Name -match "^[A-Z]$" }
$drives | ForEach-Object {
    $used = [math]::Round($_.Used / 1GB, 1)
    $free = [math]::Round($_.Free / 1GB, 1)
    $total = $used + $free
    $perc = [math]::Round(($used / $total) * 100, 1)
    Write-Host "    ${e}[38;2;100;149;237m$($_.Name): $used GB / $total GB ($perc%)${e}[0m"
}

Write-Row "Secure Boot" ""
try {
    $sbEnabled = Confirm-SecureBootUEFI -ErrorAction SilentlyContinue
    $sbStatus = if ($sbEnabled -eq $true) { "${e}[38;2;34;197;94mACTIVO${e}[0m" } else { "${e}[38;2;239;68;68mDESACTIVADO${e}[0m" }
    Write-Host "    $sbStatus"
} catch {
    Write-Host "    ${e}[38;2;148;163;184mnao disponivel (Legacy BIOS)${e}[0m"
}

Write-Row "BitLocker" ""
try {
    $bl = Get-BitLockerVolume -MountPoint C: -ErrorAction SilentlyContinue
    if ($bl -and $bl.ProtectionStatus -eq "On") {
        Write-Host "    ${e}[38;2;34;197;94mACTIVO${e}[0m"
    } else {
        Write-Host "    ${e}[38;2;239;68;68mDESACTIVADO${e}[0m"
    }
} catch {
    Write-Host "    ${e}[38;2;148;163;184m(nao disponivel)${e}[0m"
}

Write-Row "Windows Defender" ""
try {
    $def = Get-MpComputerStatus -ErrorAction SilentlyContinue
    if ($def.RealTimeProtectionEnabled) {
        Write-Host "    ${e}[38;2;34;197;94mACTIVO${e}[0m"
    } else {
        Write-Host "    ${e}[38;2;239;68;68mDESACTIVADO${e}[0m"
    }
} catch {
    Write-Host "    ${e}[38;2;148;163;184m(nao disponivel)${e}[0m"
}

Write-Row "Firewall" ""
try {
    $fw = Get-NetFirewallProfile -All -ErrorAction SilentlyContinue
    $fwEnabled = $fw | Where-Object { $_.Enabled -eq $true } | Measure-Object | Select-Object -ExpandProperty Count
    if ($fwEnabled -gt 0) {
        Write-Host "    ${e}[38;2;34;197;94mACTIVO ($fwEnabled)${e}[0m"
    } else {
        Write-Host "    ${e}[38;2;239;68;68mDESACTIVADO${e}[0m"
    }
} catch {
    Write-Host "    ${e}[38;2;148;163;184m(nao disponivel)${e}[0m"
}

if ($changes.Count -gt 0) {
    Write-Host ""
    Write-Host "  ${e}[38;2;100;149;237m>> Alteracoes Realizadas${e}[0m]"
    $changes | ForEach-Object { Write-Host "    ${e}[38;2;34;197;94m✓${e}[0m]  $_" }
}

Write-Host ""
Wait-Key
