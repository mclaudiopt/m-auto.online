# system/speedtest.ps1 - Ookla Speedtest CLI wrapper (clean version)
# Based on asheroto/speedtest, privacy-optimized for m-auto
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
$e = [char]27

$ProgressPreference = 'SilentlyContinue'
$ConfirmPreference = 'None'
$ErrorActionPreference = 'Continue'

Write-Host ""
Write-Host "  ${e}[1;97mOokla Speedtest${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

# ── Get Download Link ────────────────────────────────────────────────────
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A obter link de download..." -NoNewline

try {
    $url = "https://www.speedtest.net/apps/cli"
    $webContent = Invoke-WebRequest -Uri $url -UseBasicParsing -ErrorAction Stop

    if ($webContent.Content -match 'href="(https://install\.speedtest\.net/app/cli/ookla-speedtest-[\d\.]+-win64\.zip)"') {
        $downloadLink = $matches[1]
        Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
    } else {
        Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
        Write-Host "  ${e}[38;2;148;163;184m    Nao foi possivel encontrar o link de download${e}[0m"
        Read-Host "  Pressione ENTER para voltar"
        return
    }
} catch {
    Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
    Write-Host "  ${e}[38;2;148;163;184m    $_${e}[0m"
    Read-Host "  Pressione ENTER para voltar"
    return
}

# ── Download Speedtest ────────────────────────────────────────────────────
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A transferir Speedtest..." -NoNewline

$tempDir = "$env:TEMP\speedtest_m_auto"
$zipPath = "$tempDir\speedtest.zip"
$exePath = "$tempDir\speedtest.exe"

try {
    if (-not (Test-Path $tempDir)) {
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    }

    Invoke-WebRequest -Uri $downloadLink -OutFile $zipPath -UseBasicParsing -ErrorAction Stop
    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
} catch {
    Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
    Write-Host "  ${e}[38;2;148;163;184m    $_${e}[0m"
    Read-Host "  Pressione ENTER para voltar"
    return
}

# ── Extract Zip ──────────────────────────────────────────────────────────
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A extrair..." -NoNewline

try {
    Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force -ErrorAction Stop
    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
} catch {
    Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
    Write-Host "  ${e}[38;2;148;163;184m    $_${e}[0m"
    Read-Host "  Pressione ENTER para voltar"
    return
}

# ── Run Speedtest ────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m>> A correr teste de velocidade...${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

try {
    # Accept license and GDPR to avoid prompts
    & $exePath --accept-license --accept-gdpr
} catch {
    Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m  Falha ao executar speedtest"
    Write-Host "  ${e}[38;2;148;163;184m    $_${e}[0m"
}

# ── Cleanup ──────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A limpar ficheiros temporarios..." -NoNewline

try {
    Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
} catch {
    Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
}

Write-Host ""
Read-Host "  Pressione ENTER para voltar"
