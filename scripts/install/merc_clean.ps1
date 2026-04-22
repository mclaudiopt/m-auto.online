# install/merc_clean.ps1 - Mercedes Pack Clean Utility
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null
$e = [char]27

#-- Helpers ------------------------------------------------------------------
function Write-Header {
    Clear-Host
    Write-Host ""
    Write-Host "  ${e}[38;2;29;155;255m+------------------------------------------------------+${e}[0m"
    Write-Host "  ${e}[38;2;29;155;255m|${e}[0m  ${e}[1;97mMercedes Pack${e}[0m  ${e}[38;2;239;68;68mClean${e}[0m"
    Write-Host "  ${e}[38;2;29;155;255m+------------------------------------------------------+${e}[0m"
    Write-Host ""
}

function Write-OK($msg)   { Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m  $msg" }
function Write-Err($msg)  { Write-Host "  ${e}[38;2;239;68;68m[X]${e}[0m   $msg" }
function Write-Warn($msg) { Write-Host "  ${e}[38;2;250;204;21m[!]${e}[0m   $msg" }
function Write-Info($msg) { Write-Host "  ${e}[38;2;148;163;184m[.]${e}[0m   $msg" }

#-- Apagar DTS8.16.exe -------------------------------------------------------
function Remove-DTS816 {
    $dtsPath = "C:\Program Files (x86)\Softing\Diagnostic Tool Set 8\8.16\DTS8.16.exe"

    Write-Info "A verificar DTS8.16.exe..."

    if (-not (Test-Path $dtsPath)) {
        Write-OK "DTS8.16.exe nao existe (ja apagado ou nunca instalado)."
        return $true
    }

    try {
        Write-Info "A apagar $dtsPath..."
        Remove-Item $dtsPath -Force -ErrorAction Stop

        # Confirmar que foi apagado
        Start-Sleep -Milliseconds 500
        if (-not (Test-Path $dtsPath)) {
            Write-OK "DTS8.16.exe apagado com sucesso."
            return $true
        } else {
            Write-Err "Ficheiro ainda existe apos tentativa de remocao."
            return $false
        }
    } catch {
        Write-Err "Falha ao apagar: $_"
        Write-Warn "Pode necessitar de permissoes de administrador."
        return $false
    }
}

#-- Instalar downloads ------------------------------------------------------
function Install-Downloads {
    $installScript = Join-Path $PSScriptRoot "merc_full_pack.ps1"
    if (Test-Path $installScript) {
        & $installScript
    } else {
        Write-Err "Script de instalacao nao encontrado: $installScript"
        Start-Sleep -Seconds 2
    }
}

#-- Menu principal -----------------------------------------------------------
function Show-Menu {
    Write-Header
    Write-Host "  ${e}[38;2;148;163;184mOpcoes:${e}[0m"
    Write-Host ""
    Write-Host "    ${e}[38;2;100;149;237m[1]${e}[0m Instalar downloads (descomprimir, atalhos, limpar)"
    Write-Host "    ${e}[38;2;239;68;68m[2]${e}[0m Apagar DTS8.16.exe"
    Write-Host "    ${e}[38;2;239;68;68m[0]${e}[0m Voltar"
    Write-Host ""
    $choice = Read-Host "  Opcao"
    return $choice
}

#-- Loop principal -----------------------------------------------------------
while ($true) {
    $choice = Show-Menu

    switch ($choice) {
        "1" {
            Install-Downloads
        }
        "2" {
            Write-Header
            Write-Host "  ${e}[38;2;100;149;237m-- Apagar DTS8.16.exe --${e}[0m"
            Write-Host ""

            $result = Remove-DTS816

            Write-Host ""
            Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
            Write-Host ""
            Read-Host "  Pressione ENTER para continuar"
        }
        "0" {
            Write-Info "A voltar..."
            return
        }
        default {
            Write-Err "Opcao invalida."
            Start-Sleep -Seconds 1
        }
    }
}
