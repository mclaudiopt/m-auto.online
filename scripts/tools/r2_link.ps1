# r2_link.ps1 - Generate presigned R2 link for a single file
# Usage: r2_link.ps1 "Z:\Daimler\SDMEDIA.zip"
# Called by Explorer right-click context menu

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$FilePath
)

Add-Type -AssemblyName System.Windows.Forms

$RCLONE  = "C:\Users\marce\AppData\Local\Microsoft\WinGet\Packages\Rclone.Rclone_Microsoft.Winget.Source_8wekyb3d8bbwe\rclone-v1.73.4-windows-amd64\rclone.exe"
$BUCKET  = "r2-mauto:m-auto-software"
$EXPIRES = "2h"

# Mapping local roots → R2 prefix
# Add more entries here when scanning new vendor folders
$ROOT_MAP = @{
    "Z:\Daimler"  = "Daimler"
    "Z:\Autodata" = "Autodata"
    "Z:\Delphi"   = "Delphi"
    "Z:\GM"       = "GM"
    "Z:\PSA"      = "PSA"
    "Z:\Renault"  = "Renault"
    "Z:\Tools"    = "Tools"
    "Z:\VW"       = "VW"
    "Z:\hermes"   = "hermes"
}

function Show-Error($msg) {
    [System.Windows.Forms.MessageBox]::Show(
        $msg, "R2 Link - Erro",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
}

# Verificar rclone
if (-not (Test-Path $RCLONE)) {
    Show-Error "rclone nao encontrado:`n$RCLONE"
    exit 1
}

# Verificar ficheiro
if (-not (Test-Path $FilePath -PathType Leaf)) {
    Show-Error "Ficheiro nao encontrado:`n$FilePath"
    exit 1
}

# Resolver root + caminho relativo
$matchedRoot = $null
$r2Prefix    = $null
foreach ($k in $ROOT_MAP.Keys) {
    if ($FilePath -like "$k\*") {
        $matchedRoot = $k
        $r2Prefix    = $ROOT_MAP[$k]
        break
    }
}

if (-not $matchedRoot) {
    Show-Error "Ficheiro fora de uma pasta mapeada para R2.`n`nPath: $FilePath`n`nRoots conhecidos:`n$($ROOT_MAP.Keys -join "`n")"
    exit 1
}

$relPath = $FilePath.Substring($matchedRoot.Length).TrimStart('\').Replace('\', '/')
$r2Path  = "$BUCKET/$r2Prefix/$relPath"

# Mostrar progresso (janela invisivel — feedback via balao)
[System.Windows.Forms.MessageBox]::Show(
    "A gerar URL presigned...`n`n$relPath`n`nValido por: $EXPIRES",
    "R2 Link - A gerar",
    [System.Windows.Forms.MessageBoxButtons]::OK,
    [System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null

# Gerar link
$url = & $RCLONE link $r2Path --expire $EXPIRES 2>&1
if ($LASTEXITCODE -ne 0) {
    Show-Error "rclone falhou:`n`n$url"
    exit 1
}

$url = "$url".Trim()

# Copiar para clipboard
Set-Clipboard -Value $url

# Mostrar resultado
$msg = @"
URL copiado para o clipboard!

Ficheiro: $relPath
Expira em: $EXPIRES

URL:
$url
"@

[System.Windows.Forms.MessageBox]::Show(
    $msg, "R2 Link - OK",
    [System.Windows.Forms.MessageBoxButtons]::OK,
    [System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
