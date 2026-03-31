# M-Auto Online - Remote Installer Launcher
# Usage: irm https://m-auto.online/scripts/m-auto.ps1 | iex

$BASE_URL = "https://m-auto.online/scripts"
$VERSION  = "1.0"
$e = [char]27

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

#-- Menu: Preparacao -------------------------------------------------------
function Show-Prep {
    while ($true) {
        Write-Header
        Write-Title "Preparacao"
        Write-Opt 1  "Basic"   "Defender OFF + Firewall OFF + 7-Zip + Activar Windows"
        Write-Host ""
        Write-Opt 0  "<- Voltar"
        Write-Host ""
        switch (Read-Key) {
            "1" { Run-Sub "prep/basic" }
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
        Write-Opt 1  "Instalar 7-Zip"                  "Descompressao de arquivos"
        Write-Opt 2  "Instalar DeskIn"                  "Acesso remoto para assistencia"
        Write-Opt 3  "Instalar Free Download Manager"
        Write-Opt 4  "DControl - gerir Windows Defender"
        Write-Opt 5  "Criar ponto de restauro do sistema"
        Write-Opt 6  "Activar Windows"
        Write-Host ""
        Write-Opt 0  "<- Voltar"
        Write-Host ""
        switch (Read-Key) {
            "1" { Run-Sub "tools/install_7zip" }
            "2" { Run-Sub "tools/install_deskin" }
            "3" { Run-Sub "tools/install_fdm" }
            "4" { Run-Sub "tools/dcontrol" }
            "5" { Run-Sub "tools/restore_point" }
            "6" { Write-Header; Write-Info "A lancar activador..."; irm https://get.activated.win | iex }
            "0" { return }
            default { Write-Warn "Opcao invalida." ; Start-Sleep -Milliseconds 600 }
        }
    }
}

#-- Menu: System -----------------------------------------------------------
function Show-System {
    while ($true) {
        Write-Header
        Write-Title "Diagnostico & Sistema"
        Write-Opt 1  "Info do sistema"                  "Windows / Hardware / Seguranca"
        Write-Opt 2  "Teste de Internet"                "Ping + Speedtest"
        Write-Opt 3  "Limpar ficheiros temporarios"
        Write-Opt 4  "Desactivar actualizacoes"
        Write-Opt 5  "Alta Performance"
        Write-Opt 6  "Alterar DNS Cloudflare"          "1.1.1.1 / 1.0.0.1"
        Write-Opt 7  "Tweaks & Otimizacoes"             "Reserved Storage / CompactOS / WinSxS..."
        Write-Host ""
        Write-Opt 0  "<- Voltar"
        Write-Host ""
        switch (Read-Key) {
            "1" { Run-Sub "system/sysinfo" }
            "2" { Run-Sub "system/netcheck" }
            "3" { Run-Sub "system/cleanup" }
            "4" { Run-Sub "system/disable_updates" }
            "5" { Run-Sub "system/power_plan" }
            "6" { Run-Sub "system/dns_cloudflare" }
            "7" { Show-Tweaks }
            "0" { return }
            default { Write-Warn "Opcao invalida." ; Start-Sleep -Milliseconds 600 }
        }
    }
}

#-- Menu: Tweaks (dentro de System) -----------------------------------------
function Show-Tweaks {
    while ($true) {
        Write-Header
        Write-Title "Tweaks & Otimizacoes"
        Write-Opt 1  "Reserved Storage OFF"       "Liberta alguns GB"
        Write-Opt 2  "CompactOS"                  "Comprimir ficheiros do SO"
        Write-Opt 3  "WinSxS Cleanup + ResetBase" "Limpeza profunda (5-15 min)"
        Write-Opt 4  "Hibernacao OFF"             "Desativa hibernacao"
        Write-Opt 5  "DriverStoreExplorer"        "Gerir drivers do sistema"
        Write-Host ""
        Write-Opt 0  "<- Voltar"
        Write-Host ""
        switch (Read-Key) {
            "1" { Run-Sub "tweaks/reserved_storage" }
            "2" { Run-Sub "tweaks/compactos" }
            "3" { Run-Sub "tweaks/winsxs_cleanup" }
            "4" { Run-Sub "tweaks/hibernation_off" }
            "5" { Run-Sub "tweaks/driverstoreexplorer" }
            "0" { return }
            default { Write-Warn "Opcao invalida." ; Start-Sleep -Milliseconds 600 }
        }
    }
}

#-- Main -------------------------------------------------------------------
Set-Console
while ($true) {
    Write-Header
    Write-Title "Menu Principal"
    Write-Opt 1  "Preparacao"                 "Basic"
    Write-Opt 2  "Clientes"                   "Tesla..."
    Write-Opt 3  "Software de Diagnostico"    "Mercedes / VAG / BMW / PSA / Renault..."
    Write-Opt 4  "Utilitarios & Ferramentas"  "7-Zip / DeskIn / FDM / DControl..."
    Write-Opt 5  "Diagnostico & Sistema"      "Info / Rede / Limpeza / Tweaks..."
    Write-Host ""
    Write-Opt 0  "Sair"
    Write-Host ""
    switch (Read-Key "Escolha uma opcao") {
        "1" { Show-Prep }
        "2" { Show-Clientes }
        "3" { Show-Software }
        "4" { Show-Tools }
        "5" { Show-System }
        "0" { Write-Host ""; exit }
        default { Write-Warn "Opcao invalida." ; Start-Sleep -Milliseconds 600 }
    }
}
