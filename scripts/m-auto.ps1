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
        Write-Opt 1  "Info do sistema"                  "OS / CPU / RAM / Disco"
        Write-Opt 2  "Verificar ligacao a internet"
        Write-Opt 3  "Limpar ficheiros temporarios"
        Write-Opt 4  "Desactivar actualizacoes automaticas"
        Write-Opt 5  "Configurar Alta Performance"
        Write-Host ""
        Write-Opt 0  "<- Voltar"
        Write-Host ""
        switch (Read-Key) {
            "1" { Run-Sub "system/sysinfo" }
            "2" { Run-Sub "system/netcheck" }
            "3" { Run-Sub "system/cleanup" }
            "4" { Run-Sub "system/disable_updates" }
            "5" { Run-Sub "system/power_plan" }
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
    Write-Opt 1  "Software de Diagnostico"    "Mercedes / VAG / BMW / PSA / Renault..."
    Write-Opt 2  "Utilitarios & Ferramentas"  "7-Zip / DeskIn / FDM / DControl..."
    Write-Opt 3  "Diagnostico & Sistema"      "Info / Limpeza / Performance..."
    Write-Host ""
    Write-Opt 0  "Sair"
    Write-Host ""
    switch (Read-Key "Escolha uma opcao") {
        "1" { Show-Software }
        "2" { Show-Tools }
        "3" { Show-System }
        "0" { Write-Host ""; exit }
        default { Write-Warn "Opcao invalida." ; Start-Sleep -Milliseconds 600 }
    }
}
