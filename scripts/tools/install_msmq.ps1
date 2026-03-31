# tools/install_msmq.ps1 - MSMQ Queuing Services
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$e = [char]27

Write-Host ""
Write-Host "  ${e}[1;97mInstalar MSMQ Queuing Services${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

# Verificar se já está instalado
$msmqFeature = Get-WindowsOptionalFeature -Online -FeatureName MSMQ-Server -ErrorAction SilentlyContinue

if ($msmqFeature -and $msmqFeature.State -eq "Enabled") {
    Write-Host "  ${e}[38;2;34;197;94m✔${e}[0m  MSMQ já está instalado e ativo"
    Write-Host ""
    Read-Host "  Pressione ENTER para voltar"
    return
}

Write-Host "  ${e}[38;2;148;163;184m·${e}[0m  A instalar MSMQ Queuing Services..." -NoNewline

try {
    # Instalar todos os componentes MSMQ
    Enable-WindowsOptionalFeature -Online -FeatureName MSMQ-Server -All -NoRestart -ErrorAction Stop | Out-Null

    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"

    Write-Host "  ${e}[38;2;148;163;184m·${e}[0m  A iniciar serviços..." -NoNewline

    # Iniciar serviço MSMQ
    Start-Service -Name MSMQ -ErrorAction SilentlyContinue

    # Configurar para iniciar automaticamente
    Set-Service -Name MSMQ -StartupType Automatic -ErrorAction SilentlyContinue

    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"

    Write-Host ""
    Write-Host "  ${e}[38;2;34;197;94m✔${e}[0m  MSMQ Queuing Services instalado com sucesso."
    Write-Host "  ${e}[38;2;148;163;184m  Recomenda-se reiniciar o computador.${e}[0m"

} catch {
    Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
    Write-Host "  ${e}[38;2;239;68;68m✖${e}[0m  Erro na instalacao: $($_.Exception.Message)"
    Write-Host "  ${e}[38;2;148;163;184m  Certifique-se que tem permissoes de administrador.${e}[0m"
}

Write-Host ""
Read-Host "  Pressione ENTER para voltar"
