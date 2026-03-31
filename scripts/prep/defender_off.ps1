# prep/defender_off.ps1 - Desativar Microsoft Defender
$e = [char]27

Write-Host ""
Write-Host "  ${e}[1;97mMicrosoft Defender OFF${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

$defSvc = Get-Service -Name WinDefend -ErrorAction SilentlyContinue
$defRunning = $defSvc -and ($defSvc.Status -eq 'Running')

Write-Host "  ${e}[38;2;148;163;184m·${e}[0m  A desativar Windows Defender..." -NoNewline

if (-not $defRunning) {
    Write-Host "  ${e}[38;2;250;204;21m[JA FEITO]${e}[0m"
} else {
    try {
        Set-MpPreference `
            -DisableRealtimeMonitoring $true `
            -DisableBehaviorMonitoring $true `
            -DisableIOAVProtection $true `
            -DisableScriptScanning $true `
            -DisableArchiveScanning $true `
            -DisableBlockAtFirstSeen $true `
            -MAPSReporting 0 `
            -SubmitSamplesConsent 2 `
            -ErrorAction Stop
        Stop-Service -Name WinDefend -Force -ErrorAction SilentlyContinue
        Set-Service  -Name WinDefend -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
    } catch {
        if ($_.Exception.Message -match "0x800106ba" -or $_.Exception.HResult -eq -2147023158) {
            Write-Host "  ${e}[38;2;250;204;21m[JA FEITO]${e}[0m"
        } else {
            Write-Host "  ${e}[38;2;239;68;68m[FALHOU]${e}[0m"
            Write-Host "  ${e}[38;2;148;163;184m    $_${e}[0m"
        }
    }
}

Write-Host ""
Read-Host "  Pressione ENTER para voltar"
