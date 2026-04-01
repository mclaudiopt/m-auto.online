# sos/suspicious_processes.ps1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$e = [char]27
Write-Host ""
Write-Host "  ${e}[1;97mProcessos Suspeitos${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

$suspicious = @("miner","xmrig","cryptonight","bjw","tor","payload","inject","hook","keylog","rat","spy","stealer")
$procs = Get-Process -ErrorAction SilentlyContinue

$found = @()
foreach ($p in $procs) {
    foreach ($s in $suspicious) {
        if ($p.Name -like "*$s*" -or $p.MainWindowTitle -like "*$s*") {
            $found += $p
            break
        }
    }
}

if ($found.Count -gt 0) {
    Write-Host "  ${e}[38;2;239;68;68m[!]${e}[0m  Processos suspeitos encontrados:"
    Write-Host ""
    foreach ($p in $found) {
        Write-Host "  ${e}[38;2;239;68;68m·${e}[0m  $($p.Name) (PID: $($p.Id))"
    }
} else {
    Write-Host "  ${e}[38;2;34;197;94m✔${e}[0m  Nenhum processo suspeito encontrado."
}

Write-Host ""
Write-Host "  ${e}[38;2;148;163;184m[Processos em execucao]${e}[0m"
Get-Process | Sort-Object CPU -Descending | Select-Object -First 15 |
    Format-Table Name, Id, CPU, WorkingSet -AutoSize | Out-String | Write-Host
Write-Host ""
Read-Host "  Pressione ENTER para voltar"
