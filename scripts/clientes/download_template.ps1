# M-Auto.online — Download
# Instrucoes: corra este ficheiro com o botao direito > "Executar com PowerShell"
# Nao e necessario instalar nada.

$NOME = "NOME_DO_SOFTWARE"
$URL  = "URL_AQUI"
$FILE = "NOME_FICHEIRO.zip"
$DEST = "$env:USERPROFILE\Downloads\$FILE"

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$e = [char]27

Write-Host ""
Write-Host "  ${e}[1;97mM-Auto.online${e}[0m  — Download: $NOME"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host "  Destino: $DEST"
Write-Host ""

try {
    Import-Module BitsTransfer -ErrorAction Stop

    $job = Start-BitsTransfer `
        -Source      $URL `
        -Destination $DEST `
        -Asynchronous `
        -DisplayName "M-Auto: $NOME"

    while ($job.JobState -notin @("Transferred", "Error", "Cancelled")) {
        if ($job.BytesTotal -gt 0) {
            $pct = [int]($job.BytesTransferred / $job.BytesTotal * 100)
            $mb  = [math]::Round($job.BytesTransferred / 1MB, 1)
            $tot = [math]::Round($job.BytesTotal / 1MB, 1)
            Write-Host -NoNewline "`r  ${e}[38;2;100;149;237m·${e}[0m  $pct% — ${mb} MB / ${tot} MB    "
        } else {
            Write-Host -NoNewline "`r  ${e}[38;2;100;149;237m·${e}[0m  A iniciar...    "
        }
        Start-Sleep -Seconds 2
    }

    Write-Host ""
    Write-Host ""

    if ($job.JobState -eq "Transferred") {
        Complete-BitsTransfer $job
        Write-Host "  ${e}[38;2;34;197;94m✔${e}[0m  Concluido: $DEST"
    } else {
        Write-Host "  ${e}[38;2;239;68;68m✗${e}[0m  Erro: $($job.ErrorDescription)"
        Remove-BitsTransfer $job -ErrorAction SilentlyContinue
    }

} catch {
    Write-Host "  ${e}[38;2;239;68;68m✗${e}[0m  Erro: $_"
}

Write-Host ""
Read-Host "  Pressione ENTER para sair"
