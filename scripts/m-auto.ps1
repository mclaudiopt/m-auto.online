# M-Auto Online - Remote Installer Launcher
# Usage: irm https://m-auto.online/scripts/m-auto.ps1 | iex

$VERSION  = "1.1 [2026-04-02 15:58:43]"
$BASE_URL = "https://m-auto.online/scripts"
$e = [char]27

#-- Clear Cache ---------------------------------------------------------------
$null = $PSVersionTable
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

#-- Auto-elevate -----------------------------------------------------------
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm $BASE_URL/m-auto.ps1 | iex`"" -Verb RunAs
    exit
}

#-- UI helpers -------------------------------------------------------------
function Set-Console {
    $host.UI.RawUI.WindowTitle = "M-Auto Online  v$VERSION"
    try { $host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(80,35) } catch {}
}

function Write-Header {
    Clear-Host
    Write-Host ""
    Write-Host "  ${e}[38;2;29;155;255m+------------------------------------------------------+${e}[0m"
    Write-Host "  ${e}[38;2;29;155;255m|${e}[0m  ${e}[1;97mM-Auto Online${e}[0m  ${e}[38;2;100;149;237m|  Remote Installer  |  v$VERSION${e}[0m"
    Write-Host "  ${e}[38;2;29;155;255m+------------------------------------------------------+${e}[0m"
    Write-Host ""
}

function Write-Title($t) {
    Write-Host "  ${e}[38;2;100;149;237m>>  ${e}[1;97m$t${e}[0m"
    Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
    Write-Host ""
}

function Write-Opt($n, $label, $sub = "") {
    $s = if ($sub) { "  ${e}[38;2;80;100;140m$sub${e}[0m" } else { "" }
    Write-Host "  ${e}[38;2;29;155;255m[$n]${e}[0m  ${e}[97m$label${e}[0m$s"
}

function Write-OK($m)   { Write-Host "  ${e}[38;2;34;197;94m[OK]  $m${e}[0m" }
function Write-Warn($m) { Write-Host "  ${e}[38;2;250;204;21m[!]   $m${e}[0m" }
function Write-Err($m)  { Write-Host "  ${e}[38;2;239;68;68m[X]   $m${e}[0m" }
function Write-Info($m) { Write-Host "  ${e}[38;2;148;163;184m[.]   $m${e}[0m" }

function Read-Key($prompt = "Opcao") {
    Write-Host ""
    Write-Host -NoNewline "  ${e}[38;2;29;155;255m>${e}[0m  ${prompt}: "
    return ($Host.UI.ReadLine()).Trim()
}

function Wait-Key {
    Write-Host ""
    Write-Host -NoNewline "  ${e}[38;2;80;100;140mPressione ENTER para continuar...${e}[0m"
    $null = $Host.UI.ReadLine()
}

function Run-Sub($name) {
    Write-Header
    Write-Info "A carregar $name..."
    try {
        $s = (irm "$BASE_URL/$name.ps1" -UseBasicParsing)
        Invoke-Expression $s
    } catch {
        Write-Err "Nao foi possivel carregar: $name.ps1"
        Write-Info $_.Exception.Message
        Wait-Key
    }
}

#-- Menu: Opcoes Manuais (Menu 99 Backup) -----------------------------------
function Show-Backup {
    while ($true) {
        Write-Header
        Write-Title "Opcoes Manuais - Preparacao & Diagnostico"
        Write-Host ""
        Write-Host "  ${e}[38;2;100;149;237m[Preparacao]${e}[0m"
        Write-Opt 1  "Tamper Protection OFF"
        Write-Opt 2  "Microsoft Defender OFF"
        Write-Opt 3  "Firewall OFF + limpar regras"
        Write-Opt 4  "BitLocker OFF"
        Write-Opt 5  "Secure Boot OFF"
        Write-Opt 6  "Instalar 7-Zip"
        Write-Opt 7  "Activar Windows"
        Write-Host ""
        Write-Host "  ${e}[38;2;100;149;237m[Diagnostico & Ferramentas]${e}[0m"
        Write-Opt 8  "Info do Sistema"
        Write-Opt 9  "Teste de Internet"
        Write-Opt 10 "Limpar ficheiros temporarios"
        Write-Opt 11 "Desactivar actualizacoes"
        Write-Opt 12 "Alta Performance"
        Write-Opt 13 "Alterar DNS Cloudflare"
        Write-Opt 14 "Reserved Storage OFF"
        Write-Opt 15 "CompactOS"
        Write-Opt 16 "WinSxS Cleanup + ResetBase"
        Write-Opt 17 "Hibernacao OFF"
        Write-Opt 18 "DriverStoreExplorer"
        Write-Host ""
        Write-Host "  ${e}[38;2;100;149;237m[Customizacoes]${e}[0m"
        Write-Opt 19 "Remover Search Taskbar"
        Write-Opt 20 "Remover News Taskbar"
        Write-Opt 21 "Remover Cortana"
        Write-Opt 22 "Remover OneDrive Visual"
        Write-Host ""
        Write-Opt 0  "<- Voltar"
        Write-Host ""
        switch (Read-Key) {
            "1"  { Run-Sub "prep/tamper_off" }
            "2"  { Run-Sub "prep/defender_off" }
            "3"  { Run-Sub "prep/firewall_off" }
            "4"  { Run-Sub "prep/bitlocker_off" }
            "5"  { Run-Sub "prep/secureboot_off" }
            "6"  { Run-Sub "tools/install_7zip" }
            "7"  { Write-Header; Write-Info "A lancar activador..."; irm https://get.activated.win | iex }
            "8"  { Run-Sub "system/sysinfo" }
            "9"  { Run-Sub "system/netcheck" }
            "10" { Run-Sub "system/cleanup" }
            "11" { Run-Sub "system/disable_updates" }
            "12" { Run-Sub "system/power_plan" }
            "13" { Run-Sub "system/dns_cloudflare" }
            "14" { Run-Sub "tweaks/reserved_storage" }
            "15" { Run-Sub "tweaks/compactos" }
            "16" { Run-Sub "tweaks/winsxs_cleanup" }
            "17" { Run-Sub "tweaks/hibernation_off" }
            "18" { Run-Sub "tweaks/driverstoreexplorer" }
            "19" { Run-Sub "utils/remove_search_taskbar" }
            "20" { Run-Sub "utils/remove_news_taskbar" }
            "21" { Run-Sub "utils/remove_cortana" }
            "22" { Run-Sub "utils/remove_onedrive_visual" }
            "0" { return }
            default { Write-Warn "Opcao invalida." ; Start-Sleep -Milliseconds 600 }
        }
    }
}

#-- Menu: Clientes ---------------------------------------------------------
function Show-Clientes {
    while ($true) {
        Write-Header
        Write-Title "Clientes"
        Write-Opt 1  "Tesla"   "(em preparacao - aguarda links)"
        Write-Host ""
        Write-Opt 0  "<- Voltar"
        Write-Host ""
        switch (Read-Key) {
            "1" { Run-Sub "clients/tesla" }
            "0" { return }
            default { Write-Warn "Opcao invalida." ; Start-Sleep -Milliseconds 600 }
        }
    }
}

#-- Menu: Software ---------------------------------------------------------
function Show-Software {
    while ($true) {
        Write-Header
        Write-Title "Software de Diagnostico"
        Write-Opt 1  "Mercedes Full Pack 2026"     "Xentry + WIS + EPC + Vediamo"
        Write-Opt 2  "ODIS Service (VAG)"          "VW / Audi / Seat / Skoda"
        Write-Opt 3  "ODIS Engineering (VAG)"
        Write-Opt 4  "BMW ISTA+"
        Write-Opt 5  "BMW ISTA-P"
        Write-Opt 6  "PSA Diagbox"
        Write-Opt 7  "Renault CAN Clip"
        Write-Opt 8  "Toyota Techstream"
        Write-Opt 9  "MultiecuScan / AlfaOBD"      "Fiat / Alfa Romeo / Lancia / Jeep"
        Write-Host ""
        Write-Opt 0  "<- Voltar"
        Write-Host ""
        switch (Read-Key) {
            "1" { Run-Sub "install/merc_full_pack" }
            "2" { Run-Sub "install/vag_odis_service" }
            "3" { Run-Sub "install/vag_odis_eng" }
            "4" { Run-Sub "install/bmw_ista_plus" }
            "5" { Run-Sub "install/bmw_ista_p" }
            "6" { Run-Sub "install/psa_diagbox" }
            "7" { Run-Sub "install/renault_clip" }
            "8" { Run-Sub "install/toyota_techstream" }
            "9" { Run-Sub "install/fiat_multiecuscan" }
            "0" { return }
            default { Write-Warn "Opcao invalida." ; Start-Sleep -Milliseconds 600 }
        }
    }
}

#-- Menu: Tools ------------------------------------------------------------
function Show-Tools {
    while ($true) {
        Write-Header
        Write-Title "Utilitarios & Ferramentas"
        Write-Host "  ${e}[38;2;100;149;237m[Instalar]${e}[0m"
        Write-Opt 1  "Instalar 7-Zip"                  "Descompressao de arquivos"
        Write-Opt 2  "Instalar DeskIn"                  "Acesso remoto para assistencia"
        Write-Opt 3  "Instalar MSMQ Queuing Services"   "Message Queuing"
        Write-Host ""
        Write-Host "  ${e}[38;2;100;149;237m[Sistema]${e}[0m"
        Write-Opt 4  "DControl - gerir Windows Defender"
        Write-Opt 5  "Criar ponto de restauro do sistema"
        Write-Opt 6  "Configurar Home Page (m-auto.online)"
        Write-Opt 7  "Listar interfaces J2534"          "PassThru instalados"
        Write-Opt 8  "Speedtest"                        "Teste de velocidade"
        Write-Opt 9  "Activar Windows"
        Write-Host ""
        Write-Host "  ${e}[38;2;100;149;237m[Customizacao]${e}[0m"
        Write-Opt 10 "Remover Search Taskbar"           "Ocultar search box"
        Write-Opt 11 "Remover News Taskbar"             "Ocultar news and interests"
        Write-Opt 12 "Remover Cortana"                  "Desabilitar Cortana"
        Write-Opt 13 "Remover OneDrive Visual"          "Ocultar do File Explorer"
        Write-Opt 14 "Dark Mode"                        "Ativar tema escuro"
        Write-Opt 15 "Mostrar Extensoes"                "Mostrar extensoes de ficheiros"
        Write-Opt 16 "Ocultar Desktop Icons"            "This PC / Recycle Bin"
        Write-Host ""
        Write-Opt 0  "<- Voltar"
        Write-Host ""
        switch (Read-Key) {
            "1"  { Run-Sub "tools/install_7zip" }
            "2"  { Run-Sub "tools/install_deskin" }
            "3"  { Run-Sub "tools/install_msmq" }
            "4"  { Run-Sub "tools/dcontrol" }
            "5"  { Run-Sub "tools/restore_point" }
            "6"  { Run-Sub "tweaks/set_homepage" }
            "7"  { Run-Sub "tools/list_j2534" }
            "8"  { Run-Sub "system/speedtest" }
            "9"  { Write-Header; Write-Info "A lancar activador..."; irm https://get.activated.win | iex }
            "10" { Run-Sub "utils/remove_search_taskbar" }
            "11" { Run-Sub "utils/remove_news_taskbar" }
            "12" { Run-Sub "utils/remove_cortana" }
            "13" { Run-Sub "utils/remove_onedrive_visual" }
            "14" { Run-Sub "utils/enable_dark_mode" }
            "15" { Run-Sub "utils/show_file_extensions" }
            "16" { Run-Sub "utils/hide_desktop_icons" }
            "0"  { return }
            default { Write-Warn "Opcao invalida." ; Start-Sleep -Milliseconds 600 }
        }
    }
}

#-- Menu: SOS --------------------------------------------------------------
function Show-SOS {
    while ($true) {
        Write-Header
        Write-Title "SOS - Recuperacao de Emergencia"
        Write-Opt 1  "Reparar ficheiros de sistema"    "sfc /scannow"
        Write-Opt 2  "Reparar Windows"                 "DISM RestoreHealth"
        Write-Opt 3  "Reset TCP/IP e DNS"              "Winsock + flush + renew"
        Write-Opt 4  "Reparar Windows Update"          "Limpar cache + reiniciar servicos"
        Write-Opt 5  "Reiniciar para BIOS / UEFI"      "shutdown /r /fw /t 0"
        Write-Opt 6  "Listar processos suspeitos"      "Top 15 + scan por nome"
        Write-Host ""
        Write-Opt 0  "<- Voltar"
        Write-Host ""
        switch (Read-Key) {
            "1" { Run-Sub "sos/sfc_scan" }
            "2" { Run-Sub "sos/dism_repair" }
            "3" { Run-Sub "sos/reset_network" }
            "4" { Run-Sub "sos/fix_windows_update" }
            "5" { Run-Sub "sos/reboot_bios" }
            "6" { Run-Sub "sos/suspicious_processes" }
            "0" { return }
            default { Write-Warn "Opcao invalida." ; Start-Sleep -Milliseconds 600 }
        }
    }
}

#-- Start Engine (tudo integrado) ----------------------------------------
function Show-System {
    Run-Sub "system/start_engine"
}


#-- Main -------------------------------------------------------------------
Set-Console
while ($true) {
    Write-Header
    Write-Title "Menu Principal"
    Write-Opt 1  "Start Engine"                "Diagnostico + Preparacao + Ferramentas"
    Write-Opt 2  "Cliente"                    "Tesla..."
    Write-Opt 3  "Tools"                      "Utilitarios & Ferramentas"
    Write-Opt 4  "SOS"                        "Recuperacao de emergencia"
    Write-Host ""
    Write-Opt 0  "Sair"
    Write-Host ""
    switch (Read-Key "Escolha uma opcao") {
        "1" { Show-System }
        "2" { Show-Clientes }
        "3" { Show-Tools }
        "4" { Show-SOS }
        "0" { Write-Host ""; exit }
        default { Write-Warn "Opcao invalida." ; Start-Sleep -Milliseconds 600 }
    }
}















