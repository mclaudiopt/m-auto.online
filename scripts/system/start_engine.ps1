# system/start_engine.ps1 - Start Engine (tudo integrado)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
$e = [char]27

Write-Host ""
Write-Host "  ${e}[1;97mStart Engine${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

#-- SYSTEM INFO ──────────────────────────────────────────────────────────
Write-Host "  ${e}[38;2;100;149;237m[SISTEMA]${e}[0m"

$os = Get-CimInstance Win32_OperatingSystem
$winVer = if ($os.Caption -match "11") { "Windows 11" } elseif ($os.Caption -match "10") { "Windows 10" } else { $os.Caption }
$ram    = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
$free   = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
$usado  = $ram - $free
$percUsado = if ($ram -gt 0) { [math]::Round(($usado / $ram) * 100, 1) } else { 0 }

Write-Host "  ${e}[97m$winVer | RAM: ${usado}GB/${ram}GB ($percUsado%)${e}[0m"

$drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Name -match "^[A-Z]$" }
$driveStr = ""
$drives | ForEach-Object {
    $usedRaw = $_.Used
    $freeRaw = $_.Free
    if ($usedRaw -eq $null -or $freeRaw -eq $null) { return }
    $used  = [math]::Round($usedRaw / 1GB, 1)
    $total = $used + [math]::Round($freeRaw / 1GB, 1)
    if ($total -eq 0) { return }
    $perc = [math]::Round(($used / $total) * 100, 1)
    if ($driveStr) { $driveStr += " | " }
    $driveStr += "$($_.Name): $perc%"
}
Write-Host "  ${e}[97m$driveStr${e}[0m"

# Security status
$blActive  = $false
$defActive = $false
$fwEnabled = $false
$secStatus = ""

try {
    $bl = Get-BitLockerVolume -MountPoint C: -ErrorAction SilentlyContinue
    $blActive = $bl -and ($bl.ProtectionStatus -eq "On")
    $secStatus += if ($blActive) { "BitLocker: ${e}[38;2;34;197;94mACTIVO${e}[0m" } else { "BitLocker: ${e}[38;2;239;68;68mDESACTIVADO${e}[0m" }
} catch {
    $secStatus += "BitLocker: ${e}[38;2;148;163;184mN/A${e}[0m"
}

$secStatus += " | "

try {
    $def = Get-MpComputerStatus -ErrorAction SilentlyContinue
    $defActive = $def -and $def.RealTimeProtectionEnabled
    $secStatus += if ($defActive) { "Defender: ${e}[38;2;34;197;94mACTIVO${e}[0m" } else { "Defender: ${e}[38;2;239;68;68mDESACTIVADO${e}[0m" }
} catch {
    $secStatus += "Defender: ${e}[38;2;148;163;184mN/A${e}[0m"
}

$secStatus += " | "

try {
    $fw = Get-NetFirewallProfile -All -ErrorAction SilentlyContinue
    $fwEnabled = ($fw | Where-Object { $_.Enabled -eq $true } | Measure-Object).Count -gt 0
    $secStatus += if ($fwEnabled) { "Firewall: ${e}[38;2;34;197;94mACTIVO${e}[0m" } else { "Firewall: ${e}[38;2;239;68;68mDESACTIVADO${e}[0m" }
} catch {
    $secStatus += "Firewall: ${e}[38;2;148;163;184mN/A${e}[0m"
}

Write-Host "  ${e}[97m$secStatus${e}[0m"
Write-Host ""

#-- ACOES ────────────────────────────────────────────────────────────────
Write-Host "  ${e}[38;2;100;149;237m[ACOES]${e}[0m"
Write-Host ""

$completed = @()
$failed    = @()

#-- 0. Wallpaper M-Auto ──────────────────────────────────────────────────
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  Aplicar Wallpaper M-Auto?" -NoNewline
$response = Read-Host " [s/n]"
if ($response -match "^[sS]") {
    Write-Host ""
    try {
        irm "https://m-auto.online/scripts/utils/set_wallpaper.ps1" -UseBasicParsing | iex
        $completed += "Wallpaper M-Auto"
    } catch {
        Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m  Nao foi possivel aplicar wallpaper"
        $failed += "Wallpaper M-Auto"
    }
}

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

#-- 2. Defender OFF ──────────────────────────────────────────────────────
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
            Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
            $completed += "Firewall"
        } catch {
            Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
            $failed += "Firewall"
        }
    }
}

#-- 4. Tamper Protection ─────────────────────────────────────────────────
$tpEnabled = $false
try {
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows Defender\Features"
    $tpVal = (Get-ItemProperty $regPath -Name "TamperProtection" -ErrorAction SilentlyContinue).TamperProtection
    $tpEnabled = ($tpVal -eq 5)
} catch {}

