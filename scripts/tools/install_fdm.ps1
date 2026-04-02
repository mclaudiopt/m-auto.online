# tools/install_fdm.ps1 - Free Download Manager
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$e = [char]27
$URL = "https://dn.freedownloadmanager.org/6/fdm_x64_setup.exe"
$TMP = "$env:TEMP\fdm_setup.exe"

Write-Host ""
Write-Host "  ${e}[1;97mInstalar Free Download Manager${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

$installed = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" `
    -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "*Free Download Manager*" }

if ($installed) {
    Write-Host "  ${e}[38;2;34;197;94m✔${e}[0m  Free Download Manager ja esta instalado: $($installed.DisplayVersion)"
    Write-Host ""
    Read-Host "  Pressione ENTER para voltar"
    return
}

Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A transferir..." -NoNewline
$downloaded = $false

try {
    Invoke-WebRequest -Uri $URL -OutFile $TMP -UseBasicParsing -TimeoutSec 60 -ErrorAction Stop
    $downloaded = $true
} catch {
    try {
        $wc = New-Object System.Net.WebClient
        $wc.DownloadFile($URL, $TMP)
        $downloaded = $true
    } catch {
        Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
        Write-Host "  ${e}[38;2;148;163;184m    $($_.Exception.Message)${e}[0m"
    }
}

if (-not $downloaded) {
    Write-Host ""
    Read-Host "  Pressione ENTER para voltar"
    return
}

Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A instalar..." -NoNewline

try {
    Start-Process -FilePath $TMP -ArgumentList "/S" -Wait -ErrorAction Stop
    Remove-Item $TMP -Force -ErrorAction SilentlyContinue
    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
    Write-Host ""
    Write-Host "  ${e}[38;2;34;197;94m✔${e}[0m  Free Download Manager instalado."
} catch {
    Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
    Write-Host "  ${e}[38;2;148;163;184m    $($_.Exception.Message)${e}[0m"
}

Write-Host ""
Read-Host "  Pressione ENTER para voltar"
