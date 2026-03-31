# prep/basic.ps1 - Preparacao basica
# Desativa Defender + Tamper + Firewall + BitLocker + SecureBoot + Apaga regras + Instala 7-Zip + Activa Windows
$e = [char]27

function Write-Step($n, $total, $msg) {
    Write-Host "  ${e}[38;2;100;149;237m[$n/$total]${e}[0m  $msg" -NoNewline
}
function Write-OK   { Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m" }
function Write-Fail { Write-Host "  ${e}[38;2;239;68;68m[FALHOU]${e}[0m" }
function Write-Skip { Write-Host "  ${e}[38;2;250;204;21m[JA FEITO]${e}[0m" }

Write-Host ""
Write-Host "  ${e}[1;97mPreparacao Basic${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m[OPCOES ADICIONAIS]${e}[0m"
Write-Host ""
$disableBL = Read-Host "  Desativar BitLocker [s/n]"
$disableSB = Read-Host "  Desativar Secure Boot [s/n]"
Write-Host ""

# Pre-verificacao: estado do servico Defender
$defSvc = Get-Service -Name WinDefend -ErrorAction SilentlyContinue
$defRunning = $defSvc -and ($defSvc.Status -eq 'Running')


# ── 1. Tamper Protection OFF ──────────────────────────────────────────────
Write-Step 1 5 "Tamper Protection OFF...          "
if (-not $defRunning) {
    Write-Skip
} else {
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
        Write-OK
    } catch {
        # Se Set-Acl falhou mas IsTamperProtected=false -> ja esta OFF
        $tp = (Get-MpComputerStatus -ErrorAction SilentlyContinue).IsTamperProtected
        if ($tp -eq $false) { Write-Skip }
        elseif ($tp -eq $true) {
            Write-Host "  ${e}[38;2;250;204;21m[MANUAL]${e}[0m  -> Seguranca do Windows > Protecao virus > desativar"
        } else { Write-OK }
    }
}


# ── 2. Microsoft Defender OFF ────────────────────────────────────────────
Write-Step 2 5 "Microsoft Defender OFF...         "
if (-not $defRunning) {
    Write-Skip
} else {
    try {
        Set-MpPreference `
            -DisableRealtimeMonitoring $true `
            -DisableBehaviorMonitoring $true `
            -DisableIOAVProtection $true `
            -DisableScriptScanning $true `
            -DisableArchiveScanning $true `
            -DisableBlockAtFirstSeen $true `
            -MAPSReporting 0 `
            -SubmitSamplesConsent 2 `
            -ErrorAction Stop
        Stop-Service -Name WinDefend -Force -ErrorAction SilentlyContinue
        Set-Service  -Name WinDefend -StartupType Disabled -ErrorAction SilentlyContinue
        Write-OK
    } catch {
        # 0x800106ba = servico nao esta a correr = ja desativado
        if ($_.Exception.Message -match "0x800106ba" -or $_.Exception.HResult -eq -2147023158) {
            Write-Skip
        } else {
            Write-Fail
            Write-Host "  ${e}[38;2;148;163;184m    $_${e}[0m"
        }
    }
}


# ── 3. Firewall OFF + apagar todas as regras ─────────────────────────────
Write-Step 3 5 "Firewall OFF + limpar regras...   "
try {
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False -ErrorAction Stop
    $rules = Get-NetFirewallRule -ErrorAction SilentlyContinue
    $count = if ($rules) { $rules.Count } else { 0 }
    if ($count -gt 0) {
        Remove-NetFirewallRule -All -ErrorAction SilentlyContinue
        Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m  ($count regras apagadas)"
    } else {
        Write-Host "  ${e}[38;2;250;204;21m[OK]${e}[0m  (firewall ja limpa)"
    }
} catch {
    Write-Fail
    Write-Host "  ${e}[38;2;148;163;184m    $_${e}[0m"
}

# ── 4. BitLocker OFF (opcional) ──────────────────────────────────────────
if ($disableBL -match "^[sS]") {
    Write-Step 4 7 "BitLocker OFF...                  "
    try {
        $bl = Get-BitLockerVolume -MountPoint C: -ErrorAction SilentlyContinue
        if ($bl -and $bl.ProtectionStatus -eq "On") {
            Disable-BitLocker -MountPoint C: -ErrorAction Stop | Out-Null
            Write-OK
        } else {
            Write-Skip
        }
    } catch {
        Write-Fail
        Write-Host "  ${e}[38;2;148;163;184m    $_${e}[0m"
    }
} else {
    Write-Step 4 5 "BitLocker OFF...                  "
    Write-Host "  ${e}[38;2;250;204;21m[PULADO]${e}[0m"
}

# ── 5. Secure Boot OFF (opcional) ────────────────────────────────────────
if ($disableSB -match "^[sS]") {
    Write-Step 5 7 "Secure Boot OFF...                "
    Write-Host "  ${e}[38;2;250;204;21m[MANUAL]${e}[0m  -> Reinicia em modo UEFI BIOS Setup"
    Write-Host "  ${e}[38;2;148;163;184m         -> Security/Secure Boot > Disabled${e}[0m"
} else {
    Write-Step 5 5 "Secure Boot OFF...                "
    Write-Host "  ${e}[38;2;250;204;21m[PULADO]${e}[0m"
}

# ── 6. Instalar 7-Zip ────────────────────────────────────────────────────
Write-Step 6 7 "Instalar 7-Zip...                 "
$inst = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" `
    -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "*7-Zip*" }
if ($inst) {
    Write-Skip
} else {
    $tmp = "$env:TEMP\7z_setup.exe"
    try {
        Invoke-WebRequest -Uri "https://www.7-zip.org/a/7z2600-x64.exe" `
            -OutFile $tmp -UseBasicParsing -ErrorAction Stop
        Start-Process -FilePath $tmp -ArgumentList "/S" -Wait -ErrorAction Stop
        Remove-Item $tmp -Force -ErrorAction SilentlyContinue
        $ok = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" `
            -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "*7-Zip*" }
        if ($ok) { Write-OK } else { Write-Fail }
    } catch {
        Write-Fail
        Write-Host "  ${e}[38;2;148;163;184m    $_${e}[0m"
    }
}

# ── 7. Activar Windows ───────────────────────────────────────────────────
Write-Step 7 7 "Activar Windows...                "
Write-Host ""
try {
    irm https://get.activated.win | iex
} catch {
    Write-Fail
    Write-Host "  ${e}[38;2;148;163;184m    $_${e}[0m"
}

# ── Resumo ───────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host "  ${e}[38;2;148;163;184m  Recomenda-se reiniciar o PC para aplicar tudo.${e}[0m"
Write-Host ""
Wait-Key
