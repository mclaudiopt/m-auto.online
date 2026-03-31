# clients/tesla.ps1 - Tesla Client Setup
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$e = [char]27

Write-Host ""
Write-Host "  ${e}[1;97mTesla Setup${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

$completed = @()
$failed = @()

#-- PASSO 0: Desabilitar Proteções (Firewall + Defender + Tamper) ────────
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  Desabilitar proteções do Windows?" -NoNewline
$response = Read-Host " [s/n]"
if ($response -match "^[sS]") {
    Write-Host ""
    try {
        # 0.1 Desabilitar Firewall
        Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A desabilitar Firewall..." -NoNewline
        Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False -ErrorAction Stop | Out-Null
        Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"

        # 0.2 Desabilitar Windows Defender
        Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A desabilitar Defender..." -NoNewline
        try {
            Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction Stop
            Stop-Service -Name WinDefend -Force -ErrorAction SilentlyContinue
            Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
        } catch {
            Write-Host "  ${e}[38;2;250;204;21m[!]${e}[0m"
        }

        # 0.3 Desabilitar Tamper Protection
        Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A desabilitar Tamper Protection..." -NoNewline
        try {
            $regPath = "HKLM:\SOFTWARE\Microsoft\Windows Defender\Features"
            $acl = Get-Acl $regPath -ErrorAction Stop
            $adminSid = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544")
            $acl.SetOwner($adminSid)
            $rule = New-Object System.Security.AccessControl.RegistryAccessRule(
                $adminSid, "FullControl",
                [System.Security.AccessControl.InheritanceFlags]"ContainerInherit,ObjectInherit",
                [System.Security.AccessControl.PropagationFlags]::None,
                [System.Security.AccessControl.AccessControlType]::Allow
            )
            $acl.AddAccessRule($rule)
            Set-Acl -Path $regPath -AclObject $acl -ErrorAction Stop
            Set-ItemProperty -Path $regPath -Name "TamperProtection" -Value 4 -ErrorAction Stop
            Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
        } catch {
            Write-Host "  ${e}[38;2;250;204;21m[!]${e}[0m"
        }

        Write-Host ""
        $completed += "Desabilitar Proteções"
    } catch {
        Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
        Write-Host "  ${e}[38;2;148;163;184m    $_${e}[0m"
        $failed += "Desabilitar Proteções"
    }
}

#-- PASSO 1: Trucks Setup (7-Zip + robocopy + Extract) ──────────────────
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  Instalar 7-Zip + Copiar Trucks.zip?" -NoNewline
$response = Read-Host " [s/n]"
if ($response -match "^[sS]") {
    Write-Host ""
    try {
        # 1.1 Instalar 7-Zip silent
        Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A instalar 7-Zip..." -NoNewline
        $7zipURL = "https://www.7-zip.org/a/7z2600-x64.exe"
        $7zipTMP = "$env:TEMP\7z_setup.exe"

        $installed7zip = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" `
            -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "*7-Zip*" }

        if (-not $installed7zip) {
            Invoke-WebRequest -Uri $7zipURL -OutFile $7zipTMP -UseBasicParsing -ErrorAction Stop -TimeoutSec 30
            Start-Process -FilePath $7zipTMP -ArgumentList "/S" -Wait -ErrorAction Stop
            Remove-Item $7zipTMP -Force -ErrorAction SilentlyContinue
            Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
        } else {
            Write-Host "  ${e}[38;2;250;204;21m[JA]${e}[0m"
        }

        # 1.2 Criar pasta C:\M-Auto
        Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A criar pasta C:\M-Auto..." -NoNewline
        $mAutoPath = "C:\M-Auto"
        if (-not (Test-Path $mAutoPath)) {
            New-Item -ItemType Directory -Path $mAutoPath -Force | Out-Null
        }
        Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"

        # 1.3 Copiar Trucks.zip com robocopy (muito mais rápido)
        Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A copiar Trucks.zip (robocopy)..." -NoNewline
        $sourceDir = "D:\marcelo"
        $sourceZip = "$sourceDir\Trucks.zip"

        if (-not (Test-Path $sourceZip)) {
            Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
            Write-Host "  ${e}[38;2;148;163;184m    Ficheiro nao encontrado: $sourceZip${e}[0m"
            $failed += "Trucks Setup"
        } else {
            robocopy $sourceDir $mAutoPath Trucks.zip /R:3 /W:1 | Out-Null
            if ($LASTEXITCODE -le 1) {
                Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"

                # 1.4 Descomprimir
                Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A descomprimir..." -NoNewline
                $extractPath = "$mAutoPath\Trucks"
                if (-not (Test-Path $extractPath)) {
                    New-Item -ItemType Directory -Path $extractPath -Force | Out-Null
                }

                $7zExe = "C:\Program Files\7-Zip\7z.exe"
                if (Test-Path $7zExe) {
                    & $7zExe x "$mAutoPath\Trucks.zip" -o"$extractPath" -y | Out-Null
                } else {
                    Expand-Archive -Path "$mAutoPath\Trucks.zip" -DestinationPath $extractPath -Force -ErrorAction Stop
                }
                Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"

                # 1.5 Apagar ficheiro .zip
                Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A limpar ficheiro .zip..." -NoNewline
                Remove-Item "$mAutoPath\Trucks.zip" -Force -ErrorAction SilentlyContinue
                Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"

                Write-Host ""
                $completed += "Trucks Setup"
            } else {
                Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
                $failed += "Trucks Setup"
            }
        }
    } catch {
        Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
        Write-Host "  ${e}[38;2;148;163;184m    $($_.Exception.Message)${e}[0m"
        $failed += "Trucks Setup"
    }
}

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

        # Adicionar ícone personalizado (usar ícone proibido do sistema)
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
