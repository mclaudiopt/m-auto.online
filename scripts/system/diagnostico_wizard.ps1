# system/diagnostico_wizard.ps1 - Diagnostico + acoes do sistema
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$e = [char]27

function Write-Row($label, $value, $color = "97") {
    Write-Host "  ${e}[38;2;100;149;237m$($label.PadRight(28))${e}[0m  ${e}[${color}m$value${e}[0m"
}

function Ask-YesNo($question) {
    Write-Host ""
    $response = Read-Host "  ${e}[38;2;100;149;237m·${e}[0m  $question [s/n]"
    return $response -match "^[sS]"
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

# Security Status
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
Write-Host "  ${e}[38;2;100;149;237m>> Acoes Disponiveis${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"

$actions = @()

if ($blActive -and (Ask-YesNo "Desativar BitLocker?")) {
    $actions += @{ name = "BitLocker"; action = "bitlocker" }
}

if ($defActive -and (Ask-YesNo "Desativar Windows Defender?")) {
    $actions += @{ name = "Windows Defender"; action = "defender" }
}

if ($fwEnabled -and (Ask-YesNo "Desativar Firewall?")) {
    $actions += @{ name = "Firewall"; action = "firewall" }
}

if (Ask-YesNo "Limpar ficheiros temporarios?") {
    $actions += @{ name = "Cleanup"; action = "cleanup" }
}

if (Ask-YesNo "Teste de velocidade (Ookla Speedtest)?") {
    $actions += @{ name = "Speedtest"; action = "speedtest" }
}

if (Ask-YesNo "Desactivar actualizacoes?") {
    $actions += @{ name = "Disable Updates"; action = "disable_updates" }
}

if (Ask-YesNo "Aplicar Alta Performance?") {
    $actions += @{ name = "Power Plan"; action = "power_plan" }
}

if (Ask-YesNo "Alterar DNS para Cloudflare?") {
    $actions += @{ name = "DNS Cloudflare"; action = "dns_cloudflare" }
}

Write-Host ""

if ($actions.Count -eq 0) {
    Write-Host "  ${e}[38;2;148;163;184m(nenhuma acao selecionada)${e}[0m"
    Write-Host ""
    Read-Host "  Pressione ENTER para voltar"
    return
}

Write-Host "  ${e}[38;2;100;149;237m>> Executando...${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

$completed = @()
$failed = @()

foreach ($action in $actions) {
    Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  $($action.name)..." -NoNewline
    try {
        switch ($action.action) {
            "bitlocker" {
                Disable-BitLocker -MountPoint C: -ErrorAction Stop | Out-Null
                Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
                $completed += $action.name
            }
            "defender" {
                Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction Stop
                Stop-Service -Name WinDefend -Force -ErrorAction SilentlyContinue
                Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
                $completed += $action.name
            }
            "firewall" {
                Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False -ErrorAction Stop
                Remove-NetFirewallRule -All -ErrorAction SilentlyContinue
                Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
                $completed += $action.name
            }
            "cleanup" {
                Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
                Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
                $completed += $action.name
            }
            "speedtest" {
                Write-Host ""
                irm "$env:BASE_URL/system/speedtest.ps1" -UseBasicParsing | iex
                $completed += $action.name
            }
            "disable_updates" {
                # Just launch the script
                Write-Host ""
                irm "$env:BASE_URL/system/disable_updates.ps1" -UseBasicParsing | iex
                $completed += $action.name
            }
            "power_plan" {
                Write-Host ""
                irm "$env:BASE_URL/system/power_plan.ps1" -UseBasicParsing | iex
                $completed += $action.name
            }
            "dns_cloudflare" {
                Write-Host ""
                irm "$env:BASE_URL/system/dns_cloudflare.ps1" -UseBasicParsing | iex
                $completed += $action.name
            }
        }
    } catch {
        Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
        $failed += $action.name
    }
}

Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m>> Resumo${e}[0m"
if ($completed.Count -gt 0) {
    Write-Host "  ${e}[38;2;34;197;94m✓ Concluido:${e}[0m"
    $completed | ForEach-Object { Write-Host "    - $_" }
}
if ($failed.Count -gt 0) {
    Write-Host "  ${e}[38;2;239;68;68m✗ Falhou:${e}[0m"
    $failed | ForEach-Object { Write-Host "    - $_" }
}

Write-Host ""
Read-Host "  Pressione ENTER para voltar"
