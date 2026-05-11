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

# Mapping local roots → R2 prefix
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

#-- Toast helper -------------------------------------------------------------
function Show-Toast {
    param([string]$Title, [string]$Message)
    try {
        [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType=WindowsRuntime] | Out-Null
        [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom, ContentType=WindowsRuntime] | Out-Null
        $xml = "<toast><visual><binding template='ToastGeneric'><text>$([System.Security.SecurityElement]::Escape($Title))</text><text>$([System.Security.SecurityElement]::Escape($Message))</text></binding></visual></toast>"
        $doc = New-Object Windows.Data.Xml.Dom.XmlDocument
        $doc.LoadXml($xml)
        $toast = [Windows.UI.Notifications.ToastNotification]::new($doc)
        [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($APP_ID).Show($toast)
    } catch {}
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

# Resolver root mapeado
$matchedRoot = $null
$r2Prefix    = $null
foreach ($k in $ROOT_MAP.Keys) {
    if ($FolderPath -eq $k -or $FolderPath -like "$k\*") {
        $matchedRoot = $k
        $r2Prefix    = $ROOT_MAP[$k]
        break
    }
}
if (-not $matchedRoot) {
    Show-Toast "R2 Links - Erro" "Pasta fora dos roots mapeados (Z:\Daimler, Z:\PSA, etc.)"
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
    $relPath = $f.FullName.Substring($matchedRoot.Length).TrimStart('\').Replace('\', '/')
    $r2Path  = "$BUCKET/$r2Prefix/$relPath"

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
$expiresAt = (Get-Date).AddHours(2).ToString("yyyy-MM-dd HH:mm")
$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# R2 Presigned Links - $($matchedRoot)")
$lines.Add("# Gerado: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  |  Expira: $expiresAt  ($EXPIRES)")
$lines.Add("# Total: $($files.Count) ficheiro(s)")
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

Show-Toast "R2 Links - Pronto" "$ok OK / $fail erros - aberto no Notepad"
