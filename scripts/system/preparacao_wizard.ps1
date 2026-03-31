# system/preparacao_wizard.ps1 - Wizard de preparacao (executa logo ao responder s/n)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$e = [char]27

$completed = @()
$failed = @()

#-- PREPARACAO DO SISTEMA ---------------------------------------------------
Write-Host ""
Write-Host "  ${e}[1;97mPreparacao do Sistema${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

# Pre-verificacao: estado do servico Defender
$defSvc = Get-Service -Name WinDefend -ErrorAction SilentlyContinue
$defRunning = $defSvc -and ($defSvc.Status -eq 'Running')

#-- 1. Tamper Protection OFF ──────────────────────────────────────────────
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  Desativar Tamper Protection?" -NoNewline
$response = Read-Host " [s/n]"
if ($response -match "^[sS]") {
    Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A desativar..." -NoNewline
    try {
        if ($defRunning) {
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
        } else {
            Write-Host "  ${e}[38;2;250;204;21m[JA FEITO]${e}[0m"
        }
    } catch {
        Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
        $failed += "Tamper Protection"
    }
}

#-- 2. Microsoft Defender OFF ────────────────────────────────────────────
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  Desativar Microsoft Defender?" -NoNewline
$response = Read-Host " [s/n]"
if ($response -match "^[sS]") {
    if (-not $defRunning) {
        Write-Host "  ${e}[38;2;250;204;21m[JA FEITO]${e}[0m"
    } else {
        Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A desativar..." -NoNewline
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
            Set-Service -Name WinDefend -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
            $completed += "Microsoft Defender"
        } catch {
            Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
            $failed += "Microsoft Defender"
        }
    }
}

#-- 3. Firewall OFF + apagar regras ──────────────────────────────────────
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  Desativar Firewall + limpar regras?" -NoNewline
$response = Read-Host " [s/n]"
if ($response -match "^[sS]") {
    Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A desativar..." -NoNewline
    try {
        Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False -ErrorAction Stop
        $rules = Get-NetFirewallRule -ErrorAction SilentlyContinue
        $count = if ($rules) { $rules.Count } else { 0 }
        if ($count -gt 0) {
            Remove-NetFirewallRule -All -ErrorAction SilentlyContinue
        }
        Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
        $completed += "Firewall"
    } catch {
        Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
        $failed += "Firewall"
    }
}

#-- 4. BitLocker OFF ────────────────────────────────────────────────────
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  Desativar BitLocker?" -NoNewline
$response = Read-Host " [s/n]"
if ($response -match "^[sS]") {
    Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A desativar..." -NoNewline
    try {
        $bl = Get-BitLockerVolume -MountPoint C: -ErrorAction SilentlyContinue
        if ($bl -and $bl.ProtectionStatus -eq "On") {
            Disable-BitLocker -MountPoint C: -ErrorAction Stop | Out-Null
            Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
            $completed += "BitLocker"
        } else {
            Write-Host "  ${e}[38;2;250;204;21m[JA FEITO]${e}[0m"
        }
    } catch {
        Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
        $failed += "BitLocker"
    }
}

#-- 5. Secure Boot OFF ──────────────────────────────────────────────────
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  Desativar Secure Boot? (requer BIOS)" -NoNewline
$response = Read-Host " [s/n]"
if ($response -match "^[sS]") {
    Write-Host "  ${e}[38;2;250;204;21m[MANUAL]${e}[0m"
    Write-Host "  ${e}[38;2;148;163;184m    Reinicie em BIOS e desative em Security > Secure Boot${e}[0m"
}

#-- 6. Instalar 7-Zip ──────────────────────────────────────────────────
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  Instalar 7-Zip?" -NoNewline
$response = Read-Host " [s/n]"
if ($response -match "^[sS]") {
    Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A instalar..." -NoNewline
    try {
        $inst = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" `
            -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "*7-Zip*" }
        if (-not $inst) {
            $tmp = "$env:TEMP\7z_setup.exe"
            Invoke-WebRequest -Uri "https://www.7-zip.org/a/7z2600-x64.exe" `
                -OutFile $tmp -UseBasicParsing -ErrorAction Stop -TimeoutSec 30
            Start-Process -FilePath $tmp -ArgumentList "/S" -Wait -ErrorAction Stop
            Remove-Item $tmp -Force -ErrorAction SilentlyContinue
            Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
            $completed += "7-Zip"
        } else {
            Write-Host "  ${e}[38;2;250;204;21m[JA INSTALADO]${e}[0m"
        }
    } catch {
        Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
        $failed += "7-Zip"
    }
}

#-- 7. Activar Windows ──────────────────────────────────────────────────
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  Ativar Windows?" -NoNewline
$response = Read-Host " [s/n]"
if ($response -match "^[sS]") {
    Write-Host ""
    try {
        irm https://get.activated.win | iex
        $completed += "Windows Activation"
    } catch {
        Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m  Falha na ativacao"
        $failed += "Windows Activation"
    }
}

#-- RESUMO -------------------------------------------------------------------
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
    Write-Host ""
    Write-Host "  ${e}[38;2;148;163;184mDica: Tente novamente em 'Tools' (Menu 4)${e}[0m"
}

Write-Host ""
Write-Host "  ${e}[38;2;148;163;184m  Recomenda-se reiniciar o PC.${e}[0m"
Write-Host ""
Read-Host "  Pressione ENTER para voltar"
