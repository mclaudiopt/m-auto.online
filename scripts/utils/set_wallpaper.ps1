# utils/set_wallpaper.ps1 - Aplicar wallpaper M-Auto
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$e = [char]27

function Set-WallpaperFromURL {
    param([string]$ImageURL)

    # Guardar em local permanente (nao temp - o Windows precisa do ficheiro)
    $destDir = "$env:APPDATA\M-Auto"
    $wallpaperPath = "$destDir\wallpaper.png"

    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A transferir wallpaper..." -NoNewline
    try {
        Invoke-WebRequest -Uri $ImageURL -OutFile $wallpaperPath -UseBasicParsing -ErrorAction Stop
        Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
    } catch {
        Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
        Write-Host "  ${e}[38;2;148;163;184m    Nao foi possivel transferir: $($_.Exception.Message)${e}[0m"
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

        # Confirmar via registry
        $regPath = "HKCU:\Control Panel\Desktop"
        Set-ItemProperty -Path $regPath -Name "Wallpaper" -Value $wallpaperPath -ErrorAction Stop

        Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
        Write-Host "  ${e}[38;2;148;163;184m  Guardado em: $wallpaperPath${e}[0m"
    } catch {
        Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
        Write-Host "  ${e}[38;2;148;163;184m    $_${e}[0m"
    }
}

# Execute
Set-WallpaperFromURL "https://raw.githubusercontent.com/mclaudiopt/m-auto.online/main/IMG/mauto/m-auto-rust.png"
