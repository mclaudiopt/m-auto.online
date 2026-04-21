# renew_merc_links.ps1 - Generate presigned URLs for Mercedes Pack and save to JSON
# Place a shortcut to this script at Z:\Daimler\Pack\

Add-Type -AssemblyName System.Windows.Forms

$RCLONE   = "C:\Users\marce\AppData\Local\Microsoft\WinGet\Packages\Rclone.Rclone_Microsoft.Winget.Source_8wekyb3d8bbwe\rclone-v1.73.4-windows-amd64\rclone.exe"
$BUCKET   = "r2-mauto:m-auto-software"
$DRIVE    = "Z:"
$REPO_DIR = "D:\Tutorials\m-auto.online"
$JSON_OUT = "$REPO_DIR\scripts\data\merc_links.json"
$EXPIRES  = "168h"

$e = [char]27

# Files to link — R2 path relative to bucket root
$files = @(
    @{ label = "EWA";              r2 = "Daimler/Pack/Installer/EWA.7z";                     dest = "ewa.7z"                      },
    @{ label = "StarFinder 2024";  r2 = "Daimler/Pack/Installer/Startfifinder 2024.7z";      dest = "Startfifinder 2024.7z"       },
    @{ label = "SDMEDIA";          r2 = "Daimler/Pack/Installer/SDMEDIA.zip";                 dest = "SDMEDIA.zip"                  },
    @{ label = "Coding Tutorials"; r2 = "Daimler/Pack/Installer/Coding tutorials full.7z";   dest = "Coding tutorials full.7z"    },
    @{ label = "Databases";        r2 = "Daimler/Pack/Installer/Databases.7z";                dest = "Databases.7z"                 },
    @{ label = "WIS 2021";         r2 = "Daimler/Pack/Installer/wis2021.rar";                 dest = "wis2021.rar"                  }
)

# Check rclone
if (-not (Test-Path $RCLONE)) {
    [System.Windows.Forms.MessageBox]::Show(
        "rclone nao encontrado:`n$RCLONE",
        "Renew - Erro", [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
    exit 1
}

# UI: show progress console
$Host.UI.RawUI.WindowTitle = "M-Auto - Renew Mercedes Links"
Clear-Host
Write-Host ""
Write-Host "  ${e}[38;2;29;155;255m+--------------------------------------------------+${e}[0m"
Write-Host "  ${e}[38;2;29;155;255m|${e}[0m  ${e}[1;97mM-Auto${e}[0m  ${e}[38;2;100;149;237mRenew Mercedes Links${e}[0m"
Write-Host "  ${e}[38;2;29;155;255m+--------------------------------------------------+${e}[0m"
Write-Host ""
Write-Host "  ${e}[38;2;148;163;184mValidade: 7 dias | Ficheiros: $($files.Count)${e}[0m"
Write-Host ""

# Parallel URL generation via RunspacePool
$pool = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, [Math]::Min($files.Count, 8))
$pool.Open()

$jobs = foreach ($f in $files) {
    $ps = [System.Management.Automation.PowerShell]::Create()
    $ps.RunspacePool = $pool
    [void]$ps.AddScript({
        param($rclone, $bucket, $r2path, $expires)
        $remote = "$bucket/$r2path"
        $url = & $rclone link $remote --expire $expires 2>&1
        return @{ ok = ($LASTEXITCODE -eq 0); url = "$url" }
    }).AddParameters(@{
        rclone  = $RCLONE
        bucket  = $BUCKET
        r2path  = $f.r2
        expires = $EXPIRES
    })
    @{ ps = $ps; handle = $ps.BeginInvoke(); f = $f }
}

# Collect results
$results = [System.Collections.Generic.List[object]]::new()
$expires_dt = (Get-Date).AddDays(7).ToString("o")

$i = 0
foreach ($job in $jobs) {
    $i++
    $out = $job.ps.EndInvoke($job.handle)
    $job.ps.Dispose()
    $f   = $job.f

    if ($out.ok) {
        Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m  $($f.label)"
        $results.Add([PSCustomObject]@{
            label   = $f.label
            dest    = $f.dest
            url     = $out.url.Trim()
            expires = $expires_dt
        })
    } else {
        Write-Host "  ${e}[38;2;239;68;68m[X]${e}[0m   $($f.label) — $($out.url)"
        $results.Add([PSCustomObject]@{
            label   = $f.label
            dest    = $f.dest
            url     = ""
            expires = ""
        })
    }
}
$pool.Close()

Write-Host ""

# Save JSON
$jsonContent = $results | ConvertTo-Json -Depth 3
[System.IO.File]::WriteAllText($JSON_OUT, $jsonContent, [System.Text.Encoding]::UTF8)
Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m  JSON guardado: $JSON_OUT"

# Git commit + push
Write-Host ""
Write-Host "  ${e}[38;2;148;163;184m>> Git push...${e}[0m"
$ts = Get-Date -Format "yyyy-MM-dd HH:mm"
Push-Location $REPO_DIR
try {
    git add scripts/data/merc_links.json 2>&1 | Out-Null
    git commit -m "renew: merc_links.json $ts" 2>&1 | ForEach-Object { Write-Host "  ${e}[38;2;80;100;140m$_${e}[0m" }
    git push 2>&1 | ForEach-Object { Write-Host "  ${e}[38;2;80;100;140m$_${e}[0m" }
    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m  Publicado em m-auto.online/scripts/data/merc_links.json"
} catch {
    Write-Host "  ${e}[38;2;239;68;68m[X]${e}[0m   Git erro: $_"
} finally {
    Pop-Location
}

Write-Host ""
$ok = ($results | Where-Object { $_.url }).Count
$failed = $results.Count - $ok
if ($failed -gt 0) {
    Write-Host "  ${e}[38;2;250;204;21m[!]${e}[0m   $ok/$($results.Count) links gerados ($failed falharam)"
} else {
    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m  Todos os $ok links gerados e publicados."
}
Write-Host "  ${e}[38;2;148;163;184m       Validos ate: $(([datetime]::Parse($expires_dt)).ToString('dd/MM/yyyy HH:mm'))${e}[0m"
Write-Host ""
Read-Host "  Pressione ENTER para sair"
