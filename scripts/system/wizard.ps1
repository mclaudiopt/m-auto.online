# system/wizard.ps1 - Diagnostico + Preparacao + Ferramentas (modo wizard automatizado)
$e = [char]27

#-- Helper Functions -------------------------------------------------------
function Write-Row($label, $value, $color = "97") {
    Write-Host "  ${e}[38;2;100;149;237m$($label.PadRight(28))${e}[0m  ${e}[${color}m$value${e}[0m"
}

function Write-Step($n, $total, $msg) {
    Write-Host "  ${e}[38;2;100;149;237m[$n/$total]${e}[0m  $msg" -NoNewline
}

function Write-OK   { Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m" }
function Write-Fail { Write-Host "  ${e}[38;2;239;68;68m[FALHOU]${e}[0m" }
function Write-Skip { Write-Host "  ${e}[38;2;250;204;21m[JA FEITO]${e}[0m" }

function Ask-YesNo($question) {
    Write-Host ""
    $response = Read-Host "  ${e}[38;2;100;149;237m>>  ${e}[1;97m$question${e}[0m [s/n]"
    return $response -match "^[sS]"
}

#-- 1. DIAGNOSTICO DO SISTEMA -----------------------------------------------
Write-Host ""
Write-Host "  ${e}[1;97mDiagnostico, Preparacao & Ferramentas${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

Write-Host "  ${e}[38;2;100;149;237m[1/3] Diagnostico do Sistema${e}[0m"
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
    $color = if ($perc -gt 80) { "31" } elseif ($perc -gt 60) { "33" } else { "97" }
    Write-Host "    ${e}[38;2;100;149;237m$($_.Name): $used GB / $total GB ($perc%)${e}[0m"
}

# Security
Write-Row "Secure Boot" ""
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
    $blActive = $bl -and ($bl.ProtectionStatus -eq "On")
    if ($blActive) {
        Write-Host "    ${e}[38;2;34;197;94mACTIVO${e}[0m"
    } else {
        Write-Host "    ${e}[38;2;239;68;68mDESACTIVADO${e}[0m"
    }
} catch {
    Write-Host "    ${e}[38;2;148;163;184m(nao disponivel)${e}[0m"
    $blActive = $false
}

# Defender
Write-Row "Windows Defender" ""
try {
    $def = Get-MpComputerStatus -ErrorAction SilentlyContinue
    $defActive = $def -and $def.RealTimeProtectionEnabled
    if ($defActive) {
        Write-Host "    ${e}[38;2;34;197;94mACTIVO${e}[0m"
    } else {
        Write-Host "    ${e}[38;2;239;68;68mDESACTIVADO${e}[0m"
    }
} catch {
    Write-Host "    ${e}[38;2;148;163;184m(nao disponivel)${e}[0m"
    $defActive = $false
}

# Firewall
Write-Row "Firewall" ""
try {
    $fw = Get-NetFirewallProfile -All -ErrorAction SilentlyContinue
    $fwEnabled = ($fw | Where-Object { $_.Enabled -eq $true } | Measure-Object).Count -gt 0
    if ($fwEnabled) {
        Write-Host "    ${e}[38;2;34;197;94mACTIVO${e}[0m"
    } else {
        Write-Host "    ${e}[38;2;239;68;68mDESACTIVADO${e}[0m"
    }
} catch {
    Write-Host "    ${e}[38;2;148;163;184m(nao disponivel)${e}[0m"
    $fwEnabled = $false
}

Write-Host ""

#-- 2. PREPARACAO -----------------------------------------------------------
Write-Host "  ${e}[38;2;100;149;237m[2/3] Preparacao do Sistema${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"

$actions = @()

if (Ask-YesNo "Desativar Tamper Protection?") {
    $actions += @{ name = "Tamper Protection"; step = 1; action = "tamper" }
}

if ($defActive -and (Ask-YesNo "Desativar Windows Defender?")) {
    $actions += @{ name = "Windows Defender"; step = 2; action = "defender" }
}

if ($fwEnabled -and (Ask-YesNo "Desativar Firewall?")) {
    $actions += @{ name = "Firewall"; step = 3; action = "firewall" }
}

if ($blActive -and (Ask-YesNo "Desativar BitLocker?")) {
    $actions += @{ name = "BitLocker"; step = 4; action = "bitlocker" }
}

