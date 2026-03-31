# system/preparacao_wizard.ps1 - Wizard de preparacao (cada operacao pergunta s/n)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$e = [char]27

function Ask-YesNo($question) {
    Write-Host ""
    $response = Read-Host "  ${e}[38;2;100;149;237m·${e}[0m  $question [s/n]"
    return $response -match "^[sS]"
}

#-- PREPARACAO DO SISTEMA ---------------------------------------------------
Write-Host ""
Write-Host "  ${e}[1;97mPreparacao do Sistema${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"

$actions = @()

# Pre-verificacao: estado do servico Defender
$defSvc = Get-Service -Name WinDefend -ErrorAction SilentlyContinue
$defRunning = $defSvc -and ($defSvc.Status -eq 'Running')

#-- Perguntar cada operacao individualmente -----------------------------------
if (Ask-YesNo "Desativar Tamper Protection?") {
    $actions += @{ name = "Tamper Protection"; action = "tamper" }
}

if ($defRunning -and (Ask-YesNo "Desativar Microsoft Defender?")) {
    $actions += @{ name = "Microsoft Defender"; action = "defender" }
}

if (Ask-YesNo "Desativar Firewall + limpar regras?") {
    $actions += @{ name = "Firewall"; action = "firewall" }
}

if (Ask-YesNo "Desativar BitLocker?") {
    $actions += @{ name = "BitLocker"; action = "bitlocker" }
}

if (Ask-YesNo "Desativar Secure Boot? (requer BIOS)") {
    $actions += @{ name = "Secure Boot"; action = "secureboot" }
}

if (Ask-YesNo "Instalar 7-Zip?") {
    $actions += @{ name = "7-Zip"; action = "7zip" }
}

if (Ask-YesNo "Ativar Windows?") {
    $actions += @{ name = "Windows Activation"; action = "activation" }
}

Write-Host ""

if ($actions.Count -eq 0) {
    Write-Host "  ${e}[38;2;148;163;184m(nenhuma acao selecionada)${e}[0m"
    Write-Host ""
    Read-Host "  Pressione ENTER para voltar"
    return
}

#-- EXECUTAR -------------------------------------------------------------------
Write-Host "  ${e}[38;2;100;149;237m>> Executando...${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

$completed = @()
$failed = @()

foreach ($action in $actions) {
    Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  $($action.name)..." -NoNewline

    try {
        switch ($action.action) {
            "tamper" {
                if (-not $defRunning) {
                    Write-Host "  ${e}[38;2;250;204;21m[JA FEITO]${e}[0m"
                    $completed += $action.name
                } else {
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
                    $completed += $action.name
                }
            }

            "defender" {
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
                $completed += $action.name
            }

            "firewall" {
                Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False -ErrorAction Stop
                $rules = Get-NetFirewallRule -ErrorAction SilentlyContinue
                $count = if ($rules) { $rules.Count } else { 0 }
                if ($count -gt 0) {
                    Remove-NetFirewallRule -All -ErrorAction SilentlyContinue
                }
                Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
                $completed += $action.name
            }

            "bitlocker" {
                $bl = Get-BitLockerVolume -MountPoint C: -ErrorAction SilentlyContinue
                if ($bl -and $bl.ProtectionStatus -eq "On") {
                    Disable-BitLocker -MountPoint C: -ErrorAction Stop | Out-Null
                    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
                    $completed += $action.name
                } else {
                    Write-Host "  ${e}[38;2;250;204;21m[JA FEITO]${e}[0m"
                    $completed += $action.name
                }
            }

            "secureboot" {
                Write-Host "  ${e}[38;2;250;204;21m[MANUAL]${e}[0m"
                Write-Host ""
                Write-Host "  ${e}[38;2;148;163;184mSecure Boot requer acesso BIOS:${e}[0m"
                Write-Host "  ${e}[38;2;148;163;184m1. Reinicie o PC${e}[0m"
                Write-Host "  ${e}[38;2;148;163;184m2. Pressione DEL/F2/F10 durante boot${e}[0m"
                Write-Host "  ${e}[38;2;148;163;184m3. Security > Secure Boot > Disabled${e}[0m"
                Write-Host "  ${e}[38;2;148;163;184m4. Save & Exit${e}[0m"
                Write-Host ""
                $completed += $action.name
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
                    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
                    $completed += $action.name
                } else {
                    Write-Host "  ${e}[38;2;250;204;21m[JA INSTALADO]${e}[0m"
                    $completed += $action.name
                }
            }

            "activation" {
                Write-Host ""
                irm https://get.activated.win | iex
                $completed += $action.name
            }
        }
    } catch {
        Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
        Write-Host "  ${e}[38;2;148;163;184m    $_${e}[0m"
        $failed += $action.name
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
    Write-Host "  ${e}[38;2;148;163;184mDica: Tente novamente em 'Opcoes Manuais' (Menu 4)${e}[0m"
}

Write-Host ""
Write-Host "  ${e}[38;2;148;163;184m  Recomenda-se reiniciar o PC.${e}[0m"
Write-Host ""
Read-Host "  Pressione ENTER para voltar"
