# system/diagnostico_wizard.ps1 - Diagnostico + acoes (executa logo)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$e = [char]27

function Write-Row($label, $value, $color = "97") {
    Write-Host "  ${e}[38;2;100;149;237m$($label.PadRight(28))${e}[0m  ${e}[${color}m$value${e}[0m"
}

#-- DIAGNOSTICO DO SISTEMA ---------------------------------------------------
Write-Host ""
Write-Host "  ${e}[1;97mDiagnostico do Sistema${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

# Windows Version
$os = Get-CimInstance Win32_OperatingSystem
$winVer = if ($os.Caption -match "11") { "Windows 11" } elseif ($os.Caption -match "10") { "Windows 10" } else { $os.Caption }
Write-Row "SO" "$winVer"

# Computer Info
$comp = Get-CimInstance Win32_ComputerSystem
Write-Row "Marca" "$($comp.Manufacturer)"
Write-Row "Modelo" "$($comp.Model)"

# Memory
$ram = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
$free = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
$usado = $ram - $free
$percUsado = [math]::Round(($usado / $ram) * 100, 1)
Write-Row "RAM" "${usado} GB / ${ram} GB ($percUsado%)"

# Storage
Write-Row "Discos" ""
$drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Name -match "^[A-Z]$" }
$drives | ForEach-Object {
    $used = [math]::Round($_.Used / 1GB, 1)
    $free = [math]::Round($_.Free / 1GB, 1)
    $total = $used + $free
    $perc = [math]::Round(($used / $total) * 100, 1)
    Write-Host "    ${e}[38;2;100;149;237m$($_.Name): $used GB / $total GB ($perc%)${e}[0m"
}

# Security
try {
    $bl = Get-BitLockerVolume -MountPoint C: -ErrorAction SilentlyContinue
    if ($bl -and $bl.ProtectionStatus -eq "On") {
        Write-Row "BitLocker" "${e}[38;2;34;197;94mACTIVO${e}[0m"
        $blActive = $true
    } else {
        Write-Row "BitLocker" "${e}[38;2;239;68;68mDESACTIVADO${e}[0m"
        $blActive = $false
    }
} catch {
    Write-Row "BitLocker" "${e}[38;2;148;163;184mnao disponivel${e}[0m"
    $blActive = $false
}

try {
    $def = Get-MpComputerStatus -ErrorAction SilentlyContinue
    if ($def.RealTimeProtectionEnabled) {
        Write-Row "Windows Defender" "${e}[38;2;34;197;94mACTIVO${e}[0m"
        $defActive = $true
    } else {
        Write-Row "Windows Defender" "${e}[38;2;239;68;68mDESACTIVADO${e}[0m"
        $defActive = $false
    }
} catch {
    Write-Row "Windows Defender" "${e}[38;2;148;163;184mnao disponivel${e}[0m"
    $defActive = $false
}