if (Ask-YesNo "Instalar 7-Zip?") {
    $actions += @{ name = "7-Zip"; step = 5; action = "7zip" }
}

if (Ask-YesNo "Ativar Windows?") {
    $actions += @{ name = "Windows Activation"; step = 6; action = "activation" }
}

Write-Host ""

#-- 3. FERRAMENTAS ----------------------------------------------------------
Write-Host "  ${e}[38;2;100;149;237m[3/3] Ferramentas Adicionais${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"

if (Ask-YesNo "Instalar DeskIn (acesso remoto)?") {
    $actions += @{ name = "DeskIn"; action = "deskin" }
}

if (Ask-YesNo "Criar ponto de restauro do sistema?") {
    $actions += @{ name = "Restore Point"; action = "restore" }
}

Write-Host ""

#-- EXECUTAR ACTOES ---------------------------------------------------------
if ($actions.Count -eq 0) {
    Write-Host "  ${e}[38;2;148;163;184m(nenhuma acao selecionada)${e}[0m"
    Write-Host ""
    return
}

Write-Host "  ${e}[38;2;100;149;237m>> Executando acoes...${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

$completed = @()
$failed = @()

foreach ($action in $actions) {
    $label = $action.name
    Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  $label..." -NoNewline

    try {
        switch ($action.action) {
            "tamper" {
                $defSvc = Get-Service -Name WinDefend -ErrorAction SilentlyContinue
                if ($defSvc -and $defSvc.Status -eq 'Running') {
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
                }
                Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
                $completed += $label
            }
            "defender" {
                Set-MpPreference -DisableRealtimeMonitoring $true -DisableBehaviorMonitoring $true `
                    -DisableIOAVProtection $true -DisableScriptScanning $true `
                    -DisableArchiveScanning $true -DisableBlockAtFirstSeen $true `
                    -MAPSReporting 0 -SubmitSamplesConsent 2 -ErrorAction Stop
                Stop-Service -Name WinDefend -Force -ErrorAction SilentlyContinue
                Set-Service -Name WinDefend -StartupType Disabled -ErrorAction SilentlyContinue
                Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
                $completed += $label
            }
            "firewall" {
                Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False -ErrorAction Stop
                Remove-NetFirewallRule -All -ErrorAction SilentlyContinue
                Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
                $completed += $label
            }
            "bitlocker" {
                Disable-BitLocker -MountPoint C: -ErrorAction Stop | Out-Null
                Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
                $completed += $label
            }
            "7zip" {
                $inst = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" `
                    -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "*7-Zip*" }
                if (-not $inst) {
                    $tmp = "$env:TEMP\7z_setup.exe"
                    Invoke-WebRequest -Uri "https://www.7-zip.org/a/7z2600-x64.exe" `
                        -OutFile $tmp -UseBasicParsing -ErrorAction Stop
                    Start-Process -FilePath $tmp -ArgumentList "/S" -Wait -ErrorAction Stop
                    Remove-Item $tmp -Force -ErrorAction SilentlyContinue
                }
                Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
                $completed += $label
            }
            "activation" {
                Write-Host ""
                irm https://get.activated.win | iex
                $completed += $label
            }
            "deskin" {
                # Placeholder - implementar se houver script deskin
                Write-Host "  ${e}[38;2;148;163;184m[MANUAL]${e}[0m"
            }
            "restore" {
                $vss = Get-Service VSS -ErrorAction SilentlyContinue
                if ($vss) {
                    Checkpoint-Computer -Description "Backup by M-Auto" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
                    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
                    $completed += $label
                } else {
                    Write-Host "  ${e}[38;2;148;163;184m[FALHOU]${e}[0m"
                    $failed += $label
                }
            }
        }
    } catch {
        Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
        $failed += $label
    }
}

#-- RESUMO ------------------------------------------------------------------
Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m>> Resumo Final${e}[0m"
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
    Write-Host ""
    Write-Host "  ${e}[38;2;148;163;184mDica: Use 'Opcoes Manuais' para tentar novamente individualmente.${e}[0m"
}

Write-Host ""
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host "  ${e}[38;2;148;163;184m  Recomenda-se reiniciar o PC para aplicar tudo.${e}[0m"
Write-Host ""

Read-Host "  Pressione ENTER para voltar"
