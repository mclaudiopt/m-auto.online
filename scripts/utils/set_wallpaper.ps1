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

Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A transferir wallpaper..." -NoNewline

try {
    # WebClient - mais rapido e compativel com Windows 10/11
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($ImageURL, $wallpaperPath)
    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
} catch {
    Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
    Write-Host "  ${e}[38;2;148;163;184m    $($_.Exception.Message)${e}[0m"
    Write-Host ""
    Read-Host "  Pressione ENTER para voltar"
    return
}

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
