# tweaks/driverstoreexplorer.ps1 - Instalar DriverStoreExplorer
$e = [char]27

Write-Host ""
Write-Host "  ${e}[1;97mInstalar DriverStoreExplorer${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

Write-Host "  ${e}[38;2;100;149;237m>${e}[0m  Executando: winget install lostindark.DriverStoreExplorer"
Write-Host ""

try {
    & cmd /c "winget install lostindark.DriverStoreExplorer -e --silent" 2>&1 | ForEach-Object {
        if ($_ -match "Sucesso|Success|Instalado") {
            Write-Host "  ${e}[38;2;34;197;94m$_${e}[0m"
        } elseif ($_ -match "Downloading|Installing") {
            Write-Host "  ${e}[38;2;100;149;237m$_${e}[0m"
        }
    }
    Write-Host ""
    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m]  DriverStoreExplorer instalado"
} catch {
    Write-Host "  ${e}[38;2;239;68;68m[X]   Erro ao instalar DriverStoreExplorer${e}[0m"
    Write-Host "  ${e}[38;2;148;163;184m    Certifica-te que winget esta instalado.${e}[0m"
    Write-Host "  ${e}[38;2;148;163;184m    $_${e}[0m"
}

Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m>> O que faz:${e}[0m]"
Write-Host "  ${e}[38;2;148;163;184m  Gerir, limpar e remover drivers desactivos do sistema.{{e}[0m"
Write-Host ""
Wait-Key