if ($tpEnabled) {
    Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  Desativar Tamper Protection?" -NoNewline
    $response = Read-Host " [s/n]"
    if ($response -match "^[sS]") {
        Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A desativar..." -NoNewline
        try {
            $regPath = "HKLM:\SOFTWARE\Microsoft\Windows Defender\Features"
            $acl = Get-Acl $regPath -ErrorAction Stop
            $adminSid = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544")
            $acl.SetOwner($adminSid)
            $rule = New-Object System.Security.AccessControl.RegistryAccessRule(
                $adminSid, "FullControl",
                [System.Security.AccessControl.InheritanceFlags]"ContainerInherit,ObjectInherit",
                [System.Security.AccessControl.PropagationFlags]::None,
                [System.Security.AccessControl.AccessControlType]::Allow
            )
            $acl.AddAccessRule($rule)
            Set-Acl -Path $regPath -AclObject $acl -ErrorAction Stop
            Set-ItemProperty -Path $regPath -Name "TamperProtection" -Value 4 -ErrorAction Stop
            Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
            $completed += "Tamper Protection"
        } catch {
            Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m  Desativar manualmente: Windows Security > Virus & threat protection > Manage settings${e}[0m"
            $failed += "Tamper Protection"
        }
    }
}

#-- 5. Instalar 7-Zip ────────────────────────────────────────────────────
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  Instalar 7-Zip?" -NoNewline
$response = Read-Host " [s/n]"
if ($response -match "^[sS]") {
    Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A instalar..." -NoNewline
    try {
        $inst = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" `
            -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "*7-Zip*" }
        if (-not $inst) {
            $arch = $env:PROCESSOR_ARCHITECTURE
            $exeName = if ($arch -eq "ARM64") { "7z2409-arm64.exe" } elseif ($arch -eq "x86") { "7z2409.exe" } else { "7z2409-x64.exe" }
            $dlDir = "C:\M-auto\Temp"; if (-not (Test-Path $dlDir)) { New-Item -ItemType Directory -Path $dlDir -Force | Out-Null }
            $tmp = "$dlDir\7z_setup.exe"
            Invoke-WebRequest -Uri "https://www.7-zip.org/a/$exeName" `
                -OutFile $tmp -UseBasicParsing -ErrorAction Stop -TimeoutSec 30
            Start-Process -FilePath $tmp -ArgumentList "/S" -Wait -ErrorAction Stop
            Remove-Item $tmp -Force -ErrorAction SilentlyContinue
            Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
            $completed += "7-Zip"
        } else {
            Write-Host "  ${e}[38;2;250;204;21m[JA]${e}[0m"
        }
    } catch {
        Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
        $failed += "7-Zip"
    }
}

#-- 6. Ativar Windows ────────────────────────────────────────────────────
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  Ativar Windows?" -NoNewline
$response = Read-Host " [s/n]"
if ($response -match "^[sS]") {
    Write-Host ""
    try {
        irm https://get.activated.win -UseBasicParsing | iex
        $completed += "Windows Activation"
    } catch {
        Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
        $failed += "Windows Activation"
    }
}

#-- 7. Cleanup ───────────────────────────────────────────────────────────
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

#-- 8. Criar Restore Point ───────────────────────────────────────────────
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  Criar ponto de restauro?" -NoNewline
$response = Read-Host " [s/n]"
if ($response -match "^[sS]") {
    Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A criar..." -NoNewline
    try {
        $srEnabled = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" `
            -Name "RPSessionInterval" -ErrorAction SilentlyContinue).RPSessionInterval
        $vss = Get-Service VSS -ErrorAction SilentlyContinue
        if ($vss -and ($srEnabled -ne 0)) {
            Checkpoint-Computer -Description "M-Auto Backup" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
            Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
            $completed += "Restore Point"
        } else {
            Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
            Checkpoint-Computer -Description "M-Auto Backup" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
            Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
            $completed += "Restore Point"
        }
    } catch {
        Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
        $failed += "Restore Point"
    }
}

#-- 9. DNS Cloudflare ────────────────────────────────────────────────────
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  Alterar DNS para Cloudflare?" -NoNewline
$response = Read-Host " [s/n]"
if ($response -match "^[sS]") {
    Write-Host ""
    try {
        irm "https://m-auto.online/scripts/system/dns_cloudflare.ps1" -UseBasicParsing | iex
        $completed += "DNS Cloudflare"
    } catch {
        Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
        $failed += "DNS Cloudflare"
    }
}

#-- RESUMO ───────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m>> Resumo${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

if ($completed.Count -gt 0) {
    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m  $($completed -join ', ')"
}

if ($failed.Count -gt 0) {
    Write-Host "  ${e}[38;2;239;68;68m[X]${e}[0m   $($failed -join ', ')"
    Write-Host "  ${e}[38;2;148;163;184m      Tente novamente em Tools > Backup${e}[0m"
}

Write-Host ""
Write-Host "  ${e}[38;2;148;163;184m  Recomenda-se reiniciar o PC.${e}[0m"
Write-Host ""
Read-Host "  Pressione ENTER para voltar"