try {
    $fw = Get-NetFirewallProfile -All -ErrorAction SilentlyContinue
    $fwEnabled = ($fw | Where-Object { $_.Enabled -eq $true } | Measure-Object).Count -gt 0
    if ($fwEnabled) {
        Write-Row "Firewall" "${e}[38;2;34;197;94mACTIVO${e}[0m"
    } else {
        Write-Row "Firewall" "${e}[38;2;239;68;68mDESACTIVADO${e}[0m"
    }
} catch {
    Write-Row "Firewall" "${e}[38;2;148;163;184mnao disponivel${e}[0m"
    $fwEnabled = $false
}

Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m>> Acoes${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

$completed = @()
$failed = @()

#-- 1. BitLocker OFF ─────────────────────────────────────────────────────
if ($blActive) {
    Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  Desativar BitLocker?" -NoNewline
    $response = Read-Host " [s/n]"
    if ($response -match "^[sS]") {
        Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A desativar..." -NoNewline
        try {
            Disable-BitLocker -MountPoint C: -ErrorAction Stop | Out-Null
            Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
            $completed += "BitLocker"
        } catch {
            Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
            $failed += "BitLocker"
        }
    }
}

#-- 2. Windows Defender OFF ──────────────────────────────────────────────
if ($defActive) {
    Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  Desativar Windows Defender?" -NoNewline
    $response = Read-Host " [s/n]"
    if ($response -match "^[sS]") {
        Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A desativar..." -NoNewline
        try {
            Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction Stop
            Stop-Service -Name WinDefend -Force -ErrorAction SilentlyContinue
            Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
            $completed += "Windows Defender"
        } catch {
            Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
            $failed += "Windows Defender"
        }
    }
}

#-- 3. Firewall OFF ──────────────────────────────────────────────────────
if ($fwEnabled) {
    Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  Desativar Firewall?" -NoNewline
    $response = Read-Host " [s/n]"
    if ($response -match "^[sS]") {
        Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A desativar..." -NoNewline
        try {
            Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False -ErrorAction Stop
            Remove-NetFirewallRule -All -ErrorAction SilentlyContinue
            Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
            $completed += "Firewall"
        } catch {
            Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
            $failed += "Firewall"
        }
    }
}

#-- 4. Limpar ficheiros temporarios ──────────────────────────────────────
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  Limpar ficheiros temporarios?" -NoNewline
$response = Read-Host " [s/n]"
if ($response -match "^[sS]") {
    Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A limpar..." -NoNewline
    try {
        Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
        $completed += "Cleanup"
    } catch {
        Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
        $failed += "Cleanup"
    }
}

#-- 5. Teste de velocidade ───────────────────────────────────────────────
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  Teste de velocidade (Ookla Speedtest)?" -NoNewline
$response = Read-Host " [s/n]"
if ($response -match "^[sS]") {
    Write-Host ""
    try {
        irm "https://m-auto.online/scripts/system/speedtest.ps1" -UseBasicParsing | iex
        $completed += "Speedtest"
    } catch {
        Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m  $_"
        $failed += "Speedtest"
    }
}

#-- 6. Desactivar actualizacoes ───────────────────────────────────────────
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  Desactivar actualizacoes?" -NoNewline
$response = Read-Host " [s/n]"
if ($response -match "^[sS]") {
    Write-Host ""
    try {
        irm "https://m-auto.online/scripts/system/disable_updates.ps1" -UseBasicParsing | iex
        $completed += "Disable Updates"
    } catch {
        Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m  Nao foi possivel carregar o script"
        $failed += "Disable Updates"
    }
}

#-- 7. Alta Performance ──────────────────────────────────────────────────
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  Aplicar Alta Performance?" -NoNewline
$response = Read-Host " [s/n]"
if ($response -match "^[sS]") {
    Write-Host ""
    try {
        irm "https://m-auto.online/scripts/system/power_plan.ps1" -UseBasicParsing | iex
        $completed += "Power Plan"
    } catch {
        Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m  Nao foi possivel carregar o script"
        $failed += "Power Plan"
    }
}

#-- 8. Alterar DNS ──────────────────────────────────────────────────────
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  Alterar DNS para Cloudflare?" -NoNewline
$response = Read-Host " [s/n]"
if ($response -match "^[sS]") {
    Write-Host ""
    try {
        irm "https://m-auto.online/scripts/system/dns_cloudflare.ps1" -UseBasicParsing | iex
        $completed += "DNS Cloudflare"
    } catch {
        Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m  Nao foi possivel carregar o script"
        $failed += "DNS Cloudflare"
    }
}

#-- RESUMO ───────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m>> Resumo${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

if ($completed.Count -gt 0) {
    Write-Host "  ${e}[38;2;34;197;94m✓ Concluido:${e}[0m"
    $completed | ForEach-Object { Write-Host "    - $_" }
}

if ($failed.Count -gt 0) {
    Write-Host ""
    Write-Host "  ${e}[38;2;239;68;68m✗ Falhou:${e}[0m"
    $failed | ForEach-Object { Write-Host "    - $_" }
}

Write-Host ""
Read-Host "  Pressione ENTER para voltar"
