# install/install_dt.ps1 - DT 04-26 Installer
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null
$e = [char]27

$TEMP_DIR = "C:\M-auto\Temp"
$DT_ARCHIVE = "$TEMP_DIR\DT 04-26.7z"
$DT_EXTRACT = "$TEMP_DIR\DT_Extract"
$PASSWORD = "M-auto"

function Write-Header {
    Clear-Host
    Write-Host ""
    Write-Host "  ${e}[38;2;29;155;255m+------------------------------------------------------+${e}[0m"
    Write-Host "  ${e}[38;2;29;155;255m|${e}[0m  ${e}[1;97mDT 04-26${e}[0m  ${e}[38;2;100;149;237mInstaller${e}[0m"
    Write-Host "  ${e}[38;2;29;155;255m+------------------------------------------------------+${e}[0m"
    Write-Host ""
}

function Write-OK($msg)   { Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m  $msg" }
function Write-Err($msg)  { Write-Host "  ${e}[38;2;239;68;68m[X]${e}[0m   $msg" }
function Write-Info($msg) { Write-Host "  ${e}[38;2;148;163;184m[.]${e}[0m   $msg" }

Write-Header

# Verificar se o arquivo existe
if (-not (Test-Path $DT_ARCHIVE)) {
    Write-Err "Ficheiro nao encontrado: $DT_ARCHIVE"
    Write-Info "Execute primeiro o download do DT 04-26.7z"
    Write-Host ""
    Read-Host "  Pressione ENTER para voltar"
    return
}

# Verificar 7-Zip
$7z = "C:\Program Files\7-Zip\7z.exe"
if (-not (Test-Path $7z)) {
    Write-Err "7-Zip nao encontrado em: $7z"
    Write-Info "Instale o 7-Zip primeiro"
    Write-Host ""
    Read-Host "  Pressione ENTER para voltar"
    return
}

# Criar pasta de extração
if (Test-Path $DT_EXTRACT) {
    Write-Info "A limpar pasta anterior..."
    Remove-Item $DT_EXTRACT -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Path $DT_EXTRACT -Force | Out-Null

# Descomprimir com password
Write-Info "A descomprimir DT 04-26.7z..."
try {
    $proc = Start-Process -FilePath $7z -ArgumentList "x", "`"$DT_ARCHIVE`"", "-o`"$DT_EXTRACT`"", "-p$PASSWORD", "-y" -NoNewWindow -Wait -PassThru
    if ($proc.ExitCode -ne 0) {
        throw "7-Zip retornou codigo: $($proc.ExitCode)"
    }
    Write-OK "Descompressao concluida"
} catch {
    Write-Err "Erro ao descomprimir: $_"
    Write-Host ""
    Read-Host "  Pressione ENTER para voltar"
    return
}

# Procurar start.exe
Write-Info "A procurar start.exe..."
$startExe = Get-ChildItem -Path $DT_EXTRACT -Filter "start.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not $startExe) {
    Write-Err "start.exe nao encontrado na pasta extraida"
    Write-Host ""
    Read-Host "  Pressione ENTER para voltar"
    return
}

Write-OK "Encontrado: $($startExe.FullName)"
Write-Host ""

# Executar start.exe
Write-Info "A executar start.exe..."
try {
    Start-Process -FilePath $startExe.FullName -Wait
    Write-OK "Instalacao concluida"
} catch {
    Write-Err "Erro ao executar: $_"
}

# Limpeza
Write-Host ""
Write-Info "A limpar ficheiros temporarios..."
try {
    if (Test-Path $DT_ARCHIVE) {
        Remove-Item $DT_ARCHIVE -Force
        Write-OK "Removido: DT 04-26.7z"
    }
    if (Test-Path $DT_EXTRACT) {
        Remove-Item $DT_EXTRACT -Recurse -Force
        Write-OK "Removida pasta temporaria"
    }
} catch {
    Write-Err "Erro na limpeza: $_"
}

Write-Host ""
Write-OK "Processo concluido"
Write-Host ""
Read-Host "  Pressione ENTER para voltar"
