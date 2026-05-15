# r2_link.ps1 - Generate presigned R2 link for a single file
# Usage: r2_link.ps1 "Z:\Daimler\SDMEDIA.zip"
# Called by Explorer right-click context menu

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$FilePath,
    [ValidateSet("HTTP","Aria")]
    [string]$Mode = "HTTP"
)

# Carrega Get-S3PresignedUrl (sem dependencia de rclone)
. "$PSScriptRoot\r2_presign.ps1"

# HTTP=4h (uso rapido), Aria=24h (downloads longos)
$EXPIRES_SEC = if ($Mode -eq "Aria") { 86400 } else { 14400 }
$LOCAL_ROOT  = "Z:\"

#-- Notification via NotifyIcon BalloonTip (com message pump) ----------------
# Application.Run() e essencial quando lancado via wscript hidden
function Show-Toast {
    param(
        [string]$Title,
        [string]$Message,
        [string]$Icon = "Info",  # Info | Warning | Error
        [int]$DurationMs = 7000
    )
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $ctx = New-Object System.Windows.Forms.ApplicationContext
    $ni  = New-Object System.Windows.Forms.NotifyIcon
    $ni.Icon = [System.Drawing.SystemIcons]::Information
    $ni.BalloonTipTitle = $Title
    $ni.BalloonTipText  = $Message
    $ni.BalloonTipIcon  = [System.Windows.Forms.ToolTipIcon]::$Icon
    $ni.Visible = $true

    $ni.add_BalloonTipClosed( { $ctx.ExitThread() })
    $ni.add_BalloonTipClicked({ $ctx.ExitThread() })

    # Timer de seguranca para sair se o balao nao disparar evento de close
    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = $DurationMs + 1500
    $timer.Add_Tick({ $timer.Stop(); $ctx.ExitThread() })
    $timer.Start()

    $ni.ShowBalloonTip($DurationMs)
    [System.Windows.Forms.Application]::Run($ctx)

    $timer.Stop()
    $timer.Dispose()
    $ni.Visible = $false
    $ni.Dispose()
}

#-- Validacoes ---------------------------------------------------------------
if (-not (Test-Path $FilePath -PathType Leaf)) {
    Show-Toast -Title "R2 Link - Erro" -Message "Ficheiro nao encontrado: $FilePath" -Icon "Error"
    exit 1
}

if ($FilePath -notlike "$LOCAL_ROOT*") {
    Show-Toast -Title "R2 Link - Erro" -Message "Ficheiro fora de $LOCAL_ROOT" -Icon "Error"
    exit 1
}

$relPath = $FilePath.Substring($LOCAL_ROOT.Length).TrimStart('\').Replace('\', '/')

#-- Gerar link via S3 SigV4 (PowerShell puro, instantaneo) -------------------
try {
    $url = Get-S3PresignedUrl -Key $relPath -ExpiresSeconds $EXPIRES_SEC
} catch {
    Show-Toast -Title "R2 Link - Falhou" -Message "Erro: $_" -Icon "Error"
    exit 1
}

# Copiar para clipboard
Set-Clipboard -Value $url

# Toast de sucesso
$fileName  = Split-Path $FilePath -Leaf
$expiresAt = (Get-Date).AddSeconds($EXPIRES_SEC).ToString("HH:mm")
$validHrs  = $EXPIRES_SEC / 3600
Show-Toast -Title "Link $Mode copiado (expira $expiresAt, ${validHrs}h)" -Message "$fileName`n`nURL no clipboard"
