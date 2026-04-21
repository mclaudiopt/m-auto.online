# renew_merc_links.ps1 - Generate presigned URLs for all files in Z:\Daimler\Pack\Installer
# Place a shortcut to this script at Z:\Daimler\Pack\

Add-Type -AssemblyName System.Windows.Forms

$RCLONE    = "C:\Users\marce\AppData\Local\Microsoft\WinGet\Packages\Rclone.Rclone_Microsoft.Winget.Source_8wekyb3d8bbwe\rclone-v1.73.4-windows-amd64\rclone.exe"
$BUCKET    = "r2-mauto:m-auto-software"
$SCAN_DIR  = "Z:\Daimler\Pack\Installer"
$R2_PREFIX = "Daimler/Pack/Installer"
$REPO_DIR  = "D:\Tutorials\m-auto.online"
$JSON_OUT  = "$REPO_DIR\merc_links.json"
$EXPIRES   = "2h"
$e         = [char]27

# Check rclone
if (-not (Test-Path $RCLONE)) {
    [System.Windows.Forms.MessageBox]::Show(
        "rclone nao encontrado:`n$RCLONE",
        "Renew - Erro", [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
    exit 1
}

# Check drive
if (-not (Test-Path $SCAN_DIR)) {
    [System.Windows.Forms.MessageBox]::Show(
        "Pasta nao encontrada: $SCAN_DIR`n`nVerifica se o drive Z:\ esta mapeado.",
        "Renew - Erro", [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
    exit 1
}

# Scan all files — exclude .@__thumb folders and .error files
$allFiles = Get-ChildItem $SCAN_DIR -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object {
        $_.FullName -notmatch '\\.@__thumb\\' -and
        $_.FullName -notmatch '\\Vediamo DTS WIZ\\' -and
        $_.Extension -ne '.error'
    } |
    Sort-Object FullName

$Host.UI.RawUI.WindowTitle = "M-Auto - Renew Mercedes Links"
Clear-Host
Write-Host ""
Write-Host "  ${e}[38;2;29;155;255m+--------------------------------------------------+${e}[0m"
Write-Host "  ${e}[38;2;29;155;255m|${e}[0m  ${e}[1;97mM-Auto${e}[0m  ${e}[38;2;100;149;237mRenew Mercedes Links${e}[0m"
Write-Host "  ${e}[38;2;29;155;255m+--------------------------------------------------+${e}[0m"
Write-Host ""
Write-Host "  ${e}[38;2;148;163;184mPasta: $SCAN_DIR${e}[0m"
Write-Host "  ${e}[38;2;148;163;184mValidade: 2 horas | Ficheiros encontrados: $($allFiles.Count)${e}[0m"
Write-Host ""

# Build file entries
$files = foreach ($f in $allFiles) {
    $relPath = $f.FullName.Substring($SCAN_DIR.Length).TrimStart('\').Replace('\', '/')
    $label   = if ($f.DirectoryName -eq $SCAN_DIR) { $f.Name } else {
        $subfolder = $f.DirectoryName.Substring($SCAN_DIR.Length).TrimStart('\')
        "$subfolder\$($f.Name)"
    }
    [PSCustomObject]@{
        label = $label
        dest  = $relPath          # relative path with subfolders preserved
        r2    = "$R2_PREFIX/$relPath"
    }
}

# Parallel URL generation
$pool = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, [Math]::Min($files.Count, 8))
$pool.Open()

$jobs = foreach ($f in $files) {
    $ps = [System.Management.Automation.PowerShell]::Create()
    $ps.RunspacePool = $pool
    [void]$ps.AddScript({
        param($rclone, $bucket, $r2path, $expires)
        $remote = "$bucket/$r2path"
        $url = & $rclone link $remote --expire $expires 2>&1
        return @{ ok = ($LASTEXITCODE -eq 0); url = "$url".Trim() }
    }).AddParameters(@{ rclone = $RCLONE; bucket = $BUCKET; r2path = $f.r2; expires = $EXPIRES })
    @{ ps = $ps; handle = $ps.BeginInvoke(); f = $f }
}

$expires_dt = (Get-Date).AddHours(2).ToUniversalTime().ToString("o")
$filesList  = [System.Collections.Generic.List[object]]::new()
$errCount   = 0

foreach ($job in $jobs) {
    $out = $job.ps.EndInvoke($job.handle)
    $job.ps.Dispose()
    $f   = $job.f
    if ($out.ok) {
        Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m  $($f.label)"
        $filesList.Add([PSCustomObject]@{ name = $f.dest; url = $out.url })
    } else {
        Write-Host "  ${e}[38;2;239;68;68m[X]${e}[0m   $($f.label)"
        Write-Host "       ${e}[38;2;80;100;140m$($out.url)${e}[0m"
        $errCount++
    }
}
$pool.Close()

Write-Host ""

# Save JSON — format: { expires, files: [ { name, url } ] }
$jsonObj = [PSCustomObject]@{ expires = $expires_dt; files = $filesList.ToArray() }
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($JSON_OUT, ($jsonObj | ConvertTo-Json -Depth 3), $utf8NoBom)
Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m  JSON guardado ($($filesList.Count) ficheiros)"

# Git commit + push — capture stderr as string to avoid red output
Write-Host ""
Write-Host "  ${e}[38;2;148;163;184m>> Git push...${e}[0m"
$ts = Get-Date -Format "yyyy-MM-dd HH:mm"
Push-Location $REPO_DIR
try {
    $null = git add merc_links.json 2>&1
    $commitOut = git commit -m "renew: merc_links.json $ts ($($filesList.Count) ficheiros)" 2>&1
    $commitOut | ForEach-Object { Write-Host "  ${e}[38;2;80;100;140m$([string]$_)${e}[0m" }
    $pushOut = git push 2>&1
    $pushOut | ForEach-Object { Write-Host "  ${e}[38;2;80;100;140m$([string]$_)${e}[0m" }
    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m  Publicado em m-auto.online/merc_links.json"
} catch {
    Write-Host "  ${e}[38;2;239;68;68m[X]${e}[0m   Git erro: $([string]$_)"
} finally {
    Pop-Location
}

Write-Host ""
$ok = $filesList.Count
if ($errCount -gt 0) {
    Write-Host "  ${e}[38;2;250;204;21m[!]${e}[0m   $ok/$($ok + $errCount) links gerados ($errCount falharam)"
} else {
    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m  Todos os $ok links gerados e publicados."
}
Write-Host "  ${e}[38;2;148;163;184m       Validos ate: $((([datetime]::Parse($expires_dt)).ToLocalTime()).ToString('dd/MM/yyyy HH:mm'))${e}[0m"
Write-Host ""
Read-Host "  Pressione ENTER para sair"
