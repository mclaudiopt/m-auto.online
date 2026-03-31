# prep/secureboot_off.ps1 - Desativar Secure Boot (manual)
$e = [char]27

Write-Host ""
Write-Host "  ${e}[1;97mSecure Boot OFF${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

try {
    $sbEnabled = Confirm-SecureBootUEFI -ErrorAction SilentlyContinue
    if ($sbEnabled -eq $true) {
        Write-Host "  ${e}[38;2;250;204;21m[MANUAL]${e}[0m"
        Write-Host ""
        Write-Host "  ${e}[38;2;148;163;184mSecure Boot nao pode ser desativado por software.${e}[0m"
        Write-Host "  ${e}[38;2;148;163;184mSiga estes passos:${e}[0m"
        Write-Host ""
        Write-Host "  ${e}[38;2;100;149;237m1.${e}[0m  Reinicie o computador"
        Write-Host "  ${e}[38;2;100;149;237m2.${e}[0m  Pressione DEL, F2, F10, ESC ou outra tecla durante o boot"
        Write-Host "  ${e}[38;2;100;149;237m3.${e}[0m  Procure por 'Security' > 'Secure Boot' ou similar"
        Write-Host "  ${e}[38;2;100;149;237m4.${e}[0m  Desative a opcao"
        Write-Host "  ${e}[38;2;100;149;237m5.${e}[0m  Guarde as alteracoes (F10 ou Save & Exit)"
        Write-Host ""
    } else {
        Write-Host "  ${e}[38;2;250;204;21m[JA FEITO]${e}[0m"
    }
} catch {
    Write-Host "  ${e}[38;2;148;163;184m[INFO]${e}[0m  Legacy BIOS (Secure Boot nao disponivel)"
}

Write-Host ""
Read-Host "  Pressione ENTER para voltar"
