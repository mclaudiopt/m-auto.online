# Renew Links - Direct S3 (rclone)
# Gera presigned URLs direto de S3, sem precisar de pasta local
# Usage: & 'path\renew-s3-direct.ps1' -brand merc|renault|psa|delphi|ford|gm|vw|tesla|hermes|autodata

param([string]$brand = "merc")

Add-Type -AssemblyName System.Windows.Forms

$RCLONE    = (Get-Command rclone -ErrorAction SilentlyContinue).Source
$BUCKET    = "r2-mauto:m-auto-software"
$REPO_DIR  = "D:\Tutorials\m-auto.online"
$EXPIRES   = "2h"
$e         = [char]27

# Brand mapping
$brands = @{
    'merc'     = @{ r2='Daimler'; label='Mercedes' }
    'mercedes' = @{ r2='Daimler'; label='Mercedes' }
    'renault'  = @{ r2='Renault'; label='Renault' }
    'psa'      = @{ r2='PSA'; label='PSA' }
    'autodata' = @{ r2='Autodata'; label='Autodata' }
    'delphi'   = @{ r2='Delphi'; label='Delphi' }
    'ford'     = @{ r2='Ford'; label='Ford' }
    'gm'       = @{ r2='GM'; label='GM' }
    'tesla'    = @{ r2='TESLA'; label='TESLA' }
    'vw'       = @{ r2='VW'; label='VW' }
    'hermes'   = @{ r2='Hermes'; label='Hermes' }
}

if (-not $brands.ContainsKey($brand)) {
    Write-Host "Marcas disponíveis: $($brands.Keys -join ', ')"
    exit 1
}

$cfg = $brands[$brand]
$r2_path = "$BUCKET/$($cfg.r2)"
$json_out = "$REPO_DIR\$brand`_links.json"

# Check rclone
if (-not (Test-Path $RCLONE)) {
    [System.Windows.Forms.MessageBox]::Show("rclone nao encontrado: $RCLONE", "Erro", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
    exit 1
}

$Host.UI.RawUI.WindowTitle = "M-Auto - Renew $($cfg.label) Links (S3 Direct)"
Clear-Host
Write-Host ""
Write-Host "  ${e}[38;2;29;155;255m+--------------------------------------------------+${e}[0m"
Write-Host "  ${e}[38;2;29;155;255m|${e}[0m  ${e}[1;97mM-Auto${e}[0m  ${e}[38;2;100;149;237mRenew $($cfg.label) Links (S3)${e}[0m"
Write-Host "  ${e}[38;2;29;155;255m+--------------------------------------------------+${e}[0m"
Write-Host ""
Write-Host "  ${e}[38;2;148;163;184mS3: $r2_path${e}[0m"
Write-Host "  ${e}[38;2;148;163;184mValidade: 2 horas${e}[0m"
Write-Host ""
Write-Host "  ${e}[38;2;148;163;184m>> Listando ficheiros do S3...${e}[0m"
Write-Host ""

# List files from S3
$rclone_output = & $RCLONE ls $r2_path 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ${e}[38;2;239;68;68m[FAIL]${e}[0m  Erro ao listar S3: $rclone_output"
    exit 1
}

$files = @()
foreach ($line in $rclone_output -split "`n") {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    # Format: "  size  path/to/file"
    if ($line -match '^\s*(\d+)\s+(.+)$') {
        $size = [int]$matches[1]
        $path = $matches[2].Trim()
        $files += @{ name=$path; size=$size }
    }
}

if ($files.Count -eq 0) {
    Write-Host "  ${e}[38;2;239;68;68m[FAIL]${e}[0m  Nenhum ficheiro encontrado em $r2_path"
    exit 1
}

Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m  Encontrados $($files.Count) ficheiros"
Write-Host ""
Write-Host "  ${e}[38;2;148;163;184m>> Gerando presigned URLs (paralelo)...${e}[0m"
Write-Host ""

# Parallel URL generation
$pool = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, [Math]::Min($files.Count, 8))
$pool.Open()

$jobs = foreach ($f in $files) {
    $ps = [System.Management.Automation.PowerShell]::Create()
    $ps.RunspacePool = $pool
    [void]$ps.AddScript({
        param($rclone, $bucket, $path, $expires)
        $remote = "$bucket/$path"
        $url = & $rclone link $remote --expire $expires 2>&1
        return @{ ok = ($LASTEXITCODE -eq 0); url = "$url".Trim() }
    }).AddParameters(@{ rclone = $RCLONE; bucket = $r2_path; path = $f.name; expires = $EXPIRES })
    @{ ps = $ps; handle = $ps.BeginInvoke(); f = $f }
}

$expires_dt = (Get-Date).AddHours(2).ToUniversalTime().ToString("o")
$filesList  = [System.Collections.Generic.List[object]]::new()
$errCount   = 0
$okCount    = 0

foreach ($job in $jobs) {
    $out = $job.ps.EndInvoke($job.handle)
    $job.ps.Dispose()
    $f   = $job.f
    if ($out.ok) {
        Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m  $($f.name)"
        $filesList.Add([PSCustomObject]@{ name = $f.name; url = $out.url; size = $f.size })
        $okCount++
    } else {
        Write-Host "  ${e}[38;2;239;68;68m[FAIL]${e}[0m  $($f.name)"
        Write-Host "       ${e}[38;2;80;100;140m$($out.url)${e}[0m"
        $errCount++
    }
}
$pool.Close()

Write-Host ""
Write-Host "  ${e}[38;2;148;163;184m>> Finalizando...${e}[0m"
Write-Host ""

# Save JSON
$filesJson = ($filesList.ToArray() | ConvertTo-Json -Depth 2 -Compress)
$jsonRaw    = "{`"expires`":`"$expires_dt`",`"files`":$filesJson}"
$utf8NoBom  = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($json_out, $jsonRaw, $utf8NoBom)
Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m  JSON guardado ($($filesList.Count) ficheiros)"

# Git commit + push
Write-Host ""
Write-Host "  ${e}[38;2;148;163;184m>> Git push...${e}[0m"
$ts = Get-Date -Format "yyyy-MM-dd HH:mm"
Push-Location $REPO_DIR
try {
    $null = git add "$brand`_links.json" 2>&1
    $commitOut = git commit -m "renew: $brand`_links.json $ts ($($filesList.Count) ficheiros)" 2>&1
    $commitOut | ForEach-Object { Write-Host "  ${e}[38;2;80;100;140m$([string]$_)${e}[0m" }
    $pushOut = git push 2>&1
    $pushOut | ForEach-Object { Write-Host "  ${e}[38;2;80;100;140m$([string]$_)${e}[0m" }
    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m  Publicado em m-auto.online/$brand`_links.json"
} catch {
    Write-Host "  ${e}[38;2;239;68;68m[X]${e}[0m   Git erro: $([string]$_)"
} finally {
    Pop-Location
}

Write-Host ""
if ($errCount -gt 0) {
    Write-Host "  ${e}[38;2;250;204;21m[!]${e}[0m   $okCount/$($okCount + $errCount) links gerados ($errCount falharam)"
} else {
    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m  Todos os $okCount links gerados e publicados."
}
Write-Host "  ${e}[38;2;148;163;184m       Validos ate: $((([datetime]::Parse($expires_dt)).ToLocalTime()).ToString('dd/MM/yyyy HH:mm'))${e}[0m"
Write-Host ""
Read-Host "  Pressione ENTER para sair"
