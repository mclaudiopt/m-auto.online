# install/renault_clean.ps1 - Renault CLIP Clean Utility
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null
$e = [char]27

#-- Helpers ------------------------------------------------------------------
function Write-Header {
    Clear-Host
    Write-Host ""
    Write-Host "  ${e}[38;2;255;204;0m+------------------------------------------------------+${e}[0m"
    Write-Host "  ${e}[38;2;255;204;0m|${e}[0m  ${e}[1;97mRenault CLIP${e}[0m  ${e}[38;2;239;68;68mClean${e}[0m"
    Write-Host "  ${e}[38;2;255;204;0m+------------------------------------------------------+${e}[0m"
    Write-Host ""
}

function Write-OK($msg)   { Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m  $msg" }
function Write-Err($msg)  { Write-Host "  ${e}[38;2;239;68;68m[X]${e}[0m   $msg" }
function Write-Warn($msg) { Write-Host "  ${e}[38;2;250;204;21m[!]${e}[0m   $msg" }
function Write-Info($msg) { Write-Host "  ${e}[38;2;148;163;184m[.]${e}[0m   $msg" }

#-- Limpar ficheiros temporarios ---------------------------------------------
function Clear-TempFiles {
    $tempDir = "C:\M-auto\Temp"

    Write-Info "A verificar ficheiros temporarios..."

    if (-not (Test-Path $tempDir)) {
        Write-OK "Pasta temporaria nao existe."
        return $true
    }

    try {
        $files = Get-ChildItem -Path $tempDir -File
        if ($files.Count -eq 0) {
            Write-OK "Nenhum ficheiro temporario encontrado."
            return $true
        }

        Write-Host ""
        Write-Host "  ${e}[38;2;148;163;184mFicheiros encontrados:${e}[0m"
        foreach ($f in $files) {
            $sizeMB = [math]::Round($f.Length / 1MB, 1)
            Write-Host "    - $($f.Name) ${e}[38;2;148;163;184m($sizeMB MB)${e}[0m"
        }
        Write-Host ""

        $confirm = Read-Host "  Apagar todos? (S/N)"
        if ($confirm -ne "S" -and $confirm -ne "s") {
            Write-Info "Cancelado."
            return $false
        }

        Write-Info "A apagar ficheiros..."
        Remove-Item "$tempDir\*" -Force -ErrorAction Stop
        Write-OK "Ficheiros temporarios apagados."
        return $true
    } catch {
        Write-Err "Falha ao apagar: $_"
        return $false
    }
}

#-- Menu principal -----------------------------------------------------------
function Show-Menu {
    Write-Header
    Write-Host "  ${e}[38;2;148;163;184mOpcoes:${e}[0m"
    Write-Host ""
    Write-Host "    ${e}[38;2;255;204;0m[1]${e}[0m Limpar ficheiros temporarios"
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
            Write-Header
            Write-Host "  ${e}[38;2;255;204;0m-- Limpar ficheiros temporarios --${e}[0m"
            Write-Host ""

            $result = Clear-TempFiles

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
