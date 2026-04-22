# M-Auto.online - Download: SDMEDIA.zip
# Validade: 1 hora a partir de agora
# Corre com: botao direito > Executar com PowerShell

$URL  = "https://8d2cf9429e3c19524a14a659e5a07183.r2.cloudflarestorage.com/m-auto-software/Daimler/Pack/Installer/SDMEDIA.zip?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=59cb46144927b03a7dc575be0b734ff4%2F20260413%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260413T134714Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&x-id=GetObject&X-Amz-Signature=9ad903f551e9c4bea3022b846836c401e47deef945b7c8cb302eb95baf23709c"
$DEST = "$env:USERPROFILE\Downloads\SDMEDIA.zip"

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host ""
Write-Host "  M-Auto.online - A descarregar: SDMEDIA.zip"
Write-Host "  Destino: $DEST"
Write-Host ""

try {
    Import-Module BitsTransfer -ErrorAction Stop
    $job = Start-BitsTransfer -Source $URL -Destination $DEST -Asynchronous -DisplayName "M-Auto: SDMEDIA.zip"

    while ($job.JobState -notin @("Transferred","Error","Cancelled")) {
        if ($job.BytesTotal -gt 0) {
            $pct = [int]($job.BytesTransferred / $job.BytesTotal * 100)
            $mb  = [math]::Round($job.BytesTransferred / 1MB, 1)
            $tot = [math]::Round($job.BytesTotal / 1MB, 1)
            Write-Host -NoNewline "  $pct% - ${mb} MB / ${tot} MB    "
        } else {
            Write-Host -NoNewline "  A iniciar...    "
        }
        Start-Sleep -Seconds 2
    }

    Write-Host ""

    if ($job.JobState -eq "Transferred") {
        Complete-BitsTransfer $job
        Write-Host "  OK - Download concluido: $DEST"
    } else {
        Write-Host "  ERRO: $($job.ErrorDescription)"
        Remove-BitsTransfer $job -ErrorAction SilentlyContinue
    }
} catch {
    Write-Host "  Erro: $_"
}

Write-Host ""
Read-Host "  Pressione ENTER para sair"
