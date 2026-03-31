# prep/bitlocker_off.ps1 - Desativar BitLocker
$e = [char]27

Write-Host ""
Write-Host "  ${e}[1;97mBitLocker OFF${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

Write-Host "  ${e}[38;2;148;163;184m·${e}[0m  A desativar BitLocker..." -NoNewline

try {
    $bl = Get-BitLockerVolume -MountPoint C: -ErrorAction SilentlyContinue
    if ($bl -and $bl.ProtectionStatus -eq "On") {
        Disable-BitLocker -MountPoint C: -ErrorAction Stop | Out-Null
        Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
    } else {
        Write-Host "  ${e}[38;2;250;204;21m[JA FEITO]${e}[0m"
    }
} catch {
    Write-Host "  ${e}[38;2;239;68;68m[FALHOU]${e}[0m"
    Write-Host "  ${e}[38;2;148;163;184m    $_${e}[0m"
}

Write-Host ""
Read-Host "  Pressione ENTER para voltar"
