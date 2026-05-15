# r2_links_folder.ps1 - Generate presigned R2 links for ALL files in a folder
# Usage: r2_links_folder.ps1 "Z:\Daimler"
# Called by Explorer right-click context menu on a folder

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$FolderPath
)

# Carrega Get-S3PresignedUrl + Get-S3Objects (sem rclone)
. "$PSScriptRoot\r2_presign.ps1"

$EXPIRES_SEC = 7200   # 2h
$LOCAL_ROOT  = "Z:\"

#-- BalloonTip notification with message pump (works under wscript hidden) ---
function Show-Toast {
    param([string]$Title, [string]$Message, [string]$Icon = "Info", [int]$DurationMs = 6000)
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    $ctx = New-Object System.Windows.Forms.ApplicationContext
    $ni = New-Object System.Windows.Forms.NotifyIcon
    $ni.Icon = [System.Drawing.SystemIcons]::Information
    $ni.BalloonTipTitle = $Title
    $ni.BalloonTipText  = $Message
    $ni.BalloonTipIcon  = [System.Windows.Forms.ToolTipIcon]::$Icon
    $ni.Visible = $true
    $ni.add_BalloonTipClosed( { $ctx.ExitThread() })
    $ni.add_BalloonTipClicked({ $ctx.ExitThread() })
    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = $DurationMs + 1500
    $timer.Add_Tick({ $timer.Stop(); $ctx.ExitThread() })
    $timer.Start()
    $ni.ShowBalloonTip($DurationMs)
    [System.Windows.Forms.Application]::Run($ctx)
    $timer.Stop(); $timer.Dispose()
    $ni.Visible = $false; $ni.Dispose()
}

#-- Validacoes ---------------------------------------------------------------
if (-not (Test-Path $FolderPath -PathType Container)) {
    Show-Toast "R2 Links - Erro" "Pasta nao encontrada: $FolderPath"
    exit 1
}
if ($FolderPath -notlike "$LOCAL_ROOT*" -and $FolderPath -ne $LOCAL_ROOT.TrimEnd('\')) {
    Show-Toast "R2 Links - Erro" "Pasta fora de $LOCAL_ROOT"
    exit 1
}

# Calcular prefix R2 (relativo a Z:\)
$relFolder = $FolderPath.Substring($LOCAL_ROOT.Length).TrimStart('\').Replace('\', '/')
$prefix    = if ($relFolder) { "$relFolder/" } else { "" }

Show-Toast "R2 Links" "A listar ficheiros do R2..."

#-- Listar ficheiros directamente do R2 (sem mount, sem cache) ---------------
try {
    $files = Get-S3Objects -Prefix $prefix |
        Where-Object { -not $_.Key.EndsWith('/') } |
        Sort-Object Key
} catch {
    Show-Toast "R2 Links - Erro" "Falha ao listar R2: $_" -Icon "Error"
    exit 1
}

if ($files.Count -eq 0) {
    Show-Toast "R2 Links" "Pasta vazia no R2: $prefix"
    exit 0
}

Show-Toast "R2 Links" "A gerar $($files.Count) link(s) presigned..."

#-- Gerar URLs (instantaneo, calculo local) ----------------------------------
$expiresAt    = (Get-Date).AddSeconds($EXPIRES_SEC)
$expiresAtStr = $expiresAt.ToString("yyyy-MM-dd HH:mm:ss")
$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# R2 Presigned Links - $FolderPath")
$lines.Add("# Gerado: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
$lines.Add("# Expira: $expiresAtStr  (validade: $($EXPIRES_SEC/3600)h)")
$lines.Add("# Total:  $($files.Count) ficheiro(s)")
$lines.Add("")

$ok = 0; $fail = 0
foreach ($f in $files) {
    try {
        $url = Get-S3PresignedUrl -Key $f.Key -ExpiresSeconds $EXPIRES_SEC
        $sizeMB = [math]::Round($f.Size / 1MB, 1)
        $lines.Add("# $($f.Key)  ($sizeMB MB)")
        $lines.Add($url)
        $lines.Add("")
        $ok++
    } catch {
        $lines.Add("# $($f.Key)  -- ERRO: $_")
        $lines.Add("")
        $fail++
    }
}

#-- Guardar e abrir no Notepad ------------------------------------------------
$folderName = Split-Path $FolderPath -Leaf
$safeName   = $folderName -replace '[^a-zA-Z0-9_-]', '_'
$tempFile   = Join-Path $env:TEMP "r2_links_${safeName}_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
$lines | Set-Content $tempFile -Encoding UTF8

Start-Process notepad.exe -ArgumentList "`"$tempFile`""

$expHour = $expiresAt.ToString("HH:mm")
Show-Toast "R2 Links - Pronto (expira $expHour)" "$ok OK / $fail erros - aberto no Notepad"
