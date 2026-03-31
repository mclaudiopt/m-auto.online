# clients/tesla.ps1 - Tesla Client Setup
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$e = [char]27

Write-Host ""
Write-Host "  ${e}[1;97mTesla Setup${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

$completed = @()
$failed = @()

#-- 1. Criar pasta NAO MEXER no Desktop ───────────────────────────────────
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  Criar pasta NAO MEXER no Desktop?" -NoNewline
$response = Read-Host " [s/n]"
if ($response -match "^[sS]") {
    Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A criar..." -NoNewline
    try {
        $desktopPath = [Environment]::GetFolderPath("Desktop")
        $folderPath = Join-Path $desktopPath "NAO MEXER"

        # Criar pasta
        if (-not (Test-Path $folderPath)) {
            New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
        }

        # Proteger pasta (read-only)
        $folder = Get-Item $folderPath
        $folder.Attributes = "ReadOnly"

        # Tentar adicionar ícone personalizado (usar ícone proibido do sistema)
        $desktopIniPath = Join-Path $folderPath "desktop.ini"
        $desktopIniContent = @"
[.ShellClassInfo]
ConfirmFileOp=0
NoSharing=1
IconIndex=-1
IconResource=C:\Windows\System32\shell32.dll,-227

"@

        # Criar ficheiro desktop.ini
        Set-Content -Path $desktopIniPath -Value $desktopIniContent -Encoding ASCII -Force

        # Marcar como ficheiro de sistema/oculto
        $file = Get-Item $desktopIniPath -Force
        $file.Attributes = "Hidden,System"

        Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
        $completed += "Pasta NAO MEXER"
    } catch {
        Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
        Write-Host "  ${e}[38;2;148;163;184m    $_${e}[0m"
        $failed += "Pasta NAO MEXER"
    }
}

#-- 2. Aplicar Wallpaper Tesla ────────────────────────────────────────────
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  Aplicar Wallpaper Tesla?" -NoNewline
$response = Read-Host " [s/n]"
if ($response -match "^[sS]") {
    Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A aplicar..." -NoNewline
    try {
        # Verifica se existe em D:
        $wallpaperPath = "D:\wallpaper-tesla.png"
        if (Test-Path $wallpaperPath) {
            $regPath = "HKCU:\Control Panel\Desktop"
            Set-ItemProperty -Path $regPath -Name "Wallpaper" -Value $wallpaperPath -ErrorAction Stop

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
"@ -ErrorAction SilentlyContinue

            [Wallpaper]::Set($wallpaperPath)

            Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
            $completed += "Wallpaper Tesla"
        } else {
            Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
            Write-Host "  ${e}[38;2;148;163;184m    Ficheiro nao encontrado: $wallpaperPath${e}[0m"
            $failed += "Wallpaper Tesla"
        }
    } catch {
        Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
        Write-Host "  ${e}[38;2;148;163;184m    $_${e}[0m"
        $failed += "Wallpaper Tesla"
    }
}

#-- RESUMO ───────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m>> Resumo${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

if ($completed.Count -gt 0) {
    Write-Host "  ${e}[38;2;34;197;94m✓ Concluido${e}[0m]: $($completed -join ', ')"
}

if ($failed.Count -gt 0) {
    Write-Host "  ${e}[38;2;239;68;68m✗ Falhou${e}[0m}: $($failed -join ', ')"
}

Write-Host ""
Read-Host "  Pressione ENTER para voltar"
