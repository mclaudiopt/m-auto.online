# utils/set_wallpaper.ps1 - Aplicar wallpaper M-Auto
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$e = [char]27

$ImageURL      = "https://raw.githubusercontent.com/mclaudiopt/m-auto.online/main/IMG/mauto/m-auto-rust.png"
$destDir       = "$env:APPDATA\M-Auto"
$wallpaperPath = "$destDir\wallpaper.png"

Write-Host ""
Write-Host "  ${e}[1;97mAplicar Wallpaper M-Auto${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

if (-not (Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
}

Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A transferir wallpaper..."
$downloaded = $false

# WebClient async com barra de progresso no terminal
try {
    $wc = New-Object System.Net.WebClient

    $global:wcDone  = $false
    $global:wcError = $null

    $progressSub = Register-ObjectEvent -InputObject $wc -EventName DownloadProgressChanged -Action {
        $pct   = $Event.SourceEventArgs.ProgressPercentage
        $recv  = [math]::Round($Event.SourceEventArgs.BytesReceived / 1KB, 0)
        $total = [math]::Round($Event.SourceEventArgs.TotalBytesToReceive / 1KB, 0)

        # Progress bar estilo AskUbuntu
        $width = 50
        $filled = [math]::Round($pct / 100 * $width)
        $empty = $width - $filled

        if ($pct -eq 100) {
            $fillColor = "46;204;113"
            $emptyColor = "52;73;94"
        } else {
            $fillColor = "52;152;219"
            $emptyColor = "52;73;94"
        }

        $e = [char]27
        $barFilled = "${e}[48;2;${fillColor}m" + (" " * $filled) + "${e}[0m"
        $barEmpty = "${e}[48;2;${emptyColor}m" + (" " * $empty) + "${e}[0m"
        $percentText = "${e}[1;97m$pct%${e}[0m".PadLeft(12)

        Write-Host -NoNewline "`r  $percentText $barFilled$barEmpty  ${e}[90m$recv KB / $total KB${e}[0m   "
    }

    $completedSub = Register-ObjectEvent -InputObject $wc -EventName DownloadFileCompleted -Action {
        $global:wcDone  = $true
        $global:wcError = $Event.SourceEventArgs.Error
    }

    $wc.DownloadFileAsync([Uri]$ImageURL, $wallpaperPath)

    $timeout = 60
    $elapsed = 0
    while (-not $global:wcDone -and $elapsed -lt $timeout) {
        Start-Sleep -Milliseconds 500
        $elapsed += 0.5
    }

    $wc.Dispose()
    Unregister-Event -SourceIdentifier $progressSub.Name   -ErrorAction SilentlyContinue
    Unregister-Event -SourceIdentifier $completedSub.Name  -ErrorAction SilentlyContinue
    Remove-Job -Name $progressSub.Name  -Force -ErrorAction SilentlyContinue
    Remove-Job -Name $completedSub.Name -Force -ErrorAction SilentlyContinue

    Write-Host ""

    if (-not $global:wcDone) {
        throw "Timeout apos ${timeout}s"
    }
    if ($global:wcError) {
        throw $global:wcError.Message
    }
    if (-not (Test-Path $wallpaperPath) -or (Get-Item $wallpaperPath).Length -eq 0) {
        throw "Ficheiro vazio ou nao criado"
    }

    $downloaded = $true
    Write-Host "  ${e}[38;2;34;197;94m  [OK] Download concluido.${e}[0m"

} catch {
    Write-Host ""
    Write-Host "  ${e}[38;2;239;68;68m  [ERRO] $($_.Exception.Message)${e}[0m"
}

if (-not $downloaded) {
    Write-Host ""
    Write-Host "  ${e}[38;2;239;68;68m✖${e}[0m  Nao foi possivel transferir o wallpaper."
    Write-Host "  ${e}[38;2;148;163;184m  Verifique a ligacao a internet.${e}[0m"
    Write-Host ""
    Read-Host "  Pressione ENTER para voltar"
    return
}

# Aplicar wallpaper
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A aplicar..." -NoNewline
try {
    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class WallpaperSetter {
    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    private static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
    public static void Set(string path) {
        SystemParametersInfo(20, 0, path, 3);
    }
}
"@ -ErrorAction SilentlyContinue

    [WallpaperSetter]::Set($wallpaperPath)
    $regPath = "HKCU:\Control Panel\Desktop"
    Set-ItemProperty -Path $regPath -Name "Wallpaper" -Value $wallpaperPath -ErrorAction Stop
    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
    Write-Host ""
    Write-Host "  ${e}[38;2;34;197;94m✔${e}[0m  Wallpaper aplicado com sucesso."
} catch {
    Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
    Write-Host "  ${e}[38;2;148;163;184m    $_${e}[0m"
}

Write-Host ""
Read-Host "  Pressione ENTER para voltar"
