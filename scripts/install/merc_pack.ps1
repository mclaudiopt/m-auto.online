# install/merc_pack.ps1 - Mercedes Pack Unified Menu
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null
$e = [char]27

#-- Helpers ------------------------------------------------------------------
function Write-Header {
    Clear-Host
    Write-Host ""
    Write-Host "  ${e}[38;2;29;155;255m+------------------------------------------------------+${e}[0m"
    Write-Host "  ${e}[38;2;29;155;255m|${e}[0m  ${e}[1;97mMercedes Pack 2026${e}[0m"
    Write-Host "  ${e}[38;2;29;155;255m+------------------------------------------------------+${e}[0m"
    Write-Host "  ${e}[38;2;148;163;184m  Xentry + WIS + EPC + Vediamo + StarFinder${e}[0m"
    Write-Host ""
}

function Write-OK($msg)   { Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m  $msg" }
function Write-Err($msg)  { Write-Host "  ${e}[38;2;239;68;68m[X]${e}[0m   $msg" }
function Write-Info($msg) { Write-Host "  ${e}[38;2;148;163;184m[.]${e}[0m   $msg" }

#-- Menu loop ----------------------------------------------------------------
while ($true) {
    Write-Header

    Write-Host "  ${e}[38;2;148;163;184mOpcoes:${e}[0m"
    Write-Host ""
    Write-Host "    ${e}[38;2;100;149;237m[1]${e}[0m Download (transferir ficheiros via Internet)"
    Write-Host "    ${e}[38;2;100;149;237m[2]${e}[0m Instalar (descomprimir, atalhos, limpar)"
    Write-Host "    ${e}[38;2;100;149;237m[3]${e}[0m Download + Instalar (fluxo completo)"
    Write-Host "    ${e}[38;2;239;68;68m[0]${e}[0m Voltar"
    Write-Host ""
    $choice = Read-Host "  Opcao"

    switch ($choice) {
        "1" {
            $downloadScript = Join-Path $PSScriptRoot "merc_download.ps1"
            if (Test-Path $downloadScript) {
                & $downloadScript
            } else {
                Write-Err "Script nao encontrado: $downloadScript"
                Start-Sleep -Seconds 2
            }
        }
        "2" {
            $installScript = Join-Path $PSScriptRoot "merc_install.ps1"
            if (Test-Path $installScript) {
                & $installScript
            } else {
                Write-Err "Script nao encontrado: $installScript"
                Start-Sleep -Seconds 2
            }
        }
        "3" {
            Write-Info "A iniciar download..."
            $downloadScript = Join-Path $PSScriptRoot "merc_download.ps1"
            if (Test-Path $downloadScript) {
                & $downloadScript
            }

            Write-Host ""
            Write-Info "A iniciar instalacao..."
            Start-Sleep -Seconds 1

            $installScript = Join-Path $PSScriptRoot "merc_install.ps1"
            if (Test-Path $installScript) {
                & $installScript
            }
        }
        "0" {
            return
        }
        default {
            Write-Err "Opcao invalida"
            Start-Sleep -Seconds 1
        }
    }
}
