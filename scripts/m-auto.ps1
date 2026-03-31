# ============================================================
#  M-Auto Online — Remote Installer Launcher
#  Usage: irm https://m-auto.online/scripts/main.ps1 | iex
# ============================================================

#region ── Config ──────────────────────────────────────────
$BASE_URL  = "https://m-auto.online/scripts"
$VERSION   = "1.0"
$BRAND     = "M-Auto Online"
#endregion

#region ── Auto-elevate to Admin ──────────────────────────
if (-not ([Security.Principal.WindowsPrincipal]
          [Security.Principal.WindowsIdentity]::GetCurrent()
         ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "`n  A reiniciar como Administrador..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList `
        "-NoProfile -ExecutionPolicy Bypass -Command `"irm $BASE_URL/main.ps1 | iex`"" `
        -Verb RunAs
    exit
}
#endregion

#region ── UI Helpers ──────────────────────────────────────
$ESC = [char]27

function Set-Console {
    $host.UI.RawUI.WindowTitle = "$BRAND Installer v$VERSION"
    try { $host.UI.RawUI.BufferSize  = New-Object System.Management.Automation.Host.Size(100, 3000) } catch {}
    try { $host.UI.RawUI.WindowSize  = New-Object System.Management.Automation.Host.Size(80, 35)   } catch {}
}

function Write-Header {
    Clear-Host
    Write-Host ""
    Write-Host "  $ESC[38;2;29;155;255m╔══════════════════════════════════════════════════════╗$ESC[0m"
    Write-Host "  $ESC[38;2;29;155;255m║$ESC[0m  $ESC[1;97mM-Auto Online$ESC[0m  $ESC[38;2;100;149;237m·  Remote Installer  ·  v$VERSION$ESC[0m           $ESC[38;2;29;155;255m║$ESC[0m"
    Write-Host "  $ESC[38;2;29;155;255m╚══════════════════════════════════════════════════════╝$ESC[0m"
    Write-Host ""
}

function Write-MenuTitle($title) {
    Write-Host "  $ESC[38;2;100;149;237m▸  $ESC[1;97m$title$ESC[0m"
    Write-Host "  $ESC[38;2;50;60;80m" + ("─" * 54) + "$ESC[0m"
    Write-Host ""
}

function Write-Option($num, $label, $sub = "") {
    $numStr  = "  $ESC[38;2;29;155;255m[$num]$ESC[0m"
    $subStr  = if ($sub) { "  $ESC[38;2;100;120;160m$sub$ESC[0m" } else { "" }
    Write-Host "$numStr  $ESC[97m$label$ESC[0m$subStr"
}

function Write-Separator { Write-Host "" }

function Write-Success($msg) { Write-Host "  $ESC[38;2;34;197;94m✔  $msg$ESC[0m" }
function Write-Warn($msg)    { Write-Host "  $ESC[38;2;250;204;21m⚠  $msg$ESC[0m" }
function Write-Err($msg)     { Write-Host "  $ESC[38;2;239;68;68m✖  $msg$ESC[0m" }
function Write-Info($msg)    { Write-Host "  $ESC[38;2;148;163;184m·  $msg$ESC[0m" }

function Read-Choice($prompt = "Opção") {
    Write-Host ""
    Write-Host -NoNewline "  $ESC[38;2;29;155;255m›$ESC[0m  $prompt: "
    return ($Host.UI.ReadLine()).Trim()
}

function Invoke-SubScript($name) {
    Write-Header
    Write-Info "A carregar $name..."
    try {
        $script = (irm "$BASE_URL/$name.ps1")
        Invoke-Expression $script
    } catch {
        Write-Err "Não foi possível carregar: $name.ps1"
        Write-Info $_.Exception.Message
        pause
    }
}

function Invoke-Pause {
    Write-Host ""
    Write-Host -NoNewline "  $ESC[38;2;100;120;160mPressione qualquer tecla para continuar...$ESC[0m"
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
#endregion

#region ── Sub-menus ───────────────────────────────────────
function Show-MenuSoftware {
    while ($true) {
        Write-Header
        Write-MenuTitle "Software de Diagnóstico"
        Write-Option "1"  "Mercedes Full Pack 2026"    "Xentry + WIS + EPC + Vediamo"
        Write-Option "2"  "ODIS Service (VAG)"         "VW · Audi · Seat · Skoda"
        Write-Option "3"  "ODIS Engineering (VAG)"
        Write-Option "4"  "BMW ISTA+"
        Write-Option "5"  "BMW ISTA-P"
        Write-Option "6"  "PSA Diagbox"
        Write-Option "7"  "Renault CAN Clip"
        Write-Option "8"  "Toyota Techstream"
        Write-Option "9"  "MultiecuScan / AlfaOBD"     "Fiat · Alfa Romeo · Lancia · Jeep"
        Write-Separator
        Write-Option "0"  "← Voltar"
        Write-Separator

        switch (Read-Choice) {
            "1" { Invoke-SubScript "install/merc_full_pack" }
            "2" { Invoke-SubScript "install/vag_odis_service" }
            "3" { Invoke-SubScript "install/vag_odis_eng" }
            "4" { Invoke-SubScript "install/bmw_ista_plus" }
            "5" { Invoke-SubScript "install/bmw_ista_p" }
            "6" { Invoke-SubScript "install/psa_diagbox" }
            "7" { Invoke-SubScript "install/renault_clip" }
            "8" { Invoke-SubScript "install/toyota_techstream" }
            "9" { Invoke-SubScript "install/fiat_multiecuscan" }
            "0" { return }
            default { Write-Warn "Opção inválida." ; Start-Sleep -Milliseconds 700 }
        }
    }
}

function Show-MenuTools {
    while ($true) {
        Write-Header
        Write-MenuTitle "Utilitários & Ferramentas"
        Write-Option "1"  "Instalar 7-Zip"             "Descompressão de arquivos"
        Write-Option "2"  "Instalar DeskIn"             "Acesso remoto para assistência"
        Write-Option "3"  "Instalar Free Download Manager"
        Write-Option "4"  "DControl — gerir Windows Defender"
        Write-Option "5"  "Criar ponto de restauro do sistema"
        Write-Option "6"  "Activar Windows (get.activated.win)"
        Write-Separator
        Write-Option "0"  "← Voltar"
        Write-Separator

        switch (Read-Choice) {
            "1" { Invoke-SubScript "tools/install_7zip" }
            "2" { Invoke-SubScript "tools/install_deskin" }
            "3" { Invoke-SubScript "tools/install_fdm" }
            "4" { Invoke-SubScript "tools/dcontrol" }
            "5" { Invoke-SubScript "tools/restore_point" }
            "6" {
                Write-Header
                Write-Info "A lançar activador Windows..."
                irm https://get.activated.win | iex
            }
            "0" { return }
            default { Write-Warn "Opção inválida." ; Start-Sleep -Milliseconds 700 }
        }
    }
}

function Show-MenuSystem {
    while ($true) {
        Write-Header
        Write-MenuTitle "Diagnóstico & Sistema"
        Write-Option "1"  "Info do sistema"             "OS · CPU · RAM · Disco"
        Write-Option "2"  "Verificar ligação à internet"
        Write-Option "3"  "Limpar ficheiros temporários"
        Write-Option "4"  "Desactivar actualizações automáticas"
        Write-Option "5"  "Configurar power plan para Alta Performance"
        Write-Separator
        Write-Option "0"  "← Voltar"
        Write-Separator

        switch (Read-Choice) {
            "1" { Invoke-SubScript "system/sysinfo" }
            "2" { Invoke-SubScript "system/netcheck" }
            "3" { Invoke-SubScript "system/cleanup" }
            "4" { Invoke-SubScript "system/disable_updates" }
            "5" { Invoke-SubScript "system/power_plan" }
            "0" { return }
            default { Write-Warn "Opção inválida." ; Start-Sleep -Milliseconds 700 }
        }
    }
}
#endregion

#region ── Main Menu ───────────────────────────────────────
Set-Console

while ($true) {
    Write-Header
    Write-MenuTitle "Menu Principal"
    Write-Option "1"  "Software de Diagnóstico"     "Mercedes · VAG · BMW · PSA · Renault..."
    Write-Option "2"  "Utilitários & Ferramentas"   "7-Zip · DeskIn · FDM · DControl..."
    Write-Option "3"  "Diagnóstico & Sistema"       "Info · Limpeza · Performance..."
    Write-Separator
    Write-Option "0"  "Sair"
    Write-Separator

    switch (Read-Choice "Escolha uma opção") {
        "1" { Show-MenuSoftware }
        "2" { Show-MenuTools }
        "3" { Show-MenuSystem }
        "0" { Write-Host "" ; exit }
        default { Write-Warn "Opção inválida." ; Start-Sleep -Milliseconds 700 }
    }
}
#endregion
