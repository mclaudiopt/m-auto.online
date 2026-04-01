# sos/reboot_bios.ps1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$e = [char]27
Write-Host ""
Write-Host "  ${e}[1;97mReiniciar para BIOS / UEFI${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""
Write-Host "  ${e}[38;2;239;68;68m[!]${e}[0m  O PC vai reiniciar imediatamente para a BIOS."
Write-Host ""
$r = ""
while ($r -notmatch "^[sSnN]$") {
    $r = Read-Host "  Confirmar reinicio para BIOS? [s/n]"
}
if ($r -match "^[sS]$") {
    Write-Host ""
    Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A reiniciar..."
    Start-Sleep -Seconds 2
    shutdown /r /fw /t 0
} else {
    Write-Host "  Cancelado."
}
Write-Host ""
Read-Host "  Pressione ENTER para voltar"
