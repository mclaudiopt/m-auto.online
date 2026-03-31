# utils/set_wallpaper.ps1 - Aplicar wallpaper
param(
    [string]$WallpaperPath
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$e = [char]27

if (-not (Test-Path $WallpaperPath)) {
    Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m  Wallpaper nao encontrado: $WallpaperPath"
    return
}

Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A aplicar wallpaper..." -NoNewline

try {
    # Get full path
    $fullPath = (Resolve-Path $WallpaperPath).Path

    # Set wallpaper via registry (faster, no UAC prompt)
    $regPath = "HKCU:\Control Panel\Desktop"
    Set-ItemProperty -Path $regPath -Name "Wallpaper" -Value $fullPath -ErrorAction Stop

    # Refresh desktop
    Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;
    public class Wallpaper {
        [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        private static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
        public static void Set(string path) {
            SystemParametersInfo(20, 0, path, 3);
        }
    }
"@
    [Wallpaper]::Set($fullPath)

    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
} catch {
    Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
    Write-Host "  ${e}[38;2;148;163;184m    $_${e}[0m"
}
