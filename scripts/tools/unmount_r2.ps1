# tools/unmount_r2.ps1 - Desmonta disco Z: (rclone)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$e = [char]27

Write-Host ""
Write-Host "  ${e}[1;97mDesmontar Z: (R2)${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

$procs = Get-Process rclone -ErrorAction SilentlyContinue

if (-not $procs) {
    Write-Host "  ${e}[38;2;148;163;184m·${e}[0m  Nenhum processo rclone em execucao."
} else {
    $procs | Stop-Process -Force
    Start-Sleep -Seconds 2
    Write-Host "  ${e}[38;2;34;197;94m✔${e}[0m  rclone terminado. Disco Z: desmontado."
}

Write-Host ""
Read-Host "  Pressione ENTER para sair"
