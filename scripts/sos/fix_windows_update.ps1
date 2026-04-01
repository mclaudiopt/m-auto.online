# sos/fix_windows_update.ps1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$e = [char]27
Write-Host ""
Write-Host "  ${e}[1;97mReparar Windows Update${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A parar servicos..." -NoNewline
Stop-Service -Name wuauserv,cryptSvc,bits,msiserver -Force -ErrorAction SilentlyContinue
Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A limpar cache Windows Update..." -NoNewline
Remove-Item "$env:SystemRoot\SoftwareDistribution\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:SystemRoot\System32\catroot2\*" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A reiniciar servicos..." -NoNewline
Start-Service -Name wuauserv,cryptSvc,bits,msiserver -ErrorAction SilentlyContinue
Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
Write-Host ""
Write-Host "  ${e}[38;2;34;197;94m✔${e}[0m  Windows Update reparado."
Write-Host ""
Read-Host "  Pressione ENTER para voltar"
