# sos/reset_network.ps1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$e = [char]27
Write-Host ""
Write-Host "  ${e}[1;97mReset TCP/IP e DNS${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A resetar TCP/IP..." -NoNewline
netsh int ip reset | Out-Null
Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A limpar DNS cache..." -NoNewline
ipconfig /flushdns | Out-Null
Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A resetar Winsock..." -NoNewline
netsh winsock reset | Out-Null
Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A renovar IP..." -NoNewline
ipconfig /release | Out-Null
ipconfig /renew | Out-Null
Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
Write-Host ""
Write-Host "  ${e}[38;2;250;204;21m[!]${e}[0m  Recomenda-se reiniciar o PC."
Write-Host ""
Read-Host "  Pressione ENTER para voltar"
