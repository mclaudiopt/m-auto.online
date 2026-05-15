# r2_links_folder.ps1 - Generate presigned R2 links for ALL files in a folder
# Usage: r2_links_folder.ps1 "Z:\Daimler"
# Called by Explorer right-click context menu on a folder

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$FolderPath
)

$RCLONE  = "C:\Users\marce\AppData\Local\Microsoft\WinGet\Packages\Rclone.Rclone_Microsoft.Winget.Source_8wekyb3d8bbwe\rclone-v1.73.4-windows-amd64\rclone.exe"
$BUCKET  = "r2-mauto:m-auto-software"
$EXPIRES = "2h"
$APP_ID  = "M-Auto.R2Link"

# Local root drive — qualquer subpasta de Z:\ mapeia para o R2 com o mesmo nome
$LOCAL_ROOT = "Z:\"

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
if (-not (Test-Path $RCLONE)) {
    Show-Toast "R2 Links - Erro" "rclone nao encontrado"
    exit 1
}
if (-not (Test-Path $FolderPath -PathType Container)) {
    Show-Toast "R2 Links - Erro" "Pasta nao encontrada: $FolderPath"
    exit 1
}

# Validar que esta dentro de Z:\
if ($FolderPath -notlike "$LOCAL_ROOT*" -and $FolderPath -ne $LOCAL_ROOT.TrimEnd('\')) {
    Show-Toast "R2 Links - Erro" "Pasta fora de $LOCAL_ROOT"
    exit 1
}

#-- Listar ficheiros (recursivo, exclui thumbs/error) ------------------------
$files = Get-ChildItem $FolderPath -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object {
        $_.FullName -notmatch '\\.@__thumb\\' -and
        $_.Extension -ne '.error'
    } |
    Sort-Object FullName

if ($files.Count -eq 0) {
    Show-Toast "R2 Links" "Pasta vazia: $FolderPath"
    exit 0
}

Show-Toast "R2 Links" "A gerar $($files.Count) link(s) em paralelo..."

#-- Gerar links em paralelo (runspace pool) ----------------------------------
$pool = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, [Math]::Min($files.Count, 8))
$pool.Open()

$jobs = foreach ($f in $files) {
    $relPath = $f.FullName.Substring($LOCAL_ROOT.Length).TrimStart('\').Replace('\', '/')
    $r2Path  = "$BUCKET/$relPath"

    $ps = [PowerShell]::Create()
    $ps.RunspacePool = $pool
    [void]$ps.AddScript({
        param($rclone, $r2path, $expires)
        $url = & $rclone link $r2path --expire $expires 2>&1
        return @{ ok = ($LASTEXITCODE -eq 0); url = "$url".Trim() }
    }).AddParameters(@{ rclone = $RCLONE; r2path = $r2Path; expires = $EXPIRES })

    @{ ps = $ps; handle = $ps.BeginInvoke(); file = $f; rel = $relPath }
}

#-- Construir output ---------------------------------------------------------
$expiresAt    = (Get-Date).AddHours(2)
$expiresAtStr = $expiresAt.ToString("yyyy-MM-dd HH:mm:ss")
$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# R2 Presigned Links - $FolderPath")
$lines.Add("# Gerado: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
$lines.Add("# Expira: $expiresAtStr  (validade: $EXPIRES)")
$lines.Add("# Total:  $($files.Count) ficheiro(s)")
$lines.Add("")

$ok = 0; $fail = 0
foreach ($job in $jobs) {
    $out = $job.ps.EndInvoke($job.handle)
    $job.ps.Dispose()
    if ($out.ok) {
        $sizeMB = [math]::Round($job.file.Length / 1MB, 1)
        $lines.Add("# $($job.rel)  ($sizeMB MB)")
        $lines.Add($out.url)
        $lines.Add("")
        $ok++
    } else {
        $lines.Add("# $($job.rel)  -- ERRO")
        $lines.Add("# $($out.url)")
        $lines.Add("")
        $fail++
    }
}
$pool.Close()

#-- Guardar e abrir no Notepad ------------------------------------------------
$folderName = Split-Path $FolderPath -Leaf
$safeName   = $folderName -replace '[^a-zA-Z0-9_-]', '_'
$tempFile   = Join-Path $env:TEMP "r2_links_${safeName}_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
$lines | Set-Content $tempFile -Encoding UTF8

Start-Process notepad.exe -ArgumentList "`"$tempFile`""

$expHour = $expiresAt.ToString("HH:mm")
Show-Toast "R2 Links - Pronto (expira $expHour)" "$ok OK / $fail erros - aberto no Notepad"
