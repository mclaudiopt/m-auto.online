# clients/tesla.ps1 - Instalacao cliente Tesla
# TODO: adicionar links e configuracoes especificas do cliente
$e = [char]27

Write-Host ""
Write-Host "  ${e}[1;97mCliente: Tesla${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""
Write-Host "  ${e}[38;2;250;204;21m[!]   Script em preparacao - aguarda links do cliente.${e}[0m"
Write-Host ""
Write-Host "  Passos previstos:"
Write-Host "  ${e}[38;2;80;100;140m  [1] Desativar Defender + Firewall${e}[0m"
Write-Host "  ${e}[38;2;80;100;140m  [2] Limpar ficheiros temporarios${e}[0m"
Write-Host "  ${e}[38;2;80;100;140m  [3] Instalar 7-Zip${e}[0m"
Write-Host "  ${e}[38;2;80;100;140m  [4] Instalar software especifico${e}[0m"
Write-Host "  ${e}[38;2;80;100;140m  [5] Criar atalhos no Desktop${e}[0m"
Write-Host "  ${e}[38;2;80;100;140m  [6] Aplicar wallpaper${e}[0m"
Write-Host ""
Wait-Key
