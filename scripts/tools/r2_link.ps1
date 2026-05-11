# r2_link.ps1 - Generate presigned R2 link for a single file
# Usage: r2_link.ps1 "Z:\Daimler\SDMEDIA.zip"
# Called by Explorer right-click context menu

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$FilePath
)

$RCLONE  = "C:\Users\marce\AppData\Local\Microsoft\WinGet\Packages\Rclone.Rclone_Microsoft.Winget.Source_8wekyb3d8bbwe\rclone-v1.73.4-windows-amd64\rclone.exe"
$BUCKET  = "r2-mauto:m-auto-software"
$EXPIRES = "2h"
$APP_ID  = "M-Auto.R2Link"

# Local root drive — qualquer subpasta de Z:\ mapeia para o R2 com o mesmo nome
# Ex: Z:\Daimler\EPC\file.iso  ->  r2://m-auto-software/Daimler/EPC/file.iso
$LOCAL_ROOT = "Z:\"

#-- Notification via NotifyIcon BalloonTip (sem registo AppID) ---------------
function Show-Toast {
    param(
        [string]$Title,
        [string]$Message,
        [string]$Icon = "Info"  # Info | Warning | Error
    )
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $ni = New-Object System.Windows.Forms.NotifyIcon
    $ni.Icon = [System.Drawing.SystemIcons]::Information
    $ni.BalloonTipTitle = $Title
    $ni.BalloonTipText  = $Message
    $ni.BalloonTipIcon  = [System.Windows.Forms.ToolTipIcon]::$Icon
    $ni.Visible = $true
    $ni.ShowBalloonTip(8000)

    # Manter o icon vivo o tempo suficiente para o balao mostrar
    Start-Sleep -Seconds 6
    $ni.Dispose()
}

#-- Validacoes ---------------------------------------------------------------
if (-not (Test-Path $RCLONE)) {
    Show-Toast -Title "R2 Link - Erro" -Message "rclone nao encontrado." -Icon "Error"
    exit 1
}

if (-not (Test-Path $FilePath -PathType Leaf)) {
    Show-Toast -Title "R2 Link - Erro" -Message "Ficheiro nao encontrado: $FilePath" -Icon "Error"
    exit 1
}

# Resolver caminho relativo a Z:\ (qualquer subpasta mapeia 1:1 para o R2)
if ($FilePath -notlike "$LOCAL_ROOT*") {
    Show-Toast -Title "R2 Link - Erro" -Message "Ficheiro fora de $LOCAL_ROOT" -Icon "Error"
    exit 1
}

$relPath = $FilePath.Substring($LOCAL_ROOT.Length).TrimStart('\').Replace('\', '/')
$r2Path  = "$BUCKET/$relPath"

#-- Gerar link ---------------------------------------------------------------
$url = & $RCLONE link $r2Path --expire $EXPIRES 2>&1
if ($LASTEXITCODE -ne 0) {
    Show-Toast -Title "R2 Link - Falhou" -Message "rclone erro: $url"
    exit 1
}

$url = "$url".Trim()

# Copiar para clipboard
Set-Clipboard -Value $url

# Toast de sucesso
$fileName = Split-Path $FilePath -Leaf
$expiresAt = (Get-Date).AddHours(2).ToString("HH:mm")
Show-Toast -Title "R2 Link copiado (expira $expiresAt)" -Message "$fileName`n`nValido $EXPIRES - URL no clipboard"
