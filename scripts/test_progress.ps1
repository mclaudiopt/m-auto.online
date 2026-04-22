# Test Progress Bar
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null
$e = [char]27

function Show-Progress {
    param([int]$Percent, [int]$Width = 50, [string]$Label = "")

    $filled = [math]::Round($Percent / 100 * $Width)
    $empty = $Width - $filled

    if ($Percent -eq 100) {
        $fillColor = "46;204;113"   # Verde
        $emptyColor = "52;73;94"    # Cinza escuro
    } else {
        $fillColor = "52;152;219"   # Azul
        $emptyColor = "52;73;94"    # Cinza escuro
    }

    $barFilled = "${e}[48;2;${fillColor}m" + (" " * $filled) + "${e}[0m"
    $barEmpty = "${e}[48;2;${emptyColor}m" + (" " * $empty) + "${e}[0m"

    $percentText = "${e}[1;97m$Percent%${e}[0m".PadLeft(12)
    $labelText = if ($Label) { " ${e}[90m$Label${e}[0m" } else { "" }

    Write-Host -NoNewline "`r  $percentText $barFilled$barEmpty$labelText"

    if ($Percent -eq 100) { Write-Host "" }
}

Clear-Host
Write-Host ""
Write-Host "  ${e}[1;97mTeste Progress Bar (estilo AskUbuntu)${e}[0m"
Write-Host ""

for ($i = 0; $i -le 100; $i += 2) {
    Show-Progress -Percent $i -Label "A extrair ficheiro..."
    Start-Sleep -Milliseconds 50
}

Write-Host ""
Write-Host "  ${e}[38;2;46;204;113m[OK]${e}[0m  Concluido!"
Write-Host ""
