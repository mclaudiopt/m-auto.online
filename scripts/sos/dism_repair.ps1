# sos/dism_repair.ps1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$e = [char]27
Write-Host ""
Write-Host "  ${e}[1;97mReparar Windows (DISM)${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""
Write-Host "  ${e}[38;2;148;163;184m  Este processo pode demorar 10-20 minutos.${e}[0m"
Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A verificar imagem..."
DISM /Online /Cleanup-Image /CheckHealth
Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A reparar imagem..."
DISM /Online /Cleanup-Image /RestoreHealth
Write-Host ""
Read-Host "  Pressione ENTER para voltar"
