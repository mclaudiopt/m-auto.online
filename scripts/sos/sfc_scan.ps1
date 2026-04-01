# sos/sfc_scan.ps1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$e = [char]27
Write-Host ""
Write-Host "  ${e}[1;97mReparar Ficheiros de Sistema (SFC)${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""
Write-Host "  ${e}[38;2;148;163;184m  Este processo pode demorar varios minutos.${e}[0m"
Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A executar sfc /scannow..." -NoNewline
Write-Host ""
sfc /scannow
Write-Host ""
Read-Host "  Pressione ENTER para voltar"
