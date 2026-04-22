# tools/gerar_link.ps1 - Gera presigned URL para enviar a cliente
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$e = [char]27

$RCLONE = "C:\Users\marce\AppData\Local\Microsoft\WinGet\Packages\Rclone.Rclone_Microsoft.Winget.Source_8wekyb3d8bbwe\rclone-v1.73.4-windows-amd64\rclone.exe"
$BUCKET = "r2-mauto:m-auto-software"

$SOFTWARES = @(
    @{ Nome = "Xentry / DAS (SDMEDIA)";        Path = "Daimler/Pack/Installer/SDMEDIA.zip" },
    @{ Nome = "WIS / ASRA (Mercedes)";          Path = "Daimler/Pack/Installer/Mercedes-Benz.WIS.ASRA.Standalone.v10.2021.Anywhere.rar" },
    @{ Nome = "EPC 2018 (1/4)";                 Path = "Daimler/Pack/Installer/EPC 2018-11/EPC_1118_1of4_a1.iso" },
    @{ Nome = "EPC 2018 (2/4)";                 Path = "Daimler/Pack/Installer/EPC 2018-11/EPC_1118_2of4_a2.iso" },
    @{ Nome = "EPC 2018 (3/4)";                 Path = "Daimler/Pack/Installer/EPC 2018-11/EPC_1118_3of4_a3.iso" },
    @{ Nome = "EPC 2018 (4/4)";                 Path = "Daimler/Pack/Installer/EPC 2018-11/EPC_1118_4of4_a4.iso" },
    @{ Nome = "Delphi DS150E 2022";             Path = "Delphi" },
    @{ Nome = "Autodata 3.41";                  Path = "Autodata" }
)

Write-Host ""
Write-Host "  ${e}[1;97mGerar Link de Download${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

# Menu
for ($i = 0; $i -lt $SOFTWARES.Count; $i++) {
    Write-Host ("  {0,2}. {1}" -f ($i+1), $SOFTWARES[$i].Nome)
}
Write-Host ""
$escolha = Read-Host "  Escolha [1-$($SOFTWARES.Count)]"
$idx = [int]$escolha - 1

if ($idx -lt 0 -or $idx -ge $SOFTWARES.Count) {
    Write-Host "  ${e}[38;2;239;68;68mOpcao invalida.${e}[0m"
    Read-Host "  ENTER para sair"
    exit 1
}

$software = $SOFTWARES[$idx]

# Validade
Write-Host ""
$dias = Read-Host "  Validade em dias [default: 7]"
if (-not $dias -or $dias -notmatch '^\d+$') { $dias = 7 }
$expire = "${dias}d"

Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A gerar link..." -NoNewline

$url = & $RCLONE link "$BUCKET/$($software.Path)" --expire $expire 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
    Write-Host "  $url"
    Read-Host "  ENTER para sair"
    exit 1
}

Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"

# Gerar script download para cliente
$fileName  = Split-Path $software.Path -Leaf
$clientScript = @"
# M-Auto.online — Download: $($software.Nome)
# Validade: $dias dias a partir de hoje
# Nao e necessario instalar nada — usa o Windows BITS nativo

`$URL  = "$url"
`$DEST = "`$env:USERPROFILE\Downloads\$fileName"

Write-Host ""
Write-Host "  M-Auto.online — A descarregar: $($software.Nome)"
Write-Host "  Destino: `$DEST"
Write-Host ""

if (Test-Path `$DEST) {
    Write-Host "  Ficheiro ja existe. A retomar se incompleto..."
}

try {
    Import-Module BitsTransfer -ErrorAction Stop
    `$job = Start-BitsTransfer -Source `$URL -Destination `$DEST -Asynchronous -DisplayName "M-Auto: $($software.Nome)"

    while (`$job.JobState -notin @("Transferred","Error")) {
        `$pct = if (`$job.BytesTotal -gt 0) { [int](`$job.BytesTransferred / `$job.BytesTotal * 100) } else { 0 }
        `$mb  = [math]::Round(`$job.BytesTransferred / 1MB, 1)
        `$tot = [math]::Round(`$job.BytesTotal / 1MB, 1)
        Write-Host -NoNewline "`r  Progresso: `$pct% (`${mb} MB / `${tot} MB)    "
        Start-Sleep -Seconds 2
    }

    Write-Host ""

    if (`$job.JobState -eq "Transferred") {
        Complete-BitsTransfer `$job
        Write-Host "  OK — Download concluido: `$DEST"
    } else {
        Write-Host "  ERRO: `$(`$job.ErrorDescription)"
        Remove-BitsTransfer `$job
    }
} catch {
    Write-Host "  Erro BITS: `$_"
}

Write-Host ""
Read-Host "  Pressione ENTER para sair"
"@

# Guardar script
$outDir  = "D:\Tutorials\m-auto.online\scripts\clientes"
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }
$safeName = $software.Nome -replace '[^a-zA-Z0-9]', '_'
$outFile  = "$outDir\download_$safeName.ps1"
$clientScript | Out-File -FilePath $outFile -Encoding UTF8

# Copiar URL para clipboard
$url | Set-Clipboard

Write-Host ""
Write-Host "  ${e}[38;2;34;197;94m✔${e}[0m  Script cliente guardado:"
Write-Host "     $outFile"
Write-Host ""
Write-Host "  ${e}[38;2;34;197;94m✔${e}[0m  URL copiado para clipboard."
Write-Host ""
Write-Host "  ${e}[38;2;148;163;184m  Envie ao cliente o script .ps1 ou o URL direto.${e}[0m"
Write-Host "  ${e}[38;2;148;163;184m  O cliente corre: powershell -ExecutionPolicy Bypass -File download_*.ps1${e}[0m"
Write-Host ""
Read-Host "  Pressione ENTER para sair"
