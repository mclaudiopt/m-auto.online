# install/renault_clip.ps1 - Renault CLIP Menu
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null
$e = [char]27
$BASE_URL = "https://m-auto.online/scripts"

#-- Helpers ------------------------------------------------------------------
function Write-Header {
    Clear-Host
    Write-Host ""
    Write-Host "  ${e}[38;2;255;204;0m+------------------------------------------------------+${e}[0m"
    Write-Host "  ${e}[38;2;255;204;0m|${e}[0m  ${e}[1;97mRenault CLIP v237${e}[0m"
    Write-Host "  ${e}[38;2;255;204;0m+------------------------------------------------------+${e}[0m"
    Write-Host ""
}

function Write-OK($msg)   { Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m  $msg" }
function Write-Err($msg)  { Write-Host "  ${e}[38;2;239;68;68m[X]${e}[0m   $msg" }
function Write-Info($msg) { Write-Host "  ${e}[38;2;148;163;184m[.]${e}[0m   $msg" }

function Run-Remote($script) {
    try {
        $code = irm "$BASE_URL/$script.ps1" -UseBasicParsing
        Invoke-Expression $code
    } catch {
        Write-Err "Erro ao carregar: $script.ps1"
        Write-Info $_.Exception.Message
        Start-Sleep -Seconds 2
    }
}

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
            Run-Remote "install/renault_download"
        }
        "2" {
            Run-Remote "install/renault_install"
        }
        "3" {
            Write-Info "A iniciar download..."
            Run-Remote "install/renault_download"
            Write-Host ""
            Write-Info "A iniciar instalacao..."
            Start-Sleep -Seconds 1
            Run-Remote "install/renault_install"
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
