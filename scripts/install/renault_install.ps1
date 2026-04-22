# install/renault_install.ps1 - Renault CLIP Install
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null
$e = [char]27

$TEMP_DIR = "C:\M-auto\Temp"
$INSTALL_DIR = "C:\M-auto\Renault"

function Write-Header {
    Clear-Host
    Write-Host ""
    Write-Host "  ${e}[38;2;255;204;0m+------------------------------------------------------+${e}[0m"
    Write-Host "  ${e}[38;2;255;204;0m|${e}[0m  ${e}[1;97mRenault CLIP - Instalacao${e}[0m"
    Write-Host "  ${e}[38;2;255;204;0m+------------------------------------------------------+${e}[0m"
    Write-Host ""
}

function Write-OK($msg)   { Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m  $msg" }
function Write-Err($msg)  { Write-Host "  ${e}[38;2;239;68;68m[X]${e}[0m   $msg" }
function Write-Info($msg) { Write-Host "  ${e}[38;2;148;163;184m[.]${e}[0m   $msg" }

Write-Header

if (-not (Test-Path $TEMP_DIR)) {
    Write-Err "Pasta Temp nao encontrada: $TEMP_DIR"
    Write-Info "Execute primeiro o Download"
    Write-Host ""
    Read-Host "  Pressione ENTER para continuar"
    return
}

$rarFile = Get-ChildItem -Path $TEMP_DIR -Filter "*.rar" | Select-Object -First 1
if (-not $rarFile) {
    Write-Err "Nenhum ficheiro .rar encontrado em $TEMP_DIR"
    Write-Host ""
    Read-Host "  Pressione ENTER para continuar"
    return
}

Write-Info "Ficheiro encontrado: $($rarFile.Name)"
Write-Host ""

if (-not (Test-Path $INSTALL_DIR)) {
    Write-Info "A criar pasta: $INSTALL_DIR"
    New-Item -ItemType Directory -Path $INSTALL_DIR -Force | Out-Null
}

Write-Info "A descomprimir para: $INSTALL_DIR"
Write-Host ""

try {
    $rarPath = $rarFile.FullName
    & "C:\Program Files\WinRAR\WinRAR.exe" x -y "$rarPath" "$INSTALL_DIR\"
    Write-OK "Descompressao concluida"
} catch {
    Write-Err "Erro ao descomprimir"
    Write-Info $_.Exception.Message
    Write-Host ""
    Read-Host "  Pressione ENTER para continuar"
    return
}

Write-Host ""
Write-OK "Instalacao concluida!"
Write-Info "Pasta: $INSTALL_DIR"
Write-Host ""
Read-Host "  Pressione ENTER para continuar"
