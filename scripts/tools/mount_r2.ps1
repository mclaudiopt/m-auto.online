# mount_r2.ps1 - Monta R2 como Z: com retry
$RCLONE  = "C:\Users\marce\AppData\Local\Microsoft\WinGet\Packages\Rclone.Rclone_Microsoft.Winget.Source_8wekyb3d8bbwe\rclone-v1.73.4-windows-amd64\rclone.exe"
$DRIVE   = "Z:"
$LOGFILE = "$env:TEMP\rclone_r2.log"
$MAXWAIT = 120   # segundos maximos a aguardar WinFSP
$elapsed = 0

# Aguardar WinFSP ficar disponivel
while ($elapsed -lt $MAXWAIT) {
    $svc = Get-Service "WinFsp.Launcher" -ErrorAction SilentlyContinue
    if ($svc -and $svc.Status -eq "Running") { break }
    Start-Sleep -Seconds 5
    $elapsed += 5
}

if (Test-Path "$DRIVE\") { exit 0 }   # ja montado

$argStr = "mount r2-mauto:m-auto-software $DRIVE --volname `"M-Auto S3`" --vfs-cache-mode full --vfs-cache-max-size 2G --vfs-cache-max-age 24h --dir-cache-time 5m --transfers 8 --buffer-size 64M --links --log-file `"$LOGFILE`" --log-level INFO --no-console"

# Tentar montar com retry
for ($i = 0; $i -lt 5; $i++) {
    Start-Process -FilePath $RCLONE -ArgumentList $argStr -WindowStyle Hidden
    Start-Sleep -Seconds 8
    if (Test-Path "$DRIVE\") { exit 0 }
    Start-Sleep -Seconds 10
}
