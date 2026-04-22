# progress_bar.ps1 - Unified Progress Bar Helper
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$e = [char]27

function Show-ProgressBar {
    param(
        [int]$Current,
        [int]$Total,
        [string]$Label = "",
        [int]$BarWidth = 40,
        [string]$Color = "100;149;237"  # Azul por defeito
    )

    $percent = [math]::Round(($Current / $Total) * 100)
    $filled = [math]::Round(($percent / 100) * $BarWidth)
    $empty = $BarWidth - $filled

    $bar = ("#" * $filled) + ("-" * $empty)

    $labelText = if ($Label) { "$Label " } else { "" }

    Write-Host -NoNewline "`r  ${labelText}[${e}[38;2;${Color}m$bar${e}[0m] $percent%  "

    if ($percent -eq 100) {
        Write-Host ""  # Nova linha no fim
    }
}

function Show-Spinner {
    param(
        [string]$Label = "A processar",
        [int]$Frame = 0
    )

    $frames = @('⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏')
    $spinner = $frames[$Frame % $frames.Count]

    Write-Host -NoNewline "`r  ${e}[38;2;100;149;237m$spinner${e}[0m  $Label  "
}

Export-ModuleMember -Function Show-ProgressBar, Show-Spinner
